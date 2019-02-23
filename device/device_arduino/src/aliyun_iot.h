#include <Arduino.h>

void aliyunIoTInit(String& pk, String& dn, String& ds);

void aliyunIoTConnect();

bool aliyunIoTCheckConnection();

String aliyunIoTGetSign(String& signcontent, String& ds); 

void aliyunIoTLoop();

bool aliyunIoTPostProperty(String& props);