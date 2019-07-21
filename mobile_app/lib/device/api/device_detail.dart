import '../../base/http_utils.dart';


class DeviceDetailApi {
  
  final String DETAIL_PATH = "/device/detail";
  final String COMMAND_PATH = "/device/command";

  getDetail(int deviceId) async {
     return await IRHTTP().requestPost(DETAIL_PATH, data: {"deviceId": deviceId});
  }

  execCommand(int deviceId, Map status) {
    status["deviceId"] = deviceId;
    return IRHTTP().requestPost(COMMAND_PATH, data: status);
  }
}