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
      mode: json['mode'] as String,
      power: json['power'] as String,
      commands: (json['commands'] as List)
          ?.map((e) => e == null
              ? null
              : CommandData.fromJson(e as Map<String, dynamic>))
          ?.toList())
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
      'power': instance.power,
      'commands': instance.commands
    };
