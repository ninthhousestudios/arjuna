import 'package:arrow_options/arrow_options.dart';
import 'package:json_annotation/json_annotation.dart';

import 'body_position.dart';
import 'pheno_data.dart';
import 'star_position.dart';

class BodyMapConverter
    implements JsonConverter<Map<Body, BodyPosition>, Map<String, dynamic>> {
  const BodyMapConverter();

  @override
  Map<Body, BodyPosition> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(
        Body.values.byName(key),
        BodyPosition.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<Body, BodyPosition> object) {
    return object.map((key, value) => MapEntry(key.name, value.toJson()));
  }
}

class StarPositionMapConverter
    implements JsonConverter<Map<Star, StarPosition>, Map<String, dynamic>> {
  const StarPositionMapConverter();

  @override
  Map<Star, StarPosition> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(
        Star.values.firstWhere(
          (s) => s.name == key,
          orElse: () => throw FormatException('Unknown Star enum value: $key'),
        ),
        StarPosition.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<Star, StarPosition> object) {
    return object.map((key, value) => MapEntry(key.name, value.toJson()));
  }
}

class StringStarPositionMapConverter
    implements
        JsonConverter<Map<String, StarPosition>, Map<String, dynamic>> {
  const StringStarPositionMapConverter();

  @override
  Map<String, StarPosition> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(
        key,
        StarPosition.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<String, StarPosition> object) {
    return object.map((key, value) => MapEntry(key, value.toJson()));
  }
}

class BodyPhenoMapConverter
    implements JsonConverter<Map<Body, PhenoData>, Map<String, dynamic>> {
  const BodyPhenoMapConverter();

  @override
  Map<Body, PhenoData> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(
        Body.values.byName(key),
        PhenoData.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<Body, PhenoData> object) {
    return object.map((key, value) => MapEntry(key.name, value.toJson()));
  }
}

class BodyDoubleMapConverter
    implements JsonConverter<Map<Body, double>, Map<String, dynamic>> {
  const BodyDoubleMapConverter();

  @override
  Map<Body, double> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) =>
          MapEntry(Body.values.byName(key), (value as num).toDouble()),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<Body, double> object) {
    return object.map((key, value) => MapEntry(key.name, value));
  }
}

class StarDoubleMapConverter
    implements JsonConverter<Map<Star, double>, Map<String, dynamic>> {
  const StarDoubleMapConverter();

  @override
  Map<Star, double> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(
        Star.values.firstWhere(
          (s) => s.name == key,
          orElse: () =>
              throw FormatException('Unknown Star enum value: $key'),
        ),
        (value as num).toDouble(),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<Star, double> object) {
    return object.map((key, value) => MapEntry(key.name, value));
  }
}

class StringDoubleMapConverter
    implements JsonConverter<Map<String, double>, Map<String, dynamic>> {
  const StringDoubleMapConverter();

  @override
  Map<String, double> fromJson(Map<String, dynamic> json) {
    return json.map(
        (key, value) => MapEntry(key, (value as num).toDouble()));
  }

  @override
  Map<String, dynamic> toJson(Map<String, double> object) => object;
}
