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
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
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
      preset: CalculationPreset.ADITYA_PRESET,
    );

    final response = await client.calculate(request);
    final snapshot = response.snapshot;

    expect(snapshot.bodiesEcliptic, isNotEmpty);
    expect(snapshot.cusps, isNotEmpty);
    expect(snapshot.ascmc.ascendant, isNonZero);
    expect(snapshot.ascmc.mc, isNonZero);

    final sun = snapshot.bodiesEcliptic.firstWhere((e) => e.body == Body.SUN);
    // Sun at J2000.0 should be near 280° ecliptic longitude (Capricorn)
    expect(sun.position.longitude, closeTo(280.0, 2.0));
  });

  test('calculate chart returns being placements for all grahas', () async {
    final request = CalcRequest(
      jdUt: 2451545.0,
      location: Location(latitude: 40.7128, longitude: -74.006),
      preset: CalculationPreset.ADITYA_PRESET,
    );

    final response = await client.calculate(request);
    final placements = response.placements;

    // 9 grahas: Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Rahu, Ketu
    expect(placements, hasLength(9));

    for (final p in placements) {
      expect(p.body, isNot(Body.BODY_UNSPECIFIED));
      expect(p.trimsamsaBeing.name, isNotEmpty);
      expect(p.trimsamsaBeing.type, isNot(BeingType.BEING_TYPE_UNSPECIFIED));
      expect(p.horaBeing.name, isNotEmpty);
      expect(p.hora, isNot(Hora.HORA_UNSPECIFIED));
    }

    final sunPlacement = placements.firstWhere((p) => p.body == Body.SUN);
    expect(sunPlacement.trimsamsaBeing.signNumber, inInclusiveRange(1, 12));
    expect(sunPlacement.horaBeing.signNumber, inInclusiveRange(1, 12));
  });
}
