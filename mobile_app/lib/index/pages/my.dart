import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/index/models/my_action_data.dart';
import 'package:mobile_app/user/user_manager.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPage extends StatefulWidget {
  @override
  MyPageState createState() => new MyPageState();
}

class MyPageState extends State<MyPage> with AutomaticKeepAliveClientMixin {
  List<MyActionData> _listData;
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    //     SystemUiOverlayStyle style = SystemUiOverlayStyle(
    //     statusBarIconBrightness: Brightness.dark);
    // SystemChrome.setSystemUIOverlayStyle(style);
    _listData = new List();

    var product = MyActionData(text: "我的产品", icon: Icons.apps, url: "xxxx");
    var feedback = MyActionData(
        text: "反馈",
        icon: Icons.forum,
        url: "mailto:6a209qt@gmail.com?subject=智能红外");
    var about = MyActionData(text: "关于", icon: Icons.info, url: "xxxx");

    // _listData.add(product);
    _listData.add(feedback);
    _listData.add(about);
  }

  @override
  Widget build(BuildContext context) {
    BorderSide border = BorderSide(
        width: 1, style: BorderStyle.solid, color: Color(0xffE0E0E0));
    final container = new Container(
        // padding: EdgeInsets.all(48),
        decoration: BoxDecoration(color: Color(0xffEFEFEF)),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: EdgeInsets.fromLTRB(24, 64, 48, 36),
                decoration: BoxDecoration(
                    color: Colors.white, border: Border(bottom: border)),
                child: new Row(
                  children: <Widget>[
                    new Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: _avatar(), fit: BoxFit.cover),
                          shape: BoxShape.circle),
                    ),
                    new Container(
                      margin: EdgeInsets.only(left: 16),
                      child: Text(
                        UserManager.instance().name,
                        style: new TextStyle(
                            fontSize: 18, color: Color(0xff3c3c3c)),
                      ),
                    )
                  ],
                )),
            Container(
              margin: EdgeInsets.only(top: 12.0),
              decoration: BoxDecoration(
                  color: Colors.white, border: Border(top: border)),
              child: _buildItemList(context),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              margin: EdgeInsets.only(top: 12.0),
              child: FlatButton(
                child: Text("退出登入",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xff3c3c3c),
                    )),
                onPressed: () {
                  UserManager.instance().logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login', (Route<dynamic> route) => false);
                },
              ),
            )
          ],
        ));
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(
          elevation: 0,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
        ),
      ),
      body: container,
    );
  }

  _avatar() {
    if (null != UserManager.instance().avatar) {
      return NetworkImage(UserManager.instance().avatar);
    } else {
      return AssetImage("assets/default_avatar.png");
    }
  }

  Widget _buildItemList(BuildContext context) {
    List<Widget> listWidget = new List();

    for (var i = 0; i < _listData.length; i++) {
      var itemData = _listData[i];
      var container = new Container(
          height: 64,
          alignment: AlignmentDirectional.centerStart,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 1.0,
                      color: i == _listData.length - 1
                          ? Color(0xffffff)
                          : Color(0xffE0E0E0),
                      style: BorderStyle.solid))),
          child: Row(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(left: 24),
                  child: Icon(
                    itemData.icon,
                    color: Color(0xff727272),
                  )),
              Expanded(
                child: Container(
                    margin: EdgeInsets.only(left: 12.0),
                    child: Text(
                      itemData.text,
                      style:
                          TextStyle(fontSize: 16.0, color: Color(0xff3c3c3c)),
                    )),
              ),
              Container(
                  margin: EdgeInsets.only(right: 16.0),
                  child: Icon(
                    Icons.keyboard_arrow_right,
                    color: Color(0xff727272),
                  ))
            ],
          ));

      var itemWidget = GestureDetector(
        onTap: () {
          itemTap(itemData.text, itemData.url);
        },
        child: container,
      );

      listWidget.add(itemWidget);
    }
    return new Column(
      children: listWidget,
    );
  }

  void itemTap(String name, String url) async {
    if (name == "反馈") {
      await launch("mailto:6a209qt@gmail.com?subject=智能红外");
    } else if (name == "我的产品") {
      Navigator.of(context).pushNamed('/product', arguments: {"deviceId": -1});
    } else if (name == "关于") {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appName = "智能空调";
      String version = packageInfo.version;
      print("---------");
      print(appName);
      print(version);
      Navigator.of(context).pushNamed('/about',
          arguments: {"appName": appName, "version": version});
    }
  }
}
