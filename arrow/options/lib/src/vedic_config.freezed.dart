// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2026 Ninth House Studios LLC

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vedic_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VedicConfig {

/// Number of chara karakas: 7 (standard) or 8 (includes Rahu).
 int get charaKarakaCount; DashaYearLength get dashaYearLength; RashiAspectMode get rashiAspectMode;
/// Create a copy of VedicConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VedicConfigCopyWith<VedicConfig> get copyWith => _$VedicConfigCopyWithImpl<VedicConfig>(this as VedicConfig, _$identity);

  /// Serializes this VedicConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VedicConfig&&(identical(other.charaKarakaCount, charaKarakaCount) || other.charaKarakaCount == charaKarakaCount)&&(identical(other.dashaYearLength, dashaYearLength) || other.dashaYearLength == dashaYearLength)&&(identical(other.rashiAspectMode, rashiAspectMode) || other.rashiAspectMode == rashiAspectMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,charaKarakaCount,dashaYearLength,rashiAspectMode);

@override
String toString() {
  return 'VedicConfig(charaKarakaCount: $charaKarakaCount, dashaYearLength: $dashaYearLength, rashiAspectMode: $rashiAspectMode)';
}


}

/// @nodoc
abstract mixin class $VedicConfigCopyWith<$Res>  {
  factory $VedicConfigCopyWith(VedicConfig value, $Res Function(VedicConfig) _then) = _$VedicConfigCopyWithImpl;
@useResult
$Res call({
 int charaKarakaCount, DashaYearLength dashaYearLength, RashiAspectMode rashiAspectMode
});




}
/// @nodoc
class _$VedicConfigCopyWithImpl<$Res>
    implements $VedicConfigCopyWith<$Res> {
  _$VedicConfigCopyWithImpl(this._self, this._then);

  final VedicConfig _self;
  final $Res Function(VedicConfig) _then;

/// Create a copy of VedicConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? charaKarakaCount = null,Object? dashaYearLength = null,Object? rashiAspectMode = null,}) {
  return _then(_self.copyWith(
charaKarakaCount: null == charaKarakaCount ? _self.charaKarakaCount : charaKarakaCount // ignore: cast_nullable_to_non_nullable
as int,dashaYearLength: null == dashaYearLength ? _self.dashaYearLength : dashaYearLength // ignore: cast_nullable_to_non_nullable
as DashaYearLength,rashiAspectMode: null == rashiAspectMode ? _self.rashiAspectMode : rashiAspectMode // ignore: cast_nullable_to_non_nullable
as RashiAspectMode,
  ));
}

}


/// Adds pattern-matching-related methods to [VedicConfig].
extension VedicConfigPatterns on VedicConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VedicConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VedicConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VedicConfig value)  $default,){
final _that = this;
switch (_that) {
case _VedicConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VedicConfig value)?  $default,){
final _that = this;
switch (_that) {
case _VedicConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int charaKarakaCount,  DashaYearLength dashaYearLength,  RashiAspectMode rashiAspectMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VedicConfig() when $default != null:
return $default(_that.charaKarakaCount,_that.dashaYearLength,_that.rashiAspectMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int charaKarakaCount,  DashaYearLength dashaYearLength,  RashiAspectMode rashiAspectMode)  $default,) {final _that = this;
switch (_that) {
case _VedicConfig():
return $default(_that.charaKarakaCount,_that.dashaYearLength,_that.rashiAspectMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int charaKarakaCount,  DashaYearLength dashaYearLength,  RashiAspectMode rashiAspectMode)?  $default,) {final _that = this;
switch (_that) {
case _VedicConfig() when $default != null:
return $default(_that.charaKarakaCount,_that.dashaYearLength,_that.rashiAspectMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VedicConfig implements VedicConfig {
  const _VedicConfig({this.charaKarakaCount = 7, this.dashaYearLength = DashaYearLength.saura, this.rashiAspectMode = RashiAspectMode.quadrant});
  factory _VedicConfig.fromJson(Map<String, dynamic> json) => _$VedicConfigFromJson(json);

/// Number of chara karakas: 7 (standard) or 8 (includes Rahu).
@override@JsonKey() final  int charaKarakaCount;
@override@JsonKey() final  DashaYearLength dashaYearLength;
@override@JsonKey() final  RashiAspectMode rashiAspectMode;

/// Create a copy of VedicConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VedicConfigCopyWith<_VedicConfig> get copyWith => __$VedicConfigCopyWithImpl<_VedicConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VedicConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VedicConfig&&(identical(other.charaKarakaCount, charaKarakaCount) || other.charaKarakaCount == charaKarakaCount)&&(identical(other.dashaYearLength, dashaYearLength) || other.dashaYearLength == dashaYearLength)&&(identical(other.rashiAspectMode, rashiAspectMode) || other.rashiAspectMode == rashiAspectMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,charaKarakaCount,dashaYearLength,rashiAspectMode);

@override
String toString() {
  return 'VedicConfig(charaKarakaCount: $charaKarakaCount, dashaYearLength: $dashaYearLength, rashiAspectMode: $rashiAspectMode)';
}


}

/// @nodoc
abstract mixin class _$VedicConfigCopyWith<$Res> implements $VedicConfigCopyWith<$Res> {
  factory _$VedicConfigCopyWith(_VedicConfig value, $Res Function(_VedicConfig) _then) = __$VedicConfigCopyWithImpl;
@override @useResult
$Res call({
 int charaKarakaCount, DashaYearLength dashaYearLength, RashiAspectMode rashiAspectMode
});




}
/// @nodoc
class __$VedicConfigCopyWithImpl<$Res>
    implements _$VedicConfigCopyWith<$Res> {
  __$VedicConfigCopyWithImpl(this._self, this._then);

  final _VedicConfig _self;
  final $Res Function(_VedicConfig) _then;

/// Create a copy of VedicConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? charaKarakaCount = null,Object? dashaYearLength = null,Object? rashiAspectMode = null,}) {
  return _then(_VedicConfig(
charaKarakaCount: null == charaKarakaCount ? _self.charaKarakaCount : charaKarakaCount // ignore: cast_nullable_to_non_nullable
as int,dashaYearLength: null == dashaYearLength ? _self.dashaYearLength : dashaYearLength // ignore: cast_nullable_to_non_nullable
as DashaYearLength,rashiAspectMode: null == rashiAspectMode ? _self.rashiAspectMode : rashiAspectMode // ignore: cast_nullable_to_non_nullable
as RashiAspectMode,
  ));
}


}

// dart format on
