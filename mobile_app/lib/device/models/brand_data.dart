import 'package:json_annotation/json_annotation.dart';
part 'brand_data.g.dart';

@JsonSerializable()
class Brand {
  int id;
  String name;

  Brand(this.id, this.name);

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json); 
  Map<String, dynamic> toJson() => _$BrandToJson(this);
}


@JsonSerializable()
class BrandMode {
  int id;
  int brandId;
  String brandName;
  String mode;

  BrandMode(this.id, this.brandId, this.brandName, this.mode);

  factory BrandMode.fromJson(Map<String, dynamic> json) => _$BrandModeFromJson(json); 

  Map<String, dynamic>  toJson() => _$BrandModeToJson(this);
}



