import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// build_runner가 자동으로 생성할 파일들을 명시합니다.
part 'map_objects_response.freezed.dart';
part 'map_objects_response.g.dart';

// freezed: 불변 객체와 관련 코드를 자동으로 생성해줍니다.
// JsonSerializable: JSON 직렬화/역직렬화 코드를 자동으로 생성해줍니다.
@freezed
abstract class MapObjectsResponse with _$MapObjectsResponse {
  const factory MapObjectsResponse({
    @Default([]) List<IssueGrainDto> grains,
    @Default([]) List<StaticCloudDto> staticClouds,
    @Default([]) List<DynamicCloudDto> dynamicClouds,
  }) = _MapObjectsResponse;

  // JSON 데이터로부터 MapObjectsResponse 객체를 생성하는 factory 생성자입니다.
  factory MapObjectsResponse.fromJson(Map<String, dynamic> json) =>
      _$MapObjectsResponseFromJson(json);
}

@freezed
abstract class IssueGrainDto with _$IssueGrainDto {
  const factory IssueGrainDto({
    // API 명세서의 `postId` 필드와 매칭됩니다.
    required String postId,
    required double latitude,
    required double longitude,
    String? profileImageUrl,
  }) = _IssueGrainDto;

  factory IssueGrainDto.fromJson(Map<String, dynamic> json) =>
      _$IssueGrainDtoFromJson(json);
}

@freezed
abstract class StaticCloudDto with _$StaticCloudDto {
  const factory StaticCloudDto({
    // DTO(Data Transfer Object): 데이터 전송 계층에서 사용하는 객체라는 의미로 Dto 접미사를 붙였습니다.
    required String placeId,
    required String name,
    required double centerLatitude,
    required double centerLongitude,
    required int postCount,
    // 기획 변경에 따라 정적 클라우드도 폴리곤 정보를 받습니다.
    @Default([]) @NLatLngConverter() List<NLatLng> polygon,
  }) = _StaticCloudDto;

  factory StaticCloudDto.fromJson(Map<String, dynamic> json) =>
      _$StaticCloudDtoFromJson(json);
}

@freezed
abstract class DynamicCloudDto with _$DynamicCloudDto {
  const factory DynamicCloudDto({
    required String cloudId,
    required int postCount,
    // API 응답의 polygon(좌표 리스트)을 NLatLng 리스트로 변환하기 위해
    // 별도의 Converter를 사용합니다. (아래에 정의)
    @Default([]) @NLatLngConverter() List<NLatLng> polygon,
  }) = _DynamicCloudDto;

  factory DynamicCloudDto.fromJson(Map<String, dynamic> json) =>
      _$DynamicCloudDtoFromJson(json);
}

/// NLatLng 클래스는 fromJson/toJson을 지원하지 않으므로,
/// json_serializable이 변환할 수 있도록 헬퍼 클래스를 만들어줍니다.
class NLatLngConverter implements JsonConverter<NLatLng, Map<String, dynamic>> {
  const NLatLngConverter();

  @override
  NLatLng fromJson(Map<String, dynamic> json) {
    return NLatLng(json['latitude'] as double, json['longitude'] as double);
  }

  @override
  Map<String, dynamic> toJson(NLatLng object) {
    return {'latitude': object.latitude, 'longitude': object.longitude};
  }
}
