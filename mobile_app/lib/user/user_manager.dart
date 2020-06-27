import 'dart:async';
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:mobile_app/base/http_utils.dart';
import 'package:mobile_app/base/toast.dart';
import 'package:mobile_app/user/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class UserManager {
  factory UserManager.instance() => _shareInstance();

  static UserManager _instance;

  static UserManager _shareInstance() {
    if (_instance == null) {
      _instance = UserManager._();
    }
    return _instance;
  }

  bool _isLogin = false;
  UserData userData;

  final String IS_LOGIN_KEY = "is_login";
  final String HEAD_IMG_KEY = "head_img";
  final String NAME_KEY = "name";
  final String TOPIC_KEY = "topic";
  final String TOKEN_KEY = "token";

  UserManager._() {
    init();
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLogin = prefs.getBool(IS_LOGIN_KEY) ?? false;
    if (_isLogin) {
      String headimg = prefs.getString(HEAD_IMG_KEY);
      String name = prefs.getString(NAME_KEY);
      String topic = prefs.getString(TOPIC_KEY);
      String token = prefs.getString(TOKEN_KEY);
      IRHTTP().login(token);
      userData = UserData(headimgurl: headimg, nickname: name, topic: topic);
    }
  }

  String get topic => userData.topic; 
  String get name => userData.nickname;
  String get avatar => userData.headimgurl;
  

  Future<bool> login(String mobile, String password) async {
    print(mobile);
    if (mobile.isEmpty) {
      showToast("用户名不能为空");
      return false;
    }
    if (password.isEmpty) {
      showToast("密码不能为空");
      return false;
    }

    password = _md5(password);
    var response = await IRHTTP()
        .requestPost("/login", data: {"mobile": mobile, "password": password});
    if (response.code == 200) {
      userData = UserData.fromJSON(response.data);
      _parseLogin(userData);
      return true;
    } else {
      showToast(response.msg);
      return false;
    }
  }

  void _parseLogin(UserData userData) {
    _isLogin = true;
    _setString(HEAD_IMG_KEY, userData.headimgurl);
    _setString(NAME_KEY, userData.nickname);
    _setString(TOPIC_KEY, userData.topic);
    _setString(TOKEN_KEY, userData.token);
    _setBool(IS_LOGIN_KEY, _isLogin);
    IRHTTP().login(userData.token);
  }

  requestCaptcha() async {
    var response = await IRHTTP().requestPost("/captcha");
    if (200 == response.code) {
      CaptchaData captchaData = CaptchaData.fromJSON(response.data);
      return captchaData; 
    }
  }

  Future<bool> register(String nickname, String mobile, String password, String captcha, String captchaKey) async {

    if (nickname.isEmpty) {
      showToast("用户名不能为空");
      return false;
    }

    if (mobile.isEmpty) {
      showToast("手机号码不能为空");
      return false;
    }

    if (password.isEmpty) {
      showToast("密码不能为空");
      return false;
    }

    if (captcha.isEmpty) {
      showToast("验证码不能为空");
      return false;
    }

    password = _md5(password);

    var params = {
      "mobile": mobile,
      "password": password,
      "captcha": captcha,
      "captchaKey": captchaKey,
      "nickname": nickname
    };
    var response = await IRHTTP().requestPost("/register", data: params);
    if (200 == response.code) {
      userData = UserData.fromJSON(response.data);
      _parseLogin(userData);
      return true;
    } else {
      showToast(response.msg);
    }
    return false;
  }

  void logout() async {
    _isLogin = false;
    IRHTTP().logout();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  bool isLogin() {
    return _isLogin;
  }

  String _md5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  void _setString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  void _setBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<String> _getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
