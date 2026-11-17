#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

python3 - <<'PY'
import pathlib
f = pathlib.Path('lib/src/init.dart')
s = f.read_text()
old = r"return '  stasige:\n      path: $pkgRoot\n';"
new = r"return '  stasige:\n    path: $pkgRoot\n';"
if old in s:
    s = s.replace(old, new)
    f.write_text(s)
    print('fixed line 89')
else:
    print('line 89 pattern not found')
PY

grep -n "stasige:" lib/src/init.dart
dart analyze || true