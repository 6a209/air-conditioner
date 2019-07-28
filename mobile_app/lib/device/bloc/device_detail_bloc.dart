import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:mobile_app/base/base_data.dart';
import 'package:mobile_app/base/base_page.dart';
import 'package:mobile_app/base/toast.dart';
import 'package:mobile_app/device/models/command_data.dart';
import 'package:mobile_app/device/models/device_data.dart';
import 'package:mobile_app/user/user_manager.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mobile_app/device/api/device_detail.dart';
import 'package:mobile_app/base/http_utils.dart';
import 'package:mobile_app/base/mqtt_utils.dart';

class DeviceDetailBloc {
  final DeviceDetailApi _api = DeviceDetailApi();

  final BehaviorSubject<DeviceDetailData> _detailSubject = BehaviorSubject();
  final BehaviorSubject<BasePageState> _pageStateSubject = BehaviorSubject();
  final PublishSubject<bool> loadingSubject = new PublishSubject();
  final PublishSubject updatePropertySubject = new PublishSubject();

  bool isUpdateProperty = false;
  bool isDispose = false;
  String topic;
  Timer timer;
  BuildContext context;

  void init(int deviceId, BuildContext context) async {
    isDispose = false;
    this.context = context;
    loadingSubject.sink.add(true);
    print("loadingSubject => true");
    String topic = UserManager.instance().topic;
    topic = "user/$topic/property/update";
    MqttManager.instance().subscribe(topic, MqttQos.atMostOnce);
    MqttManager.instance().messageSubject.where((data) {
      return data.topic == topic;
    }).listen((data) {
      if (timer != null) {
        timer.cancel();
      }
      isUpdateProperty = false;
      var jsonData = json.decode(data.message);
      updateProperty(jsonData);
      loadingSubject.sink.add(false);
    });
    await getDetail(deviceId);

    loadingSubject.sink.add(false);
    // loadingSubject.sink.add(false);
  }

  void dispose() {
    
    isUpdateProperty = false;
    isDispose = true;
    if (topic.isNotEmpty) {
      MqttManager.instance().unsubscribe(topic);
    }
  }

  void updateProperty(var jsonData) {
    loadingSubject.add(false);
    _detailSubject.value.power = jsonData["power"];
    _detailSubject.value.mode = jsonData["mode"];
    _detailSubject.value.temperature = jsonData["temperature"];
    _detailSubject.sink.add(_detailSubject.value);
  }

  getDetail(int deviceId) async {
    HTTPResponse response = await _api.getDetail(deviceId);
    if (response.code != 200) {
      showToast(response.msg);
    } else {
      DeviceDetailData detailData = DeviceDetailData.fromJson(response.data);
      _detailSubject.sink.add(detailData);
    }
  }

  setPageStateChangeListener(listener) {
    _pageStateSubject.listen(listener);
  }

  funBtnClick(String name) async {
    int mode = modeValue(name);
    await execCommand("mode", mode);
  }

  modeValue(String name) {
    switch (name) {
      case "clod":
        return MODE_COOL;
      case "hot":
        return MODE_HEAT;
      case "wind":
        return MODE_FAN;
      case "wet":
        return MODE_DRY;
    }
    return MODE_COOL;
  }

  deleteDevice(int deviceId) async {
    HTTPResponse response = await _api.deleteDevice(deviceId);
    if (isDispose) {
      return;
    }
    if (200 == response.code) {
      Navigator.of(context).pop();
    } else {
      showToast(response.msg);
    }
  }

  updateDeviceName(int deviceId, String name) async {
    HTTPResponse response = await _api.updateDeviceName(deviceId, name);
    if (isDispose) {
      return;
    }
    if (200 == response.code) {
      _detailSubject.value.name = name;
      _detailSubject.sink.add(_detailSubject.value);
    } else {
      showToast(response.msg);
    }
  }

  powerOn() async {
    await execCommand("power", POWER_ON);
  }

  powerOff() async {
    await execCommand("power", POWER_OFF);
  }

  subTemperature() async {
    await execCommand("temperature", temperature - 1);
  }

  addTemperature() async {
    await execCommand("temperature", temperature + 1);
    // updatePropertySubject.add();
  }

  execCommand(String name, int value) async {
    if (isUpdateProperty) {
      return BaseData(code: 500, msg: "正在等上一个命令响应");
    }
    loadingSubject.add(true);
    isUpdateProperty = true;
    timer = Timer(Duration(seconds: 10), () {
      isUpdateProperty = false;
      showToast("设备响应超时");
      loadingSubject.add(false);
    });
    int deviceId = _detailSubject.value.id;
    var status = {};
    status['power'] = power;
    status['mode'] = _detailSubject.value.mode;
    status['temperature'] = _detailSubject.value.temperature;

    status[name] = value;
    var res = await _api.execCommand(deviceId, status);
    return BaseData(code: res.code, msg: res.msg);
  }

  BehaviorSubject<DeviceDetailData> get detailSubject => _detailSubject;
  int get temperature => _detailSubject.value.temperature;
  set temperature(int t) {
    _detailSubject.value.temperature = t;
    _detailSubject.add(detailSubject.value);
  }

  int get power => _detailSubject.value.power;
  set curStatus(int s) {
    _detailSubject.value.power = s;
    _detailSubject.sink.add(_detailSubject.value);
  }

  int get mode => _detailSubject.value.mode;
  set mode(int name) {
    _detailSubject.value.mode = name;
    _detailSubject.sink.add(_detailSubject.value);
  }
}

final deviceDetailBloc = DeviceDetailBloc();
