(
SynthDef(\calciumOsc, {
	var bufA, bufB, bufC;
	var valA, rocA, valB, rocB, valC, rocC;
	var valAB, valAC, valBC, valABC;
	var rocAB, rocAC, rocBC, rocABC;
	var rateA = \rateA.kr(1);
	var rateB = \rateB.kr(1);
	var rateC = \rateC.kr(1);

	// SOURCE BUFFERS
	bufA = PlayBuf.ar(2, \bufA.kr(0), rateA * BufRateScale.kr(\bufA.kr(0)), loop: 1);
	bufB = PlayBuf.ar(2, \bufB.kr(0), rateB * BufRateScale.kr(\bufB.kr(0)), loop: 1);
	bufC = PlayBuf.ar(2, \bufC.kr(0), rateC * BufRateScale.kr(\bufC.kr(0)), loop: 1);

	// [0] = value, [1] = roc
	valA = bufA[0]; //valA.poll;
	rocA = bufA[1];

	valB = bufB[0];
	rocB = bufB[1];

	valC = bufC[0];
	rocC = bufC[1];

	// Value combinations
	valAB = (valA + valB) * 0.5;
	valAC = (valA + valC) * 0.5;
	valBC = (valB + valC) * 0.5;
	valABC = (valA + valB + valC) * 0.333;

	// ROC combinations
	rocAB = (rocA + rocB) * 0.5;
	rocAC = (rocA + rocC) * 0.5;
	rocBC = (rocB + rocC) * 0.5;
	rocABC = (rocA + rocB + rocC) * 0.333;

	SendTrig.kr(Impulse.kr(20), 0, valA);
	SendTrig.kr(Impulse.kr(20), 1, valB);
	SendTrig.kr(Impulse.kr(20), 2, valC);
	SendTrig.kr(Impulse.kr(20), 3, rocA);
	SendTrig.kr(Impulse.kr(20), 4, rocB);
	SendTrig.kr(Impulse.kr(20), 5, rocC);
	SendTrig.kr(Impulse.kr(20), 6, valABC);

	// OUTPUT
	Out.kr(\outValA.kr(0), valA);
	Out.kr(\outRocA.kr(1), rocA);
	Out.kr(\outValB.kr(2), valB);
	Out.kr(\outRocB.kr(3), rocB);
	Out.kr(\outValC.kr(4), valC);
	Out.kr(\outRocC.kr(5), rocC);

	// OUTPUT COMBOS
	Out.kr(\outValAB.kr(6), valAB);
	Out.kr(\outRocAB.kr(7), rocAB);
	Out.kr(\outValAC.kr(8), valAC);
	Out.kr(\outRocAC.kr(9), rocAC);
	Out.kr(\outValBC.kr(10), valBC);
	Out.kr(\outRocBC.kr(11), rocBC);
	Out.kr(\outValABC.kr(12), valABC);
	Out.kr(\outRocABC.kr(13), rocABC);
}).add;

SynthDef(\playBuf, {
	var sig1, sig2, sig3, sig4, env;
	// var sigA, sigB;
	var pan1, pan2, pan3, pan4;
	var panfreq1, panfreq2, panfreq3, panfreq4;
	var rate1, rate2, rate3, rate4;
	var ratefreq1, ratefreq2, ratefreq3, ratefreq4;
	var direction1 = \direction1.kr(1);
	var direction2 = \direction2.kr(1);
	var direction3 = \direction3.kr(1);
	var direction4 = \direction4.kr(1);
	var mix1 = \mix1.kr(1);
	var mix2 = \mix2.kr(1);
	var mix3 = \mix3.kr(1);
	var mix4 = \mix4.kr(1);
	var amp = \amp.kr(0.5);
	var gate = \gate.kr(1);

	panfreq1 = SinOsc.kr(0.1).range(0.02, 0.2);
	panfreq2 = SinOsc.kr(0.08).range(0.03, 0.25);
	panfreq3 = SinOsc.kr(0.12).range(0.01, 0.15);
	panfreq4 = SinOsc.kr(0.15).range(0.04, 0.3);

	ratefreq1 = SinOsc.kr(0.05).range(0.01, 0.1);
	ratefreq2 = SinOsc.kr(0.06).range(0.015, 0.12);
	ratefreq3 = SinOsc.kr(0.07).range(0.02, 0.15);
	ratefreq4 = SinOsc.kr(0.08).range(0.025, 0.18);

	rate1 = (LFNoise1.kr(ratefreq1).range(\minRate1.kr(0.98), \maxRate1.kr(1.12))) * direction1;
	rate2 = (LFNoise1.kr(ratefreq2).range(\minRate2.kr(0.97), \maxRate2.kr(1.13))) * direction2;
	rate3 = (LFNoise1.kr(ratefreq3).range(\minRate3.kr(0.96), \maxRate3.kr(1.14))) * direction3;
	rate4 = (LFNoise1.kr(ratefreq4).range(\minRate4.kr(0.95), \maxRate4.kr(1.15))) * direction4;

	pan1 = LFNoise1.kr(panfreq1);
	pan2 = LFNoise1.kr(panfreq2);
	pan3 = LFNoise1.kr(panfreq3);
	pan4 = LFNoise1.kr(panfreq4);

	sig1 = PlayBuf.ar(1, \bufnum1.kr(), rate1, loop: 1);
	sig2 = PlayBuf.ar(1, \bufnum2.kr(), rate2, loop: 1);
	sig3 = PlayBuf.ar(1, \bufnum3.kr(), rate3, loop: 1);
	sig4 = PlayBuf.ar(1, \bufnum4.kr(), rate4, loop: 1);

	sig1 = LPF.ar(sig1,  LFNoise1.kr(rate4 * (ratefreq2 * panfreq3)).exprange(250, \maxLPF1.kr(5500)));
	sig2 = LPF.ar(sig2,  LFNoise1.kr(rate3 * (ratefreq4 * panfreq1)).exprange(250, \maxLPF2.kr(5500)));
	sig3 = LPF.ar(sig3,  LFNoise1.kr(rate2 * (ratefreq1 * panfreq4)).exprange(250, \maxLPF3.kr(5500)));
	sig4 = LPF.ar(sig4,  LFNoise1.kr(rate1 * (ratefreq3 * panfreq2)).exprange(250, \maxLPF4.kr(5500)));

	sig1 = PanAz.ar(~nChans, sig1, pan1) * mix1 * LFNoise1.kr(rate3 * (ratefreq4 * panfreq2)).range(0, 1);
	sig2 = PanAz.ar(~nChans, sig2, pan2) * mix2 * LFNoise1.kr(rate4 * (ratefreq3 * panfreq4)).range(0, 1);
	sig3 = PanAz.ar(~nChans, sig3, pan3) * mix3 * LFNoise1.kr(rate1 * (ratefreq2 * panfreq1)).range(0, 1);
	sig4 = PanAz.ar(~nChans, sig4, pan4) * mix4 * LFNoise1.kr(rate2 * (ratefreq1 * panfreq3)).range(0, 1);

	env = EnvGen.kr(Env.asr(4, 1, 4), gate, doneAction: 2);
	amp = amp * LFNoise1.kr(rate3 * (rate1 * (ratefreq4 * panfreq2)) + rate4 * (rate2 * (ratefreq1 * panfreq3))).range(0, 1);

	Out.ar(\out1.kr(0), sig1 * env * amp * \amp1.kr(1) * SinOsc.kr(LFNoise1.kr(0.0023).range(0.05, \maxSwellFreq1.kr(0.15)), 3pi/2).range(0.15, 1));
	Out.ar(\out2.kr(1), sig2 * env * amp * \amp2.kr(1) * SinOsc.kr(LFNoise1.kr(0.0025).range(0.05, \maxSwellFreq2.kr(0.15)), 3pi/2).range(0.15, 1));
	Out.ar(\out3.kr(2), sig3 * env * amp * \amp3.kr(1) * SinOsc.kr(LFNoise1.kr(0.0027).range(0.05, \maxSwellFreq3.kr(0.15)), 3pi/2).range(0.15, 1));
	Out.ar(\out4.kr(3), sig4 * env * amp * \amp4.kr(1) * SinOsc.kr(LFNoise1.kr(0.0029).range(0.05, \maxSwellFreq4.kr(0.15)), 3pi/2).range(0.15, 1));
}).add;

SynthDef(\pulsrForm, {
	var lfo, sig;
	var globalLpfFreq, globalAmp;
	var freqRatio, panRate;

	var valBus = \val.kr(0);
	var rocBus = \roc.kr(0);

	lfo = [In.kr(valBus), In.kr(rocBus)];
	// lfo[0].poll; lfo[1].poll;

	freqRatio = (lfo[1] * lfo[0].linexp(0,1,0.5,3)).midiratio;
	panRate = lfo[1].abs.linexp(0,1,0.3,3.6);

	sig = Mix.fill(8, {
		var minRate, maxRate, pulseRate;
		var formfreq, env, noiseMask, form;

		minRate = ExpRand(0.01, 0.05);
		maxRate = ExpRand(5.0, 11.0);
		pulseRate = lfo[0].pow(0.75).linexp(0, 1, minRate, maxRate);

		formfreq = LFNoise0.kr(
			lfo[0].pow(1.5).linexp(0,1,0.01,3.3)
		).exprange(
			pulseRate.expexp(minRate, maxRate, 720, 1440),
			10800
		);

		env = EnvGen.ar(
			Env.perc(
				attackTime: pulseRate.expexp(minRate, maxRate, 0.3, 0.01),
				releaseTime: (1 / pulseRate) * lfo[0].linexp(0,1,0.01,1),
				curve: lfo[0].linexp(0, 1, -64, -8)
			),
			Dust.ar(pulseRate)
		);

		noiseMask = LFNoise1.ar(
			lfo[1].abs.linexp(0, 1, ExpRand(0.01, 0.03), ExpRand(0.83, 1.9))
		).range(0, 1);

		form = Formant.ar(
			fundfreq: \freq.kr(333.0) * freqRatio,
			formfreq: formfreq,
			bwfreq: formfreq.explin(720*1.5,10800,440,55),
			mul: 0.03
		);

		form = form * env * noiseMask;
		form = HPF.ar(form, LFNoise1.kr(ExpRand(0.03, 0.1)).exprange(720, 1440));

		PanAz.ar(~nChans, form, LFNoise1.kr(panRate))
	});

	globalAmp = LFNoise1.ar(0.05).range(0, 1);
	globalLpfFreq = LFNoise1.kr(0.01).exprange(720, 1440*4);

	sig = sig * globalAmp;
	sig = LPF.ar(sig, globalLpfFreq);
	sig = sig * Env.asr(10,1,1,8).kr(Done.freeSelf, \gate.kr(1));

	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\pulsrPulse, {
	var lfo, sig;
	var globalLpfFreq, globalAmp;
	var freqRatio, panRate;

	var valBus = \val.kr(0);
	var rocBus = \roc.kr(0);

	lfo = [In.kr(valBus), In.kr(rocBus)];
	// lfo[0].poll; lfo[1].poll;

	freqRatio = (lfo[1] * lfo[0].linexp(0,1,0.5,3)).midiratio;
	panRate = lfo[1].abs.linexp(0,1,0.3,3.6);

	sig = Mix.fill(8, {
		var minRate, maxRate, pulseRate;
		var formfreq, env, noiseMask, form;

		minRate = ExpRand(0.05, 0.1);
		maxRate = ExpRand(13.0, 27.0);
		pulseRate = lfo[0].pow(2).linexp(0, 1, minRate, maxRate);

		formfreq = LFNoise0.kr(pulseRate).exprange(
			pulseRate.expexp(minRate, maxRate, 720/2, 1440),
			10800/2
		);

		env = EnvGen.ar(
			Env.perc(
				attackTime: pulseRate.expexp(minRate, maxRate, 0.3, 0.01),
				releaseTime: (1 / pulseRate) * lfo[0].linexp(0,1,0.01,1),
				curve: lfo[0].linexp(0, 1, -64, -8)
			),
			Impulse.ar(pulseRate)
		);

		noiseMask = LFNoise1.ar(
			lfo[1].abs.linexp(0, 1, ExpRand(0.01, 0.03), ExpRand(0.83, 1.9))
		).range(0, 1);

		form = LFPulse.ar(
			freq: formfreq,
			width:lfo[1].linlin(-1,1,0.1,0.5),
			mul: 0.02
		);

		form = form * env * noiseMask;
		form = HPF.ar(form, LFNoise1.kr(ExpRand(0.03, 0.1)).exprange(720, 1440));

		PanAz.ar(~nChans, form, LFNoise1.kr(panRate))
	});

	globalAmp = LFNoise1.ar(0.05).range(0, 1);
	globalLpfFreq = LFNoise1.kr(0.01).exprange(720, 1440*4);

	sig = sig * globalAmp;
	sig = LPF.ar(sig, globalLpfFreq);
	sig = sig * Env.asr(10,1,1,8).kr(Done.freeSelf, \gate.kr(1));

	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\scrape, {
	var valLFO = PlayBuf.ar(1, \valBuf.kr(0), BufRateScale.kr(\valBuf.kr(0)) * \rate.kr(1), doneAction: Done.none);
	var rocLFO = PlayBuf.ar(1, \rocBuf.kr(0), BufRateScale.kr(\rocBuf.kr(0)) * \rate.kr(1), doneAction: Done.none);
	var freq = \freq.kr([440,440*3]);

	var impulse = BPF.ar(WhiteNoise.ar(0.5), rocLFO.linlin(-1,1,500,4500), rq: 0.75);
	var pluckSig = Pluck.ar(impulse, Impulse.ar(rocLFO.linlin(-1,1,10,40)), freq.reciprocal, freq.reciprocal, 1, valLFO.linlin(0,1,0.85,0.01)).sum;

	pluckSig = LPF.ar(pluckSig, 2500);

	pluckSig = PanAz.ar(~nChans,pluckSig, LFNoise1.kr(0.4));
	pluckSig = pluckSig * EnvGen.kr(Env.asr(\attackTime.kr(3), 1, \releaseTime.kr(0), curve: -8), \gate.kr(1), doneAction: 2);
	Out.ar(\out.kr(0), pluckSig * -3.dbamp);
}).add;

SynthDef(\pluck, {
	var duration = \duration.kr(10);
	var release = \releaseTime.kr(0);
	var freq = XLine.ar(220,440*3,duration);
	var sig, delay, ps;

	sig = Pluck.ar(PinkNoise.ar(0.35), Impulse.ar(0), freq.reciprocal, freq.reciprocal, 5, XLine.ar(0.1,0.5,1));
	delay = CombL.ar(sig, 1, Clip.kr(1 - \reactionStrength.kr(0.5), 0.1, 1)*0.5, release) * Env.perc(0, release, -8.dbamp, curve: -16).kr(Done.none);
	delay = PanAz.ar(~nChans, delay, LFNoise1.ar(1.7));
	sig = PanAz.ar(~nChans, sig, LFNoise1.ar(1.3));

	sig = sig + delay;

	sig = sig * Env.linen(attackTime: 0, sustainTime: duration, releaseTime: release).kr(Done.freeSelf);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\heat, {
	var valLFO = PlayBuf.ar(1, \valBuf.kr(0), BufRateScale.kr(\valBuf.kr(0)) * \rate.kr(1), doneAction: Done.none);
	var rocLFO = PlayBuf.ar(1, \rocBuf.kr(0), BufRateScale.kr(\rocBuf.kr(0)) * \rate.kr(1), doneAction: Done.none);

	var osc = LFSaw.ar(55);
	var sig = LPF.ar(osc, rocLFO.pow(0.5).linexp(0, 1, 60, 2500));

	sig = sig * EnvGen.kr(Env.asr(\attackTime.kr(3), 1, \releaseTime.kr(3), curve: -2), \gate.kr(1), doneAction: 2);
	sig = SplayAz.ar(~nChans, sig);
	Out.ar(\out.kr(0), sig * \amp.kr(1) * -36.dbamp);
}).add;

SynthDef(\binswapBPF, {
    |in=0, out=0, gate=1, wet=0.5|
    var sig = In.ar(in);
    var chain = FFT(LocalBuf(2048), sig);
    var binSwapped = IFFT(PV_BinScramble(chain,
        wipe: Clip.kr(LFNoise1.kr(SinOsc.kr(0.033).range(0.13, 0.73)).range(0.1, 0.9), 0.1, 0.9),
        width: Clip.kr(LFNoise1.kr(SinOsc.kr(0.036).range(0.13, 0.73)).range(0.1, 0.9), 0.1, 0.9),
        trig: Dust.kr(ExpRand(0.01, 0.02))
    ));
    var bpf = Mix.fill(10, {
        var freq = LFNoise1.kr(SinOsc.kr(ExpRand(0.02, 0.05)).range(0.13, 0.73)).exprange(100, 9000);
        var rq = 0.01;
        var pan = LFNoise1.kr(SinOsc.kr(ExpRand(0.015, 0.023)).range(0.1, 0.93));
        var fmLFO = LFNoise0.kr(
            freq: LFNoise1.kr(ExpRand(0.1, 0.15)).range(0.05, 7.1),
            mul: LFNoise1.kr(ExpRand(0.1, 0.15)).range(50.0, 550)
        );
        PanAz.ar(~nChans,
            BPF.ar(
                FreqShift.ar(binSwapped, fmLFO),
                freq, rq, mul: 8),
            pan
        );
    });
	// var wet = LFNoise1.kr(ExpRand(0.007, 0.13)).range(0, 1);
    binSwapped = LPF.ar(binSwapped, LFNoise1.kr(ExpRand(0.05, 0.08)).exprange(550, 1500));
    binSwapped = PanAz.ar(~nChans, binSwapped, LFNoise1.kr(SinOsc.kr(Rand(0.02, 0.03)).range(0.06, 0.67)));
    sig = (sig * (1 - wet)) + ((binSwapped + bpf) * wet);
    sig = sig * EnvGen.kr(Env.asr(1, 1, 1), gate, doneAction: 2);
    Out.ar(out, sig);
}).add;

SynthDef(\pitchShifter, {
    |in=0, out=0, gate=1, wet=0.5|
    var sig = In.ar(in);
    var ps = Mix.fill(8, {
        var window = Rand(0.1, 0.5);
        var psh = PitchShift.ar(
            sig,
            windowSize: window,
            pitchRatio: Rand(0.5, 4.0),
            pitchDispersion: 0.01,
            timeDispersion: 0.05
        );
        PanAz.ar(~nChans,
            psh,
            SinOsc.kr(LFNoise1.kr(ExpRand(0.07, 0.15)).range(0.06, 1.17)), 0.5
        );
    });
	// var wet = LFNoise1.kr(ExpRand(0.007, 0.13)).range(0, 1);
    sig = (sig * (1 - wet)) + (ps * wet);
    sig = LPF.ar(sig, LFNoise1.kr(ExpRand(0.03, 0.05)).exprange(550, 2500));
    sig = sig * EnvGen.kr(Env.asr(1, 1, 1), gate, doneAction: 2);
    Out.ar(out, sig);
}).add;

SynthDef(\verb, {
	var sig = FreeVerb.ar(In.ar(0, ~nChans), \mix.kr(0.33), \room.kr(0.92), \damp.kr(0.05));
	sig = Limiter.ar(sig, \limitLevel.kr(0.95), \releaseTime.kr(0.01));
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\pinkTest, {
	var sig;
	sig = PinkNoise.ar(\amp.kr(0.5));
	sig = sig * Env.linen(sustainTime: \duration.kr(1), releaseTime: 0.0).kr(Done.freeSelf);
	Out.ar(\out.kr(0), sig);
}).add;
)
