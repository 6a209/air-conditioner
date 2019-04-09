
class DeviceData {

  int code;
  String msg;
  String pk;
  String dn;
  String sk;

  DeviceData.fromJSON(Map<String, dynamic> json) {
    this.code = json['code'];
    this.msg = json['msg'];
    this.pk = json['pk'];
    this.dn = json['dn'];
    this.sk = json['sk'];
  }
}