import 'menus.dart';

class PageLang {
  final String url;
  final String title;
  final String lang;
  final bool disabled;
  PageLang({required this.url, required this.title, required this.lang, required this.disabled});
}

/// Аналог getPageLangs из core/utils/langs.ts
List<PageLang> getPageLangs(
  List<String> langs,
  String currentLang,
  Map<String, MenuItem> dirs,
) {
  final out = <PageLang>[];
  for (final lng in langs) {
    final it = dirs[lng];
    if (it == null) continue;
    out.add(PageLang(
      url: it.path,
      title: it.lang,
      lang: it.lang,
      disabled: it.lang == currentLang,
    ));
  }
  return out;
}
