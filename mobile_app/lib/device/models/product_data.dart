import '../../base/base_data.dart' as basedata;

class ProductListData extends basedata.BaseData {
  List<ProductItem> data;
  ProductListData({this.data});

  ProductListData.fromJSON(Map<String, dynamic> json) {
    this.code = json['code'];
    this.msg = json['msg'];
    this.data = (json['data'] as List).map((item) {
      return ProductItem(
          id: item['id'], name: item['name'], icon: item['icon'], detailImage: item['detailImage']);
    }).toList();
  }
}

class ProductItem {
  String name;
  int id;
  String icon;
  String detailImage;

  ProductItem({this.id, this.name, this.icon, this.detailImage});
}
