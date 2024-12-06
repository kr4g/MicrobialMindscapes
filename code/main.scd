ServerOptions.devices;
(
Server.killAll;
Buffer.freeAll;
~nChans = 4;
s = Server.local;
s.options.outDevice_(
	// "HY5066"
	// "MacBook Pro Speakers"
	"UMC404HD 192k"
	// "ZoomAudioD"
	// "Audio Out"
	// "External Headphones"
	// "BESTISAN SE07D"
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

(
~projectPath = PathName.new(thisProcess.nowExecutingPath).parentPath;
(~projectPath ++ "routines.scd").load;
(~projectPath ++ "functions.scd").load;
(~projectPath ++ "synthdefs.scd").load;
)
// ~pinkTest.(~nChans, 0.5);
~setup.play;
~main.play;