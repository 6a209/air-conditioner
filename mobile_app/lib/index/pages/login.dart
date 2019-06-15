import 'package:flutter/material.dart';
import 'package:mobile_app/base/toast.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {

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
        Text("智能空调", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),

      ],
    );

    return Container(
    );
  }

  Widget loginForm() {
    return Container(
        child: Column(
          children: <Widget>[
            TextField(
              // login
              decoration: InputDecoration(
                hintText: "用户名",
                prefixIcon: Icon(Icons.face),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "密码",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            FlatButton(
              color: Colors.blueAccent,
              child: Text("登入", style: TextStyle(color: Colors.white)), onPressed: () {

              },
            ),
            FlatButton(
              child: Text("注册"), onPressed: () {
                showToast("暂时不开放注册，请联系开发版卖家提供账号");
              },
            )
          ],
        )
    ); 
  }
}