import 'package:grpc/grpc.dart';
import 'package:quiver_core/quiver_core.dart';
import 'package:quiver_server/src/server.dart';
import 'package:test/test.dart';

void main() {
  late QuiverServer server;
  late ClientChannel channel;
  late ChartServiceClient client;

  setUp(() async {
    server = QuiverServer(port: 0);
    await server.start();

    channel = ClientChannel(
      'localhost',
      port: server.port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    client = ChartServiceClient(channel);
  });

  tearDown(() async {
    await channel.shutdown();
    await server.stop();
  });

  test('calculate chart returns planet positions', () async {
    final request = CalcRequest(
      jdUt: 2451545.0, // J2000.0 — 2000-01-01 12:00 UT
      location: Location(latitude: 40.7128, longitude: -74.006),
    );

    final response = await client.calculate(request);
    final snapshot = response.snapshot;

    expect(snapshot.bodiesEcliptic, isNotEmpty);
    expect(snapshot.cusps, isNotEmpty);
    expect(snapshot.ascmc.ascendant, isNonZero);
    expect(snapshot.ascmc.mc, isNonZero);

    final sun = snapshot.bodiesEcliptic.firstWhere(
      (e) => e.body == Body.SUN,
    );
    // Sun at J2000.0 should be near 280° ecliptic longitude (Capricorn)
    expect(sun.position.longitude, closeTo(280.0, 2.0));
  });
}
