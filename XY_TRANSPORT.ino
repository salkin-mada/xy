
#include <AFMotor.h> //legacy babay

// simple >if< program

AF_DCMotor motor1(1, MOTOR12_8KHZ);
AF_DCMotor motor2(2, MOTOR12_8KHZ);
AF_DCMotor motor3(3, MOTOR34_8KHZ);
AF_DCMotor motor4(4, MOTOR34_8KHZ);

#define STOPPED 0
#define FORWARDS 1
#define BACKWARDS 2
#define AT_DOWN 3

unsigned long time;

int flag = 0;

// int currentMotor1State = STOPPED;
// int lastMotor1State = STOPPED;
// int motor1Speed;
// int currentMotor2State = STOPPED;
// int lastMotor2State = STOPPED;
// int motor2Speed;


const int downStop1Pin = A0;
const int downStop2Pin = A1;
const int downStop3Pin = A2;
const int downStop4Pin = A3;
int downStop1Val;
int downStop2Val;
int downStop3Val;
int downStop4Val;

void setup() {
    Serial.begin(9600);
    Serial.println("setup");

    // stop switches
    pinMode(downStop1Pin, INPUT_PULLUP);
    pinMode(downStop2Pin, INPUT_PULLUP);
    pinMode(downStop3Pin, INPUT_PULLUP);
    pinMode(downStop4Pin, INPUT_PULLUP);

    // turn on motor
    motor1.setSpeed(60);
    motor2.setSpeed(60);
    motor3.setSpeed(60);
    motor4.setSpeed(60);
    motor1.run(RELEASE);
    motor2.run(RELEASE);
    motor3.run(RELEASE);
    motor4.run(RELEASE);
    Serial.println("ready!");
}

void loop() {

    downStop1Val = digitalRead(downStop1Pin);
    downStop2Val = digitalRead(downStop2Pin);
    downStop3Val = digitalRead(downStop3Pin);
    downStop4Val = digitalRead(downStop4Pin);

    time = millis();
	check_time();
    
    //Serial.print("ds1= ");
    //Serial.println(downStop1Val);
    //Serial.print("ds2= ");
    //Serial.println(downStop1Val);
    //Serial.print("ds3= ");
    //Serial.println(downStop1Val);
    //Serial.print("ds4= ");
    //Serial.println(downStop1Val);
    
    
    if(flag == 0) {

		if(downStop1Val == 1) {
			motor1.setSpeed(200);
			motor1.run(BACKWARD);
		}

		if(downStop1Val == 0){
			motor1.run(RELEASE);
			delay(1000);
			motor1.setSpeed(255);
			motor1.run(FORWARD);
			delay(20);
			motor1.setSpeed(190);
			delay(1200);
			motor1.run(RELEASE);
			delay(3000);
			
			flag = 1;
		}
    
    }

    if(flag == 1){

		if(downStop2Val == 1) {
			motor2.setSpeed(170);
			motor2.run(BACKWARD);
		}

		if(downStop2Val == 0){
			motor2.run(RELEASE);
			delay(1000);
			motor2.setSpeed(255);
			motor2.run(FORWARD);
			delay(20);
			motor2.setSpeed(250);
			delay(800);
			//motor2.run(RELEASE);
			motor2.setSpeed(60);
			delay(3000);
		
			flag = 2;
		}
    
    }

    if(flag == 2){

		if(downStop3Val == 1) {
			motor3.setSpeed(170);
			motor3.run(BACKWARD);
		}

		if(downStop3Val == 0){
			motor3.run(RELEASE);
			delay(1000);
			motor3.setSpeed(255);
			motor3.run(FORWARD);
			delay(20);
			motor3.setSpeed(250);
			delay(800);
			motor3.run(RELEASE);
			delay(3000);
		
			flag = 3;
		}
    
    }

    if(flag == 3){

		if(downStop4Val == 1) {
			motor4.setSpeed(170);
			motor4.run(BACKWARD);
		}

		if(downStop4Val == 0){
			motor4.run(RELEASE);
			delay(1000);
			motor4.setSpeed(255);
			motor4.run(FORWARD);
			delay(20);
			motor4.setSpeed(250);
			delay(800);
			motor4.run(RELEASE);
			delay(3000);
		
			flag = 0;
		}
    
    }

    delay(10); //relax

}
