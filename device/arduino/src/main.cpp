#include <Arduino.h>
#include <WiFiClient.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>

#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include <WiFiManager.h>
#include <AsyncMqttClient.h>
#include "ir.h"
#include "json_util.h"

#include "custom_mqtt.h"
#include <Ticker.h>

String PK = String("IR");

// DN size 16
String DN = String("E68DEA31-260F-1C");
// String SK = String("c274761d-9a8c-42c2-992c-0974c512f4d4");

//
String uid = "uid";

#define UDP_PORT 9876
char udpPackage[255]; // buffer for incoming packets
WiFiUDP udp;
Ticker UDPTicker;

String mqttTmp = "";

// int curTemperture;
// // 0 off, 1 on
// int power;
// // 0 制冷，1 制热，2 除湿， 3 通风
// int mode;

void sendUDPBroadcast()
{
  IPAddress ip = WiFi.localIP();
  ip[3] = 255;
  udp.beginPacket(ip, UDP_PORT);
  String sendData = PK + "&" + DN;
  udp.write(sendData.c_str());
  udp.endPacket();
}

void parseBindData(String data)
{
  if (data.startsWith("uid"))
  {
    uid = data.substring(3);
  }
}

void onMqttConnect(bool sessionPresent)
{
  // publish online
  String topic = String("device/online/" + PK + "/" + DN);
  publishMsg(topic, PK + "&" + DN);

  topic = String("device/sendCommand") + "/" + PK + "/" + DN;
  subscribe(topic);
}

void onMqttMessage(char *topic, char *payload, AsyncMqttClientMessageProperties properties,
                   size_t len, size_t index, size_t total)
{

  if (len + index < total) {
    // if split more than 2 cause bug！
    payload[len] = '\0';
    mqttTmp = mqttTmp + String(payload);
    return;
  }

  String _topic = String(topic);
  if (_topic.startsWith("device/sendCommand"))
  {
    Serial.println("sendIRCode");
    payload[len] = '\0';

    String msg = mqttTmp + String(payload);
    mqttTmp = "";
    Serial.println(msg.c_str());
    Serial.printf("len => %d", msg.length());

    // info&data&len
    int splitIdx = msg.indexOf("&");
    if (-1 == splitIdx) {
      return; 
    }
    String infoMsg = msg.substring(0, splitIdx);
    String commandData = msg.substring(splitIdx + 1);

    splitIdx = commandData.indexOf("&");
    if (-1 == splitIdx) {
      return;
    }
    String command = commandData.substring(0, splitIdx); 
    String lenStr = commandData.substring(splitIdx + 1);
    int commandLen = lenStr.toInt(); 

    Serial.println("---************>>>>");
    Serial.println(infoMsg.c_str());
    Serial.println(command.c_str());
    Serial.println(lenStr.c_str());
    uint16_t data[commandLen]; 
    json2intArray(command, data, commandLen);

    sendRawData(data, commandLen);
    String topic = String("device/status/" + PK + "/" + DN);
    publishMsg(topic, infoMsg);
  }
}


void setup()
{
  // put your setup code here, to run once:
  Serial.begin(115200);
  WiFiManager wifiManager;
  Serial.print("--------------------------");
  wifiManager.autoConnect("AutoConnectAP");
  Serial.println("Connected to internet \n");

  udp.begin(UDP_PORT);
  String clientId = PK + "_" + DN;
  initMqtt(clientId, onMqttConnect, onMqttMessage);
  initIR();

  if (uid.equals("uid"))
  {
    // not bind, send broadcast wait bind
    UDPTicker.attach(5, sendUDPBroadcast);
  }
}


void onReceiveIRData(uint16_t *rawdata, int len)
{
  Serial.println("onReceive ir data");
  String topic = String("device/receiveIR/") + PK + "/" + DN;
  String outStr = intArray2Json(rawdata, len);
  publishMsg(topic, outStr);
  // dumpRawData();
}



bool test = true;

void loop()
{
  receiveIRData(onReceiveIRData);

  int packageSize = udp.parsePacket();
  if (packageSize)
  {
    int len = udp.read(udpPackage, 255);
    udpPackage[len] = 0;
    parseBindData(String(udpPackage));
  }
}