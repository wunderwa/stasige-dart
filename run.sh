#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "==> full dry-run (save to file)"
dart pub publish --dry-run > /tmp/pub_dry.txt 2>&1 || true

echo "==> templates tree (from dry-run)"
sed -n '/templates/,/^The server\|^Package\|^Validating\|^Total/p' /tmp/pub_dry.txt

echo "==> checks"
for f in \
  'templates/default/css/bootstrap-5.3.8.min.css' \
  'templates/default/pages/index.en.md' \
  'templates/default/data/example.json' \
  'templates/default/build.json' \
  'templates/default/bin/wrk.dart' \
  'templates/default/wrk' \
  'templates/default/assets/svg/github.svg' \
  'templates/default/styles/index.scss' \
  'templates/default/scripts/index.ts' \
  'templates/default/views/index.pug' \
  'templates/default/views/plugins.dart' \
  'templates/default/views/layouts/data.pug' \
  'templates/default/views/layouts/default.pug'
do
  if grep -qF "$f" /tmp/pub_dry.txt; then echo "OK  $f"; else echo "MISS $f"; fi
done

echo "==> undesired files"
for f in run.sh '.context/' '.ai-content' 'CONTEXT.txt' 'bin/site.dart' 'bin/debug_menu.dart'; do
  if grep -qF "$f" /tmp/pub_dry.txt; then echo "FAIL  $f is in archive"; else echo "OK  $f absent"; fi
done

echo "==> archive size"
grep 'Total compressed archive size' /tmp/pub_dry.txt || true