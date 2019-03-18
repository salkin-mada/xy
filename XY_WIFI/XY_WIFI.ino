
// teensy + esp8266 with firmare 0.9.5.2 or higher
#define WLAN_SSID  "amonvika"
#define WLAN_PASS  "limpistol"
#define WLAN_ADDR  "1.2.3.23" // ctrl machine
#define ADDR "/xy" //incoming osc addy
#define PORT  2999  //incoming osc port
uint8_t buf[16]; // bufsize
char indata[12]; // fra 12 til 16 bytes
char inbuffer[256];
char OKrn[] = "OK\r\n";

// timer stuff
unsigned long lastTimeGuard = 0;
const long timeGuardInterval = 100;
unsigned long ignitionLastTimeGuard = 0;
const long ignitionTimeGuardInterval = 40;
unsigned long timeElapsed;

int led = 13;

// position, aka min max switch pressed
#define POS_TRUE 0
#define POS_FALSE 1

// modus and boundaries
#define STOPPED 0
#define UPWARDS 1
#define DOWNWARDS 2
#define AT_MIN 3
#define AT_MAX 4

bool ignitionFlag = false;

// states
int currentMotor1State = STOPPED;
int lastMotor1State = STOPPED;

const int line1ExpandMinPin = 22;
const int line1ExpandMaxPin = 23;
int line1ExpandMin;
int line1ExpandMax;


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

// L293B
// motor
int in1PinMotor1 = 11; //digital - dir
int in2PinMotor1 = 12; //digital - dir
int enablePinMotor1 = 10; // pwm
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

    pinMode(line1ExpandMinPin, INPUT_PULLUP);
    pinMode(line1ExpandMaxPin, INPUT_PULLUP);

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
    Serial1.begin(115200);  //teensy rx tx, for sending AT commands and piping OSC to Teensy
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

    // visual setup done
    for(int i=0; i<=10; i++){
        digitalWrite(led, HIGH);
        delay(70);
        digitalWrite(led, LOW);
        delay(70);
    }

    Serial.println("setup done");
}

/*--------------------------------------*/
/*                MAIN                  */
/*--------------------------------------*/

void loop() {

    timeElapsed = millis();

    speedMotor1 = buf[14]; // update speed

    line1ExpandMin = digitalRead(line1ExpandMinPin);
    line1ExpandMax = digitalRead(line1ExpandMaxPin);



    // STOP MIN
    if (
        (line1ExpandMin == POS_TRUE) &&
        (currentMotor1State == DOWNWARDS))
        {
        analogWrite(enablePinMotor1, 0);
        currentMotor1State = AT_MIN;
    }
    // STOP MAX
    if (
        (line1ExpandMax == POS_TRUE) &&
        currentMotor1State == UPWARDS)
        {
        analogWrite(enablePinMotor1, 0);
        currentMotor1State = AT_MAX;
    }

    // ignition timer
    if ((timeElapsed - ignitionLastTimeGuard >= ignitionTimeGuardInterval) && (ignitionFlag == true)) {
        analogWrite(enablePinMotor1, speedMotor1);
        ignitionFlag = false;
    }

    if (wait_for_esp_response(10, "\r\n+IPD,4,16:")) {
        if (wait_for_esp_response(10, ADDR)) {
            Serial1.readBytes(indata, 12);

            buf[12] = indata[8];
            buf[13] = indata[9];
            buf[14] = indata[10];
            buf[15] = indata[11];

            // SET DIRECTION
            if (buf[13] == 1) {
                reverseMotor1 = false;
            } else if (buf[13] == 0) {
                reverseMotor1 = true;
            }

            /*---------------------------------*/
            /*         SPILL THE BEANS         */
            /*---------------------------------*/
            if (timeElapsed - lastTimeGuard >= timeGuardInterval) {
                Serial.print("REVERSE: ");
                if(reverseMotor1 == false){
                    Serial.println("FALSE");
                }
                if(reverseMotor1 == true){
                    Serial.println("TRUE");
                }

                Serial.print("SPEED: ");
                Serial.println(speedMotor1);

                if(line1ExpandMin == POS_TRUE) {
                  Serial.println("AT_MIN");
                }
                //Serial.println(line1ExpandMin);

                if(line1ExpandMax == POS_TRUE) {
                  Serial.println("AT_MAX");
                }
                //Serial.println(line1ExpandMax);

                // spill the buf
                for (int i = 0; i < 16; i++) {
                  //Serial.print("buf[\"i\"]: ");
                  Serial.println(buf[i]);
                }

                //indata?
                // for (int i = 0; i < 12; i++) {
                //   Serial.print("indata[\"i\"]: ");
                //   Serial.println(indata[i]);
                // }

                lastTimeGuard = timeElapsed;
            }

            // UPWARDS
            if (
                (reverseMotor1 == false) &&
                (currentMotor1State != AT_MAX) &&
                (line1ExpandMax == POS_FALSE) &&
                (currentMotor1State != UPWARDS))
                {
                digitalWrite(in1PinMotor1, ! reverseMotor1);
                digitalWrite(in2PinMotor1, reverseMotor1);
                currentMotor1State = UPWARDS;
                Serial.print("MOTOR 1 UPWARDS <<< ---state#:  ");
                Serial.println(currentMotor1State);
            }
            //DOWNWARDS
            if (
                (reverseMotor1 == true) &&
                (currentMotor1State != AT_MIN) &&
                (line1ExpandMin == POS_FALSE) &&
                (currentMotor1State != DOWNWARDS))
                {
                digitalWrite(in1PinMotor1, ! reverseMotor1);
                digitalWrite(in2PinMotor1, reverseMotor1);
                currentMotor1State = DOWNWARDS;
                Serial.print("MOTOR 1 DOWNWARDS >>> ---state#: ");
                Serial.println(currentMotor1State);
            }
            // BRAKES
            if (
                (currentMotor1State != AT_MIN) &&
                (currentMotor1State != AT_MAX) &&
                (currentMotor1State != STOPPED) &&
                (speedMotor1 <= 5))
                {
                analogWrite(enablePinMotor1, 0);
                currentMotor1State = STOPPED;
                lastMotor1State = STOPPED;
                Serial.print("MOTOR 1 STOPPED ... ---state#: ");
                Serial.println(currentMotor1State);
            }

            // SPEED
            // MOTOR 1
            if(currentMotor1State != AT_MIN) {
                if (currentMotor1State == UPWARDS) {
                    if (lastMotor1State == STOPPED) {
                        ignitionFlag = true;
                        lastMotor1State = UPWARDS;
                        analogWrite(enablePinMotor1, 255);
                        ignitionLastTimeGuard = timeElapsed;
                        Serial.println("ignite UPWARDS");

                    } else {
                        analogWrite(enablePinMotor1, speedMotor1);
                    }
                }

            }
            if(currentMotor1State != AT_MAX) {
                if (currentMotor1State == DOWNWARDS) {
                    if (lastMotor1State == STOPPED) {
                        ignitionFlag = true;
                        lastMotor1State = DOWNWARDS;
                        analogWrite(enablePinMotor1, 255);
                        ignitionLastTimeGuard = timeElapsed;
                        Serial.println("ignite DOWNWARDS");
                    } else {
                        analogWrite(enablePinMotor1, speedMotor1);
                    }
                }
            }



            // analogWrite(enablePinMotor1, speedMotor1);
            // digitalWrite(in1PinMotor1, ! reverseMotor1);
            // digitalWrite(in2PinMotor1, reverseMotor1);

            // Serial.print("dirMotor1: ");
            // Serial.println(buf[12]);
            // Serial.print("speedMotor1: ");
            // Serial.println(buf[13]);

            Serial1.println("AT+CIPSEND=4,16");
            if (wait_for_esp_response(10, "> ")) {
                Serial1.write(buf, sizeof(buf));
                if (wait_for_esp_response(10)) {
                    //Serial.println("reply sent!");
                }
            }
        }
    }
}
