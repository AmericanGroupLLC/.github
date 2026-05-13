#!/usr/bin/env bash
# Generate desktop app icons (PNG, ICO, ICNS) from a brand colour and
# a single uppercase letter. Writes to the requested output dir.
#
# Usage:
#   make-icons.sh <#RRGGBB> <Letter> <outDir>
#
# Outputs:
#   $outDir/icon.png   1024x1024
#   $outDir/icon.ico   contains 16, 32, 48, 256
#   $outDir/icon.icns  best-effort — falls back to a copy of icon.png
#                      (electron-builder accepts .png on Linux runners
#                       and produces .icns via png2icns when available)
set -euo pipefail

BRAND="${1:?brand colour required, e.g. #FF6B9D}"
LETTER="${2:?icon letter required}"
OUT="${3:?output dir required}"

mkdir -p "$OUT"

# Strip leading '#' for ImageMagick.
HEX="${BRAND#\#}"

# Find a bold sans-serif font on common Linux distros.
FONT="DejaVu-Sans-Bold"
if ! fc-list 2>/dev/null | grep -qi "DejaVu Sans Bold"; then
  FONT="Liberation-Sans-Bold"
fi

if ! command -v convert >/dev/null 2>&1; then
  echo "::error::ImageMagick (convert) is required" >&2
  exit 1
fi

# 1024x1024 PNG with rounded background + centered letter.
convert -size 1024x1024 xc:"#$HEX" \
  -fill white -font "$FONT" -gravity center -pointsize 640 \
  -annotate +0+0 "$LETTER" \
  -alpha set -channel A -evaluate set 100% +channel \
  "$OUT/icon.png"

# Multi-resolution ICO.
convert "$OUT/icon.png" \
  -define icon:auto-resize=256,48,32,16 \
  "$OUT/icon.ico"

# ICNS (best effort). Use png2icns if available; else copy PNG.
if command -v png2icns >/dev/null 2>&1; then
  TMPDIR="$(mktemp -d)"
  for sz in 16 32 64 128 256 512 1024; do
    convert "$OUT/icon.png" -resize "${sz}x${sz}" "$TMPDIR/icon_${sz}.png"
  done
  png2icns "$OUT/icon.icns" \
    "$TMPDIR/icon_16.png" "$TMPDIR/icon_32.png" "$TMPDIR/icon_64.png" \
    "$TMPDIR/icon_128.png" "$TMPDIR/icon_256.png" "$TMPDIR/icon_512.png" \
    "$TMPDIR/icon_1024.png" 2>/dev/null || cp "$OUT/icon.png" "$OUT/icon.icns"
  rm -rf "$TMPDIR"
else
  cp "$OUT/icon.png" "$OUT/icon.icns"
fi

echo "Wrote icons to $OUT/"
ls -l "$OUT/icon.png" "$OUT/icon.ico" "$OUT/icon.icns"
