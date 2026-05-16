// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'asc_mc_points.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AscMcPoints {

 double get ascendant; double get mc; double get armc; double get vertex; double get equatorialAscendant; double get coAscendantKoch; double get coAscendantMunkasey; double get polarAscendant;
/// Create a copy of AscMcPoints
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AscMcPointsCopyWith<AscMcPoints> get copyWith => _$AscMcPointsCopyWithImpl<AscMcPoints>(this as AscMcPoints, _$identity);

  /// Serializes this AscMcPoints to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AscMcPoints&&(identical(other.ascendant, ascendant) || other.ascendant == ascendant)&&(identical(other.mc, mc) || other.mc == mc)&&(identical(other.armc, armc) || other.armc == armc)&&(identical(other.vertex, vertex) || other.vertex == vertex)&&(identical(other.equatorialAscendant, equatorialAscendant) || other.equatorialAscendant == equatorialAscendant)&&(identical(other.coAscendantKoch, coAscendantKoch) || other.coAscendantKoch == coAscendantKoch)&&(identical(other.coAscendantMunkasey, coAscendantMunkasey) || other.coAscendantMunkasey == coAscendantMunkasey)&&(identical(other.polarAscendant, polarAscendant) || other.polarAscendant == polarAscendant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ascendant,mc,armc,vertex,equatorialAscendant,coAscendantKoch,coAscendantMunkasey,polarAscendant);

@override
String toString() {
  return 'AscMcPoints(ascendant: $ascendant, mc: $mc, armc: $armc, vertex: $vertex, equatorialAscendant: $equatorialAscendant, coAscendantKoch: $coAscendantKoch, coAscendantMunkasey: $coAscendantMunkasey, polarAscendant: $polarAscendant)';
}


}

/// @nodoc
abstract mixin class $AscMcPointsCopyWith<$Res>  {
  factory $AscMcPointsCopyWith(AscMcPoints value, $Res Function(AscMcPoints) _then) = _$AscMcPointsCopyWithImpl;
@useResult
$Res call({
 double ascendant, double mc, double armc, double vertex, double equatorialAscendant, double coAscendantKoch, double coAscendantMunkasey, double polarAscendant
});




}
/// @nodoc
class _$AscMcPointsCopyWithImpl<$Res>
    implements $AscMcPointsCopyWith<$Res> {
  _$AscMcPointsCopyWithImpl(this._self, this._then);

  final AscMcPoints _self;
  final $Res Function(AscMcPoints) _then;

/// Create a copy of AscMcPoints
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ascendant = null,Object? mc = null,Object? armc = null,Object? vertex = null,Object? equatorialAscendant = null,Object? coAscendantKoch = null,Object? coAscendantMunkasey = null,Object? polarAscendant = null,}) {
  return _then(_self.copyWith(
ascendant: null == ascendant ? _self.ascendant : ascendant // ignore: cast_nullable_to_non_nullable
as double,mc: null == mc ? _self.mc : mc // ignore: cast_nullable_to_non_nullable
as double,armc: null == armc ? _self.armc : armc // ignore: cast_nullable_to_non_nullable
as double,vertex: null == vertex ? _self.vertex : vertex // ignore: cast_nullable_to_non_nullable
as double,equatorialAscendant: null == equatorialAscendant ? _self.equatorialAscendant : equatorialAscendant // ignore: cast_nullable_to_non_nullable
as double,coAscendantKoch: null == coAscendantKoch ? _self.coAscendantKoch : coAscendantKoch // ignore: cast_nullable_to_non_nullable
as double,coAscendantMunkasey: null == coAscendantMunkasey ? _self.coAscendantMunkasey : coAscendantMunkasey // ignore: cast_nullable_to_non_nullable
as double,polarAscendant: null == polarAscendant ? _self.polarAscendant : polarAscendant // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AscMcPoints].
extension AscMcPointsPatterns on AscMcPoints {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AscMcPoints value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AscMcPoints() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AscMcPoints value)  $default,){
final _that = this;
switch (_that) {
case _AscMcPoints():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AscMcPoints value)?  $default,){
final _that = this;
switch (_that) {
case _AscMcPoints() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double ascendant,  double mc,  double armc,  double vertex,  double equatorialAscendant,  double coAscendantKoch,  double coAscendantMunkasey,  double polarAscendant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AscMcPoints() when $default != null:
return $default(_that.ascendant,_that.mc,_that.armc,_that.vertex,_that.equatorialAscendant,_that.coAscendantKoch,_that.coAscendantMunkasey,_that.polarAscendant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double ascendant,  double mc,  double armc,  double vertex,  double equatorialAscendant,  double coAscendantKoch,  double coAscendantMunkasey,  double polarAscendant)  $default,) {final _that = this;
switch (_that) {
case _AscMcPoints():
return $default(_that.ascendant,_that.mc,_that.armc,_that.vertex,_that.equatorialAscendant,_that.coAscendantKoch,_that.coAscendantMunkasey,_that.polarAscendant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double ascendant,  double mc,  double armc,  double vertex,  double equatorialAscendant,  double coAscendantKoch,  double coAscendantMunkasey,  double polarAscendant)?  $default,) {final _that = this;
switch (_that) {
case _AscMcPoints() when $default != null:
return $default(_that.ascendant,_that.mc,_that.armc,_that.vertex,_that.equatorialAscendant,_that.coAscendantKoch,_that.coAscendantMunkasey,_that.polarAscendant);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AscMcPoints implements AscMcPoints {
  const _AscMcPoints({required this.ascendant, required this.mc, required this.armc, required this.vertex, required this.equatorialAscendant, required this.coAscendantKoch, required this.coAscendantMunkasey, required this.polarAscendant});
  factory _AscMcPoints.fromJson(Map<String, dynamic> json) => _$AscMcPointsFromJson(json);

@override final  double ascendant;
@override final  double mc;
@override final  double armc;
@override final  double vertex;
@override final  double equatorialAscendant;
@override final  double coAscendantKoch;
@override final  double coAscendantMunkasey;
@override final  double polarAscendant;

/// Create a copy of AscMcPoints
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AscMcPointsCopyWith<_AscMcPoints> get copyWith => __$AscMcPointsCopyWithImpl<_AscMcPoints>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AscMcPointsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AscMcPoints&&(identical(other.ascendant, ascendant) || other.ascendant == ascendant)&&(identical(other.mc, mc) || other.mc == mc)&&(identical(other.armc, armc) || other.armc == armc)&&(identical(other.vertex, vertex) || other.vertex == vertex)&&(identical(other.equatorialAscendant, equatorialAscendant) || other.equatorialAscendant == equatorialAscendant)&&(identical(other.coAscendantKoch, coAscendantKoch) || other.coAscendantKoch == coAscendantKoch)&&(identical(other.coAscendantMunkasey, coAscendantMunkasey) || other.coAscendantMunkasey == coAscendantMunkasey)&&(identical(other.polarAscendant, polarAscendant) || other.polarAscendant == polarAscendant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ascendant,mc,armc,vertex,equatorialAscendant,coAscendantKoch,coAscendantMunkasey,polarAscendant);

@override
String toString() {
  return 'AscMcPoints(ascendant: $ascendant, mc: $mc, armc: $armc, vertex: $vertex, equatorialAscendant: $equatorialAscendant, coAscendantKoch: $coAscendantKoch, coAscendantMunkasey: $coAscendantMunkasey, polarAscendant: $polarAscendant)';
}


}

/// @nodoc
abstract mixin class _$AscMcPointsCopyWith<$Res> implements $AscMcPointsCopyWith<$Res> {
  factory _$AscMcPointsCopyWith(_AscMcPoints value, $Res Function(_AscMcPoints) _then) = __$AscMcPointsCopyWithImpl;
@override @useResult
$Res call({
 double ascendant, double mc, double armc, double vertex, double equatorialAscendant, double coAscendantKoch, double coAscendantMunkasey, double polarAscendant
});




}
/// @nodoc
class __$AscMcPointsCopyWithImpl<$Res>
    implements _$AscMcPointsCopyWith<$Res> {
  __$AscMcPointsCopyWithImpl(this._self, this._then);

  final _AscMcPoints _self;
  final $Res Function(_AscMcPoints) _then;

/// Create a copy of AscMcPoints
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ascendant = null,Object? mc = null,Object? armc = null,Object? vertex = null,Object? equatorialAscendant = null,Object? coAscendantKoch = null,Object? coAscendantMunkasey = null,Object? polarAscendant = null,}) {
  return _then(_AscMcPoints(
ascendant: null == ascendant ? _self.ascendant : ascendant // ignore: cast_nullable_to_non_nullable
as double,mc: null == mc ? _self.mc : mc // ignore: cast_nullable_to_non_nullable
as double,armc: null == armc ? _self.armc : armc // ignore: cast_nullable_to_non_nullable
as double,vertex: null == vertex ? _self.vertex : vertex // ignore: cast_nullable_to_non_nullable
as double,equatorialAscendant: null == equatorialAscendant ? _self.equatorialAscendant : equatorialAscendant // ignore: cast_nullable_to_non_nullable
as double,coAscendantKoch: null == coAscendantKoch ? _self.coAscendantKoch : coAscendantKoch // ignore: cast_nullable_to_non_nullable
as double,coAscendantMunkasey: null == coAscendantMunkasey ? _self.coAscendantMunkasey : coAscendantMunkasey // ignore: cast_nullable_to_non_nullable
as double,polarAscendant: null == polarAscendant ? _self.polarAscendant : polarAscendant // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
