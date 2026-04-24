import 'package:arrow_options/arrow_options.dart';
import 'package:json_annotation/json_annotation.dart';

import 'body_position.dart';
import 'pheno_data.dart';
import 'star_data.dart';

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

class StarMapConverter
    implements JsonConverter<Map<Star, BodyPosition>, Map<String, dynamic>> {
  const StarMapConverter();

  @override
  Map<Star, BodyPosition> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(
        Star.values.firstWhere((s) => s.name == key),
        BodyPosition.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<Star, BodyPosition> object) {
    return object.map((key, value) => MapEntry(key.name, value.toJson()));
  }
}

class StringBodyPositionMapConverter
    implements
        JsonConverter<Map<String, BodyPosition>, Map<String, dynamic>> {
  const StringBodyPositionMapConverter();

  @override
  Map<String, BodyPosition> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(
        key,
        BodyPosition.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<String, BodyPosition> object) {
    return object.map((key, value) => MapEntry(key, value.toJson()));
  }
}

class StarDataMapConverter
    implements JsonConverter<Map<Star, StarData>, Map<String, dynamic>> {
  const StarDataMapConverter();

  @override
  Map<Star, StarData> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(
        Star.values.firstWhere((s) => s.name == key),
        StarData.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<Star, StarData> object) {
    return object.map((key, value) => MapEntry(key.name, value.toJson()));
  }
}

class StringStarDataMapConverter
    implements JsonConverter<Map<String, StarData>, Map<String, dynamic>> {
  const StringStarDataMapConverter();

  @override
  Map<String, StarData> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(
        key,
        StarData.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<String, StarData> object) {
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
