import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_app/base/mqtt_utils.dart';
import 'package:mobile_app/device/pages/brand_list.dart';
import 'package:mobile_app/device/pages/brand_mode.dart';
import 'package:mobile_app/index/pages/about.dart';
import 'package:mobile_app/user/login.dart';
import 'package:mobile_app/user/user_manager.dart';
import './index/pages/index.dart' as index;
import './index/pages/my.dart' as my;
import './device/pages/bind_device.dart';
import './device/pages/product_list.dart';
import './device/pages/product_detail.dart';
import 'package:fluro/fluro.dart';
import './device/pages/device_detail.dart';
import 'dart:io';

void main() async {
  // final router = Router();
  // Object a;

  MqttManager.instance().init();
  await UserManager.instance().init();

  runApp(MyApp());
  // initialRoute: '/',
  // routes: <String, WidgetBuilder> {
  //   '/index': (BuildContext context) => new index.IndexPage(),
  //   '/device/add': (BuildContext context) => new BindPage(),
  //   '/product': (BuildContext context) => new ProductList(),
  // },
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        color: Color(0xFFFF00BF),
        home: UserManager.instance().isLogin() ? MyTabs() : LoginPage(),
        onGenerateRoute: (RouteSettings settings) {
          Map argu = settings.arguments;
          print(argu);
          if (settings.name == '/device/add') {
            return MaterialPageRoute(builder: (context) => BindPage());
          } else if (settings.name == '/product') {
            return MaterialPageRoute(
                builder: (context) =>
                    new ProductList(deviceId: argu['deviceId']));
          } else if (settings.name == '/product/detail') {
            return MaterialPageRoute(
                builder: (context) =>
                    new ProductDetail(pid: argu['pid'], name: argu['name']));
          } else if (settings.name == '/device/detail') {
            return MaterialPageRoute(
                builder: (context) => new DeviceDetailPage(
                      pid: argu['pid'],
                      deviceId: argu['deviceId']
                    ));
          } else if (settings.name == '/index') {
            return MaterialPageRoute(builder: (context) => new MyTabs());
          } else if (settings.name == '/login') {
            return MaterialPageRoute(builder: (context) => new LoginPage());
          } else if (settings.name == '/brand') {
            return MaterialPageRoute(builder: (context) => new BrandPage(argu["pk"], argu["dn"]));
          } else if (settings.name == '/brand/mode') {
            return MaterialPageRoute(builder: (context) => new BrandModePage(argu['name'], argu['brandId'], argu["pk"], argu["dn"]));
          } else if (settings.name == '/about') {
            return MaterialPageRoute(
                builder: (context) =>
                    new AboutPage(argu['appName'], argu['version']));
          }
        });
  }
}

void initRouter(Router router) {
  router.define('/device/add', handler:
      Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return BindPage();
  }));
}

class MyTabs extends StatefulWidget {
  @override
  MyTabsState createState() => new MyTabsState();
}

class MyTabsState extends State<MyTabs> with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 2);
    print("initState");

    // NetworkInterface.list(includeLoopback: true, includeLinkLocal: true).then((list) {

    //  print("-------------------");
    //  print(list);
    // });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: SizedBox(
          height: 60.0,
          child: new Material(
              color: Colors.white,
              child: new TabBar(
                  controller: controller,
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.blueAccent,
                  unselectedLabelColor: Colors.black38,
                  tabs: <Tab>[
                    new Tab(text: "设备", icon: new Icon(Icons.memory)),
                    new Tab(text: "我的", icon: new Icon(Icons.person))
                  ]))),
      body: new TabBarView(
          controller: controller,
          children: <Widget>[new index.IndexPage(), new my.MyPage()]),
    );
  }
}
