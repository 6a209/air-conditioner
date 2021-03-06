import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app/base/toast.dart';
import '../../base/http_utils.dart';
import '../models/index_list_data.dart';

class IndexPage extends StatefulWidget {
  @override
  IndexPageState createState() => new IndexPageState();
}

class IndexPageState extends State<IndexPage> with AutomaticKeepAliveClientMixin{
  List _listData;

  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<Null> initData() async {
    print("initData");
    var response = await IRHTTP().requestPost("/device/list");
    print(response);
    if (response.code != 200) {
      showToast(response.msg);
      return;
    }
    setState(() {
      IndexListData res = IndexListData.fromJSON(response.data);
      print(res.data);
      _listData = res.data;
    });
  }

   Future<Null> _refresh() async {
    await initData();
  }

  @override
  Widget build(BuildContext context) {
    var container = new Container(
        padding: new EdgeInsets.symmetric(horizontal: 24.0),
        color: Color(0xffEFEFEF),
        // decoration: new BoxDecoration(
        //   color: Colors.white
        // ),
        child: RefreshIndicator(
          onRefresh: _refresh,
            child: new ListView.builder(
          itemCount: _listData == null ? 0 : _listData.length,
          itemBuilder: (BuildContext context, int index) {
            IndexItem item = _listData[index];
            Widget card = new Card(
                margin: new EdgeInsets.only(top: 18.0),
                child: new Container(
                    decoration: BoxDecoration(
                        // border: new Border.all(width: 1.0, color: Color(0xffcfcfcf)),
                        // borderRadius: new BorderRadius.all(new Radius.circular(2.0)),
                        // color: Color(0xFFFFFFFF),
                        ),
                    padding: EdgeInsets.all(12.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Image.network(
                          'https://irremote-1253860771.cos.ap-chengdu.myqcloud.com/air_icon.png',
                          width: 108.0,
                        ),
                        new Container(
                          margin: EdgeInsets.only(left: 24.0),
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(item.name,
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      color: Color(0xff3c3c3c))),
                              new Container(
                                height: 6.0,
                              ),
                              new Row(
                                children: <Widget>[
                                  new Container(
                                    margin: EdgeInsets.only(right: 4.0),
                                    width: 8,
                                    height: 8,
                                    decoration: new BoxDecoration(
                                        color: item.status == 1 ? Colors.green : Colors.grey,
                                        shape: BoxShape.circle),
                                  ),
                                  new Text(
                                    item.status == 1 ? "在线" : "离线",
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: Color(0xff727272)),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    )));
            return GestureDetector(
                child: card,
                onTap: () {
                  print(item);
                  Navigator.of(context).pushNamed('/device/detail', arguments: {
                    "pid": item.productId,
                    "name": item.name,
                    "deviceId": item.deviceId
                  });
                });
          },
        )));

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("智能红外"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.of(context).pushNamed('/device/add');
            },
          )
        ],
      ),
      body: container,
    );
  }
}
