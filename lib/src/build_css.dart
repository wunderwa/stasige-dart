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
