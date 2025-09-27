// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated_comments.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaginatedComments {

// ✨ 2. 'values' 키를 'comments' 필드에 매핑하라는 규칙을 알려줍니다.
@JsonKey(name: 'values') List<Comment> get comments; String? get nextCursor; bool get hasNext;// 현재 답글을 다는 대상 댓글 정보를 저장합니다. 백엔드에서 받는 정보가 아니라, 앱 내에서 상태로 관리하는 용도입니다.
 Comment? get replyingTo;// 댓글/대댓글 전송이 진행 중인지 여부를 나타내는 UI 상태
 bool get isSubmitting;
/// Create a copy of PaginatedComments
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedCommentsCopyWith<PaginatedComments> get copyWith => _$PaginatedCommentsCopyWithImpl<PaginatedComments>(this as PaginatedComments, _$identity);

  /// Serializes this PaginatedComments to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedComments&&const DeepCollectionEquality().equals(other.comments, comments)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext)&&(identical(other.replyingTo, replyingTo) || other.replyingTo == replyingTo)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(comments),nextCursor,hasNext,replyingTo,isSubmitting);

@override
String toString() {
  return 'PaginatedComments(comments: $comments, nextCursor: $nextCursor, hasNext: $hasNext, replyingTo: $replyingTo, isSubmitting: $isSubmitting)';
}


}

/// @nodoc
abstract mixin class $PaginatedCommentsCopyWith<$Res>  {
  factory $PaginatedCommentsCopyWith(PaginatedComments value, $Res Function(PaginatedComments) _then) = _$PaginatedCommentsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'values') List<Comment> comments, String? nextCursor, bool hasNext, Comment? replyingTo, bool isSubmitting
});


$CommentCopyWith<$Res>? get replyingTo;

}
/// @nodoc
class _$PaginatedCommentsCopyWithImpl<$Res>
    implements $PaginatedCommentsCopyWith<$Res> {
  _$PaginatedCommentsCopyWithImpl(this._self, this._then);

  final PaginatedComments _self;
  final $Res Function(PaginatedComments) _then;

/// Create a copy of PaginatedComments
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? comments = null,Object? nextCursor = freezed,Object? hasNext = null,Object? replyingTo = freezed,Object? isSubmitting = null,}) {
  return _then(_self.copyWith(
comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<Comment>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,replyingTo: freezed == replyingTo ? _self.replyingTo : replyingTo // ignore: cast_nullable_to_non_nullable
as Comment?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PaginatedComments
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentCopyWith<$Res>? get replyingTo {
    if (_self.replyingTo == null) {
    return null;
  }

  return $CommentCopyWith<$Res>(_self.replyingTo!, (value) {
    return _then(_self.copyWith(replyingTo: value));
  });
}
}


/// Adds pattern-matching-related methods to [PaginatedComments].
extension PaginatedCommentsPatterns on PaginatedComments {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedComments value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedComments() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedComments value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedComments():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedComments value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedComments() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'values')  List<Comment> comments,  String? nextCursor,  bool hasNext,  Comment? replyingTo,  bool isSubmitting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedComments() when $default != null:
return $default(_that.comments,_that.nextCursor,_that.hasNext,_that.replyingTo,_that.isSubmitting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'values')  List<Comment> comments,  String? nextCursor,  bool hasNext,  Comment? replyingTo,  bool isSubmitting)  $default,) {final _that = this;
switch (_that) {
case _PaginatedComments():
return $default(_that.comments,_that.nextCursor,_that.hasNext,_that.replyingTo,_that.isSubmitting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'values')  List<Comment> comments,  String? nextCursor,  bool hasNext,  Comment? replyingTo,  bool isSubmitting)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedComments() when $default != null:
return $default(_that.comments,_that.nextCursor,_that.hasNext,_that.replyingTo,_that.isSubmitting);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedComments implements PaginatedComments {
  const _PaginatedComments({@JsonKey(name: 'values') final  List<Comment> comments = const [], this.nextCursor, this.hasNext = true, this.replyingTo, this.isSubmitting = false}): _comments = comments;
  factory _PaginatedComments.fromJson(Map<String, dynamic> json) => _$PaginatedCommentsFromJson(json);

// ✨ 2. 'values' 키를 'comments' 필드에 매핑하라는 규칙을 알려줍니다.
 final  List<Comment> _comments;
// ✨ 2. 'values' 키를 'comments' 필드에 매핑하라는 규칙을 알려줍니다.
@override@JsonKey(name: 'values') List<Comment> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

@override final  String? nextCursor;
@override@JsonKey() final  bool hasNext;
// 현재 답글을 다는 대상 댓글 정보를 저장합니다. 백엔드에서 받는 정보가 아니라, 앱 내에서 상태로 관리하는 용도입니다.
@override final  Comment? replyingTo;
// 댓글/대댓글 전송이 진행 중인지 여부를 나타내는 UI 상태
@override@JsonKey() final  bool isSubmitting;

/// Create a copy of PaginatedComments
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedCommentsCopyWith<_PaginatedComments> get copyWith => __$PaginatedCommentsCopyWithImpl<_PaginatedComments>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedCommentsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedComments&&const DeepCollectionEquality().equals(other._comments, _comments)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext)&&(identical(other.replyingTo, replyingTo) || other.replyingTo == replyingTo)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_comments),nextCursor,hasNext,replyingTo,isSubmitting);

@override
String toString() {
  return 'PaginatedComments(comments: $comments, nextCursor: $nextCursor, hasNext: $hasNext, replyingTo: $replyingTo, isSubmitting: $isSubmitting)';
}


}

/// @nodoc
abstract mixin class _$PaginatedCommentsCopyWith<$Res> implements $PaginatedCommentsCopyWith<$Res> {
  factory _$PaginatedCommentsCopyWith(_PaginatedComments value, $Res Function(_PaginatedComments) _then) = __$PaginatedCommentsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'values') List<Comment> comments, String? nextCursor, bool hasNext, Comment? replyingTo, bool isSubmitting
});


@override $CommentCopyWith<$Res>? get replyingTo;

}
/// @nodoc
class __$PaginatedCommentsCopyWithImpl<$Res>
    implements _$PaginatedCommentsCopyWith<$Res> {
  __$PaginatedCommentsCopyWithImpl(this._self, this._then);

  final _PaginatedComments _self;
  final $Res Function(_PaginatedComments) _then;

/// Create a copy of PaginatedComments
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? comments = null,Object? nextCursor = freezed,Object? hasNext = null,Object? replyingTo = freezed,Object? isSubmitting = null,}) {
  return _then(_PaginatedComments(
comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<Comment>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,replyingTo: freezed == replyingTo ? _self.replyingTo : replyingTo // ignore: cast_nullable_to_non_nullable
as Comment?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PaginatedComments
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentCopyWith<$Res>? get replyingTo {
    if (_self.replyingTo == null) {
    return null;
  }

  return $CommentCopyWith<$Res>(_self.replyingTo!, (value) {
    return _then(_self.copyWith(replyingTo: value));
  });
}
}

// dart format on
