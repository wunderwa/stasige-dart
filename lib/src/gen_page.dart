import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:pug_dart/pug_dart.dart' as pug;
import 'config.dart';
import 'pages.dart';
import 'menus.dart';
import 'langs.dart';


Map<String, dynamic> _readData(String dir) {
  final d = Directory(dir);
  if (!d.existsSync()) return {};
  final out = <String, dynamic>{};
  for (final f in d.listSync().whereType<File>()) {
    if (!f.path.endsWith('.json')) continue;
    final name = f.uri.pathSegments.last.replaceAll('.json', '');
    out[name] = jsonDecode(f.readAsStringSync());
  }
  return out;
}


Map<String, dynamic> _menusToMap(Map<String, List<MenuMainItem>> menus) {
  Map<String, dynamic> item(MenuMainItem i) => {
    'lang': i.lang,
    'path': i.path,
    'pathBase': i.pathBase,
    'menuShort': i.menuShort,
    'menuLong': i.menuLong,
    'title': i.title,
    'children': i.children.map(item).toList(),
  };
  return menus.map((k, v) => MapEntry(k, v.map(item).toList()));
}

Future<void> genPage({
  required CoreConfig cfg,
  required PageConfig page,
  required Menus menus,
  required Map<String, pug.PugHelper> helpers,
}) async {
  final viewsDir = p.join(cfg.root.path, 'views');
  final layoutFile = p.join(viewsDir, 'layouts', '${page.layout}.pug');
  final viewFile = p.join(viewsDir, 'index.pug');

  final options = pug.PugOptions(helpers: helpers, allowLocalAssignments: true);

  final layoutLocals = <String, Object?>{
    'title': page.title,
    'menuShort': page.menuShort,
    'menuLong': page.menuLong,
    'body': page.body,
    'lang': page.lang,
    'path': page.path,
    'pathBase': page.pathBase,
    'langs': cfg.build.langs,
    'mainMenu': _menusToMap(menus.mainMenu),
    'linksByLang': menus.linksByLang,
    'linksByDir': menus.linksByDir,
    'timekey': cfg.timekey,
    'meta': cfg.build.meta,
    'links': cfg.build.links,
    'data': _readData(p.join(cfg.root.path, 'data')),
  };

  final layoutContent = await pug.renderFile(layoutFile, layoutLocals, options);

  final viewLocals = <String, Object?>{
    ...layoutLocals,
    'content': layoutContent,
    'pageLangs': getPageLangs(
      cfg.build.langs,
      page.lang,
      menus.linksByDir[page.pathBase] ?? {},
    ),
  };

  final html = await pug.renderFile(viewFile, viewLocals, options);

  // Убираем ведущий слэш, иначе p.join сбросит distDir
  final relPath = page.path.startsWith('/') ? page.path.substring(1) : page.path;
  final outFile = File(cfg.pathInBuild(p.join(relPath, 'index.html')));
  await outFile.parent.create(recursive: true);
  await outFile.writeAsString(html);
}
