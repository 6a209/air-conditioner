import '../../base/http_utils.dart';


class DeviceDetailApi {
  
  final String DETAIL_PATH = "/device/detail";
  final String COMMAND_PATH = "/device/command";

  getDetail(int deviceId) async {
     return await IRHTTP().requestPost(DETAIL_PATH, data: {"deviceId": deviceId});
  }

  execCommand(int deviceId, int commandId) {
     return IRHTTP().requestPost(COMMAND_PATH, data: {"deviceId": deviceId, "commandId": commandId});
  }
}