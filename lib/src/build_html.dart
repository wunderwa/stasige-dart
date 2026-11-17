import 'package:pug_dart/pug_dart.dart' as pug;
import 'config.dart';
import 'pages.dart';
import 'menus.dart';
import 'gen_page.dart';

/// Аналог taskHtml из core/task-html.ts
Future<void> taskHtml(
  CoreConfig cfg,
  Map<String, pug.PugHelper> helpers,
) async {
  final pages = getPageConfigList(cfg);
  final menus = getMenus(pages, cfg.build.langs);

  for (final page in pages) {
    await genPage(cfg: cfg, page: page, menus: menus, helpers: helpers);
  }
}
