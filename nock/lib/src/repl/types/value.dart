// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

import '../error.dart';

abstract class NockValue {
  String display();

  NockValue access(String field) =>
      throw NockError('${typeName()} has no property "$field"');

  Future<NockValue> call(
    String method,
    List<NockValue> positional,
    Map<String, NockValue> named,
  ) => throw NockError('${typeName()} has no method "$method"');

  String typeName();
}

class NockString extends NockValue {
  final String value;
  NockString(this.value);

  @override
  String display() => value;

  @override
  String typeName() => 'string';
}

class NockNumber extends NockValue {
  final double value;
  NockNumber(this.value);

  @override
  String display() => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();

  @override
  String typeName() => 'number';
}

class NockBool extends NockValue {
  final bool value;
  NockBool(this.value);

  @override
  String display() => value.toString();

  @override
  String typeName() => 'bool';
}

class NockList extends NockValue {
  final List<NockValue> items;
  NockList(this.items);

  @override
  String display() => items.map((v) => v.display()).join('\n');

  @override
  String typeName() => 'list';
}
