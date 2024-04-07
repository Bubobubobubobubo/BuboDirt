/*

ORBIT BASED (GLOBAL)
CORE SYNTHDEFS FOR DIRT
(REQUIRED: GlobalDirtEffects)

	Global synth defs: these synths run in each DirtOrbit and are only released when it is stopped
	when you change them, to update them, hit cmd-period (i.e. stop the synths on the server) once.
	they'll come back automatically

*/



(
{
	var numChannels = ~dirt.numChannels;


	/*

	Routing and Analysis

	*/

	SynthDef("dirt_monitor" ++ numChannels, { |dryBus, effectBus, outBus, gate = 1, limitertype = 1|
		var drySignal = In.ar(dryBus, numChannels);
		var wetSignal = In.ar(effectBus, numChannels);
		//var signal = XFade2.ar(wetSignal, drySignal, dry * 2 - 1);
		var signal = wetSignal + drySignal;
		var post = if(SuperDirt.postBadValues) { 2 } { 0 };

		signal = Select.ar(CheckBadValues.ar(signal, post: post) > 0, [signal, DC.ar(0)]);

		signal = Select.ar(limitertype,
			[
				signal,
				Limiter.ar(signal),
				softclip(signal * 0.5) * 2
			]
		);

		DirtPause.ar(signal, graceTime:4);

		signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
		Out.ar(outBus, signal)
	}, [\ir, \ir, \kr, \kr, \kr]).add;


	// RMS measurement, sending back to editor
	SynthDef("dirt_rms" ++ numChannels, { |gate = 1, dryBus, effectBus, rmsReplyRate, rmsPeakLag, orbitIndex|
		var drySignal = In.ar(dryBus, numChannels);
		var wetSignal = In.ar(effectBus, numChannels);
		var signal = wetSignal + drySignal;

		DirtPause.ar(signal, graceTime:4);
		EnvGen.kr(Env.asr, gate, doneAction:2);

		SendPeakRMS.kr(signal, replyRate: rmsReplyRate, peakLag: rmsPeakLag, cmdName:"/rms", replyID: orbitIndex)

	}, [\kr, \ir, \ir, \kr, \kr, \kr]).add;



	/*

	Effect synths

	Each must have at least: dryBus, effectBus, gate

	dryBus and effectBus have \ir as rates (they shouldn't change at runtime)

	*/



	if(\SwitchDelay.asClass.notNil) {

		SynthDef("dirt_delay" ++ numChannels, { |dryBus, effectBus, gate = 1, delaytime, delayfeedback, delaySend = 1, delayAmp = 1, lock = 0, cps = 1|
			var signal;
			var input = In.ar(dryBus, numChannels);
			var maxDelayTime = 4;

			input = input * delaySend.lag(LFNoise1.kr(1).range(0.01, 0.02)); // regulate input

			delayfeedback = delayfeedback.max(0);
			delaytime = delaytime * if(lock, reciprocal(cps), 1);
			delaytime = delaytime.clip(0, maxDelayTime); // just to be sure
			// from sc3-plugins
			signal = \SwitchDelay.asClass.ar(input, 1, 1, delaytime, delayfeedback, maxDelayTime);

			signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
			signal = signal * delayAmp.lag(0.01);

			DirtPause.ar(signal, graceTime:4);

			Out.ar(effectBus, signal);

		}, [\ir, \ir]).add;
	} {
		"\n\n ---- SC3-Plugins not found. This is not a problem."
		"Note that we are using a comb delay, which may not sound the same as SwitchDelay from the plugins".postln;

		SynthDef("dirt_delay" ++ numChannels, { |dryBus, effectBus, gate = 1, delaytime, delayfeedback, delayAmp = 1, lock = 0, cps = 1|
			var signal = In.ar(dryBus, numChannels);
			var maxDelayTime = 4;
			var decayTime;

			delayfeedback = delayfeedback.clip(0, 0.99);
			delaytime = delaytime * if(lock, reciprocal(cps), 1);
			delaytime = delaytime.clip(0, maxDelayTime); // just to be sure
			decayTime = log2(-60.dbamp) / log2(delayfeedback) * delaytime;
			decayTime = decayTime.clip(0, 20);

			signal = CombL.ar(signal, maxDelayTime, delaytime.lag(1), decayTime);

			signal = LeakDC.ar(signal) * delayAmp.lag(0.01) * EnvGen.kr(Env.asr, gate, doneAction:2);

			DirtPause.ar(signal, graceTime:4);

			Out.ar(effectBus, signal);
		}, [\ir, \ir]).add;

	};

  SynthDef("dirt_reverb" ++ numChannels, { |dryBus, effectBus,
      stereo = 0.5, gate = 1, room = 0, size = 0.1, dry = 0,
      rmod = 0.2, rdepth = 0.3, low=200, lowr=0.5, high=400,
      highr=0.5|
      var in, wetSignal, drySignal, mixedSignal, env;
      in = In.ar(dryBus, numChannels);
      wetSignal = NHHall.ar(
          in,
          rt60: room.linlin(0, 1, 1, 10),
          stereo: stereo.clip(0, 1),
          lowFreq: low.clip(10, 20000),
          lowRatio: lowr,
          hiFreq: high.clip(10, 20000),
          hiRatio: highr,
          earlyDiffusion: size.linlin(0, 1, 0.5, 0.9),
          lateDiffusion: size.linlin(0, 1, 0.5, 0.9),
          modRate: rmod.clip(0.01, 0.99),
          modDepth: rdepth.clip(0.01, 0.99)
      );
      drySignal = in;
      mixedSignal = XFade2.ar(drySignal, wetSignal, dry * 2 - 1);
      env = EnvGen.kr(Env.asr, gate, doneAction: 2);
      mixedSignal = mixedSignal * env;
      Out.ar(effectBus, mixedSignal);
  }, [\ir, \ir]).add;

  SynthDef("dirt_miverb" ++ numChannels, { |dryBus, effectBus,
  miroom = 0.5, misize = 0.1, midry = 0.5, midamp = 0.5,
  mihp = 0.05, mifreeze = 0, midiff = 0.625|
      var in, wetSignal, drySignal, mixedSignal, env;
      in = In.ar(dryBus, numChannels);
      wetSignal = MiVerb.ar(
          inputArray: in,
          time: miroom.linlin(0, 1, 0.7, 1.25),
          drywet: midry.clip(0, 1),
          midamp: midamp.clip(0, 1),
          mihp: mihp.clip(0, 1),
          mifreeze: mifreeze.clip(0, 1),
          diff: midiff.clip(0, 1),
      );
      drySignal = in;
      mixedSignal = XFade2.ar(drySignal, wetSignal, midry * 2 - 1);
      env = EnvGen.kr(Env.asr, gate: 1, doneAction: 2);
      mixedSignal = mixedSignal * env;
      Out.ar(effectBus, mixedSignal);
  }).add;

	// "leslie" controls dry/wet
	// "lrate" is the modulation rate (typical vintage rates would be 6.7 for "fast", 0.7 for "slow")
	// "lsize" is the physical size of the cabinet in meters, this mostly affects the Doppler amount (pitch warble)
	SynthDef("dirt_leslie" ++ numChannels, { |dryBus, effectBus, gate = 1, leslie=0.5, lrate=6.7, lsize=0.3|
		var in, distance, throb, sound1, sound2, bal1, bal2, snd;

		in = In.ar(dryBus, numChannels);
		ReplaceOut.ar(dryBus, in * (1 - leslie));

		in = if(numChannels > 2) { in.clump(2).sum } { in.dup };
		distance = SinOsc.ar(Lag.kr(lrate,10), 0).range(0, lsize);
		throb = SinOsc.ar(Lag.kr(lrate*0.8, 20), 0).range(0,lsize*1.3);
		bal1 = SinOsc.kr(Lag.kr(lrate*0.8, 4), pi/2).range(-0.2,0.2);
		bal2 = SinOsc.kr(Lag.kr(lrate,2), pi/2).range(-0.4, 0.4);
		sound2 = HPF.ar(in, 800);
		sound1 = in - sound2;
		sound1 = leslie * (1.0 - throb) * sound1;
		sound1 = Balance2.ar(sound1[0], sound1[1], bal1);
		sound2 = DelayC.ar(sound2, 1, distance / 343);
		sound2 = leslie * (1.0 - distance) * sound2;
		sound2 = Balance2.ar(sound2[0], sound2[1], bal2);

		snd = 1.2 * (sound1 + sound2);

		DirtPause.ar(snd, graceTime:4);
		snd = snd * EnvGen.kr(Env.asr, gate, doneAction:2);

		case(
			{ numChannels == 1 }, { snd = snd.sum },
			{ numChannels > 2 }, {
				snd = [
					// wild interpretation
					PanAz.ar(numChannels, snd[0], LFSaw.kr(lrate)),
					PanAz.ar(numChannels, snd[1], LFSaw.kr(lrate) + 1)
				].sum
			}
		);


		Out.ar(effectBus, snd);

	}, [\ir, \ir]).add;

	"---- core synth defs loaded ----".postln;

}.value
);
