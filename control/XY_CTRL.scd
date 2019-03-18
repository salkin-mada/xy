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
~esp= NetAddr("1.2.3.185", 2999); //esp8266 ip
g= {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)};
r= Routine.run({
	inf.do{|i|
		//n.sendMsg(\tap, g.value(4, 3, i.asInteger%256, 1));
		//~esp.sendMsg(\tap, g.value(2, 4, i.asInteger%181, 2.rand));
		~esp.sendMsg(\xy1, g.value(1, 255, 0, 0));
		send= Main.elapsedTime;
		0.5.wait;
	};
});
)



/*-------------------------------------------*/
/*    working - control motor1 with mouse    */
/*-------------------------------------------*/
(
g= {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)}; // should change name of bytes
~esp= NetAddr("1.2.3.185", 2999);

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
~xy1.sendMsg(\xy1, g.value(/*dir*/1,/*speed*/148, /*addi*/0, /*addi*/0))
~xy1.sendMsg(\xy1, g.value(/*dir*/0,/*speed*/0, /*addi*/0, /*addi*/0))
~xy1.sendMsg(\xy1, g.value(/*dir*/0,/*speed*/165, /*addi*/0, /*addi*/0))

g= {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)};
~xy2= NetAddr("1.2.3.185", 2999);
~xy2.sendMsg(\xy1, g.value(/*dir*/1,/*speed*/42, /*addi*/0, /*addi*/0))
~xy2.sendMsg(\xy1, g.value(/*dir*/0,/*speed*/0, /*addi*/0, /*addi*/0))
~xy2.sendMsg(\xy1, g.value(/*dir*/0,/*speed*/40, /*addi*/0, /*addi*/0))







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




/*---------------------------------*/
/*--------- MULTISLIDER -----------*/
/*---------------------------------*/
// simple multi slider with mouseUp release env, and ctrl mousedown meta action to all stop!
(

var numSliders = 4;
var sliderSize = 70;
var sliders = Array.fill(numSliders, {0.5});
~bits = {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)};
~xy1= NetAddr("1.2.3.184", 2999);
~speed1 = 0;
~dir1 = 0;
~xy2= NetAddr("1.2.3.185", 2999);
~speed2 = 0;
~dir2 = 0;
~xy3= NetAddr("1.2.3.186", 2999);
~speed3 = 0;
~dir3 = 0;
~xy4= NetAddr("1.2.3.187", 2999);
~speed4 = 0;
~dir4 = 0;

~mefaFlag = 0;
~release = 2.5; // seconds

w = Window("xy ctrl",
	Rect(
		Window.screenBounds.width-(Window.screenBounds.width/1.7),
		Window.screenBounds.height-(Window.screenBounds.height/1.4),
		numSliders*sliderSize+30,
		450
	)
);
f={
	w.view.decorator = FlowLayout( w.view.bounds, 10@10, 10@2 );
	m = MultiSliderView(w,Rect(0,0,numSliders*sliderSize+10,400)); // default thumbWidth is 13
	m.thumbSize_(sliderSize);
	m.colors_(Color.black, Color.fromHexString("#FF6600"));
	m.showIndex_(true);
	m.value=Array.fill(numSliders, {0.5});
	m.action = {arg q;

		case
		{(q.index == 0) and: (q.value.at(0) > 0.5)}
		{
			~dir1 = 1;
			~speed1 = q.value.at(0).linlin(0.5,1.0,0,255).asInteger;
			"xy1 up, with speed: ".post; ~speed1.postln;
		}
		{(q.index == 0) and: (q.value.at(0) < 0.5)}
		{
			~dir1 = 0;
			~speed1 = q.value.at(0).linlin(0.0,0.5,255,0).asInteger;
			"xy1 down, with speed: ".post; ~speed1.postln;
		}
		{(q.index == 1) and: (q.value.at(1) > 0.5)}
		{
			~dir2 = 1;
			~speed2 = q.value.at(1).linlin(0.5,1.0,0,255).asInteger;
			"xy2 up, with speed: ".post; ~speed2.postln;
		}
		{(q.index == 1) and: (q.value.at(1) < 0.5)}
		{
			~dir2 = 0;
			~speed2 = q.value.at(1).linlin(0.0,0.5,255,0).asInteger;
			"xy2 down, with speed: ".post; ~speed2.postln;
		}
		{(q.index == 2) and: (q.value.at(2) > 0.5)}
		{
			~dir3 = 1;
			~speed3 = q.value.at(2).linlin(0.5,1.0,0,255).asInteger;
			"xy3 up, with speed: ".post; ~speed3.postln;
		}
		{(q.index == 2) and: (q.value.at(2) < 0.5)}
		{
			~dir3 = 0;
			~speed3 = q.value.at(2).linlin(0.0,0.5,255,0).asInteger;
			"xy3 down, with speed: ".post; ~speed3.postln;
		}
		{(q.index == 3) and: (q.value.at(3) > 0.5)}
		{
			~dir4 = 1;
			~speed4 = q.value.at(3).linlin(0.5,1.0,0,255).asInteger;
			"xy4 up, with speed: ".post; ~speed4.postln;
		}
		{(q.index == 3) and: (q.value.at(3) < 0.5)}
		{
			~dir4 = 0;
			~speed4 = q.value.at(3).linlin(0.0,0.5,255,0).asInteger;
			"xy4 down, with speed: ".post; ~speed4.postln;
		};

		~env1 = Env([~speed1, 0], [~release*~speed1/255]).asStream;
		~env2 = Env([~speed2, 0], [~release*~speed2/255]).asStream;
		~env3 = Env([~speed3, 0], [~release*~speed3/255]).asStream;
		~env4 = Env([~speed4, 0], [~release*~speed4/255]).asStream;

		r[q.index].stop;
		r[q.index].reset;
	};

	m.metaAction = {arg q;
		numSliders.do({arg i;
			r.at(i).stop;
		});
		sliders = Array.fill(numSliders, {0.5});
		m.value = sliders;
		~speed1 = 0;
		~speed2 = 0;
		~speed3 = 0;
		~speed4 = 0;
		~metaFlag = 1;
		"stop all".postln;
	};

	//# routine1, routine2, routine3, routine4 = 4.collect etc
	r = 4.collect({arg item;
		Task ({
			case
			{item == 0} {
				while({~env1.next.asInteger > 0},{
					~speed1 = ~env1.next.asInteger;
					if(~dir1 == 1){
						sliders[0] = ~speed1.linlin(0,255,0.5,1.0);
						m.value = sliders;
					};
					if(~dir1 == 0){
						sliders[0] = ~speed1.linlin(0,255,0.5,0.0);
						m.value = sliders;
					};
					0.1.wait;
					~speed1.postln;
				});
				if(~env1.next.asInteger == 0){
					~speed1 = 0;
					sliders[0] = 0.5;
					m.value = sliders;
					"speed1 next was 0, now it's ".postln;
					~speed1.postln;
				};

			}
			{item == 1} {
				while({~env2.next.asInteger > 0},{
					~speed2 = ~env2.next.asInteger;
					if(~dir2 == 1){
						sliders[1] = ~speed2.linlin(0,255,0.5,1.0);
						m.value = sliders;
					};
					if(~dir2 == 0){
						sliders[1] = ~speed2.linlin(0,255,0.5,0.0);
						m.value = sliders;
					};
					0.1.wait;
					~speed2.postln;
				});
				if(~env2.next.asInteger == 0){
					~speed2 = 0;
					sliders[1] = 0.5;
					m.value = sliders;
					"speed2 next was 0, now it's ".postln;
					~speed2.postln;
				};

			}
			{item == 2} {
				while({~env3.next.asInteger > 0},{
					~speed3 = ~env3.next.asInteger;
					if(~dir3 == 1){
						sliders[2] = ~speed3.linlin(0,255,0.5,1.0);
						m.value = sliders;
					};
					if(~dir3 == 0){
						sliders[2] = ~speed3.linlin(0,255,0.5,0.0);
						m.value = sliders;
					};
					0.1.wait;
					~speed3.postln;
				});
				if(~env3.next.asInteger == 0){
					~speed3 = 0;
					sliders[2] = 0.5;
					m.value = sliders;
					"speed3 next was 0, now it's ".postln;
					~speed3.postln;
				};

			}
			{item == 3} {
				while({~env4.next.asInteger > 0},{
					~speed4 = ~env4.next.asInteger;
					if(~dir4 == 1){
						sliders[3] = ~speed4.linlin(0,255,0.5,1.0);
						m.value = sliders;
					};
					if(~dir4 == 0){
						sliders[3] = ~speed4.linlin(0,255,0.5,0.0);
						m.value = sliders;
					};
					0.1.wait;
					~speed4.postln;
				});
				if(~env4.next.asInteger == 0){
					~speed4 = 0;
					sliders[3] = 0.5;
					m.value = sliders;
					"speed4 next was 0, now it's ".postln;
					~speed4.postln;
				};
			};
		}, AppClock)
	});

	m.mouseUpAction = {arg q;
		if(~metaFlag == 0){
			// if r.at(q.index) is not done restart from new val
			r.at(q.index).start;
		};
		if(~metaFlag == 1){
			"metaFlag mouseUpAction".postln;
			~metaFlag = 0;
		};

		q.value.postln;
	};
};

f.value;

~send = Task({
	loop {
		~xy1.sendMsg(\xy1, ~bits.value(~dir1, ~speed1, /*addi*/0, /*addi*/0));
		~xy2.sendMsg(\xy2, ~bits.value(~dir2, ~speed2, /*addi*/0, /*addi*/0));
		~xy3.sendMsg(\xy3, ~bits.value(~dir3, ~speed3, /*addi*/0, /*addi*/0));
		~xy4.sendMsg(\xy4, ~bits.value(~dir4, ~speed4, /*addi*/0, /*addi*/0));
		0.1.wait;
	};
}).play;

w.front;
w.alwaysOnTop = true;
w.onClose = {
	~speed1 = 0; ~speed2 = 0; ~speed3 = 0; ~speed4 = 0; "ABORT".postln;
	fork{1.0.wait; ~send.stop; "stopped sending OSC".postln}; // stop sending
};

)












/* ÜˆŒ°˝É‡˜Üˆ˚ÄÖﬂº¬˘¯∆∑◊⁄Ç«»“”„·ÜˆŒ°˝É‡˜Üˆ˚ÄÖﬂº¬˘¯∆∑◊⁄Ç«»“”„· */
/* ·„”“»«Ç⁄◊∑∆∫¯˘¬ºﬂ°˝‡˜ÜˆŒ∏Ü∆»»·„”“»«Ç⁄◊∑∆∫¯˘¬ºﬂ°˝‡˜ÜˆŒ∏Ü∆»» */
/*                                                            */
/*                          2D SLIDER                         */
/*                                                            */
/* ·„”“»«Ç⁄◊∑∆∫¯˘¬ºﬂ°˝‡˜ÜˆŒ∏Ü∆»»ÜˆŒ°˝É‡˜Üˆ˚ÄÖﬂº¬˘¯∆∑◊⁄Ç«»“”„· */
/* ÜˆŒ°˝É‡˜Üˆ˚ÄÖﬂº¬˘¯∆∑◊⁄Ç«»“”„··„”“»«Ç⁄◊∑∆∫¯˘¬ºﬂ°˝‡˜ÜˆŒ∏Ü∆»» */

t.x        // get the x loc
t.x_(0.25) // set the x loc

(

~bits = {|id, on, hi, lo| (id&255<<24)|(on&255<<16)|(hi&255<<8)|(lo&255)};
// hack for changing physical postion, ip not incrementing straight
~espXY1= NetAddr("1.2.3.184", 2999);
~espXY2= NetAddr("1.2.3.187", 2999);
~espXY3= NetAddr("1.2.3.186", 2999);
~espXY4= NetAddr("1.2.3.185", 2999);
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
.background_(Color.fromHexString("#FF6600"))
.knobColor_(Color.magenta)
.action_({|sl|

//              Y
//              |
//         1    |	  2
//              |
//     X--------|--------
//              |
//        4     |	  3
//              |


	case
	{(sl.y < 0.5) and: (sl.x == 0.5)}{
		"lift quadrant 1,2".postln;
		~speed1 = (sl.y).linexp(0.0,0.5,255,1).asInteger;
		~dir1 = 1;
		~speed2 = (sl.y).linexp(0.0,0.5,255,1).asInteger;
		~dir2 = 1;
		~speed3 = 255; //down
		~dir3 = 0;
		~speed4 = 255; //down
		~dir4 = 0;
	}
	{(sl.y > 0.5) and: (sl.x == 0.5)}{
		"lift quadrant 3,4".postln;
		~speed1 = 255; //down
		~dir1 = 0;
		~speed2 = 255; //down
		~dir2 = 0;
		~speed3 = (sl.y).linexp(0.5,1.0,1,255).asInteger;
		~dir3 = 1;
		~speed4 = (sl.y).linexp(0.5,1.0,1,255).asInteger;
		~dir4 = 1;
	}
	{(sl.x < 0.5) and: (sl.y == 0.5)}{
		"lift quadrant 2,3".postln;
		~speed1 = 255; //down
		~dir1 = 0;
		~speed2 = (sl.x).linexp(0.0,0.5,255,1).asInteger;
		~dir2 = 1;
		~speed3 = (sl.x).linexp(0.0,0.5,255,1).asInteger;
		~dir3 = 1;
		~speed4 = 255; //down
		~dir4 = 0;

	}
	{(sl.x > 0.5) and: (sl.y == 0.5)}{
		"lift quadrant 1,4".postln;
		~speed1 = (sl.x).linexp(0.5,1.0,1,255).asInteger;
		~dir1 = 1;
		~speed2 = 255; //down
		~dir2 = 0;
		~speed3 = 255; //down
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


	if(~dir1 == 1){
		"speed 1: ".post;
		~speed1.postln;
	} {
		"speed 1: ".post;
		"DOWN".postln;
	};
		if(~dir2 == 1){
		"speed 2: ".post;
		~speed2.postln;
	} {
		"speed 2: ".post;
		"DOWN".postln;
	};
		if(~dir3 == 1){
		"speed 3: ".post;
		~speed3.postln;
	} {
		"speed 3: ".post;
		"DOWN".postln;
	};
		if(~dir4 == 1){
		"speed 4: ".post;
		~speed4.postln;
	} {
		"speed 4: ".post;
		"DOWN".postln;
	};

	"\n\n\n\n\n".post;


	//[\sliderX, sl.x, \sliderY, sl.y].postln;
});

t.step_(0.00); // disable keyboard

~mouseDown = {"we're moving".postln;};

~mouseUp = {
	t.x_(0.5); t.y_(0.5);

	~dir1 = 0;
	~dir2 = 0;
	~dir3 = 0;
	~dir4 = 0;
	~speed1 = 60;
	~speed2 = 60;
	~speed1 = 60;
	~speed2 = 60;

	"ALL DOWN".postln;
};

t.addAction(~mouseDown, \mouseDownAction);
t.addAction(~mouseUp, \mouseUpAction);

~send = Task({
	loop {
		~espXY1.sendMsg(\xy1, ~bits.value(~dir1, ~speed1, /*addi*/0, /*addi*/0));
		~espXY2.sendMsg(\xy1, ~bits.value(~dir2, ~speed2, /*addi*/0, /*addi*/0));
		~espXY3.sendMsg(\xy3, ~bits.value(~dir3, ~speed3, /*addi*/0, /*addi*/0));
		~espXY4.sendMsg(\xy4, ~bits.value(~dir4, ~speed4, /*addi*/0, /*addi*/0));

		0.125.wait;
	};
}).play;


w.front;
w.alwaysOnTop = true;
w.onClose = {
	~speed1 = 0; ~speed2 = 0; ~speed3 = 0; ~speed4 = 0; "ABORT".postln;
	fork{1.0.wait; ~send.stop; "stopped sending OSC".postln}; // stop sending
};
)


