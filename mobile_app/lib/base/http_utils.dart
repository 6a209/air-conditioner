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

}