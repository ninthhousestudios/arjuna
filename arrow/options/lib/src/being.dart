// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import 'being_type.dart';

class Being {
  final String name;
  final BeingType type;
  final int signNumber;

  const Being({
    required this.name,
    required this.type,
    required this.signNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Being &&
          name == other.name &&
          type == other.type &&
          signNumber == other.signNumber;

  @override
  int get hashCode => Object.hash(name, type, signNumber);
}
