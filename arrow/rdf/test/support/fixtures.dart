// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'dart:convert';
import 'dart:io';

import 'package:arrow_options/arrow_options.dart';
import 'package:arrow_rdf/arrow_rdf.dart';

/// Resolves a path under the `rdf/` package whether tests run from `rdf/` or
/// from the workspace root (`arrow/rdf/…`) — mirrors arrow's golden-test idiom.
File packageFile(String relative) {
  final local = File(relative);
  if (local.existsSync()) {
    return local;
  }
  return File('rdf/$relative');
}

/// The hermetic fixture: identity + view config + computed placements captured
/// from a real SWE run by `tool/gen_golden.dart`, so the golden test needs no
/// ephemeris.
final class GoldenFixture {
  final ChartIdentity identity;
  final ViewSpec view;
  final ComputedView computed;
  const GoldenFixture(this.identity, this.view, this.computed);

  static GoldenFixture load(String relative) {
    final root =
        jsonDecode(packageFile(relative).readAsStringSync())
            as Map<String, dynamic>;
    return GoldenFixture(
      _identity(root['identity'] as Map<String, dynamic>),
      _view(root['view'] as Map<String, dynamic>),
      _computed(root['computed'] as Map<String, dynamic>),
    );
  }

  static ChartIdentity _identity(Map<String, dynamic> m) => ChartIdentity(
    jd: (m['jd'] as num).toDouble(),
    lat: (m['lat'] as num).toDouble(),
    lon: (m['lon'] as num).toDouble(),
    name: m['name'] as String,
    gender: m['gender'] as String?,
    rodden: m['rodden'] as String?,
    tags: (m['tags'] as List<dynamic>).cast<String>(),
    placename: m['placename'] as String?,
    country: m['country'] as String?,
    civilDate: m['civilDate'] as String?,
    civilTime: m['civilTime'] as String?,
    utcOffset: (m['utcOffset'] as num?)?.toDouble(),
  );

  static ViewSpec _view(Map<String, dynamic> m) {
    final prov = m['provenance'] as Map<String, dynamic>;
    return ViewSpec(
      circle: Circle.values.byName(m['circle'] as String),
      signAyanamsa: Ayanamsa.values.byName(m['signAyanamsa'] as String),
      houseSystem: HouseSystem.values.byName(m['houseSystem'] as String),
      provenance: Provenance(
        engine: prov['engine'] as String,
        engineVersion: prov['engineVersion'] as String,
        ephemeris: prov['ephemeris'] as String,
      ),
    );
  }

  static ComputedView _computed(Map<String, dynamic> m) => ComputedView(
    lagnaSign: m['lagnaSign'] as int,
    placements: <ComputedPlacement>[
      for (final p in m['placements'] as List<dynamic>)
        _placement(p as Map<String, dynamic>),
    ],
  );

  static ComputedPlacement _placement(Map<String, dynamic> m) =>
      ComputedPlacement(
        body: Body.values.byName(m['body'] as String),
        longitude: (m['longitude'] as num).toDouble(),
        sign: m['sign'] as int,
        house: m['house'] as int,
        retrograde: m['retrograde'] as bool,
      );
}
