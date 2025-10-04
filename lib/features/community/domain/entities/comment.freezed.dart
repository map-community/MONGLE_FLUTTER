// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Comment {

@JsonKey(readValue: _readCommentId) String get commentId; String get content; Author get author; int get likeCount; int get dislikeCount; DateTime get createdAt; DateTime? get updatedAt; bool get isAuthor; bool get isDeleted; bool get hasReplies; List<Comment> get replies;
/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentCopyWith<Comment> get copyWith => _$CommentCopyWithImpl<Comment>(this as Comment, _$identity);

  /// Serializes this Comment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Comment&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.content, content) || other.content == content)&&(identical(other.author, author) || other.author == author)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.dislikeCount, dislikeCount) || other.dislikeCount == dislikeCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isAuthor, isAuthor) || other.isAuthor == isAuthor)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.hasReplies, hasReplies) || other.hasReplies == hasReplies)&&const DeepCollectionEquality().equals(other.replies, replies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,commentId,content,author,likeCount,dislikeCount,createdAt,updatedAt,isAuthor,isDeleted,hasReplies,const DeepCollectionEquality().hash(replies));

@override
String toString() {
  return 'Comment(commentId: $commentId, content: $content, author: $author, likeCount: $likeCount, dislikeCount: $dislikeCount, createdAt: $createdAt, updatedAt: $updatedAt, isAuthor: $isAuthor, isDeleted: $isDeleted, hasReplies: $hasReplies, replies: $replies)';
}


}

/// @nodoc
abstract mixin class $CommentCopyWith<$Res>  {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) _then) = _$CommentCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readCommentId) String commentId, String content, Author author, int likeCount, int dislikeCount, DateTime createdAt, DateTime? updatedAt, bool isAuthor, bool isDeleted, bool hasReplies, List<Comment> replies
});


$AuthorCopyWith<$Res> get author;

}
/// @nodoc
class _$CommentCopyWithImpl<$Res>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._self, this._then);

  final Comment _self;
  final $Res Function(Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commentId = null,Object? content = null,Object? author = null,Object? likeCount = null,Object? dislikeCount = null,Object? createdAt = null,Object? updatedAt = freezed,Object? isAuthor = null,Object? isDeleted = null,Object? hasReplies = null,Object? replies = null,}) {
  return _then(_self.copyWith(
commentId: null == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,dislikeCount: null == dislikeCount ? _self.dislikeCount : dislikeCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isAuthor: null == isAuthor ? _self.isAuthor : isAuthor // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,hasReplies: null == hasReplies ? _self.hasReplies : hasReplies // ignore: cast_nullable_to_non_nullable
as bool,replies: null == replies ? _self.replies : replies // ignore: cast_nullable_to_non_nullable
as List<Comment>,
  ));
}
/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get author {
  
  return $AuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}


/// Adds pattern-matching-related methods to [Comment].
extension CommentPatterns on Comment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Comment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Comment value)  $default,){
final _that = this;
switch (_that) {
case _Comment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Comment value)?  $default,){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readCommentId)  String commentId,  String content,  Author author,  int likeCount,  int dislikeCount,  DateTime createdAt,  DateTime? updatedAt,  bool isAuthor,  bool isDeleted,  bool hasReplies,  List<Comment> replies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.commentId,_that.content,_that.author,_that.likeCount,_that.dislikeCount,_that.createdAt,_that.updatedAt,_that.isAuthor,_that.isDeleted,_that.hasReplies,_that.replies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readCommentId)  String commentId,  String content,  Author author,  int likeCount,  int dislikeCount,  DateTime createdAt,  DateTime? updatedAt,  bool isAuthor,  bool isDeleted,  bool hasReplies,  List<Comment> replies)  $default,) {final _that = this;
switch (_that) {
case _Comment():
return $default(_that.commentId,_that.content,_that.author,_that.likeCount,_that.dislikeCount,_that.createdAt,_that.updatedAt,_that.isAuthor,_that.isDeleted,_that.hasReplies,_that.replies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readCommentId)  String commentId,  String content,  Author author,  int likeCount,  int dislikeCount,  DateTime createdAt,  DateTime? updatedAt,  bool isAuthor,  bool isDeleted,  bool hasReplies,  List<Comment> replies)?  $default,) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.commentId,_that.content,_that.author,_that.likeCount,_that.dislikeCount,_that.createdAt,_that.updatedAt,_that.isAuthor,_that.isDeleted,_that.hasReplies,_that.replies);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Comment implements Comment {
  const _Comment({@JsonKey(readValue: _readCommentId) required this.commentId, required this.content, required this.author, this.likeCount = 0, this.dislikeCount = 0, required this.createdAt, this.updatedAt, this.isAuthor = false, this.isDeleted = false, this.hasReplies = false, final  List<Comment> replies = const []}): _replies = replies;
  factory _Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

@override@JsonKey(readValue: _readCommentId) final  String commentId;
@override final  String content;
@override final  Author author;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int dislikeCount;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  bool isAuthor;
@override@JsonKey() final  bool isDeleted;
@override@JsonKey() final  bool hasReplies;
 final  List<Comment> _replies;
@override@JsonKey() List<Comment> get replies {
  if (_replies is EqualUnmodifiableListView) return _replies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_replies);
}


/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentCopyWith<_Comment> get copyWith => __$CommentCopyWithImpl<_Comment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Comment&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.content, content) || other.content == content)&&(identical(other.author, author) || other.author == author)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.dislikeCount, dislikeCount) || other.dislikeCount == dislikeCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isAuthor, isAuthor) || other.isAuthor == isAuthor)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.hasReplies, hasReplies) || other.hasReplies == hasReplies)&&const DeepCollectionEquality().equals(other._replies, _replies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,commentId,content,author,likeCount,dislikeCount,createdAt,updatedAt,isAuthor,isDeleted,hasReplies,const DeepCollectionEquality().hash(_replies));

@override
String toString() {
  return 'Comment(commentId: $commentId, content: $content, author: $author, likeCount: $likeCount, dislikeCount: $dislikeCount, createdAt: $createdAt, updatedAt: $updatedAt, isAuthor: $isAuthor, isDeleted: $isDeleted, hasReplies: $hasReplies, replies: $replies)';
}


}

/// @nodoc
abstract mixin class _$CommentCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$CommentCopyWith(_Comment value, $Res Function(_Comment) _then) = __$CommentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readCommentId) String commentId, String content, Author author, int likeCount, int dislikeCount, DateTime createdAt, DateTime? updatedAt, bool isAuthor, bool isDeleted, bool hasReplies, List<Comment> replies
});


@override $AuthorCopyWith<$Res> get author;

}
/// @nodoc
class __$CommentCopyWithImpl<$Res>
    implements _$CommentCopyWith<$Res> {
  __$CommentCopyWithImpl(this._self, this._then);

  final _Comment _self;
  final $Res Function(_Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commentId = null,Object? content = null,Object? author = null,Object? likeCount = null,Object? dislikeCount = null,Object? createdAt = null,Object? updatedAt = freezed,Object? isAuthor = null,Object? isDeleted = null,Object? hasReplies = null,Object? replies = null,}) {
  return _then(_Comment(
commentId: null == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,dislikeCount: null == dislikeCount ? _self.dislikeCount : dislikeCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isAuthor: null == isAuthor ? _self.isAuthor : isAuthor // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,hasReplies: null == hasReplies ? _self.hasReplies : hasReplies // ignore: cast_nullable_to_non_nullable
as bool,replies: null == replies ? _self._replies : replies // ignore: cast_nullable_to_non_nullable
as List<Comment>,
  ));
}

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get author {
  
  return $AuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}

// dart format on
