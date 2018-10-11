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



/*-------------------------------------------*/
/*    working - control motor1 with mouse    */
/*-------------------------------------------*/
(
g= {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)}; // should change name of bytes
~esp= NetAddr("1.2.3.184", 2999);

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
    ~esp.sendMsg(\xy1, g.value(/*dir*/dir1,/*speed*/speed1,0,0));
}, '/boksCtrl');

OSCdef(\sendToEsp).enable;

Ndef(\control, {
    var ctrl;
    ctrl = MouseY.kr(-1.0, 1.0);
    //ctrl.poll;
    SendReply.kr(Impulse.kr(10), '/boksCtrl', ctrl);
});

)







// simple control with sendMsg evaluation

(
("port"+~esp.port).postln;
("ip"+~esp.ip).postln;
"done"
)

// dc H-BRO control
g= {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)};
~esp= NetAddr("1.2.3.184", 2999);
~esp.sendMsg(\xy1, g.value(/*dir*/0,/*speed*/85, /*addi*/0, /*addi*/0))
~esp.sendMsg(\xy1, g.value(/*dir*/1,/*speed*/22, /*addi*/0, /*addi*/0))
~esp.sendMsg(\xy1, g.value(/*dir*/0,/*speed*/0, /*addi*/0, /*addi*/0))








// GUI WORK
(
~bits = {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)};
~esp= NetAddr("1.2.3.184", 2999);
~speed = 0;
~dir = 0;


w = Window.new.front;
g = EZSlider( w,         // parent
	              390@20,    // bounds
	              "xy1",  // label
	              \pan,     // controlSpec
	              { |slider|
		case
		{slider.value >0.1} {
			"above (+)".postln;
			~dir = 1;
			(slider.value.asString).postln;
			~speed = (slider.value.linexp(0.0,1.0,0.01,1.0)*255).asInteger;
		}
		{(slider.value > (0.1).neg) and: (slider.value < 0.1)} {
			"complete stop".postln;
			~speed = 0;
		}
		{slider.value < (0.1).neg} {
			"above (-)".postln;
			~dir = 0;
			(slider.value.asString).postln;
			~speed = (slider.value.abs.linexp(0.0,1.0,0.01,1.0)*255).asInteger;

		};
		~speed.postln;
		~esp.sendMsg(\xy1, ~bits.value(~dir, ~speed, /*addi*/0, /*addi*/0));
		//(slider.value.asString).postln;

	} // action
);
g.setColors(Color.red,Color.white)
);

OSCFunc.trace(false)
