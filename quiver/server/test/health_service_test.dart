// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:grpc/grpc.dart';
import 'package:quiver_core/quiver_core.dart';
import 'package:quiver_server/src/server.dart';
import 'package:test/test.dart';

void main() {
  late QuiverServer server;
  late ClientChannel channel;
  late HealthServiceClient client;

  setUp(() async {
    server = QuiverServer(port: 0);
    await server.start();
    final port = server.port;

    channel = ClientChannel(
      'localhost',
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    client = HealthServiceClient(channel);
  });

  tearDown(() async {
    await channel.shutdown();
    await server.stop();
  });

  test('health check returns healthy', () async {
    final response = await client.check(HealthRequest());

    expect(response.healthy, isTrue);
    expect(response.version, equals('0.1.0'));
    expect(response.uptimeSeconds.toInt(), greaterThanOrEqualTo(0));
  });
}
