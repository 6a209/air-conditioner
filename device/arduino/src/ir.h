
/**
 * 红外控制  
 */
#ifndef IR_H_
#define IR_H_
#include <Arduino.h>

void initIR();

// void initIRSend();

void receiveIRData(void (*onReceiveData)(uint16_t data[], int len));

void dumpRawData();

void sendRawData(uint16_t rawData[]);

#endif