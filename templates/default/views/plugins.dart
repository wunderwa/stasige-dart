import 'package:pug_dart/pug_dart.dart' as pug;

Map<String, pug.PugHelper> get helpers => {
  'assets': (args) {
    final path = args.first?.toString() ?? '';
    return '/a/$path';
  },
  'dateFmt': (args) {
    final raw = args.first?.toString() ?? '';
    if (raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return dt.toIso8601String().substring(0, 16).replaceAll('T', ' ');
  },
};
