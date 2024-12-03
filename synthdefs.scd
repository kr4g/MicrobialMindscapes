(
SynthDef(\drone1, {
	var sig1, sig2, sig, chain, binSwapped, ps, bpf;

	// CALCIUM OSC LFOs
	var calOscVal = SinOsc.ar(LFNoise1.kr(Rand(0.00167, 0.00125)).range(0.01, 0.07)).range(0,1);
	var calOscROC = SinOsc.ar(LFNoise1.kr(Rand(0.00167, 0.00125)).range(0.01, 0.07));

	// SOURCE 1
	sig1 = PlayBuf.ar(1, \bufnum1.kr(0), BufRateScale.kr(\bufnum1.kr(0)), loop: 1);

	chain = FFT(LocalBuf(2048), sig1);
	binSwapped = IFFT(PV_BinScramble(chain,
		wipe: Clip.kr(calOscVal.pow(0.5)),
		width: Clip.kr(calOscROC.pow(2)),
		trig: Dust.kr(LFNoise0.kr(0.001).range(0.01, 0.03))
	));

	// binSwapped = FreqShift.ar(binSwapped, LFNoise0.kr(LFNoise1.kr(0.00123).range(0.04, 1.1), mul: 350));
	bpf = Mix.fill(10, {
		var freq = LFNoise1.kr(SinOsc.kr(0.03).range(0.13, 0.73)).exprange(100, 9000);
		var rq = LFNoise1.kr(SinOsc.kr(0.04).range(0.5, 0.93)).range(0.0001, 0.01);
		var pan = LFNoise1.kr(SinOsc.kr(Rand(0.012, 0.017)).range(0.1, 0.93));
		Pan2.ar(
			// BPF.ar(binSwapped, freq, rq, 4),
			BPF.ar(FreqShift.ar(binSwapped, LFNoise1.kr(LFNoise1.kr(ExpRand(0.023, 0.037)).range(0.05, 3.1), mul: Rand(150, 550))), freq, rq, 4),
			pan
		);
	});

	binSwapped = XFade2.ar(binSwapped, bpf, LFNoise1.kr(ExpRand(0.087, 0.093)));
	sig1 = XFade2.ar(sig1, binSwapped, LFNoise1.kr(ExpRand(0.087, 0.093)));
	sig1 = Pan2.ar(sig1, SinOsc.kr(LFNoise1.kr(0.07).range(0.06, 0.17)));

	// SOURCE 2
	sig2 = PlayBuf.ar(1, \bufnum2.kr(0), BufRateScale.kr(\bufnum2.kr(0)), loop: 1);
	ps = Mix.fill(8, {
		var wind = Rand(0.1, 0.5);
		var psh = PitchShift.ar(
			sig2,
			windowSize: wind,
			pitchRatio: LFNoise1.kr(0.37).range(0.5, 4),
			pitchDispersion: Rand(0.01, 0.75),
			timeDispersion: Rand(0.001, wind)
		);
		Pan2.ar(psh, SinOsc.kr(LFNoise1.kr(0.07).range(0.06, 1.17)), 0.25);
	});

	sig2 = LPF.ar(sig2, LFTri.kr(0.03).exprange(550, 6000));
	sig2 = Pan2.ar(sig2, SinOsc.kr(LFNoise1.kr(0.07).range(0.06, 0.17)));
	sig2 = XFade2.ar(sig2, ps, LFNoise1.kr(ExpRand(0.083, 0.087)));

	// MIX
	sig = XFade2.ar(sig1, sig2, calOscROC);
	sig = sig * SinOsc.kr(LFNoise1.kr(Rand(0.03, 0.05)).range(0.03, 0.07)).range(0.2,1);
	sig = Limiter.ar(sig, \limitLevel.kr(0.8), \releaseTime.kr(0.01));
	sig = sig * EnvGen.kr(Env.asr(3, 1, 3), \gate.kr(1), doneAction: 2);

	Out.ar(\out.kr(0), sig * \amp.kr(1, 0.5) * -8.dbamp);
}).add;

SynthDef(\scrape, {
	var buf = \buf.kr(0);
	var sig = PlayBuf.ar(1, buf, \rate.kr(0.5), doneAction: Done.none);
	var freq = \freq.kr([440,440*3]) * sig.bipolar(1).midiratio;
	var lfo1 = LFNoise1.ar(0.67);
	var impulse = BPF.ar(WhiteNoise.ar(0.5), sig.linexp(0,1,250,2500), rq: 0.75);
	var pluckSig = Pluck.ar(impulse, Impulse.ar(sig.range(17,3)), freq.reciprocal, freq.reciprocal, 3, sig.range(0.8,0.05)).sum;
	pluckSig = pluckSig * lfo1.range(-12.dbamp, -6.dbamp);
	pluckSig = Pan2.ar(pluckSig, LFNoise1.kr(0.4));
	pluckSig = pluckSig * EnvGen.kr(Env.asr(0.3, 1, \releaseTime.kr(0), curve: -8), \gate.kr(1), doneAction: 2);
	Out.ar(\out.kr(0), pluckSig * -2.dbamp);
}).add;

SynthDef(\pluck, {
	var duration = \duration.kr(10);
	var release = \releaseTime.kr(0);
	var freq = XLine.ar(220,440*3,duration);
	var sig, ps;

	sig = Pluck.ar(PinkNoise.ar(0.35), Impulse.ar(0), freq.reciprocal, freq.reciprocal, 1, XLine.ar(0.1,0.9,1));
	sig = CombL.ar(sig, 0.2, Rand(0.1, 0.2), 3);

	ps = PitchShift.ar(sig, 0.2, pitchRatio: [0.75, 1.5], pitchDispersion: Rand(0.025, 0.05), timeDispersion:Rand(0.0025, 0.005));
	ps = CombL.ar(ps, maxdelaytime: 0.5, delaytime: 2.collect{Rand(0.25, 0.5)}, decaytime: release) * Env.perc(0, releaseTime: release, curve: -8).kr(Done.none);

	ps = Pan2.ar(ps, 2.collect{LFNoise1.ar(Line.ar(15,3,duration))});
	sig = Pan2.ar(sig, LFNoise1.ar(Line.ar(15,3,duration)));

	sig = XFade2.ar(sig, ps * -3.dbamp, Line.ar(-1,0,duration));

	sig = Pan2.ar(sig, LFNoise1.ar(XLine.ar(10,3,duration)));

	sig = sig * -10.dbamp;

	sig = sig * Env.linen(attackTime: 0, sustainTime: duration, releaseTime: release).kr(Done.freeSelf);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\impact, {
	var duration = \duration.kr(5);
	var mod = Line.kr(64,1,duration);
	var sig = SinOsc.ar(55).lincurve(-1,1-1,1,mod);
	var sub = SinOsc.ar(55/2, mul:4);
	sig = LPF.ar(sig, XLine.kr(2500,110,duration));
	sig = sig * Env.perc(attackTime: 0.01, releaseTime: duration, curve: -8).kr(Done.freeSelf);
	sub = sub * Env.perc(attackTime: 0.05, releaseTime: duration, curve: -4).kr(Done.freeSelf);
	sig = Splay.ar(sig + sub);
	Out.ar(\out.kr(0), sig * -52.dbamp);
}).add;

SynthDef(\rumble, {
	var lfo = PlayBuf.ar(1, \buf.kr(0), \rate.kr(0.5), doneAction: Done.none);
	var osc = LFSaw.ar(55 * 4.collect{ lfo.linlin(0,1,-1,1) * Rand(1.0,5) }.midiratio);//.lincurve(-1,1,-1,1,mod);
	var sig = LPF.ar(osc, LFNoise1.kr(Rand(1.3, 3.7)).exprange(60,1500));
	// var sig = osc;

	sig = sig * EnvGen.kr(Env.asr(\attackTime.kr(3), 1, \releaseTime.kr(3), curve: -2), \gate.kr(1), doneAction: 2);
	sig = Splay.ar(sig);
	Out.ar(\out.kr(0), sig * \amp.kr(1) * -28.dbamp * lfo.pow(0.5));
}).add;

SynthDef(\verb, {
	var sig = FreeVerb.ar(In.ar(0, 2), 0.67, 0.9, 0.05);
	sig = Limiter.ar(sig, \limitLevel.kr(0.8), \releaseTime.kr(0.01));
	Out.ar(\out.kr(0), sig);
}).add;
)