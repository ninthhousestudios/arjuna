// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_position.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BodyPosition {

 double get longitude; double get latitude; double get distance; double get speedLongitude; double get speedLatitude; double get speedDistance;
/// Create a copy of BodyPosition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BodyPositionCopyWith<BodyPosition> get copyWith => _$BodyPositionCopyWithImpl<BodyPosition>(this as BodyPosition, _$identity);

  /// Serializes this BodyPosition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BodyPosition&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.speedLongitude, speedLongitude) || other.speedLongitude == speedLongitude)&&(identical(other.speedLatitude, speedLatitude) || other.speedLatitude == speedLatitude)&&(identical(other.speedDistance, speedDistance) || other.speedDistance == speedDistance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,longitude,latitude,distance,speedLongitude,speedLatitude,speedDistance);

@override
String toString() {
  return 'BodyPosition(longitude: $longitude, latitude: $latitude, distance: $distance, speedLongitude: $speedLongitude, speedLatitude: $speedLatitude, speedDistance: $speedDistance)';
}


}

/// @nodoc
abstract mixin class $BodyPositionCopyWith<$Res>  {
  factory $BodyPositionCopyWith(BodyPosition value, $Res Function(BodyPosition) _then) = _$BodyPositionCopyWithImpl;
@useResult
$Res call({
 double longitude, double latitude, double distance, double speedLongitude, double speedLatitude, double speedDistance
});




}
/// @nodoc
class _$BodyPositionCopyWithImpl<$Res>
    implements $BodyPositionCopyWith<$Res> {
  _$BodyPositionCopyWithImpl(this._self, this._then);

  final BodyPosition _self;
  final $Res Function(BodyPosition) _then;

/// Create a copy of BodyPosition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? longitude = null,Object? latitude = null,Object? distance = null,Object? speedLongitude = null,Object? speedLatitude = null,Object? speedDistance = null,}) {
  return _then(_self.copyWith(
longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,speedLongitude: null == speedLongitude ? _self.speedLongitude : speedLongitude // ignore: cast_nullable_to_non_nullable
as double,speedLatitude: null == speedLatitude ? _self.speedLatitude : speedLatitude // ignore: cast_nullable_to_non_nullable
as double,speedDistance: null == speedDistance ? _self.speedDistance : speedDistance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BodyPosition].
extension BodyPositionPatterns on BodyPosition {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BodyPosition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BodyPosition() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BodyPosition value)  $default,){
final _that = this;
switch (_that) {
case _BodyPosition():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BodyPosition value)?  $default,){
final _that = this;
switch (_that) {
case _BodyPosition() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double longitude,  double latitude,  double distance,  double speedLongitude,  double speedLatitude,  double speedDistance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BodyPosition() when $default != null:
return $default(_that.longitude,_that.latitude,_that.distance,_that.speedLongitude,_that.speedLatitude,_that.speedDistance);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double longitude,  double latitude,  double distance,  double speedLongitude,  double speedLatitude,  double speedDistance)  $default,) {final _that = this;
switch (_that) {
case _BodyPosition():
return $default(_that.longitude,_that.latitude,_that.distance,_that.speedLongitude,_that.speedLatitude,_that.speedDistance);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double longitude,  double latitude,  double distance,  double speedLongitude,  double speedLatitude,  double speedDistance)?  $default,) {final _that = this;
switch (_that) {
case _BodyPosition() when $default != null:
return $default(_that.longitude,_that.latitude,_that.distance,_that.speedLongitude,_that.speedLatitude,_that.speedDistance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BodyPosition implements BodyPosition {
  const _BodyPosition({required this.longitude, required this.latitude, required this.distance, required this.speedLongitude, required this.speedLatitude, required this.speedDistance});
  factory _BodyPosition.fromJson(Map<String, dynamic> json) => _$BodyPositionFromJson(json);

@override final  double longitude;
@override final  double latitude;
@override final  double distance;
@override final  double speedLongitude;
@override final  double speedLatitude;
@override final  double speedDistance;

/// Create a copy of BodyPosition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BodyPositionCopyWith<_BodyPosition> get copyWith => __$BodyPositionCopyWithImpl<_BodyPosition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BodyPositionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BodyPosition&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.speedLongitude, speedLongitude) || other.speedLongitude == speedLongitude)&&(identical(other.speedLatitude, speedLatitude) || other.speedLatitude == speedLatitude)&&(identical(other.speedDistance, speedDistance) || other.speedDistance == speedDistance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,longitude,latitude,distance,speedLongitude,speedLatitude,speedDistance);

@override
String toString() {
  return 'BodyPosition(longitude: $longitude, latitude: $latitude, distance: $distance, speedLongitude: $speedLongitude, speedLatitude: $speedLatitude, speedDistance: $speedDistance)';
}


}

/// @nodoc
abstract mixin class _$BodyPositionCopyWith<$Res> implements $BodyPositionCopyWith<$Res> {
  factory _$BodyPositionCopyWith(_BodyPosition value, $Res Function(_BodyPosition) _then) = __$BodyPositionCopyWithImpl;
@override @useResult
$Res call({
 double longitude, double latitude, double distance, double speedLongitude, double speedLatitude, double speedDistance
});




}
/// @nodoc
class __$BodyPositionCopyWithImpl<$Res>
    implements _$BodyPositionCopyWith<$Res> {
  __$BodyPositionCopyWithImpl(this._self, this._then);

  final _BodyPosition _self;
  final $Res Function(_BodyPosition) _then;

/// Create a copy of BodyPosition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? longitude = null,Object? latitude = null,Object? distance = null,Object? speedLongitude = null,Object? speedLatitude = null,Object? speedDistance = null,}) {
  return _then(_BodyPosition(
longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,speedLongitude: null == speedLongitude ? _self.speedLongitude : speedLongitude // ignore: cast_nullable_to_non_nullable
as double,speedLatitude: null == speedLatitude ? _self.speedLatitude : speedLatitude // ignore: cast_nullable_to_non_nullable
as double,speedDistance: null == speedDistance ? _self.speedDistance : speedDistance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
