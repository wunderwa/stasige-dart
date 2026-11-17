import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

Future<void> runNew(List<String> rest) async {
  if (rest.isEmpty) {
    stderr.writeln('Usage: stasige new <path>');
    exit(1);
  }
  final name = rest.first.replaceAll(RegExp(r'^/+|/+$'), '');
  if (name.isEmpty) {
    stderr.writeln('new: empty name');
    exit(1);
  }

  final buildFile = File(p.join(Directory.current.path, 'build.json'));
  if (!buildFile.existsSync()) {
    stderr.writeln('new: build.json not found (run in site root)');
    exit(1);
  }
  final raw = loadYaml(buildFile.readAsStringSync()) as YamlMap;
  final langs = (raw['langs'] as YamlList).cast<String>();

  final dir = Directory(p.join('pages', name));
  if (dir.existsSync() && dir.listSync().isNotEmpty) {
    stderr.writeln('new: pages/$name/ already exists and is not empty');
    exit(1);
  }
  await dir.create(recursive: true);

  final slug = name.split('/').last;
  final title = slug.isEmpty ? slug : slug[0].toUpperCase() + slug.substring(1);

  for (final lang in langs) {
    final file = File(p.join(dir.path, 'index.$lang.md'));
    final content = '''
```yaml
layout: default
menuShort: $title
menuLong: $title
title: $title
```
<!--config-->
## $title{.text-center}

TODO: write content.
''';
    await file.writeAsString(content);
    stdout.writeln('new: ${file.path}');
  }
}
