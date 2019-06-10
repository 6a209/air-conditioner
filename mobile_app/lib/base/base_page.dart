import 'package:flutter/material.dart';


abstract class BasePage extends State<StatefulWidget> {


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // return ;
  }

  Widget body(BuildContext context);

}

enum BasePageState {
  SHOW_LOADING,
  SHOW_ERROR,
  SHOW_DATA
}