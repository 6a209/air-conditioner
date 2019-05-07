import 'dart:core';

import '../../base/base_data.dart' as basedata;
import 'package:json_annotation/json_annotation.dart';
import '../models/command_data.dart';

part 'device_data.g.dart';

@JsonSerializable()
class DeviceDetailData extends basedata.BaseData {
  String deviceName;
  String productKey; 
  String productId;
  String icon;
  String detailImage;
  String name;

  List<CommandData> commands;

  DeviceDetailData({
    this.deviceName, 
    this.productKey, 
    this.productId, 
    this.icon,
    this.detailImage,
    this.name,
    this.commands});

  factory DeviceDetailData.fromJson(Map<String, dynamic> json) => _$DeviceDetailDataFromJson(json); 
  Map<String, dynamic> toJson() => _$DeviceDetailDataToJson(this);
}