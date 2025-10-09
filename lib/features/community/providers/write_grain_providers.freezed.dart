// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'write_grain_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WriteGrainState {

 bool get isSubmitting; String? get errorMessage; List<AssetEntity> get photos; List<AssetEntity> get videos; LocationPermissionDenialType? get permissionDenialType;
/// Create a copy of WriteGrainState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WriteGrainStateCopyWith<WriteGrainState> get copyWith => _$WriteGrainStateCopyWithImpl<WriteGrainState>(this as WriteGrainState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WriteGrainState&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.photos, photos)&&const DeepCollectionEquality().equals(other.videos, videos)&&(identical(other.permissionDenialType, permissionDenialType) || other.permissionDenialType == permissionDenialType));
}


@override
int get hashCode => Object.hash(runtimeType,isSubmitting,errorMessage,const DeepCollectionEquality().hash(photos),const DeepCollectionEquality().hash(videos),permissionDenialType);

@override
String toString() {
  return 'WriteGrainState(isSubmitting: $isSubmitting, errorMessage: $errorMessage, photos: $photos, videos: $videos, permissionDenialType: $permissionDenialType)';
}


}

/// @nodoc
abstract mixin class $WriteGrainStateCopyWith<$Res>  {
  factory $WriteGrainStateCopyWith(WriteGrainState value, $Res Function(WriteGrainState) _then) = _$WriteGrainStateCopyWithImpl;
@useResult
$Res call({
 bool isSubmitting, String? errorMessage, List<AssetEntity> photos, List<AssetEntity> videos, LocationPermissionDenialType? permissionDenialType
});




}
/// @nodoc
class _$WriteGrainStateCopyWithImpl<$Res>
    implements $WriteGrainStateCopyWith<$Res> {
  _$WriteGrainStateCopyWithImpl(this._self, this._then);

  final WriteGrainState _self;
  final $Res Function(WriteGrainState) _then;

/// Create a copy of WriteGrainState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSubmitting = null,Object? errorMessage = freezed,Object? photos = null,Object? videos = null,Object? permissionDenialType = freezed,}) {
  return _then(_self.copyWith(
isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<AssetEntity>,videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<AssetEntity>,permissionDenialType: freezed == permissionDenialType ? _self.permissionDenialType : permissionDenialType // ignore: cast_nullable_to_non_nullable
as LocationPermissionDenialType?,
  ));
}

}


/// Adds pattern-matching-related methods to [WriteGrainState].
extension WriteGrainStatePatterns on WriteGrainState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WriteGrainState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WriteGrainState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WriteGrainState value)  $default,){
final _that = this;
switch (_that) {
case _WriteGrainState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WriteGrainState value)?  $default,){
final _that = this;
switch (_that) {
case _WriteGrainState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSubmitting,  String? errorMessage,  List<AssetEntity> photos,  List<AssetEntity> videos,  LocationPermissionDenialType? permissionDenialType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WriteGrainState() when $default != null:
return $default(_that.isSubmitting,_that.errorMessage,_that.photos,_that.videos,_that.permissionDenialType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSubmitting,  String? errorMessage,  List<AssetEntity> photos,  List<AssetEntity> videos,  LocationPermissionDenialType? permissionDenialType)  $default,) {final _that = this;
switch (_that) {
case _WriteGrainState():
return $default(_that.isSubmitting,_that.errorMessage,_that.photos,_that.videos,_that.permissionDenialType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSubmitting,  String? errorMessage,  List<AssetEntity> photos,  List<AssetEntity> videos,  LocationPermissionDenialType? permissionDenialType)?  $default,) {final _that = this;
switch (_that) {
case _WriteGrainState() when $default != null:
return $default(_that.isSubmitting,_that.errorMessage,_that.photos,_that.videos,_that.permissionDenialType);case _:
  return null;

}
}

}

/// @nodoc


class _WriteGrainState implements WriteGrainState {
  const _WriteGrainState({this.isSubmitting = false, this.errorMessage, final  List<AssetEntity> photos = const [], final  List<AssetEntity> videos = const [], this.permissionDenialType}): _photos = photos,_videos = videos;
  

@override@JsonKey() final  bool isSubmitting;
@override final  String? errorMessage;
 final  List<AssetEntity> _photos;
@override@JsonKey() List<AssetEntity> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

 final  List<AssetEntity> _videos;
@override@JsonKey() List<AssetEntity> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

@override final  LocationPermissionDenialType? permissionDenialType;

/// Create a copy of WriteGrainState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WriteGrainStateCopyWith<_WriteGrainState> get copyWith => __$WriteGrainStateCopyWithImpl<_WriteGrainState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WriteGrainState&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._photos, _photos)&&const DeepCollectionEquality().equals(other._videos, _videos)&&(identical(other.permissionDenialType, permissionDenialType) || other.permissionDenialType == permissionDenialType));
}


@override
int get hashCode => Object.hash(runtimeType,isSubmitting,errorMessage,const DeepCollectionEquality().hash(_photos),const DeepCollectionEquality().hash(_videos),permissionDenialType);

@override
String toString() {
  return 'WriteGrainState(isSubmitting: $isSubmitting, errorMessage: $errorMessage, photos: $photos, videos: $videos, permissionDenialType: $permissionDenialType)';
}


}

/// @nodoc
abstract mixin class _$WriteGrainStateCopyWith<$Res> implements $WriteGrainStateCopyWith<$Res> {
  factory _$WriteGrainStateCopyWith(_WriteGrainState value, $Res Function(_WriteGrainState) _then) = __$WriteGrainStateCopyWithImpl;
@override @useResult
$Res call({
 bool isSubmitting, String? errorMessage, List<AssetEntity> photos, List<AssetEntity> videos, LocationPermissionDenialType? permissionDenialType
});




}
/// @nodoc
class __$WriteGrainStateCopyWithImpl<$Res>
    implements _$WriteGrainStateCopyWith<$Res> {
  __$WriteGrainStateCopyWithImpl(this._self, this._then);

  final _WriteGrainState _self;
  final $Res Function(_WriteGrainState) _then;

/// Create a copy of WriteGrainState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSubmitting = null,Object? errorMessage = freezed,Object? photos = null,Object? videos = null,Object? permissionDenialType = freezed,}) {
  return _then(_WriteGrainState(
isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<AssetEntity>,videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<AssetEntity>,permissionDenialType: freezed == permissionDenialType ? _self.permissionDenialType : permissionDenialType // ignore: cast_nullable_to_non_nullable
as LocationPermissionDenialType?,
  ));
}


}

// dart format on
