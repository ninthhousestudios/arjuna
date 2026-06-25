import 'package:grpc/grpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
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

  test('calculate chart via Timestamp datetime field', () async {
    final request = CalcRequest(
      datetime: Timestamp.fromDateTime(DateTime.utc(2000, 1, 1, 12)),
      location: Location(latitude: 40.7128, longitude: -74.006),
      preset: CalculationPreset.ADITYA_PRESET,
    );

    final response = await client.calculate(request);
    final sun = response.snapshot.bodiesEcliptic.firstWhere(
      (e) => e.body == Body.SUN,
    );
    expect(sun.position.longitude, closeTo(280.0, 2.0));
  });

  test('calculate chart via datetime_iso field', () async {
    final request = CalcRequest(
      datetimeIso: '2000-01-01T12:00:00Z',
      location: Location(latitude: 40.7128, longitude: -74.006),
      preset: CalculationPreset.ADITYA_PRESET,
    );

    final response = await client.calculate(request);
    final sun = response.snapshot.bodiesEcliptic.firstWhere(
      (e) => e.body == Body.SUN,
    );
    expect(sun.position.longitude, closeTo(280.0, 2.0));
  });

  test('returns INVALID_ARGUMENT when no time field is set', () async {
    final request = CalcRequest(
      location: Location(latitude: 40.7128, longitude: -74.006),
    );

    expect(
      () => client.calculate(request),
      throwsA(
        isA<GrpcError>().having(
          (e) => e.code,
          'code',
          StatusCode.invalidArgument,
        ),
      ),
    );
  });

  test('returns INVALID_ARGUMENT when multiple time fields are set', () async {
    final request = CalcRequest(
      jdUt: 2451545.0,
      datetimeIso: '2000-01-01T12:00:00Z',
      location: Location(latitude: 40.7128, longitude: -74.006),
    );

    expect(
      () => client.calculate(request),
      throwsA(
        isA<GrpcError>().having(
          (e) => e.code,
          'code',
          StatusCode.invalidArgument,
        ),
      ),
    );
  });

  test('calculate chart returns being placements for all grahas', () async {
    final request = CalcRequest(
      jdUt: 2451545.0,
      location: Location(latitude: 40.7128, longitude: -74.006),
      preset: CalculationPreset.ADITYA_PRESET,
    );

    final response = await client.calculate(request);
    final placements = response.placements;

    expect(placements, hasLength(9));

    PlanetPlacement p(Body b) => placements.firstWhere((e) => e.body == b);

    // Sun in Aquarius (sign 11): trimsamsa Rishi, sun hora → Aditya
    expect(p(Body.SUN).trimsamsaBeing.name, 'Gautama');
    expect(p(Body.SUN).trimsamsaBeing.type, BeingType.RISHI);
    expect(p(Body.SUN).trimsamsaBeing.signNumber, 11);
    expect(p(Body.SUN).horaBeing.name, 'Pusha');
    expect(p(Body.SUN).horaBeing.type, BeingType.ADITYA_BEING);
    expect(p(Body.SUN).hora, Hora.SUN_HORA);

    // Venus in Capricorn (sign 10): trimsamsa Apsara, moon hora → Naga
    expect(p(Body.VENUS).trimsamsaBeing.name, 'Purvacitti');
    expect(p(Body.VENUS).trimsamsaBeing.type, BeingType.APSARA);
    expect(p(Body.VENUS).horaBeing.name, 'Karkotaka');
    expect(p(Body.VENUS).horaBeing.type, BeingType.NAGA);
    expect(p(Body.VENUS).hora, Hora.MOON_HORA);

    // Ketu in Pisces (sign 12): trimsamsa Apsara, moon hora → Naga
    expect(p(Body.KETU).trimsamsaBeing.name, 'Vishvaci');
    expect(p(Body.KETU).beingType, BeingType.APSARA);
    expect(p(Body.KETU).horaBeing.name, 'Airavata');
    expect(p(Body.KETU).horaBeing.type, BeingType.NAGA);
    expect(p(Body.KETU).hora, Hora.MOON_HORA);
  });
}
