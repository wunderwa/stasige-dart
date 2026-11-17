import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Соответствует core/utils/config.ts + types.ts (BuildConfig)
class BuildConfig {
  final List<String> langs;
  final Map<String, dynamic> meta;
  final Map<String, dynamic> links;
  BuildConfig({required this.langs, required this.meta, required this.links});
}

class CoreConfig {
  final Directory root;
  final BuildConfig build;
  final bool dev;
  final String timekey;
  final String distDir;
  final String pagesDir;
  final String viewsDir;
  final String dataDir;
  final String assetsDir;
  final String stylesDir;
  final String scriptsDir;
  final String cssDir;

  CoreConfig({
    required this.root,
    required this.build,
    required this.dev,
    required this.timekey,
    required this.distDir,
    required this.pagesDir,
    required this.viewsDir,
    required this.dataDir,
    required this.assetsDir,
    required this.stylesDir,
    required this.scriptsDir,
    required this.cssDir,
  });

  String pathInPages([String file = '']) => p.join(pagesDir, file);
  String pathInBuild([String file = '']) => p.join(distDir, file);
  String pathInAssets([String file = '']) => p.join(assetsDir, file);
  String pathInData([String file = '']) => p.join(dataDir, file);
  String pathInView([String file = '']) => p.join(viewsDir, file);

  String get styleIndexPath => p.join(stylesDir, 'index.scss');
  String get scriptIndexPath => p.join(scriptsDir, 'index.ts');
  String get cssVendorDir => cssDir;

  String layoutByName(String name) => p.join(viewsDir, 'layouts', '$name.pug');
}

/// Аналог getConfig({ mono, dev, siteName }) — без мультисайтовости.
CoreConfig getConfig({required bool dev}) {
  final root = Directory.current;
  final buildFile = File(p.join(root.path, 'build.json'));
  final raw = loadYaml(buildFile.readAsStringSync()) as YamlMap;

  final build = BuildConfig(
    langs: (raw['langs'] as YamlList).cast<String>(),
    meta: (raw['meta'] as YamlMap?)?.cast<String, dynamic>() ?? {},
    links: (raw['links'] as YamlMap?)?.cast<String, dynamic>() ?? {},
  );

  final distDir = p.join(root.path, dev ? 'dev' : 'dist');

  return CoreConfig(
    root: root,
    build: build,
    dev: dev,
    timekey: dev ? 'dev' : DateTime.now().millisecondsSinceEpoch.toRadixString(36),
    distDir: distDir,
    pagesDir: p.join(root.path, 'pages'),
    viewsDir: p.join(root.path, 'views'),
    dataDir: p.join(root.path, 'data'),
    assetsDir: p.join(root.path, 'assets'),
    stylesDir: p.join(root.path, 'styles'),
    scriptsDir: p.join(root.path, 'scripts'),
    cssDir: p.join(root.path, 'css'),
  );
}
