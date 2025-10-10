// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reaction_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReactionResponse {

 int get likeCount; int get dislikeCount;
/// Create a copy of ReactionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReactionResponseCopyWith<ReactionResponse> get copyWith => _$ReactionResponseCopyWithImpl<ReactionResponse>(this as ReactionResponse, _$identity);

  /// Serializes this ReactionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReactionResponse&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.dislikeCount, dislikeCount) || other.dislikeCount == dislikeCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,likeCount,dislikeCount);

@override
String toString() {
  return 'ReactionResponse(likeCount: $likeCount, dislikeCount: $dislikeCount)';
}


}

/// @nodoc
abstract mixin class $ReactionResponseCopyWith<$Res>  {
  factory $ReactionResponseCopyWith(ReactionResponse value, $Res Function(ReactionResponse) _then) = _$ReactionResponseCopyWithImpl;
@useResult
$Res call({
 int likeCount, int dislikeCount
});




}
/// @nodoc
class _$ReactionResponseCopyWithImpl<$Res>
    implements $ReactionResponseCopyWith<$Res> {
  _$ReactionResponseCopyWithImpl(this._self, this._then);

  final ReactionResponse _self;
  final $Res Function(ReactionResponse) _then;

/// Create a copy of ReactionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? likeCount = null,Object? dislikeCount = null,}) {
  return _then(_self.copyWith(
likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,dislikeCount: null == dislikeCount ? _self.dislikeCount : dislikeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReactionResponse].
extension ReactionResponsePatterns on ReactionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReactionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReactionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReactionResponse value)  $default,){
final _that = this;
switch (_that) {
case _ReactionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReactionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ReactionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int likeCount,  int dislikeCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReactionResponse() when $default != null:
return $default(_that.likeCount,_that.dislikeCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int likeCount,  int dislikeCount)  $default,) {final _that = this;
switch (_that) {
case _ReactionResponse():
return $default(_that.likeCount,_that.dislikeCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int likeCount,  int dislikeCount)?  $default,) {final _that = this;
switch (_that) {
case _ReactionResponse() when $default != null:
return $default(_that.likeCount,_that.dislikeCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReactionResponse implements ReactionResponse {
  const _ReactionResponse({required this.likeCount, required this.dislikeCount});
  factory _ReactionResponse.fromJson(Map<String, dynamic> json) => _$ReactionResponseFromJson(json);

@override final  int likeCount;
@override final  int dislikeCount;

/// Create a copy of ReactionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReactionResponseCopyWith<_ReactionResponse> get copyWith => __$ReactionResponseCopyWithImpl<_ReactionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReactionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReactionResponse&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.dislikeCount, dislikeCount) || other.dislikeCount == dislikeCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,likeCount,dislikeCount);

@override
String toString() {
  return 'ReactionResponse(likeCount: $likeCount, dislikeCount: $dislikeCount)';
}


}

/// @nodoc
abstract mixin class _$ReactionResponseCopyWith<$Res> implements $ReactionResponseCopyWith<$Res> {
  factory _$ReactionResponseCopyWith(_ReactionResponse value, $Res Function(_ReactionResponse) _then) = __$ReactionResponseCopyWithImpl;
@override @useResult
$Res call({
 int likeCount, int dislikeCount
});




}
/// @nodoc
class __$ReactionResponseCopyWithImpl<$Res>
    implements _$ReactionResponseCopyWith<$Res> {
  __$ReactionResponseCopyWithImpl(this._self, this._then);

  final _ReactionResponse _self;
  final $Res Function(_ReactionResponse) _then;

/// Create a copy of ReactionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? likeCount = null,Object? dislikeCount = null,}) {
  return _then(_ReactionResponse(
likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,dislikeCount: null == dislikeCount ? _self.dislikeCount : dislikeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ReactionState {

 int get likeCount; int get dislikeCount; ReactionType? get myReaction; bool get isUpdating;
/// Create a copy of ReactionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReactionStateCopyWith<ReactionState> get copyWith => _$ReactionStateCopyWithImpl<ReactionState>(this as ReactionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReactionState&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.dislikeCount, dislikeCount) || other.dislikeCount == dislikeCount)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating));
}


@override
int get hashCode => Object.hash(runtimeType,likeCount,dislikeCount,myReaction,isUpdating);

@override
String toString() {
  return 'ReactionState(likeCount: $likeCount, dislikeCount: $dislikeCount, myReaction: $myReaction, isUpdating: $isUpdating)';
}


}

/// @nodoc
abstract mixin class $ReactionStateCopyWith<$Res>  {
  factory $ReactionStateCopyWith(ReactionState value, $Res Function(ReactionState) _then) = _$ReactionStateCopyWithImpl;
@useResult
$Res call({
 int likeCount, int dislikeCount, ReactionType? myReaction, bool isUpdating
});




}
/// @nodoc
class _$ReactionStateCopyWithImpl<$Res>
    implements $ReactionStateCopyWith<$Res> {
  _$ReactionStateCopyWithImpl(this._self, this._then);

  final ReactionState _self;
  final $Res Function(ReactionState) _then;

/// Create a copy of ReactionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? likeCount = null,Object? dislikeCount = null,Object? myReaction = freezed,Object? isUpdating = null,}) {
  return _then(_self.copyWith(
likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,dislikeCount: null == dislikeCount ? _self.dislikeCount : dislikeCount // ignore: cast_nullable_to_non_nullable
as int,myReaction: freezed == myReaction ? _self.myReaction : myReaction // ignore: cast_nullable_to_non_nullable
as ReactionType?,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReactionState].
extension ReactionStatePatterns on ReactionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReactionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReactionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReactionState value)  $default,){
final _that = this;
switch (_that) {
case _ReactionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReactionState value)?  $default,){
final _that = this;
switch (_that) {
case _ReactionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int likeCount,  int dislikeCount,  ReactionType? myReaction,  bool isUpdating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReactionState() when $default != null:
return $default(_that.likeCount,_that.dislikeCount,_that.myReaction,_that.isUpdating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int likeCount,  int dislikeCount,  ReactionType? myReaction,  bool isUpdating)  $default,) {final _that = this;
switch (_that) {
case _ReactionState():
return $default(_that.likeCount,_that.dislikeCount,_that.myReaction,_that.isUpdating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int likeCount,  int dislikeCount,  ReactionType? myReaction,  bool isUpdating)?  $default,) {final _that = this;
switch (_that) {
case _ReactionState() when $default != null:
return $default(_that.likeCount,_that.dislikeCount,_that.myReaction,_that.isUpdating);case _:
  return null;

}
}

}

/// @nodoc


class _ReactionState implements ReactionState {
  const _ReactionState({required this.likeCount, required this.dislikeCount, this.myReaction, this.isUpdating = false});
  

@override final  int likeCount;
@override final  int dislikeCount;
@override final  ReactionType? myReaction;
@override@JsonKey() final  bool isUpdating;

/// Create a copy of ReactionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReactionStateCopyWith<_ReactionState> get copyWith => __$ReactionStateCopyWithImpl<_ReactionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReactionState&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.dislikeCount, dislikeCount) || other.dislikeCount == dislikeCount)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating));
}


@override
int get hashCode => Object.hash(runtimeType,likeCount,dislikeCount,myReaction,isUpdating);

@override
String toString() {
  return 'ReactionState(likeCount: $likeCount, dislikeCount: $dislikeCount, myReaction: $myReaction, isUpdating: $isUpdating)';
}


}

/// @nodoc
abstract mixin class _$ReactionStateCopyWith<$Res> implements $ReactionStateCopyWith<$Res> {
  factory _$ReactionStateCopyWith(_ReactionState value, $Res Function(_ReactionState) _then) = __$ReactionStateCopyWithImpl;
@override @useResult
$Res call({
 int likeCount, int dislikeCount, ReactionType? myReaction, bool isUpdating
});




}
/// @nodoc
class __$ReactionStateCopyWithImpl<$Res>
    implements _$ReactionStateCopyWith<$Res> {
  __$ReactionStateCopyWithImpl(this._self, this._then);

  final _ReactionState _self;
  final $Res Function(_ReactionState) _then;

/// Create a copy of ReactionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? likeCount = null,Object? dislikeCount = null,Object? myReaction = freezed,Object? isUpdating = null,}) {
  return _then(_ReactionState(
likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,dislikeCount: null == dislikeCount ? _self.dislikeCount : dislikeCount // ignore: cast_nullable_to_non_nullable
as int,myReaction: freezed == myReaction ? _self.myReaction : myReaction // ignore: cast_nullable_to_non_nullable
as ReactionType?,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
