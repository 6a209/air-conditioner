// #include "aliyun_iot.h"
// #include <AsyncMqttClient.h>
// #include <Crypto.h>
// #include <ESP8266WiFi.h>
// #include <ArduinoJson.h>

// static WiFiClient mqttWiFiClient;
// AsyncMqttClient mqttClient;

// static String productKey;
// static String deviceName;
// static String deviceSecret;
// static String mqttBroker;
// static IPAddress mqttBrokerIP;
// static String mqttClientID;
// static String mqttUsername;
// static String mqttPassword;
// static String mqttPostPropertyTopic;

// #define MQTT_HOST  "%pk%.iot-as-mqtt.cn-shanghai.aliyuncs.com"
// #define PORT 1883 

// // first %s pk, second deviceName 
// #define PROPERTY_POST  "/sys/%pk%/%dn%/thing/event/property/post"
// #define PROPERTY_SET  "/sys/%pk%/%dn%/thing/service/property/set"

// #define ACTION_POST  "/sys/%pk%/%dn%/thing/event/${tsl.event.identifer}/post"
// // #define SERVICE_SUBSCRIBE  "/sys/a1UJ1snG2BI/${deviceName}/thing/service/${tsl.event.identifer}" 


// void aliyunIoTInit(String& pk, String& dn, String& ds) {
//     productKey = pk;
//     deviceName = dn;
//     deviceSecret = ds;

//     mqttBroker = F(MQTT_HOST);
//     mqttBroker.replace("%pk%", pk);
//     mqttBroker.toLowerCase();

//     WiFi.hostByName(mqttBroker.c_str(), mqttBrokerIP);

//     // 生成 MQTT ClientID
//     String timestamp = F("");
//     timestamp += millis();
//     mqttClientID = F("%dn%&%pk%|securemode=3,signmethod=hmacsha256,timestamp=%timestamp%|");
//     mqttClientID.replace("%pk%", pk);
//     mqttClientID.replace("%dn%", dn);
//     mqttClientID.replace("%timestamp%", timestamp);

//     // 生成 MQTT Username
//     mqttUsername = dn;
//     mqttUsername += "&";
//     mqttUsername += pk;


//     // 生成 MQTT Password
//     String signcontent = F("clientId");
//     signcontent += dn + F("&") + pk + F("deviceName") + dn + F("productKey") + pk + F("timestamp") + timestamp;
//     mqttPassword = aliyunIoTGetSign(signcontent, ds);

//     String topic = F(PROPERTY_POST);
//     topic.replace("%pk%", productKey);
//     topic.replace("%dn%", deviceName);
//     mqttPostPropertyTopic = topic;

//     String log = F("Aliyun IoT options:\n");
//     log += "Broker: " + mqttBroker + "\n";
//     log += "BrokerIP: ";
//     log += String(mqttBrokerIP[0]) + "." + String(mqttBrokerIP[1]) + "." + String(mqttBrokerIP[2]) + "." + String(mqttBrokerIP[3]) + F("\n");
//     log += "ClientID: " + mqttClientID + "\n";
//     log += "Username: " + mqttUsername + "\n";
//     log += "Password: " + mqttPassword + "\n";
//     Serial.println(log);    
// }

// String aliyunIoTGetSign(String& signcontent, String& ds) {
//     SHA256HMAC hmac((const byte *)ds.c_str(), ds.length());
//     hmac.doUpdate((const byte *)signcontent.c_str(), signcontent.length());
//     byte authCode[SHA256HMAC_SIZE];
//     hmac.doFinal(authCode);
//     String sign = F("");
//     for (byte i = 0; i < SHA256HMAC_SIZE; ++i) {
//         if (authCode[i] < 0x10) {
//             sign += F("0");
//         }
//         sign += String(authCode[i], HEX);
//     }
//     String log = F("GetSign:\n");
//     log += signcontent + F("\n");
//     log += sign + F("\n");
//     Serial.println(log);
//     return sign;
// }

// // void propertyPost(JsonObject& params) {
// void propertyPost() {

//   StaticJsonBuffer<200> jsonParamsBuffer;
//   JsonObject& params = jsonParamsBuffer.createObject();

//   params["CurrentTemperature"] = 22;
//   params["TargetTemperature"] = 28; 
//   params["PowerSwitch"] = 1;
//   params["WorkMode"] = 3;

//   StaticJsonBuffer<300> jsonBuffer;
//   char output[300];
//   JsonObject& payload = jsonBuffer.createObject();
//   payload["id"] = millis();
//   payload["version"] = "1.0";
//   payload["method"] = "thing.event.property.post";
//   payload["params"] = params;

// //   params.printTo(output);
//   payload.printTo(output);
//   String outStr(output);
//   aliyunIoTPostProperty(outStr);
// }

// // 设备属性发布
// void aliyunPropertyPost(String dn, JsonObject property) {

// }

// // 设备事件发布
// void aliyunEventPost(String dn, String eventIdentifer, JsonObject info) {

// }



// void _onMqttConnect(bool sessionPresent) {
//   Serial.println("Connected to MQTT.");
//   Serial.print("Session present: ");
//   Serial.println(sessionPresent);
//   uint16_t packetIdSub = mqttClient.subscribe("test/lol", 2);
//   Serial.print("Subscribing at QoS 2, packetId: ");
//   Serial.println(packetIdSub);
//   mqttClient.publish("test/lol", 0, true, "test 1");
//   Serial.println("Publishing at QoS 0");
//   uint16_t packetIdPub1 = mqttClient.publish("test/lol", 1, true, "test 2");
//   Serial.print("Publishing at QoS 1, packetId: ");
//   Serial.println(packetIdPub1);
//   uint16_t packetIdPub2 = mqttClient.publish("test/lol", 2, true, "test 3");
//   Serial.print("Publishing at QoS 2, packetId: ");
//   Serial.println(packetIdPub2);

  
//   String propertySub(PROPERTY_SET);
//   propertySub.replace("%pk%", productKey);
//   propertySub.replace("%dn%", deviceName);
//   mqttClient.subscribe(propertySub.c_str(), 2);

//   propertyPost();

// }

// void onMqttDisconnect(AsyncMqttClientDisconnectReason reason) {
//   Serial.println("Disconnected from MQTT.");

// //   if (WiFi.isConnected()) {
// //     xTimerStart(mqttReconnectTimer, 0);
// //   }
// }

// void onMqttSubscribe(uint16_t packetId, uint8_t qos) {
//   Serial.println("Subscribe acknowledged.");
//   Serial.print("  packetId: ");
//   Serial.println(packetId);
//   Serial.print("  qos: ");
//   Serial.println(qos);
// }

// void onMqttUnsubscribe(uint16_t packetId) {
//   Serial.println("Unsubscribe acknowledged.");
//   Serial.print("  packetId: ");
//   Serial.println(packetId);
// }

// void _onMqttMessage(char* topic, char* payload, AsyncMqttClientMessageProperties properties, size_t len, size_t index, size_t total) {
//   Serial.println("Publish received.");
//   Serial.print("  topic: ");
//   Serial.println(topic);
//   Serial.print("  qos: ");
//   Serial.println(properties.qos);
//   Serial.print("  dup: ");
//   Serial.println(properties.dup);
//   Serial.print("  retain: ");
//   Serial.println(properties.retain);
//   Serial.print("  len: ");
//   Serial.println(len);
//   Serial.print("  index: ");
//   Serial.println(index);
//   Serial.print("  total: ");
//   Serial.println(total);
// }

// void onMqttPublish(uint16_t packetId) {
//   Serial.println("Publish acknowledged.");
//   Serial.print("  packetId: ");
//   Serial.println(packetId);
// }

// void aliyunIoTConnect() {
//     Serial.println("mqtt start connect");
//     mqttClient.onConnect(_onMqttConnect);
//     mqttClient.onDisconnect(onMqttDisconnect);
//     mqttClient.onSubscribe(onMqttSubscribe);
//     mqttClient.onUnsubscribe(onMqttUnsubscribe);
//     mqttClient.onMessage(_onMqttMessage);
//     mqttClient.onPublish(onMqttPublish);
//     mqttClient.setServer(mqttBrokerIP, PORT);
//     mqttClient.setClientId(mqttClientID.c_str());
//     mqttClient.setMaxTopicLength(512);
//     mqttClient.setKeepAlive(60);
//     mqttClient.setCredentials(mqttUsername.c_str(), mqttPassword.c_str());
//     mqttClient.connect();

// }

// String aliyunIoTBuildPayload(String& props) {
//     String payload = F("{\"id\":\"");
//     payload += millis();
//     payload += F("\",\"version\":\"1.0\",\"method\":\"thing.event.property.post\",\"params\":");
//     payload += props;
//     payload += F("}");
//     return payload;
// }

// bool aliyunIoTPostProperty(String& payload) {


//     bool result = false;
//     if (mqttClient.connected()) {
//         // String payload = aliyunIoTBuildPayload(props);
//         result = mqttClient.publish(mqttPostPropertyTopic.c_str(), 1, true, payload.c_str());
//         Serial.println(mqttPostPropertyTopic);
//         Serial.println("Post property payload:");
//         Serial.println(payload);
//     }

//     return result;
// }