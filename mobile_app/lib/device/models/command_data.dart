import '../../base/base_data.dart' as basedata;
import 'package:json_annotation/json_annotation.dart';

part 'command_data.g.dart';

@JsonSerializable()
class CommandsData extends basedata.BaseData {
  List<CommandData> data;

  CommandsData({this.data});

  factory CommandsData.fromJson(Map<String, dynamic> json) => _$CommandsDataFromJson(json); 
  Map<String, dynamic> toJson() => _$CommandsDataToJson(this);
}

@JsonSerializable()
class CommandData {
  int id = -1;
  String name;
  String irdata = "";

  CommandData({this.id, this.name, this.irdata});
  factory CommandData.fromJson(Map<String, dynamic> json) => _$CommandDataFromJson(json); 
  Map<String, dynamic> toJson() => _$CommandDataToJson(this);
}
