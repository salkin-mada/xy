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

// dc H-BRO control
g= {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)};
~xy1= NetAddr("1.2.3.184", 2999);
~xy1.sendMsg(\xy1, g.value(/*dir*/0,/*speed*/255, /*addi*/0, /*addi*/0))
~xy1.sendMsg(\xy1, g.value(/*dir*/1,/*speed*/22, /*addi*/0, /*addi*/0))
~xy1.sendMsg(\xy1, g.value(/*dir*/0,/*speed*/0, /*addi*/0, /*addi*/0))

~xy2= NetAddr("1.2.3.185", 2999);
~xy2.sendMsg(\xy1, g.value(/*dir*/0,/*speed*/85, /*addi*/0, /*addi*/0))
~xy2.sendMsg(\xy1, g.value(/*dir*/1,/*speed*/22, /*addi*/0, /*addi*/0))
~xy2.sendMsg(\xy1, g.value(/*dir*/0,/*speed*/0, /*addi*/0, /*addi*/0))







// GUI WORK

// simple slider
(
~bits = {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)};
~xy1= NetAddr("1.2.3.184", 2999);
~speed1 = 0;
~dir1 = 0;
~xy2= NetAddr("1.2.3.185", 2999);
~speed2 = 0;
~dir2 = 0;


w = Window.new(bounds: Rect(100, 500, 790, 100)).front;
g = EZSlider( w,         // parent
	              790@100,    // bounds
	              "xy1",  // label
	              \pan,     // controlSpec
	              { |slider|
		case
		{slider.value >0.1} {
			"1 above (+)".postln;
			~dir1 = 1;
			(slider.value.asString).postln;
			~speed1 = (slider.value.linexp(0.0,1.0,0.01,1.0)*255).asInteger;
		}
		{(slider.value > (0.1).neg) and: (slider.value < 0.1)} {
			"1 complete stop".postln;
			~speed1 = 0;
		}
		{slider.value < (0.1).neg} {
			"1 above (-)".postln;
			~dir1 = 0;
			(slider.value.asString).postln;
			~speed1 = (slider.value.abs.linexp(0.0,1.0,0.01,1.0)*255).asInteger;

		};
		~speed1.postln;
		~xy1.sendMsg(\xy1, ~bits.value(~dir1, ~speed1, /*addi*/0, /*addi*/0));
		//(slider.value.asString).postln;

	} // action
);
g.setColors(Color.red,Color.white);

e = Window.new(bounds: Rect(900, 500, 790, 100)).front;
h = EZSlider( e,         // parent
	              790@100,    // bounds
	              "xy2",  // label
	              \pan,     // controlSpec
	              { |slider|
		case
		{slider.value >0.1} {
			"2 above (+)".postln;
			~dir2 = 1;
			(slider.value.asString).postln;
			~speed2 = (slider.value.linexp(0.0,1.0,0.01,1.0)*255).asInteger;
		}
		{(slider.value > (0.1).neg) and: (slider.value < 0.1)} {
			"2 complete stop".postln;
			~speed2 = 0;
		}
		{slider.value < (0.1).neg} {
			"2 above (-)".postln;
			~dir2 = 0;
			(slider.value.asString).postln;
			~speed2 = (slider.value.abs.linexp(0.0,1.0,0.01,1.0)*255).asInteger;

		};
		~speed2.postln;
		~xy2.sendMsg(\xy1, ~bits.value(~dir2, ~speed2, /*addi*/0, /*addi*/0));
		//(slider.value.asString).postln;

	} // action
);
h.setColors(Color.red,Color.white);

);



// 2d slider

t.x        // get the x loc
t.x_(0.25) // set the x loc




(

~bits = {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)};
~espXY1= NetAddr("1.2.3.184", 2999);
~espXY2= NetAddr("1.2.3.185", 2999);
//~espXY3= NetAddr("1.2.3.254", 2999);
//~espXY4= NetAddr("1.2.3.253", 2999);
~speed1 = 0;
~dir1 = 0;
~speed2 = 0;
~dir2 = 0;
~speed3 = 0;
~dir3 = 0;
~speed4 = 0;
~dir4 = 0;

w = Window("XY_KÅNTRÅL", Rect(200, 200, 500, 500));
w.view.decorator = FlowLayout(w.view.bounds);
t = Slider2D(w, Rect(20, 20, 490, 490))
        .x_(0.5) // initial location of x
        .y_(0.5)   // initial location of y
        .background_(Color.yellow(0.89))
.knobColor_(Color.magenta)
        .action_({|sl|

	/*
	         Y
	         |
	    1    |	  2
	         |
	X--------|--------
	         |
	    4    |	  3
	         |
	*/

	case
	{(sl.y < 0.5) and: (sl.x == 0.5)}{
		"lift quadrant 1,2".postln;
		~speed1 = (sl.y).linexp(0.0,0.5,255,1).asInteger;
		~dir1 = 1;
		~speed2 = (sl.y).linexp(0.0,0.5,255,1).asInteger;
		~dir2 = 1;
		~speed3 = 100; //down
		~dir3 = 0;
		~speed4 = 100; //down
		~dir4 = 0;
	}
	{(sl.y > 0.5) and: (sl.x == 0.5)}{
		"lift quadrant 3,4".postln;
		~speed1 = 100; //down
		~dir1 = 0;
		~speed2 = 100; //down
		~dir2 = 0;
		~speed3 = (sl.y).linexp(0.5,1.0,1,255).asInteger;
		~dir3 = 1;
		~speed4 = (sl.y).linexp(0.5,1.0,1,255).asInteger;
		~dir4 = 1;
	}
	{(sl.x < 0.5) and: (sl.y == 0.5)}{
		"lift quadrant 2,3".postln;
		~speed1 = 100; //down
		~dir1 = 0;
		~speed2 = (sl.x).linexp(0.0,0.5,255,1).asInteger;
		~dir2 = 1;
		~speed3 = (sl.x).linexp(0.0,0.5,255,1).asInteger;
		~dir3 = 1;
		~speed4 = 100; //down
		~dir4 = 0;

	}
	{(sl.x > 0.5) and: (sl.y == 0.5)}{
		"lift quadrant 1,4".postln;
		~speed1 = (sl.x).linexp(0.5,1.0,1,255).asInteger;
		~dir1 = 1;
		~speed2 = 100; //down
		~dir2 = 0;
		~speed3 = 100; //down
		~dir3 = 0;
		~speed4 = (sl.x).linexp(0.5,1.0,1,255).asInteger;
		~dir4 = 1;

	}
	{(sl.y < 0.5) and: (sl.x > 0.5)}{
		"lift quadrant 1,2,4".postln;
		if((sl.y).linlin(0.0,0.5,1.0,0.5) > sl.x, {
			~speed1 = (sl.y).linexp(0.0,0.5,255,1).asInteger;
		},{
			~speed1 = (sl.x).linexp(0.5,1.0,1,255).asInteger;
		});
		~dir1 = 1;
		~speed2 = (sl.y).linexp(0.0,0.5,255,1).asInteger;
		~dir2 = 1;
		~speed3 = 100; //down
		~dir3 = 0;
		~speed4 = (sl.x).linexp(0.5,1.0,1,255).asInteger;
		~dir4 = 1;

	}
	{(sl.y < 0.5) and: (sl.x < 0.5)}{
		"lift quadrant 1,2,3".postln;
		~speed1 = (sl.y).linexp(0.0,0.5,255,1).asInteger;
		~dir1 = 1;
		if(sl.y < sl.x, {
			~speed2 = (sl.y).linexp(0.0,0.5,255,1).asInteger;
		},{
			~speed2 = (sl.x).linexp(0.0,0.5,255,1).asInteger;
		});
		~dir2 = 1;
		~speed3 = (sl.x).linexp(0.0,0.5,255,1).asInteger;
		~dir3 = 1;
		~speed4 = 100; //down
		~dir4 = 0;
	}
	{(sl.y > 0.5) and: (sl.x < 0.5)}{
		"lift quadrant 2,3,4".postln;
		~speed1 = 100; //down
		~dir1 = 0;
		~speed2 = (sl.x).linexp(0.0,0.5,255,1).asInteger;
		~dir2 = 1;
		if(sl.y > (sl.x).linlin(0.0,0.5,1.0,0.5), {
			~speed3 = (sl.y).linexp(0.5,1.0,1,255).asInteger;
		},{
			~speed3 = (sl.x).linexp(0.0,0.5,255,1).asInteger;
		});
		~dir3 = 1;
		~speed4 = (sl.y).linexp(0.5,1.0,1,255).asInteger;
		~dir4 = 1;

	}
	{(sl.y > 0.5) and: (sl.x > 0.5)}{
		"lift quadrant 1,3,4".postln;
		~speed1 = (sl.x).linexp(0.5,1.0,1,255).asInteger;
		~dir1 = 1;
		~speed2 = 100; // down
		~dir2 = 0;
		~speed3 = (sl.y).linexp(0.5,1.0,1,255).asInteger;
		~dir3 = 1;
		if(sl.y > sl.x, {
			~speed4 = (sl.y).linexp(0.5,1.0,1,255).asInteger;
		},{
			~speed4 = (sl.x).linexp(0.5,1.0,1,255).asInteger;
		});
		~dir4 = 1;

	};

	"speed 1: ".post;
	~speed1.postln;
	"speed 2: ".post;
	~speed2.postln;
	"speed 3: ".post;
	~speed3.postln;
	"speed 4: ".post;
	~speed4.postln;



	//[\sliderX, sl.x, \sliderY, sl.y].postln;
});

t.step_(0.00); // disable keyboard

~mouseDown = {"we're moving".postln;};

~mouseUp = {
	t.x_(0.5); t.y_(0.5);

	~dir1 = 0;
	~dir2 = 0;
	~speed1 = 100;
	~speed2 = 100;

	"ALL DOWN".postln;
};

t.addAction(~mouseDown, \mouseDownAction);
t.addAction(~mouseUp, \mouseUpAction);

~send = Task({
	loop {
		~espXY1.sendMsg(\xy1, ~bits.value(~dir1, ~speed1, /*addi*/0, /*addi*/0));
		~espXY2.sendMsg(\xy1, ~bits.value(~dir2, ~speed2, /*addi*/0, /*addi*/0));
		//~espXY3.sendMsg(\xy3, ~bits.value(~dir3, ~speed3, /*addi*/0, /*addi*/0));
		//~espXY4.sendMsg(\xy4, ~bits.value(~dir4, ~speed4, /*addi*/0, /*addi*/0));

		0.125.wait;
	};
}).play;


w.front;
w.alwaysOnTop = true;
w.onClose = {
	~speed1 = 0; ~speed2 = 0; "ABORT".postln;
};
)

~send.stop; // stop sending

