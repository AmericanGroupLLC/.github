#!/usr/bin/env node
/*
 * Parse a RELEASE-VIDEO-SCRIPT.md into a JSON array of scenes.
 *
 * Format (one scene per markdown H2):
 *
 *   ## Title | <duration_seconds>
 *   - viewport: 1280x720
 *   - scroll: 0px           (or 50% / 800px)
 *   - wait: 500ms           (optional dwell after navigation)
 *   - caption: Some text {APP_NAME} {VERSION}
 *
 * Lines starting with '#' before the first H2 are ignored.
 *
 * Usage:
 *   node parse-video-script.js <path/to/RELEASE-VIDEO-SCRIPT.md> \
 *        [--app-name "Drift"] [--version "v1.0.0"]
 */
'use strict';
const fs = require('fs');
const path = require('path');

function parseArgs(argv) {
  const out = { _: [], appName: '', version: '' };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--app-name') out.appName = argv[++i] || '';
    else if (a === '--version') out.version = argv[++i] || '';
    else out._.push(a);
  }
  return out;
}

function parseDuration(spec, fallback = 4) {
  if (!spec) return fallback;
  const s = String(spec).trim();
  // "4" "4s" "1500ms" "0.5"
  const m = s.match(/^([0-9]*\.?[0-9]+)\s*(s|ms)?$/i);
  if (!m) return fallback;
  const n = parseFloat(m[1]);
  if (m[2] && m[2].toLowerCase() === 'ms') return n / 1000;
  return n;
}

function parseScroll(spec) {
  if (!spec) return { type: 'px', value: 0 };
  const s = String(spec).trim();
  let m = s.match(/^([0-9]+)\s*px$/i);
  if (m) return { type: 'px', value: parseInt(m[1], 10) };
  m = s.match(/^([0-9]+)\s*%$/);
  if (m) return { type: 'percent', value: parseInt(m[1], 10) };
  m = s.match(/^([0-9]+)$/);
  if (m) return { type: 'px', value: parseInt(m[1], 10) };
  if (s.toLowerCase() === 'top') return { type: 'px', value: 0 };
  if (s.toLowerCase() === 'bottom') return { type: 'percent', value: 100 };
  return { type: 'px', value: 0 };
}

function parseViewport(spec, fallback = { width: 1280, height: 720 }) {
  if (!spec) return fallback;
  const m = String(spec).trim().match(/^([0-9]+)\s*[xX×]\s*([0-9]+)$/);
  if (!m) return fallback;
  return { width: parseInt(m[1], 10), height: parseInt(m[2], 10) };
}

function substitute(s, vars) {
  return String(s || '')
    .replace(/\{APP_NAME\}/g, vars.appName)
    .replace(/\{VERSION\}/g, vars.version);
}

function parseScript(text, vars) {
  const lines = text.split(/\r?\n/);
  const scenes = [];
  let cur = null;

  for (const line of lines) {
    const h2 = line.match(/^##\s+(.+?)(?:\s*\|\s*(.+))?\s*$/);
    if (h2) {
      if (cur) scenes.push(cur);
      cur = {
        title: substitute(h2[1].trim(), vars),
        duration: parseDuration(h2[2], 4),
        viewport: { width: 1280, height: 720 },
        scroll: { type: 'px', value: 0 },
        wait_ms: 0,
        caption: ''
      };
      continue;
    }
    if (!cur) continue;
    const kv = line.match(/^\s*[-*]\s*([a-zA-Z_]+)\s*:\s*(.+?)\s*$/);
    if (!kv) continue;
    const key = kv[1].toLowerCase();
    const val = kv[2];
    switch (key) {
      case 'viewport': cur.viewport = parseViewport(val, cur.viewport); break;
      case 'scroll':   cur.scroll   = parseScroll(val); break;
      case 'wait': {
        const sec = parseDuration(val, 0);
        cur.wait_ms = Math.round(sec * 1000);
        break;
      }
      case 'caption':  cur.caption  = substitute(val, vars); break;
      case 'duration': cur.duration = parseDuration(val, cur.duration); break;
      default: /* ignore unknown keys */ break;
    }
  }
  if (cur) scenes.push(cur);
  return scenes;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args._[0]) {
    console.error('Usage: parse-video-script.js <script.md> [--app-name X] [--version vY]');
    process.exit(2);
  }
  const file = args._[0];
  if (!fs.existsSync(file)) {
    console.error(`File not found: ${file}`);
    process.exit(2);
  }
  const txt = fs.readFileSync(file, 'utf8');
  const scenes = parseScript(txt, {
    appName: args.appName || '',
    version: args.version || ''
  });
  if (scenes.length === 0) {
    console.error('::warning::No scenes parsed; emitting fallback single scene');
    scenes.push({
      title: 'Overview',
      duration: 5,
      viewport: { width: 1280, height: 720 },
      scroll: { type: 'px', value: 0 },
      wait_ms: 500,
      caption: substitute('{APP_NAME} {VERSION}', {
        appName: args.appName || '',
        version: args.version || ''
      })
    });
  }
  process.stdout.write(JSON.stringify(scenes, null, 2) + '\n');
}

if (require.main === module) main();

module.exports = { parseScript, parseDuration, parseScroll, parseViewport };
