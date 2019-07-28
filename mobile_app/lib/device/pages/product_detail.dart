import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app/base/mqtt_utils.dart';
import 'package:mobile_app/user/user_manager.dart';
import 'dart:convert';
import '../models/command_data.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../base/http_utils.dart';

import '../../base/toast.dart';

class ProductDetail extends StatefulWidget {
  final int pid;
  String name = "空调";

  ProductDetail({Key key, this.pid, this.name}) : super(key: key);

  @override
  ProductDetailState createState() => new ProductDetailState();
}

class ProductDetailState extends State<ProductDetail> {
  // ProductDetailData productDetailData;
  String currentCommandValue = "";
  CommandsData commandsData = new CommandsData(data: List());
  TextEditingController nameController = TextEditingController();
  bool isUpdate = false;
  String topic;

  // final MqttClient client = MqttClient("192.168.4.92", '');

  @override
  void initState() {
    super.initState();
    String userTopic = UserManager.instance().topic;
    topic = "user/$userTopic/study"; 
    initMqtt();
    initData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initMqtt() {
    MqttManager.instance().messageSubject.where((MqttData data) {

      if (data.topic == topic) {
        return true;
      }
    }).listen((MqttData data) {
      print("mqtt irdata");
      List jsonData = jsonDecode(data.message)['data'] as List;
      print("lenght -->>>");
      print(jsonData.length);
      String irData = jsonEncode(jsonData);
      updateIRData(irData);
    });
  }

  void updateIRData(String irdata) {
    setState(() {
      for (CommandData command in commandsData.data) {
        if (command.value == currentCommandValue) {
          command.irdata = irdata;
        }
      }
    });
    cancelWait();
  }

  initData() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('config/airconditioner.json');
    CommandsData commandsRes = CommandsData();
    try {
      var response = await IRHTTP()
          .post('/product/detail', data: {"productId": widget.pid});
      print("prodcut/detail");
      commandsRes = CommandsData.fromJson(response.data);
    } catch (e) {
      print(e.toString());
    }

    print(commandsRes.code);

    if (commandsRes.code == 200 && commandsRes.data.length > 0) {
      isUpdate = true;
      setState(() {
        this.commandsData = commandsRes;
      });
    } else {
      setState(() {
        this.commandsData = CommandsData.fromJson(jsonDecode(data));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("产品详情"),
        backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          FlatButton(
            child: Text(
              "保存",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              saveIRData();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(children: buildDetailData()),
        ),
      ),
    );
  }

  saveIRData() async {
    String path = '/product/commands/create';
    if (isUpdate) {
      path = '/product/commands/update';
    }
    var commandMap = this.commandsData.toJson();
    commandMap.remove("code");
    commandMap.remove("msg");
    print(commandMap);
    await IRHTTP().post(path,
        data: {'productId': this.widget.pid, 'commands': commandMap['data']});
    showToast("保存成功");
    new Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  List<Widget> buildDetailData() {
    List<Widget> listWidget = List();
    nameController.text = "901 空调";
    Column column = new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("产品名称",
            style: TextStyle(
                color: Color(0xff3c3c3c),
                fontSize: 18.0,
                fontWeight: FontWeight.bold)),
        Divider(
          height: 1,
          color: Color(0x7f727272),
        ),
        Container(
            margin: EdgeInsets.only(top: 12.0),
            child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
//            borderSide: BorderSide(color: Colors.red, width: 3.0, style: BorderStyle.solid)//没什么卵效果
                    )))),
      ],
    );

    Container nameContainer = new Container(
      margin: EdgeInsets.only(top: 12.0),
      child: column,
    );
    listWidget.add(nameContainer);

    var columnChild = List<Widget>();
    for (CommandData row in commandsData.data) {
      Widget rowWidget = buildRow(row.value, row.irdata);
      columnChild.add(rowWidget);
    }
    Column commandColumn = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnChild,
    );
    Container groupContainer = new Container(
      margin: EdgeInsets.only(top: 18.0),
      child: commandColumn,
    );

    listWidget.add(groupContainer);
    return listWidget;
  }

  Widget buildRow(String value, String data) {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 16.0),
          child: Text(
            value,
            style: TextStyle(color: Color(0xff727272)),
          ),
        ),
        Expanded(child: Text(data, overflow: TextOverflow.ellipsis)),
        FlatButton(
          child: Text("学习", style: TextStyle(color: Colors.white)),
          color: Colors.blueAccent,
          onPressed: () {
            currentCommandValue = value;
            waitDialog();
          },
        )
      ],
    );
  }

  waitDialog() {
    MqttManager.instance().subscribe(topic, MqttQos.atMostOnce);

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
    MqttManager.instance().unsubscribe(topic);
  }
}

class CountDownDialog extends StatefulWidget {
  var countDownFinish;

  CountDownDialog({Key key, this.countDownFinish}) : super(key: key);

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
        // padding: EdgeInsets.all(24.0),
        child: Text(
          countDownSecond.toString(),
          style: TextStyle(
              fontSize: 48.0,
              color: Color(0xff727272),
              fontWeight: FontWeight.bold),
        ));
  }
}
