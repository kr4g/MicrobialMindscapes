(
~server2 = Server(\server2, NetAddr("127.0.0.1", 57121));

~server2.options.outDevice_("HY5066");
~server2.options.numOutputBusChannels_(2);
~server2.options.numInputBusChannels_(0);
~server2.options.sampleRate_(48000);
~server2.options.memSize_(2.pow(20));
~server2.newBusAllocators;
~server2.reboot;
)


(
SynthDef(\hum, {
	var mod = SinOsc.kr(SinOsc.kr(0.01, 3pi/2).exprange(0.1, 3.5), 3pi/2).exprange(1, 25);
	var sig = SinOsc.ar(\freq.kr(55)).lincurve(-1,1,-1,1,mod) * 0.25;
	var env = EnvGen.kr(
		Env.new(times: [0.5, 0.5]),
		gate: Impulse.kr(0.5),
		doneAction: Done.none
	);
	sig = LeakDC.ar(sig);
	sig = LPF.ar(sig, SinOsc.kr(0.4).exprange(150, 500));
	sig = sig * env;
	sig = Splay.ar(sig);
	Out.ar(\out.kr(0), sig);
}).send(~server2);

SynthDef(\sweeps, {
	var mod = SinOsc.kr(SinOsc.kr(0.05, 3pi/2).exprange(0.1, 0.25), 3pi/2).exprange(1, 55);
	var sig = Wrap.ar(SinOsc.ar(\freq.kr(55), mul: mod)) * 0.1;
	sig = LeakDC.ar(sig);
	sig = BPF.ar(sig, LFSaw.kr(SinOsc.kr(0.3, 3pi/2).exprange(0.5, 5.5), 1).exprange(150, 9000), rq:0.5);
	sig = Splay.ar(sig);
	Out.ar(\out.kr(0), sig);
}).send(~server2);
)

x = Synth(\hum, target: ~server2);
x.free;

y = Synth(\sweeps, target: ~server2);
y.free;

// ~server2.quit;