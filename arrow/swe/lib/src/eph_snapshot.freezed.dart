// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'eph_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EphSnapshot {

 double get jdUt; Location get location; SweConfig get sweConfig;@BodyMapConverter() Map<Body, BodyPosition> get bodiesEcliptic;@BodyMapConverter() Map<Body, BodyPosition> get bodiesEquatorial;@BodyPhenoMapConverter() Map<Body, PhenoData> get phenoData; List<double> get cusps; AscMcPoints get ascmc; SunTimes get sunTimes; double get ayanamsaValue;@BodyDoubleMapConverter() Map<Body, double> get bodiesNakEclLon;@BodyDoubleMapConverter() Map<Body, double> get bodiesNakEquLon;@StarDoubleMapConverter() Map<Star, double> get starsNakEclLon;@StarDoubleMapConverter() Map<Star, double> get starsNakEquLon;@StringDoubleMapConverter() Map<String, double> get customStarsNakEclLon;@StringDoubleMapConverter() Map<String, double> get customStarsNakEquLon; List<double> get cuspsNakLon;@BodyMapConverter() Map<Body, BodyPosition>? get bodiesEclipticBarycentric;@BodyMapConverter() Map<Body, BodyPosition>? get bodiesEclipticHeliocentric;@StarPositionMapConverter() Map<Star, StarPosition> get stars;@StringStarPositionMapConverter() Map<String, StarPosition> get customStars;
/// Create a copy of EphSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EphSnapshotCopyWith<EphSnapshot> get copyWith => _$EphSnapshotCopyWithImpl<EphSnapshot>(this as EphSnapshot, _$identity);

  /// Serializes this EphSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EphSnapshot&&(identical(other.jdUt, jdUt) || other.jdUt == jdUt)&&(identical(other.location, location) || other.location == location)&&(identical(other.sweConfig, sweConfig) || other.sweConfig == sweConfig)&&const DeepCollectionEquality().equals(other.bodiesEcliptic, bodiesEcliptic)&&const DeepCollectionEquality().equals(other.bodiesEquatorial, bodiesEquatorial)&&const DeepCollectionEquality().equals(other.phenoData, phenoData)&&const DeepCollectionEquality().equals(other.cusps, cusps)&&(identical(other.ascmc, ascmc) || other.ascmc == ascmc)&&(identical(other.sunTimes, sunTimes) || other.sunTimes == sunTimes)&&(identical(other.ayanamsaValue, ayanamsaValue) || other.ayanamsaValue == ayanamsaValue)&&const DeepCollectionEquality().equals(other.bodiesNakEclLon, bodiesNakEclLon)&&const DeepCollectionEquality().equals(other.bodiesNakEquLon, bodiesNakEquLon)&&const DeepCollectionEquality().equals(other.starsNakEclLon, starsNakEclLon)&&const DeepCollectionEquality().equals(other.starsNakEquLon, starsNakEquLon)&&const DeepCollectionEquality().equals(other.customStarsNakEclLon, customStarsNakEclLon)&&const DeepCollectionEquality().equals(other.customStarsNakEquLon, customStarsNakEquLon)&&const DeepCollectionEquality().equals(other.cuspsNakLon, cuspsNakLon)&&const DeepCollectionEquality().equals(other.bodiesEclipticBarycentric, bodiesEclipticBarycentric)&&const DeepCollectionEquality().equals(other.bodiesEclipticHeliocentric, bodiesEclipticHeliocentric)&&const DeepCollectionEquality().equals(other.stars, stars)&&const DeepCollectionEquality().equals(other.customStars, customStars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,jdUt,location,sweConfig,const DeepCollectionEquality().hash(bodiesEcliptic),const DeepCollectionEquality().hash(bodiesEquatorial),const DeepCollectionEquality().hash(phenoData),const DeepCollectionEquality().hash(cusps),ascmc,sunTimes,ayanamsaValue,const DeepCollectionEquality().hash(bodiesNakEclLon),const DeepCollectionEquality().hash(bodiesNakEquLon),const DeepCollectionEquality().hash(starsNakEclLon),const DeepCollectionEquality().hash(starsNakEquLon),const DeepCollectionEquality().hash(customStarsNakEclLon),const DeepCollectionEquality().hash(customStarsNakEquLon),const DeepCollectionEquality().hash(cuspsNakLon),const DeepCollectionEquality().hash(bodiesEclipticBarycentric),const DeepCollectionEquality().hash(bodiesEclipticHeliocentric),const DeepCollectionEquality().hash(stars),const DeepCollectionEquality().hash(customStars)]);

@override
String toString() {
  return 'EphSnapshot(jdUt: $jdUt, location: $location, sweConfig: $sweConfig, bodiesEcliptic: $bodiesEcliptic, bodiesEquatorial: $bodiesEquatorial, phenoData: $phenoData, cusps: $cusps, ascmc: $ascmc, sunTimes: $sunTimes, ayanamsaValue: $ayanamsaValue, bodiesNakEclLon: $bodiesNakEclLon, bodiesNakEquLon: $bodiesNakEquLon, starsNakEclLon: $starsNakEclLon, starsNakEquLon: $starsNakEquLon, customStarsNakEclLon: $customStarsNakEclLon, customStarsNakEquLon: $customStarsNakEquLon, cuspsNakLon: $cuspsNakLon, bodiesEclipticBarycentric: $bodiesEclipticBarycentric, bodiesEclipticHeliocentric: $bodiesEclipticHeliocentric, stars: $stars, customStars: $customStars)';
}


}

/// @nodoc
abstract mixin class $EphSnapshotCopyWith<$Res>  {
  factory $EphSnapshotCopyWith(EphSnapshot value, $Res Function(EphSnapshot) _then) = _$EphSnapshotCopyWithImpl;
@useResult
$Res call({
 double jdUt, Location location, SweConfig sweConfig,@BodyMapConverter() Map<Body, BodyPosition> bodiesEcliptic,@BodyMapConverter() Map<Body, BodyPosition> bodiesEquatorial,@BodyPhenoMapConverter() Map<Body, PhenoData> phenoData, List<double> cusps, AscMcPoints ascmc, SunTimes sunTimes, double ayanamsaValue,@BodyDoubleMapConverter() Map<Body, double> bodiesNakEclLon,@BodyDoubleMapConverter() Map<Body, double> bodiesNakEquLon,@StarDoubleMapConverter() Map<Star, double> starsNakEclLon,@StarDoubleMapConverter() Map<Star, double> starsNakEquLon,@StringDoubleMapConverter() Map<String, double> customStarsNakEclLon,@StringDoubleMapConverter() Map<String, double> customStarsNakEquLon, List<double> cuspsNakLon,@BodyMapConverter() Map<Body, BodyPosition>? bodiesEclipticBarycentric,@BodyMapConverter() Map<Body, BodyPosition>? bodiesEclipticHeliocentric,@StarPositionMapConverter() Map<Star, StarPosition> stars,@StringStarPositionMapConverter() Map<String, StarPosition> customStars
});


$LocationCopyWith<$Res> get location;$SweConfigCopyWith<$Res> get sweConfig;$AscMcPointsCopyWith<$Res> get ascmc;$SunTimesCopyWith<$Res> get sunTimes;

}
/// @nodoc
class _$EphSnapshotCopyWithImpl<$Res>
    implements $EphSnapshotCopyWith<$Res> {
  _$EphSnapshotCopyWithImpl(this._self, this._then);

  final EphSnapshot _self;
  final $Res Function(EphSnapshot) _then;

/// Create a copy of EphSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jdUt = null,Object? location = null,Object? sweConfig = null,Object? bodiesEcliptic = null,Object? bodiesEquatorial = null,Object? phenoData = null,Object? cusps = null,Object? ascmc = null,Object? sunTimes = null,Object? ayanamsaValue = null,Object? bodiesNakEclLon = null,Object? bodiesNakEquLon = null,Object? starsNakEclLon = null,Object? starsNakEquLon = null,Object? customStarsNakEclLon = null,Object? customStarsNakEquLon = null,Object? cuspsNakLon = null,Object? bodiesEclipticBarycentric = freezed,Object? bodiesEclipticHeliocentric = freezed,Object? stars = null,Object? customStars = null,}) {
  return _then(_self.copyWith(
jdUt: null == jdUt ? _self.jdUt : jdUt // ignore: cast_nullable_to_non_nullable
as double,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location,sweConfig: null == sweConfig ? _self.sweConfig : sweConfig // ignore: cast_nullable_to_non_nullable
as SweConfig,bodiesEcliptic: null == bodiesEcliptic ? _self.bodiesEcliptic : bodiesEcliptic // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>,bodiesEquatorial: null == bodiesEquatorial ? _self.bodiesEquatorial : bodiesEquatorial // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>,phenoData: null == phenoData ? _self.phenoData : phenoData // ignore: cast_nullable_to_non_nullable
as Map<Body, PhenoData>,cusps: null == cusps ? _self.cusps : cusps // ignore: cast_nullable_to_non_nullable
as List<double>,ascmc: null == ascmc ? _self.ascmc : ascmc // ignore: cast_nullable_to_non_nullable
as AscMcPoints,sunTimes: null == sunTimes ? _self.sunTimes : sunTimes // ignore: cast_nullable_to_non_nullable
as SunTimes,ayanamsaValue: null == ayanamsaValue ? _self.ayanamsaValue : ayanamsaValue // ignore: cast_nullable_to_non_nullable
as double,bodiesNakEclLon: null == bodiesNakEclLon ? _self.bodiesNakEclLon : bodiesNakEclLon // ignore: cast_nullable_to_non_nullable
as Map<Body, double>,bodiesNakEquLon: null == bodiesNakEquLon ? _self.bodiesNakEquLon : bodiesNakEquLon // ignore: cast_nullable_to_non_nullable
as Map<Body, double>,starsNakEclLon: null == starsNakEclLon ? _self.starsNakEclLon : starsNakEclLon // ignore: cast_nullable_to_non_nullable
as Map<Star, double>,starsNakEquLon: null == starsNakEquLon ? _self.starsNakEquLon : starsNakEquLon // ignore: cast_nullable_to_non_nullable
as Map<Star, double>,customStarsNakEclLon: null == customStarsNakEclLon ? _self.customStarsNakEclLon : customStarsNakEclLon // ignore: cast_nullable_to_non_nullable
as Map<String, double>,customStarsNakEquLon: null == customStarsNakEquLon ? _self.customStarsNakEquLon : customStarsNakEquLon // ignore: cast_nullable_to_non_nullable
as Map<String, double>,cuspsNakLon: null == cuspsNakLon ? _self.cuspsNakLon : cuspsNakLon // ignore: cast_nullable_to_non_nullable
as List<double>,bodiesEclipticBarycentric: freezed == bodiesEclipticBarycentric ? _self.bodiesEclipticBarycentric : bodiesEclipticBarycentric // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>?,bodiesEclipticHeliocentric: freezed == bodiesEclipticHeliocentric ? _self.bodiesEclipticHeliocentric : bodiesEclipticHeliocentric // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>?,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as Map<Star, StarPosition>,customStars: null == customStars ? _self.customStars : customStars // ignore: cast_nullable_to_non_nullable
as Map<String, StarPosition>,
  ));
}
/// Create a copy of EphSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res> get location {
  
  return $LocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of EphSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SweConfigCopyWith<$Res> get sweConfig {
  
  return $SweConfigCopyWith<$Res>(_self.sweConfig, (value) {
    return _then(_self.copyWith(sweConfig: value));
  });
}/// Create a copy of EphSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AscMcPointsCopyWith<$Res> get ascmc {
  
  return $AscMcPointsCopyWith<$Res>(_self.ascmc, (value) {
    return _then(_self.copyWith(ascmc: value));
  });
}/// Create a copy of EphSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SunTimesCopyWith<$Res> get sunTimes {
  
  return $SunTimesCopyWith<$Res>(_self.sunTimes, (value) {
    return _then(_self.copyWith(sunTimes: value));
  });
}
}


/// Adds pattern-matching-related methods to [EphSnapshot].
extension EphSnapshotPatterns on EphSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EphSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EphSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EphSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _EphSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EphSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _EphSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double jdUt,  Location location,  SweConfig sweConfig, @BodyMapConverter()  Map<Body, BodyPosition> bodiesEcliptic, @BodyMapConverter()  Map<Body, BodyPosition> bodiesEquatorial, @BodyPhenoMapConverter()  Map<Body, PhenoData> phenoData,  List<double> cusps,  AscMcPoints ascmc,  SunTimes sunTimes,  double ayanamsaValue, @BodyDoubleMapConverter()  Map<Body, double> bodiesNakEclLon, @BodyDoubleMapConverter()  Map<Body, double> bodiesNakEquLon, @StarDoubleMapConverter()  Map<Star, double> starsNakEclLon, @StarDoubleMapConverter()  Map<Star, double> starsNakEquLon, @StringDoubleMapConverter()  Map<String, double> customStarsNakEclLon, @StringDoubleMapConverter()  Map<String, double> customStarsNakEquLon,  List<double> cuspsNakLon, @BodyMapConverter()  Map<Body, BodyPosition>? bodiesEclipticBarycentric, @BodyMapConverter()  Map<Body, BodyPosition>? bodiesEclipticHeliocentric, @StarPositionMapConverter()  Map<Star, StarPosition> stars, @StringStarPositionMapConverter()  Map<String, StarPosition> customStars)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EphSnapshot() when $default != null:
return $default(_that.jdUt,_that.location,_that.sweConfig,_that.bodiesEcliptic,_that.bodiesEquatorial,_that.phenoData,_that.cusps,_that.ascmc,_that.sunTimes,_that.ayanamsaValue,_that.bodiesNakEclLon,_that.bodiesNakEquLon,_that.starsNakEclLon,_that.starsNakEquLon,_that.customStarsNakEclLon,_that.customStarsNakEquLon,_that.cuspsNakLon,_that.bodiesEclipticBarycentric,_that.bodiesEclipticHeliocentric,_that.stars,_that.customStars);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double jdUt,  Location location,  SweConfig sweConfig, @BodyMapConverter()  Map<Body, BodyPosition> bodiesEcliptic, @BodyMapConverter()  Map<Body, BodyPosition> bodiesEquatorial, @BodyPhenoMapConverter()  Map<Body, PhenoData> phenoData,  List<double> cusps,  AscMcPoints ascmc,  SunTimes sunTimes,  double ayanamsaValue, @BodyDoubleMapConverter()  Map<Body, double> bodiesNakEclLon, @BodyDoubleMapConverter()  Map<Body, double> bodiesNakEquLon, @StarDoubleMapConverter()  Map<Star, double> starsNakEclLon, @StarDoubleMapConverter()  Map<Star, double> starsNakEquLon, @StringDoubleMapConverter()  Map<String, double> customStarsNakEclLon, @StringDoubleMapConverter()  Map<String, double> customStarsNakEquLon,  List<double> cuspsNakLon, @BodyMapConverter()  Map<Body, BodyPosition>? bodiesEclipticBarycentric, @BodyMapConverter()  Map<Body, BodyPosition>? bodiesEclipticHeliocentric, @StarPositionMapConverter()  Map<Star, StarPosition> stars, @StringStarPositionMapConverter()  Map<String, StarPosition> customStars)  $default,) {final _that = this;
switch (_that) {
case _EphSnapshot():
return $default(_that.jdUt,_that.location,_that.sweConfig,_that.bodiesEcliptic,_that.bodiesEquatorial,_that.phenoData,_that.cusps,_that.ascmc,_that.sunTimes,_that.ayanamsaValue,_that.bodiesNakEclLon,_that.bodiesNakEquLon,_that.starsNakEclLon,_that.starsNakEquLon,_that.customStarsNakEclLon,_that.customStarsNakEquLon,_that.cuspsNakLon,_that.bodiesEclipticBarycentric,_that.bodiesEclipticHeliocentric,_that.stars,_that.customStars);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double jdUt,  Location location,  SweConfig sweConfig, @BodyMapConverter()  Map<Body, BodyPosition> bodiesEcliptic, @BodyMapConverter()  Map<Body, BodyPosition> bodiesEquatorial, @BodyPhenoMapConverter()  Map<Body, PhenoData> phenoData,  List<double> cusps,  AscMcPoints ascmc,  SunTimes sunTimes,  double ayanamsaValue, @BodyDoubleMapConverter()  Map<Body, double> bodiesNakEclLon, @BodyDoubleMapConverter()  Map<Body, double> bodiesNakEquLon, @StarDoubleMapConverter()  Map<Star, double> starsNakEclLon, @StarDoubleMapConverter()  Map<Star, double> starsNakEquLon, @StringDoubleMapConverter()  Map<String, double> customStarsNakEclLon, @StringDoubleMapConverter()  Map<String, double> customStarsNakEquLon,  List<double> cuspsNakLon, @BodyMapConverter()  Map<Body, BodyPosition>? bodiesEclipticBarycentric, @BodyMapConverter()  Map<Body, BodyPosition>? bodiesEclipticHeliocentric, @StarPositionMapConverter()  Map<Star, StarPosition> stars, @StringStarPositionMapConverter()  Map<String, StarPosition> customStars)?  $default,) {final _that = this;
switch (_that) {
case _EphSnapshot() when $default != null:
return $default(_that.jdUt,_that.location,_that.sweConfig,_that.bodiesEcliptic,_that.bodiesEquatorial,_that.phenoData,_that.cusps,_that.ascmc,_that.sunTimes,_that.ayanamsaValue,_that.bodiesNakEclLon,_that.bodiesNakEquLon,_that.starsNakEclLon,_that.starsNakEquLon,_that.customStarsNakEclLon,_that.customStarsNakEquLon,_that.cuspsNakLon,_that.bodiesEclipticBarycentric,_that.bodiesEclipticHeliocentric,_that.stars,_that.customStars);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EphSnapshot implements EphSnapshot {
  const _EphSnapshot({required this.jdUt, required this.location, required this.sweConfig, @BodyMapConverter() required final  Map<Body, BodyPosition> bodiesEcliptic, @BodyMapConverter() required final  Map<Body, BodyPosition> bodiesEquatorial, @BodyPhenoMapConverter() required final  Map<Body, PhenoData> phenoData, required final  List<double> cusps, required this.ascmc, required this.sunTimes, required this.ayanamsaValue, @BodyDoubleMapConverter() final  Map<Body, double> bodiesNakEclLon = const <Body, double>{}, @BodyDoubleMapConverter() final  Map<Body, double> bodiesNakEquLon = const <Body, double>{}, @StarDoubleMapConverter() final  Map<Star, double> starsNakEclLon = const <Star, double>{}, @StarDoubleMapConverter() final  Map<Star, double> starsNakEquLon = const <Star, double>{}, @StringDoubleMapConverter() final  Map<String, double> customStarsNakEclLon = const <String, double>{}, @StringDoubleMapConverter() final  Map<String, double> customStarsNakEquLon = const <String, double>{}, final  List<double> cuspsNakLon = const <double>[], @BodyMapConverter() final  Map<Body, BodyPosition>? bodiesEclipticBarycentric, @BodyMapConverter() final  Map<Body, BodyPosition>? bodiesEclipticHeliocentric, @StarPositionMapConverter() final  Map<Star, StarPosition> stars = const <Star, StarPosition>{}, @StringStarPositionMapConverter() final  Map<String, StarPosition> customStars = const <String, StarPosition>{}}): _bodiesEcliptic = bodiesEcliptic,_bodiesEquatorial = bodiesEquatorial,_phenoData = phenoData,_cusps = cusps,_bodiesNakEclLon = bodiesNakEclLon,_bodiesNakEquLon = bodiesNakEquLon,_starsNakEclLon = starsNakEclLon,_starsNakEquLon = starsNakEquLon,_customStarsNakEclLon = customStarsNakEclLon,_customStarsNakEquLon = customStarsNakEquLon,_cuspsNakLon = cuspsNakLon,_bodiesEclipticBarycentric = bodiesEclipticBarycentric,_bodiesEclipticHeliocentric = bodiesEclipticHeliocentric,_stars = stars,_customStars = customStars;
  factory _EphSnapshot.fromJson(Map<String, dynamic> json) => _$EphSnapshotFromJson(json);

@override final  double jdUt;
@override final  Location location;
@override final  SweConfig sweConfig;
 final  Map<Body, BodyPosition> _bodiesEcliptic;
@override@BodyMapConverter() Map<Body, BodyPosition> get bodiesEcliptic {
  if (_bodiesEcliptic is EqualUnmodifiableMapView) return _bodiesEcliptic;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bodiesEcliptic);
}

 final  Map<Body, BodyPosition> _bodiesEquatorial;
@override@BodyMapConverter() Map<Body, BodyPosition> get bodiesEquatorial {
  if (_bodiesEquatorial is EqualUnmodifiableMapView) return _bodiesEquatorial;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bodiesEquatorial);
}

 final  Map<Body, PhenoData> _phenoData;
@override@BodyPhenoMapConverter() Map<Body, PhenoData> get phenoData {
  if (_phenoData is EqualUnmodifiableMapView) return _phenoData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_phenoData);
}

 final  List<double> _cusps;
@override List<double> get cusps {
  if (_cusps is EqualUnmodifiableListView) return _cusps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cusps);
}

@override final  AscMcPoints ascmc;
@override final  SunTimes sunTimes;
@override final  double ayanamsaValue;
 final  Map<Body, double> _bodiesNakEclLon;
@override@JsonKey()@BodyDoubleMapConverter() Map<Body, double> get bodiesNakEclLon {
  if (_bodiesNakEclLon is EqualUnmodifiableMapView) return _bodiesNakEclLon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bodiesNakEclLon);
}

 final  Map<Body, double> _bodiesNakEquLon;
@override@JsonKey()@BodyDoubleMapConverter() Map<Body, double> get bodiesNakEquLon {
  if (_bodiesNakEquLon is EqualUnmodifiableMapView) return _bodiesNakEquLon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bodiesNakEquLon);
}

 final  Map<Star, double> _starsNakEclLon;
@override@JsonKey()@StarDoubleMapConverter() Map<Star, double> get starsNakEclLon {
  if (_starsNakEclLon is EqualUnmodifiableMapView) return _starsNakEclLon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_starsNakEclLon);
}

 final  Map<Star, double> _starsNakEquLon;
@override@JsonKey()@StarDoubleMapConverter() Map<Star, double> get starsNakEquLon {
  if (_starsNakEquLon is EqualUnmodifiableMapView) return _starsNakEquLon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_starsNakEquLon);
}

 final  Map<String, double> _customStarsNakEclLon;
@override@JsonKey()@StringDoubleMapConverter() Map<String, double> get customStarsNakEclLon {
  if (_customStarsNakEclLon is EqualUnmodifiableMapView) return _customStarsNakEclLon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_customStarsNakEclLon);
}

 final  Map<String, double> _customStarsNakEquLon;
@override@JsonKey()@StringDoubleMapConverter() Map<String, double> get customStarsNakEquLon {
  if (_customStarsNakEquLon is EqualUnmodifiableMapView) return _customStarsNakEquLon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_customStarsNakEquLon);
}

 final  List<double> _cuspsNakLon;
@override@JsonKey() List<double> get cuspsNakLon {
  if (_cuspsNakLon is EqualUnmodifiableListView) return _cuspsNakLon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cuspsNakLon);
}

 final  Map<Body, BodyPosition>? _bodiesEclipticBarycentric;
@override@BodyMapConverter() Map<Body, BodyPosition>? get bodiesEclipticBarycentric {
  final value = _bodiesEclipticBarycentric;
  if (value == null) return null;
  if (_bodiesEclipticBarycentric is EqualUnmodifiableMapView) return _bodiesEclipticBarycentric;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<Body, BodyPosition>? _bodiesEclipticHeliocentric;
@override@BodyMapConverter() Map<Body, BodyPosition>? get bodiesEclipticHeliocentric {
  final value = _bodiesEclipticHeliocentric;
  if (value == null) return null;
  if (_bodiesEclipticHeliocentric is EqualUnmodifiableMapView) return _bodiesEclipticHeliocentric;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<Star, StarPosition> _stars;
@override@JsonKey()@StarPositionMapConverter() Map<Star, StarPosition> get stars {
  if (_stars is EqualUnmodifiableMapView) return _stars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stars);
}

 final  Map<String, StarPosition> _customStars;
@override@JsonKey()@StringStarPositionMapConverter() Map<String, StarPosition> get customStars {
  if (_customStars is EqualUnmodifiableMapView) return _customStars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_customStars);
}


/// Create a copy of EphSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EphSnapshotCopyWith<_EphSnapshot> get copyWith => __$EphSnapshotCopyWithImpl<_EphSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EphSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EphSnapshot&&(identical(other.jdUt, jdUt) || other.jdUt == jdUt)&&(identical(other.location, location) || other.location == location)&&(identical(other.sweConfig, sweConfig) || other.sweConfig == sweConfig)&&const DeepCollectionEquality().equals(other._bodiesEcliptic, _bodiesEcliptic)&&const DeepCollectionEquality().equals(other._bodiesEquatorial, _bodiesEquatorial)&&const DeepCollectionEquality().equals(other._phenoData, _phenoData)&&const DeepCollectionEquality().equals(other._cusps, _cusps)&&(identical(other.ascmc, ascmc) || other.ascmc == ascmc)&&(identical(other.sunTimes, sunTimes) || other.sunTimes == sunTimes)&&(identical(other.ayanamsaValue, ayanamsaValue) || other.ayanamsaValue == ayanamsaValue)&&const DeepCollectionEquality().equals(other._bodiesNakEclLon, _bodiesNakEclLon)&&const DeepCollectionEquality().equals(other._bodiesNakEquLon, _bodiesNakEquLon)&&const DeepCollectionEquality().equals(other._starsNakEclLon, _starsNakEclLon)&&const DeepCollectionEquality().equals(other._starsNakEquLon, _starsNakEquLon)&&const DeepCollectionEquality().equals(other._customStarsNakEclLon, _customStarsNakEclLon)&&const DeepCollectionEquality().equals(other._customStarsNakEquLon, _customStarsNakEquLon)&&const DeepCollectionEquality().equals(other._cuspsNakLon, _cuspsNakLon)&&const DeepCollectionEquality().equals(other._bodiesEclipticBarycentric, _bodiesEclipticBarycentric)&&const DeepCollectionEquality().equals(other._bodiesEclipticHeliocentric, _bodiesEclipticHeliocentric)&&const DeepCollectionEquality().equals(other._stars, _stars)&&const DeepCollectionEquality().equals(other._customStars, _customStars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,jdUt,location,sweConfig,const DeepCollectionEquality().hash(_bodiesEcliptic),const DeepCollectionEquality().hash(_bodiesEquatorial),const DeepCollectionEquality().hash(_phenoData),const DeepCollectionEquality().hash(_cusps),ascmc,sunTimes,ayanamsaValue,const DeepCollectionEquality().hash(_bodiesNakEclLon),const DeepCollectionEquality().hash(_bodiesNakEquLon),const DeepCollectionEquality().hash(_starsNakEclLon),const DeepCollectionEquality().hash(_starsNakEquLon),const DeepCollectionEquality().hash(_customStarsNakEclLon),const DeepCollectionEquality().hash(_customStarsNakEquLon),const DeepCollectionEquality().hash(_cuspsNakLon),const DeepCollectionEquality().hash(_bodiesEclipticBarycentric),const DeepCollectionEquality().hash(_bodiesEclipticHeliocentric),const DeepCollectionEquality().hash(_stars),const DeepCollectionEquality().hash(_customStars)]);

@override
String toString() {
  return 'EphSnapshot(jdUt: $jdUt, location: $location, sweConfig: $sweConfig, bodiesEcliptic: $bodiesEcliptic, bodiesEquatorial: $bodiesEquatorial, phenoData: $phenoData, cusps: $cusps, ascmc: $ascmc, sunTimes: $sunTimes, ayanamsaValue: $ayanamsaValue, bodiesNakEclLon: $bodiesNakEclLon, bodiesNakEquLon: $bodiesNakEquLon, starsNakEclLon: $starsNakEclLon, starsNakEquLon: $starsNakEquLon, customStarsNakEclLon: $customStarsNakEclLon, customStarsNakEquLon: $customStarsNakEquLon, cuspsNakLon: $cuspsNakLon, bodiesEclipticBarycentric: $bodiesEclipticBarycentric, bodiesEclipticHeliocentric: $bodiesEclipticHeliocentric, stars: $stars, customStars: $customStars)';
}


}

/// @nodoc
abstract mixin class _$EphSnapshotCopyWith<$Res> implements $EphSnapshotCopyWith<$Res> {
  factory _$EphSnapshotCopyWith(_EphSnapshot value, $Res Function(_EphSnapshot) _then) = __$EphSnapshotCopyWithImpl;
@override @useResult
$Res call({
 double jdUt, Location location, SweConfig sweConfig,@BodyMapConverter() Map<Body, BodyPosition> bodiesEcliptic,@BodyMapConverter() Map<Body, BodyPosition> bodiesEquatorial,@BodyPhenoMapConverter() Map<Body, PhenoData> phenoData, List<double> cusps, AscMcPoints ascmc, SunTimes sunTimes, double ayanamsaValue,@BodyDoubleMapConverter() Map<Body, double> bodiesNakEclLon,@BodyDoubleMapConverter() Map<Body, double> bodiesNakEquLon,@StarDoubleMapConverter() Map<Star, double> starsNakEclLon,@StarDoubleMapConverter() Map<Star, double> starsNakEquLon,@StringDoubleMapConverter() Map<String, double> customStarsNakEclLon,@StringDoubleMapConverter() Map<String, double> customStarsNakEquLon, List<double> cuspsNakLon,@BodyMapConverter() Map<Body, BodyPosition>? bodiesEclipticBarycentric,@BodyMapConverter() Map<Body, BodyPosition>? bodiesEclipticHeliocentric,@StarPositionMapConverter() Map<Star, StarPosition> stars,@StringStarPositionMapConverter() Map<String, StarPosition> customStars
});


@override $LocationCopyWith<$Res> get location;@override $SweConfigCopyWith<$Res> get sweConfig;@override $AscMcPointsCopyWith<$Res> get ascmc;@override $SunTimesCopyWith<$Res> get sunTimes;

}
/// @nodoc
class __$EphSnapshotCopyWithImpl<$Res>
    implements _$EphSnapshotCopyWith<$Res> {
  __$EphSnapshotCopyWithImpl(this._self, this._then);

  final _EphSnapshot _self;
  final $Res Function(_EphSnapshot) _then;

/// Create a copy of EphSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jdUt = null,Object? location = null,Object? sweConfig = null,Object? bodiesEcliptic = null,Object? bodiesEquatorial = null,Object? phenoData = null,Object? cusps = null,Object? ascmc = null,Object? sunTimes = null,Object? ayanamsaValue = null,Object? bodiesNakEclLon = null,Object? bodiesNakEquLon = null,Object? starsNakEclLon = null,Object? starsNakEquLon = null,Object? customStarsNakEclLon = null,Object? customStarsNakEquLon = null,Object? cuspsNakLon = null,Object? bodiesEclipticBarycentric = freezed,Object? bodiesEclipticHeliocentric = freezed,Object? stars = null,Object? customStars = null,}) {
  return _then(_EphSnapshot(
jdUt: null == jdUt ? _self.jdUt : jdUt // ignore: cast_nullable_to_non_nullable
as double,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location,sweConfig: null == sweConfig ? _self.sweConfig : sweConfig // ignore: cast_nullable_to_non_nullable
as SweConfig,bodiesEcliptic: null == bodiesEcliptic ? _self._bodiesEcliptic : bodiesEcliptic // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>,bodiesEquatorial: null == bodiesEquatorial ? _self._bodiesEquatorial : bodiesEquatorial // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>,phenoData: null == phenoData ? _self._phenoData : phenoData // ignore: cast_nullable_to_non_nullable
as Map<Body, PhenoData>,cusps: null == cusps ? _self._cusps : cusps // ignore: cast_nullable_to_non_nullable
as List<double>,ascmc: null == ascmc ? _self.ascmc : ascmc // ignore: cast_nullable_to_non_nullable
as AscMcPoints,sunTimes: null == sunTimes ? _self.sunTimes : sunTimes // ignore: cast_nullable_to_non_nullable
as SunTimes,ayanamsaValue: null == ayanamsaValue ? _self.ayanamsaValue : ayanamsaValue // ignore: cast_nullable_to_non_nullable
as double,bodiesNakEclLon: null == bodiesNakEclLon ? _self._bodiesNakEclLon : bodiesNakEclLon // ignore: cast_nullable_to_non_nullable
as Map<Body, double>,bodiesNakEquLon: null == bodiesNakEquLon ? _self._bodiesNakEquLon : bodiesNakEquLon // ignore: cast_nullable_to_non_nullable
as Map<Body, double>,starsNakEclLon: null == starsNakEclLon ? _self._starsNakEclLon : starsNakEclLon // ignore: cast_nullable_to_non_nullable
as Map<Star, double>,starsNakEquLon: null == starsNakEquLon ? _self._starsNakEquLon : starsNakEquLon // ignore: cast_nullable_to_non_nullable
as Map<Star, double>,customStarsNakEclLon: null == customStarsNakEclLon ? _self._customStarsNakEclLon : customStarsNakEclLon // ignore: cast_nullable_to_non_nullable
as Map<String, double>,customStarsNakEquLon: null == customStarsNakEquLon ? _self._customStarsNakEquLon : customStarsNakEquLon // ignore: cast_nullable_to_non_nullable
as Map<String, double>,cuspsNakLon: null == cuspsNakLon ? _self._cuspsNakLon : cuspsNakLon // ignore: cast_nullable_to_non_nullable
as List<double>,bodiesEclipticBarycentric: freezed == bodiesEclipticBarycentric ? _self._bodiesEclipticBarycentric : bodiesEclipticBarycentric // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>?,bodiesEclipticHeliocentric: freezed == bodiesEclipticHeliocentric ? _self._bodiesEclipticHeliocentric : bodiesEclipticHeliocentric // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>?,stars: null == stars ? _self._stars : stars // ignore: cast_nullable_to_non_nullable
as Map<Star, StarPosition>,customStars: null == customStars ? _self._customStars : customStars // ignore: cast_nullable_to_non_nullable
as Map<String, StarPosition>,
  ));
}

/// Create a copy of EphSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res> get location {
  
  return $LocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of EphSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SweConfigCopyWith<$Res> get sweConfig {
  
  return $SweConfigCopyWith<$Res>(_self.sweConfig, (value) {
    return _then(_self.copyWith(sweConfig: value));
  });
}/// Create a copy of EphSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AscMcPointsCopyWith<$Res> get ascmc {
  
  return $AscMcPointsCopyWith<$Res>(_self.ascmc, (value) {
    return _then(_self.copyWith(ascmc: value));
  });
}/// Create a copy of EphSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SunTimesCopyWith<$Res> get sunTimes {
  
  return $SunTimesCopyWith<$Res>(_self.sunTimes, (value) {
    return _then(_self.copyWith(sunTimes: value));
  });
}
}

// dart format on
