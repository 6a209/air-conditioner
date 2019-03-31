import '../../base/base_data.dart' as basedata;

class IndexListData extends basedata.BaseData {
  List<IndexItem> data;

  IndexListData({this.data});

  IndexListData.fromJSON(Map<String, dynamic> json) {
    this.code = json['code'];
    this.msg = json['msg'];
    this.data = (json['data'] as List).map((item) {
      return IndexItem(productId: item['productId'], id: item['id'], 
        name: item['name'], status: item['status'], icon: item['icon']);  
    }).toList();
  }
}

class IndexItem {
  String productId;
  String id;
  String name;
  int status;
  String icon;

  IndexItem({
    this.productId,
    this.id,
    this.name,
    this.status,
    this.icon
  });
}
