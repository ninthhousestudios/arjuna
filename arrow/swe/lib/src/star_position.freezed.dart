// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'star_position.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StarPosition {

 BodyPosition get ecliptic; BodyPosition get equatorial; StarData? get starData;
/// Create a copy of StarPosition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StarPositionCopyWith<StarPosition> get copyWith => _$StarPositionCopyWithImpl<StarPosition>(this as StarPosition, _$identity);

  /// Serializes this StarPosition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StarPosition&&(identical(other.ecliptic, ecliptic) || other.ecliptic == ecliptic)&&(identical(other.equatorial, equatorial) || other.equatorial == equatorial)&&(identical(other.starData, starData) || other.starData == starData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ecliptic,equatorial,starData);

@override
String toString() {
  return 'StarPosition(ecliptic: $ecliptic, equatorial: $equatorial, starData: $starData)';
}


}

/// @nodoc
abstract mixin class $StarPositionCopyWith<$Res>  {
  factory $StarPositionCopyWith(StarPosition value, $Res Function(StarPosition) _then) = _$StarPositionCopyWithImpl;
@useResult
$Res call({
 BodyPosition ecliptic, BodyPosition equatorial, StarData? starData
});


$BodyPositionCopyWith<$Res> get ecliptic;$BodyPositionCopyWith<$Res> get equatorial;$StarDataCopyWith<$Res>? get starData;

}
/// @nodoc
class _$StarPositionCopyWithImpl<$Res>
    implements $StarPositionCopyWith<$Res> {
  _$StarPositionCopyWithImpl(this._self, this._then);

  final StarPosition _self;
  final $Res Function(StarPosition) _then;

/// Create a copy of StarPosition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ecliptic = null,Object? equatorial = null,Object? starData = freezed,}) {
  return _then(_self.copyWith(
ecliptic: null == ecliptic ? _self.ecliptic : ecliptic // ignore: cast_nullable_to_non_nullable
as BodyPosition,equatorial: null == equatorial ? _self.equatorial : equatorial // ignore: cast_nullable_to_non_nullable
as BodyPosition,starData: freezed == starData ? _self.starData : starData // ignore: cast_nullable_to_non_nullable
as StarData?,
  ));
}
/// Create a copy of StarPosition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BodyPositionCopyWith<$Res> get ecliptic {
  
  return $BodyPositionCopyWith<$Res>(_self.ecliptic, (value) {
    return _then(_self.copyWith(ecliptic: value));
  });
}/// Create a copy of StarPosition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BodyPositionCopyWith<$Res> get equatorial {
  
  return $BodyPositionCopyWith<$Res>(_self.equatorial, (value) {
    return _then(_self.copyWith(equatorial: value));
  });
}/// Create a copy of StarPosition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StarDataCopyWith<$Res>? get starData {
    if (_self.starData == null) {
    return null;
  }

  return $StarDataCopyWith<$Res>(_self.starData!, (value) {
    return _then(_self.copyWith(starData: value));
  });
}
}


/// Adds pattern-matching-related methods to [StarPosition].
extension StarPositionPatterns on StarPosition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StarPosition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StarPosition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StarPosition value)  $default,){
final _that = this;
switch (_that) {
case _StarPosition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StarPosition value)?  $default,){
final _that = this;
switch (_that) {
case _StarPosition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BodyPosition ecliptic,  BodyPosition equatorial,  StarData? starData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StarPosition() when $default != null:
return $default(_that.ecliptic,_that.equatorial,_that.starData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BodyPosition ecliptic,  BodyPosition equatorial,  StarData? starData)  $default,) {final _that = this;
switch (_that) {
case _StarPosition():
return $default(_that.ecliptic,_that.equatorial,_that.starData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BodyPosition ecliptic,  BodyPosition equatorial,  StarData? starData)?  $default,) {final _that = this;
switch (_that) {
case _StarPosition() when $default != null:
return $default(_that.ecliptic,_that.equatorial,_that.starData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StarPosition implements StarPosition {
  const _StarPosition({required this.ecliptic, required this.equatorial, this.starData});
  factory _StarPosition.fromJson(Map<String, dynamic> json) => _$StarPositionFromJson(json);

@override final  BodyPosition ecliptic;
@override final  BodyPosition equatorial;
@override final  StarData? starData;

/// Create a copy of StarPosition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StarPositionCopyWith<_StarPosition> get copyWith => __$StarPositionCopyWithImpl<_StarPosition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StarPositionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StarPosition&&(identical(other.ecliptic, ecliptic) || other.ecliptic == ecliptic)&&(identical(other.equatorial, equatorial) || other.equatorial == equatorial)&&(identical(other.starData, starData) || other.starData == starData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ecliptic,equatorial,starData);

@override
String toString() {
  return 'StarPosition(ecliptic: $ecliptic, equatorial: $equatorial, starData: $starData)';
}


}

/// @nodoc
abstract mixin class _$StarPositionCopyWith<$Res> implements $StarPositionCopyWith<$Res> {
  factory _$StarPositionCopyWith(_StarPosition value, $Res Function(_StarPosition) _then) = __$StarPositionCopyWithImpl;
@override @useResult
$Res call({
 BodyPosition ecliptic, BodyPosition equatorial, StarData? starData
});


@override $BodyPositionCopyWith<$Res> get ecliptic;@override $BodyPositionCopyWith<$Res> get equatorial;@override $StarDataCopyWith<$Res>? get starData;

}
/// @nodoc
class __$StarPositionCopyWithImpl<$Res>
    implements _$StarPositionCopyWith<$Res> {
  __$StarPositionCopyWithImpl(this._self, this._then);

  final _StarPosition _self;
  final $Res Function(_StarPosition) _then;

/// Create a copy of StarPosition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ecliptic = null,Object? equatorial = null,Object? starData = freezed,}) {
  return _then(_StarPosition(
ecliptic: null == ecliptic ? _self.ecliptic : ecliptic // ignore: cast_nullable_to_non_nullable
as BodyPosition,equatorial: null == equatorial ? _self.equatorial : equatorial // ignore: cast_nullable_to_non_nullable
as BodyPosition,starData: freezed == starData ? _self.starData : starData // ignore: cast_nullable_to_non_nullable
as StarData?,
  ));
}

/// Create a copy of StarPosition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BodyPositionCopyWith<$Res> get ecliptic {
  
  return $BodyPositionCopyWith<$Res>(_self.ecliptic, (value) {
    return _then(_self.copyWith(ecliptic: value));
  });
}/// Create a copy of StarPosition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BodyPositionCopyWith<$Res> get equatorial {
  
  return $BodyPositionCopyWith<$Res>(_self.equatorial, (value) {
    return _then(_self.copyWith(equatorial: value));
  });
}/// Create a copy of StarPosition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StarDataCopyWith<$Res>? get starData {
    if (_self.starData == null) {
    return null;
  }

  return $StarDataCopyWith<$Res>(_self.starData!, (value) {
    return _then(_self.copyWith(starData: value));
  });
}
}

// dart format on
