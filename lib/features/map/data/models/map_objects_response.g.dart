// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_objects_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MapObjectsResponse _$MapObjectsResponseFromJson(Map<String, dynamic> json) =>
    _MapObjectsResponse(
      grains:
          (json['grains'] as List<dynamic>?)
              ?.map((e) => IssueGrainDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      staticClouds:
          (json['staticClouds'] as List<dynamic>?)
              ?.map((e) => StaticCloudDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dynamicClouds:
          (json['dynamicClouds'] as List<dynamic>?)
              ?.map((e) => DynamicCloudDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MapObjectsResponseToJson(_MapObjectsResponse instance) =>
    <String, dynamic>{
      'grains': instance.grains,
      'staticClouds': instance.staticClouds,
      'dynamicClouds': instance.dynamicClouds,
    };

_IssueGrainDto _$IssueGrainDtoFromJson(Map<String, dynamic> json) =>
    _IssueGrainDto(
      postId: json['postId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      profileImageUrl: json['profileImageUrl'] as String?,
    );

Map<String, dynamic> _$IssueGrainDtoToJson(_IssueGrainDto instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'profileImageUrl': instance.profileImageUrl,
    };

_StaticCloudDto _$StaticCloudDtoFromJson(Map<String, dynamic> json) =>
    _StaticCloudDto(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      centerLatitude: (json['centerLatitude'] as num).toDouble(),
      centerLongitude: (json['centerLongitude'] as num).toDouble(),
      postCount: (json['postCount'] as num).toInt(),
      polygon:
          (json['polygon'] as List<dynamic>?)
              ?.map(
                (e) => const NLatLngConverter().fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StaticCloudDtoToJson(_StaticCloudDto instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'name': instance.name,
      'centerLatitude': instance.centerLatitude,
      'centerLongitude': instance.centerLongitude,
      'postCount': instance.postCount,
      'polygon': instance.polygon.map(const NLatLngConverter().toJson).toList(),
    };

_DynamicCloudDto _$DynamicCloudDtoFromJson(Map<String, dynamic> json) =>
    _DynamicCloudDto(
      cloudId: json['cloudId'] as String,
      postCount: (json['postCount'] as num).toInt(),
      polygon:
          (json['polygon'] as List<dynamic>?)
              ?.map(
                (e) => const NLatLngConverter().fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DynamicCloudDtoToJson(_DynamicCloudDto instance) =>
    <String, dynamic>{
      'cloudId': instance.cloudId,
      'postCount': instance.postCount,
      'polygon': instance.polygon.map(const NLatLngConverter().toJson).toList(),
    };
