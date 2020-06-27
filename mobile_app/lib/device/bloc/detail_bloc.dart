import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_app/base/base_data.dart';
import 'package:mobile_app/base/http_utils.dart';
import 'package:mobile_app/base/mqtt_utils.dart';
import 'package:mobile_app/base/toast.dart';
import 'package:mobile_app/device/api/device_detail.dart';
import 'package:mobile_app/device/bloc/detail_event.dart';
import 'package:mobile_app/device/models/broadcast_data.dart';
import 'package:mobile_app/device/models/command_data.dart';
import 'package:mobile_app/device/models/device_data.dart';
import 'package:mobile_app/user/user_manager.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  final DeviceDetailApi _api = DeviceDetailApi();

  bool isUpdateProperty = false;
  bool isDispose = false;
  String topic;
  Timer timer;
  int deviceId;
  int power;
  int mode;
  int temperature;
  // BuildContext context;

  DetailBloc({@required this.deviceId}) {
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
    });
  }

  @override
  DetailState get initialState => LoadingState();

  @override
  Future<void> close() async {
    super.close();
  }

  @override
  Stream<DetailState> mapEventToState(DetailEvent event) async* {
    if (event is InitEvent) {
      yield* _mapInitState(event);
    } else if (event is LoadingEvent) {
      yield LoadingState(show: event.show);
    } else if (event is AddTemperatuerEvent) {
      yield* _mapUpdateTemperatureState(event);
    } else if (event is SubTemperatureEvent) {
      yield* _mapUpdateTemperatureState(event);
    } else if (event is ChangeModeEvent) {
      yield* _mapUpdateModeState(event);
    } else if (event is PowerEvent) {
      yield* _mapUpdatePowerState(event);
    } else if (event is ChangeNameEvent) {
      yield* _mapUpdateNameState(event);
    } else if (event is DeleteDeviceEvent) {
      yield* _mapDeleteDeviceState(event);
    } else if (event is UpdateInfoEvent) {
      yield* _mapUpdateInfoState(event);
    } else if (event is ErrorEvent) {
      yield ErrorState(event.msg);
    }
  }

  Stream<DetailState> _mapInitState(InitEvent event) async* {
    isDispose = false;
    print("loadingSubject => true");
    final deviceData = await getDetail(event.deviceId);
    mode = deviceData.mode ?? MODE_COOL;
    power = deviceData.power ?? POWER_OFF;
    temperature = deviceData.temperature ?? 18;
    yield InitState(deviceData);
  }

  Stream<DetailState> _mapUpdateTemperatureState(DetailEvent event) async* {
    yield LoadingState();
    if (event is AddTemperatuerEvent) {
      await addTemperature();
    } else {
      await subTemperature();
    }
    // yield UpdateTemperatureState(event.temperature);
  }

  Stream<DetailState> _mapUpdateModeState(ChangeModeEvent event) async* {
    yield LoadingState();
    BaseData resData = await updateMode(event.mode);
    if (resData.code != 200) {
      yield ErrorState(resData.msg);
    }
  }

  Stream<DetailState> _mapUpdatePowerState(PowerEvent event) async* {
    yield LoadingState();
    BaseData resData;
    if (event.power == POWER_ON) {
      resData = await powerOn();
    } else {
      resData = await powerOff();
    }
    if (resData.code != 200) {
      yield ErrorState(resData.msg);
    }
  }

  Stream<DetailState> _mapUpdateNameState(ChangeNameEvent event) async* {
    yield LoadingState();
    HTTPResponse response = await _api.updateDeviceName(deviceId, event.name);
    if (isDispose) {
      return;
    }
    if (200 == response.code) {
      yield RenameState(event.name);
    } else {
      yield ErrorState(response.msg);
    }
  }

  Stream<DetailState> _mapDeleteDeviceState(DeleteDeviceEvent event) async* {
    yield LoadingState();
    HTTPResponse response = await _api.deleteDevice(deviceId);
    if (isDispose) {
      return;
    }
    if (200 == response.code) {
    } else {
      yield ErrorState(response.msg);
    }
  }

  Stream<DetailState> _mapUpdateInfoState(UpdateInfoEvent event) async* {
    yield UpdateInfoState(event.deviceData);
  }

  Future<DeviceDetailData> getDetail(int deviceId) async {
    DeviceDetailData detailData;
    HTTPResponse response = await _api.getDetail(deviceId);
    if (response.code != 200) {
      showToast(response.msg);
    } else {
      detailData = DeviceDetailData.fromJson(response.data);
    }
    return detailData;
  }

  updateProperty(Map jsonData) {
    power = jsonData["power"];
    mode = jsonData["mode"];
    temperature = jsonData["temperature"];

    final deviceData =
        DeviceDetailData(power: power, mode: mode, temperature: temperature);

    add(UpdateInfoEvent(deviceData));
  }

  updateMode(String mode) async {
    final value = modeValue(mode);
    return await execCommand("mode", value);
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

  Future<BaseData> powerOn() async {
    return await execCommand("power", POWER_ON);
  }

  Future<BaseData> powerOff() async {
    return await execCommand("power", POWER_OFF);
  }

  Future<BaseData> subTemperature() async {
    return await execCommand("temperature", temperature - 1);
  }

  Future<BaseData> addTemperature() async {
    return await execCommand("temperature", temperature + 1);
    // updatePropertySubject.add();
  }

  Future<BaseData> execCommand(String name, int value) async {
    if (isUpdateProperty) {
      return BaseData(code: 500, msg: "正在等上一个命令响应");
    }
    // loadingSubject.add(true);
    isUpdateProperty = true;
    // int deviceId = _detailSubject.value.id;
    var status = {};
    status['power'] = power;
    status['mode'] = mode;
    status['temperature'] = temperature;

    status[name] = value;
    var res = await _api.execCommand(deviceId, status);
    if (res.code == 200) {
      timer = Timer(Duration(seconds: 10), () {
        isUpdateProperty = false;
        // showToast("设备响应超时");
        add(ErrorEvent("设备响应超时"));
        add(LoadingEvent(show: false));
        // loadingSubject.add(false);
      });
    } else {
      isUpdateProperty = false;
      add(ErrorEvent(res.msg)); 
      add(LoadingEvent(show: false));
    }
    return BaseData(code: res.code, msg: res.msg);
  }
}
