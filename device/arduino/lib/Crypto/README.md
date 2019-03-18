# ESP8266 Crypto

This is a minimal, lightweight crypto library for the ESP8266 IOT device.  It 
provides the following functions:

* SHA256
* AES 128 and 256
* SHA256HMAC
* RNG

The SHA256 and AES implementations are based upon the implementations in axTLS 
except ported to the ESP8266 Arduino platform, credit to Cameron Rich for the 
axTLS project.

## Usage

### SHA256HMAC

The following snippet demonstrates how to compute the SHA256 HMAC authentication 
code for a message.

    /* Include the crypto library into your project */
    #include <Crypto.h>
    
    /* The length of the key we will use for this HMAC */
    /* The key can be of any length, 16 and 32 are common */
    #define KEY_LENGTH 16
    
    /* Define our */
    byte key[KEY_LENGTH] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
    
    /* Create the HMAC instance with our key */
    SHA256HMAC hmac(key, KEY_LENGTH);
    
    /* Update the HMAC with just a plain string (null terminated) */
    hmac.doUpdate("Hello World");
    
    /* And or with a string and length */
    const char *goodbye = "GoodBye World";
    hmac.doUpdate(goodbye, strlen(goodbye));
    
    /* And or with a binary message */
    byte message[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
    hmac.doUpdate(message, sizeof(message));
    
    /* Finish the HMAC calculation and return the authentication code */
    byte authCode[SHA256HMAC_SIZE];
    hmac.doFinal(authCode);
    
    /* authCode now contains our 32 byte authentication code */
    for (byte i; i < SHA256HMAC_SIZE; i++)
    {
        Serial.print(authCode[i], HEX);
    }

### SHA256

The following snippet demonstrates how to compute the SHA256 hash of a message.

    /* Create a SHA256 hash */
    SHA256 hasher;
    
    /* Update the hash with your message, as many times as you like */
    const char *hello = "Hello World";
    hasher.doUpdate(hello, strlen(hello));
    
    /* Update the hash with just a plain string*/
    hasher.doUpdate("Goodbye World");
    
    /* Update the hash with a binary message */
    byte message[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
    hasher.doUpdate(message, sizeof(message));
    
    /* Compute the final hash */
    byte hash[SHA256_SIZE];
    hasher.doFinal(hash);
    
    /* hash now contains our 32 byte hash */
    for (byte i; i < SHA256_SIZE; i++)
    {
        Serial.print(hash[i], HEX);
    }

## License

ESP8266 Crypto
Copyright (c) 2016, Chris Ellis, with portions derived from axTLS
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Author

Chris Ellis

Twitter: @intrbiz

Copyright (c) Chris Ellis 2016
