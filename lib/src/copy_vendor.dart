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
