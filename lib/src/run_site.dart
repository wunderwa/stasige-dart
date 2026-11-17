import 'dart:io';
import 'package:args/args.dart';
import 'package:pug_dart/pug_dart.dart' as pug;
import 'config.dart';
import 'build_css.dart';
import 'build_html.dart';
import 'init.dart';

Future<void> runSite({
  required List<String> args,
  Map<String, pug.PugHelper> helpers = const {},
}) async {
  final defaultHelpers = <String, pug.PugHelper>{
    'assets': (a) => '/a/${a.first?.toString() ?? ''}',
    'dateFmt': (a) {
      final raw = a.first?.toString() ?? '';
      if (raw.isEmpty) return '';
      final dt = DateTime.tryParse(raw);
      if (dt == null) return raw;
      return dt.toIso8601String().substring(0, 16).replaceAll('T', ' ');
    },
  };
  final effectiveHelpers = <String, pug.PugHelper>{...defaultHelpers, ...helpers};

  final parser = ArgParser()
    ..addFlag('dev', abbr: 'D', negatable: false)
    ..addFlag('css', abbr: 'S', negatable: false)
    ..addFlag('js', abbr: 'J', negatable: false)
    ..addFlag('html', abbr: 'H', negatable: false)
    ..addFlag('img', abbr: 'I', negatable: false)
    ..addFlag('help', abbr: 'h', negatable: false);

  final cmd = args.isNotEmpty ? args.first : '';
  final rest = args.length > 1 ? args.sublist(1) : <String>[];

  if (cmd == 'help' || cmd == '' || cmd == '-h' || cmd == '--help') {
    print('Usage: stasige init | stasige build [--dev --css --js --html --img]');
    return;
  }
  if (cmd == 'init') { await runInit(); return; }
  if (cmd == 'build') {
    final argv = parser.parse(rest);
    final cfg = getConfig(dev: argv['dev'] as bool);
    final css = argv['css'] as bool, js = argv['js'] as bool,
          html = argv['html'] as bool, img = argv['img'] as bool;
    final all = !css && !js && !html && !img;
    if (all || css) await buildCss(cfg);
    if (all || js) stdout.writeln('js: not implemented yet');
    if (all || html) await taskHtml(cfg, effectiveHelpers);
    if (all || img) stdout.writeln('img: not implemented yet');
    print('Built: ${cfg.distDir}');
    return;
  }
  print('Unknown command: $cmd');
}
