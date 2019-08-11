

#ifndef JSON_UTIL_H_
#define JSON_UTIL_H_ 
#include <Arduino.h>

String int2String(uint16_t input ) {
  String result = "";
  do {
    char c = input % 10;
    input /= 10;

    if (c < 10)
      c += '0';
    else
      c += 'A' - 10;
    result = c + result;
  } while (input);
  return result;
}

String intArray2Json(uint16_t *rawdata, int len) {
  String json = "{\"data\":[";
  for (int i = 0; i < len; i++) {
    json += int2String(rawdata[i]); 
    if (i < len - 1) {
      json += ",";
    }
  } 
  json += "]}";
  return json;
}

void json2intArray(String jsonStr, uint16_t arr[], int len) {
  if (len < 2) return;
  jsonStr = jsonStr.substring(1, jsonStr.length() - 1);
  char *c = strtok((char*)(jsonStr.c_str()), ","); 
  String s = String(c);
  int i =  0;
  while (c != NULL) {
    String s = String(c);
    arr[i++] = s.toInt();
    c = strtok(NULL, ",");
  } 
}


#endif
