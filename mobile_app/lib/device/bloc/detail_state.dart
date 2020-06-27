

import 'package:equatable/equatable.dart';
import 'package:mobile_app/device/models/device_data.dart';

abstract class DetailState extends Equatable {}


class LoadingState extends DetailState {

  final bool show;
  LoadingState({this.show});

  @override
  List<Object> get props => [show];
}

class InitState extends DetailState {

  final DeviceDetailData deviceData;

  InitState(this.deviceData);

  @override
  List<Object> get props => [deviceData];
}

class UpdateInfoState extends DetailState {

  final DeviceDetailData deviceData;

  UpdateInfoState(this.deviceData);

  @override
  List<Object> get props => [deviceData];

}

class RenameState extends DetailState {
  
  final String name;

  RenameState(this.name);

  @override
  List<Object> get props => [name];

}

class DeleteDeviceState extends DetailState {

  final String id;

  DeleteDeviceState(this.id);

  @override
  List<Object> get props => [id];

}

class ErrorState extends DetailState {

  final String msg;

  ErrorState(this.msg);

  @override
  List<Object> get props => [msg];
}