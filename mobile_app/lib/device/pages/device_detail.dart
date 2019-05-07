import 'package:flutter/material.dart';
import 'package:mobile_app/device/models/device_data.dart';

class DeviceDetail extends StatefulWidget {
  final int deviceId;
  final int pid;
  String name = "空调";

  DeviceDetail({Key key, this.pid, this.deviceId, this.name}) : super(key: key);

  @override
  DeviceDetailState createState() => new DeviceDetailState();
}

class DeviceDetailState extends State<DeviceDetail> {
  DeviceDetailData deviceData;
  String curTemperatuer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: <Widget>[
          IconButton(
            icon: new Icon(Icons.more_horiz),
            onPressed: () {},
          )
        ],
      ),
      body: body(),
    );
  }

  Widget body() {
    List<Widget> list = List();
    list.add(Image.network(deviceData.detailImage));
    list.add(Container(
      margin: EdgeInsets.only(top: 64.0),
      child: Text(
        curTemperatuer,
        style: TextStyle(fontSize: 36.0, color: Color(0xff3c3c3c)),
      ),
    ));
    list.add(temperatureCtrl());
    list.add(functionCtrl());
    list.add(Container(alignment: Alignment.center,
      child: FlatButton(
        child: Text("打开"), onPressed: () {
        },
      ), 
    ));
    return Column(
      children: list,
    );
  }

  Widget temperatureCtrl() {
    return Container(
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {},
          ),
          Slider(
            value: double.parse(curTemperatuer),
            onChanged: (newValue) {},
            min: 16.0,
            max: 32,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget functionCtrl() {
    return Container(
      child: Row(
        children: <Widget>[
          FlatButton(
            child: Text("制热"),
            onPressed: () {

            },
          ),
          FlatButton(
            child: Text("制冷"),
            onPressed: () {

            },
          ),
          FlatButton(
            child: Text("通风"),
            onPressed: () {
            },
          ),

          FlatButton(
            child: Text("除湿"),
            onPressed: () {
            },
          ),

        ],
      ),
    );
  }
}
