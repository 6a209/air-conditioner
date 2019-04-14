import 'package:flutter/material.dart';

class ProductDetail extends StatefulWidget {
  final int deviceId;
  String name;

  ProductDetail({Key key, this.deviceId}) : super(key: key);

  @override
  ProductDetailState createState() => new ProductDetailState();
}

class ProductDetailState extends State<ProductDetail> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          title: new Text(widget.name), backgroundColor: Colors.blueAccent),
      body: Container(
        child: Column(
          children: <Widget>[],
        ),
      ),
    );
  }

  Widget buildFunction(BuildContext context) {
     
  }

  Widget buildTemperature(BuildContext context) {

  }

  Widget buildRow(String name, String data) {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 16.0),
          child: Text(name),
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
