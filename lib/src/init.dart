import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;

Future<Directory?> _locateTemplates() async {
  // 1) путь к пакету через resolvePackageUri
  try {
    final uri = await Isolate.resolvePackageUri(
      Uri.parse('package:stasige/stasige.dart'),
    );
    if (uri != null && uri.scheme == 'file') {
      final libDir = p.dirname(uri.toFilePath());
      final pkgRoot = p.dirname(libDir);
      final candidate = Directory(p.join(pkgRoot, 'templates', 'default'));
      if (candidate.existsSync()) return candidate;
    }
  } catch (_) {}
  // 2) cwd/templates/default (когда запускаем из корня пакета)
  final cwdCandidate = Directory(p.join(Directory.current.path, 'templates', 'default'));
  if (cwdCandidate.existsSync()) return cwdCandidate;
  return null;
}

Future<void> _copyDir(Directory src, Directory dst) async {
  await dst.create(recursive: true);
  await for (final ent in src.list(recursive: false, followLinks: false)) {
    final name = p.basename(ent.path);
    final target = p.join(dst.path, name);
    if (ent is Directory) {
      await _copyDir(ent, Directory(target));
    } else if (ent is File) {
      await ent.copy(target);
      if (name == 'wrk') {
        // сохранить exec-бит
        await Process.run('chmod', ['+x', target]);
      }
    }
  }
}

Future<void> runInit() async {
  final templates = await _locateTemplates();
  if (templates == null) {
    stderr.writeln('init: templates/default not found in package');
    exit(1);
  }
  final cwd = Directory.current;
  final existing = ['build.json', 'views', 'pages', 'wrk', 'bin']
      .where((e) => FileSystemEntity.typeSync(p.join(cwd.path, e)) != FileSystemEntityType.notFound)
      .toList();
  if (existing.isNotEmpty) {
    stderr.writeln('init: refusing to overwrite existing: ${existing.join(', ')}');
    stderr.writeln('      run in an empty directory');
    exit(1);
  }
  stdout.writeln('init: ${templates.path} -> ${cwd.path}');
  await _copyDir(templates, cwd);
  stdout.writeln('init: done. Now: ./wrk -b');
}
