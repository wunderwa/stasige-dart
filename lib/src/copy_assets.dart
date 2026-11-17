import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'config.dart';

const _rasterExts = {'.png', '.jpg', '.jpeg'};

Future<void> copyAssets(CoreConfig cfg) async {
  final src = Directory(cfg.assetsDir);
  if (!src.existsSync()) { stdout.writeln('assets: skip (no assets/)'); return; }
  final dst = Directory(cfg.pathInBuild('a'));
  var copied = 0, converted = 0, failed = 0;

  await for (final ent in src.list(recursive: true, followLinks: false)) {
    if (ent is! File) continue;
    final rel = p.relative(ent.path, from: cfg.assetsDir);
    if (p.basename(rel).startsWith('.')) continue;
    final ext = p.extension(rel).toLowerCase();

    if (_rasterExts.contains(ext)) {
      try {
        final bytes = await ent.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded == null) throw 'decode failed';
        final webp = img.encodeWebP(decoded);
        final target = File(p.join(dst.path, p.setExtension(rel, '.webp')));
        await target.parent.create(recursive: true);
        await target.writeAsBytes(webp);
        converted++;
      } catch (e) {
        stderr.writeln('assets: webp failed for $rel ($e), copying raw');
        final target = File(p.join(dst.path, rel));
        await target.parent.create(recursive: true);
        await ent.copy(target.path);
        failed++;
      }
      continue;
    }

    final target = File(p.join(dst.path, rel));
    await target.parent.create(recursive: true);
    await ent.copy(target.path);
    copied++;
  }
  stdout.writeln('assets: copied=$copied webp=$converted failed=$failed -> ${dst.path}');
}
