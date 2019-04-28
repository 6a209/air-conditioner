import '../../base/base_data.dart' as basedata;

class CommandsData extends basedata.BaseData{
  List<CommandData> commands;

  CommandsData({this.commands});

  CommandsData.fromJSON(Map<String, dynamic> json) {
    this.code = json['code'];
    this.msg = json['msg'];
    this.commands = (json['data'] as List).map((item) {
      return CommandData(id: item.id, name: item.name, irdata: item.irdata);
    }).toList();
  }
}

class CommandData {
  int id;
  String name;  
  String irdata;

  CommandData({this.id, this.name, this.irdata});
}