#!/usr/bin/env bash
# Build a single styled PDF from a JSON-listed array of markdown docs.
#
# Usage:
#   build-release-book.sh <AppName> <Version> <BrandColor> <DocsJsonString>
#
# Notes:
#   - Runs in the CALLER repo's working dir (the workflow checks the
#     repo out at $GITHUB_WORKSPACE which is the cwd).
#   - The shared umbrella tooling is expected at ./.umbrella when
#     invoked from CI, or at the umbrella repo root when invoked
#     locally (auto-detected).
set -euo pipefail

APP_NAME="${1:?app name required}"
VERSION="${2:?version required}"
BRAND_COLOR="${3:?brand color required (e.g. #FF6B9D or FF6B9D)}"
DOCS_JSON="${4:?docs json array required}"

# Strip leading '#' from brand color for LaTeX HTML colour spec.
BRAND_HEX="${BRAND_COLOR#\#}"

# Locate the umbrella tooling root (templates/release-book/template.latex).
if [ -f ".umbrella/templates/release-book/template.latex" ]; then
  UMB_ROOT="$(pwd)/.umbrella"
elif [ -f "templates/release-book/template.latex" ]; then
  UMB_ROOT="$(pwd)"
elif [ -n "${UMBRELLA_ROOT:-}" ] && [ -f "$UMBRELLA_ROOT/templates/release-book/template.latex" ]; then
  UMB_ROOT="$UMBRELLA_ROOT"
else
  echo "::error::Cannot find umbrella templates. Set UMBRELLA_ROOT env var." >&2
  exit 1
fi

TEMPLATE="$UMB_ROOT/templates/release-book/template.latex"
METADATA="$UMB_ROOT/templates/release-book/metadata.yml"
HEADER_TEX="$UMB_ROOT/templates/release-book/header.tex"

# Parse docs JSON into bash array.
if ! command -v jq >/dev/null; then
  echo "::error::jq is required" >&2
  exit 1
fi

mapfile -t DOCS < <(echo "$DOCS_JSON" | jq -r '.[]')

if [ "${#DOCS[@]}" -eq 0 ]; then
  echo "::error::docs JSON parsed to empty array" >&2
  exit 1
fi

# Filter to existing files; warn about missing.
FOUND=()
for d in "${DOCS[@]}"; do
  if [ -f "$d" ]; then
    FOUND+=("$d")
  else
    echo "::warning::doc '$d' not found in caller repo, skipping"
  fi
done

if [ "${#FOUND[@]}" -eq 0 ]; then
  echo "::error::no docs found from list" >&2
  exit 1
fi

OUT="${APP_NAME}-Release-Book-${VERSION}.pdf"
DATE_STR="$(date +'%B %d, %Y')"

echo "Building $OUT from ${#FOUND[@]} docs with brand #$BRAND_HEX"

pandoc \
  --pdf-engine=xelatex \
  --template="$TEMPLATE" \
  --metadata-file="$METADATA" \
  --include-in-header="$HEADER_TEX" \
  -V title="$APP_NAME" \
  -V version="$VERSION" \
  -V date="$DATE_STR" \
  -V brandcolor="$BRAND_HEX" \
  -V geometry:margin=1in \
  --top-level-division=chapter \
  --toc --toc-depth=2 \
  -o "$OUT" \
  "${FOUND[@]}"

echo "::notice::Built $OUT ($(stat -c%s "$OUT") bytes)"
ls -lh "$OUT"
