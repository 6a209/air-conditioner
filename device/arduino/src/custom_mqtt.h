#include <AsyncMqttClient.h>

typedef void (*OnMqttConnect)(bool session);
typedef void (*OnMqttMessage)(char* topic, char* payload, AsyncMqttClientMessageProperties properties, size_t len, size_t index, size_t total);

void initMqtt(OnMqttConnect connect, OnMqttMessage message);

void publishMsg(String& topic, String& payload);

void subscribe(String& topic);
