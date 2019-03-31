import 'dart:convert';

import 'package:flutter/material.dart';
import './index/pages/index.dart' as index;
import './index/pages/my.dart' as my;
import 'dart:io';

void main() {
  runApp(new MaterialApp(
    home: new MyTabs()
  ));
}

class MyTabs extends StatefulWidget{
  @override
  MyTabsState createState() => new MyTabsState();
}

class MyTabsState extends State<MyTabs> with SingleTickerProviderStateMixin{
  
  TabController controller;


  @override
  void initState(){
    super.initState();
    controller = new TabController(vsync: this, length: 2);
    print("initState");

    // NetworkInterface.list(includeLoopback: true, includeLinkLocal: true).then((list) {

    //  print("-------------------");
    //  print(list);
    // });

    
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(title: new Text("智能红外"), backgroundColor: Colors.blueAccent),
      bottomNavigationBar: new Material(
        color: Colors.blueAccent,
        child: new TabBar(
          controller: controller,
          unselectedLabelColor: Colors.white54,

          tabs: <Tab>[
            new Tab(text: "设备", icon: new Icon(Icons.memory)),
            new Tab(text: "我的", icon: new Icon(Icons.person))
          ]
        )
      ),
      body: new TabBarView(
        controller: controller,
        children: <Widget>[
          new index.IndexPage(),
          new my.MyPage()
        ]
      )
    );
  }
}
