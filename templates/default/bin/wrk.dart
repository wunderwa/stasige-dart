import 'package:stasige/stasige.dart';
import '../views/plugins.dart' as plugins;

Future<void> main(List<String> args) async {
  await runSite(args: args, helpers: plugins.helpers);
}
