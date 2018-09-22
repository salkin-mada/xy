#include "check.h"

extern unsigned long time;
unsigned long guard1 = 0;
unsigned long guard2 = 0;
unsigned long guard3 = 0;
unsigned long guard4 = 0;
long interval1 = 1000;
long interval2 = 1000;
long interval3 = 1000;
long interval4 = 1000;

void check_do(){
    //som
}

void check_time(){

    if (time - guard1 >= interval1) {
        Serial.println("i1");
        guard1 = time;
    }

    if (time - guard2 >= interval2) {
        Serial.println("i2");
        guard2 = time;
    }

    if (time - guard3 >= interval3) {
        Serial.println("i3");
        guard3 = time;
    }

    if (time - guard4 >= interval4) {
        Serial.println("i4");
        guard4 = time;
    }

}