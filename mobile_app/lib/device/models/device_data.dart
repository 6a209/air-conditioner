import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_app/device/models/command_data.dart';

part 'device_data.g.dart';

@JsonSerializable()
class DeviceDetailData  {
  int id;
  String deviceName;
  String productKey; 
  int productId;
  String icon;
  String detailImage;
  String name;
  int temperature;
  String mode;
  // on off
  String power;

  List<CommandData> commands;

  DeviceDetailData({
    this.deviceName, 
    this.productKey, 
    this.productId, 
    this.icon,
    this.detailImage,
    this.name,
    temperature = 18,
    this.mode = 'code',
    this.power = 'off',
    this.commands}) {

      if (temperature == null) {
        temperature = 18;
      }
      if (mode == null) {
        mode = 'code';
      }
      if (power == null) {
        power = 'off';
      }
      print("t-->>>>>>>>>>>");
      print(temperature);
      this.temperature = temperature;
      this.mode = mode;
      this.power = power;
    }

  factory DeviceDetailData.fromJson(Map<String, dynamic> json) => _$DeviceDetailDataFromJson(json); 
  Map<String, dynamic> toJson() => _$DeviceDetailDataToJson(this);
}
