ServerOptions.devices;
(
~nChans = 4;
s = Server.local;
s.options.outDevice_(
	// "MacBook Pro Speakers"
	// "ZoomAudioD"
	// "Audio Out"
	// "Ryan’s AirPods P"
	"External Headphones"
	// "BESTISAN SE07D"
	// "Scarlett 4i4 USB"
	// "Klipsch One II"
	// "UMC1820"
);
// s.options.inDevice_("Built-in Microph");
s.options.numOutputBusChannels_(~nChans);
s.options.numInputBusChannels_(0);
s.options.sampleRate_(48000);
s.options.memSize_(2.pow(20));
s.newBusAllocators;
// ServerBoot.removeAll;
// ServerTree.removeAll;
// ServerQuit.removeAll;
s.reboot;
)

~projectPath = PathName.new(thisProcess.nowExecutingPath).parentPath;
(~projectPath ++ "synthdefs.scd").load;
(~projectPath ++ "functions.scd").load;

(
a = Buffer.read(s, "/Users/ryanmillett/AE24_MM/ARS_24/buffers/audio/FB1_L.wav");
b = Buffer.read(s, "/Users/ryanmillett/AE24_MM/ARS_24/buffers/audio/FB2_L.wav");
c = Buffer.read(s, "/Users/ryanmillett/AE24_MM/ARS_24/buffers/audio/FB1_R.wav");
d = Buffer.read(s, "/Users/ryanmillett/AE24_MM/ARS_24/buffers/audio/FB2_R.wav");
e = Buffer.read(s, "/Users/ryanmillett/AE24_MM/ARS_24/buffers/audio/FB1b_L.wav");
f = Buffer.read(s, "/Users/ryanmillett/AE24_MM/ARS_24/buffers/audio/FB2b_L.wav");
g = Buffer.read(s, "/Users/ryanmillett/AE24_MM/ARS_24/buffers/audio/FB1b_R.wav");
h = Buffer.read(s, "/Users/ryanmillett/AE24_MM/ARS_24/buffers/audio/FB2b_R.wav");
)

(
Synth.tail(nil, \verb);
Synth(\drone1, [\bufnum1, a, \bufnum2, b, \amp, 0.5]);
// Synth(\playBuf, [\bufnum1, c, \bufnum2, d]);
Synth(\drone1, [\bufnum1, e, \bufnum2, f, \amp, 0.5]);
// Synth(\playBuf, [\bufnum1, g, \bufnum2, h]);
)

(
Routine({
	loop{
		~playRandomAFMEvent.value;
		rrand(60.0, 240).wait;
	}
}).play;
)
