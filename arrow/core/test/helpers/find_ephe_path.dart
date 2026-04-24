import 'dart:io';

String? findEphePath() {
  final env = Platform.environment['ARROW_EPHE_PATH'];
  if (env != null && Directory(env).existsSync()) return env;
  final home = Platform.environment['HOME'] ?? '';
  for (final p in [
    '$home/nhs/soft/astrology/libaditya/libaditya/ephe',
    '$home/.arrow/ephe',
    '/usr/local/share/swisseph',
  ]) {
    if (Directory(p).existsSync()) return p;
  }
  return null;
}
