

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {

  String appName;
  String version;
  String url = "https://github.com/6a209/air-conditioner";

  AboutPage(String appName, String version) {
    this.appName = appName;
    this.version = version;
  } 

  @override
  Widget build(BuildContext context) {

    Container container =  Container(
      margin: EdgeInsets.only(top: 96.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/app_icon.png', height: 96, width: 96,),
          Container(
            margin: EdgeInsets.only(top: 24.0),
            child: Text(appName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold ),)),
          Container(
            margin: EdgeInsets.only(top: 4.0),
            child: Text("V$version", style: TextStyle(fontSize: 14,),),
          ),
          // Container(margin: EdgeInsets.only(top: 48.0), child: Text(url, style: TextStyle(fontSize: 14, color: Colors.black87) ,),),
          Expanded(child: Container(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Align(child: Text("Copyringht ©️ 花花吵吵闹闹科技"),alignment: Alignment.bottomCenter,),))
        ],   
      ),
    );

    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(color: Colors.black87), elevation: 0, brightness: Brightness.light, backgroundColor: Colors.white),
      body: Container(color: Colors.white,
        child: container,
      ),
    );
  }
}