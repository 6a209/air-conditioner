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
String DN = String("F92BA2A2-BE6D-45C1-9C95-A34E082E638D");
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

    

    // char payloadArray[total];
    // strncpy(payloadArray, payload, total);

    // DynamicJsonDocument doc(4086);
    // DeserializationError err = deserializeJson(doc, msg);
    // if (err) {
    //   Serial.print(F("deserializeJson() failed with code "));
    //   Serial.println(err.c_str());
    //   return; 
    // }
    // JsonArray array = doc["data"];
    // int size = array.size();
    // Serial.printf("data size %d", size);
    // uint16_t data[size];
    // for (int i = 0; i < size; i++)
    // {
    //   data[i] = array[i];
    // }
    // // send ir data
    // sendRawData(data, size);

    // String topic = String("device/status/" + PK + "/" + DN);
    // publishMsg(topic, msg);
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

  // String pk = F("a1AG1kNKF0E");
  // String dn = F("HFn5RuPU9lGFHRRebJA8");
  // String ds = F("YkmGJQ31zokDFLZOd6coS8KCklFumHdz");
  // aliyunIoTInit(pk, dn, ds);
  // aliyunIoTConnect();
  udp.begin(UDP_PORT);

  initMqtt(onMqttConnect, onMqttMessage);
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
  // if (test) {

  // uint16_t rawdData[126] = {9066,4570,620,666,546,666,542,666,544,1742,588,628,582,666,546,664,570,1716,586,682,544,668,544,1740,588,626,588,626,582,1744,610,604,582,666,544,684,568,1720,538,674,588,662,544,628,582,628,582,628,584,626,582,682,544,666,544,628,614,634,544,666,544,670,540,628,582,668,550,676,544,668,542,668,544,668,544,628,582,668,568,602,584,668,544,682,550,1742,568,646,578,1742,588,626,584,632,582,626,580,670,544,644,584,666,544,634,532,714,544,1740,572,1726,620,666,544,668,544,682,544,666,544,668,544,668,546,666,544,668};
  // uint16_t rawData[147] = {9110, 4600,  572, 668,  548, 666,  568, 644,  542, 1832,  502, 672,  496, 714,  548, 664,  546, 1830,  502, 1804,  494, 718,  544, 1832,  502, 668,  538, 676,  538, 1794,  544, 670,  544, 670,  544, 736,448, 1832,  544, 668,  580, 634,  544, 668,  544, 670,  548, 662,  544, 672,  496, 730,  546, 672,  496, 714,  580, 676,  530, 642,  544, 668,  542, 672,  544, 668,  544, 736,  448, 762,  498, 608,  598, 674,  544, 672,  540, 670,  544, 674,  494, 714,  544, 688,  544, 768,  470, 1766,  494, 1838,  494, 714,  540, 672,  546, 668,  542, 670,  542, 678,  580, 642,  540, 626,  592, 714,  494, 674,  542, 674,  496, 712,  544, 670,  546, 684,  544, 714,  494, 672,  572, 640,  548, 666,  544, 670,  544, 668,  550, 658,  502, 732,  574, 640,  542, 1790,  546, 1786,  548, 666,  544, 1738,  632, 620,  576, 648,  542};
  // uint16_t rawData[147] = {25,9098,4584,586,622,590,622,612,598,590,1736,594,622,590,622,590,622,590,1736,594,638,588,622,612,1716,592,620,592,624,584,1742,592,624,590,622,590,640,584,1740,592,622,592,622,590,622,590,622,598,614,590,622,590,638,590,622,614,598,590,598,614,622,590,622,610,602,592,624,536,690,590,624,590,622,590,622,592,620,590,622,618,596,590,626,586,642,588,1736,618,598,590,1738,592,622,590,622,592,620,592,622,590,636,592,1738,592,622,590,622,612,1716,588,626,590,620,590,622,592,638,590,622,590,624,588,624,588,622,614,600,588,622,590,628,612,610,590,622,590,1736,594,1738,590,626,612,1714,594,622,590,624};

  // uint16_t rawData[147] = {9098, 4628,  494, 716,  540, 670,  544, 668,  542, 1790,  542, 670,  544, 672,  494, 714,  570, 1760,  540, 688,  544, 668,  542, 1788,  578, 632,  544, 668,  542, 1788,  576, 636,  494, 720,  494, 730,  546, 1784,  544, 668,  544, 668,  544, 668,  544, 670,  544, 666,  546, 666,  542, 686,  542, 670,  576, 636,  544, 674,  494, 712,  544, 668,  544, 668,  578, 634,  542, 686,  542, 670,  544, 666,  544, 670,  574, 640,  536, 672,  546, 668,  544, 668,  542, 686,  542, 1788,  544, 668,  542, 1786,  546, 668,  598, 612,  546, 668,  538, 674,  536, 692,  496, 716,  548, 664,  544, 668,  544, 712,  498, 1788,  544, 668,  544, 670,  544, 684,  542, 670,  544, 668,  544, 668,  544, 668,  550, 664,  546, 668,  544, 670,  496, 732,  542, 670,  544, 1792,  494, 1798,  576, 672,  496, 1830,  568, 644,  544, 668,  494};

  // sendRawData(rawData, 147);
  // }
  // delay(1000);
}