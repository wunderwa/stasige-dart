import 'dart:io';
import 'package:yaml/yaml.dart';
import 'markdown_attrs.dart';

const separator = '<!--config-->';

Map<String, dynamic> parseMd(String filePath, Map<String, dynamic> build) {
  final content = File(filePath).readAsStringSync();
  final parts = content.split(separator);
  final yamlPart = parts.first.trim()
      .replaceFirst(RegExp(r'^```yaml'), '')
      .replaceFirst(RegExp(r'```$'), '');
  final bodySrc = parts.length > 1 ? parts.sublist(1).join(separator) : '';

  final front = (loadYaml(yamlPart) as YamlMap?)?.cast<String, dynamic>() ?? {};

  return {
    'layout': 'default',
    ...front,
    'body': renderMarkdown(_applyVars(bodySrc, build)),
  };
}

String _applyVars(String src, Map<String, dynamic> build) {
  final map = <String, String>{};
  void walk(dynamic node, String prefix) {
    if (node is Map) {
      node.forEach((k, v) => walk(v, prefix.isEmpty ? k.toString() : '$prefix.$k'));
    } else if (node is List) {
      for (var i = 0; i < node.length; i++) {
        walk(node[i], '$prefix.$i');
      }
    } else {
      map['\${$prefix}'] = node.toString();
    }
  }
  walk(build, '');
  var out = src;
  map.forEach((k, v) => out = out.replaceAll(k, v));
  return out;
}
