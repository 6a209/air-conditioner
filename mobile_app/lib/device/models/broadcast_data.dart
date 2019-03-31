
class BroadcastData {

  int code;
  String msg;
  String pk;
  String dn;

  BroadcastData.fromJSON(Map<String, dynamic> json) {
    this.code = json['code'];
    this.msg = json['msg'];
    this.pk = json['pk'];
    this.dn = json['dn'];
  }
}