import 'dart:convert';

import 'package:flutter/material.dart';
import './index/pages/index.dart' as index;
import './index/pages/my.dart' as my;
import './device/pages/bind_device.dart';
import './device/pages/product_list.dart';
import './device/pages/product_detail.dart';
import 'package:fluro/fluro.dart';
import 'dart:io';

void main() {
  final router = Router();
  Object a;
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
        home: new MyTabs(),
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == '/device/add') {
            return MaterialPageRoute(builder: (context) => BindPage());
          } else if (settings.name == '/product') {
            Map argu = settings.arguments;
            return MaterialPageRoute(
              builder: (context) =>
                new ProductList(deviceId: argu['deviceId']));
          } else if (settings.name == '/product/detail') {
            return MaterialPageRoute(builder: (context) => new ProductDetail());
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
      bottomNavigationBar: new Material(
          color: Colors.blueAccent,
          child: new TabBar(
              controller: controller,
              unselectedLabelColor: Colors.white54,
              tabs: <Tab>[
                new Tab(text: "设备", icon: new Icon(Icons.memory)),
                new Tab(text: "我的", icon: new Icon(Icons.person))
              ])),
      body: new TabBarView(
          controller: controller,
          children: <Widget>[new index.IndexPage(), new my.MyPage()]),
    );
  }
}
