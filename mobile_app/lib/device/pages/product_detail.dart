import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/product_data.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../base/http_utils.dart';

class ProductDetail extends StatefulWidget {
  final int deviceId;
  final int pid;
  String name = "空调";

  ProductDetail({Key key, this.pid, this.deviceId, this.name}) : super(key: key);

  @override
  ProductDetailState createState() => new ProductDetailState();
}

class ProductDetailState extends State<ProductDetail> {
  ProductDetailData productDetailData;
  String currentCommandName = "";

  final MqttClient client = MqttClient("192.168.4.92", '');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
    client.onConnected = onMqttConnected;
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .keepAliveFor(20) // Must agree with the keep alive set above or not set
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;
    client.connect();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onMqttConnected() {
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttReceivedMessage recMess = c[0];
      if (recMess.topic == "user/6a209/study") {
        final MqttPublishMessage mpm = recMess.payload;
        String pt =
            MqttPublishPayload.bytesToStringAsString(mpm.payload.message);
        print(pt);
        
      }
    });
  }

  initData() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('config/airconditioner.json');
    List<dynamic> listData = jsonDecode(data) as List;
    setState(() {
      this.productDetailData = ProductDetailData.fromJSON(listData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text("空调"), backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          FlatButton(child: Text("保存", style: TextStyle(color: Colors.white),), onPressed: () {
            //  IRHTTP().post('/device/createCommand')
          },)
        ],),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(children: buildDetailData()),
        ),
      ),
    );
  }

  List<Widget> buildDetailData() {
    List<Widget> listWidget = List();
    if (null == productDetailData) {
      return listWidget;
    }
    for (ProductGroup groupData in productDetailData.groups) {
      List<Widget> columnChild = List();
      columnChild.add(Text(
        groupData.title,
        style: TextStyle(
            color: Color(0xff3c3c3c),
            fontSize: 18.0,
            fontWeight: FontWeight.bold),
      ));
      columnChild.add(Divider(
        height: 1,
        color: Color(0x7f727272),
      ));

      for (ProductRow row in groupData.rows) {
        Widget rowWidget = buildRow(row.name, row.data);
        columnChild.add(rowWidget);
      }
      Column column = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChild,
      );
      listWidget.add(column);
    }
    return listWidget;
  }

  Widget buildRow(String name, String data) {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 16.0),
          child: Text(
            name,
            style: TextStyle(color: Color(0xff727272)),
          ),
        ),
        Expanded(child: Text(data, overflow: TextOverflow.ellipsis)),
        FlatButton(
          child: Text("学习", style: TextStyle(color: Colors.white)),
          color: Colors.blueAccent,
          onPressed: () {
            currentCommandName = name;
            waitDialog();
          },
        )
      ],
    );
  }

  waitDialog() {
    client.subscribe("user/6a209/study", MqttQos.exactlyOnce);

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, state) {
              return AlertDialog(
                title: new Text("等待红外信号"),
                content: CountDownDialog(countDownFinish: this.cancelWait),
                actions: <Widget>[
                  FlatButton(
                    child: Text("取消"),
                    onPressed: () {
                      cancelWait();
                    },
                  )
                ],
              );
            },
          );
        });
  }

  void cancelWait() {
    Navigator.pop(context);
    client.unsubscribe("user/6a209/study");
  }
}


class CountDownDialog extends StatefulWidget {

  var countDownFinish;

  CountDownDialog({
    Key key, this.countDownFinish
  }) : super (key: key);

  @override
  CountDownState createState() => new CountDownState();

}

class CountDownState extends State<CountDownDialog> {
  int countDownSecond = 60;
  Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      setState(() {
        countDownSecond = countDownSecond - 1;
        if (countDownSecond <= 0) {
          countDownSecond = 0;
          timer.cancel();
          widget.countDownFinish();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _countdownTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {

    return new Container(
        alignment: Alignment.center,
        height: 72.0,
        padding: EdgeInsets.all(24.0),
        child: Text(
          countDownSecond.toString(),
          style: TextStyle(
              fontSize: 48.0,
              color: Color(0xff727272),
              fontWeight: FontWeight.bold),
        ));
  }
}
