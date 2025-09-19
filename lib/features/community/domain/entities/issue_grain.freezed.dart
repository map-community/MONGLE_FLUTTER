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

@JsonKey(name: 'post_id') String get postId; Author get author;// 작성자 정보 (User 모델과 결합)
 String get content; double get latitude; double get longitude; List<String> get photoUrls;// 이미지 URL 목록
@JsonKey(name: 'like_count') int get likeCount;@JsonKey(name: 'dislike_count') int get dislikeCount;@JsonKey(name: 'comment_count') int get commentCount;@JsonKey(name: 'view_count') int get viewCount;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of IssueGrain
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueGrainCopyWith<IssueGrain> get copyWith => _$IssueGrainCopyWithImpl<IssueGrain>(this as IssueGrain, _$identity);

  /// Serializes this IssueGrain to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueGrain&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.photoUrls, photoUrls)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.dislikeCount, dislikeCount) || other.dislikeCount == dislikeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,author,content,latitude,longitude,const DeepCollectionEquality().hash(photoUrls),likeCount,dislikeCount,commentCount,viewCount,createdAt);

@override
String toString() {
  return 'IssueGrain(postId: $postId, author: $author, content: $content, latitude: $latitude, longitude: $longitude, photoUrls: $photoUrls, likeCount: $likeCount, dislikeCount: $dislikeCount, commentCount: $commentCount, viewCount: $viewCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $IssueGrainCopyWith<$Res>  {
  factory $IssueGrainCopyWith(IssueGrain value, $Res Function(IssueGrain) _then) = _$IssueGrainCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'post_id') String postId, Author author, String content, double latitude, double longitude, List<String> photoUrls,@JsonKey(name: 'like_count') int likeCount,@JsonKey(name: 'dislike_count') int dislikeCount,@JsonKey(name: 'comment_count') int commentCount,@JsonKey(name: 'view_count') int viewCount,@JsonKey(name: 'created_at') DateTime createdAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,Object? author = null,Object? content = null,Object? latitude = null,Object? longitude = null,Object? photoUrls = null,Object? likeCount = null,Object? dislikeCount = null,Object? commentCount = null,Object? viewCount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,photoUrls: null == photoUrls ? _self.photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,dislikeCount: null == dislikeCount ? _self.dislikeCount : dislikeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'post_id')  String postId,  Author author,  String content,  double latitude,  double longitude,  List<String> photoUrls, @JsonKey(name: 'like_count')  int likeCount, @JsonKey(name: 'dislike_count')  int dislikeCount, @JsonKey(name: 'comment_count')  int commentCount, @JsonKey(name: 'view_count')  int viewCount, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueGrain() when $default != null:
return $default(_that.postId,_that.author,_that.content,_that.latitude,_that.longitude,_that.photoUrls,_that.likeCount,_that.dislikeCount,_that.commentCount,_that.viewCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'post_id')  String postId,  Author author,  String content,  double latitude,  double longitude,  List<String> photoUrls, @JsonKey(name: 'like_count')  int likeCount, @JsonKey(name: 'dislike_count')  int dislikeCount, @JsonKey(name: 'comment_count')  int commentCount, @JsonKey(name: 'view_count')  int viewCount, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _IssueGrain():
return $default(_that.postId,_that.author,_that.content,_that.latitude,_that.longitude,_that.photoUrls,_that.likeCount,_that.dislikeCount,_that.commentCount,_that.viewCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'post_id')  String postId,  Author author,  String content,  double latitude,  double longitude,  List<String> photoUrls, @JsonKey(name: 'like_count')  int likeCount, @JsonKey(name: 'dislike_count')  int dislikeCount, @JsonKey(name: 'comment_count')  int commentCount, @JsonKey(name: 'view_count')  int viewCount, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _IssueGrain() when $default != null:
return $default(_that.postId,_that.author,_that.content,_that.latitude,_that.longitude,_that.photoUrls,_that.likeCount,_that.dislikeCount,_that.commentCount,_that.viewCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueGrain implements IssueGrain {
  const _IssueGrain({@JsonKey(name: 'post_id') required this.postId, required this.author, required this.content, required this.latitude, required this.longitude, final  List<String> photoUrls = const [], @JsonKey(name: 'like_count') required this.likeCount, @JsonKey(name: 'dislike_count') required this.dislikeCount, @JsonKey(name: 'comment_count') required this.commentCount, @JsonKey(name: 'view_count') required this.viewCount, @JsonKey(name: 'created_at') required this.createdAt}): _photoUrls = photoUrls;
  factory _IssueGrain.fromJson(Map<String, dynamic> json) => _$IssueGrainFromJson(json);

@override@JsonKey(name: 'post_id') final  String postId;
@override final  Author author;
// 작성자 정보 (User 모델과 결합)
@override final  String content;
@override final  double latitude;
@override final  double longitude;
 final  List<String> _photoUrls;
@override@JsonKey() List<String> get photoUrls {
  if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoUrls);
}

// 이미지 URL 목록
@override@JsonKey(name: 'like_count') final  int likeCount;
@override@JsonKey(name: 'dislike_count') final  int dislikeCount;
@override@JsonKey(name: 'comment_count') final  int commentCount;
@override@JsonKey(name: 'view_count') final  int viewCount;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueGrain&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._photoUrls, _photoUrls)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.dislikeCount, dislikeCount) || other.dislikeCount == dislikeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,author,content,latitude,longitude,const DeepCollectionEquality().hash(_photoUrls),likeCount,dislikeCount,commentCount,viewCount,createdAt);

@override
String toString() {
  return 'IssueGrain(postId: $postId, author: $author, content: $content, latitude: $latitude, longitude: $longitude, photoUrls: $photoUrls, likeCount: $likeCount, dislikeCount: $dislikeCount, commentCount: $commentCount, viewCount: $viewCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$IssueGrainCopyWith<$Res> implements $IssueGrainCopyWith<$Res> {
  factory _$IssueGrainCopyWith(_IssueGrain value, $Res Function(_IssueGrain) _then) = __$IssueGrainCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'post_id') String postId, Author author, String content, double latitude, double longitude, List<String> photoUrls,@JsonKey(name: 'like_count') int likeCount,@JsonKey(name: 'dislike_count') int dislikeCount,@JsonKey(name: 'comment_count') int commentCount,@JsonKey(name: 'view_count') int viewCount,@JsonKey(name: 'created_at') DateTime createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? author = null,Object? content = null,Object? latitude = null,Object? longitude = null,Object? photoUrls = null,Object? likeCount = null,Object? dislikeCount = null,Object? commentCount = null,Object? viewCount = null,Object? createdAt = null,}) {
  return _then(_IssueGrain(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,photoUrls: null == photoUrls ? _self._photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,dislikeCount: null == dislikeCount ? _self.dislikeCount : dislikeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
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
