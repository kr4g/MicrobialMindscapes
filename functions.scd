(
~playRandomAFMEvent = { |beforeRate=0.02, reactRate=0.01, afterRate=0.05|
	var path, files, beforeFiles, reactionFiles, afterFiles, randIndex, beforePath, reactionPath, afterPath;
	path = "/Users/ryanmillett/Downloads/Buffers";
	files = PathName(path).files;
	beforeFiles = files.select({|f| f.fileName.contains("before")});
	reactionFiles = files.select({|f| f.fileName.contains("reaction")});
	afterFiles = files.select({|f| f.fileName.contains("after")});

	if(beforeFiles.size > 0, {
		randIndex = beforeFiles.size.rand;
		beforePath = beforeFiles[randIndex].fullPath;
		reactionPath = reactionFiles[randIndex].fullPath;
		afterPath = afterFiles[randIndex].fullPath;

		Buffer.read(s, beforePath, action: {|beforeBuf|
			Buffer.read(s, reactionPath, action: {|reactionBuf|
				Buffer.read(s, afterPath, action: {|afterBuf|
					Routine({
						var before_dur, reaction_dur, after_dur;
						var scrape, rumble;
						var beforeDuringBuf = Buffer.alloc(s, beforeBuf.numFrames + reactionBuf.numFrames, 1);
						var duringAfterBuf = Buffer.alloc(s, reactionBuf.numFrames + afterBuf.numFrames, 1);

						s.sync;

						beforeBuf.copyData(beforeDuringBuf, 0, 0, beforeBuf.numFrames);
						reactionBuf.copyData(beforeDuringBuf, 0, beforeBuf.numFrames, reactionBuf.numFrames);
						reactionBuf.copyData(duringAfterBuf, 0, 0, reactionBuf.numFrames);
						afterBuf.copyData(duringAfterBuf, 0, reactionBuf.numFrames, afterBuf.numFrames);

						before_dur = beforeBuf.numFrames / 48000 * (1/beforeRate);
						reaction_dur = reactionBuf.numFrames / 48000 * (1/reactRate);
						after_dur = afterBuf.numFrames / 48000 * (1/afterRate);
						// "%, %, %".format(before_dur, reaction_dur, after_dur).postln;

						s.bind{
							scrape = Synth(\scrape, [
								\buf, beforeDuringBuf,
								\rate, beforeRate,
								\releaseTime, reaction_dur
							]);
						};
						before_dur.wait;
						scrape.set(\gate, 0);
						s.bind{ Synth(\pluck, [\duration, reaction_dur, \releaseTime, after_dur]); };
						s.bind{ Synth(\impact, [\duration, reaction_dur + (after_dur/2)]); };
						s.bind{ rumble = Synth(\rumble, [\buf, duringAfterBuf, \rate, afterRate, \attackTime: reaction_dur, \releaseTime: after_dur]) };
						reaction_dur.wait;
						s.bind{ rumble.set(\gate, 0); };
						after_dur.wait;

						beforeBuf.free;
						reactionBuf.free;
						beforeDuringBuf.free;
						afterBuf.free;
					}).play;
				});
			});
		});
	}, {
		"No files found in directory".postln;
	});
};
)