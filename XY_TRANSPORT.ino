
#include <AFMotor.h> //legacy babay
#include "check.h"
// simple >if< program

AF_DCMotor motor1(1, MOTOR12_8KHZ); // use 149.12.(>=90)
AF_DCMotor motor2(2, MOTOR12_8KHZ);
AF_DCMotor motor3(3, MOTOR34_8KHZ);
AF_DCMotor motor4(4, MOTOR34_8KHZ);

#define STOPPED 0
#define FORWARDS 1
#define BACKWARDS 2
#define AT_DOWN 3

unsigned long time;

int flag = 0;
int localFlag1 = 0;
int localFlag2 = 0;
int localFlag3 = 0;
int localFlag4 = 0;

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
int downStop1Val; // bool !
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

    //time = millis();
	//check_time();
    
    //Serial.print("ds1= ");
    //Serial.println(downStop1Val);
    //Serial.print("ds2= ");
    //Serial.println(downStop1Val);
    //Serial.print("ds3= ");
    //Serial.println(downStop1Val);
    //Serial.print("ds4= ");
    //Serial.println(downStop1Val);
    
    // 1
    if(flag == 0) {

		if(downStop1Val == 1 && localFlag1 == 0) {
			motor1.setSpeed(200);
			motor1.run(BACKWARD);
		}

		if(downStop1Val == 0 && localFlag1 == 0){
			motor1.run(RELEASE);
			delay(random(500,1000));
			motor1.setSpeed(255);
			motor1.run(FORWARD);
			delay(20);
			motor1.setSpeed(190);
			delay(1200);
			motor1.run(RELEASE);
			delay(random(500,3000));
			
			localFlag1 = 1;
		}

		if(downStop1Val == 1 && localFlag1 == 1) {
			motor1.setSpeed(200);
			motor1.run(BACKWARD);
			localFlag1 = 2;
		}

		if(downStop1Val == 0 && localFlag1 == 2) {
			localFlag1 = 3;
		}

		if(downStop1Val == 0 && localFlag1 == 3){
			motor1.run(RELEASE);
			delay(random(500,1000));

			localFlag1 = 0;
			flag = 1;

		}

		
    
    }

	// 2
    if(flag == 1){


		if(downStop2Val == 1 && localFlag2 == 0) {
			motor2.setSpeed(255);
			motor2.run(BACKWARD);
		}

		if(downStop2Val == 0 && localFlag2 == 0){
			motor2.run(RELEASE);
			delay(random(500,1000));
			motor2.setSpeed(255);
			motor2.run(FORWARD);
			delay(20);
			motor2.setSpeed(250);
			delay(900);
			//motor2.run(RELEASE);
			motor2.setSpeed(60);
			delay(random(500,3000));
			//motor2.run(RELEASE); // special case 149.12.43 motor not strong enough
			
			localFlag2 = 1;
		}

		if(downStop2Val == 1 && localFlag2 == 1) {
			// special
			motor2.run(BACKWARD);
			motor2.setSpeed(255);
			localFlag2 = 2;
		}

		if(downStop2Val == 0 && localFlag2 == 2) {
			localFlag2 = 3;
		}

		if(downStop2Val == 0 && localFlag2 == 3){
			motor2.run(RELEASE);
			delay(random(500,1000));

			localFlag2 = 0;
			flag = 2;

		}
    
    }

	// 3
    if(flag == 2){

		if(downStop3Val == 1 && localFlag3 == 0) {
			motor3.setSpeed(210);
			motor3.run(BACKWARD);
		}

		if(downStop3Val == 0 && localFlag3 == 0){
			motor3.run(RELEASE);
			delay(random(500,1000));
			motor3.setSpeed(255);
			motor3.run(FORWARD);
			delay(20);
			motor3.setSpeed(215);
			delay(1500);
			//motor3.run(RELEASE);
			motor3.setSpeed(60);
			delay(random(1500,3000));
			
			localFlag3 = 1;
		}

		if(downStop3Val == 1 && localFlag3 == 1) {
			motor3.setSpeed(190);
			motor3.run(BACKWARD);
			localFlag3 = 2;
		}

		if(downStop3Val == 0 && localFlag3 == 2) {
			localFlag3 = 3;
		}

		if(downStop3Val == 0 && localFlag3 == 3){
			motor3.run(RELEASE);
			delay(random(500,1000));

			localFlag3 = 0;
			flag = 3;

		}
    
    }

	// 4
    if(flag == 3){


		if(downStop4Val == 1 && localFlag4 == 0) {
			motor4.setSpeed(190);
			motor4.run(BACKWARD);
		}

		if(downStop4Val == 0 && localFlag4 == 0){
			motor4.run(RELEASE);
			delay(random(500,1000));
			motor4.setSpeed(255);
			motor4.run(FORWARD);
			delay(20);
			motor4.setSpeed(225);
			delay(1100);
			motor4.setSpeed(60);
			//motor4.run(RELEASE);
			delay(random(500,3000));
			
			localFlag4 = 1;
		}

		if(downStop4Val == 1 && localFlag4 == 1) {
			motor4.setSpeed(170);
			motor4.run(BACKWARD);
			localFlag4 = 2;
		}

		if(downStop4Val == 0 && localFlag4 == 2) {
			localFlag4 = 3;
		}

		if(downStop4Val == 0 && localFlag4 == 3){
			motor4.run(RELEASE);
			delay(random(500,1000));

			localFlag4 = 0;
			flag = 0;

		}
    
    }

    delay(10); //relax

}
