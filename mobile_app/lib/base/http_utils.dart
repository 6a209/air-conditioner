import 'package:dio/dio.dart';


class IRHTTP {
  static final IRHTTP _instance = new IRHTTP._createInstance();

  factory IRHTTP() {
    return _instance;
  }

  Dio dio = new Dio();

  IRHTTP._createInstance() {
    dio.options.baseUrl = "http://127.0.0.1:7001";   
    dio.options.connectTimeout = 10000;
    dio.options.receiveTimeout = 15000;

    login("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOjEsImlhdCI6MTU1NDYxNzU3NX0.ulTvboXUIneW7qVuLb3YXkOU_EANyYFwWiZ5yh7yKOk");
  }

  void login(jwtToken) {
    dio.options.headers["Authorization"] = jwtToken;
  }
  
  void logout() {
    dio.options.headers["Authorization"] = "";
  }

  post(String path, {data}) async {
    var response =  await dio.post(path, data: data); 
    return response;
  }

  requestPost(String path, {data}) async {
    HTTPResponse httpResponse = HTTPResponse();
    try {
      var response =  await dio.post(path, data: data); 
      httpResponse.code = response.data['code'];
      httpResponse.msg = response.data['msg'];
      httpResponse.data = response.data['data'];
      print("----------------------");
      print(httpResponse.data);
    } on DioError catch(e) {
      print("dio error");
      if(e.response != null) {
        httpResponse.code = e.response.data['code'];    
        httpResponse.msg = e.response.data['msg'];    
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
      httpResponse.error = e;
      httpResponse.msg = "未知异常";
    }
    return httpResponse;
  }
}

class HTTPResponse {
  Error error; 
  var data;
  String msg;
  int code;

  HTTPResponse({this.error, this.data, this.msg, this.code});
}