
import 'dart:async';

import 'package:mobile_app/base/toast.dart';

import 'http_utils.dart';

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

  UserManager._() {
  }

  Future<bool> login() async{
   var response = await IRHTTP().requestPost("/login");
   if (response.code == 200) {
    //  IRHTTP().login(jwtToken)
    _isLogin = true;
    return true;
   } else {
     showToast(response.msg);
     return false;
   }
  }

  void logout() {
    _isLogin = false;
  }

  bool isLogin() {
    return _isLogin;
  }
}