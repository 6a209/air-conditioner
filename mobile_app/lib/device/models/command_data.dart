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
  String value;
  String irdata = "";

  CommandData({this.id, this.name, this.value, this.irdata});
  factory CommandData.fromJson(Map<String, dynamic> json) => _$CommandDataFromJson(json); 
  Map<String, dynamic> toJson() => _$CommandDataToJson(this);
}

const int POWER_ON = 0x00;
const int POWER_OFF = 0x01;

const int MODE_COOL = 0x00;
const int MODE_HEAT = 0x01;
const int MODE_AUTO = 0x02;
const int MODE_FAN = 0x03;
const int MODE_DRY = 0x04;

class AirCommand {
  int power;
  int mode;
  int temperature = -1; 
}




