
// teensy + esp8266 with firmare 0.9.5.2 or higher
#define WLAN_SSID  "togbane"
#define WLAN_PASS  "limpistol"
#define WLAN_ADDR  "1.2.3.23" // ctrl machine
#define ADDR "/xy1" //incoming osc addy
#define PORT  2999  //incoming osc port
uint8_t buf[16]; // bufsize
char indata[16]; // fra 12 til 16 bytes
char inbuffer[256];
char OKrn[] = "OK\r\n";

// timer stuff
unsigned long lastTimeGuard = 0;
const long timeGuardInterval = 500;
unsigned long timeElapsed;

int led = 13;

bool ignitionIsNeededFlag = true;

byte wait_for_esp_response(int timeout, char* term = OKrn) {
    unsigned long t = millis();
    bool found = false;
    int i = 0;
    int len = strlen(term);
    while (millis() < t + timeout) {
        if (Serial1.available()) {
            inbuffer[i++] = Serial1.read();
            if (i >= len) {
                if (strncmp(inbuffer + i - len, term, len) == 0) {
                    found = true;
                    break;
                }
            }
        }
    }
    inbuffer[i] = 0;
    return found;
}

// double dual L293B H-bridge
// motor 1
int in1PinMotor1 = 7; //digital - dir
int in2PinMotor1 = 8; //digital - dir
int enablePinMotor1 = 9; // pwm
int speedMotor1 = 0;
bool reverseMotor1 = false;

void setup() {
    /*----------------------*/
    /*      OSC message     */
    /*----------------------*/
    buf[0] = 47;   // /
    buf[1] = 115;  // s
    buf[2] = 116;  // t
    buf[3] = 105;  // i
    buf[4] = 0;
    buf[5] = 0;
    buf[6] = 0;
    buf[7] = 0;
    buf[8] = 44;   // ,
    buf[9] = 105;  // i
    buf[10] = 0;
    buf[11] = 0;
    buf[12] = 0;   // motor direction
    buf[13] = 0;   // motor speed
    buf[14] = 0;   // additional
    buf[15] = 0;   // additional


    /*----------------------*/
    /*     Pin Settings     */
    /*----------------------*/
    pinMode(led, OUTPUT);

    // changing pin 5, 6, 9, 10, 20, 21, 22, 23	PWM freq on Timer FTM0
    analogWriteFrequency(5, 187500); // 8 BIT = 0-255 (CPU speedMotor1 96MHz)
    //analogWriteFrequency(enablePinMotor1, 46875); // 10 BIT = 0-1023 (CPU speedMotor1 96MHz)

    // motor 1
    pinMode(in1PinMotor1, OUTPUT);
    pinMode(in2PinMotor1, OUTPUT);
    pinMode(enablePinMotor1, OUTPUT);

    /*--------------------------------------*/
    /*  Initiate Serial and do AT commands  */
    /*--------------------------------------*/

    Serial.begin(115200);   //usb serial for feedback
    //while(!Serial){} //wait for serial;
    delay(400);
    Serial1.begin(115200);  //teensy hardware pins 0 and 1, for sending AT commands and piping OSC to Teensy
    Serial.println("starting");
    Serial.print("hard reset...");
    pinMode(4, OUTPUT); // reset
    delay(10);
    pinMode(4, INPUT); // reset off
    Serial.print("ready...");
    boolean resp = wait_for_esp_response(1000, "ready\r\n");
    Serial.println(resp);
    Serial.print("mode1...");
    Serial1.println("AT+CWMODE=1");
    resp = wait_for_esp_response(1000);
    Serial.println(resp);
    Serial.print("connecting...");
    do {
        Serial1.print("AT+CWJAP=\"");
        Serial1.print(WLAN_SSID);
        Serial1.print("\",\"");
        Serial1.print(WLAN_PASS);
        Serial1.println("\"");
        resp = wait_for_esp_response(3000);
        Serial.print(resp);
    } while (!resp);
    Serial.print("\nmux1...");
    Serial1.println("AT+CIPMUX=1");
    resp = wait_for_esp_response(1000);
    Serial.println(resp);
    Serial.print("udp...");
    Serial1.print("AT+CIPSTART=4,\"UDP\",\"");
    Serial1.print(WLAN_ADDR);
    Serial1.print("\",57120,");
    Serial1.print(PORT);
    Serial1.println(",0");
    resp = wait_for_esp_response(1000);
    Serial.println(resp);
    Serial.println("setup done");
}

    /*--------------------------------------*/
    /*                MAIN                  */
    /*--------------------------------------*/

void loop() {

    timeElapsed = millis();

    if (wait_for_esp_response(10, "\r\n+IPD,4,16:")) {
        if (wait_for_esp_response(10, ADDR)) {
            Serial1.readBytes(indata, 16); // fra 12 bytes til 16 bytes
            buf[12] = indata[8];
            buf[13] = indata[9];
            buf[14] = indata[10];
            buf[15] = indata[11];

            if (buf[12] == 1) {
                reverseMotor1 = false;
            } else if (buf[12] == 0) {
                reverseMotor1 = true;
            }
            speedMotor1 = buf[13];

            // ignition for slow movements
            // you can do better than this !
            if (speedMotor1 <= 5) {
                ignitionIsNeededFlag = true;
            }

            if ( (ignitionIsNeededFlag == true) && (speedMotor1 < 22) && (speedMotor1 > 5) ) {
                speedMotor1 = 255;
                ignitionIsNeededFlag = false;
            }

            if (timeElapsed - lastTimeGuard >= timeGuardInterval) {
                Serial.println("det var tid");

                lastTimeGuard = timeElapsed;
            }

            analogWrite(enablePinMotor1, speedMotor1);
            digitalWrite(in1PinMotor1, ! reverseMotor1);
            digitalWrite(in2PinMotor1, reverseMotor1);

            Serial.print("dirMotor1: ");
            Serial.println(buf[12]);
            Serial.print("speedMotor1: ");
            Serial.println(buf[13]);

            Serial1.println("AT+CIPSEND=4,16");
            if (wait_for_esp_response(10, "> ")) {
                Serial1.write(buf, sizeof(buf));
                if (wait_for_esp_response(10)) {
                    Serial.println("reply sent!");
                }
            }
        }
    }
}