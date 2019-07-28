import '../../base/http_utils.dart';

class DeviceDetailApi {
  static final String DETAIL_PATH = "/device/detail";
  static final String COMMAND_PATH = "/device/command";
  static final String DELETE_PATH = "/device/unbind";
  static final String UPDATE_NAME_PATH = "/device/updateName";

  getDetail(int deviceId) async {
    return await IRHTTP()
        .requestPost(DETAIL_PATH, data: {"deviceId": deviceId});
  }

  execCommand(int deviceId, Map status) async {
    status["deviceId"] = deviceId;
    return await IRHTTP().requestPost(COMMAND_PATH, data: status);
  }

  deleteDevice(int deviceId) async {
    return await IRHTTP()
        .requestPost(DELETE_PATH, data: {"deviceId": deviceId});
  }

  updateDeviceName(int deviceId, String name) async {
    print(name);
    print(deviceId);
    return await IRHTTP().requestPost(UPDATE_NAME_PATH,
        data: {"deviceId": deviceId, "name": name});
  }
}
