
#include "custom_mqtt.h"
#include <ESP8266WiFi.h>

AsyncMqttClient mqttClient;

// #define MQTT_HOST IPAddress(192, 168, 4, 92)
#define MQTT_HOST "air.6a209.club"
#define PORT 1883

OnMqttConnect onConnect;
OnMqttMessage onMessage; 


void _onMqttConnect(bool sessionPresent) {
  Serial.println("Connected to MQTT.");
  Serial.print("Session present: ");
  Serial.println(sessionPresent);
  uint16_t packetIdSub = mqttClient.subscribe("test/lol", 2);
  Serial.print("Subscribing at QoS 2, packetId: ");
  Serial.println(packetIdSub);
  mqttClient.publish("test/lol", 0, true, "test 1");
  Serial.println("Publishing at QoS 0");
  uint16_t packetIdPub1 = mqttClient.publish("test/lol", 1, true, "test 2");
  Serial.print("Publishing at QoS 1, packetId: ");
  Serial.println(packetIdPub1);
  uint16_t packetIdPub2 = mqttClient.publish("test/lol", 2, true, "test 3");
  Serial.print("Publishing at QoS 2, packetId: ");
  Serial.println(packetIdPub2);

  onConnect(sessionPresent); 
}

void onMqttDisconnect(AsyncMqttClientDisconnectReason reason) {
  Serial.println("Disconnected from MQTT.");
}

void onMqttSubscribe(uint16_t packetId, uint8_t qos) {
  Serial.println("Subscribe acknowledged.");
  Serial.print("  packetId: ");
  Serial.println(packetId);
  Serial.print("  qos: ");
  Serial.println(qos);
}

void onMqttUnsubscribe(uint16_t packetId) {
  Serial.println("Unsubscribe acknowledged.");
  Serial.print("  packetId: ");
  Serial.println(packetId);
}

void _onMqttMessage(char* topic, char* payload, AsyncMqttClientMessageProperties properties, size_t len, size_t index, size_t total) {
  Serial.println("Publish received.");
  Serial.print("  topic: ");
  Serial.println(topic);
  Serial.print("  qos: ");
  Serial.println(properties.qos);
  Serial.print("  dup: ");
  Serial.println(properties.dup);
  Serial.print("  retain: ");
  Serial.println(properties.retain);
  Serial.print("  len: ");
  Serial.println(len);
  Serial.print("  index: ");
  Serial.println(index);
  Serial.print("  total: ");
  Serial.println(total);

  onMessage(topic, payload, properties, len, index, total);
}

void onMqttPublish(uint16_t packetId) {
  Serial.println("Publish acknowledged.");
  Serial.print("  packetId: ");
  Serial.println(packetId);
}


void initMqtt(const char* clientId, OnMqttConnect connect, OnMqttMessage onMsg) {

    onConnect = connect;
    onMessage = onMsg;

    mqttClient.setClientId(clientId);
    mqttClient.onConnect(_onMqttConnect);
    mqttClient.onDisconnect(onMqttDisconnect);
    mqttClient.onSubscribe(onMqttSubscribe);
    mqttClient.onUnsubscribe(onMqttUnsubscribe);
    mqttClient.onMessage(_onMqttMessage);
    mqttClient.onPublish(onMqttPublish);
    mqttClient.setServer(MQTT_HOST, PORT);
    mqttClient.setMaxTopicLength(512);
    mqttClient.setKeepAlive(60);
    // mqttClient.setCredentials(mqttUsername.c_str(), mqttPassword.c_str());
    mqttClient.connect();
}

void publishMsg(String& topic, String& payload) {
  
  if (mqttClient.connected()) {
    Serial.print(topic.c_str());
    mqttClient.publish(topic.c_str(), 1, true, payload.c_str());
  } else {
    Serial.print("mqtt not connected");
  }
}

void subscribe(String& topic) {
  mqttClient.subscribe(topic.c_str(), 2);
}