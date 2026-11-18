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

  // Нормализуем: заменяем точки и решетки на пробел + символ,
  // чтобы гарантированно разделить их, даже если забыли пробел ({.btn.btn-secondary})
  final normalized = raw.replaceAll('.', ' .').replaceAll('#', ' #');

  for (final part in normalized.split(RegExp(r'\s+'))) {
    if (part.startsWith('.')) {
      final className = part.substring(1).trim();
      if (className.isNotEmpty) classes.add(className);
    } else if (part.startsWith('#')) {
      final idName = part.substring(1).trim();
      if (idName.isNotEmpty) id = idName;
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

  final text = last.text;
  final nl = text.lastIndexOf('\n');

  String? blockClasses;
  String? blockId;
  String remaining = text;

  // 1. Блочный атрибут — после переноса строки
  if (nl != -1) {
    final tail = text.substring(nl + 1).trim();
    final blockAttr = _parse(tail);
    if (blockAttr != null && blockAttr.cleanText.trim().isEmpty) {
      blockClasses = blockAttr.classes;
      blockId = blockAttr.id;
      remaining = text.substring(0, nl);
    }
  }

  // 2. Inline-атрибут — в конце оставшегося текста (без \n)
  if (!remaining.contains('\n')) {
    final inlineAttr = _parse(remaining);
    if (inlineAttr != null) {
      // Ищем предыдущий inline-элемент (например, <a> или <code>)
      md.Element? target;
      for (var i = e.children!.length - 1; i >= 0; i--) {
        final child = e.children![i];
        if (child is md.Element && child.tag != 'p') {
          target = child;
          break;
        }
      }

      // Если inline-элемента нет, применяем к самому блоку (fallback)
      final targetElement = target ?? e;

      if (inlineAttr.classes != null) {
        final old = targetElement.attributes['class'];
        targetElement.attributes['class'] =
        old == null ? inlineAttr.classes! : '$old ${inlineAttr.classes}';
      }
      if (inlineAttr.id != null) targetElement.attributes['id'] = inlineAttr.id!;

      remaining = inlineAttr.cleanText;
    }
  }

  // 3. Применяем блочные атрибуты к самому элементу
  if (blockClasses != null) {
    final old = e.attributes['class'];
    e.attributes['class'] =
    old == null ? blockClasses : '$old $blockClasses';
  }
  if (blockId != null) e.attributes['id'] = blockId;

  // 4. Обновляем текстовый узел
  if (remaining.trim().isEmpty) {
    e.children!.removeLast();
  } else {
    e.children![e.children!.length - 1] = md.Text(remaining);
  }
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
