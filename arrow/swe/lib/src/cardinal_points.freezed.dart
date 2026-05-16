// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cardinal_points.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CardinalPoints {

 double get ascendingEquinox; double get northernSolstice; double get descendingEquinox; double get southernSolstice;
/// Create a copy of CardinalPoints
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardinalPointsCopyWith<CardinalPoints> get copyWith => _$CardinalPointsCopyWithImpl<CardinalPoints>(this as CardinalPoints, _$identity);

  /// Serializes this CardinalPoints to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardinalPoints&&(identical(other.ascendingEquinox, ascendingEquinox) || other.ascendingEquinox == ascendingEquinox)&&(identical(other.northernSolstice, northernSolstice) || other.northernSolstice == northernSolstice)&&(identical(other.descendingEquinox, descendingEquinox) || other.descendingEquinox == descendingEquinox)&&(identical(other.southernSolstice, southernSolstice) || other.southernSolstice == southernSolstice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ascendingEquinox,northernSolstice,descendingEquinox,southernSolstice);

@override
String toString() {
  return 'CardinalPoints(ascendingEquinox: $ascendingEquinox, northernSolstice: $northernSolstice, descendingEquinox: $descendingEquinox, southernSolstice: $southernSolstice)';
}


}

/// @nodoc
abstract mixin class $CardinalPointsCopyWith<$Res>  {
  factory $CardinalPointsCopyWith(CardinalPoints value, $Res Function(CardinalPoints) _then) = _$CardinalPointsCopyWithImpl;
@useResult
$Res call({
 double ascendingEquinox, double northernSolstice, double descendingEquinox, double southernSolstice
});




}
/// @nodoc
class _$CardinalPointsCopyWithImpl<$Res>
    implements $CardinalPointsCopyWith<$Res> {
  _$CardinalPointsCopyWithImpl(this._self, this._then);

  final CardinalPoints _self;
  final $Res Function(CardinalPoints) _then;

/// Create a copy of CardinalPoints
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ascendingEquinox = null,Object? northernSolstice = null,Object? descendingEquinox = null,Object? southernSolstice = null,}) {
  return _then(_self.copyWith(
ascendingEquinox: null == ascendingEquinox ? _self.ascendingEquinox : ascendingEquinox // ignore: cast_nullable_to_non_nullable
as double,northernSolstice: null == northernSolstice ? _self.northernSolstice : northernSolstice // ignore: cast_nullable_to_non_nullable
as double,descendingEquinox: null == descendingEquinox ? _self.descendingEquinox : descendingEquinox // ignore: cast_nullable_to_non_nullable
as double,southernSolstice: null == southernSolstice ? _self.southernSolstice : southernSolstice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CardinalPoints].
extension CardinalPointsPatterns on CardinalPoints {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardinalPoints value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardinalPoints() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardinalPoints value)  $default,){
final _that = this;
switch (_that) {
case _CardinalPoints():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardinalPoints value)?  $default,){
final _that = this;
switch (_that) {
case _CardinalPoints() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double ascendingEquinox,  double northernSolstice,  double descendingEquinox,  double southernSolstice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardinalPoints() when $default != null:
return $default(_that.ascendingEquinox,_that.northernSolstice,_that.descendingEquinox,_that.southernSolstice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double ascendingEquinox,  double northernSolstice,  double descendingEquinox,  double southernSolstice)  $default,) {final _that = this;
switch (_that) {
case _CardinalPoints():
return $default(_that.ascendingEquinox,_that.northernSolstice,_that.descendingEquinox,_that.southernSolstice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double ascendingEquinox,  double northernSolstice,  double descendingEquinox,  double southernSolstice)?  $default,) {final _that = this;
switch (_that) {
case _CardinalPoints() when $default != null:
return $default(_that.ascendingEquinox,_that.northernSolstice,_that.descendingEquinox,_that.southernSolstice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardinalPoints implements CardinalPoints {
  const _CardinalPoints({required this.ascendingEquinox, required this.northernSolstice, required this.descendingEquinox, required this.southernSolstice});
  factory _CardinalPoints.fromJson(Map<String, dynamic> json) => _$CardinalPointsFromJson(json);

@override final  double ascendingEquinox;
@override final  double northernSolstice;
@override final  double descendingEquinox;
@override final  double southernSolstice;

/// Create a copy of CardinalPoints
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardinalPointsCopyWith<_CardinalPoints> get copyWith => __$CardinalPointsCopyWithImpl<_CardinalPoints>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardinalPointsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardinalPoints&&(identical(other.ascendingEquinox, ascendingEquinox) || other.ascendingEquinox == ascendingEquinox)&&(identical(other.northernSolstice, northernSolstice) || other.northernSolstice == northernSolstice)&&(identical(other.descendingEquinox, descendingEquinox) || other.descendingEquinox == descendingEquinox)&&(identical(other.southernSolstice, southernSolstice) || other.southernSolstice == southernSolstice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ascendingEquinox,northernSolstice,descendingEquinox,southernSolstice);

@override
String toString() {
  return 'CardinalPoints(ascendingEquinox: $ascendingEquinox, northernSolstice: $northernSolstice, descendingEquinox: $descendingEquinox, southernSolstice: $southernSolstice)';
}


}

/// @nodoc
abstract mixin class _$CardinalPointsCopyWith<$Res> implements $CardinalPointsCopyWith<$Res> {
  factory _$CardinalPointsCopyWith(_CardinalPoints value, $Res Function(_CardinalPoints) _then) = __$CardinalPointsCopyWithImpl;
@override @useResult
$Res call({
 double ascendingEquinox, double northernSolstice, double descendingEquinox, double southernSolstice
});




}
/// @nodoc
class __$CardinalPointsCopyWithImpl<$Res>
    implements _$CardinalPointsCopyWith<$Res> {
  __$CardinalPointsCopyWithImpl(this._self, this._then);

  final _CardinalPoints _self;
  final $Res Function(_CardinalPoints) _then;

/// Create a copy of CardinalPoints
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ascendingEquinox = null,Object? northernSolstice = null,Object? descendingEquinox = null,Object? southernSolstice = null,}) {
  return _then(_CardinalPoints(
ascendingEquinox: null == ascendingEquinox ? _self.ascendingEquinox : ascendingEquinox // ignore: cast_nullable_to_non_nullable
as double,northernSolstice: null == northernSolstice ? _self.northernSolstice : northernSolstice // ignore: cast_nullable_to_non_nullable
as double,descendingEquinox: null == descendingEquinox ? _self.descendingEquinox : descendingEquinox // ignore: cast_nullable_to_non_nullable
as double,southernSolstice: null == southernSolstice ? _self.southernSolstice : southernSolstice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
