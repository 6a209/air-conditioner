
import 'package:flutter/material.dart';

class DeviceDetail extends StatefulWidget {
  final int deviceId;
  final int pid;
  String name = "空调";

  DeviceDetail({Key key, this.pid, this.deviceId, this.name})
      : super(key: key);

  @override
  DeviceDetailState createState() => new DeviceDetailState();
}

class DeviceDetailState extends State<DeviceDetail> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}