
import 'package:mobile_app/base/base_data.dart';
import 'package:mobile_app/base/base_page.dart';
import 'package:mobile_app/device/models/command_data.dart';
import 'package:mobile_app/device/models/device_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mobile_app/device/api/device_detail.dart';
import 'package:mobile_app/base/http_utils.dart';

class DeviceDetailBloc {
  final DeviceDetailApi _api = DeviceDetailApi();

  final BehaviorSubject<DeviceDetailData> _detailSubject = BehaviorSubject();
  final BehaviorSubject<BasePageState> _pageStateSubject = BehaviorSubject();


  getDetail(int deviceId) async {
     _pageStateSubject.sink.add(BasePageState.SHOW_LOADING);
     HTTPResponse response = await _api.getDetail(deviceId);
     print("*********************8");
     print(response.data);

     if (response.error != null) {
       print("if");
       _pageStateSubject.sink.add(BasePageState.SHOW_ERROR);
     } else {
       _pageStateSubject.sink.add(BasePageState.SHOW_DATA);
       DeviceDetailData detailData = DeviceDetailData.fromJson(response.data);
       print("else");
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
    BaseData data = await execCommand((temperature + 1).toString());
    if (data.code == 200) {
      temperature = temperature + 1;
    } else {

    }
  }

  execCommand(String name) async {
    int deviceId = _detailSubject.value.id;
    CommandData command = getCommand(name);
    if (command != null) {
      return await _api.execCommand(deviceId, command.id);
    } else {
      return BaseData(code: 500, msg: "command not found");
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
  int get temperature => _detailSubject.value.temperature;
  set temperature(int t) { 
    _detailSubject.value.temperature = t;
    _detailSubject.sink.add(detailSubject.value);
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


