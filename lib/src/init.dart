import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

Future<Directory?> _locateTemplates() async {
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
      if (name == 'wrk') await Process.run('chmod', ['+x', target]);
    }
  }
}

String _pubCacheRoot() {
  final env = Platform.environment;
  if (env['PUB_CACHE'] != null && env['PUB_CACHE']!.isNotEmpty) return env['PUB_CACHE']!;
  if (env['HOME'] != null) return p.join(env['HOME']!, '.pub-cache');
  if (env['USERPROFILE'] != null) return p.join(env['USERPROFILE']!, '.pub-cache');
  return '';
}

String _sanitizePackageName(String s) {
  final n = s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  if (n.isEmpty || RegExp(r'^[0-9]').hasMatch(n)) return 'my_site';
  return n;
}

Future<String> _dependencyBlock() async {
  final lockPath = p.join(_pubCacheRoot(), 'global_packages', 'stasige', 'pubspec.lock');
  final lockFile = File(lockPath);
  if (lockFile.existsSync()) {
    try {
      final raw = loadYaml(lockFile.readAsStringSync()) as YamlMap;
      final entry = (raw['packages'] as YamlMap?)?['stasige'] as YamlMap?;
      if (entry != null) {
        final source = entry['source']?.toString();
        final desc = entry['description'];
        final version = entry['version']?.toString() ?? '0.1.0';
        if (source == 'git' && desc is YamlMap) {
          final url = desc['url']?.toString() ?? '';
          final ref = desc['resolved-ref']?.toString() ?? desc['ref']?.toString() ?? 'main';
          if (url.isNotEmpty) {
            return '  stasige:\n    git:\n      url: $url\n      ref: $ref\n';
          }
        }
        if (source == 'path' && desc is YamlMap) {
          final path = desc['path']?.toString() ?? '';
          if (path.isNotEmpty) {
            return '  stasige:\n    path: $path\n';
          }
        }
        if (source == 'hosted') {
          return '  stasige: ^$version\n';
        }
      }
    } catch (_) {}
  }
  try {
    final uri = await Isolate.resolvePackageUri(
      Uri.parse('package:stasige/stasige.dart'),
    );
    if (uri != null && uri.scheme == 'file') {
      final libDir = p.dirname(uri.toFilePath());
      final pkgRoot = p.dirname(libDir);
      if (!pkgRoot.contains('.pub-cache')) {
        return '  stasige:\n    path: $pkgRoot\n';
      }
      final py = File(p.join(pkgRoot, 'pubspec.yaml'));
      if (py.existsSync()) {
        final m = RegExp(r'^version:\s*(.+)$', multiLine: true)
            .firstMatch(py.readAsStringSync());
        final v = m?.group(1)?.trim() ?? '0.1.0';
        return '  stasige: ^$v\n';
      }
    }
  } catch (_) {}
  return '  stasige: ^0.1.0\n';
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

  final pubspecFile = File(p.join(cwd.path, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    final name = _sanitizePackageName(p.basename(cwd.path));
    final dep = await _dependencyBlock();
    final content =
        'name: $name\npublish_to: none\n\nenvironment:\n  sdk: ^3.5.0\n\ndev_dependencies:\n$dep';
    await pubspecFile.writeAsString(content);
    stdout.writeln('init: created pubspec.yaml ($name)');
  } else {
    stdout.writeln('init: pubspec.yaml exists, keeping it');
  }

  stdout.writeln('init: ${templates.path} -> ${cwd.path}');
  await _copyDir(templates, cwd);
  stdout.writeln('init: done. Next: dart pub get && ./wrk -b -D');
}
