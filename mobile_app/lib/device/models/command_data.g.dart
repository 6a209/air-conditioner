// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandsData _$CommandsDataFromJson(Map<String, dynamic> json) {
  return CommandsData(
      commands: (json['data'] as List)
          ?.map((e) => e == null
              ? null
              : CommandData.fromJson(e as Map<String, dynamic>))
          ?.toList())
    ..code = json['code'] as int
    ..msg = json['msg'] as String;
}

Map<String, dynamic> _$CommandsDataToJson(CommandsData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.commands
    };

CommandData _$CommandDataFromJson(Map<String, dynamic> json) {
  return CommandData(
      id: json['id'] as int,
      name: json['name'] as String,
      irdata: json['irdata'] as String);
}

Map<String, dynamic> _$CommandDataToJson(CommandData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'irdata': instance.irdata
    };
