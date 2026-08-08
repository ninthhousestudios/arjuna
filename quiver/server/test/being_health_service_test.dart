// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:grpc/grpc.dart';
import 'package:quiver_core/quiver_core.dart';
import 'package:quiver_server/src/server.dart';
import 'package:test/test.dart';

void main() {
  late QuiverServer server;
  late ClientChannel channel;
  late BeingHealthServiceClient client;

  setUp(() async {
    server = QuiverServer(port: 0);
    await server.start();

    channel = ClientChannel(
      'localhost',
      port: server.port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    client = BeingHealthServiceClient(channel);
  });

  tearDown(() async {
    await channel.shutdown();
    await server.stop();
  });

  test('exact time returns one ranking of the seven karakas', () async {
    final request = BeingHealthRequest(
      datetimeIso: '2000-01-01T12:00:00Z',
      location: Location(latitude: 40.7128, longitude: -74.006),
      preset: CalculationPreset.ADITYA_PRESET,
    );

    final response = await client.rankBeings(request);

    expect(response.rankings, hasLength(1));
    final ranking = response.rankings.single;
    expect(ranking.jdUt, greaterThan(0));
    expect(ranking.beings, hasLength(7));

    // Healthiest first: ranks are non-decreasing and start at 1.
    expect(ranking.beings.first.rank, 1);
    for (var i = 1; i < ranking.beings.length; i++) {
      expect(
        ranking.beings[i].rank,
        greaterThanOrEqualTo(ranking.beings[i - 1].rank),
      );
    }

    // Each carries a body, its activated beings, and the split score.
    for (final b in ranking.beings) {
      expect(b.body, isNot(Body.BODY_UNSPECIFIED));
      expect(b.sign, inInclusiveRange(1, 12));
      expect(b.trimsamsaBeing.name, isNotEmpty);
      expect(b.horaBeing.name, isNotEmpty);
      expect(b.aditya.name, isNotEmpty);
      expect(b.score.body, b.body);
      // Total is the sum of the two ranking subtotals.
      expect(
        b.score.virupas,
        closeTo(b.score.strongVirupas + b.score.aspectVirupas, 1e-9),
      );
    }
  });

  test('score exposes per-state totals and the factor breakdown', () async {
    final request = BeingHealthRequest(
      datetimeIso: '2000-01-01T12:00:00Z',
      location: Location(latitude: 40.7128, longitude: -74.006),
      preset: CalculationPreset.ADITYA_PRESET,
    );

    final response = await client.rankBeings(request);
    final beings = response.rankings.single.beings;

    // At least one karaka has scored factors, and every factor names a state
    // and a source that survived the wire (not the UNSPECIFIED zero value).
    final withFactors = beings.where((b) => b.score.factors.isNotEmpty);
    expect(withFactors, isNotEmpty);
    for (final b in withFactors) {
      expect(b.score.byState, isNotEmpty);
      for (final f in b.score.factors) {
        expect(f.state, isNot(LajjitaadiState.LAJJITAADI_STATE_UNSPECIFIED));
        expect(f.factor.source, isNot(FactorSource.FACTOR_SOURCE_UNSPECIFIED));
      }
    }
  });

  test('period uncertainty returns one ranking per sampled chart', () async {
    final request = BeingHealthRequest(
      datetimeIso: '2000-01-01T12:00:00Z',
      location: Location(latitude: 40.7128, longitude: -74.006),
      preset: CalculationPreset.ADITYA_PRESET,
      timeUncertainty: TimeUncertainty(
        period: PeriodTime(startHour: 6, endHour: 12),
      ),
    );

    final response = await client.rankBeings(request);

    expect(response.rankings.length, greaterThan(1));
    final jds = <double>{};
    for (final ranking in response.rankings) {
      expect(ranking.beings, hasLength(7));
      jds.add(ranking.jdUt);
    }
    // Distinct instants → distinct Julian Days.
    expect(jds, hasLength(response.rankings.length));
  });

  test('returns INVALID_ARGUMENT when datetime_iso is missing', () async {
    final request = BeingHealthRequest(
      location: Location(latitude: 40.7128, longitude: -74.006),
    );

    expect(
      () => client.rankBeings(request),
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
    final request = BeingHealthRequest(datetimeIso: '2000-01-01T12:00:00Z');

    expect(
      () => client.rankBeings(request),
      throwsA(
        isA<GrpcError>().having(
          (e) => e.code,
          'code',
          StatusCode.invalidArgument,
        ),
      ),
    );
  });
}
