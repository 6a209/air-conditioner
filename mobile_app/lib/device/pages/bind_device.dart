import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_app/base/toast.dart';
import 'package:mobile_app/device/models/broadcast_data.dart';
import 'package:connectivity/connectivity.dart';
import '../../base/http_utils.dart';

class BindPage extends StatefulWidget {
  @override
  BindPageState createState() => new BindPageState();
}

class BindPageState extends State<BindPage> {
  RawDatagramSocket _socket;
  List<DeviceData> _deviceList;
  String _ssidName;
  InternetAddress _deviceAddress;

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
        _deviceAddress = dg.address;
        print(_deviceAddress);
        if (dg != null) {
          print(dg.toString());
          var codec = new Utf8Codec();
          String jsonData = codec.decode(dg.data);
          var broadcast = DeviceData.fromJSON(json.decode(jsonData));
          if (broadcast.code == 200) {
            addDevice(broadcast);
          }
        }
      });
    });
  }

  void addDevice(DeviceData data) {
    for (var item in _deviceList) {
      if (item.dn == data.dn) {
        return;
      }
    }
    // print(data);
    setState(() {
      _deviceList.add(data);
    });
  }

  void resetDevice() {
    _deviceList.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _socket?.close();
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
            ), 
            new Container(
              margin: EdgeInsets.only(top: 12.0),
              child: _buildDeviceList(context),
            )
          ],
        )));
  }

  Widget _buildDeviceList(BuildContext context) {
      List<Widget> widgets = List();
      for (var item in _deviceList) {
        String pk = item.pk;
        String dn = item.dn;
        Row row = new Row(
          children: <Widget>[
            Expanded(
              child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Container(
                  child: Text("PK: $pk"),
                ),
                new Container(
                  margin: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "DN: $dn", 
                    overflow: TextOverflow.ellipsis,
                    ),
                ),
                   
              ],
            )),
            new FlatButton(
              child: Text("绑定"), 
              textColor: Colors.white,
              color: Colors.lightBlue,
              onPressed: () {
                bind(item);
              },
            )
          ],
        );
        widgets.add(row); 
        widgets.add(Divider(color: Color(0x7f727272), height: 1.0,));
      }
      return new Column(
        children: widgets,
      );
  }

  void bind(DeviceData deviceData) async {
    var response = await IRHTTP().post('/device/bind', data: {"pk": deviceData.pk, "dn": deviceData.dn});
    print(response);
    if (response.data['code'] == 200) {
      sendBindSuccess();
      var deviceId = response.data['data']['deviceId'];
      Navigator.of(context).pushNamed('/product', arguments: {"deviceId": deviceId});
    } else {
      print(response.data['msg']);
      showToast(response.data['msg']); 
    }
  }

  void sendBindSuccess() {
    var codec = new Utf8Codec();
    _socket.send(codec.encode("mobile_uid"), _deviceAddress, 9988);
  }
}
