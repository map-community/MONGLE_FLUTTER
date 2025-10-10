// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reply_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RepliesState {

/// 현재 로드된 대댓글 목록
 List<Comment> get replies;/// 다음 페이지를 로드하기 위한 커서
 String? get nextCursor;/// 더 불러올 대댓글이 있는지 여부
 bool get hasNext;/// '더보기' 로딩 중인지 여부
 bool get isLoadingMore;
/// Create a copy of RepliesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepliesStateCopyWith<RepliesState> get copyWith => _$RepliesStateCopyWithImpl<RepliesState>(this as RepliesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepliesState&&const DeepCollectionEquality().equals(other.replies, replies)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(replies),nextCursor,hasNext,isLoadingMore);

@override
String toString() {
  return 'RepliesState(replies: $replies, nextCursor: $nextCursor, hasNext: $hasNext, isLoadingMore: $isLoadingMore)';
}


}

/// @nodoc
abstract mixin class $RepliesStateCopyWith<$Res>  {
  factory $RepliesStateCopyWith(RepliesState value, $Res Function(RepliesState) _then) = _$RepliesStateCopyWithImpl;
@useResult
$Res call({
 List<Comment> replies, String? nextCursor, bool hasNext, bool isLoadingMore
});




}
/// @nodoc
class _$RepliesStateCopyWithImpl<$Res>
    implements $RepliesStateCopyWith<$Res> {
  _$RepliesStateCopyWithImpl(this._self, this._then);

  final RepliesState _self;
  final $Res Function(RepliesState) _then;

/// Create a copy of RepliesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? replies = null,Object? nextCursor = freezed,Object? hasNext = null,Object? isLoadingMore = null,}) {
  return _then(_self.copyWith(
replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as List<Comment>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RepliesState].
extension RepliesStatePatterns on RepliesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepliesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepliesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepliesState value)  $default,){
final _that = this;
switch (_that) {
case _RepliesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepliesState value)?  $default,){
final _that = this;
switch (_that) {
case _RepliesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Comment> replies,  String? nextCursor,  bool hasNext,  bool isLoadingMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepliesState() when $default != null:
return $default(_that.replies,_that.nextCursor,_that.hasNext,_that.isLoadingMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Comment> replies,  String? nextCursor,  bool hasNext,  bool isLoadingMore)  $default,) {final _that = this;
switch (_that) {
case _RepliesState():
return $default(_that.replies,_that.nextCursor,_that.hasNext,_that.isLoadingMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Comment> replies,  String? nextCursor,  bool hasNext,  bool isLoadingMore)?  $default,) {final _that = this;
switch (_that) {
case _RepliesState() when $default != null:
return $default(_that.replies,_that.nextCursor,_that.hasNext,_that.isLoadingMore);case _:
  return null;

}
}

}

/// @nodoc


class _RepliesState implements RepliesState {
  const _RepliesState({final  List<Comment> replies = const [], this.nextCursor, this.hasNext = true, this.isLoadingMore = false}): _replies = replies;
  

/// 현재 로드된 대댓글 목록
 final  List<Comment> _replies;
/// 현재 로드된 대댓글 목록
@override@JsonKey() List<Comment> get replies {
  if (_replies is EqualUnmodifiableListView) return _replies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_replies);
}

/// 다음 페이지를 로드하기 위한 커서
@override final  String? nextCursor;
/// 더 불러올 대댓글이 있는지 여부
@override@JsonKey() final  bool hasNext;
/// '더보기' 로딩 중인지 여부
@override@JsonKey() final  bool isLoadingMore;

/// Create a copy of RepliesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepliesStateCopyWith<_RepliesState> get copyWith => __$RepliesStateCopyWithImpl<_RepliesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepliesState&&const DeepCollectionEquality().equals(other._replies, _replies)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_replies),nextCursor,hasNext,isLoadingMore);

@override
String toString() {
  return 'RepliesState(replies: $replies, nextCursor: $nextCursor, hasNext: $hasNext, isLoadingMore: $isLoadingMore)';
}


}

/// @nodoc
abstract mixin class _$RepliesStateCopyWith<$Res> implements $RepliesStateCopyWith<$Res> {
  factory _$RepliesStateCopyWith(_RepliesState value, $Res Function(_RepliesState) _then) = __$RepliesStateCopyWithImpl;
@override @useResult
$Res call({
 List<Comment> replies, String? nextCursor, bool hasNext, bool isLoadingMore
});




}
/// @nodoc
class __$RepliesStateCopyWithImpl<$Res>
    implements _$RepliesStateCopyWith<$Res> {
  __$RepliesStateCopyWithImpl(this._self, this._then);

  final _RepliesState _self;
  final $Res Function(_RepliesState) _then;

/// Create a copy of RepliesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? replies = null,Object? nextCursor = freezed,Object? hasNext = null,Object? isLoadingMore = null,}) {
  return _then(_RepliesState(
replies: null == replies ? _self._replies : replies // ignore: cast_nullable_to_non_nullable
as List<Comment>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
