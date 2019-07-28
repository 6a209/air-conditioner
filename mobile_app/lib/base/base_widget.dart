import 'package:flutter/material.dart';


class LoadingWidget extends StatelessWidget {

  final bool show; 

  LoadingWidget({this.show});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: FractionalOffset.center,
      child: Offstage(offstage: !show, child: CircularProgressIndicator(),),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  final IconData iconData; 
  final String text;
  EmptyWidget({this.iconData, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Icon(iconData != null ? iconData : Icons.error_outline),
          Text(text != null ? text : "暂无数据")
        ],
      ),
      );
  }
}


