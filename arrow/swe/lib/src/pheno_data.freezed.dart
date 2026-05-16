// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pheno_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PhenoData {

 double get phaseAngle; double get phase; double get elongation; double get apparentDiameter; double get apparentMagnitude;
/// Create a copy of PhenoData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhenoDataCopyWith<PhenoData> get copyWith => _$PhenoDataCopyWithImpl<PhenoData>(this as PhenoData, _$identity);

  /// Serializes this PhenoData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhenoData&&(identical(other.phaseAngle, phaseAngle) || other.phaseAngle == phaseAngle)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.elongation, elongation) || other.elongation == elongation)&&(identical(other.apparentDiameter, apparentDiameter) || other.apparentDiameter == apparentDiameter)&&(identical(other.apparentMagnitude, apparentMagnitude) || other.apparentMagnitude == apparentMagnitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phaseAngle,phase,elongation,apparentDiameter,apparentMagnitude);

@override
String toString() {
  return 'PhenoData(phaseAngle: $phaseAngle, phase: $phase, elongation: $elongation, apparentDiameter: $apparentDiameter, apparentMagnitude: $apparentMagnitude)';
}


}

/// @nodoc
abstract mixin class $PhenoDataCopyWith<$Res>  {
  factory $PhenoDataCopyWith(PhenoData value, $Res Function(PhenoData) _then) = _$PhenoDataCopyWithImpl;
@useResult
$Res call({
 double phaseAngle, double phase, double elongation, double apparentDiameter, double apparentMagnitude
});




}
/// @nodoc
class _$PhenoDataCopyWithImpl<$Res>
    implements $PhenoDataCopyWith<$Res> {
  _$PhenoDataCopyWithImpl(this._self, this._then);

  final PhenoData _self;
  final $Res Function(PhenoData) _then;

/// Create a copy of PhenoData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phaseAngle = null,Object? phase = null,Object? elongation = null,Object? apparentDiameter = null,Object? apparentMagnitude = null,}) {
  return _then(_self.copyWith(
phaseAngle: null == phaseAngle ? _self.phaseAngle : phaseAngle // ignore: cast_nullable_to_non_nullable
as double,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as double,elongation: null == elongation ? _self.elongation : elongation // ignore: cast_nullable_to_non_nullable
as double,apparentDiameter: null == apparentDiameter ? _self.apparentDiameter : apparentDiameter // ignore: cast_nullable_to_non_nullable
as double,apparentMagnitude: null == apparentMagnitude ? _self.apparentMagnitude : apparentMagnitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PhenoData].
extension PhenoDataPatterns on PhenoData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhenoData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhenoData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhenoData value)  $default,){
final _that = this;
switch (_that) {
case _PhenoData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhenoData value)?  $default,){
final _that = this;
switch (_that) {
case _PhenoData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double phaseAngle,  double phase,  double elongation,  double apparentDiameter,  double apparentMagnitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhenoData() when $default != null:
return $default(_that.phaseAngle,_that.phase,_that.elongation,_that.apparentDiameter,_that.apparentMagnitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double phaseAngle,  double phase,  double elongation,  double apparentDiameter,  double apparentMagnitude)  $default,) {final _that = this;
switch (_that) {
case _PhenoData():
return $default(_that.phaseAngle,_that.phase,_that.elongation,_that.apparentDiameter,_that.apparentMagnitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double phaseAngle,  double phase,  double elongation,  double apparentDiameter,  double apparentMagnitude)?  $default,) {final _that = this;
switch (_that) {
case _PhenoData() when $default != null:
return $default(_that.phaseAngle,_that.phase,_that.elongation,_that.apparentDiameter,_that.apparentMagnitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhenoData implements PhenoData {
  const _PhenoData({required this.phaseAngle, required this.phase, required this.elongation, required this.apparentDiameter, required this.apparentMagnitude});
  factory _PhenoData.fromJson(Map<String, dynamic> json) => _$PhenoDataFromJson(json);

@override final  double phaseAngle;
@override final  double phase;
@override final  double elongation;
@override final  double apparentDiameter;
@override final  double apparentMagnitude;

/// Create a copy of PhenoData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhenoDataCopyWith<_PhenoData> get copyWith => __$PhenoDataCopyWithImpl<_PhenoData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhenoDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhenoData&&(identical(other.phaseAngle, phaseAngle) || other.phaseAngle == phaseAngle)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.elongation, elongation) || other.elongation == elongation)&&(identical(other.apparentDiameter, apparentDiameter) || other.apparentDiameter == apparentDiameter)&&(identical(other.apparentMagnitude, apparentMagnitude) || other.apparentMagnitude == apparentMagnitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phaseAngle,phase,elongation,apparentDiameter,apparentMagnitude);

@override
String toString() {
  return 'PhenoData(phaseAngle: $phaseAngle, phase: $phase, elongation: $elongation, apparentDiameter: $apparentDiameter, apparentMagnitude: $apparentMagnitude)';
}


}

/// @nodoc
abstract mixin class _$PhenoDataCopyWith<$Res> implements $PhenoDataCopyWith<$Res> {
  factory _$PhenoDataCopyWith(_PhenoData value, $Res Function(_PhenoData) _then) = __$PhenoDataCopyWithImpl;
@override @useResult
$Res call({
 double phaseAngle, double phase, double elongation, double apparentDiameter, double apparentMagnitude
});




}
/// @nodoc
class __$PhenoDataCopyWithImpl<$Res>
    implements _$PhenoDataCopyWith<$Res> {
  __$PhenoDataCopyWithImpl(this._self, this._then);

  final _PhenoData _self;
  final $Res Function(_PhenoData) _then;

/// Create a copy of PhenoData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phaseAngle = null,Object? phase = null,Object? elongation = null,Object? apparentDiameter = null,Object? apparentMagnitude = null,}) {
  return _then(_PhenoData(
phaseAngle: null == phaseAngle ? _self.phaseAngle : phaseAngle // ignore: cast_nullable_to_non_nullable
as double,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as double,elongation: null == elongation ? _self.elongation : elongation // ignore: cast_nullable_to_non_nullable
as double,apparentDiameter: null == apparentDiameter ? _self.apparentDiameter : apparentDiameter // ignore: cast_nullable_to_non_nullable
as double,apparentMagnitude: null == apparentMagnitude ? _self.apparentMagnitude : apparentMagnitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
