import 'package:flutter/material.dart';
import 'package:mobile_app/base/base_page.dart';
import 'package:mobile_app/device/models/command_data.dart';
import 'package:mobile_app/device/models/device_data.dart';
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
      width: 192,
      height: 48,
      child: FlatButton(
        child: Text(deviceData.power == POWER_ON ? "关闭" : "打开", style: TextStyle(color: Colors.white),),
        color: deviceData.power == POWER_ON ? Colors.blueAccent : Colors.blueGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        onPressed: () {
          deviceData.power == POWER_ON ? 
            deviceDetailBloc.powerOff() : deviceDetailBloc.powerOn(); 
        },
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
    return Container(
      margin: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 48.0),
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
}
