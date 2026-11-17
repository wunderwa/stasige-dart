import 'pages.dart';

class MenuItem {
  final String lang;
  final String path;
  final String pathBase;
  final String menuShort;
  final String menuLong;
  final String title;
  MenuItem({
    required this.lang,
    required this.path,
    required this.pathBase,
    required this.menuShort,
    required this.menuLong,
    required this.title,
  });
}

class MenuMainItem extends MenuItem {
  final List<MenuMainItem> children;
  MenuMainItem({
    required super.lang,
    required super.path,
    required super.pathBase,
    required super.menuShort,
    required super.menuLong,
    required super.title,
    required this.children,
  });
}

class Menus {
  final Map<String, Map<String, MenuItem>> linksByLang;
  final Map<String, Map<String, MenuItem>> linksByDir;
  final Map<String, List<MenuMainItem>> mainMenu;
  Menus({required this.linksByLang, required this.linksByDir, required this.mainMenu});
}

Map<String, Map<String, MenuItem>> _groupByLang(List<PageConfig> pages, List<String> langs) {
  final acc = <String, Map<String, MenuItem>>{};
  for (final pg in pages) {
    if (!langs.contains(pg.lang)) continue;
    acc.putIfAbsent(pg.lang, () => {});
    acc[pg.lang]![pg.pathBase] = MenuItem(
      lang: pg.lang, path: pg.path, pathBase: pg.pathBase,
      menuShort: pg.menuShort, menuLong: pg.menuLong, title: pg.title,
    );
  }
  return acc;
}

Map<String, Map<String, MenuItem>> _groupByDir(List<PageConfig> pages, List<String> langs) {
  final acc = <String, Map<String, MenuItem>>{};
  for (final pg in pages) {
    if (!langs.contains(pg.lang)) continue;
    acc.putIfAbsent(pg.pathBase, () => {});
    acc[pg.pathBase]![pg.lang] = MenuItem(
      lang: pg.lang, path: pg.path, pathBase: pg.pathBase,
      menuShort: pg.menuShort, menuLong: pg.menuLong, title: pg.title,
    );
  }
  return acc;
}

List<MenuMainItem> _groupChildren(Map<String, MenuItem> items) {
  final mapped = items.values.map((it) {
    final dirList = [it.lang, ...it.pathBase.split('/').where((d) => d.isNotEmpty)];
    return {
      'item': it,
      'id': dirList.join(':'),
      'pid': dirList.sublist(0, dirList.length - 1).join(':'),
    };
  }).toList();

  List<MenuMainItem> children(String pid) {
    return mapped.where((m) => m['pid'] == pid).map((m) {
      final it = m['item'] as MenuItem;
      return MenuMainItem(
        lang: it.lang, path: it.path, pathBase: it.pathBase,
        menuShort: it.menuShort, menuLong: it.menuLong, title: it.title,
        children: children(m['id'] as String),
      );
    }).toList();
  }

  return mapped.where((m) => m['pid'] == '').map((m) {
    final it = m['item'] as MenuItem;
    return MenuMainItem(
      lang: it.lang, path: it.path, pathBase: it.pathBase,
      menuShort: it.menuShort, menuLong: it.menuLong, title: it.title,
      children: children(m['id'] as String),
    );
  }).toList();
}

/// Аналог getMenus из core/utils/menus.ts
Menus getMenus(List<PageConfig> pages, List<String> langs) {
  final byLang = _groupByLang(pages, langs);
  final byDir = _groupByDir(pages, langs);
  final mainMenu = byLang.map((lang, items) => MapEntry(lang, _groupChildren(items)));
  return Menus(linksByLang: byLang, linksByDir: byDir, mainMenu: mainMenu);
}
