// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportedContent _$ReportedContentFromJson(Map<String, dynamic> json) =>
    _ReportedContent(
      id: json['id'] as String,
      type: $enumDecode(_$ReportContentTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$ReportedContentToJson(_ReportedContent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ReportContentTypeEnumMap[instance.type]!,
    };

const _$ReportContentTypeEnumMap = {
  ReportContentType.POST: 'POST',
  ReportContentType.COMMENT: 'COMMENT',
};
