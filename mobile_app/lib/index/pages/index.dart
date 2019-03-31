import 'package:flutter/material.dart';

class IndexPage extends StatefulWidget {
  @override
  IndexPageState createState() => new IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  List data;

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new ListView.builder(
      itemCount: data == null ? 0 : data.length,
      itemBuilder: (BuildContext context, int index) {
        return new Card(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Image.network(
                  'http://pic.baike.soso.com/p/20130828/20130828161137-1346445960.jpg',
                ),
              new Expanded(
              child: new Column(
                children: <Widget>[
                  new Text("花花的空调"),
                  new Row(
                    children: <Widget>[
                      new Container(
                        width: 8,
                        height: 8,
                        decoration: new BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                      ),
                      new Text("在线")
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
      },
    ));
  }
}
