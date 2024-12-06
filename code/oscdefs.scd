(
~calciumOSC = OSCdef(\calcium, {|msg|
	var id = msg[2], val = msg[3];
	// [id, val].postln;
	if (id < 3) {
		~synths[\playbufs][id].set(\maxRate1, val.linexp(0, 1, 1.12, 2.196));
		~synths[\playbufs][id].set(\maxRate2, val.linexp(0, 1, 1.13, 2.197));
		~synths[\playbufs][id].set(\maxRate3, val.linexp(0, 1, 1.14, 2.198));
		~synths[\playbufs][id].set(\maxRate4, val.linexp(0, 1, 1.15, 2.199));

		~synths[\playbufs][id].set(\minRate1, val.linexp(0, 1, 0.98, 0.456));
		~synths[\playbufs][id].set(\minRate2, val.linexp(0, 1, 0.97, 0.457));
		~synths[\playbufs][id].set(\minRate3, val.linexp(0, 1, 0.96, 0.458));
		~synths[\playbufs][id].set(\minRate4, val.linexp(0, 1, 0.95, 0.459));

		4.do{ |i| ~synths[\playbufs][id].set(\maxLPF ++ (i + 1), val.linexp(0, 1, 5500, 1500)) };
		4.do{ |i| ~synths[\playbufs][id].set(\maxSwellFreq1 ++ (i + 1), val.linexp(0, 1, 0.15, 0.5)) };

		2.do{ |i| ~synths[\playbufs][id].set(\amp ++ (i), val.linlin(0, 1, 1, 0.7)) };
		2.do{ |i| ~synths[\playbufs][id].set(\amp ++ (i + 2), val.linexp(0, 1, 0.7, 1)) };
	} {

	}
}, '/tr');
)