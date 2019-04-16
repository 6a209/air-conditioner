import '../../base/base_data.dart' as basedata;

class ProductListData extends basedata.BaseData {
  List<ProductItem> data;
  ProductListData({this.data});

  ProductListData.fromJSON(Map<String, dynamic> json) {
    this.code = json['code'];
    this.msg = json['msg'];
    this.data = (json['data'] as List).map((item) {
      return ProductItem(
          id: item['id'],
          name: item['name'],
          icon: item['icon'],
          detailImage: item['detailImage']);
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

// ----------------------------------------------------------------

class ProductDetailData {
  List<ProductGroup> groups;

  ProductDetailData({this.groups});

  factory ProductDetailData.fromJSON(List<dynamic> data) {
    List<ProductGroup> _groups = data.map((item) {
      return ProductGroup.fromJSON(item); 
    }).toList();
    return ProductDetailData(groups: _groups); 
  }
}

class ProductGroup {
  String title;
  List<ProductRow> rows;

  ProductGroup({this.title, this.rows});

  factory ProductGroup.fromJSON(Map<String, dynamic> json) {
    String title = json['title'];
    List<ProductRow> rows = (json['rows'] as List).map((item) {
      return ProductRow.fromJSON(item);
    }).toList();
    return ProductGroup(title: title, rows: rows);
  }
}

class ProductRow {
  String name;
  String data;

  ProductRow({this.name, this.data});

  factory ProductRow.fromJSON(Map<String, dynamic> json) {
    return ProductRow(name: json['name'], data: json['data']);
  }
}
