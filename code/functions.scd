(
~loadBuffers = { |path, dict, type|
	path.files.do { |file|
		var key = file.fileNameWithoutExtension.asSymbol;
		dict[key] = switch(type,
			\audio, { Buffer.read(s, file.fullPath) },
			\calcium, { Buffer.read(s, file.fullPath) }
		);
	};
};

~initGroups = {
	~groups = ();
	~groups.control = Group.new(s, \addToHead);
	~groups.players = Group.after(~groups.control);
	~groups.fx = Group.after(~groups.players);
	~groups.verb = Group.after(~groups.fx);
};

~initBusses = { |nChans|
	~fxBusses = 4.collect { Bus.audio(s, nChans) };
	~verbBus = Bus.audio(s, nChans);

	~ctlBuses = (
		val: [\a, \b, \c, \ab, \ac, \bc, \abc].collect({ |key|
			key -> Bus.control(s, 1)
		}).asDict,
		roc: [\a, \b, \c, \ab, \ac, \bc, \abc].collect({ |key|
			key -> Bus.control(s, 1)
		}).asDict
	);
};

~processReaction = { |beforeScale = 0.01, duringScale = 0.01, afterScale = 0.01|
	Routine({
		var dataPath = PathName(~projectPath).parentPath ++ "buffers/data/afm/reactions";
		var allFiles = PathName(dataPath).files;
		var chosenFile = allFiles.choose;
		var dataBuffer = Buffer.readChannel(s, chosenFile.fullPath, channels: [0]);
		var rateBuffer = Buffer.readChannel(s, chosenFile.fullPath, channels: [1]);
		var metaBuffer = Buffer.readChannel(s, chosenFile.fullPath, channels: [2]);
		s.sync;
		("Playing file " ++ chosenFile.fileName).postln;
		metaBuffer.loadToFloatArray(action: { |metaArray|
			var reactionStartFrame = metaArray[0];
			var reactionEndFrame = metaArray[1];
			var reactionStrength = metaArray[2];
			var routine = Routine({
				var preReactionTime = (reactionStartFrame / s.sampleRate) / beforeScale;
				var reactionTime = ((reactionEndFrame - reactionStartFrame) / s.sampleRate) / duringScale;
				var postReactionTime = ((dataBuffer.numFrames - reactionEndFrame) / s.sampleRate) / afterScale;
				var totalTime = [preReactionTime, reactionTime, postReactionTime].sum;
				// [preReactionTime, reactionTime, postReactionTime, totalTime].postln;
				var scrape, pluck, heat;

				"Section 1: Beginning".postln;
				s.bind{
					scrape = Synth(\scrape, [
						\rate, beforeScale,
						\valBuf, dataBuffer,
						\rocBuf, rateBuffer,
						\attackTime, preReactionTime,
						\releaseTime, reactionTime
					]);
				};
				s.bind{
					heat = Synth(\heat, [
						\rate, beforeScale,
						\valBuf, dataBuffer,
						\rocBuf, rateBuffer,
						\attackTime, preReactionTime,
						\releaseTime, reactionTime + postReactionTime
					]);
				};
				preReactionTime.wait;

				"Section 2: Reaction period".postln;
				s.bind{ scrape.set(\gate, 0); };
				s.bind{
					pluck = Synth(\pluck, [
						\reactionStrength, reactionStrength,
						\duration, reactionTime,
						\releaseTime, postReactionTime
					]);
				};
				reactionTime.wait;

				"Section 3: Post reaction".postln;
				postReactionTime.wait;
				s.bind{ heat.set(\gate, 0); };

				"Done.".postln;
				[dataBuffer, rateBuffer, metaBuffer].do(_.free);
			});
			routine.play;
		});
	}).play;
};

~pinkTest = { |chans = 2, dur = 0.5|
	Routine({
		inf.do { |i|
			Synth(\pinkTest, [\amp, 0.15, \duration, dur, \out, i % chans]);
			dur.wait;
		}
	}).play;
};
)