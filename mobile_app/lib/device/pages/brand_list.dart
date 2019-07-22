import 'package:flutter/material.dart';
import 'package:mobile_app/base/base_widget.dart';
import 'package:mobile_app/base/http_utils.dart';
import 'package:mobile_app/base/toast.dart';
import 'package:mobile_app/device/models/brand_data.dart';

class BrandPage extends StatefulWidget {
  int deviceId;

  BrandPage(this.deviceId);

  @override
  BrandPageState createState() => new BrandPageState();
}

class BrandPageState extends State<BrandPage> {
  TextEditingController editingController = TextEditingController();

  List<Brand> brandData;
  List<Brand> allData;
  bool showLoadind;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    allData = new List();
    setState(() {
      showLoadind = true;
    });
    HTTPResponse response = await IRHTTP().requestPost("/brand/list");
    setState(() {
      showLoadind = false;
      if (response.code == 200) {
        print(response.data);
        brandData = (response.data as List)
            .map((item) => Brand.fromJson(item))
            .toList();
        allData.addAll(brandData);
      } else {
        showToast(response.msg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Color(0xffEFEFEF),
        appBar: new AppBar(actions: <Widget>[
          // new FlatButton(
          //   child: Text(
          //     "自定义",
          //     style: TextStyle(color: Colors.white),
          //   ),
          //   onPressed: () {},
          // )
        ], title: new Text("品牌列表"), backgroundColor: Colors.blueAccent),
        body: Stack(
          children: <Widget>[
            body(),
            new LoadingWidget(
              show: showLoadind,
            )
          ],
        ));
  }

  void _searchFilter(String value) {
    List<Brand> tmpData = new List();
    tmpData.addAll(allData);
    if (value.isNotEmpty) {
      tmpData = tmpData.where((item) => item.name.contains(value)).toList();
    }
    setState(() {
      brandData = tmpData;
    });
  }


  Widget body() {
    return new Column(
      children: <Widget>[
        Container(
          child: TextField(
              decoration: InputDecoration(
                  hintText: "搜索", prefixIcon: Icon(Icons.search)),
              controller: editingController,
              onChanged: _searchFilter),
        ),
        listBrand(),
      ],
    );
  }

  Widget listBrand() {
    Widget list = new ListView.separated(
      separatorBuilder: (BuildContext context, int index) {
        const divider = Divider(
          color: Color(0x7f727272),
          height: 1.0,
        );
        return Container(
          margin: EdgeInsets.only(left: 16.0),
          child: divider,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        Brand item = brandData[index];
        Container container = new Container(
          child: new Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(item.name),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.grey,
                )
              ],
            ),
          ),
        );
        return GestureDetector(
          child: container,
          onTap: () {
            Navigator.of(context).pushNamed('/brand/mode',
                arguments: {"deviceId": widget.deviceId, "brandId": item.id, "name": item.name});
          },
        );
      },
      itemCount: brandData?.length ?? 0 
    );

    return new Expanded(
      child: list,
    );
  }
}
