import 'package:flutter/material.dart';
import 'package:mobile_app/device/models/device_data.dart';
import '../bloc/device_detail_bloc.dart';

class DeviceDetail extends StatefulWidget {
  final int deviceId;
  final int pid;
  String name = "空调";

  DeviceDetail({Key key, this.pid, this.deviceId, this.name}) : super(key: key);

  @override
  DeviceDetailState createState() => new DeviceDetailState();
}

class DeviceDetailState extends State<DeviceDetail> {

  @override
  void initState() {
    super.initState();
    deviceDetailBloc.getDetail(widget.deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DeviceDetailData>(
      stream: deviceDetailBloc.detailSubject.stream,
      builder: (context, AsyncSnapshot<DeviceDetailData> snapshot) {
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
          body: body(snapshot.data),
        );
      },
    );
  }

  Widget body(DeviceDetailData deviceData) {
    List<Widget> list = List();
    list.add(Image.network(deviceData.detailImage));
    list.add(Container(
      margin: EdgeInsets.only(top: 64.0),
      child: Text(
        deviceData.curTemperatuer,
        style: TextStyle(fontSize: 36.0, color: Color(0xff3c3c3c)),
      ),
    ));
    list.add(temperatureCtrl(deviceData));
    list.add(functionCtrl(deviceData));
    list.add(Container(
      alignment: Alignment.center,
      child: FlatButton(
        child: Text("打开"),
        onPressed: () {},
      ),
    ));
    return Column(
      children: list,
    );
  }

  Widget temperatureCtrl(DeviceDetailData deviceData) {
    return Container(
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {},
          ),
          Slider(
            value: double.parse(deviceData.curTemperatuer),
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

  Widget functionCtrl(DeviceDetailData deviceData) {
    String hot = "制热";
    String cold = "制冷";
    String wind = "通风";
    String wet = "除湿";
    return Container(
      child: Row(
        children: <Widget>[
          FlatButton(
            child: Text(hot),
            onPressed: () {
              deviceDetailBloc.execCommand(hot);
            },
          ),
          FlatButton(
            child: Text(cold),
            onPressed: () {
              deviceDetailBloc.execCommand(cold);
            },
          ),
          FlatButton(
            child: Text(wind),
            onPressed: () {
              deviceDetailBloc.execCommand(wind);
            },
          ),
          FlatButton(
            child: Text(wet),
            onPressed: () {
              deviceDetailBloc.execCommand(wet);
            },
          ),
        ],
      ),
    );
  }
}
