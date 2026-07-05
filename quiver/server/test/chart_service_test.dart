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

  test('exact time returns placements and atmakaraka', () async {
    final request = CalcRequest(
      datetimeIso: '2000-01-01T12:00:00Z',
      location: Location(latitude: 40.7128, longitude: -74.006),
      preset: CalculationPreset.ADITYA_PRESET,
    );

    final response = await client.calculate(request);

    expect(response.timeCertain, isTrue);
    expect(response.placements, hasLength(9));
    expect(response.atmakaraka.body, isNot(Body.BODY_UNSPECIFIED));
    expect(response.atmakaraka.signNumber, greaterThan(0));
  });

  test('returns correct being placements for J2000.0 New York', () async {
    final request = CalcRequest(
      datetimeIso: '2000-01-01T12:00:00Z',
      location: Location(latitude: 40.7128, longitude: -74.006),
      preset: CalculationPreset.ADITYA_PRESET,
    );

    final response = await client.calculate(request);

    Placement p(Body b) => response.placements.firstWhere((e) => e.body == b);

    expect(p(Body.SUN).trimsamsaBeing.name, 'Gautama');
    expect(p(Body.SUN).trimsamsaBeing.type, BeingType.RISHI);
    expect(p(Body.SUN).trimsamsaBeing.signNumber, 11);
    expect(p(Body.SUN).horaBeing.name, 'Pusha');
    expect(p(Body.SUN).horaBeing.type, BeingType.ADITYA_BEING);
    expect(p(Body.SUN).hora, Hora.SUN_HORA);

    expect(p(Body.VENUS).trimsamsaBeing.name, 'Purvacitti');
    expect(p(Body.VENUS).trimsamsaBeing.type, BeingType.APSARA);
    expect(p(Body.VENUS).horaBeing.name, 'Karkotaka');
    expect(p(Body.VENUS).horaBeing.type, BeingType.NAGA);
    expect(p(Body.VENUS).hora, Hora.MOON_HORA);

    expect(p(Body.KETU).trimsamsaBeing.name, 'Vishvaci');
    expect(p(Body.KETU).beingType, BeingType.APSARA);
    expect(p(Body.KETU).horaBeing.name, 'Airavata');
    expect(p(Body.KETU).horaBeing.type, BeingType.NAGA);
    expect(p(Body.KETU).hora, Hora.MOON_HORA);
  });

  test('period uncertainty returns uncertain placements', () async {
    final request = CalcRequest(
      datetimeIso: '2000-01-01T12:00:00Z',
      location: Location(latitude: 40.7128, longitude: -74.006),
      preset: CalculationPreset.ADITYA_PRESET,
      timeUncertainty: TimeUncertainty(
        period: PeriodTime(startHour: 6, endHour: 12),
      ),
    );

    final response = await client.calculate(request);

    expect(response.timeCertain, isFalse);
    expect(response.uncertainPlacements, hasLength(9));
    for (final up in response.uncertainPlacements) {
      expect(up.trimsamsaOptions, isNotEmpty);
      expect(up.horaOptions, isNotEmpty);
    }
    expect(response.uncertainAtmakaraka.options, isNotEmpty);
  });

  test(
    'unknown time returns uncertain placements with multiple samples',
    () async {
      final request = CalcRequest(
        datetimeIso: '2000-01-01T12:00:00Z',
        location: Location(latitude: 40.7128, longitude: -74.006),
        preset: CalculationPreset.ADITYA_PRESET,
        timeUncertainty: TimeUncertainty(
          unknown: UnknownTime(intervalHours: 4),
        ),
      );

      final response = await client.calculate(request);

      expect(response.timeCertain, isFalse);
      expect(response.uncertainPlacements, hasLength(9));
    },
  );

  test('returns INVALID_ARGUMENT when datetime_iso is missing', () async {
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

  test('returns INVALID_ARGUMENT when location is missing', () async {
    final request = CalcRequest(datetimeIso: '2000-01-01T12:00:00Z');

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

  test('returns INVALID_ARGUMENT for ISO without timezone', () async {
    final request = CalcRequest(
      datetimeIso: '2000-01-01T12:00:00',
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

  test('returns INVALID_ARGUMENT for out-of-range period hours', () async {
    final request = CalcRequest(
      datetimeIso: '2000-01-01T12:00:00Z',
      location: Location(latitude: 40.7128, longitude: -74.006),
      preset: CalculationPreset.ADITYA_PRESET,
      timeUncertainty: TimeUncertainty(
        period: PeriodTime(startHour: 25, endHour: 12),
      ),
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

  test('non-Z offset with period uncertainty samples local hours', () async {
    // 2000-01-01T17:30:00+05:30 = 2000-01-01T12:00:00Z (New Delhi)
    // Period 6-12 local should sample at local 06:00 and 12:00 IST
    final request = CalcRequest(
      datetimeIso: '2000-01-01T17:30:00+05:30',
      location: Location(latitude: 28.6139, longitude: 77.209),
      preset: CalculationPreset.ADITYA_PRESET,
      timeUncertainty: TimeUncertainty(
        period: PeriodTime(startHour: 6, endHour: 12),
      ),
    );

    final response = await client.calculate(request);

    expect(response.timeCertain, isFalse);
    expect(response.uncertainPlacements, hasLength(9));
    // Verify it didn't crash and returned valid results
    for (final up in response.uncertainPlacements) {
      expect(up.trimsamsaOptions, isNotEmpty);
    }
  });

  test('explicit ExactTime returns certain response', () async {
    final request = CalcRequest(
      datetimeIso: '2000-01-01T12:00:00Z',
      location: Location(latitude: 40.7128, longitude: -74.006),
      preset: CalculationPreset.ADITYA_PRESET,
      timeUncertainty: TimeUncertainty(exact: ExactTime()),
    );

    final response = await client.calculate(request);

    expect(response.timeCertain, isTrue);
    expect(response.placements, hasLength(9));
  });
}
