import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_app/base/base_page.dart';

import 'package:mobile_app/device/models/device_data.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../bloc/device_detail_bloc.dart';
import 'package:mobile_app/base/base_widget.dart';

class DeviceDetailPage extends StatefulWidget {
  final int deviceId;
  final int pid;
  String name = "空调";

  DeviceDetailPage({Key key, this.pid, this.deviceId, this.name})
      : super(key: key);

  @override
  DeviceDetailState createState() => new DeviceDetailState();
}

class DeviceDetailState extends State<DeviceDetailPage> {
  bool showLoading = true;

  @override
  void initState() {
    super.initState();
    
    deviceDetailBloc.init(widget.deviceId);
    deviceDetailBloc.setPageStateChangeListener((BasePageState pageState) {
      if (pageState == BasePageState.SHOW_LOADING) {
        showLoading = true;
      } else {
        showLoading = false;
      }
    });

  }

  @override
  void dispose() {
    super.dispose();
    deviceDetailBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        StreamBuilder<DeviceDetailData>(
            stream: deviceDetailBloc.detailSubject.stream,
            builder: (context, AsyncSnapshot<DeviceDetailData> snapshot) {

              if (snapshot.hasData) {
                return _deviceDetail(snapshot.data);
              } else {
                return EmptyWidget();
              }
            }),
        StreamBuilder<bool>(
          stream: deviceDetailBloc.loadingSubject.stream,
          initialData: false,
          builder: (context, snapshot){
            print("loading");
            print(snapshot.data);
            // return LoadingWidget(show: true);
            return LoadingWidget(show: snapshot.data);
          }
        ),
      ],
    );
  }

  Widget _deviceDetail(DeviceDetailData data) {
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
      body: body(data),
    );
  }

  Widget body(DeviceDetailData deviceData) {
    final curTemperature = deviceData.temperature;
    print("curTemperature");
    print(curTemperature);
    List<Widget> list = List();
    print(deviceData.detailImage);
    list.add(
      Container(
          margin: EdgeInsets.all(96),
          child: Image.network(deviceData.detailImage, fit: BoxFit.contain)),
    );
    list.add(Expanded(
      child: Container(
          margin: EdgeInsets.only(bottom: 48.0),
          alignment: Alignment.bottomCenter,
          child: Text(
            "$curTemperature°",
            style: TextStyle(
                fontSize: 48.0,
                color: Color(0xff3c3c3c),
                fontWeight: FontWeight.bold),
          )),
    ));
    list.add(temperatureCtrl(deviceData));
    list.add(functionCtrl(deviceData));
    list.add(Container(
      margin: EdgeInsets.only(bottom: 48.0),
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
      margin: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 48.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              deviceDetailBloc.subTemperature();
            },
          ),
          Expanded(child: 
          Slider(
            value: deviceData.temperature.toDouble(),
            onChanged: (newValue) {},
            min: 16.0,
            max: 32,
          )),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              deviceDetailBloc.addTemperature();
            },
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
      margin: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 48.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
