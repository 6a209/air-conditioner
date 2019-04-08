import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_app/device/models/broadcast_data.dart';
import 'package:connectivity/connectivity.dart';

class BindPage extends StatefulWidget {
  @override
  BindPageState createState() => new BindPageState();
}

class BindPageState extends State<BindPage> {
  RawDatagramSocket _socket;
  List<BroadcastData> _deviceList;
  String _ssidName;

  @override
  void initState() {
    super.initState();
    _deviceList = new List();
    Connectivity().getWifiName().then((wifiName) {
      _ssidName = wifiName;
    });

    var address = new InternetAddress('0.0.0.0');
    RawDatagramSocket.bind(address, 9876).then((udpSocket) {
      _socket = udpSocket;
      udpSocket.broadcastEnabled = true;
      udpSocket.listen((data) {
        print(data.toString());
        Datagram dg = udpSocket.receive();
        if (dg != null) {
          print(dg.toString());
          var codec = new Utf8Codec();
          String jsonData = codec.decode(dg.data);
          var broadcast = BroadcastData.fromJSON(json.decode(jsonData));

          if (broadcast.code == 200) {
            addDevice(broadcast);
          }
        }
      });
    });
  }

  void addDevice(BroadcastData data) {
    for (var item in _deviceList) {
      if (item.dn == data.dn) {
        return;
      }
    }
    _deviceList.add(data);
  }

  void resetDevice() {
    _deviceList.clear();
  }

  @override
  void dispose() {
    super.dispose();
    if (_socket != null) {
      _socket.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Color(0xffEFEFEF),
        appBar: new AppBar(
            title: new Text("绑定设备"), backgroundColor: Colors.blueAccent),
        body: new Container(
          padding: EdgeInsets.all(24.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            new Card(
               
              child: Column(
                children: <Widget>[
                  new Container(
                    margin: EdgeInsets.only(top: 12.0),
                    child: new Text('请确保手机和设备在同一个wifi'),
                  ),
                  new Container(
                    alignment: Alignment.center,
                    constraints: BoxConstraints.expand(height: 24.0),
                    child: new Text('当前wifi: $_ssidName'),
                  )
                ],
              ),
            ),
            new Container(
              margin: EdgeInsets.only(top: 32.0),
              child: new Text('当前在线设备列表:'),
            )
            // new ListView.separated(
            //     itemCount: _deviceList.length,
            //     itemBuilder: (BuildContext context, int index) {
            //       BroadcastData itemData = _deviceList[index];
            //       String dn = itemData.dn;
            //       String pk = itemData.pk;
            //       return new Container(
            //         child: new Row(
            //           children: <Widget>[
            //             new Column(children: <Widget>[
            //               new Text("DeviceName: $dn"),
            //               new Text("ProductKey: $pk")
            //             ],),
            //             new FlatButton(
            //               onPressed: () {
            //               },
            //               child: Text("绑定"),
            //               color: Colors.blue,)
            //           ],
            //         ),
            //       );
            //     },
            //     separatorBuilder: (BuildContext context, int index) {
            //       return new Divider(height: 1.0, color: Color(0x7F606060),);
            //     },)
          ],
        )));
  }

  Widget _buildDeviceList(BuildContext context) {
      Column column = new Column();
      for (var item in _deviceList) {

      }
      return column;
  }
}
