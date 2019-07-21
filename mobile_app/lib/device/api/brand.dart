

import 'package:mobile_app/base/http_utils.dart';

class BrandApi {

  static brands(String pk) async {
    return await IRHTTP().requestPost("/brand/list");
  }

  static brandsMode(int brandId) async {
    print("-------------------------------");
    print(brandId);
    return await IRHTTP().requestPost("/brand/mode", data: {"brandId": brandId});
  }
}