#!/usr/bin/env bash
set -euo pipefail
PKG="$(cd "$(dirname "$0")" && pwd)"
cd "$PKG"

cat > lib/src/build_css.dart <<'EOF'
import 'dart:io';
import 'package:sass/sass.dart' as sass;
import 'config.dart';

Future<void> buildCss(CoreConfig cfg) async {
  final src = File(cfg.styleIndexPath);
  if (!src.existsSync()) { stdout.writeln('css: skip (no scss)'); return; }
  if (src.readAsStringSync().trim().isEmpty) { stdout.writeln('css: skip (empty)'); return; }
  final result = sass.compileToResult(cfg.styleIndexPath);
  final out = File(cfg.pathInBuild('index.${cfg.timekey}.css'));
  await out.parent.create(recursive: true);
  await out.writeAsString(result.css);
  stdout.writeln('css: ${out.path} (${result.css.length} bytes)');
}
EOF

cat > lib/src/run_site.dart <<'EOF'
import 'dart:io';
import 'package:args/args.dart';
import 'package:pug_dart/pug_dart.dart' as pug;
import 'config.dart';
import 'build_css.dart';
import 'build_html.dart';
import 'init.dart';

Future<void> runSite({
  required List<String> args,
  Map<String, pug.PugHelper> helpers = const {},
}) async {
  final defaultHelpers = <String, pug.PugHelper>{
    'assets': (a) => '/a/${a.first?.toString() ?? ''}',
    'dateFmt': (a) {
      final raw = a.first?.toString() ?? '';
      if (raw.isEmpty) return '';
      final dt = DateTime.tryParse(raw);
      if (dt == null) return raw;
      return dt.toIso8601String().substring(0, 16).replaceAll('T', ' ');
    },
  };
  final effectiveHelpers = <String, pug.PugHelper>{...defaultHelpers, ...helpers};

  final parser = ArgParser()
    ..addFlag('dev', abbr: 'D', negatable: false)
    ..addFlag('css', abbr: 'S', negatable: false)
    ..addFlag('js', abbr: 'J', negatable: false)
    ..addFlag('html', abbr: 'H', negatable: false)
    ..addFlag('img', abbr: 'I', negatable: false)
    ..addFlag('help', abbr: 'h', negatable: false);

  final cmd = args.isNotEmpty ? args.first : '';
  final rest = args.length > 1 ? args.sublist(1) : <String>[];

  if (cmd == 'help' || cmd == '' || cmd == '-h' || cmd == '--help') {
    print('Usage: stasige init | stasige build [--dev --css --js --html --img]');
    return;
  }
  if (cmd == 'init') { await runInit(); return; }
  if (cmd == 'build') {
    final argv = parser.parse(rest);
    final cfg = getConfig(dev: argv['dev'] as bool);
    final css = argv['css'] as bool, js = argv['js'] as bool,
          html = argv['html'] as bool, img = argv['img'] as bool;
    final all = !css && !js && !html && !img;
    if (all || css) await buildCss(cfg);
    if (all || js) stdout.writeln('js: not implemented yet');
    if (all || html) await taskHtml(cfg, effectiveHelpers);
    if (all || img) stdout.writeln('img: not implemented yet');
    print('Built: ${cfg.distDir}');
    return;
  }
  print('Unknown command: $cmd');
}
EOF

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

echo "==> full -b -D"
( cd "$TMP" && ./wrk -b -D )
CSS="$TMP/dev/index.dev.css"; HTML="$TMP/dev/index.html"
test -f "$CSS" && echo "OK  css ($(wc -c <"$CSS") b)" || { echo "MISS css"; exit 1; }
grep -q '/index.dev.css' "$HTML" && echo "OK  ref" || echo "MISS ref"
grep -q 'st-brand' "$CSS" && echo "OK  st-brand" || echo "MISS st-brand"

sleep 1.1; BEFORE=$(stat -c %Y "$HTML")
echo "==> -S only"
( cd "$TMP" && ./wrk -b -D -S )
AFTER=$(stat -c %Y "$HTML")
[ "$BEFORE" = "$AFTER" ] && echo "OK  html untouched" || echo "WARN html changed"

echo "tmp: $TMP"