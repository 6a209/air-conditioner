import 'package:flutter/material.dart';
import 'package:mobile_app/index/models/my_action_data.dart';



class MyPage extends StatefulWidget {
  @override
  MyPageState createState() => new MyPageState();
}

class MyPageState extends State<MyPage> {

  List<MyActionData> _listData;

  @override
  Widget build(BuildContext context){
    return new Container(
      child: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("xxx"),
                    fit: BoxFit.cover
                  ),
                  shape: BoxShape.circle
                ),
              ),
              new Container(
                child: Text(
                  "我是闹闹喵",
                  style: new TextStyle(fontSize: 16, color: Color(0x727272)),
                ),
              )
            ],
          ),
          Divider(
            color: Color(0x727272),
            height: 1.0,
          ),
        ],
      )
    );
  }

  Widget _buildItemList(BuildContext context) {

    List<Widget> listWidget = new List();

    for (var itemData in _listData) {
      var itemWidget = new Container(
        child: Expanded(
          
          child: Text(itemData.text),
        ), 
      ); 
    }
    return new Column(

    );
  }
}