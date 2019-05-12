import '../../base/http_utils.dart';

import '../models//device_data.dart';
import '../../base/base_data.dart';

class DeviceDetailApi {
  
  final String DETAIL_PATH = "/device/detail";
  final String COMMAND_PATH = "/device/command";

  getDetail(int deviceId) async {
    try {
      var resData = await IRHTTP().post(DETAIL_PATH, data: {"deviceId": deviceId});
      if (resData.statusCode == 200) {
        return DeviceDetailData.fromJson(resData.data);
      }
    } catch (error, stacktrace) {
    }
  }

  execCommand(int deviceId, int commandId) {

    BaseData baseData = new BaseData();
    try {
     var resData = IRHTTP().post(COMMAND_PATH, data: {"deviceId": deviceId, "commandId": commandId});
     if (resData.statusCode == 200) {
        baseData = BaseData(code: resData.data['code'], msg: resData.data['msg']);
     }
    } catch (error, stacktrace) {
      baseData.code = 600;
      baseData.msg = '网络异常';
    }
    return baseData;
  }
}