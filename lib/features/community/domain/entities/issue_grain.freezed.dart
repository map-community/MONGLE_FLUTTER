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

 String get postId; Author get author;// 작성자 정보 (User 모델과 결합)
 String get content; double get latitude; double get longitude; List<String> get photoUrls;// 이미지 URL 목록
 List<String> get videoUrls; int get likeCount; int get dislikeCount; int get commentCount; int get viewCount; DateTime get createdAt; DateTime? get updatedAt;@JsonKey(includeFromJson: false, includeToJson: false) ReactionType? get myReaction;
/// Create a copy of IssueGrain
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueGrainCopyWith<IssueGrain> get copyWith => _$IssueGrainCopyWithImpl<IssueGrain>(this as IssueGrain, _$identity);

  /// Serializes this IssueGrain to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueGrain&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.photoUrls, photoUrls)&&const DeepCollectionEquality().equals(other.videoUrls, videoUrls)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.dislikeCount, dislikeCount) || other.dislikeCount == dislikeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,author,content,latitude,longitude,const DeepCollectionEquality().hash(photoUrls),const DeepCollectionEquality().hash(videoUrls),likeCount,dislikeCount,commentCount,viewCount,createdAt,updatedAt,myReaction);

@override
String toString() {
  return 'IssueGrain(postId: $postId, author: $author, content: $content, latitude: $latitude, longitude: $longitude, photoUrls: $photoUrls, videoUrls: $videoUrls, likeCount: $likeCount, dislikeCount: $dislikeCount, commentCount: $commentCount, viewCount: $viewCount, createdAt: $createdAt, updatedAt: $updatedAt, myReaction: $myReaction)';
}


}

/// @nodoc
abstract mixin class $IssueGrainCopyWith<$Res>  {
  factory $IssueGrainCopyWith(IssueGrain value, $Res Function(IssueGrain) _then) = _$IssueGrainCopyWithImpl;
@useResult
$Res call({
 String postId, Author author, String content, double latitude, double longitude, List<String> photoUrls, List<String> videoUrls, int likeCount, int dislikeCount, int commentCount, int viewCount, DateTime createdAt, DateTime? updatedAt,@JsonKey(includeFromJson: false, includeToJson: false) ReactionType? myReaction
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
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,Object? author = null,Object? content = null,Object? latitude = null,Object? longitude = null,Object? photoUrls = null,Object? videoUrls = null,Object? likeCount = null,Object? dislikeCount = null,Object? commentCount = null,Object? viewCount = null,Object? createdAt = null,Object? updatedAt = freezed,Object? myReaction = freezed,}) {
  return _then(_self.copyWith(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,photoUrls: null == photoUrls ? _self.photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,videoUrls: null == videoUrls ? _self.videoUrls : videoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,dislikeCount: null == dislikeCount ? _self.dislikeCount : dislikeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,myReaction: freezed == myReaction ? _self.myReaction : myReaction // ignore: cast_nullable_to_non_nullable
as ReactionType?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String postId,  Author author,  String content,  double latitude,  double longitude,  List<String> photoUrls,  List<String> videoUrls,  int likeCount,  int dislikeCount,  int commentCount,  int viewCount,  DateTime createdAt,  DateTime? updatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  ReactionType? myReaction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueGrain() when $default != null:
return $default(_that.postId,_that.author,_that.content,_that.latitude,_that.longitude,_that.photoUrls,_that.videoUrls,_that.likeCount,_that.dislikeCount,_that.commentCount,_that.viewCount,_that.createdAt,_that.updatedAt,_that.myReaction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String postId,  Author author,  String content,  double latitude,  double longitude,  List<String> photoUrls,  List<String> videoUrls,  int likeCount,  int dislikeCount,  int commentCount,  int viewCount,  DateTime createdAt,  DateTime? updatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  ReactionType? myReaction)  $default,) {final _that = this;
switch (_that) {
case _IssueGrain():
return $default(_that.postId,_that.author,_that.content,_that.latitude,_that.longitude,_that.photoUrls,_that.videoUrls,_that.likeCount,_that.dislikeCount,_that.commentCount,_that.viewCount,_that.createdAt,_that.updatedAt,_that.myReaction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String postId,  Author author,  String content,  double latitude,  double longitude,  List<String> photoUrls,  List<String> videoUrls,  int likeCount,  int dislikeCount,  int commentCount,  int viewCount,  DateTime createdAt,  DateTime? updatedAt, @JsonKey(includeFromJson: false, includeToJson: false)  ReactionType? myReaction)?  $default,) {final _that = this;
switch (_that) {
case _IssueGrain() when $default != null:
return $default(_that.postId,_that.author,_that.content,_that.latitude,_that.longitude,_that.photoUrls,_that.videoUrls,_that.likeCount,_that.dislikeCount,_that.commentCount,_that.viewCount,_that.createdAt,_that.updatedAt,_that.myReaction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueGrain implements IssueGrain {
  const _IssueGrain({required this.postId, required this.author, required this.content, required this.latitude, required this.longitude, final  List<String> photoUrls = const [], final  List<String> videoUrls = const [], required this.likeCount, required this.dislikeCount, required this.commentCount, required this.viewCount, required this.createdAt, this.updatedAt, @JsonKey(includeFromJson: false, includeToJson: false) this.myReaction = null}): _photoUrls = photoUrls,_videoUrls = videoUrls;
  factory _IssueGrain.fromJson(Map<String, dynamic> json) => _$IssueGrainFromJson(json);

@override final  String postId;
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
 final  List<String> _videoUrls;
// 이미지 URL 목록
@override@JsonKey() List<String> get videoUrls {
  if (_videoUrls is EqualUnmodifiableListView) return _videoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videoUrls);
}

@override final  int likeCount;
@override final  int dislikeCount;
@override final  int commentCount;
@override final  int viewCount;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  ReactionType? myReaction;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueGrain&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._photoUrls, _photoUrls)&&const DeepCollectionEquality().equals(other._videoUrls, _videoUrls)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.dislikeCount, dislikeCount) || other.dislikeCount == dislikeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,author,content,latitude,longitude,const DeepCollectionEquality().hash(_photoUrls),const DeepCollectionEquality().hash(_videoUrls),likeCount,dislikeCount,commentCount,viewCount,createdAt,updatedAt,myReaction);

@override
String toString() {
  return 'IssueGrain(postId: $postId, author: $author, content: $content, latitude: $latitude, longitude: $longitude, photoUrls: $photoUrls, videoUrls: $videoUrls, likeCount: $likeCount, dislikeCount: $dislikeCount, commentCount: $commentCount, viewCount: $viewCount, createdAt: $createdAt, updatedAt: $updatedAt, myReaction: $myReaction)';
}


}

/// @nodoc
abstract mixin class _$IssueGrainCopyWith<$Res> implements $IssueGrainCopyWith<$Res> {
  factory _$IssueGrainCopyWith(_IssueGrain value, $Res Function(_IssueGrain) _then) = __$IssueGrainCopyWithImpl;
@override @useResult
$Res call({
 String postId, Author author, String content, double latitude, double longitude, List<String> photoUrls, List<String> videoUrls, int likeCount, int dislikeCount, int commentCount, int viewCount, DateTime createdAt, DateTime? updatedAt,@JsonKey(includeFromJson: false, includeToJson: false) ReactionType? myReaction
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
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? author = null,Object? content = null,Object? latitude = null,Object? longitude = null,Object? photoUrls = null,Object? videoUrls = null,Object? likeCount = null,Object? dislikeCount = null,Object? commentCount = null,Object? viewCount = null,Object? createdAt = null,Object? updatedAt = freezed,Object? myReaction = freezed,}) {
  return _then(_IssueGrain(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,photoUrls: null == photoUrls ? _self._photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,videoUrls: null == videoUrls ? _self._videoUrls : videoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,dislikeCount: null == dislikeCount ? _self.dislikeCount : dislikeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,myReaction: freezed == myReaction ? _self.myReaction : myReaction // ignore: cast_nullable_to_non_nullable
as ReactionType?,
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
