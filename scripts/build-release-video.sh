#!/usr/bin/env bash
# Build a silent MP4 release video from a marketing index.html and a
# RELEASE-VIDEO-SCRIPT.md scene file.
#
# Usage:
#   build-release-video.sh <AppName> <Version> <BrandColor> \
#                          <VideoScriptPath> <MarketingHtmlPath>
#
# Produces: <AppName>-Release-<Version>.mp4 in cwd.
set -euo pipefail

APP_NAME="${1:?app name}"
VERSION="${2:?version}"
BRAND_COLOR="${3:-#1F6FEB}"
VIDEO_SCRIPT="${4:-RELEASE-VIDEO-SCRIPT.md}"
MARKETING_HTML="${5:-index.html}"

BRAND_HEX="${BRAND_COLOR#\#}"

# Locate umbrella tooling root.
if [ -f ".umbrella/scripts/parse-video-script.js" ]; then
  UMB_ROOT="$(pwd)/.umbrella"
elif [ -f "scripts/parse-video-script.js" ]; then
  UMB_ROOT="$(pwd)"
elif [ -n "${UMBRELLA_ROOT:-}" ] && [ -f "$UMBRELLA_ROOT/scripts/parse-video-script.js" ]; then
  UMB_ROOT="$UMBRELLA_ROOT"
else
  echo "::error::Cannot find umbrella tooling" >&2
  exit 1
fi

PARSER="$UMB_ROOT/scripts/parse-video-script.js"
TRANSITIONS="$UMB_ROOT/templates/release-video/transitions.json"
INTRO_HTML="$UMB_ROOT/templates/release-video/intro-template.html"
OUTRO_HTML="$UMB_ROOT/templates/release-video/outro-template.html"

if [ ! -f "$MARKETING_HTML" ]; then
  echo "::error::Marketing html not found at $MARKETING_HTML" >&2
  exit 1
fi

WORKDIR="$(mktemp -d -t relvideo-XXXXXX)"
trap 'rm -rf "$WORKDIR"' EXIT

# ----- 1. Parse video script (or auto-fallback if missing) -----
if [ -f "$VIDEO_SCRIPT" ]; then
  node "$PARSER" "$VIDEO_SCRIPT" --app-name "$APP_NAME" --version "$VERSION" \
    > "$WORKDIR/scenes.json"
else
  echo "::warning::No $VIDEO_SCRIPT found; building 1-scene fallback"
  cat > "$WORKDIR/scenes.json" <<JSON
[{"title":"Overview","duration":6,"viewport":{"width":1280,"height":720},"scroll":{"type":"px","value":0},"wait_ms":500,"caption":"$APP_NAME $VERSION"}]
JSON
fi

NUM_SCENES=$(node -e "console.log(require('$WORKDIR/scenes.json').length)")
echo "Parsed $NUM_SCENES scene(s) from $VIDEO_SCRIPT"

# ----- 2. Render intro + outro HTML cards -----
sed -e "s|{{APP_NAME}}|$APP_NAME|g" \
    -e "s|{{VERSION}}|$VERSION|g" \
    -e "s|{{BRAND_COLOR}}|#$BRAND_HEX|g" \
    "$INTRO_HTML" > "$WORKDIR/intro.html"
sed -e "s|{{APP_NAME}}|$APP_NAME|g" \
    -e "s|{{VERSION}}|$VERSION|g" \
    -e "s|{{BRAND_COLOR}}|#$BRAND_HEX|g" \
    "$OUTRO_HTML" > "$WORKDIR/outro.html"

# ----- 3. Drive Playwright to capture frames -----
cat > "$WORKDIR/capture.js" <<'JSNODE'
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

(async () => {
  const [, , scenesPath, htmlPath, introPath, outroPath, outDir, transitionsPath] = process.argv;
  const scenes = JSON.parse(fs.readFileSync(scenesPath, 'utf8'));
  const cfg = JSON.parse(fs.readFileSync(transitionsPath, 'utf8'));
  fs.mkdirSync(outDir, { recursive: true });

  const browser = await chromium.launch();
  try {
    // Intro
    {
      const ctx = await browser.newContext({ viewport: cfg.viewport });
      const page = await ctx.newPage();
      await page.goto('file://' + path.resolve(introPath));
      await page.waitForTimeout(200);
      await page.screenshot({
        path: path.join(outDir, 'intro.png'), fullPage: false
      });
      await ctx.close();
    }
    // Scenes
    for (let i = 0; i < scenes.length; i++) {
      const s = scenes[i];
      const ctx = await browser.newContext({ viewport: s.viewport || cfg.viewport });
      const page = await ctx.newPage();
      await page.goto('file://' + path.resolve(htmlPath));
      // Compute scroll target
      const scroll = s.scroll || { type: 'px', value: 0 };
      let yPx = 0;
      if (scroll.type === 'percent') {
        yPx = await page.evaluate((p) => {
          const h = Math.max(
            document.body.scrollHeight,
            document.documentElement.scrollHeight
          ) - window.innerHeight;
          return Math.max(0, Math.floor(h * p / 100));
        }, scroll.value);
      } else {
        yPx = scroll.value | 0;
      }
      await page.evaluate((y) => window.scrollTo({ top: y, behavior: 'instant' }), yPx);
      const wait = (s.wait_ms || 0) + 250;
      await page.waitForTimeout(wait);
      const fname = `scene_${String(i).padStart(3, '0')}.png`;
      await page.screenshot({ path: path.join(outDir, fname), fullPage: false });
      await ctx.close();
    }
    // Outro
    {
      const ctx = await browser.newContext({ viewport: cfg.viewport });
      const page = await ctx.newPage();
      await page.goto('file://' + path.resolve(outroPath));
      await page.waitForTimeout(200);
      await page.screenshot({
        path: path.join(outDir, 'outro.png'), fullPage: false
      });
      await ctx.close();
    }
  } finally {
    await browser.close();
  }
})().catch((e) => { console.error(e); process.exit(1); });
JSNODE

node "$WORKDIR/capture.js" \
  "$WORKDIR/scenes.json" \
  "$MARKETING_HTML" \
  "$WORKDIR/intro.html" \
  "$WORKDIR/outro.html" \
  "$WORKDIR/frames" \
  "$TRANSITIONS"

# ----- 4. Build per-scene MP4 clips with caption + ffmpeg, then concat -----
FPS=$(node -e "console.log(require('$TRANSITIONS').fps)")
INTRO_SEC=$(node -e "console.log(require('$TRANSITIONS').intro_seconds)")
OUTRO_SEC=$(node -e "console.log(require('$TRANSITIONS').outro_seconds)")
FONT=$(node -e "console.log(require('$TRANSITIONS').caption.font)")
CAP_SIZE=$(node -e "console.log(require('$TRANSITIONS').caption.size)")
CAP_Y_OFFSET=$(node -e "console.log(require('$TRANSITIONS').caption.y_from_bottom)")

# Helper: turn one PNG into an N-second MP4 with optional caption.
make_clip () {
  local png="$1"; local secs="$2"; local caption="${3:-}"; local out="$4"
  local vf="format=yuv420p"
  if [ -n "$caption" ]; then
    # Escape special chars for drawtext
    local safe
    safe=$(printf '%s' "$caption" | sed -e "s/\\\\/\\\\\\\\/g" -e "s/'/\\\\'/g" -e "s/:/\\\\:/g")
    vf="drawtext=fontfile=${FONT}:text='${safe}':fontcolor=white:fontsize=${CAP_SIZE}:box=1:boxcolor=black@0.55:boxborderw=16:x=(w-text_w)/2:y=h-${CAP_Y_OFFSET}-text_h,format=yuv420p"
  fi
  ffmpeg -y -loglevel error \
    -loop 1 -t "$secs" -i "$png" \
    -vf "$vf" -r "$FPS" \
    -c:v libx264 -preset veryfast -pix_fmt yuv420p \
    "$out"
}

CLIPS_LIST="$WORKDIR/clips.txt"
: > "$CLIPS_LIST"

# intro
make_clip "$WORKDIR/frames/intro.png" "$INTRO_SEC" "" "$WORKDIR/intro.mp4"
echo "file '$WORKDIR/intro.mp4'" >> "$CLIPS_LIST"

# scenes
for i in $(seq 0 $((NUM_SCENES - 1))); do
  idx=$(printf '%03d' "$i")
  png="$WORKDIR/frames/scene_${idx}.png"
  if [ ! -f "$png" ]; then
    echo "::warning::Missing frame for scene $i, skipping"
    continue
  fi
  dur=$(node -e "console.log(require('$WORKDIR/scenes.json')[$i].duration)")
  cap=$(node -e "console.log(require('$WORKDIR/scenes.json')[$i].caption || '')")
  out="$WORKDIR/scene_${idx}.mp4"
  make_clip "$png" "$dur" "$cap" "$out"
  echo "file '$out'" >> "$CLIPS_LIST"
done

# outro
make_clip "$WORKDIR/frames/outro.png" "$OUTRO_SEC" "" "$WORKDIR/outro.mp4"
echo "file '$WORKDIR/outro.mp4'" >> "$CLIPS_LIST"

OUT="${APP_NAME}-Release-${VERSION}.mp4"
ffmpeg -y -loglevel error \
  -f concat -safe 0 -i "$CLIPS_LIST" \
  -c copy "$OUT"

echo "::notice::Built $OUT ($(stat -c%s "$OUT") bytes)"
ls -lh "$OUT"
