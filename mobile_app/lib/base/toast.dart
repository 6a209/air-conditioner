

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(text) {
  Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 3,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0
    );
}