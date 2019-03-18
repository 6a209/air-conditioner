#include "ir.h"
#include <IRrecv.h>
#include <IRremoteESP8266.h>
#include <IRutils.h>
#include <IRsend.h>


#define IR_LED 4  // ESP8266 GPIO pin to use. Recommended: 4 (D2).
IRsend irsend(IR_LED);  // Set the GPIO to be used to sending the message.

// (D5)
const uint16_t recvPin = 14;

const uint16_t captureBufferSize = 1024;
const uint8_t timeout = 50;
const uint16_t minUnknownSize = 12;
IRrecv irrecv(recvPin, captureBufferSize, timeout, true);

decode_results results;  // Somewhere to store the results

void initIR() {
    irsend.begin();
    irrecv.enableIRIn();
}

void receiveIRData(void (*onReceiveData)(uint16_t data[])){
    if (irrecv.decode(&results)) {
        uint16_t rawData[results.rawlen];
        for (int i = 0; i < results.rawlen; i ++) {
            rawData[i] = results.rawbuf[i] * 2;
        } 
        onReceiveData(rawData);
    }
}

void sendRawData(uint16_t data[]) {
    int len = sizeof(data) / sizeof(data[0]);
    irsend.sendRaw(data, len, 38);
}

void dumpRawData() {

    uint32_t now = millis();
    Serial.printf("Timestamp : %06u.%03u\n", now / 1000, now % 1000);
    if (results.overflow)
      Serial.printf(
          "WARNING: IR code is too big for buffer (>= %d). "
          "This result shouldn't be trusted until this is resolved. "
          "Edit & increase kCaptureBufferSize.\n",
          captureBufferSize);
    // Display the basic output of what we found.
    Serial.print(resultToHumanReadableBasic(&results));
    // dumpACInfo(&results);  // Display any extra A/C info if we have it.
    yield();  // Feed the WDT as the text output can take a while to print.

    // Display the library version the message was captured with.
    Serial.print("Library   : v");
    Serial.println(_IRREMOTEESP8266_VERSION_);
    Serial.println();

    // Output RAW timing info of the result.
    Serial.println(resultToTimingInfo(&results));
    yield();  // Feed the WDT (again)

    // Output the results as source code
    Serial.println(resultToSourceCode(&results));
    Serial.println("");  // Blank line between entries
    yield();             // Feed the WDT (again)
}