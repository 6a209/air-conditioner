import 'package:flutter/material.dart';
import 'package:mobile_app/index/models/my_action_data.dart';



class MyPage extends StatefulWidget {
  @override
  MyPageState createState() => new MyPageState();
}

class MyPageState extends State<MyPage> {

  List<MyActionData> _listData;

  @override
  void initState() {
    super.initState();
    _listData = new List();

    var product = MyActionData(text: "我的产品", url: "xxxx");  
    var form = MyActionData(text: "官方论坛", url: "xxx");
    var feedback = MyActionData(text: "反馈", url: "xxx");
    var about = MyActionData(text: "关于", url: "xxxx");

    _listData.add(product);
    _listData.add(form);
    _listData.add(feedback);
    _listData.add(about);
  }

  @override
  Widget build(BuildContext context){
    return new Container(
      padding: EdgeInsets.all(48), 
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://avatars2.githubusercontent.com/u/688545?s=460&v=4"),
                    fit: BoxFit.cover
                  ),
                  shape: BoxShape.circle
                ),
              ),
              new Container(
                margin: EdgeInsets.only(left: 36),
                child: Text(
                  "我是闹闹喵",
                  style: new TextStyle(fontSize: 18, color: Color(0xff3c3c3c)),
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 48.0),
            child: Divider(
              color: Color(0x7f727272),
              height: 1.0,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 24.0),
            child: _buildItemList(context),
          ),
        ],
      )
    );
  }

  Widget _buildItemList(BuildContext context) {

    List<Widget> listWidget = new List();

    for (var i = 0; i < _listData.length; i++) {
      var itemData = _listData[i];

      var container = new Container(
        constraints: BoxConstraints.expand(height: 48),
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1.0, 
              color: i == _listData.length - 1 ? Color(0xffffff) : Color(0x5f727272),
              style: BorderStyle.solid
            ) 
          )
        ),
        child: Text(itemData.text, style: TextStyle(fontSize: 16.0, color: Color(0xff727272)),),
      ); 

      var itemWidget = GestureDetector(onTap: () {
             Navigator.of(context).pushNamed('/product', arguments: {"deviceId": -1}); 
      }, child: container,); 

      listWidget.add(itemWidget);
    }
    return new Column(
      children: listWidget,
    );
  }
}