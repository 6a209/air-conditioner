import 'package:flutter/material.dart';
import 'package:mobile_app/base/toast.dart';
import 'package:mobile_app/user/user_manager.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {

  TextEditingController nameController = TextEditingController();
  TextEditingController passwdController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Column column = new Column(
      children: <Widget>[
        // show icon
        // Image.asset(name)
        Expanded(
            flex: 1,
            child: Text(
              "智能空调",
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            )),
        Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.only(bottom: 60),
              padding: EdgeInsets.only(left: 32, right: 32),
              alignment: Alignment.bottomLeft,
              child: loginForm(),
            )),
      ],
    );

    return Scaffold(
      body: Container(
        child: column,
        padding: EdgeInsets.all(24),
        margin: EdgeInsets.only(top: 128),
      ),
    );
  }

  Widget loginForm() {
    return Container(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          // login
          controller: nameController,
          decoration: InputDecoration(
            hintText: "用户名",
            prefixIcon: Icon(Icons.face),
          ),
        ),
        TextField(
          controller: passwdController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "密码",
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 8),
            child: SizedBox(
                width: double.infinity,
                child: FlatButton(
                  color: Colors.blueAccent,
                  child: Text("登入", style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    bool result = await UserManager.instance().login(nameController.text, passwdController.text);
                    if (result) {
                      Navigator.of(context).popAndPushNamed('/index', arguments: {});
                    }
                  },
                ))),
        FlatButton(
          child: Text("注册"),
          onPressed: () {
            showToast("暂时不开放注册，请联系开发版卖家提供账号");
          },
        )
      ],
    ));
  }
}
