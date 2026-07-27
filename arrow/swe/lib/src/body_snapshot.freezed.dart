// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BodySnapshot {

 double get jdUt; Location get location; SweConfig get sweConfig; Map<Body, BodyPosition> get bodiesEcliptic; Map<Body, BodyPosition> get bodiesEquatorial; Map<Body, PhenoData> get phenoData;/// Null when [ReferencePoint.barycentric] was not in
/// [SweConfig.extraFrames] — distinct from an empty map.
 Map<Body, BodyPosition>? get bodiesEclipticBarycentric;/// Null when [ReferencePoint.heliocentric] was not in
/// [SweConfig.extraFrames]. Never contains [Body.sun].
 Map<Body, BodyPosition>? get bodiesEclipticHeliocentric;
/// Create a copy of BodySnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BodySnapshotCopyWith<BodySnapshot> get copyWith => _$BodySnapshotCopyWithImpl<BodySnapshot>(this as BodySnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BodySnapshot&&(identical(other.jdUt, jdUt) || other.jdUt == jdUt)&&(identical(other.location, location) || other.location == location)&&(identical(other.sweConfig, sweConfig) || other.sweConfig == sweConfig)&&const DeepCollectionEquality().equals(other.bodiesEcliptic, bodiesEcliptic)&&const DeepCollectionEquality().equals(other.bodiesEquatorial, bodiesEquatorial)&&const DeepCollectionEquality().equals(other.phenoData, phenoData)&&const DeepCollectionEquality().equals(other.bodiesEclipticBarycentric, bodiesEclipticBarycentric)&&const DeepCollectionEquality().equals(other.bodiesEclipticHeliocentric, bodiesEclipticHeliocentric));
}


@override
int get hashCode => Object.hash(runtimeType,jdUt,location,sweConfig,const DeepCollectionEquality().hash(bodiesEcliptic),const DeepCollectionEquality().hash(bodiesEquatorial),const DeepCollectionEquality().hash(phenoData),const DeepCollectionEquality().hash(bodiesEclipticBarycentric),const DeepCollectionEquality().hash(bodiesEclipticHeliocentric));

@override
String toString() {
  return 'BodySnapshot(jdUt: $jdUt, location: $location, sweConfig: $sweConfig, bodiesEcliptic: $bodiesEcliptic, bodiesEquatorial: $bodiesEquatorial, phenoData: $phenoData, bodiesEclipticBarycentric: $bodiesEclipticBarycentric, bodiesEclipticHeliocentric: $bodiesEclipticHeliocentric)';
}


}

/// @nodoc
abstract mixin class $BodySnapshotCopyWith<$Res>  {
  factory $BodySnapshotCopyWith(BodySnapshot value, $Res Function(BodySnapshot) _then) = _$BodySnapshotCopyWithImpl;
@useResult
$Res call({
 double jdUt, Location location, SweConfig sweConfig, Map<Body, BodyPosition> bodiesEcliptic, Map<Body, BodyPosition> bodiesEquatorial, Map<Body, PhenoData> phenoData, Map<Body, BodyPosition>? bodiesEclipticBarycentric, Map<Body, BodyPosition>? bodiesEclipticHeliocentric
});


$LocationCopyWith<$Res> get location;$SweConfigCopyWith<$Res> get sweConfig;

}
/// @nodoc
class _$BodySnapshotCopyWithImpl<$Res>
    implements $BodySnapshotCopyWith<$Res> {
  _$BodySnapshotCopyWithImpl(this._self, this._then);

  final BodySnapshot _self;
  final $Res Function(BodySnapshot) _then;

/// Create a copy of BodySnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jdUt = null,Object? location = null,Object? sweConfig = null,Object? bodiesEcliptic = null,Object? bodiesEquatorial = null,Object? phenoData = null,Object? bodiesEclipticBarycentric = freezed,Object? bodiesEclipticHeliocentric = freezed,}) {
  return _then(_self.copyWith(
jdUt: null == jdUt ? _self.jdUt : jdUt // ignore: cast_nullable_to_non_nullable
as double,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location,sweConfig: null == sweConfig ? _self.sweConfig : sweConfig // ignore: cast_nullable_to_non_nullable
as SweConfig,bodiesEcliptic: null == bodiesEcliptic ? _self.bodiesEcliptic : bodiesEcliptic // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>,bodiesEquatorial: null == bodiesEquatorial ? _self.bodiesEquatorial : bodiesEquatorial // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>,phenoData: null == phenoData ? _self.phenoData : phenoData // ignore: cast_nullable_to_non_nullable
as Map<Body, PhenoData>,bodiesEclipticBarycentric: freezed == bodiesEclipticBarycentric ? _self.bodiesEclipticBarycentric : bodiesEclipticBarycentric // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>?,bodiesEclipticHeliocentric: freezed == bodiesEclipticHeliocentric ? _self.bodiesEclipticHeliocentric : bodiesEclipticHeliocentric // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>?,
  ));
}
/// Create a copy of BodySnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res> get location {
  
  return $LocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of BodySnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SweConfigCopyWith<$Res> get sweConfig {
  
  return $SweConfigCopyWith<$Res>(_self.sweConfig, (value) {
    return _then(_self.copyWith(sweConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [BodySnapshot].
extension BodySnapshotPatterns on BodySnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BodySnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BodySnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BodySnapshot value)  $default,){
final _that = this;
switch (_that) {
case _BodySnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BodySnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _BodySnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double jdUt,  Location location,  SweConfig sweConfig,  Map<Body, BodyPosition> bodiesEcliptic,  Map<Body, BodyPosition> bodiesEquatorial,  Map<Body, PhenoData> phenoData,  Map<Body, BodyPosition>? bodiesEclipticBarycentric,  Map<Body, BodyPosition>? bodiesEclipticHeliocentric)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BodySnapshot() when $default != null:
return $default(_that.jdUt,_that.location,_that.sweConfig,_that.bodiesEcliptic,_that.bodiesEquatorial,_that.phenoData,_that.bodiesEclipticBarycentric,_that.bodiesEclipticHeliocentric);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double jdUt,  Location location,  SweConfig sweConfig,  Map<Body, BodyPosition> bodiesEcliptic,  Map<Body, BodyPosition> bodiesEquatorial,  Map<Body, PhenoData> phenoData,  Map<Body, BodyPosition>? bodiesEclipticBarycentric,  Map<Body, BodyPosition>? bodiesEclipticHeliocentric)  $default,) {final _that = this;
switch (_that) {
case _BodySnapshot():
return $default(_that.jdUt,_that.location,_that.sweConfig,_that.bodiesEcliptic,_that.bodiesEquatorial,_that.phenoData,_that.bodiesEclipticBarycentric,_that.bodiesEclipticHeliocentric);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double jdUt,  Location location,  SweConfig sweConfig,  Map<Body, BodyPosition> bodiesEcliptic,  Map<Body, BodyPosition> bodiesEquatorial,  Map<Body, PhenoData> phenoData,  Map<Body, BodyPosition>? bodiesEclipticBarycentric,  Map<Body, BodyPosition>? bodiesEclipticHeliocentric)?  $default,) {final _that = this;
switch (_that) {
case _BodySnapshot() when $default != null:
return $default(_that.jdUt,_that.location,_that.sweConfig,_that.bodiesEcliptic,_that.bodiesEquatorial,_that.phenoData,_that.bodiesEclipticBarycentric,_that.bodiesEclipticHeliocentric);case _:
  return null;

}
}

}

/// @nodoc


class _BodySnapshot implements BodySnapshot {
  const _BodySnapshot({required this.jdUt, required this.location, required this.sweConfig, required final  Map<Body, BodyPosition> bodiesEcliptic, required final  Map<Body, BodyPosition> bodiesEquatorial, required final  Map<Body, PhenoData> phenoData, final  Map<Body, BodyPosition>? bodiesEclipticBarycentric, final  Map<Body, BodyPosition>? bodiesEclipticHeliocentric}): _bodiesEcliptic = bodiesEcliptic,_bodiesEquatorial = bodiesEquatorial,_phenoData = phenoData,_bodiesEclipticBarycentric = bodiesEclipticBarycentric,_bodiesEclipticHeliocentric = bodiesEclipticHeliocentric;
  

@override final  double jdUt;
@override final  Location location;
@override final  SweConfig sweConfig;
 final  Map<Body, BodyPosition> _bodiesEcliptic;
@override Map<Body, BodyPosition> get bodiesEcliptic {
  if (_bodiesEcliptic is EqualUnmodifiableMapView) return _bodiesEcliptic;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bodiesEcliptic);
}

 final  Map<Body, BodyPosition> _bodiesEquatorial;
@override Map<Body, BodyPosition> get bodiesEquatorial {
  if (_bodiesEquatorial is EqualUnmodifiableMapView) return _bodiesEquatorial;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bodiesEquatorial);
}

 final  Map<Body, PhenoData> _phenoData;
@override Map<Body, PhenoData> get phenoData {
  if (_phenoData is EqualUnmodifiableMapView) return _phenoData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_phenoData);
}

/// Null when [ReferencePoint.barycentric] was not in
/// [SweConfig.extraFrames] — distinct from an empty map.
 final  Map<Body, BodyPosition>? _bodiesEclipticBarycentric;
/// Null when [ReferencePoint.barycentric] was not in
/// [SweConfig.extraFrames] — distinct from an empty map.
@override Map<Body, BodyPosition>? get bodiesEclipticBarycentric {
  final value = _bodiesEclipticBarycentric;
  if (value == null) return null;
  if (_bodiesEclipticBarycentric is EqualUnmodifiableMapView) return _bodiesEclipticBarycentric;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Null when [ReferencePoint.heliocentric] was not in
/// [SweConfig.extraFrames]. Never contains [Body.sun].
 final  Map<Body, BodyPosition>? _bodiesEclipticHeliocentric;
/// Null when [ReferencePoint.heliocentric] was not in
/// [SweConfig.extraFrames]. Never contains [Body.sun].
@override Map<Body, BodyPosition>? get bodiesEclipticHeliocentric {
  final value = _bodiesEclipticHeliocentric;
  if (value == null) return null;
  if (_bodiesEclipticHeliocentric is EqualUnmodifiableMapView) return _bodiesEclipticHeliocentric;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of BodySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BodySnapshotCopyWith<_BodySnapshot> get copyWith => __$BodySnapshotCopyWithImpl<_BodySnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BodySnapshot&&(identical(other.jdUt, jdUt) || other.jdUt == jdUt)&&(identical(other.location, location) || other.location == location)&&(identical(other.sweConfig, sweConfig) || other.sweConfig == sweConfig)&&const DeepCollectionEquality().equals(other._bodiesEcliptic, _bodiesEcliptic)&&const DeepCollectionEquality().equals(other._bodiesEquatorial, _bodiesEquatorial)&&const DeepCollectionEquality().equals(other._phenoData, _phenoData)&&const DeepCollectionEquality().equals(other._bodiesEclipticBarycentric, _bodiesEclipticBarycentric)&&const DeepCollectionEquality().equals(other._bodiesEclipticHeliocentric, _bodiesEclipticHeliocentric));
}


@override
int get hashCode => Object.hash(runtimeType,jdUt,location,sweConfig,const DeepCollectionEquality().hash(_bodiesEcliptic),const DeepCollectionEquality().hash(_bodiesEquatorial),const DeepCollectionEquality().hash(_phenoData),const DeepCollectionEquality().hash(_bodiesEclipticBarycentric),const DeepCollectionEquality().hash(_bodiesEclipticHeliocentric));

@override
String toString() {
  return 'BodySnapshot(jdUt: $jdUt, location: $location, sweConfig: $sweConfig, bodiesEcliptic: $bodiesEcliptic, bodiesEquatorial: $bodiesEquatorial, phenoData: $phenoData, bodiesEclipticBarycentric: $bodiesEclipticBarycentric, bodiesEclipticHeliocentric: $bodiesEclipticHeliocentric)';
}


}

/// @nodoc
abstract mixin class _$BodySnapshotCopyWith<$Res> implements $BodySnapshotCopyWith<$Res> {
  factory _$BodySnapshotCopyWith(_BodySnapshot value, $Res Function(_BodySnapshot) _then) = __$BodySnapshotCopyWithImpl;
@override @useResult
$Res call({
 double jdUt, Location location, SweConfig sweConfig, Map<Body, BodyPosition> bodiesEcliptic, Map<Body, BodyPosition> bodiesEquatorial, Map<Body, PhenoData> phenoData, Map<Body, BodyPosition>? bodiesEclipticBarycentric, Map<Body, BodyPosition>? bodiesEclipticHeliocentric
});


@override $LocationCopyWith<$Res> get location;@override $SweConfigCopyWith<$Res> get sweConfig;

}
/// @nodoc
class __$BodySnapshotCopyWithImpl<$Res>
    implements _$BodySnapshotCopyWith<$Res> {
  __$BodySnapshotCopyWithImpl(this._self, this._then);

  final _BodySnapshot _self;
  final $Res Function(_BodySnapshot) _then;

/// Create a copy of BodySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jdUt = null,Object? location = null,Object? sweConfig = null,Object? bodiesEcliptic = null,Object? bodiesEquatorial = null,Object? phenoData = null,Object? bodiesEclipticBarycentric = freezed,Object? bodiesEclipticHeliocentric = freezed,}) {
  return _then(_BodySnapshot(
jdUt: null == jdUt ? _self.jdUt : jdUt // ignore: cast_nullable_to_non_nullable
as double,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location,sweConfig: null == sweConfig ? _self.sweConfig : sweConfig // ignore: cast_nullable_to_non_nullable
as SweConfig,bodiesEcliptic: null == bodiesEcliptic ? _self._bodiesEcliptic : bodiesEcliptic // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>,bodiesEquatorial: null == bodiesEquatorial ? _self._bodiesEquatorial : bodiesEquatorial // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>,phenoData: null == phenoData ? _self._phenoData : phenoData // ignore: cast_nullable_to_non_nullable
as Map<Body, PhenoData>,bodiesEclipticBarycentric: freezed == bodiesEclipticBarycentric ? _self._bodiesEclipticBarycentric : bodiesEclipticBarycentric // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>?,bodiesEclipticHeliocentric: freezed == bodiesEclipticHeliocentric ? _self._bodiesEclipticHeliocentric : bodiesEclipticHeliocentric // ignore: cast_nullable_to_non_nullable
as Map<Body, BodyPosition>?,
  ));
}

/// Create a copy of BodySnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res> get location {
  
  return $LocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of BodySnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SweConfigCopyWith<$Res> get sweConfig {
  
  return $SweConfigCopyWith<$Res>(_self.sweConfig, (value) {
    return _then(_self.copyWith(sweConfig: value));
  });
}
}

// dart format on
