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
#include <EEPROM.h>



#define UDP_PORT 9876
#define STATUS_LED 2

#define CONNECTING 0
#define CONNECTED 1

// Flash btn
#define RESET_BTN  0

String PK = String("IR");
// DN size 16
String DN = String("E68DEA31-260F-1C");

String uid = "uid";

char udpPackage[255]; // buffer for incoming packets
WiFiUDP udp;
Ticker udpTicker;

String mqttTmp = "";

void(* resetFunc) (void) = 0;

String readUid() {
  char uid[3];
  EEPROM.begin(2048);
  uid[0] = EEPROM.read(0);
  uid[1] = EEPROM.read(1);
  uid[2] = EEPROM.read(2);
  EEPROM.end();
  return String(uid);
}

void writeUid() {
  EEPROM.begin(2048);
  EEPROM.write(0, 'u');
  EEPROM.write(1, 'i');
  EEPROM.write(2, 'd');
  EEPROM.end();
}

void clearUid() {
  EEPROM.begin(2048);
  EEPROM.write(0, 0);
  EEPROM.write(1, 0);
  EEPROM.write(2, 0);
  EEPROM.end();
}


void sendUDPBroadcast()
{
  IPAddress ip = WiFi.localIP();
  ip[3] = 255;
  udp.beginPacket(ip, UDP_PORT);
  String sendData = PK + "&" + DN;
  udp.write(sendData.c_str());
  udp.endPacket();
}

/**
 *  uid data => uid#123 
 */
void parseBindData(String data)
{
  if (data.startsWith("uid#"))
  {
    uid = data.substring(4);
    writeUid();
    udpTicker.detach();
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


  payload[len] = '\0';
  if (len + index < total) {
    // if split more than 2 cause bug！
    mqttTmp = mqttTmp + String(payload);
    return;
  }

  String _topic = String(topic);
  if (_topic.startsWith("device/sendCommand"))
  {
    Serial.println("sendIRCode");

    String msg = mqttTmp + String(payload);
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
  } else if (_topic.startsWith("device/bind")){
    String msg = mqttTmp + String(payload);
    parseBindData(msg);
  }
  mqttTmp = "";
}

void status(int output) {
  // not connect 
  pinMode(STATUS_LED, OUTPUT);
  digitalWrite(STATUS_LED, output);
}


void setup()
{
  // put your setup code here, to run once:
  Serial.print("-------- setup ----------");
  Serial.begin(115200);

  status(CONNECTING);
  EEPROM.begin(2048);
  EEPROM.read(0);
  WiFiManager wifiManager;
  wifiManager.autoConnect("IR_WIFI");
  Serial.println("Connected to internet \n");
  status(CONNECTED);
  // init mqtt 
  initMqtt(DN.c_str(), onMqttConnect, onMqttMessage);

  // init irremote 
  initIR();

  // udp broadcast if need
  // Serial.printf("uid is => %s", readUid());
  if (readUid() != "uid")
  {
    udp.begin(UDP_PORT);
    // not bind, send broadcast wait bind
    udpTicker.attach(5, sendUDPBroadcast);
  }
  // init reset btn
  pinMode(RESET_BTN, INPUT);
}


void onReceiveIRData(uint16_t *rawdata, int len)
{
  Serial.println("onReceive ir data");
  String topic = String("device/receiveIR/") + PK + "/" + DN;
  String outStr = intArray2Json(rawdata, len);
  publishMsg(topic, outStr);
  // dumpRawData();
}

int resetCount = 0;

void reset() 
{
  while(LOW == digitalRead(RESET_BTN)) {
    delay(200); 
    resetCount ++;
    if (resetCount >= 25) {
      resetCount = 0;
      WiFi.disconnect();
      String topic = String("device/unbind/") + PK + "/" + DN;
      String msg = String("unbind");
      publishMsg(topic, msg);
      clearUid();
      delay(150); 
      resetFunc();
      return;
    }
  }
  resetCount = 0;
}



void loop()
{
  reset();
  receiveIRData(onReceiveIRData);
}