#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

python3 - <<'PY'
import pathlib
f = pathlib.Path('lib/src/run_site.dart')
s = f.read_text()

old = "  if (cmd == 'init') { await runInit(); return; }"
new = """  if (cmd == 'init') { await runInit(); return; }
  if (cmd == 'new') { await runNew(rest); return; }"""

if "cmd == 'new'" in s:
    print('already patched')
elif old in s:
    s = s.replace(old, new, 1)
    f.write_text(s)
    print('patched new')
else:
    print('ERROR: init one-liner not found')
PY

grep -n "cmd == 'init'\|cmd == 'new'" lib/src/run_site.dart || true

dart analyze || true

TMP="$(mktemp -d)"
cat > "$TMP/pubspec.yaml" <<YAML
name: e2e_site
publish_to: none
environment:
  sdk: ^3.5.0
dev_dependencies:
  stasige:
    path: /media/data/work/wunderwa/stasige-dart
YAML
( cd "$TMP" && dart pub get >/dev/null && dart run stasige init >/dev/null )

echo "==> stasige new hello"
( cd "$TMP" && dart run stasige new hello )

test -f "$TMP/pages/hello/index.en.md" && echo "OK  en" || { echo "MISS en"; exit 1; }
test -f "$TMP/pages/hello/index.ru.md" && echo "OK  ru" || { echo "MISS ru"; exit 1; }

echo "==> content en:"
cat "$TMP/pages/hello/index.en.md"

echo "==> duplicate blocked?"
( cd "$TMP" && dart run stasige new hello ) && echo "WARN dup allowed" || echo "OK  dup blocked"

echo "==> nested: stasige new docs/intro"
( cd "$TMP" && dart run stasige new docs/intro )
test -f "$TMP/pages/docs/intro/index.en.md" && echo "OK  nested en" || echo "MISS nested"

echo "==> build"
( cd "$TMP" && ./wrk -b -D )
test -f "$TMP/dev/hello/index.html" && echo "OK  hello html" || echo "MISS hello"
test -f "$TMP/dev/docs/intro/index.html" && echo "OK  docs/intro html" || echo "MISS nested html"

echo "tmp: $TMP"
