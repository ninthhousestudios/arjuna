// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'package:arrow_options/arrow_options.dart' as arrow;

import '../generated/quiver/types.pb.dart' as qt;
import '../generated/quiver/types.pbenum.dart' as qe;

/// Shared arrow-domain → quiver-proto conversions for the common value types
/// (`Body`, `Being`, `BeingType`, `Hora`). One source of truth for both the
/// chart-calc response mapper and the being-health mapper.
class QuiverTypeMapper {
  const QuiverTypeMapper._();

  static qt.Being being(arrow.Being being) => qt.Being(
    name: being.name,
    type: beingType(being.type),
    signNumber: being.signNumber,
  );

  static qe.BeingType beingType(arrow.BeingType type) => switch (type) {
    arrow.BeingType.gandharva => qe.BeingType.GANDHARVA,
    arrow.BeingType.rakshasa => qe.BeingType.RAKSHASA,
    arrow.BeingType.rishi => qe.BeingType.RISHI,
    arrow.BeingType.yaksha => qe.BeingType.YAKSHA,
    arrow.BeingType.apsara => qe.BeingType.APSARA,
    arrow.BeingType.aditya => qe.BeingType.ADITYA_BEING,
    arrow.BeingType.naga => qe.BeingType.NAGA,
  };

  static qe.Hora hora(arrow.Hora hora) => switch (hora) {
    arrow.Hora.sun => qe.Hora.SUN_HORA,
    arrow.Hora.moon => qe.Hora.MOON_HORA,
  };

  static qe.Body body(arrow.Body body) => switch (body) {
    arrow.Body.sun => qe.Body.SUN,
    arrow.Body.moon => qe.Body.MOON,
    arrow.Body.mercury => qe.Body.MERCURY,
    arrow.Body.venus => qe.Body.VENUS,
    arrow.Body.mars => qe.Body.MARS,
    arrow.Body.jupiter => qe.Body.JUPITER,
    arrow.Body.saturn => qe.Body.SATURN,
    arrow.Body.rahu => qe.Body.RAHU,
    arrow.Body.ketu => qe.Body.KETU,
    _ => qe.Body.BODY_UNSPECIFIED,
  };
}
