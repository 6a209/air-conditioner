import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/product_data.dart';

class ProductDetail extends StatefulWidget {
  final int deviceId;
  String name = "空调";

  ProductDetail({Key key, this.deviceId, this.name}) : super(key: key);

  @override
  ProductDetailState createState() => new ProductDetailState();
}

class ProductDetailState extends State<ProductDetail> {
  ProductDetailData productDetailData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  initData() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('config/airconditioner.json');
    List<dynamic> listData = jsonDecode(data) as List;
    setState(() {
      this.productDetailData = ProductDetailData.fromJSON(listData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: new Text("空调"), backgroundColor: Colors.blueAccent),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(children: buildDetailData()),
        ),
      ),
    );
  }

  List<Widget> buildDetailData() {
    List<Widget> listWidget = List();
    if (null == productDetailData) {
      return listWidget;
    }
    for (ProductGroup groupData in productDetailData.groups) {
      List<Widget> columnChild = List();
      columnChild.add(Text(
        groupData.title,
        style: TextStyle(color: Color(0xff3c3c3c), fontSize: 18.0, fontWeight: FontWeight.bold),
      ));
      columnChild.add(Divider(
        height: 1,
        color: Color(0x7f727272),
      ));

      for (ProductRow row in groupData.rows) {
        Widget rowWidget = buildRow(row.name, row.data);
        columnChild.add(rowWidget);
      }
      Column column = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChild,
      );
      listWidget.add(column);
    }
    return listWidget;
  }

  Widget buildRow(String name, String data) {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 16.0),
          child: Text(name, style: TextStyle(color: Color(0xff727272)),),
        ),
        Expanded(child: Text(data, overflow: TextOverflow.ellipsis)),
        FlatButton(
          child: Text("学习", style: TextStyle(color: Colors.white)),
          color: Colors.blueAccent,
          onPressed: () {

          },
        )
      ],
    );
  }
}
