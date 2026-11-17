import 'package:markdown/markdown.dart' as md;

class _Attrs {
  final String cleanText;
  final String? classes;
  final String? id;
  _Attrs(this.cleanText, this.classes, this.id);
}

_Attrs? _parse(String text) {
  final m = RegExp(r'\{([^}]+)\}\s*$').firstMatch(text);
  if (m == null) return null;
  final raw = m.group(1)!;
  final classes = <String>[];
  String? id;
  for (final part in raw.split(RegExp(r'\s+'))) {
    if (part.startsWith('.')) {
      classes.add(part.substring(1));
    } else if (part.startsWith('#')) {
      id = part.substring(1);
    }
  }
  if (classes.isEmpty && id == null) return null;
  return _Attrs(
    text.substring(0, m.start),
    classes.isEmpty ? null : classes.join(' '),
    id,
  );
}

void _apply(md.Element e) {
  if (e.children == null || e.children!.isEmpty) return;
  final last = e.children!.last;
  if (last is! md.Text) return;
  final a = _parse(last.text);
  if (a == null) return;
  if (a.classes != null) e.attributes['class'] = a.classes!;
  if (a.id != null) e.attributes['id'] = a.id!;
  e.children![e.children!.length - 1] = md.Text(a.cleanText);
}

void _walk(List<md.Node> nodes) {
  for (final n in nodes) {
    if (n is md.Element) {
      _apply(n);
      if (n.children != null) _walk(n.children!);
    }
  }
}

String renderMarkdown(String src) {
  final doc = md.Document(extensionSet: md.ExtensionSet.gitHubWeb);
  final nodes = doc.parseLines(src.split('\n'));
  _walk(nodes);
  return md.HtmlRenderer().render(nodes);
}
