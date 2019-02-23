#include <Arduino.h>
#include <WiFiClient.h>
#include <ESP8266WiFi.h>      

#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include <WiFiManager.h> 
#include <AsyncMqttClient.h>
#include "aliyun_iot.h"
#include <ArduinoJson.h>


// void updateProperty() {
//   StaticJsonBuffer<200> jsonBuffer;
//   char output[200];
//   JsonObject& property = jsonBuffer.createObject();
//   property["CurrentTemperature"] = 20;
//   property["TargetTemperature"] = 26; 
//   property["PowerSwitch"] = 0;
//   property["WorkMode"] = 2;
//   property.printTo(output);

//   String outStr(output);
//   aliyunIoTPostProperty(outStr);
// }


void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  WiFiManager wifiManager;
  Serial.print("--------------------------");
  wifiManager.autoConnect("AutoConnectAP");
  // wifiManager.autoConnect("huahua_iphone", "mogujie123");
  Serial.println("Connected to internet \n");

  String pk = F("a1GNYDPL460");
  String dn = F("PZe69E6SdYJUpLGqR3Tg");
  String ds = F("K3a7mssrNRilGPQwaD8VrKr4aGUsFmXr");
  aliyunIoTInit(pk, dn, ds);
  aliyunIoTConnect();

  // updateProperty();
}




void loop() {
  // put your main code here, to run repeatedly:
  // Serial.println("-------------------------");
}

// 控制空调

void syncIRcode() {

}

void setMode(int value) {
}


void setTemperature(int value) {
}

void closeAirConditioner() {
}

void openAirConditioner() {
}

// 学习红外
void updateReceiveCode() {
   
}