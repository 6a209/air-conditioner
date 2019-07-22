import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobile_app/base/base_widget.dart';
import 'package:mobile_app/base/http_utils.dart';
import 'package:mobile_app/base/toast.dart';
import 'package:mobile_app/device/api/brand.dart';
import 'package:mobile_app/device/models/brand_data.dart';
import 'package:mobile_app/device/models/command_data.dart';

class BrandModePage extends StatefulWidget {
  String name;
  int brandId;
  int deviceId;

  BrandModePage(this.name, this.brandId, this.deviceId);

  @override
  BrandModePageState createState() => new BrandModePageState();
}

class BrandModePageState extends State<BrandModePage> {
  List<BrandMode> brandModes;
  bool showLoadind;
  int selectIdx = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    setState(() {
      showLoadind = true;
    });
    // brandModes = new List();
    HTTPResponse response = await BrandApi.brandsMode(widget.brandId);
    if (200 == response.code) {
      setState(() {
        showLoadind = false;
        brandModes = (response.data as List)
            .map((item) => BrandMode.fromJson(item))
            .toList();
      });
    } else {
      showToast(response.msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: brandModes?.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.name),
            actions: <Widget>[
              // FlatButton(
              //   child: Text(
              //     "自定义",
              //     style: TextStyle(color: Colors.white),
              //   ),
              //   onPressed: () {},
              // )
            ],
            bottom: TabBar(
                indicatorPadding: EdgeInsets.only(top: 8, left: 8, right: 8),
                indicatorSize: TabBarIndicatorSize.label,
                isScrollable: true,
                indicatorColor: Colors.white,
                onTap: (idx) {
                  selectIdx = idx;
                },
                tabs: brandModes
                    .map((item) => Text(
                          item.mode,
                          style: TextStyle(color: Colors.white),
                        ))
                    .toList()),
          ),
          body: Stack(
            children: body(context),
          ),
        ));
  }

  List<Widget> body(BuildContext context) {
    List<Widget> list = new List();
    if (null != brandModes && brandModes.length > 0) {
      Container container = Container(
        child: Column(
          children: <Widget>[
            _tip(),
            Expanded(
              child: FunTestWidget(
                click: funClick,
              ),
            ),
            _btnLy(context),
          ],
        ),
      );
      list.add(container);
    }
    list.add(LoadingWidget(show: showLoadind));
    return list;
  }

  Widget _tip() {
    Card card = new Card(
      child: Column(
        children: <Widget>[
          new Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(12.0),
            child: new Text('请测试相关功能，有反应点击确定绑定，都无反应请选择自定义'),
          ),
        ],
      ),
    );

    return Container(
      margin: EdgeInsets.all(16.0),
      child: card,
    );
  }

  void funClick(AirCommand command) {
    BrandMode brandMode = brandModes[selectIdx];
    print(brandMode.mode);
    print(widget.deviceId);
    IRHTTP().requestPost("/device/command", data: {
      "power": command.power,
      "mode": command.mode,
      "brandMode": brandMode.mode,
      "deviceId": widget.deviceId
    });
  }

  Widget _btnLy(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.all(24.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: MaterialButton(
            child: Text(
              "确定",
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.blueAccent,
            onPressed: () {
              showAlertDialog(context);
            },
          )),
        ],
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: new Text("创建一个产品"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "请输入名称",
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("取消"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("保存"),
                  onPressed: () {
                    createProduct(context, nameController.text, "", "", 0);
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  void createProduct(BuildContext context, String name, String icon,
      String detailImage, int type) async {
    BrandMode brandMode = brandModes[selectIdx];
    var response = await IRHTTP().post('/product/create', data: {
      "product": {
        "name": name,
        "icon": icon,
        "detailImage": detailImage,
        "brand": widget.name,
        "brand_mode": brandMode.mode, 
        "type": type
      }
    });

    if (response.data['code'] == 200) {
      Navigator.of(context).pushNamedAndRemoveUntil('/index', ModalRoute.withName('/index')); 
    }
  }
}

class FunTestWidget extends StatelessWidget {
  Function funClick;
  FunTestWidget({Key key, Function click}) : super(key: key) {
    this.funClick = click;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[row("开启", "关闭"), row("制冷", "制热")],
    );
  }

  Widget row(String name1, String name2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[_btn(name1), _btn(name2)],
    );
  }

  Widget _btn(String name) {
    Widget btn = FlatButton(
      child: Text(
        name,
        style: TextStyle(color: Colors.white),
      ),
      color: Colors.blueAccent,
      shape: CircleBorder(),
      onPressed: () {
        _onClick(name);
      },
    );
    return new Container(
      margin: EdgeInsets.only(top: 32),
      height: 96,
      width: 96,
      child: btn,
    );
  }

  void _onClick(name) {
    AirCommand airCommand = AirCommand();

    airCommand.power = POWER_ON;
    switch (name) {
      case "开启":
        airCommand.power = POWER_ON;
        break;
      case "关闭":
        airCommand.power = POWER_OFF;
        break;
      case "制冷":
        airCommand.mode = MODE_COOL;
        break;
      case "制热":
        airCommand.mode = MODE_HEAT;
        break;
    }
    funClick(airCommand);
  }
}
