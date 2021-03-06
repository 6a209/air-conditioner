import 'package:dio/dio.dart';


class IRHTTP {
  static final IRHTTP _instance = new IRHTTP._createInstance();

  factory IRHTTP() {
    return _instance;
  }

  Dio dio = new Dio();

  IRHTTP._createInstance() {
    // dio.options.baseUrl = "http://air.6a209.club:7001";   
    dio.options.baseUrl = "http://192.168.4.215:7001";   
    dio.options.connectTimeout = 10000;
    dio.options.receiveTimeout = 15000;

    // login("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOjEsImlhdCI6MTU1NDYxNzU3NX0.ulTvboXUIneW7qVuLb3YXkOU_EANyYFwWiZ5yh7yKOk");
  }

  void login(jwtToken) {
    dio.options.headers["Authorization"] = "Bearer " + jwtToken;
  }
  
  void logout() {
    dio.options.headers["Authorization"] = "";
  }

  post(String path, {data}) async {
    var response =  await dio.post(path, data: data); 
    return response;
  }

  dynamic Function(Object) fromJson;

  requestPost(String path, {data, fromJson}) async {
    HTTPResponse httpResponse = HTTPResponse();
    print('path is => $path');
    try {
      var response =  await dio.post(path, data: data); 
      print(response);
      httpResponse.code = response.data['code'];
      httpResponse.msg = response.data['msg'];
      httpResponse.data = response.data['data'];
      print("----------------------");
      print(httpResponse.code);
      print(httpResponse.msg);
    } on DioError catch(e) {
      print("dio error");
      print(e.message);
      print(e.error);
      if(e.response != null) {
        httpResponse.code = 500;    
        httpResponse.msg = "server error";    
      } else {
        // net error
        httpResponse.error = e;
        if (e.type == DioErrorType.CONNECT_TIMEOUT || e.type == DioErrorType.RECEIVE_TIMEOUT) {
          httpResponse.msg = "连接超时";
        } else {
          httpResponse.msg = "网络异常";
        }
      }
    } on Error catch(e) {
      print(e.toString());
      print(e.stackTrace);
      httpResponse.error = e;
      httpResponse.msg = "未知异常";
    }
    return httpResponse;
  }
}

class HTTPResponse {
  var error; 
  var data;
  String msg;
  int code;

  HTTPResponse({this.error, this.data, this.msg, this.code});
}