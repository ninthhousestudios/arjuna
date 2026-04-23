import 'dart:io';
import 'package:drishti/drishti.dart';

void main(List<String> args) async {
  String? ephePath;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--ephe-path' && i + 1 < args.length) {
      ephePath = args[++i];
    }
  }
  ephePath ??= Platform.environment['DRISHTI_EPHE_PATH'];

  await startServer(ephePath: ephePath);
}
