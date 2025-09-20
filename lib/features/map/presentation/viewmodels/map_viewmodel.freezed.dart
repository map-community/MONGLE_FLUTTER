// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_viewmodel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MapState()';
}


}

/// @nodoc
class $MapStateCopyWith<$Res>  {
$MapStateCopyWith(MapState _, $Res Function(MapState) __);
}


/// Adds pattern-matching-related methods to [MapState].
extension MapStatePatterns on MapState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Loading value)?  loading,TResult Function( _Error value)?  error,TResult Function( _Data value)?  data,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Loading() when loading != null:
return loading(_that);case _Error() when error != null:
return error(_that);case _Data() when data != null:
return data(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Loading value)  loading,required TResult Function( _Error value)  error,required TResult Function( _Data value)  data,}){
final _that = this;
switch (_that) {
case _Loading():
return loading(_that);case _Error():
return error(_that);case _Data():
return data(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Loading value)?  loading,TResult? Function( _Error value)?  error,TResult? Function( _Data value)?  data,}){
final _that = this;
switch (_that) {
case _Loading() when loading != null:
return loading(_that);case _Error() when error != null:
return error(_that);case _Data() when data != null:
return data(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( String message)?  error,TResult Function( NLatLng initialPosition,  MapObjectsResponse? mapObjects)?  data,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Loading() when loading != null:
return loading();case _Error() when error != null:
return error(_that.message);case _Data() when data != null:
return data(_that.initialPosition,_that.mapObjects);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( String message)  error,required TResult Function( NLatLng initialPosition,  MapObjectsResponse? mapObjects)  data,}) {final _that = this;
switch (_that) {
case _Loading():
return loading();case _Error():
return error(_that.message);case _Data():
return data(_that.initialPosition,_that.mapObjects);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( String message)?  error,TResult? Function( NLatLng initialPosition,  MapObjectsResponse? mapObjects)?  data,}) {final _that = this;
switch (_that) {
case _Loading() when loading != null:
return loading();case _Error() when error != null:
return error(_that.message);case _Data() when data != null:
return data(_that.initialPosition,_that.mapObjects);case _:
  return null;

}
}

}

/// @nodoc


class _Loading implements MapState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MapState.loading()';
}


}




/// @nodoc


class _Error implements MapState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'MapState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $MapStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Data implements MapState {
  const _Data({required this.initialPosition, this.mapObjects});
  

// 지도의 초기 카메라 위치를 설정하기 위한 좌표
 final  NLatLng initialPosition;
// API로부터 받아온 지도 객체(알갱이, 구름) 데이터. 아직 로드 전일 수 있으므로 nullable.
 final  MapObjectsResponse? mapObjects;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DataCopyWith<_Data> get copyWith => __$DataCopyWithImpl<_Data>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Data&&(identical(other.initialPosition, initialPosition) || other.initialPosition == initialPosition)&&(identical(other.mapObjects, mapObjects) || other.mapObjects == mapObjects));
}


@override
int get hashCode => Object.hash(runtimeType,initialPosition,mapObjects);

@override
String toString() {
  return 'MapState.data(initialPosition: $initialPosition, mapObjects: $mapObjects)';
}


}

/// @nodoc
abstract mixin class _$DataCopyWith<$Res> implements $MapStateCopyWith<$Res> {
  factory _$DataCopyWith(_Data value, $Res Function(_Data) _then) = __$DataCopyWithImpl;
@useResult
$Res call({
 NLatLng initialPosition, MapObjectsResponse? mapObjects
});


$MapObjectsResponseCopyWith<$Res>? get mapObjects;

}
/// @nodoc
class __$DataCopyWithImpl<$Res>
    implements _$DataCopyWith<$Res> {
  __$DataCopyWithImpl(this._self, this._then);

  final _Data _self;
  final $Res Function(_Data) _then;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? initialPosition = null,Object? mapObjects = freezed,}) {
  return _then(_Data(
initialPosition: null == initialPosition ? _self.initialPosition : initialPosition // ignore: cast_nullable_to_non_nullable
as NLatLng,mapObjects: freezed == mapObjects ? _self.mapObjects : mapObjects // ignore: cast_nullable_to_non_nullable
as MapObjectsResponse?,
  ));
}

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MapObjectsResponseCopyWith<$Res>? get mapObjects {
    if (_self.mapObjects == null) {
    return null;
  }

  return $MapObjectsResponseCopyWith<$Res>(_self.mapObjects!, (value) {
    return _then(_self.copyWith(mapObjects: value));
  });
}
}

// dart format on
