import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app/user/user_data.dart';
import 'package:mobile_app/user/user_manager.dart';

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => new RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController captchaController = TextEditingController();

  Container captchaContainer;

  CaptchaData captchaData;
  String captchaKey;
  String svgData = "";

  @override
  void initState() {
    super.initState();
    _requestCaptcha();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(
          "注册",
          style: TextStyle(),
        ),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    Widget body = Container(
      padding: EdgeInsets.all(24.0),
      margin: EdgeInsets.only(bottom: 96.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "用户名",
              prefixIcon: Icon(Icons.face),
            ),
          ),
          TextField(
            controller: mobileController,
            decoration: InputDecoration(
              hintText: "手机号",
              prefixIcon: Icon(Icons.phone_android),
            ),
          ),
          TextField(
            obscureText: true,
            controller: passwdController,
            decoration:
                InputDecoration(hintText: "密码", prefixIcon: Icon(Icons.lock)),
          ),
          _captchaLayout(),
          Container(
              margin: EdgeInsets.only(top: 36),
              width: double.infinity,
              child: FlatButton(
                color: Colors.blueAccent,
                child: Text("注册", style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  bool result = await UserManager.instance().register(
                    nameController.text,
                    mobileController.text,
                    passwdController.text,
                    captchaController.text,
                    captchaKey);
                  if (result) {
                    Navigator.of(context).popAndPushNamed('/index', arguments: {});
                  }
                },
              )),
        ],
      ),
    );

    return body;
  }

  Widget _captchaLayout() {
    Row row = Row(
      children: <Widget>[
        Expanded(
            flex: 2,
            child: TextField(
                controller: captchaController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.casino),
                  hintText: "验证码",
                ))),
        Expanded(
            flex: 1,
            child: GestureDetector(
              child: Container(
                child: SvgPicture.string(svgData),
              ),
              onTap: () {
                _requestCaptcha();
              },
            ))
      ],
    );
    return row;
  }

  // Widget _getCaptcha() {
  //   // final DrawableRoot svgRoot = await svg.fromSvgString(captchaData.data, captchaData.data);
  //   // String svgData = captchaData?.data;
  //   // svgData ??= "";
  //   // return SvgPicture.string(svgData);
  // }

  _requestCaptcha() async {
    captchaData = await UserManager.instance().requestCaptcha();
    captchaKey = captchaData.key; 
    setState(() {
      svgData = captchaData?.data;
    });
  }
}
