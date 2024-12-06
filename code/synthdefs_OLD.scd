(
SynthDef(\ctrl, {
	var rateMod = LFNoise1.kr(ExpRand(0.013, 0.017)).exprange(0, 1);
    var lfo = PlayBuf.ar(2, \bufnum1.kr(0), BufRateScale.kr(\bufnum1.kr(0)) * rateMod.linexp(0,1,1,3), loop: 1);
    var lfoL = lfo[0];
    var lfoR = lfo[1];

    Out.kr(\outBus1.kr(0), lfoL);
    Out.kr(\outBus2.kr(1), lfoR);
    Out.kr(\outBus3.kr(1), rateMod);
}).add;

SynthDef(\playBuf, {
	var sig1, sig2, sig, chain, binSwapped, ps, bpf;
	var xfadePos1, xfadePos2, xfadePos3, finalXfade;

	// NOISE MASKS
	var noiseMask1 = LFNoise1.kr(SinOsc.kr(ExpRand(0.003, 0.007)).exprange(0.013, 0.196)).range(0, 1);
	var noiseMask2 = LFNoise1.kr(SinOsc.kr(ExpRand(0.003, 0.007)).exprange(0.013, 0.196)).range(0, 1);

	// SOURCE 1 BUF
	sig1 = PlayBuf.ar(1, \buf1.kr(0), BufRateScale.kr(\buf1.kr(0)) * \buf1_rate.kr(1) * LFNoise1.kr(ExpRand(0.0031, 0.0035)).range(0.667, 1.167), loop: 1) * -1.dbamp;

	// SOURCE 1 FX
	chain = FFT(LocalBuf(2048), sig1);
	binSwapped = IFFT(PV_BinScramble(chain,
		wipe: Clip.kr(LFNoise1.kr(SinOsc.kr(0.033).range(0.13, 0.73)).range(0.1, 0.9), 0.1, 0.9),
		width: Clip.kr(LFNoise1.kr(SinOsc.kr(0.036).range(0.13, 0.73)).range(0.1, 0.9), 0.1, 0.9),
		trig: Dust.kr(ExpRand(0.01, 0.02))
	));
	bpf = Mix.fill(10, {
		var freq = LFNoise1.kr(SinOsc.kr(0.03).range(0.13, 0.73)).exprange(100, 9000);
		var rq = 0.001;
		var pan = LFNoise1.kr(SinOsc.kr(0.015).range(0.1, 0.93));
		var fmLFO = LFNoise0.kr(
			freq: LFNoise1.kr(0.1).range(0.05, 7.1),
			mul: LFNoise1.kr(0.1).range(50.0, 550)
		);
		PanAz.ar(~nChans,
			BPF.ar(
				FreqShift.ar(binSwapped, fmLFO),
				freq, rq, mul: 8),
			pan
		);
	});

	xfadePos1 = LFNoise1.kr(SinOsc.kr(Rand(0.002, 0.003)).exprange(0.01, 0.067));
	xfadePos2 = LFNoise1.kr(SinOsc.kr(Rand(0.002, 0.003)).exprange(0.01, 0.067));
	xfadePos3 = SinOsc.kr(LFNoise1.kr(0.007).exprange(0.009, 0.17));
	finalXfade = LFNoise1.kr(0.05);

	// SOURCE 1 MIX
	binSwapped = LPF.ar(binSwapped, LFNoise1.kr(0.05).exprange(550, 1500));
	binSwapped = PanAz.ar(~nChans, binSwapped, LFNoise1.kr(SinOsc.kr(Rand(0.02, 0.03)).range(0.06, 0.67)));
	binSwapped = (binSwapped * (1 - xfadePos1)) + (bpf * xfadePos1);

	sig1 = PanAz.ar(~nChans, sig1, LFNoise1.kr(SinOsc.kr(Rand(0.02, 0.03)).range(0.06, 0.67)));
	sig1 = LPF.ar(sig1 * noiseMask1, LFNoise1.kr(0.05).exprange(150, 1500));
	sig1 = (sig1 * (1 - xfadePos2)) + (binSwapped * xfadePos2);


	// ------------------------------

	// SOURCE 2 BUF
	sig2 = PlayBuf.ar(1, \buf2.kr(0), BufRateScale.kr(\buf2.kr(0)) * \buf2_rate.kr(1), loop: 1) * -3.dbamp;

	// SOURCE 2 FX
	ps = Mix.fill(8, {
		var window = Rand(0.1, 0.5);
		var psh = PitchShift.ar(
			sig2,
			windowSize: window,
			pitchRatio: Rand(0.5, 4.0),
			pitchDispersion: 0.01,
			timeDispersion: 0.05
		);
		// var noiseMask = LFNoise1.kr(SinOsc.kr(ExpRand(0.013, 0.017)).exprange(0.067, 0.196)).range(0,1);
		PanAz.ar(~nChans,
			psh,
			SinOsc.kr(LFNoise1.kr(0.07).range(0.06, 1.17)), 0.5
		);
	});

	// SOURCE 2 MIX
	sig2 = PanAz.ar(~nChans, sig2, SinOsc.kr(LFNoise1.kr(0.07).range(0.06, 0.17)));
	sig2 = sig2 * noiseMask2;
	sig2 = (sig2 * (1 - xfadePos3)) + (ps * xfadePos3);

	sig2 = LPF.ar(sig2, LFNoise1.kr(0.03).exprange(550, 2500));

	// OVERALL MIX
	sig = (sig1 * (1 - finalXfade)) + (sig2 * finalXfade);

	// sig = sig * SinOsc.kr(LFNoise1.kr(Rand(0.03, 0.05)).range(0.03, 0.07)).range(0,1);
	sig = LPF.ar(sig, LFNoise1.kr(0.03).exprange(550, 6500));
	sig = sig * EnvGen.kr(Env.asr(10, 1, 10), \gate.kr(1), doneAction: 2);
	sig = Limiter.ar(sig, \limitLevel.kr(0.9), \releaseTime.kr(0.01));
	Out.ar(\out.kr(0), sig * \amp.kr(1, 0.5) * -8.dbamp);
}).add;

SynthDef(\smplr, {
	var sig = PlayBuf.ar(1, \buf.kr(0), BufRateScale.kr(\buf.kr(0)) * \bufRate.kr(1), loop: 1) * -12.dbamp;
	var fb;
	sig = Splay.ar(sig);
	// fb = FreqShift.ar(LocalIn.ar(2), LFSaw.kr(SinOsc.kr(0.01, 3pi/2).range(0.1, 10), 1).exprange(10,1550));
	fb = LocalIn.ar(2);
	sig = CombC.ar(sig + fb, delaytime: 0.1, decaytime: 1) * -6.dbamp;
	sig = PitchShift.ar(sig, 0.2, LFNoise1.kr(0.9).exprange(1.067, 3.667), LFNoise1.kr(1.1).exprange(0.001, 0.067), 0.01);
	LocalOut.ar(sig * 0.75);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\pulsr, {
	var playRateMod = LFNoise1.kr(ExpRand(0.006, 0.009)).range(1, 3.6);
	var lfo = PlayBuf.ar(2, \lfoBuf.kr(0), BufRateScale.kr(\lfoBuf.kr(0)) * \lfoBuf_rate.kr(1) * playRateMod, loop: 1);
	var sig = Mix.fill(10, {
		var minRate = ExpRand(0.01, 0.1);
		var maxRate = ExpRand(9.0, 13.0);
		var pulseRate = lfo[0].pow(2).linexp(0, 1, minRate, maxRate);
		var formfreq = LFNoise0.kr(lfo[0].pow(1.5).linexp(0,1,0.01,3.3)).exprange(pulseRate.expexp(minRate, maxRate, 720, 1440), 10800);
		var env =EnvGen.ar(
			Env.perc(attackTime: pulseRate.explin(minRate, maxRate, 0.3, 0.01), releaseTime: 1 / pulseRate, curve: -32),
			Impulse.ar(pulseRate)
		);
		var form = Formant.ar(
			fundfreq: \freq.kr(333.0) * (lfo[1] * lfo[0].linexp(0,1,0.5,3)).midiratio,
			formfreq: formfreq * playRateMod.linlin(1, 3.6, -1, 1).midiratio,
			bwfreq: formfreq.explin(720*1.5,10800,440,55),
			mul: 0.05
		) * env * LFNoise1.ar(lfo[1].abs.linexp(0,1,0.01,1.9)).range(0, 1);
		form = LPF.ar(form, LFNoise1.kr(0.03).exprange(720, 1440*2));
		PanAz.ar(~nChans, form, LFNoise1.kr(lfo[1].abs.linexp(0,1,0.3,3.6)))
	});

	sig = sig * LFNoise1.ar(0.05).range(0, 1);
	sig = LPF.ar(sig, LFNoise1.kr(0.01).exprange(720, 1440*4));

	sig = sig * Env.asr(20).kr(Done.freeSelf, \gate.kr(1));
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\scrape, {
	var buf = \buf.kr(0);
	var sig = PlayBuf.ar(1, buf, \rate.kr(0.5), doneAction: Done.none);
	var freq = \freq.kr([440,440*3]) * sig.bipolar(1).midiratio;
	var lfo1 = LFNoise1.ar(0.67);
	var impulse = BPF.ar(WhiteNoise.ar(0.5), sig.linexp(0,1,250,2500), rq: 0.75);
	var pluckSig = Pluck.ar(impulse, Impulse.ar(sig.range(17,3)), freq.reciprocal, freq.reciprocal, 3, sig.range(0.8,0.05)).sum;
	pluckSig = pluckSig * lfo1.range(-12.dbamp, -6.dbamp);
	pluckSig = PanAz.ar(~nChans,pluckSig, LFNoise1.kr(0.4));
	pluckSig = pluckSig * EnvGen.kr(Env.asr(2, 1, \releaseTime.kr(0), curve: -8), \gate.kr(1), doneAction: 2);
	Out.ar(\out.kr(0), pluckSig * -3.dbamp);
}).add;

SynthDef(\pluck, {
	var duration = \duration.kr(10);
	var release = \releaseTime.kr(0);
	var freq = XLine.ar(220,440*3,duration);
	var sig, ps;

	sig = Pluck.ar(PinkNoise.ar(0.35), Impulse.ar(0), freq.reciprocal, freq.reciprocal, 1, XLine.ar(0.1,0.9,1));
	sig = CombL.ar(sig, 0.2, Rand(0.1, 0.2), 3);

	// ps = PitchShift.ar(sig, 0.2, pitchRatio: [0.75, 1.5], pitchDispersion: Rand(0.025, 0.05), timeDispersion:Rand(0.0025, 0.005));
	// ps = CombL.ar(ps, maxdelaytime: 0.5, delaytime: 2.collect{Rand(0.25, 0.5)}, decaytime: release) * Env.perc(0, releaseTime: release, curve: -8).kr(Done.none);

	// ps = PanAz.ar(~nChans, ps, 2.collect{LFNoise1.ar(Line.ar(15,3,duration))});
	sig = PanAz.ar(~nChans,sig, LFNoise1.ar(Line.ar(15,3,duration)));

	// sig = XFade2.ar(sig, ps * -3.dbamp, 0);

	sig = PanAz.ar(~nChans, sig, LFNoise1.ar(XLine.ar(10,3,duration)));

	sig = sig * -6.dbamp;

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
	sig = SplayAz.ar(~nChans, sig + sub);
	Out.ar(\out.kr(0), sig * -62.dbamp);
}).add;

SynthDef(\rumble, {
	var lfo = PlayBuf.ar(1, \buf.kr(0), \rate.kr(0.5), doneAction: Done.none);
	var osc = LFSaw.ar(55 * 4.collect{ lfo.linlin(0,1,-1,1) * Rand(1.0,5) }.midiratio);//.lincurve(-1,1,-1,1,mod);
	var sig = LPF.ar(osc, LFNoise1.kr(Rand(1.3, 3.7)).exprange(60,2500));
	// var sig = osc;

	sig = sig * EnvGen.kr(Env.asr(\attackTime.kr(3), 1, \releaseTime.kr(3), curve: -2), \gate.kr(1), doneAction: 2);
	sig = SplayAz.ar(~nChans, sig);
	Out.ar(\out.kr(0), sig * \amp.kr(1) * -23.dbamp * lfo.pow(0.5));
}).add;

SynthDef(\verb, {
	var sig = FreeVerb.ar(In.ar(0, ~nChans), 0.67, 0.9, 0.05);
	sig = Limiter.ar(sig, \limitLevel.kr(0.9), \releaseTime.kr(0.01));
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\pinkTest, {
	var sig;
	sig = PinkNoise.ar(\amp.kr(0.5));
	sig = sig * Env.linen(sustainTime: \duration.kr(1), releaseTime: 0.0).kr(Done.freeSelf);
	Out.ar(\out.kr(0), sig);
}).add;
)