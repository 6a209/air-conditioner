import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/base/toast.dart';
import 'package:mobile_app/device/bloc/detail_bloc.dart';
import 'package:mobile_app/device/bloc/detail_event.dart';
import 'package:mobile_app/device/bloc/detail_state.dart';
import 'package:mobile_app/device/models/command_data.dart';
import 'package:mobile_app/device/models/device_data.dart';
import 'package:mobile_app/base/base_widget.dart';

class DeviceDetailPage extends StatelessWidget {
  final int deviceId;

  const DeviceDetailPage({Key key, this.deviceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = DetailBloc(deviceId: deviceId);
    return BlocProvider<DetailBloc>(
      create: (context) => bloc,
      child: _DeviceDetailPage(bloc: bloc),
    );
  }
}

class _DeviceDetailPage extends StatelessWidget {
  final TextEditingController controller = new TextEditingController();
  static final DETAIL_IMG =
      "https://irremote-1253860771.cos.ap-chengdu.myqcloud.com/big.png";
  final title = "设备详情";
  final DetailBloc bloc;

  _DeviceDetailPage({this.bloc,
    Key key,
  }) : super(key: key) {
    bloc.add(InitEvent(bloc.deviceId));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<DetailBloc>(context);

    // final listener =
    return BlocListener<DetailBloc, DetailState>(listener: (context, state) {
      if (state is ErrorState) {
        showToast(state.msg);
      }
    }, child: BlocBuilder<DetailBloc, DetailState>(
      builder: (context, state) {
        DeviceDetailData detailData = DeviceDetailData();
        Widget body;
        var show = false;
        if (state is InitState) {
          detailData = state.deviceData;
          // return _body(bloc, state.deviceData);
        }
        if (state is UpdateInfoState) {
          detailData = state.deviceData;
        }
        if (state is LoadingState) {
          show = state.show;
          // body = LoadingWidget(show: true);
        } else {
          body = _body(bloc, detailData);
        }

        body = Stack(children: <Widget>[
          _body(bloc, detailData), LoadingWidget(show: show,)
        ],);

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [_popMenu(bloc, context)],
          ),
          body: body,
        );
      },
    ));
  }

  Widget _popMenu(DetailBloc bloc, BuildContext context) {
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
        // BlocProvider.of<DetailBloc>(context);
        switch (value) {
          case "rename":
            updateName(bloc, context);
            break;
          case "delete":
            confirmDelete(bloc, context);
            break;
          default:
            break;
        }
      },
    );
  }

  Widget _body(DetailBloc bloc, DeviceDetailData deviceData) {
    // this.title = deviceData.name;
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
    list.add(temperatureCtrl(bloc, deviceData));
    list.add(functionCtrl(bloc, deviceData));
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
              ? bloc.add(PowerEvent(POWER_OFF))
              : bloc.add(PowerEvent(POWER_ON));
        },
      ),
    ));
    return Column(
      children: list,
    );
  }

  Widget temperatureCtrl(DetailBloc bloc, DeviceDetailData deviceData) {
    return Container(
      margin: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 36.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              bloc.add(SubTemperatureEvent());
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
              bloc.add(AddTemperatuerEvent());
              // deviceDetailBloc.addTemperature();
            },
          ),
        ],
      ),
    );
  }

  Widget functionCtrl(DetailBloc bloc, DeviceDetailData deviceData) {
    return Container(
      margin: EdgeInsets.only(left: 24.0, right: 24.0, bottom: 36.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          funBtn(bloc, "cold", deviceData.mode),
          funBtn(bloc, "hot", deviceData.mode),
          funBtn(bloc, "wet", deviceData.mode),
          funBtn(bloc, "wind", deviceData.mode)
        ],
      ),
    );
  }

  Widget funBtn(DetailBloc bloc, String name, int mode) {
    bool isSelect = bloc.modeValue(name) == mode;
    return GestureDetector(
        child: ImageIcon(
          AssetImage("assets/" + name + ".png"),
          size: 64,
          color: isSelect ? Colors.blueAccent : Colors.grey,
        ),
        onTap: () {
          bloc.add(ChangeModeEvent(name));
          // deviceDetailBloc.funBtnClick(name);
        });
  }

  void confirmDelete(DetailBloc bloc, BuildContext context) {
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
                  bloc.add(DeleteDeviceEvent());
                  // deviceDetailBloc.deleteDevice(widget.deviceId);
                },
              ),
            ],
          );
        });
  }

  void updateName(DetailBloc bloc, BuildContext context) {
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
              FlatButton(
                child: Text("确定"),
                onPressed: () {
                  bloc.add(ChangeNameEvent(controller.text));
                  // deviceDetailBloc.updateDeviceName(
                  //     widget.deviceId, controller.text);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
