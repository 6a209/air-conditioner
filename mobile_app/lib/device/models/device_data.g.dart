// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceDetailData _$DeviceDetailDataFromJson(Map<String, dynamic> json) {
  return DeviceDetailData(
      deviceName: json['deviceName'] as String,
      productKey: json['productKey'] as String,
      productId: json['productId'] as String,
      icon: json['icon'] as String,
      detailImage: json['detailImage'] as String,
      name: json['name'] as String,
      commands: (json['commands'] as List)
          ?.map((e) => e == null
              ? null
              : CommandData.fromJson(e as Map<String, dynamic>))
          ?.toList())
    ..code = json['code'] as int
    ..msg = json['msg'] as String;
}

Map<String, dynamic> _$DeviceDetailDataToJson(DeviceDetailData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'deviceName': instance.deviceName,
      'productKey': instance.productKey,
      'productId': instance.productId,
      'icon': instance.icon,
      'detailImage': instance.detailImage,
      'name': instance.name,
      'commands': instance.commands
    };
