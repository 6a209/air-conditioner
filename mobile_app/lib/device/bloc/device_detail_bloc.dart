import 'dart:async';
import 'dart:convert';

import 'package:mobile_app/base/base_data.dart';
import 'package:mobile_app/base/base_page.dart';
import 'package:mobile_app/base/toast.dart';
import 'package:mobile_app/device/models/command_data.dart';
import 'package:mobile_app/device/models/device_data.dart';
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
  String topic;

  void init(int deviceId) async {
    loadingSubject.sink.add(true);
    print("loadingSubject => true");
    topic = "user/6a209/property/update";
    MqttManager.instance().subscribe(topic, MqttQos.atMostOnce);
    MqttManager.instance().messageSubject.where((data) {
      return data.topic == topic;
    }).listen((data) {
      isUpdateProperty = false;
      var jsonData = json.decode(data.message);
      updateProperty(jsonData['name'], jsonData['value']);
    });
    await getDetail(deviceId);

    updatePropertySubject
      .listen((name) async {
        BaseData data = await execCommand(name); 
        if (data.code != 200) {
           showToast(data.msg);
        }
      });

    loadingSubject.sink.add(false);
    // loadingSubject.sink.add(false);
  }

  void dispose() {
    isUpdateProperty = false;
    MqttManager.instance().unsubscribe(topic);
  }


  void updateProperty(String name, String value) {
    print("****updateProperty***");
    print(name);
    print(value);
    loadingSubject.add(false);
    if (name == "power") {
      _detailSubject.value.power = value; 
    } else if (name == "mode") {
      _detailSubject.value.mode = value;
    } else if (name == "temperture") {
      _detailSubject.value.temperature = int.parse(value);
    }
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

  subTemperature() async {
    BaseData data = await execCommand((temperature - 1).toString());
    if (data.code == 200) {
      temperature = temperature - 1;
    }
  }

  addTemperature() async {
    updatePropertySubject.add((temperature + 1).toString());
  }

  execCommand(String value) async {
    if (isUpdateProperty) {
      return BaseData(code: 500, msg: "正在等上一个命令响应");
    } 
    loadingSubject.add(true); 
    isUpdateProperty = true;
    Future.delayed(Duration(seconds: 30), (){
      if (isUpdateProperty) {
        isUpdateProperty = false;
        showToast("设备响应超时");
        loadingSubject.add(false);
      }
    });
    int deviceId = _detailSubject.value.id;
    CommandData command = getCommand(value);
    if (command != null) {
      var res =  await _api.execCommand(deviceId, command.id);
      return BaseData(code: res.code, msg: res.msg);
    } else {
      return BaseData(code: 500, msg: "command not found");
    }
  }

  getCommand(String value) {
    for (CommandData command in _detailSubject.value.commands) {
      if (command.value == value) {
        return command;
      }
    }
  }

  BehaviorSubject<DeviceDetailData> get detailSubject => _detailSubject;
  int get temperature => _detailSubject.value.temperature;
  set temperature(int t) {
    _detailSubject.value.temperature = t;
    _detailSubject.add(detailSubject.value);
  }

  String get power => _detailSubject.value.power;
  set curStatus(String s) {
    _detailSubject.value.power = s;
    _detailSubject.sink.add(_detailSubject.value);
  }

  String get mode => _detailSubject.value.mode;
  set mode(String name) {
    _detailSubject.value.mode = name;
    _detailSubject.sink.add(_detailSubject.value);
  }
}

final deviceDetailBloc = DeviceDetailBloc();
