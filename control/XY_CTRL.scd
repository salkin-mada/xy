(

/* -------------------- */
/*   TEST CONNECTION    */
/* -------------------- */
//--kald & svar baby
var send= 0, last= Main.elapsedTime;
OSCdef(\sti, {|msg, time, addr|
    ("\n"++[msg[1]>>24, (msg[1]>>16)&255, (msg[1]>>8)&255, msg[1]&255]).post;
    ("\nsec since last: %, % sec since sent").format(time-last, time-send).postln;
    last= time;
    ("osc from"+addr.ip+"port"+addr.port).postln;
}, \sti);
~esp= NetAddr("1.2.3.184", 2999); //esp8266 ip
g= {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)};
r= Routine.run({
    inf.do{|i|
        //n.sendMsg(\tap, g.value(4, 3, i.asInteger%256, 1));
        //~esp.sendMsg(\tap, g.value(2, 4, i.asInteger%181, 2.rand));
        ~esp.sendMsg(\xy1, g.value(1, 255, 0, 0));
        send= Main.elapsedTime;
        (1.0+10.0.rand).wait;
    };
});
)

(
("port"+~esp.port).postln;
("ip"+~esp.ip).postln;
"done"
)

// dc H-BRO control
g= {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)};
~esp= NetAddr("1.2.3.184", 2999);
~esp.sendMsg(\xy1, g.value(/*dir*/0,/*speed*/85, /*addi*/0, /*addi*/0))
~esp.sendMsg(\xy1, g.value(/*dir*/1,/*speed*/100, /*addi*/0, /*addi*/0))






255**2
f.value(1,4,255,255)
f= {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)};
NetAddr("192.168.1.249", 1112).sendMsg(\tap, f.value(4, 3, 204.5.asInteger%256, 1))


OSCFunc.trace(false)
OSCFunc.trace(true)


n = NetAddr("127.0.0.1", 57120); // 57120 is sclang default port
r = OSCFunc({ arg msg, time; [time, msg].postln }, '/good/news', n);

n.sendMsg("/good/news", "you", "not you");
n.sendMsg("/good/news", 1, 1.3, 77);


n.sendBundle(0.2, ["/good/news", 1, 1.3, 77]);

r.free;
n.disconnect;
n
r
// note that different NetAddr objects with the same port and ip are independent.

r = OSCFunc({ "message arrived".postln }, '/x');

n = NetAddr("127.0.0.1", 57120);
n.sendMsg("/x")


u = NetAddr("127.0.0.1", 57120);
u.sendMsg("/x");

n.disconnect

u.sendMsg("/x");

r.free;
u.disconnect;

~esp.sendMsg(\tap, g.value(/*dir1*/0,/*speed1*/0,/*dir2*/0,/*speed2*/0));






/*--------------------------------*/
/*    working - control motor1    */
/*--------------------------------*/
(
g= {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)}; // should change name of bytes
~esp= NetAddr("1.2.3.251", 1112);

OSCdef(\sendToEsp, {arg msg, time, addr, port;
    //msg.postln;
    var speed1 = msg[3];
    var dir1 = 0;

    case
    {speed1 >= 0.1} {
        dir1 = 1;
        speed1 = speed1.lincurve(0.1,0.99,5,255,4);
        "forwards".postln;}
    {speed1 <= -0.1} {
        dir1 = 0;
        speed1 = speed1.lincurve(-0.99,-0.1,255,5,-4);
        "backwards".postln;}
    {(speed1 < 0.1) and: (speed1 > -0.1)} {
        dir1 = 0;
        speed1 = 0;
        "stopped".postln;};
    // float to integer
    speed1 = speed1.asInteger;
    ("speed1"+speed1).postln;
    ("dir1"+dir1).postln;
    ~esp.sendMsg(\tap, g.value(/*dir*/dir1,/*speed*/speed1,0,0));
}, '/boksCtrl');

OSCdef(\sendToEsp).enable;

Ndef(\control, {
    var ctrl;
    ctrl = MouseY.kr(-1.0, 1.0);
    //ctrl.poll;
    SendReply.kr(Impulse.kr(10), '/boksCtrl', ctrl);
});

)





/*------------------------*/
/*    lastest use this    */
/*------------------------*/
(
g= {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)}; // should change name of bytes
~esp= NetAddr("1.2.3.251", 1112);

~dir1 = 0;
~speed1 = 0;
~dir2 = 0;
~speed2 = 0;

OSCdef(\motor1, {arg msg, time;
    // caller responsibility, val must be in -1.0<>1.0
    var val = msg[1];
    var speed = 0;
    var dir = 0;

    //val = val.linlin(0.000001, 1.0, -1.0, 1.0);
    "motor1: ".post;
    val.postln;

    // motor1
    case
    {val >= 0.1} {
        dir = 1;
        speed = val.lincurve(0.1,0.99,5,255,4);
        "motor1 forwards".postln;}
    {val <= -0.1} {
        dir = 0;
        speed = val.lincurve(-0.99,-0.1,255,5,-4);
        "motor1 backwards".postln;}
    {(val < 0.1) and: (val > -0.1)} {
        dir = 0;
        speed = 0;
        "motor1 stopped".postln;};

    // float to integer
    ~speed1 = speed.asInteger;
    ("speed1"+~speed1).postln;

    ~dir1 = dir;
    ("dir1"+~dir1).postln;

    ~esp.sendMsg(\tap, g.value(~dir1,~speed1,~dir2,~speed2));
}, '/boksControl/motor1');

OSCdef(\motor2, {arg msg, time;
    // caller responsibility, val must be in -1.0<>1.0
    var val = msg[1];
    var speed = 0;
    var dir = 0;

    //val = val.linlin(0.000001, 1.0, -1.0, 1.0);
    "motor2: ".post;
    val.postln;

    // motor2
    case
    {val >= 0.1} {
        dir = 1;
        speed = val.lincurve(0.1,0.99,5,255,4);
        "motor2 forwards".postln;}
    {val <= -0.1} {
        dir = 0;
        speed = val.lincurve(-0.99,-0.1,255,5,-4);
        "motor2 backwards".postln;}
    {(val < 0.1) and: (speed > -0.1)} {
        dir = 0;
        speed = 0;
        "motor2 stopped".postln;};

    // float to integer
    ~speed2 = speed.asInteger;
    ("speed2"+~speed2).postln;

    ~dir2 = dir;
    ("dir2"+~dir2).postln;

    ~esp.sendMsg(\tap, g.value(~dir1,~speed1,~dir2,~speed2));
}, '/boksControl/motor2');
)

(
//abort abort !!!
~esp.sendMsg(\tap, g.value(0,0,0,0));
)