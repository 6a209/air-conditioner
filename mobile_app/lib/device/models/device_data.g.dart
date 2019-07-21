// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceDetailData _$DeviceDetailDataFromJson(Map<String, dynamic> json) {
  return DeviceDetailData(
      deviceName: json['deviceName'] as String,
      productKey: json['productKey'] as String,
      productId: json['productId'] as int,
      icon: json['icon'] as String,
      detailImage: json['detailImage'] as String,
      name: json['name'] as String,
      temperature: json['temperature'],
      mode: json['mode'] as int,
      power: json['power'] as int)
    ..id = json['id'] as int;
}

Map<String, dynamic> _$DeviceDetailDataToJson(DeviceDetailData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceName': instance.deviceName,
      'productKey': instance.productKey,
      'productId': instance.productId,
      'icon': instance.icon,
      'detailImage': instance.detailImage,
      'name': instance.name,
      'temperature': instance.temperature,
      'mode': instance.mode,
      'power': instance.power
    };
