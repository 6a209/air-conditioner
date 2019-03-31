import 'dart:io';
import 'dart:convert';
import 'models/index_list_data.dart';

class IndexApi {


  Future<IndexListData> getIndex() async {
    var client = HttpClient();
    var request = await client.getUrl(Uri.parse(
      'http://192.168.4.92:7100/index'));
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    Map data = json.decode(responseBody);
    return IndexListData.fromJSON(data);
  }
}