#include <Arduino.h>
#include <WiFiClient.h>
#include <ESP8266WiFi.h>      
#include <WiFiUdp.h>

#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include <WiFiManager.h> 
#include <AsyncMqttClient.h>
#include <ArduinoJson.h>
#include "ir.h"

#include "custom_mqtt.h"
#include <Ticker.h>

String PK = String("IR");
String DN = String("F92BA2A2-BE6D-45C1-9C95-A34E082E638D");
String SK = String("c274761d-9a8c-42c2-992c-0974c512f4d4");

// 
String uid = "uid";

#define UDP_PORT 9876
char udpPackage[255];  // buffer for incoming packets
WiFiUDP udp;
Ticker UDPTicker;

void sendUDPBroadcast() {
  IPAddress ip = WiFi.localIP();
  ip[3] = 255;
  udp.beginPacket(ip, UDP_PORT);
  char output[512];
  DynamicJsonDocument doc(512);
  doc["code"] = 200;
  doc["msg"] = "ok";
  doc["pk"] = PK.c_str(); 
  doc["dn"] = DN.c_str();
  doc["sk"] = SK.c_str();
  // String sendData = PK + "&" + DN + "&" + SK;
  serializeJson(doc, output);
  udp.write(output);
  udp.endPacket();
}

void parseBindData(String data) {
  if (data.startsWith("uid")) {
    uid = data.substring(3);
  }
}

void onMqttConnect(bool sessionPresent) {
  // publish online
  String topic = String("device/online");
  publishMsg(topic, PK + "&" + DN + "&" + SK);

  topic = String("device/sendCommand") + "/" + PK + "/" + DN;
  subscribe(topic);
}

void onMqttMessage(char* topic, char* payload, AsyncMqttClientMessageProperties properties,
                   size_t len, size_t index, size_t total) {
  String _topic = String(topic);                   
  if (_topic.startsWith("device/sendCommand")) {
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
  udp.begin(UDP_PORT);

  initMqtt(onMqttConnect, onMqttMessage);
  initIR();

  if (uid.equals("uid")) {
    // not bind, send broadcast wait bind
    UDPTicker.attach(5, sendUDPBroadcast);
  }
}

void onReceiveIRData(uint16_t data[], int len) {
  Serial.println("onReceive ir data");


  String topic = String("device/receiveIR/") + PK + "/" + DN;

  char output[2048];
  DynamicJsonDocument doc(2048);
  JsonObject root = doc.to<JsonObject>();
  JsonArray dataArray = root.createNestedArray("data");
  for (int i = 0; i < len; i ++) {
    dataArray.add(data[i]);
  }
  serializeJson(doc, output);
  String outStr = String(output);
  publishMsg(topic, outStr);
  // dumpRawData();
}

void loop() {
  receiveIRData(onReceiveIRData);
  int packageSize = udp.parsePacket(); 
  if (packageSize) {
    int len = udp.read(udpPackage, 255);
    udpPackage[len] = 0;
    parseBindData(String(udpPackage));
  }
}