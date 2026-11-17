import 'dart:io';
import 'config.dart';

Future<bool> _hasEsbuild() async {
  try {
    final r = await Process.run('esbuild', ['--version']);
    return r.exitCode == 0;
  } on ProcessException {
    return false;
  }
}

Future<void> buildJs(CoreConfig cfg) async {
  final src = File(cfg.scriptIndexPath);
  if (!src.existsSync()) {
    stdout.writeln('js: skip (no ${src.path})');
    return;
  }
  if (!await _hasEsbuild()) {
    stderr.writeln('js: WARNING esbuild not found, skipping JS build');
    stderr.writeln('js:   install esbuild: https://esbuild.github.io/getting-started/');
    return;
  }
  final out = cfg.pathInBuild('index.${cfg.timekey}.js');
  await File(out).parent.create(recursive: true);

  final args = <String>[
    cfg.scriptIndexPath,
    '--bundle',
    '--outfile=$out',
    '--target=es2020',
    '--log-level=warning',
  ];
  if (!cfg.dev) args.add('--minify');

  final r = await Process.run('esbuild', args);
  if (r.exitCode != 0) {
    stderr.writeln('js: esbuild failed:\n${r.stderr}');
    return;
  }
  stdout.writeln('js: $out (${File(out).lengthSync()} bytes)');
}
