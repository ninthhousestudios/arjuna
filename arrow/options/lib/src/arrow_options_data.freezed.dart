// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'arrow_options_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ArrowOptions {

 SweConfig get sweConfig; CalcConfig get calcConfig;
/// Create a copy of ArrowOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArrowOptionsCopyWith<ArrowOptions> get copyWith => _$ArrowOptionsCopyWithImpl<ArrowOptions>(this as ArrowOptions, _$identity);

  /// Serializes this ArrowOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArrowOptions&&(identical(other.sweConfig, sweConfig) || other.sweConfig == sweConfig)&&(identical(other.calcConfig, calcConfig) || other.calcConfig == calcConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sweConfig,calcConfig);

@override
String toString() {
  return 'ArrowOptions(sweConfig: $sweConfig, calcConfig: $calcConfig)';
}


}

/// @nodoc
abstract mixin class $ArrowOptionsCopyWith<$Res>  {
  factory $ArrowOptionsCopyWith(ArrowOptions value, $Res Function(ArrowOptions) _then) = _$ArrowOptionsCopyWithImpl;
@useResult
$Res call({
 SweConfig sweConfig, CalcConfig calcConfig
});


$SweConfigCopyWith<$Res> get sweConfig;$CalcConfigCopyWith<$Res> get calcConfig;

}
/// @nodoc
class _$ArrowOptionsCopyWithImpl<$Res>
    implements $ArrowOptionsCopyWith<$Res> {
  _$ArrowOptionsCopyWithImpl(this._self, this._then);

  final ArrowOptions _self;
  final $Res Function(ArrowOptions) _then;

/// Create a copy of ArrowOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sweConfig = null,Object? calcConfig = null,}) {
  return _then(_self.copyWith(
sweConfig: null == sweConfig ? _self.sweConfig : sweConfig // ignore: cast_nullable_to_non_nullable
as SweConfig,calcConfig: null == calcConfig ? _self.calcConfig : calcConfig // ignore: cast_nullable_to_non_nullable
as CalcConfig,
  ));
}
/// Create a copy of ArrowOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SweConfigCopyWith<$Res> get sweConfig {
  
  return $SweConfigCopyWith<$Res>(_self.sweConfig, (value) {
    return _then(_self.copyWith(sweConfig: value));
  });
}/// Create a copy of ArrowOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalcConfigCopyWith<$Res> get calcConfig {
  
  return $CalcConfigCopyWith<$Res>(_self.calcConfig, (value) {
    return _then(_self.copyWith(calcConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [ArrowOptions].
extension ArrowOptionsPatterns on ArrowOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArrowOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArrowOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArrowOptions value)  $default,){
final _that = this;
switch (_that) {
case _ArrowOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArrowOptions value)?  $default,){
final _that = this;
switch (_that) {
case _ArrowOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SweConfig sweConfig,  CalcConfig calcConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArrowOptions() when $default != null:
return $default(_that.sweConfig,_that.calcConfig);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SweConfig sweConfig,  CalcConfig calcConfig)  $default,) {final _that = this;
switch (_that) {
case _ArrowOptions():
return $default(_that.sweConfig,_that.calcConfig);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SweConfig sweConfig,  CalcConfig calcConfig)?  $default,) {final _that = this;
switch (_that) {
case _ArrowOptions() when $default != null:
return $default(_that.sweConfig,_that.calcConfig);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ArrowOptions extends ArrowOptions {
  const _ArrowOptions({this.sweConfig = const SweConfig(), this.calcConfig = const CalcConfig()}): super._();
  factory _ArrowOptions.fromJson(Map<String, dynamic> json) => _$ArrowOptionsFromJson(json);

@override@JsonKey() final  SweConfig sweConfig;
@override@JsonKey() final  CalcConfig calcConfig;

/// Create a copy of ArrowOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArrowOptionsCopyWith<_ArrowOptions> get copyWith => __$ArrowOptionsCopyWithImpl<_ArrowOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArrowOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArrowOptions&&(identical(other.sweConfig, sweConfig) || other.sweConfig == sweConfig)&&(identical(other.calcConfig, calcConfig) || other.calcConfig == calcConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sweConfig,calcConfig);

@override
String toString() {
  return 'ArrowOptions(sweConfig: $sweConfig, calcConfig: $calcConfig)';
}


}

/// @nodoc
abstract mixin class _$ArrowOptionsCopyWith<$Res> implements $ArrowOptionsCopyWith<$Res> {
  factory _$ArrowOptionsCopyWith(_ArrowOptions value, $Res Function(_ArrowOptions) _then) = __$ArrowOptionsCopyWithImpl;
@override @useResult
$Res call({
 SweConfig sweConfig, CalcConfig calcConfig
});


@override $SweConfigCopyWith<$Res> get sweConfig;@override $CalcConfigCopyWith<$Res> get calcConfig;

}
/// @nodoc
class __$ArrowOptionsCopyWithImpl<$Res>
    implements _$ArrowOptionsCopyWith<$Res> {
  __$ArrowOptionsCopyWithImpl(this._self, this._then);

  final _ArrowOptions _self;
  final $Res Function(_ArrowOptions) _then;

/// Create a copy of ArrowOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sweConfig = null,Object? calcConfig = null,}) {
  return _then(_ArrowOptions(
sweConfig: null == sweConfig ? _self.sweConfig : sweConfig // ignore: cast_nullable_to_non_nullable
as SweConfig,calcConfig: null == calcConfig ? _self.calcConfig : calcConfig // ignore: cast_nullable_to_non_nullable
as CalcConfig,
  ));
}

/// Create a copy of ArrowOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SweConfigCopyWith<$Res> get sweConfig {
  
  return $SweConfigCopyWith<$Res>(_self.sweConfig, (value) {
    return _then(_self.copyWith(sweConfig: value));
  });
}/// Create a copy of ArrowOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalcConfigCopyWith<$Res> get calcConfig {
  
  return $CalcConfigCopyWith<$Res>(_self.calcConfig, (value) {
    return _then(_self.copyWith(calcConfig: value));
  });
}
}

// dart format on
