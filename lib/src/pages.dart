import 'dart:io';
import 'package:path/path.dart' as p;
import 'config.dart';
import 'markdown.dart';

/// Аналог PageConfig из types.ts
class PageConfig {
  final String lang;
  final String src;
  final String path;
  final String pathBase;
  final String title;
  final String layout;
  final String menuShort;
  final String menuLong;
  final String body;

  PageConfig({
    required this.lang,
    required this.src,
    required this.path,
    required this.pathBase,
    required this.title,
    required this.layout,
    required this.menuShort,
    required this.menuLong,
    required this.body,
  });
}

final pageRegExp = RegExp(r'index\.([a-z]{2})\.md$');

/// Аналог getPageConfigList из core/utils/pageConfigs.ts
List<PageConfig> getPageConfigList(CoreConfig cfg) {
  final mainLang = cfg.build.langs.first;
  final dir = Directory(cfg.pagesDir);
  if (!dir.existsSync()) return [];

  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => pageRegExp.hasMatch(f.path))
      .map((f) {
    final lang = pageRegExp.firstMatch(f.path)!.group(1)!;
    final rel = p.relative(f.path, from: cfg.pagesDir);
    final pathBase = p.dirname('/$rel');
    final isMain = lang == mainLang;
    final path = '${isMain ? '' : '/$lang'}$pathBase';
    final parsed = parseMd(f.path, {
      'langs': cfg.build.langs,
      'meta': cfg.build.meta,
      'links': cfg.build.links,
    });

    return PageConfig(
      lang: lang,
      src: f.path,
      path: path,
      pathBase: pathBase,
      title: parsed['title']?.toString() ?? '',
      layout: parsed['layout']?.toString() ?? 'default',
      menuShort: parsed['menuShort']?.toString() ?? '',
      menuLong: parsed['menuLong']?.toString() ?? '',
      body: parsed['body']?.toString() ?? '',
    );
  }).toList();
}
