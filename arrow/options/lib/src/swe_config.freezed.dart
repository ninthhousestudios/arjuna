// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swe_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SweConfig {

 Set<Body> get bodies; Ayanamsa get signAyanamsa; HouseSystem get houseSystem; bool get trueNode; bool get topocentric; EphemerisSource get ephemerisSource; Set<ReferencePoint> get extraFrames; Set<Star> get stars; Set<String> get customStarNames; Ayanamsa get nakAyanamsa;
/// Create a copy of SweConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SweConfigCopyWith<SweConfig> get copyWith => _$SweConfigCopyWithImpl<SweConfig>(this as SweConfig, _$identity);

  /// Serializes this SweConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SweConfig&&const DeepCollectionEquality().equals(other.bodies, bodies)&&(identical(other.signAyanamsa, signAyanamsa) || other.signAyanamsa == signAyanamsa)&&(identical(other.houseSystem, houseSystem) || other.houseSystem == houseSystem)&&(identical(other.trueNode, trueNode) || other.trueNode == trueNode)&&(identical(other.topocentric, topocentric) || other.topocentric == topocentric)&&(identical(other.ephemerisSource, ephemerisSource) || other.ephemerisSource == ephemerisSource)&&const DeepCollectionEquality().equals(other.extraFrames, extraFrames)&&const DeepCollectionEquality().equals(other.stars, stars)&&const DeepCollectionEquality().equals(other.customStarNames, customStarNames)&&(identical(other.nakAyanamsa, nakAyanamsa) || other.nakAyanamsa == nakAyanamsa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bodies),signAyanamsa,houseSystem,trueNode,topocentric,ephemerisSource,const DeepCollectionEquality().hash(extraFrames),const DeepCollectionEquality().hash(stars),const DeepCollectionEquality().hash(customStarNames),nakAyanamsa);

@override
String toString() {
  return 'SweConfig(bodies: $bodies, signAyanamsa: $signAyanamsa, houseSystem: $houseSystem, trueNode: $trueNode, topocentric: $topocentric, ephemerisSource: $ephemerisSource, extraFrames: $extraFrames, stars: $stars, customStarNames: $customStarNames, nakAyanamsa: $nakAyanamsa)';
}


}

/// @nodoc
abstract mixin class $SweConfigCopyWith<$Res>  {
  factory $SweConfigCopyWith(SweConfig value, $Res Function(SweConfig) _then) = _$SweConfigCopyWithImpl;
@useResult
$Res call({
 Set<Body> bodies, Ayanamsa signAyanamsa, HouseSystem houseSystem, bool trueNode, bool topocentric, EphemerisSource ephemerisSource, Set<ReferencePoint> extraFrames, Set<Star> stars, Set<String> customStarNames, Ayanamsa nakAyanamsa
});




}
/// @nodoc
class _$SweConfigCopyWithImpl<$Res>
    implements $SweConfigCopyWith<$Res> {
  _$SweConfigCopyWithImpl(this._self, this._then);

  final SweConfig _self;
  final $Res Function(SweConfig) _then;

/// Create a copy of SweConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bodies = null,Object? signAyanamsa = null,Object? houseSystem = null,Object? trueNode = null,Object? topocentric = null,Object? ephemerisSource = null,Object? extraFrames = null,Object? stars = null,Object? customStarNames = null,Object? nakAyanamsa = null,}) {
  return _then(_self.copyWith(
bodies: null == bodies ? _self.bodies : bodies // ignore: cast_nullable_to_non_nullable
as Set<Body>,signAyanamsa: null == signAyanamsa ? _self.signAyanamsa : signAyanamsa // ignore: cast_nullable_to_non_nullable
as Ayanamsa,houseSystem: null == houseSystem ? _self.houseSystem : houseSystem // ignore: cast_nullable_to_non_nullable
as HouseSystem,trueNode: null == trueNode ? _self.trueNode : trueNode // ignore: cast_nullable_to_non_nullable
as bool,topocentric: null == topocentric ? _self.topocentric : topocentric // ignore: cast_nullable_to_non_nullable
as bool,ephemerisSource: null == ephemerisSource ? _self.ephemerisSource : ephemerisSource // ignore: cast_nullable_to_non_nullable
as EphemerisSource,extraFrames: null == extraFrames ? _self.extraFrames : extraFrames // ignore: cast_nullable_to_non_nullable
as Set<ReferencePoint>,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as Set<Star>,customStarNames: null == customStarNames ? _self.customStarNames : customStarNames // ignore: cast_nullable_to_non_nullable
as Set<String>,nakAyanamsa: null == nakAyanamsa ? _self.nakAyanamsa : nakAyanamsa // ignore: cast_nullable_to_non_nullable
as Ayanamsa,
  ));
}

}


/// Adds pattern-matching-related methods to [SweConfig].
extension SweConfigPatterns on SweConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SweConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SweConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SweConfig value)  $default,){
final _that = this;
switch (_that) {
case _SweConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SweConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SweConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<Body> bodies,  Ayanamsa signAyanamsa,  HouseSystem houseSystem,  bool trueNode,  bool topocentric,  EphemerisSource ephemerisSource,  Set<ReferencePoint> extraFrames,  Set<Star> stars,  Set<String> customStarNames,  Ayanamsa nakAyanamsa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SweConfig() when $default != null:
return $default(_that.bodies,_that.signAyanamsa,_that.houseSystem,_that.trueNode,_that.topocentric,_that.ephemerisSource,_that.extraFrames,_that.stars,_that.customStarNames,_that.nakAyanamsa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<Body> bodies,  Ayanamsa signAyanamsa,  HouseSystem houseSystem,  bool trueNode,  bool topocentric,  EphemerisSource ephemerisSource,  Set<ReferencePoint> extraFrames,  Set<Star> stars,  Set<String> customStarNames,  Ayanamsa nakAyanamsa)  $default,) {final _that = this;
switch (_that) {
case _SweConfig():
return $default(_that.bodies,_that.signAyanamsa,_that.houseSystem,_that.trueNode,_that.topocentric,_that.ephemerisSource,_that.extraFrames,_that.stars,_that.customStarNames,_that.nakAyanamsa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<Body> bodies,  Ayanamsa signAyanamsa,  HouseSystem houseSystem,  bool trueNode,  bool topocentric,  EphemerisSource ephemerisSource,  Set<ReferencePoint> extraFrames,  Set<Star> stars,  Set<String> customStarNames,  Ayanamsa nakAyanamsa)?  $default,) {final _that = this;
switch (_that) {
case _SweConfig() when $default != null:
return $default(_that.bodies,_that.signAyanamsa,_that.houseSystem,_that.trueNode,_that.topocentric,_that.ephemerisSource,_that.extraFrames,_that.stars,_that.customStarNames,_that.nakAyanamsa);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SweConfig implements SweConfig {
  const _SweConfig({final  Set<Body> bodies = const {Body.sun, Body.moon, Body.mercury, Body.venus, Body.mars, Body.jupiter, Body.saturn, Body.rahu, Body.ketu}, this.signAyanamsa = Ayanamsa.tropical, this.houseSystem = HouseSystem.campanus, this.trueNode = true, this.topocentric = false, this.ephemerisSource = EphemerisSource.swissEph, final  Set<ReferencePoint> extraFrames = const <ReferencePoint>{}, final  Set<Star> stars = const <Star>{}, final  Set<String> customStarNames = const <String>{}, this.nakAyanamsa = Ayanamsa.dhruva}): _bodies = bodies,_extraFrames = extraFrames,_stars = stars,_customStarNames = customStarNames;
  factory _SweConfig.fromJson(Map<String, dynamic> json) => _$SweConfigFromJson(json);

 final  Set<Body> _bodies;
@override@JsonKey() Set<Body> get bodies {
  if (_bodies is EqualUnmodifiableSetView) return _bodies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_bodies);
}

@override@JsonKey() final  Ayanamsa signAyanamsa;
@override@JsonKey() final  HouseSystem houseSystem;
@override@JsonKey() final  bool trueNode;
@override@JsonKey() final  bool topocentric;
@override@JsonKey() final  EphemerisSource ephemerisSource;
 final  Set<ReferencePoint> _extraFrames;
@override@JsonKey() Set<ReferencePoint> get extraFrames {
  if (_extraFrames is EqualUnmodifiableSetView) return _extraFrames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_extraFrames);
}

 final  Set<Star> _stars;
@override@JsonKey() Set<Star> get stars {
  if (_stars is EqualUnmodifiableSetView) return _stars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_stars);
}

 final  Set<String> _customStarNames;
@override@JsonKey() Set<String> get customStarNames {
  if (_customStarNames is EqualUnmodifiableSetView) return _customStarNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_customStarNames);
}

@override@JsonKey() final  Ayanamsa nakAyanamsa;

/// Create a copy of SweConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SweConfigCopyWith<_SweConfig> get copyWith => __$SweConfigCopyWithImpl<_SweConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SweConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SweConfig&&const DeepCollectionEquality().equals(other._bodies, _bodies)&&(identical(other.signAyanamsa, signAyanamsa) || other.signAyanamsa == signAyanamsa)&&(identical(other.houseSystem, houseSystem) || other.houseSystem == houseSystem)&&(identical(other.trueNode, trueNode) || other.trueNode == trueNode)&&(identical(other.topocentric, topocentric) || other.topocentric == topocentric)&&(identical(other.ephemerisSource, ephemerisSource) || other.ephemerisSource == ephemerisSource)&&const DeepCollectionEquality().equals(other._extraFrames, _extraFrames)&&const DeepCollectionEquality().equals(other._stars, _stars)&&const DeepCollectionEquality().equals(other._customStarNames, _customStarNames)&&(identical(other.nakAyanamsa, nakAyanamsa) || other.nakAyanamsa == nakAyanamsa));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bodies),signAyanamsa,houseSystem,trueNode,topocentric,ephemerisSource,const DeepCollectionEquality().hash(_extraFrames),const DeepCollectionEquality().hash(_stars),const DeepCollectionEquality().hash(_customStarNames),nakAyanamsa);

@override
String toString() {
  return 'SweConfig(bodies: $bodies, signAyanamsa: $signAyanamsa, houseSystem: $houseSystem, trueNode: $trueNode, topocentric: $topocentric, ephemerisSource: $ephemerisSource, extraFrames: $extraFrames, stars: $stars, customStarNames: $customStarNames, nakAyanamsa: $nakAyanamsa)';
}


}

/// @nodoc
abstract mixin class _$SweConfigCopyWith<$Res> implements $SweConfigCopyWith<$Res> {
  factory _$SweConfigCopyWith(_SweConfig value, $Res Function(_SweConfig) _then) = __$SweConfigCopyWithImpl;
@override @useResult
$Res call({
 Set<Body> bodies, Ayanamsa signAyanamsa, HouseSystem houseSystem, bool trueNode, bool topocentric, EphemerisSource ephemerisSource, Set<ReferencePoint> extraFrames, Set<Star> stars, Set<String> customStarNames, Ayanamsa nakAyanamsa
});




}
/// @nodoc
class __$SweConfigCopyWithImpl<$Res>
    implements _$SweConfigCopyWith<$Res> {
  __$SweConfigCopyWithImpl(this._self, this._then);

  final _SweConfig _self;
  final $Res Function(_SweConfig) _then;

/// Create a copy of SweConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bodies = null,Object? signAyanamsa = null,Object? houseSystem = null,Object? trueNode = null,Object? topocentric = null,Object? ephemerisSource = null,Object? extraFrames = null,Object? stars = null,Object? customStarNames = null,Object? nakAyanamsa = null,}) {
  return _then(_SweConfig(
bodies: null == bodies ? _self._bodies : bodies // ignore: cast_nullable_to_non_nullable
as Set<Body>,signAyanamsa: null == signAyanamsa ? _self.signAyanamsa : signAyanamsa // ignore: cast_nullable_to_non_nullable
as Ayanamsa,houseSystem: null == houseSystem ? _self.houseSystem : houseSystem // ignore: cast_nullable_to_non_nullable
as HouseSystem,trueNode: null == trueNode ? _self.trueNode : trueNode // ignore: cast_nullable_to_non_nullable
as bool,topocentric: null == topocentric ? _self.topocentric : topocentric // ignore: cast_nullable_to_non_nullable
as bool,ephemerisSource: null == ephemerisSource ? _self.ephemerisSource : ephemerisSource // ignore: cast_nullable_to_non_nullable
as EphemerisSource,extraFrames: null == extraFrames ? _self._extraFrames : extraFrames // ignore: cast_nullable_to_non_nullable
as Set<ReferencePoint>,stars: null == stars ? _self._stars : stars // ignore: cast_nullable_to_non_nullable
as Set<Star>,customStarNames: null == customStarNames ? _self._customStarNames : customStarNames // ignore: cast_nullable_to_non_nullable
as Set<String>,nakAyanamsa: null == nakAyanamsa ? _self.nakAyanamsa : nakAyanamsa // ignore: cast_nullable_to_non_nullable
as Ayanamsa,
  ));
}


}

// dart format on
