import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final bool show;

  LoadingWidget({this.show});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: FractionalOffset.center,
      child: Offstage(
        offstage: !show,
        child: CircularProgressIndicator(),
      ),
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
      width: double.maxFinite,
      height: double.maxFinite,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(iconData != null ? iconData : Icons.error_outline, size: 48, color: Colors.grey,),
          Text(text != null ? text : "暂无数据", style: TextStyle(fontSize: 18, color: Colors.black54),)
        ],
      ),
    );
  }
}
