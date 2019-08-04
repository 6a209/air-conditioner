import 'package:flutter/material.dart';
import 'package:mobile_app/base/base_page.dart';
import 'package:mobile_app/device/models/command_data.dart';
import 'package:mobile_app/device/models/device_data.dart';
import '../bloc/device_detail_bloc.dart';
import 'package:mobile_app/base/base_widget.dart';


class DeviceDetailPage extends StatefulWidget {
  final int deviceId;
  final int pid;

  DeviceDetailPage({Key key, this.pid, this.deviceId})
      : super(key: key);

  @override
  DeviceDetailState createState() => new DeviceDetailState();
}

class DeviceDetailState extends State<DeviceDetailPage> {
  bool showLoading = true;
  TextEditingController controller;
  static final String DETAIL_IMG = "https://irremote-1253860771.cos.ap-chengdu.myqcloud.com/big.png"; 

  @override
  void initState() {
    super.initState();
    controller = new TextEditingController();

    deviceDetailBloc.init(widget.deviceId, context);
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
            builder: (context, snapshot) {
              print("loading");
              print(snapshot.data);
              // return LoadingWidget(show: true);
              return LoadingWidget(show: snapshot.data);
            }),
      ],
    );
  }

  Widget _deviceDetail(DeviceDetailData data) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data.name),
        actions: <Widget>[
          _popMenu(),
        ],
      ),
      body: body(data),
    );
  }

  Widget _popMenu() {
    return new PopupMenuButton(
      icon: new Icon(Icons.more_horiz),
      itemBuilder: (BuildContext context) {
        List<PopupMenuItem<String>> items = new List(); 
        items.add(PopupMenuItem(
          value: "rename",
          child: new Text("修改名称"),
        ));

        items.add(PopupMenuItem(
          value: "delete",
          child: new Text("删除该设备"),
        ));
        return items;
      },
      onSelected: (String value) {
        switch (value) {
          case "rename":
            updateName(context);
            break;
          case "delete":
            confirmDelete(context);
            break;
          default:
            break;
        }
      },
    );
  }

  Widget body(DeviceDetailData deviceData) {
    final curTemperature = deviceData.temperature;
    print("curTemperature");
    print(curTemperature);
    List<Widget> list = List();
    list.add(
      Container(
          margin: EdgeInsets.all(80),
          child: Image.network(DETAIL_IMG, fit: BoxFit.contain)),
    );
    list.add(Expanded(
      child: Container(
          margin: EdgeInsets.only(bottom: 36.0),
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
      width: 192,
      height: 48,
      child: FlatButton(
        child: Text(
          deviceData.power == POWER_ON ? "关闭" : "打开",
          style: TextStyle(color: Colors.white),
        ),
        color:
            deviceData.power == POWER_ON ? Colors.blueAccent : Colors.blueGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        onPressed: () {
          deviceData.power == POWER_ON
              ? deviceDetailBloc.powerOff()
              : deviceDetailBloc.powerOn();
        },
      ),
    ));
    return Column(
      children: list,
    );
  }

  Widget temperatureCtrl(DeviceDetailData deviceData) {
    return Container(
      margin: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 36.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              deviceDetailBloc.subTemperature();
            },
          ),
          Expanded(
              child: Slider(
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
    return Container(
      margin: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 36.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          funBtn("cold"),
          funBtn("hot"),
          funBtn("wet"),
          funBtn("wind")
        ],
      ),
    );
  }

  Widget funBtn(String name) {
    bool isSelect = deviceDetailBloc.modeValue(name) == deviceDetailBloc.mode;
    return GestureDetector(
        child: ImageIcon(
          AssetImage("assets/" + name + ".png"),
          size: 64,
          color: isSelect ? Colors.blueAccent : Colors.grey,
        ),
        onTap: () {
          deviceDetailBloc.funBtnClick(name);
        });
  }

  void confirmDelete(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("确定删除这个设备么？"),
            actions: <Widget>[
              FlatButton(
                child: Text("取消"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("确定"),
                onPressed: () {
                  Navigator.of(context).pop();
                  deviceDetailBloc.deleteDevice(widget.deviceId);
                },
              ),
            ],
          );
        });
  }

  void updateName(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("修改设备名称"),
            content: TextField(controller: controller),
            actions: <Widget>[
              FlatButton(
                child: Text("取消"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(child: Text("确定"),
                onPressed: ()  {
                  deviceDetailBloc.updateDeviceName(widget.deviceId, controller.text);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
