import 'package:equatable/equatable.dart';
import 'package:mobile_app/device/models/device_data.dart';

class DetailEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class InitEvent extends DetailEvent {

  final int deviceId;

  InitEvent(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class LoadingEvent extends DetailEvent {
  final bool show;

  LoadingEvent({this.show}); 

  @override
  List<Object> get props => [show];
}

class ErrorEvent extends DetailEvent {
  final String msg;

  ErrorEvent(this.msg);

  @override
  List<Object> get props => [msg];

}

class UpdateInfoEvent extends DetailEvent {
  final DeviceDetailData deviceData;

  UpdateInfoEvent(this.deviceData);

  @override
  List<Object> get props => [deviceData];
}

class AddTemperatuerEvent extends DetailEvent {
}

class SubTemperatureEvent extends DetailEvent {
}

class ChangeModeEvent extends DetailEvent {
  final String mode;

  ChangeModeEvent(this.mode);

  @override
  List<Object> get props => [mode];
}

class PowerEvent extends DetailEvent {
  final int power;

  PowerEvent(this.power);

  @override
  List<Object> get props => [power];
}

class ChangeNameEvent extends DetailEvent {
  final String name;

  ChangeNameEvent(this.name);

  @override
  List<Object> get props => [name];
}

class DeleteDeviceEvent extends DetailEvent {
}
