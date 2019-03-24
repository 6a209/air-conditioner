#include <Arduino.h>
#include <WiFiClient.h>
#include <ESP8266WiFi.h>      

#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include <WiFiManager.h> 
#include <AsyncMqttClient.h>
#include <ArduinoJson.h>
#include "ir.h"

#include "custom_mqtt.h"

String PK = String("IR");
String DN = String("F92BA2A2-BE6D-45C1-9C95-A34E082E638D");

void onMqttConnect(bool sessionPresent) {
  // publish online
  String topic = String("device/online");
  publishMsg(topic, PK + "&" + DN);

  topic = PK + "&" + DN + "&" +  String("device/sendCommand");
  subscribe(topic);
}

void onMqttMessage(char* topic, char* payload, AsyncMqttClientMessageProperties properties,
                   size_t len, size_t index, size_t total) {
  String _topic = String(topic);                   
  if (_topic.endsWith("device/sendCommand")) {
    Serial.print("sendIRCode");
    DynamicJsonDocument doc(2048);
    JsonObject root = doc.as<JsonObject>();
    deserializeJson(doc, payload);
    JsonArray array = root["data"];
    int size = array.size();
    uint16_t data[size];
    for (int i = 0; i < size; i++) {
      data[i] = array[i];
    }
    // send ir data 
    sendRawData(data);
  }
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  WiFiManager wifiManager;
  Serial.print("--------------------------");
  wifiManager.autoConnect("AutoConnectAP");
  Serial.println("Connected to internet \n");

  // String pk = F("a1AG1kNKF0E");
  // String dn = F("HFn5RuPU9lGFHRRebJA8");
  // String ds = F("YkmGJQ31zokDFLZOd6coS8KCklFumHdz");
  // aliyunIoTInit(pk, dn, ds);
  // aliyunIoTConnect();
  initMqtt(onMqttConnect, onMqttMessage);
  initIR();
}

void onReceiveIRData(uint16_t data[]) {
  Serial.println("onReceive ir data");
  String topic = PK + "&" + DN + "&" + String("device/receiveIR");

  char output[2048];
  DynamicJsonDocument doc(2048);
  JsonObject root = doc.to<JsonObject>();
  JsonArray dataArray = root.createNestedArray("data");
  int length = sizeof(data) / sizeof(data[0]);
  for (int i = 0; i < length; i ++) {
    dataArray.add(data[i]);
  }
  serializeJson(doc, output);
  String outStr = String(output);
  publishMsg(topic, outStr);
  dumpRawData();
}

void loop() {
  receiveIRData(onReceiveIRData);
}