// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calc_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalcConfig {

 Circle get circle; bool get nakEquatorial; Set<Tradition> get traditions; ZodiacSystem get zodiacSystem; VedicConfig get vedic;
/// Create a copy of CalcConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalcConfigCopyWith<CalcConfig> get copyWith => _$CalcConfigCopyWithImpl<CalcConfig>(this as CalcConfig, _$identity);

  /// Serializes this CalcConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalcConfig&&(identical(other.circle, circle) || other.circle == circle)&&(identical(other.nakEquatorial, nakEquatorial) || other.nakEquatorial == nakEquatorial)&&const DeepCollectionEquality().equals(other.traditions, traditions)&&(identical(other.zodiacSystem, zodiacSystem) || other.zodiacSystem == zodiacSystem)&&(identical(other.vedic, vedic) || other.vedic == vedic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,circle,nakEquatorial,const DeepCollectionEquality().hash(traditions),zodiacSystem,vedic);

@override
String toString() {
  return 'CalcConfig(circle: $circle, nakEquatorial: $nakEquatorial, traditions: $traditions, zodiacSystem: $zodiacSystem, vedic: $vedic)';
}


}

/// @nodoc
abstract mixin class $CalcConfigCopyWith<$Res>  {
  factory $CalcConfigCopyWith(CalcConfig value, $Res Function(CalcConfig) _then) = _$CalcConfigCopyWithImpl;
@useResult
$Res call({
 Circle circle, bool nakEquatorial, Set<Tradition> traditions, ZodiacSystem zodiacSystem, VedicConfig vedic
});


$VedicConfigCopyWith<$Res> get vedic;

}
/// @nodoc
class _$CalcConfigCopyWithImpl<$Res>
    implements $CalcConfigCopyWith<$Res> {
  _$CalcConfigCopyWithImpl(this._self, this._then);

  final CalcConfig _self;
  final $Res Function(CalcConfig) _then;

/// Create a copy of CalcConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? circle = null,Object? nakEquatorial = null,Object? traditions = null,Object? zodiacSystem = null,Object? vedic = null,}) {
  return _then(_self.copyWith(
circle: null == circle ? _self.circle : circle // ignore: cast_nullable_to_non_nullable
as Circle,nakEquatorial: null == nakEquatorial ? _self.nakEquatorial : nakEquatorial // ignore: cast_nullable_to_non_nullable
as bool,traditions: null == traditions ? _self.traditions : traditions // ignore: cast_nullable_to_non_nullable
as Set<Tradition>,zodiacSystem: null == zodiacSystem ? _self.zodiacSystem : zodiacSystem // ignore: cast_nullable_to_non_nullable
as ZodiacSystem,vedic: null == vedic ? _self.vedic : vedic // ignore: cast_nullable_to_non_nullable
as VedicConfig,
  ));
}
/// Create a copy of CalcConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VedicConfigCopyWith<$Res> get vedic {
  
  return $VedicConfigCopyWith<$Res>(_self.vedic, (value) {
    return _then(_self.copyWith(vedic: value));
  });
}
}


/// Adds pattern-matching-related methods to [CalcConfig].
extension CalcConfigPatterns on CalcConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalcConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalcConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalcConfig value)  $default,){
final _that = this;
switch (_that) {
case _CalcConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalcConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CalcConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Circle circle,  bool nakEquatorial,  Set<Tradition> traditions,  ZodiacSystem zodiacSystem,  VedicConfig vedic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalcConfig() when $default != null:
return $default(_that.circle,_that.nakEquatorial,_that.traditions,_that.zodiacSystem,_that.vedic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Circle circle,  bool nakEquatorial,  Set<Tradition> traditions,  ZodiacSystem zodiacSystem,  VedicConfig vedic)  $default,) {final _that = this;
switch (_that) {
case _CalcConfig():
return $default(_that.circle,_that.nakEquatorial,_that.traditions,_that.zodiacSystem,_that.vedic);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Circle circle,  bool nakEquatorial,  Set<Tradition> traditions,  ZodiacSystem zodiacSystem,  VedicConfig vedic)?  $default,) {final _that = this;
switch (_that) {
case _CalcConfig() when $default != null:
return $default(_that.circle,_that.nakEquatorial,_that.traditions,_that.zodiacSystem,_that.vedic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalcConfig implements CalcConfig {
  const _CalcConfig({this.circle = Circle.aditya, this.nakEquatorial = true, final  Set<Tradition> traditions = const {Tradition.vedic}, this.zodiacSystem = ZodiacSystem.sidereal12, this.vedic = const VedicConfig()}): _traditions = traditions;
  factory _CalcConfig.fromJson(Map<String, dynamic> json) => _$CalcConfigFromJson(json);

@override@JsonKey() final  Circle circle;
@override@JsonKey() final  bool nakEquatorial;
 final  Set<Tradition> _traditions;
@override@JsonKey() Set<Tradition> get traditions {
  if (_traditions is EqualUnmodifiableSetView) return _traditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_traditions);
}

@override@JsonKey() final  ZodiacSystem zodiacSystem;
@override@JsonKey() final  VedicConfig vedic;

/// Create a copy of CalcConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalcConfigCopyWith<_CalcConfig> get copyWith => __$CalcConfigCopyWithImpl<_CalcConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalcConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalcConfig&&(identical(other.circle, circle) || other.circle == circle)&&(identical(other.nakEquatorial, nakEquatorial) || other.nakEquatorial == nakEquatorial)&&const DeepCollectionEquality().equals(other._traditions, _traditions)&&(identical(other.zodiacSystem, zodiacSystem) || other.zodiacSystem == zodiacSystem)&&(identical(other.vedic, vedic) || other.vedic == vedic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,circle,nakEquatorial,const DeepCollectionEquality().hash(_traditions),zodiacSystem,vedic);

@override
String toString() {
  return 'CalcConfig(circle: $circle, nakEquatorial: $nakEquatorial, traditions: $traditions, zodiacSystem: $zodiacSystem, vedic: $vedic)';
}


}

/// @nodoc
abstract mixin class _$CalcConfigCopyWith<$Res> implements $CalcConfigCopyWith<$Res> {
  factory _$CalcConfigCopyWith(_CalcConfig value, $Res Function(_CalcConfig) _then) = __$CalcConfigCopyWithImpl;
@override @useResult
$Res call({
 Circle circle, bool nakEquatorial, Set<Tradition> traditions, ZodiacSystem zodiacSystem, VedicConfig vedic
});


@override $VedicConfigCopyWith<$Res> get vedic;

}
/// @nodoc
class __$CalcConfigCopyWithImpl<$Res>
    implements _$CalcConfigCopyWith<$Res> {
  __$CalcConfigCopyWithImpl(this._self, this._then);

  final _CalcConfig _self;
  final $Res Function(_CalcConfig) _then;

/// Create a copy of CalcConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? circle = null,Object? nakEquatorial = null,Object? traditions = null,Object? zodiacSystem = null,Object? vedic = null,}) {
  return _then(_CalcConfig(
circle: null == circle ? _self.circle : circle // ignore: cast_nullable_to_non_nullable
as Circle,nakEquatorial: null == nakEquatorial ? _self.nakEquatorial : nakEquatorial // ignore: cast_nullable_to_non_nullable
as bool,traditions: null == traditions ? _self._traditions : traditions // ignore: cast_nullable_to_non_nullable
as Set<Tradition>,zodiacSystem: null == zodiacSystem ? _self.zodiacSystem : zodiacSystem // ignore: cast_nullable_to_non_nullable
as ZodiacSystem,vedic: null == vedic ? _self.vedic : vedic // ignore: cast_nullable_to_non_nullable
as VedicConfig,
  ));
}

/// Create a copy of CalcConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VedicConfigCopyWith<$Res> get vedic {
  
  return $VedicConfigCopyWith<$Res>(_self.vedic, (value) {
    return _then(_self.copyWith(vedic: value));
  });
}
}

// dart format on
