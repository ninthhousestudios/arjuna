// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart';

/// v0 calc-provenance stub (I9, minimal). Exactly the three fields chart.ttl v0
/// defines on `chart:View` — the attachment point. Full provenance (projection
/// mode, varga dignity method, full config) is ARP-4b, gated on the ontology
/// v1 extension (vidya ARP-2b); it is deliberately NOT modelled here so the
/// serializer emits nothing the approved ontology can't name.
final class Provenance {
  final String engine;
  final String engineVersion;
  final String ephemeris;
  const Provenance({
    required this.engine,
    required this.engineVersion,
    required this.ephemeris,
  });
}

/// The canonical configuration of a View: its identity for deterministic IRI
/// minting (I3) and its provenance stamp. Maps to arrow's two configs.
///
/// Tracer scope is one view family — sidereal · lahiri · whole-sign — but the
/// shape carries the general config so the standard slate (I11) drops in later.
///
/// Note the ontology/arrow vocabulary mismatch: arrow's [Circle] is only the
/// position of sign 1 (zodiac vs aditya); "sidereal"/"tropical" is a function of
/// the ayanamsa. The ontology's `chart:circle` blends the two (its example
/// values are "tropical"/"sidereal"/"aditya"), so [ontologyCircle] /
/// [ontologyAyanamsa] translate arrow -> ontology rather than emitting raw
/// enum names.
final class ViewSpec {
  final Circle circle;
  final Ayanamsa signAyanamsa;
  final HouseSystem houseSystem;
  final Provenance provenance;

  const ViewSpec({
    required this.circle,
    required this.signAyanamsa,
    required this.houseSystem,
    required this.provenance,
  });

  /// The canonical, stable string form of the config — the SOLE input to the
  /// View IRI (I3). Two [ViewSpec]s mint the same View IRI iff this matches;
  /// provenance is excluded (it stamps, it does not identify).
  String get canonicalConfig =>
      'circle=${circle.name};ayanamsa=${signAyanamsa.name};'
      'house=${houseSystem.name}';

  /// A readable, IRI-safe slug of the config for the View IRI path segment.
  String get slug => '${circle.name}-${signAyanamsa.name}-${houseSystem.name}';

  /// The ontology's `chart:circle` value: the tropical/sidereal/aditya
  /// distinction, derived from arrow's [circle] + [signAyanamsa].
  String get ontologyCircle {
    if (circle == Circle.aditya) {
      return 'aditya';
    }
    return signAyanamsa.isTropical ? 'tropical' : 'sidereal';
  }

  /// The ontology's `chart:ayanamsa` value, or null for a tropical circle
  /// (absent per the ontology comment).
  String? get ontologyAyanamsa =>
      signAyanamsa.isTropical ? null : signAyanamsa.name;

  /// The ontology's `chart:houseSystem` value (e.g. "whole-sign"), from the
  /// enum's human label rather than its identifier (`wholeSigns`).
  String get ontologyHouseSystem =>
      houseSystem.label.toLowerCase().replaceAll(' ', '-');

  /// Arrow ephemeris config for this view (drives the expensive SWE call). The
  /// nakshatra frame is irrelevant to the tracer (placements only), so it
  /// tracks the sign ayanamsa; [CalcConfig] reads the ecliptic nak map.
  SweConfig toSweConfig() => SweConfig(
    signAyanamsa: signAyanamsa,
    nakAyanamsa: signAyanamsa,
    houseSystem: houseSystem,
  );

  /// Arrow derived-interpretation config for this view (free to vary).
  CalcConfig toCalcConfig() => CalcConfig(circle: circle, nakEquatorial: false);
}
