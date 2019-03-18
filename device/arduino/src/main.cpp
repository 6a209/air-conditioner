#include <Arduino.h>
#include <WiFiClient.h>
#include <ESP8266WiFi.h>      

#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include <WiFiManager.h> 
#include <AsyncMqttClient.h>
#include <ArduinoJson.h>
#include "aliyun_iot.h"
#include "ir.h"



void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  WiFiManager wifiManager;
  Serial.print("--------------------------");
  wifiManager.autoConnect("AutoConnectAP");
  Serial.println("Connected to internet \n");

  String pk = F("a1AG1kNKF0E");
  String dn = F("HFn5RuPU9lGFHRRebJA8");
  String ds = F("YkmGJQ31zokDFLZOd6coS8KCklFumHdz");
  aliyunIoTInit(pk, dn, ds);
  aliyunIoTConnect();

  initIR();
}

void onAliyunMqttConnect() {
}

void onAliyunMqttMessage(char* topic, char* payload, AsyncMqttClientMessageProperties properties, size_t len, size_t index, size_t total) {
  if (strcmp(topic, "sendIRCode")) {
    Serial.print("sendIRCode");
  }
}


void onReceiveIRData(uint16_t data[]) {
  Serial.println("onReceive ir data");
  dumpRawData();
}

void loop() {
  receiveIRData(onReceiveIRData);
}