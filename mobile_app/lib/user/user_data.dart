

// 暂时不支持微信登入，（微信登入需要企业账号注册）
class UserData {
  String nickname;
  String headimgurl;
  String mobile;
  String topic;
  String token;

  UserData({this.nickname, this.headimgurl, this.mobile, this.topic});

  UserData.fromJSON(Map<String, dynamic> json) {
    this.nickname = json['nickname'];  
    this.headimgurl = json['headimgurl'];
    this.mobile = json['mobile'];
    this.topic = json['topic'];
    this.token = json['token'];
  }
}