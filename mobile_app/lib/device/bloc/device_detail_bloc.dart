
import 'package:mobile_app/base/base_data.dart';
import 'package:mobile_app/device/models/command_data.dart';
import 'package:mobile_app/device/models/device_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mobile_app/device/api/device_detail.dart';

class DeviceDetailBloc {
  final DeviceDetailApi _api = DeviceDetailApi();

  final BehaviorSubject<DeviceDetailData> _detailSubject = BehaviorSubject();


  getDetail(int deviceId) async {
     DeviceDetailData detailData = _api.getDetail(deviceId);
     _detailSubject.sink.add(detailData);
  }

  subTemperature() async {
    BaseData data = await execCommand((curTemperature - 1).toString());
    if (data.code == 200) {
      curTemperature = curTemperature - 1;
    }
  }

  addTemperature() async {
    BaseData data = execCommand((curTemperature + 1).toString());
    if (data.code == 200) {
      curTemperature = curTemperature + 1;
    }
  }

  execCommand(String name) async {
    int deviceId = _detailSubject.value.id;
    CommandData command = getCommand(name);
    if (command != null) {
      return await _api.execCommand(deviceId, command.id);
    }
  }

  getCommand(String name) {
    for (CommandData command in _detailSubject.value.commands) {
      if (command.name == name) {
        return command;  
      } 
    } 
  } 

  BehaviorSubject<DeviceDetailData> get detailSubject => _detailSubject;
  int get curTemperature => _detailSubject.value.curTemperature;
  set curTemperature(int t) { 
    _detailSubject.value.curTemperature = t;
    _detailSubject.sink.add(detailSubject.value);
  }

  int get curStatus => _detailSubject.value.curStatus; 
  set curStatus(int s) { 
    _detailSubject.value.curStatus = s;
    _detailSubject.sink.add(_detailSubject.value);
 } 

  String get curModeName => _detailSubject.value.curModeName; 
  set curModeName(String name) {
    _detailSubject.value.curModeName = name;
    _detailSubject.sink.add(_detailSubject.value);
  } 

}

final deviceDetailBloc = DeviceDetailBloc();


