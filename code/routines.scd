(
~setup = Routine({
	var audioPath = PathName(~projectPath).parentPath ++ "buffers/audio/";
	var dataPath = PathName(~projectPath).parentPath ++ "buffers/data/calcium/";

	(~projectPath ++ "functions.scd").load;

	"Starting setup...".postln;

	// DICTS
	~buffers = Dictionary.newFrom([\audio, Dictionary.new(), \data, Dictionary.new()]);
	~buffers[\data][\calcium] = ();
	~synths = (\playbufs: (), \pulsrs: (), \fx: (), \verbs: ());

	// BUFFERS
	// ~loadBuffers.(PathName(audioPath), ~buffers[\audio], \audio);
	~loadBuffers.(PathName(dataPath), ~buffers[\data][\calcium], \calcium);
	s.sync;

	~buffers[\audio][\tonal] = Buffer.readChannel(s, audioPath ++ "tonal.wav", channels: [0]);
	~buffers[\audio][\crunchy] = Buffer.readChannel(s, audioPath ++ "crunchy.wav", channels: [0]);
	~buffers[\audio][\sharp] = Buffer.readChannel(s, audioPath ++ "sharp.wav", channels: [0]);
	~buffers[\audio][\slimey] = Buffer.readChannel(s, audioPath ++ "slimey.wav", channels: [0]);
	~buffers[\audio][\zappy] = Buffer.readChannel(s, audioPath ++ "zappy.wav", channels: [0]);
	~buffers[\audio][\beepy] = Buffer.readChannel(s, audioPath ++ "beepy.wav", channels: [0]);
	~buffers[\audio][\droney] = Buffer.readChannel(s, audioPath ++ "droney.wav", channels: [0]);
	~buffers[\audio][\grainy] = Buffer.readChannel(s, audioPath ++ "grainy.wav", channels: [0]);
	~buffers[\audio][\chirpy] = Buffer.readChannel(s, audioPath ++ "chirpy.wav", channels: [0]);
	~buffers[\audio][\FB2b_L] = Buffer.read(s, audioPath ++ "FB2b_L.wav");
	~buffers[\audio][\FB2b_R] = Buffer.read(s, audioPath ++ "FB2b_R.wav");
	~buffers[\audio][\FB1b_L] = Buffer.read(s, audioPath ++ "FB1b_L.wav");
	s.sync;

	// BUSSES
	~initBusses.(~nChans);
	s.sync;

	"Setup done".postln;
});

~main = Routine({
	"Starting main program...".postln;

	(~projectPath ++ "oscdefs.scd").load;

	// GROUPS
	~initGroups.();

	// SYNTHS
	~synths[\verbs][\main] = Synth.tail(nil, \verb);

	~synths[\ctrl] = Synth(\calciumOsc, [
		\bufA, ~buffers[\data][\calcium][\Apamin],
		\bufB, ~buffers[\data][\calcium][\cCD4],
		\bufC, ~buffers[\data][\calcium][\nCD4],
		\rateA, 1,
		\rateB, 1,
		\rateC, 1,
	]
	++ ~ctlBuses.val.collect({ |bus, key| [\outVal ++ key, bus.index]}).asPairs
	++ ~ctlBuses.roc.collect({ |bus, key| [\outRoc ++ key, bus.index]}).asPairs,
	~groups.control
	);

	// ~synths[\fx][\pitchShifter1] = Synth(\pitchShifter, [
	// 	\in, ~fxBusses[0],
	// 	\out, 0
	// ], ~groups.fx);
	//
	// ~synths[\fx][\pitchShifter2] = Synth(\pitchShifter, [
	// 	\in, ~fxBusses[1],
	// 	\out, 0
	// ], ~groups.fx);
	//
	// ~synths[\fx][\binswapBPF1] = Synth(\binswapBPF, [
	// 	\in, ~fxBusses[2],
	// 	\out, 0
	// ], ~groups.fx);
	//
	// ~synths[\fx][\binswapBPF2] = Synth(\binswapBPF, [
	// 	\in, ~fxBusses[3],
	// 	\out, 0
	// ], ~groups.fx);

	~synths[\playbufs][0] = Synth(\playBuf, [
		\bufnum1, ~buffers[\audio][\tonal],
		\bufnum2, ~buffers[\audio][\crunchy],
		\bufnum3, ~buffers[\audio][\sharp],
		\bufnum4, ~buffers[\audio][\slimey],
		\mix1, 0.5,
		\mix2, 1,
		\mix3, 1,
		\mix4, 1,
		\out1, 0,//~fxBusses[2],
		\out2, 0,//~fxBusses[3],
		\out3, 0,//~fxBusses[1],
		\out4, 0,//~fxBusses[0],
		\amp, 0.9
	], ~groups.players);

	~synths[\playbufs][1] = Synth(\playBuf, [
		\bufnum1, ~buffers[\audio][\droney],
		\bufnum2, ~buffers[\audio][\chirpy],
		\bufnum3, ~buffers[\audio][\zappy],
		\bufnum4, ~buffers[\audio][\beepy],
		\mix1, 0.6,
		\mix2, 1,
		\mix3, 1,
		\mix4, 1,
		\out1, 0,//~fxBusses[2],
		\out2, 0,//~fxBusses[3],
		\out3, 0,//~fxBusses[1],
		\out4, 0,//~fxBusses[0],
		\amp, 0.9
	], ~groups.players);

	~synths[\playbufs][2] = Synth(\playBuf, [
		\bufnum1, ~buffers[\audio][\FB1b_L],
		\bufnum2, ~buffers[\audio][\FB2b_L],
		\bufnum3, ~buffers[\audio][\FB2b_R],
		\bufnum4, ~buffers[\audio][\grainy],
		\mix1, 0.5,
		\mix2, 0.5,
		\mix3, 0.5,
		\mix4, 1,
		\out1, 0,//~fxBusses[2],
		\out2, 0,//~fxBusses[3],
		\out3, 0,//~fxBusses[1],
		\out4, 0,//~fxBusses[0],
		\amp, 0.9
	], ~groups.players);

	~synths[\pulsrs][0] = Synth(\pulsrForm, [
		\freq, 36,
		\val, ~ctlBuses.val[\a],
		\roc, ~ctlBuses.roc[\a]
	], ~groups.players);

	~synths[\pulsrs][1] = Synth(\pulsrForm, [
		\freq, 36,
		\val, ~ctlBuses.val[\b],
		\roc, ~ctlBuses.roc[\b]
	], ~groups.players);

	~synths[\pulsrs][2] = Synth(\pulsrForm, [
		\freq, 36,
		\val, ~ctlBuses.val[\c],
		\roc, ~ctlBuses.roc[\c]
	], ~groups.players);

	rrand(60.0, 120).wait;

	~afm.play;
});

~afm = Routine({
	loop{
		~processReaction.value(beforeScale: 0.01, duringScale: 0.01, afterScale: 0.01);
		rrand(120.0, 480).wait;
	};
});
)
