import '../../base/base_data.dart' as basedata;

class IndexListData {
  List<IndexItem> data;

  IndexListData({this.data});

  IndexListData.fromJSON(List json) {
    this.data = json.map((item) {
      return IndexItem(productId: item['productId'], deviceId: item['deviceId'], 
        name: item['name'], status: item['status'], icon: item['icon']);  
    }).toList();
  }
}

class IndexItem {
  int productId;
  int deviceId;
  String name;
  int status;
  String icon;

  IndexItem({
    this.productId,
    this.deviceId,
    this.name,
    this.status,
    this.icon
  });
}
