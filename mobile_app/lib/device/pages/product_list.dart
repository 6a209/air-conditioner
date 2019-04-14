import 'package:flutter/material.dart';
import '../models/product_data.dart';
import '../../base/http_utils.dart';

class ProductList extends StatefulWidget {
  final int deviceId;

  ProductList({Key key, this.deviceId}) : super(key: key);

  @override
  ProductListState createState() => new ProductListState();
}

class ProductListState extends State<ProductList> {
  ProductListData _productList;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var value;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    var response = await IRHTTP().post('/product/list');
    setState(() {
      _productList = ProductListData.fromJSON(response.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          title: new Text("产品列表"), backgroundColor: Colors.blueAccent),
      body: new ListView.separated(
        itemCount: _productList == null ? 0 : _productList.data.length,
        itemBuilder: (BuildContext context, int index) {
          ProductItem item = _productList.data[index];
          return new Container(
            margin: EdgeInsets.only(top: 12.0),
            child: new Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(item.name),
                  ),
                  FlatButton(
                    child: Text("绑定", style: TextStyle(color: Colors.blueAccent),),
                    onPressed: () {},
                  ),
                  FlatButton(
                    child: Text("编辑", style: TextStyle(color: Colors.blueAccent),),
                    onPressed: () {},
                  )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: Color(0x7f727272),
            height: 1.0,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showAlertDialog(context);
        },
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();

    List<DropdownMenuItem> dropItems = new List();
    dropItems.add(DropdownMenuItem(value: "AirConditioner", child: Text("空调")));
    dropItems.add(DropdownMenuItem(value: "TV", child: Text("电视")));

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: new Text("创建一个产品"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "请输入名称",
                    ),
                  ),
                  DropdownButton(
                    hint: Text("选择产品类型"),
                    items: dropItems,
                    value: value,
                    onChanged: (T) {
                      setState(() {
                        value = T;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("取消"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("保存"),
                  onPressed: () {
                    createProduct(context, nameController.text, "", "", value);
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  void createProduct(BuildContext context, String name, String icon,
      String detailImage, String type) async {
    var response = await IRHTTP().post('/product/create', data: {
      "product": {
        "name": name,
        "icon": icon,
        "detailImage": detailImage,
        "type": type
      }
    });

    if (response.data['code'] == 200) {
      final snackBar = SnackBar(content: Text('创建成功'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      await initData();
    }
  }
}

// class CreateProductDialog extends Dialog {

//   CreateProductDialog({
//     Key key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(8.0),
//       child: Material(
//         child: Column(
//         ),
//       ),
//     );
//   }
// }
