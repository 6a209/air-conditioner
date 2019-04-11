import 'package:flutter/material.dart';
import '../models/product_data.dart';

class ProductList extends StatefulWidget {
  @override
  ProductListState createState() => new ProductListState();
}


class ProductListState extends State<ProductList> {
  ProductListData _productList; 

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("产品列表"), backgroundColor: Colors.blueAccent),
      body: new ListView.separated(
        itemCount: _productList == null ? 0 : _productList.data.length,
        itemBuilder: (BuildContext context, int index) {
          
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
      ),
    );
  }

}
