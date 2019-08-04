import 'package:mqtt_client/mqtt_client.dart';
import 'package:rxdart/rxdart.dart';

class MqttData {
  String topic;
  String message;

  MqttData(this.topic, this.message);
}

class MqttManager {
  factory MqttManager.instance() => _sharedInstance();

  static MqttManager _instance;
  MqttClient client;

  MqttManager._() {}

  PublishSubject<MqttData> messageSubject = new PublishSubject();

  static MqttManager _sharedInstance() {
    if (null == _instance) {
      _instance = MqttManager._();
    }
    return _instance;
  }

  void init() {
    client = MqttClient("air.6a209.club", '');
    client.onConnected = onMqttConnected;
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .keepAliveFor(60) // Must agree with the keep alive set above or not set
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;
    client.onDisconnected = () {
      print("client Disconnected");
    };
    client.connect();

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      print("___listen");
      print("c leng +.."  + c.length.toString());
      final MqttReceivedMessage recMess = c[0];
      final MqttPublishMessage mpm = recMess.payload;
      String message = MqttPublishPayload.bytesToStringAsString(mpm.payload.message);
      messageSubject.sink.add(MqttData(recMess.topic, message));
    });
  }

  subscribe(String topic, MqttQos qos) {
    print(client.connectionStatus.state);
    print(client.connectionState);
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print("mqtt subscribe, topic is -> " + topic);
      client.subscribe(topic, qos);
      return true;
    }
    return false;
  }


  unsubscribe(String topic) {
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      client.unsubscribe(topic);
      return true;
    }
    return false;
  }

  void onMqttConnected() {
    print("mqtt connected");
  }
}
