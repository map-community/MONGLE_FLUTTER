// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue_grain.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IssueGrain {

 String get id; Author get author;// 작성자 정보 (User 모델과 결합)
 String get content; List<String> get photoUrls;// 이미지 URL 목록
 DateTime get createdAt; int get viewCount; int get likeCount; int get dislikeCount; int get commentCount;
/// Create a copy of IssueGrain
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueGrainCopyWith<IssueGrain> get copyWith => _$IssueGrainCopyWithImpl<IssueGrain>(this as IssueGrain, _$identity);

  /// Serializes this IssueGrain to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueGrain&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.photoUrls, photoUrls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.dislikeCount, dislikeCount) || other.dislikeCount == dislikeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,content,const DeepCollectionEquality().hash(photoUrls),createdAt,viewCount,likeCount,dislikeCount,commentCount);

@override
String toString() {
  return 'IssueGrain(id: $id, author: $author, content: $content, photoUrls: $photoUrls, createdAt: $createdAt, viewCount: $viewCount, likeCount: $likeCount, dislikeCount: $dislikeCount, commentCount: $commentCount)';
}


}

/// @nodoc
abstract mixin class $IssueGrainCopyWith<$Res>  {
  factory $IssueGrainCopyWith(IssueGrain value, $Res Function(IssueGrain) _then) = _$IssueGrainCopyWithImpl;
@useResult
$Res call({
 String id, Author author, String content, List<String> photoUrls, DateTime createdAt, int viewCount, int likeCount, int dislikeCount, int commentCount
});


$AuthorCopyWith<$Res> get author;

}
/// @nodoc
class _$IssueGrainCopyWithImpl<$Res>
    implements $IssueGrainCopyWith<$Res> {
  _$IssueGrainCopyWithImpl(this._self, this._then);

  final IssueGrain _self;
  final $Res Function(IssueGrain) _then;

/// Create a copy of IssueGrain
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? author = null,Object? content = null,Object? photoUrls = null,Object? createdAt = null,Object? viewCount = null,Object? likeCount = null,Object? dislikeCount = null,Object? commentCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,photoUrls: null == photoUrls ? _self.photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,dislikeCount: null == dislikeCount ? _self.dislikeCount : dislikeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of IssueGrain
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get author {
  
  return $AuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}


/// Adds pattern-matching-related methods to [IssueGrain].
extension IssueGrainPatterns on IssueGrain {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueGrain value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueGrain() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueGrain value)  $default,){
final _that = this;
switch (_that) {
case _IssueGrain():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueGrain value)?  $default,){
final _that = this;
switch (_that) {
case _IssueGrain() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Author author,  String content,  List<String> photoUrls,  DateTime createdAt,  int viewCount,  int likeCount,  int dislikeCount,  int commentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueGrain() when $default != null:
return $default(_that.id,_that.author,_that.content,_that.photoUrls,_that.createdAt,_that.viewCount,_that.likeCount,_that.dislikeCount,_that.commentCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Author author,  String content,  List<String> photoUrls,  DateTime createdAt,  int viewCount,  int likeCount,  int dislikeCount,  int commentCount)  $default,) {final _that = this;
switch (_that) {
case _IssueGrain():
return $default(_that.id,_that.author,_that.content,_that.photoUrls,_that.createdAt,_that.viewCount,_that.likeCount,_that.dislikeCount,_that.commentCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Author author,  String content,  List<String> photoUrls,  DateTime createdAt,  int viewCount,  int likeCount,  int dislikeCount,  int commentCount)?  $default,) {final _that = this;
switch (_that) {
case _IssueGrain() when $default != null:
return $default(_that.id,_that.author,_that.content,_that.photoUrls,_that.createdAt,_that.viewCount,_that.likeCount,_that.dislikeCount,_that.commentCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueGrain implements IssueGrain {
  const _IssueGrain({required this.id, required this.author, required this.content, final  List<String> photoUrls = const [], required this.createdAt, required this.viewCount, required this.likeCount, required this.dislikeCount, required this.commentCount}): _photoUrls = photoUrls;
  factory _IssueGrain.fromJson(Map<String, dynamic> json) => _$IssueGrainFromJson(json);

@override final  String id;
@override final  Author author;
// 작성자 정보 (User 모델과 결합)
@override final  String content;
 final  List<String> _photoUrls;
@override@JsonKey() List<String> get photoUrls {
  if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoUrls);
}

// 이미지 URL 목록
@override final  DateTime createdAt;
@override final  int viewCount;
@override final  int likeCount;
@override final  int dislikeCount;
@override final  int commentCount;

/// Create a copy of IssueGrain
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueGrainCopyWith<_IssueGrain> get copyWith => __$IssueGrainCopyWithImpl<_IssueGrain>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueGrainToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueGrain&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._photoUrls, _photoUrls)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.dislikeCount, dislikeCount) || other.dislikeCount == dislikeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,content,const DeepCollectionEquality().hash(_photoUrls),createdAt,viewCount,likeCount,dislikeCount,commentCount);

@override
String toString() {
  return 'IssueGrain(id: $id, author: $author, content: $content, photoUrls: $photoUrls, createdAt: $createdAt, viewCount: $viewCount, likeCount: $likeCount, dislikeCount: $dislikeCount, commentCount: $commentCount)';
}


}

/// @nodoc
abstract mixin class _$IssueGrainCopyWith<$Res> implements $IssueGrainCopyWith<$Res> {
  factory _$IssueGrainCopyWith(_IssueGrain value, $Res Function(_IssueGrain) _then) = __$IssueGrainCopyWithImpl;
@override @useResult
$Res call({
 String id, Author author, String content, List<String> photoUrls, DateTime createdAt, int viewCount, int likeCount, int dislikeCount, int commentCount
});


@override $AuthorCopyWith<$Res> get author;

}
/// @nodoc
class __$IssueGrainCopyWithImpl<$Res>
    implements _$IssueGrainCopyWith<$Res> {
  __$IssueGrainCopyWithImpl(this._self, this._then);

  final _IssueGrain _self;
  final $Res Function(_IssueGrain) _then;

/// Create a copy of IssueGrain
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? author = null,Object? content = null,Object? photoUrls = null,Object? createdAt = null,Object? viewCount = null,Object? likeCount = null,Object? dislikeCount = null,Object? commentCount = null,}) {
  return _then(_IssueGrain(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,photoUrls: null == photoUrls ? _self._photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,dislikeCount: null == dislikeCount ? _self.dislikeCount : dislikeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of IssueGrain
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
