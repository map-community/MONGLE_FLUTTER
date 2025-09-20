// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_objects_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MapObjectsResponse {

 List<IssueGrainDto> get grains; List<StaticCloudDto> get staticClouds; List<DynamicCloudDto> get dynamicClouds;
/// Create a copy of MapObjectsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapObjectsResponseCopyWith<MapObjectsResponse> get copyWith => _$MapObjectsResponseCopyWithImpl<MapObjectsResponse>(this as MapObjectsResponse, _$identity);

  /// Serializes this MapObjectsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapObjectsResponse&&const DeepCollectionEquality().equals(other.grains, grains)&&const DeepCollectionEquality().equals(other.staticClouds, staticClouds)&&const DeepCollectionEquality().equals(other.dynamicClouds, dynamicClouds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(grains),const DeepCollectionEquality().hash(staticClouds),const DeepCollectionEquality().hash(dynamicClouds));

@override
String toString() {
  return 'MapObjectsResponse(grains: $grains, staticClouds: $staticClouds, dynamicClouds: $dynamicClouds)';
}


}

/// @nodoc
abstract mixin class $MapObjectsResponseCopyWith<$Res>  {
  factory $MapObjectsResponseCopyWith(MapObjectsResponse value, $Res Function(MapObjectsResponse) _then) = _$MapObjectsResponseCopyWithImpl;
@useResult
$Res call({
 List<IssueGrainDto> grains, List<StaticCloudDto> staticClouds, List<DynamicCloudDto> dynamicClouds
});




}
/// @nodoc
class _$MapObjectsResponseCopyWithImpl<$Res>
    implements $MapObjectsResponseCopyWith<$Res> {
  _$MapObjectsResponseCopyWithImpl(this._self, this._then);

  final MapObjectsResponse _self;
  final $Res Function(MapObjectsResponse) _then;

/// Create a copy of MapObjectsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? grains = null,Object? staticClouds = null,Object? dynamicClouds = null,}) {
  return _then(_self.copyWith(
grains: null == grains ? _self.grains : grains // ignore: cast_nullable_to_non_nullable
as List<IssueGrainDto>,staticClouds: null == staticClouds ? _self.staticClouds : staticClouds // ignore: cast_nullable_to_non_nullable
as List<StaticCloudDto>,dynamicClouds: null == dynamicClouds ? _self.dynamicClouds : dynamicClouds // ignore: cast_nullable_to_non_nullable
as List<DynamicCloudDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [MapObjectsResponse].
extension MapObjectsResponsePatterns on MapObjectsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapObjectsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapObjectsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapObjectsResponse value)  $default,){
final _that = this;
switch (_that) {
case _MapObjectsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapObjectsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MapObjectsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<IssueGrainDto> grains,  List<StaticCloudDto> staticClouds,  List<DynamicCloudDto> dynamicClouds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapObjectsResponse() when $default != null:
return $default(_that.grains,_that.staticClouds,_that.dynamicClouds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<IssueGrainDto> grains,  List<StaticCloudDto> staticClouds,  List<DynamicCloudDto> dynamicClouds)  $default,) {final _that = this;
switch (_that) {
case _MapObjectsResponse():
return $default(_that.grains,_that.staticClouds,_that.dynamicClouds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<IssueGrainDto> grains,  List<StaticCloudDto> staticClouds,  List<DynamicCloudDto> dynamicClouds)?  $default,) {final _that = this;
switch (_that) {
case _MapObjectsResponse() when $default != null:
return $default(_that.grains,_that.staticClouds,_that.dynamicClouds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MapObjectsResponse implements MapObjectsResponse {
  const _MapObjectsResponse({final  List<IssueGrainDto> grains = const [], final  List<StaticCloudDto> staticClouds = const [], final  List<DynamicCloudDto> dynamicClouds = const []}): _grains = grains,_staticClouds = staticClouds,_dynamicClouds = dynamicClouds;
  factory _MapObjectsResponse.fromJson(Map<String, dynamic> json) => _$MapObjectsResponseFromJson(json);

 final  List<IssueGrainDto> _grains;
@override@JsonKey() List<IssueGrainDto> get grains {
  if (_grains is EqualUnmodifiableListView) return _grains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_grains);
}

 final  List<StaticCloudDto> _staticClouds;
@override@JsonKey() List<StaticCloudDto> get staticClouds {
  if (_staticClouds is EqualUnmodifiableListView) return _staticClouds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_staticClouds);
}

 final  List<DynamicCloudDto> _dynamicClouds;
@override@JsonKey() List<DynamicCloudDto> get dynamicClouds {
  if (_dynamicClouds is EqualUnmodifiableListView) return _dynamicClouds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dynamicClouds);
}


/// Create a copy of MapObjectsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapObjectsResponseCopyWith<_MapObjectsResponse> get copyWith => __$MapObjectsResponseCopyWithImpl<_MapObjectsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MapObjectsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapObjectsResponse&&const DeepCollectionEquality().equals(other._grains, _grains)&&const DeepCollectionEquality().equals(other._staticClouds, _staticClouds)&&const DeepCollectionEquality().equals(other._dynamicClouds, _dynamicClouds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_grains),const DeepCollectionEquality().hash(_staticClouds),const DeepCollectionEquality().hash(_dynamicClouds));

@override
String toString() {
  return 'MapObjectsResponse(grains: $grains, staticClouds: $staticClouds, dynamicClouds: $dynamicClouds)';
}


}

/// @nodoc
abstract mixin class _$MapObjectsResponseCopyWith<$Res> implements $MapObjectsResponseCopyWith<$Res> {
  factory _$MapObjectsResponseCopyWith(_MapObjectsResponse value, $Res Function(_MapObjectsResponse) _then) = __$MapObjectsResponseCopyWithImpl;
@override @useResult
$Res call({
 List<IssueGrainDto> grains, List<StaticCloudDto> staticClouds, List<DynamicCloudDto> dynamicClouds
});




}
/// @nodoc
class __$MapObjectsResponseCopyWithImpl<$Res>
    implements _$MapObjectsResponseCopyWith<$Res> {
  __$MapObjectsResponseCopyWithImpl(this._self, this._then);

  final _MapObjectsResponse _self;
  final $Res Function(_MapObjectsResponse) _then;

/// Create a copy of MapObjectsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? grains = null,Object? staticClouds = null,Object? dynamicClouds = null,}) {
  return _then(_MapObjectsResponse(
grains: null == grains ? _self._grains : grains // ignore: cast_nullable_to_non_nullable
as List<IssueGrainDto>,staticClouds: null == staticClouds ? _self._staticClouds : staticClouds // ignore: cast_nullable_to_non_nullable
as List<StaticCloudDto>,dynamicClouds: null == dynamicClouds ? _self._dynamicClouds : dynamicClouds // ignore: cast_nullable_to_non_nullable
as List<DynamicCloudDto>,
  ));
}


}


/// @nodoc
mixin _$IssueGrainDto {

// API 명세서의 `postId` 필드와 매칭됩니다.
 String get postId; double get latitude; double get longitude; String? get profileImageUrl;
/// Create a copy of IssueGrainDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IssueGrainDtoCopyWith<IssueGrainDto> get copyWith => _$IssueGrainDtoCopyWithImpl<IssueGrainDto>(this as IssueGrainDto, _$identity);

  /// Serializes this IssueGrainDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IssueGrainDto&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,latitude,longitude,profileImageUrl);

@override
String toString() {
  return 'IssueGrainDto(postId: $postId, latitude: $latitude, longitude: $longitude, profileImageUrl: $profileImageUrl)';
}


}

/// @nodoc
abstract mixin class $IssueGrainDtoCopyWith<$Res>  {
  factory $IssueGrainDtoCopyWith(IssueGrainDto value, $Res Function(IssueGrainDto) _then) = _$IssueGrainDtoCopyWithImpl;
@useResult
$Res call({
 String postId, double latitude, double longitude, String? profileImageUrl
});




}
/// @nodoc
class _$IssueGrainDtoCopyWithImpl<$Res>
    implements $IssueGrainDtoCopyWith<$Res> {
  _$IssueGrainDtoCopyWithImpl(this._self, this._then);

  final IssueGrainDto _self;
  final $Res Function(IssueGrainDto) _then;

/// Create a copy of IssueGrainDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,Object? latitude = null,Object? longitude = null,Object? profileImageUrl = freezed,}) {
  return _then(_self.copyWith(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [IssueGrainDto].
extension IssueGrainDtoPatterns on IssueGrainDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IssueGrainDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IssueGrainDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IssueGrainDto value)  $default,){
final _that = this;
switch (_that) {
case _IssueGrainDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IssueGrainDto value)?  $default,){
final _that = this;
switch (_that) {
case _IssueGrainDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String postId,  double latitude,  double longitude,  String? profileImageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IssueGrainDto() when $default != null:
return $default(_that.postId,_that.latitude,_that.longitude,_that.profileImageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String postId,  double latitude,  double longitude,  String? profileImageUrl)  $default,) {final _that = this;
switch (_that) {
case _IssueGrainDto():
return $default(_that.postId,_that.latitude,_that.longitude,_that.profileImageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String postId,  double latitude,  double longitude,  String? profileImageUrl)?  $default,) {final _that = this;
switch (_that) {
case _IssueGrainDto() when $default != null:
return $default(_that.postId,_that.latitude,_that.longitude,_that.profileImageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IssueGrainDto implements IssueGrainDto {
  const _IssueGrainDto({required this.postId, required this.latitude, required this.longitude, this.profileImageUrl});
  factory _IssueGrainDto.fromJson(Map<String, dynamic> json) => _$IssueGrainDtoFromJson(json);

// API 명세서의 `postId` 필드와 매칭됩니다.
@override final  String postId;
@override final  double latitude;
@override final  double longitude;
@override final  String? profileImageUrl;

/// Create a copy of IssueGrainDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IssueGrainDtoCopyWith<_IssueGrainDto> get copyWith => __$IssueGrainDtoCopyWithImpl<_IssueGrainDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IssueGrainDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IssueGrainDto&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,postId,latitude,longitude,profileImageUrl);

@override
String toString() {
  return 'IssueGrainDto(postId: $postId, latitude: $latitude, longitude: $longitude, profileImageUrl: $profileImageUrl)';
}


}

/// @nodoc
abstract mixin class _$IssueGrainDtoCopyWith<$Res> implements $IssueGrainDtoCopyWith<$Res> {
  factory _$IssueGrainDtoCopyWith(_IssueGrainDto value, $Res Function(_IssueGrainDto) _then) = __$IssueGrainDtoCopyWithImpl;
@override @useResult
$Res call({
 String postId, double latitude, double longitude, String? profileImageUrl
});




}
/// @nodoc
class __$IssueGrainDtoCopyWithImpl<$Res>
    implements _$IssueGrainDtoCopyWith<$Res> {
  __$IssueGrainDtoCopyWithImpl(this._self, this._then);

  final _IssueGrainDto _self;
  final $Res Function(_IssueGrainDto) _then;

/// Create a copy of IssueGrainDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,Object? latitude = null,Object? longitude = null,Object? profileImageUrl = freezed,}) {
  return _then(_IssueGrainDto(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StaticCloudDto {

// DTO(Data Transfer Object): 데이터 전송 계층에서 사용하는 객체라는 의미로 Dto 접미사를 붙였습니다.
 String get placeId; String get name; double get centerLatitude; double get centerLongitude; int get postCount;// 기획 변경에 따라 정적 클라우드도 폴리곤 정보를 받습니다.
@NLatLngConverter() List<NLatLng> get polygon;
/// Create a copy of StaticCloudDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaticCloudDtoCopyWith<StaticCloudDto> get copyWith => _$StaticCloudDtoCopyWithImpl<StaticCloudDto>(this as StaticCloudDto, _$identity);

  /// Serializes this StaticCloudDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaticCloudDto&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.centerLatitude, centerLatitude) || other.centerLatitude == centerLatitude)&&(identical(other.centerLongitude, centerLongitude) || other.centerLongitude == centerLongitude)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&const DeepCollectionEquality().equals(other.polygon, polygon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,name,centerLatitude,centerLongitude,postCount,const DeepCollectionEquality().hash(polygon));

@override
String toString() {
  return 'StaticCloudDto(placeId: $placeId, name: $name, centerLatitude: $centerLatitude, centerLongitude: $centerLongitude, postCount: $postCount, polygon: $polygon)';
}


}

/// @nodoc
abstract mixin class $StaticCloudDtoCopyWith<$Res>  {
  factory $StaticCloudDtoCopyWith(StaticCloudDto value, $Res Function(StaticCloudDto) _then) = _$StaticCloudDtoCopyWithImpl;
@useResult
$Res call({
 String placeId, String name, double centerLatitude, double centerLongitude, int postCount,@NLatLngConverter() List<NLatLng> polygon
});




}
/// @nodoc
class _$StaticCloudDtoCopyWithImpl<$Res>
    implements $StaticCloudDtoCopyWith<$Res> {
  _$StaticCloudDtoCopyWithImpl(this._self, this._then);

  final StaticCloudDto _self;
  final $Res Function(StaticCloudDto) _then;

/// Create a copy of StaticCloudDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? name = null,Object? centerLatitude = null,Object? centerLongitude = null,Object? postCount = null,Object? polygon = null,}) {
  return _then(_self.copyWith(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,centerLatitude: null == centerLatitude ? _self.centerLatitude : centerLatitude // ignore: cast_nullable_to_non_nullable
as double,centerLongitude: null == centerLongitude ? _self.centerLongitude : centerLongitude // ignore: cast_nullable_to_non_nullable
as double,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,polygon: null == polygon ? _self.polygon : polygon // ignore: cast_nullable_to_non_nullable
as List<NLatLng>,
  ));
}

}


/// Adds pattern-matching-related methods to [StaticCloudDto].
extension StaticCloudDtoPatterns on StaticCloudDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaticCloudDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaticCloudDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaticCloudDto value)  $default,){
final _that = this;
switch (_that) {
case _StaticCloudDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaticCloudDto value)?  $default,){
final _that = this;
switch (_that) {
case _StaticCloudDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String placeId,  String name,  double centerLatitude,  double centerLongitude,  int postCount, @NLatLngConverter()  List<NLatLng> polygon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaticCloudDto() when $default != null:
return $default(_that.placeId,_that.name,_that.centerLatitude,_that.centerLongitude,_that.postCount,_that.polygon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String placeId,  String name,  double centerLatitude,  double centerLongitude,  int postCount, @NLatLngConverter()  List<NLatLng> polygon)  $default,) {final _that = this;
switch (_that) {
case _StaticCloudDto():
return $default(_that.placeId,_that.name,_that.centerLatitude,_that.centerLongitude,_that.postCount,_that.polygon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String placeId,  String name,  double centerLatitude,  double centerLongitude,  int postCount, @NLatLngConverter()  List<NLatLng> polygon)?  $default,) {final _that = this;
switch (_that) {
case _StaticCloudDto() when $default != null:
return $default(_that.placeId,_that.name,_that.centerLatitude,_that.centerLongitude,_that.postCount,_that.polygon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaticCloudDto implements StaticCloudDto {
  const _StaticCloudDto({required this.placeId, required this.name, required this.centerLatitude, required this.centerLongitude, required this.postCount, @NLatLngConverter() final  List<NLatLng> polygon = const []}): _polygon = polygon;
  factory _StaticCloudDto.fromJson(Map<String, dynamic> json) => _$StaticCloudDtoFromJson(json);

// DTO(Data Transfer Object): 데이터 전송 계층에서 사용하는 객체라는 의미로 Dto 접미사를 붙였습니다.
@override final  String placeId;
@override final  String name;
@override final  double centerLatitude;
@override final  double centerLongitude;
@override final  int postCount;
// 기획 변경에 따라 정적 클라우드도 폴리곤 정보를 받습니다.
 final  List<NLatLng> _polygon;
// 기획 변경에 따라 정적 클라우드도 폴리곤 정보를 받습니다.
@override@JsonKey()@NLatLngConverter() List<NLatLng> get polygon {
  if (_polygon is EqualUnmodifiableListView) return _polygon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_polygon);
}


/// Create a copy of StaticCloudDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaticCloudDtoCopyWith<_StaticCloudDto> get copyWith => __$StaticCloudDtoCopyWithImpl<_StaticCloudDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaticCloudDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaticCloudDto&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.centerLatitude, centerLatitude) || other.centerLatitude == centerLatitude)&&(identical(other.centerLongitude, centerLongitude) || other.centerLongitude == centerLongitude)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&const DeepCollectionEquality().equals(other._polygon, _polygon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,name,centerLatitude,centerLongitude,postCount,const DeepCollectionEquality().hash(_polygon));

@override
String toString() {
  return 'StaticCloudDto(placeId: $placeId, name: $name, centerLatitude: $centerLatitude, centerLongitude: $centerLongitude, postCount: $postCount, polygon: $polygon)';
}


}

/// @nodoc
abstract mixin class _$StaticCloudDtoCopyWith<$Res> implements $StaticCloudDtoCopyWith<$Res> {
  factory _$StaticCloudDtoCopyWith(_StaticCloudDto value, $Res Function(_StaticCloudDto) _then) = __$StaticCloudDtoCopyWithImpl;
@override @useResult
$Res call({
 String placeId, String name, double centerLatitude, double centerLongitude, int postCount,@NLatLngConverter() List<NLatLng> polygon
});




}
/// @nodoc
class __$StaticCloudDtoCopyWithImpl<$Res>
    implements _$StaticCloudDtoCopyWith<$Res> {
  __$StaticCloudDtoCopyWithImpl(this._self, this._then);

  final _StaticCloudDto _self;
  final $Res Function(_StaticCloudDto) _then;

/// Create a copy of StaticCloudDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? name = null,Object? centerLatitude = null,Object? centerLongitude = null,Object? postCount = null,Object? polygon = null,}) {
  return _then(_StaticCloudDto(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,centerLatitude: null == centerLatitude ? _self.centerLatitude : centerLatitude // ignore: cast_nullable_to_non_nullable
as double,centerLongitude: null == centerLongitude ? _self.centerLongitude : centerLongitude // ignore: cast_nullable_to_non_nullable
as double,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,polygon: null == polygon ? _self._polygon : polygon // ignore: cast_nullable_to_non_nullable
as List<NLatLng>,
  ));
}


}


/// @nodoc
mixin _$DynamicCloudDto {

 String get cloudId; int get postCount;// API 응답의 polygon(좌표 리스트)을 NLatLng 리스트로 변환하기 위해
// 별도의 Converter를 사용합니다. (아래에 정의)
@NLatLngConverter() List<NLatLng> get polygon;
/// Create a copy of DynamicCloudDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DynamicCloudDtoCopyWith<DynamicCloudDto> get copyWith => _$DynamicCloudDtoCopyWithImpl<DynamicCloudDto>(this as DynamicCloudDto, _$identity);

  /// Serializes this DynamicCloudDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DynamicCloudDto&&(identical(other.cloudId, cloudId) || other.cloudId == cloudId)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&const DeepCollectionEquality().equals(other.polygon, polygon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cloudId,postCount,const DeepCollectionEquality().hash(polygon));

@override
String toString() {
  return 'DynamicCloudDto(cloudId: $cloudId, postCount: $postCount, polygon: $polygon)';
}


}

/// @nodoc
abstract mixin class $DynamicCloudDtoCopyWith<$Res>  {
  factory $DynamicCloudDtoCopyWith(DynamicCloudDto value, $Res Function(DynamicCloudDto) _then) = _$DynamicCloudDtoCopyWithImpl;
@useResult
$Res call({
 String cloudId, int postCount,@NLatLngConverter() List<NLatLng> polygon
});




}
/// @nodoc
class _$DynamicCloudDtoCopyWithImpl<$Res>
    implements $DynamicCloudDtoCopyWith<$Res> {
  _$DynamicCloudDtoCopyWithImpl(this._self, this._then);

  final DynamicCloudDto _self;
  final $Res Function(DynamicCloudDto) _then;

/// Create a copy of DynamicCloudDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cloudId = null,Object? postCount = null,Object? polygon = null,}) {
  return _then(_self.copyWith(
cloudId: null == cloudId ? _self.cloudId : cloudId // ignore: cast_nullable_to_non_nullable
as String,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,polygon: null == polygon ? _self.polygon : polygon // ignore: cast_nullable_to_non_nullable
as List<NLatLng>,
  ));
}

}


/// Adds pattern-matching-related methods to [DynamicCloudDto].
extension DynamicCloudDtoPatterns on DynamicCloudDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DynamicCloudDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DynamicCloudDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DynamicCloudDto value)  $default,){
final _that = this;
switch (_that) {
case _DynamicCloudDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DynamicCloudDto value)?  $default,){
final _that = this;
switch (_that) {
case _DynamicCloudDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String cloudId,  int postCount, @NLatLngConverter()  List<NLatLng> polygon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DynamicCloudDto() when $default != null:
return $default(_that.cloudId,_that.postCount,_that.polygon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String cloudId,  int postCount, @NLatLngConverter()  List<NLatLng> polygon)  $default,) {final _that = this;
switch (_that) {
case _DynamicCloudDto():
return $default(_that.cloudId,_that.postCount,_that.polygon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String cloudId,  int postCount, @NLatLngConverter()  List<NLatLng> polygon)?  $default,) {final _that = this;
switch (_that) {
case _DynamicCloudDto() when $default != null:
return $default(_that.cloudId,_that.postCount,_that.polygon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DynamicCloudDto implements DynamicCloudDto {
  const _DynamicCloudDto({required this.cloudId, required this.postCount, @NLatLngConverter() final  List<NLatLng> polygon = const []}): _polygon = polygon;
  factory _DynamicCloudDto.fromJson(Map<String, dynamic> json) => _$DynamicCloudDtoFromJson(json);

@override final  String cloudId;
@override final  int postCount;
// API 응답의 polygon(좌표 리스트)을 NLatLng 리스트로 변환하기 위해
// 별도의 Converter를 사용합니다. (아래에 정의)
 final  List<NLatLng> _polygon;
// API 응답의 polygon(좌표 리스트)을 NLatLng 리스트로 변환하기 위해
// 별도의 Converter를 사용합니다. (아래에 정의)
@override@JsonKey()@NLatLngConverter() List<NLatLng> get polygon {
  if (_polygon is EqualUnmodifiableListView) return _polygon;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_polygon);
}


/// Create a copy of DynamicCloudDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DynamicCloudDtoCopyWith<_DynamicCloudDto> get copyWith => __$DynamicCloudDtoCopyWithImpl<_DynamicCloudDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DynamicCloudDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DynamicCloudDto&&(identical(other.cloudId, cloudId) || other.cloudId == cloudId)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&const DeepCollectionEquality().equals(other._polygon, _polygon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cloudId,postCount,const DeepCollectionEquality().hash(_polygon));

@override
String toString() {
  return 'DynamicCloudDto(cloudId: $cloudId, postCount: $postCount, polygon: $polygon)';
}


}

/// @nodoc
abstract mixin class _$DynamicCloudDtoCopyWith<$Res> implements $DynamicCloudDtoCopyWith<$Res> {
  factory _$DynamicCloudDtoCopyWith(_DynamicCloudDto value, $Res Function(_DynamicCloudDto) _then) = __$DynamicCloudDtoCopyWithImpl;
@override @useResult
$Res call({
 String cloudId, int postCount,@NLatLngConverter() List<NLatLng> polygon
});




}
/// @nodoc
class __$DynamicCloudDtoCopyWithImpl<$Res>
    implements _$DynamicCloudDtoCopyWith<$Res> {
  __$DynamicCloudDtoCopyWithImpl(this._self, this._then);

  final _DynamicCloudDto _self;
  final $Res Function(_DynamicCloudDto) _then;

/// Create a copy of DynamicCloudDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cloudId = null,Object? postCount = null,Object? polygon = null,}) {
  return _then(_DynamicCloudDto(
cloudId: null == cloudId ? _self.cloudId : cloudId // ignore: cast_nullable_to_non_nullable
as String,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,polygon: null == polygon ? _self._polygon : polygon // ignore: cast_nullable_to_non_nullable
as List<NLatLng>,
  ));
}


}

// dart format on
