import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/product_data.dart';
import '../models/command_data.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../base/http_utils.dart';

class ProductDetail extends StatefulWidget {
  final int pid;
  String name = "空调";

  ProductDetail({Key key, this.pid, this.name})
      : super(key: key);

  @override
  ProductDetailState createState() => new ProductDetailState();
}

class ProductDetailState extends State<ProductDetail> {
  ProductDetailData productDetailData;
  String currentCommandName = "";
  CommandsData commandsData = new CommandsData(commands: List());
  TextEditingController nameController = TextEditingController();
  bool isUpdate = false;

  final MqttClient client = MqttClient("192.168.4.92", '');

  @override
  void initState() {
    super.initState();

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

    initData();
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
        String message =
            MqttPublishPayload.bytesToStringAsString(mpm.payload.message);
        String irData = jsonEncode(jsonDecode(message)['data']);
        print(irData);
        updateIRData(irData);
      }
    });
  }

  void updateIRData(String irdata) {
    for (CommandData command in commandsData.commands) {
      if (command.name == currentCommandName) {
        command.irdata = irdata;
      }
    }
    setState(() {
      for (ProductGroup group in productDetailData.groups) {
        for (ProductRow row in group.rows) {
          if (row.name == currentCommandName) {
            row.data = irdata;
          }
        }
      }
    });
    cancelWait();
  }

  initData() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('config/airconditioner.json');
    List<dynamic> listData = jsonDecode(data) as List;
    setState(() {
      this.productDetailData = ProductDetailData.fromJSON(listData);
    });
    CommandsData commandsRes = CommandsData();
    try {
      var response =
        await IRHTTP().post('/product/detail', data: {"productId": widget.pid});
      print("prodcut/detail");
      commandsRes = CommandsData.fromJson(response.data);
    } catch (e){
      print(e.toString());
    }

    print(commandsRes.code);
    print(commandsRes.commands);

    if (commandsRes.code == 200 && commandsRes.commands.length > 0) {
      isUpdate = true;
      setState(() {
        this.commandsData = commandsRes;
        var map = Map();
        for (CommandData command in commandsData.commands) {
          map[command.name] = command.irdata;
        }
        print(map);

        for (ProductGroup group in productDetailData.groups) {
          for (ProductRow row in group.rows) {
            row.data = map[row.name];
          }
        }
      });
    } else {
        for (ProductGroup group in productDetailData.groups) {
          for (ProductRow row in group.rows) {
            this.commandsData.commands.add(CommandData(name: row.name, id: -1, irdata: ""));
          }
        }
 
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
    print(widget.pid);
    var commandMap = this.commandsData.toJson();
    commandMap.remove("code");
    commandMap.remove("msg");
    var jsonStr = json.encode(commandMap);
    print(jsonStr);
    await IRHTTP().post(path, data: {
      'productId': this.widget.pid,
      'commands': commandMap['commands']
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
      Container groupContainer = new Container(
        margin: EdgeInsets.only(top: 18.0),
        child: column,
      );

      listWidget.add(groupContainer);
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
