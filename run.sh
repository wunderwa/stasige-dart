#!/usr/bin/env bash
set -euo pipefail
PKG="$(cd "$(dirname "$0")" && pwd)"
cd "$PKG"

cat > lib/src/copy_vendor.dart <<'EOF'
import 'dart:io';
import 'package:path/path.dart' as p;
import 'config.dart';

Future<void> copyVendor(CoreConfig cfg) async {
  final src = Directory(cfg.cssVendorDir);
  if (!src.existsSync()) { stdout.writeln('vendor: skip (no css/)'); return; }
  final dst = Directory(cfg.pathInBuild('css'));
  var n = 0;
  await for (final ent in src.list(recursive: true, followLinks: false)) {
    if (ent is! File) continue;
    final rel = p.relative(ent.path, from: cfg.cssVendorDir);
    final target = File(p.join(dst.path, rel));
    await target.parent.create(recursive: true);
    await ent.copy(target.path);
    n++;
  }
  stdout.writeln('vendor: $n file(s) -> ${dst.path}');
}
EOF

# подключаем copyVendor в run_site.dart (в общий -b и в -S)
python3 - <<'PY'
import re, pathlib
f = pathlib.Path('lib/src/run_site.dart')
s = f.read_text()
if "import 'copy_vendor.dart';" not in s:
    s = s.replace("import 'build_html.dart';", "import 'build_html.dart';\nimport 'copy_vendor.dart';")
s = s.replace("if (all || css) await buildCss(cfg);",
              "if (all || css) { await buildCss(cfg); await copyVendor(cfg); }")
f.write_text(s)
print('patched run_site.dart')
PY

dart analyze || true

TMP="$(mktemp -d)"
cat > "$TMP/pubspec.yaml" <<YAML
name: e2e_site
publish_to: none
environment:
  sdk: ^3.5.0
dev_dependencies:
  stasige:
    path: $PKG
YAML
( cd "$TMP" && dart pub get >/dev/null && dart run stasige init >/dev/null )

echo "==> -b -D"
( cd "$TMP" && ./wrk -b -D )

V="$TMP/dev/css/bootstrap-5.3.8.min.css"
H="$TMP/dev/index.html"
test -f "$V" && echo "OK  vendor ($(wc -c <"$V") b)" || { echo "MISS vendor"; exit 1; }
grep -q '/css/bootstrap-5.3.8.min.css' "$H" && echo "OK  html refs bootstrap" || echo "MISS ref"

echo "==> -S only still copies vendor"
( cd "$TMP" && rm -rf dev && ./wrk -b -D -S )
test -f "$V" && echo "OK  vendor via -S" || { echo "MISS vendor -S"; exit 1; }

echo "tmp: $TMP"