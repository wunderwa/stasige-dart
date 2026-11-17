import 'pages.dart';

/// Аналог findPage из core/utils/findPage.ts
PageConfig? findPage(List<PageConfig> pages, {String? pathBase, String? lang}) {
  if (pages.isEmpty) return null;
  if (pathBase == null && lang == null) return pages.first;

  if (pathBase != null && lang != null) {
    final hit = pages.where((p) => p.pathBase == pathBase && p.lang == lang).firstOrNull;
    if (hit != null) return hit;
  }
  if (pathBase != null) {
    return pages.where((p) => p.pathBase == pathBase).firstOrNull ?? pages.first;
  }
  return pages.first;
}
