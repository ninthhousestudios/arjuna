// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:args/command_runner.dart';
import 'package:grpc/grpc.dart';
import 'package:quiver_core/quiver_core.dart';

class HealthCommand extends Command<void> {
  @override
  final name = 'health';

  @override
  final description = 'Check Quiver server health.';

  HealthCommand() {
    argParser
      ..addOption('host', defaultsTo: 'localhost', help: 'Quiver host')
      ..addOption('port', abbr: 'p', defaultsTo: '50051', help: 'Quiver port');
  }

  @override
  Future<void> run() async {
    final host = argResults!.option('host')!;
    final port = int.parse(argResults!.option('port')!);

    final channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    try {
      final client = HealthServiceClient(channel);
      final response = await client.check(HealthRequest());

      print('Quiver @ $host:$port');
      print('  healthy:  ${response.healthy}');
      print('  version:  ${response.version}');
      print('  uptime:   ${response.uptimeSeconds}s');
    } on GrpcError catch (e) {
      print('Failed to connect to Quiver @ $host:$port');
      print('  ${e.message}');
    } finally {
      await channel.shutdown();
    }
  }
}
