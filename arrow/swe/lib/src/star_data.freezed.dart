// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'star_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StarData {

 double? get apparentMagnitude; double? get riseJd; double? get setJd; bool get circumpolar;
/// Create a copy of StarData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StarDataCopyWith<StarData> get copyWith => _$StarDataCopyWithImpl<StarData>(this as StarData, _$identity);

  /// Serializes this StarData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StarData&&(identical(other.apparentMagnitude, apparentMagnitude) || other.apparentMagnitude == apparentMagnitude)&&(identical(other.riseJd, riseJd) || other.riseJd == riseJd)&&(identical(other.setJd, setJd) || other.setJd == setJd)&&(identical(other.circumpolar, circumpolar) || other.circumpolar == circumpolar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,apparentMagnitude,riseJd,setJd,circumpolar);

@override
String toString() {
  return 'StarData(apparentMagnitude: $apparentMagnitude, riseJd: $riseJd, setJd: $setJd, circumpolar: $circumpolar)';
}


}

/// @nodoc
abstract mixin class $StarDataCopyWith<$Res>  {
  factory $StarDataCopyWith(StarData value, $Res Function(StarData) _then) = _$StarDataCopyWithImpl;
@useResult
$Res call({
 double? apparentMagnitude, double? riseJd, double? setJd, bool circumpolar
});




}
/// @nodoc
class _$StarDataCopyWithImpl<$Res>
    implements $StarDataCopyWith<$Res> {
  _$StarDataCopyWithImpl(this._self, this._then);

  final StarData _self;
  final $Res Function(StarData) _then;

/// Create a copy of StarData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? apparentMagnitude = freezed,Object? riseJd = freezed,Object? setJd = freezed,Object? circumpolar = null,}) {
  return _then(_self.copyWith(
apparentMagnitude: freezed == apparentMagnitude ? _self.apparentMagnitude : apparentMagnitude // ignore: cast_nullable_to_non_nullable
as double?,riseJd: freezed == riseJd ? _self.riseJd : riseJd // ignore: cast_nullable_to_non_nullable
as double?,setJd: freezed == setJd ? _self.setJd : setJd // ignore: cast_nullable_to_non_nullable
as double?,circumpolar: null == circumpolar ? _self.circumpolar : circumpolar // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StarData].
extension StarDataPatterns on StarData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StarData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StarData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StarData value)  $default,){
final _that = this;
switch (_that) {
case _StarData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StarData value)?  $default,){
final _that = this;
switch (_that) {
case _StarData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? apparentMagnitude,  double? riseJd,  double? setJd,  bool circumpolar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StarData() when $default != null:
return $default(_that.apparentMagnitude,_that.riseJd,_that.setJd,_that.circumpolar);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? apparentMagnitude,  double? riseJd,  double? setJd,  bool circumpolar)  $default,) {final _that = this;
switch (_that) {
case _StarData():
return $default(_that.apparentMagnitude,_that.riseJd,_that.setJd,_that.circumpolar);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? apparentMagnitude,  double? riseJd,  double? setJd,  bool circumpolar)?  $default,) {final _that = this;
switch (_that) {
case _StarData() when $default != null:
return $default(_that.apparentMagnitude,_that.riseJd,_that.setJd,_that.circumpolar);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StarData implements StarData {
  const _StarData({this.apparentMagnitude, this.riseJd, this.setJd, this.circumpolar = false});
  factory _StarData.fromJson(Map<String, dynamic> json) => _$StarDataFromJson(json);

@override final  double? apparentMagnitude;
@override final  double? riseJd;
@override final  double? setJd;
@override@JsonKey() final  bool circumpolar;

/// Create a copy of StarData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StarDataCopyWith<_StarData> get copyWith => __$StarDataCopyWithImpl<_StarData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StarDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StarData&&(identical(other.apparentMagnitude, apparentMagnitude) || other.apparentMagnitude == apparentMagnitude)&&(identical(other.riseJd, riseJd) || other.riseJd == riseJd)&&(identical(other.setJd, setJd) || other.setJd == setJd)&&(identical(other.circumpolar, circumpolar) || other.circumpolar == circumpolar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,apparentMagnitude,riseJd,setJd,circumpolar);

@override
String toString() {
  return 'StarData(apparentMagnitude: $apparentMagnitude, riseJd: $riseJd, setJd: $setJd, circumpolar: $circumpolar)';
}


}

/// @nodoc
abstract mixin class _$StarDataCopyWith<$Res> implements $StarDataCopyWith<$Res> {
  factory _$StarDataCopyWith(_StarData value, $Res Function(_StarData) _then) = __$StarDataCopyWithImpl;
@override @useResult
$Res call({
 double? apparentMagnitude, double? riseJd, double? setJd, bool circumpolar
});




}
/// @nodoc
class __$StarDataCopyWithImpl<$Res>
    implements _$StarDataCopyWith<$Res> {
  __$StarDataCopyWithImpl(this._self, this._then);

  final _StarData _self;
  final $Res Function(_StarData) _then;

/// Create a copy of StarData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? apparentMagnitude = freezed,Object? riseJd = freezed,Object? setJd = freezed,Object? circumpolar = null,}) {
  return _then(_StarData(
apparentMagnitude: freezed == apparentMagnitude ? _self.apparentMagnitude : apparentMagnitude // ignore: cast_nullable_to_non_nullable
as double?,riseJd: freezed == riseJd ? _self.riseJd : riseJd // ignore: cast_nullable_to_non_nullable
as double?,setJd: freezed == setJd ? _self.setJd : setJd // ignore: cast_nullable_to_non_nullable
as double?,circumpolar: null == circumpolar ? _self.circumpolar : circumpolar // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
