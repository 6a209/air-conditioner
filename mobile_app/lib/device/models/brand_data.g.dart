// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Brand _$BrandFromJson(Map<String, dynamic> json) {
  return Brand(json['id'] as int, json['name'] as String);
}

Map<String, dynamic> _$BrandToJson(Brand instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

BrandMode _$BrandModeFromJson(Map<String, dynamic> json) {
  return BrandMode(json['id'] as int, json['brandId'] as int,
      json['brandName'] as String, json['mode'] as String);
}

Map<String, dynamic> _$BrandModeToJson(BrandMode instance) => <String, dynamic>{
      'id': instance.id,
      'brandId': instance.brandId,
      'brandName': instance.brandName,
      'mode': instance.mode
    };
