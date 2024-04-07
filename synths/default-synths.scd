(
  SynthDef(\braids, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0,timbre=0.5,color=0.5,model=0|
    var envLength = sustain*(end-begin)/speed;
    var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
    var env = Env.asr;
    var volume = IEnvGen.ar(env, line);
    var sig;

    freq = max(0, freq * speed * (1 + (accelerate * line)));
    sig = MiBraids.ar(pitch: freq.cpsmidi, timbre: timbre, color: color, model: model);

    Out.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
  }).add;
);

(
  SynthDef(\omi, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0|
    var envLength = sustain*(end-begin)/speed;
    var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
    var env = Env.asr;
    var volume = IEnvGen.ar(env, line);
    var sig;

    freq = max(0, freq * speed * (1 + (accelerate * line)));
    sig = MiOmi.ar(pit: freq.cpsmidi);

    Out.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
  }).add;
);

(
  SynthDef(\plaits, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0,
      timbre=0.5,engine=0,harm=0.5,morph=0.5,level=1,lpgdecay=0,lpgcolour=0,mode=0|
    var envLength = sustain*(end-begin)/speed;
    var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
    var env = Env.asr;
    var volume = IEnvGen.ar(env, line);
    var sig;

    freq = max(0, freq * speed * (1 + (accelerate * line)));
    sig = MiPlaits.ar(
      pitch: freq.cpsmidi,
      timbre: timbre,
      harm: harm,
      engine: engine,
      morph: morph,
      level: level,
      decay: lpgdecay,
      lpg_colour: lpgcolour,
    );
    sig = Select.ar(mode, sig);
    Out.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
  }).add;
);

(
  SynthDef(\tides, {|out=0,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0,tidesshape=0.5,slope=0.5,tidessmooth=0.5,shift=0.5,mode=2|
    var envLength = sustain*(end-begin)/speed;
    var line = Line.ar(begin, end, envLength, doneAction: Done.freeSelf);
    var env = Env.asr;
    var volume = IEnvGen.ar(env, line);
    var sig;

    freq = max(0, freq * speed * (1 + (accelerate * line)));
    sig = MiTides.ar(
      freq: freq,
      shape: tidesshape,
      slope: slope,
      smooth: tidessmooth,
      shift: shift,
      output_mode: mode,
      ramp_mode: 1,
      rate: 1
    );

    Out.ar(out, DirtPan.ar(sig * volume, ~dirt.numChannels, pan));
  }).add;
);

(
~dirt.addModule('elements', { |dirtEvent|
	dirtEvent.sendSynth('elements' ++ ~dirt.numChannels,
		[
      elementspitch: ~elementspitch,
      elementsstrength: ~elementsstrength,
      elementscontour: ~elementscontour,
      elementsbowlevel: ~elementsbowlevel,
      elementsblowlevel: ~elementsblowlevel,
      elementsstrikelevel: ~elementsstrikelevel,
      elementsflow: ~elementsflow,
      elementsmallet: ~elementsmallet,
      elementsbowtimb: ~elementsbowtimb,
      elementsblowtimb: ~elementsblowtimb,
      elementsstriketimb: ~elementsstriketimb,
      elementsgeom: ~elementsgeom,
      elementsbright: ~elementsbright,
      elementsdamp: ~elementsdamp,
      elementspos: ~elementspos,
      elementsspace: ~elementsspace,
      elementsmodel: ~elementsmodel,
      elementseasteregg: ~elementseasteregg,
			out: ~out
		]
	)
}, {~elementsstrength.notNil});
);

(
  SynthDef("elements" ++ ~dirt.numChannels, {|out,freq=440,sustain=1,pan=0,begin=0,end=1,speed=1,accelerate=0,
      elementspitch=48, elementsstrength=0.5, elementscontour=0.2, elementsbowlevel=0,elementsblowlevel=0, elementsstrikelevel=0,
      elementsflow=0.5, elementsmallet=0.5, elementsbowtimb=0.5, elementsblowtimb=0.5,
      elementsstriketimb=0.5, elementsgeom=0.25, elementsbright=0.5, elementsdamp=0.7, elementspos=0.2, elementsspace=0.3, elementsmodel=0,
      elementseasteregg=0|
    var signal = In.ar(out, ~dirt.numChannels);
    ReplaceOut.ar(out, MiElements.ar(
      blow_in: signal,
      strike_in: signal,
      gate: 1,
      pit: elementspitch,
      strength: elementsstrength,
      contour: elementscontour,
      bow_level: elementsbowlevel,
      blow_level: elementsblowlevel,
      strike_level: elementsstrikelevel,
      flow: elementsflow,
      mallet: elementsmallet,
      bow_timb: elementsbowtimb,
      blow_timb: elementsblowtimb,
      strike_timb: elementsstriketimb,
      geom: elementsgeom,
      bright: elementsbright,
      damp: elementsdamp,
      pos: elementspos,
      space: elementsspace,
      model: elementsmodel,
      easteregg: elementseasteregg
    ));
  }).add;
);

(
~dirt.addModule('rings', { |dirtEvent|
	dirtEvent.sendSynth('rings' ++ ~dirt.numChannels,
		[
			ringstrig: ~ringstrig,
			ringsfreq: ~ringsfreq,
			ringsstruct: ~ringsstruct,
			ringsbright: ~ringsbright,
			ringsdamp: ~ringsdamp,
			ringspos: ~ringspos,
			ringsmodel: ~ringsmodel,
			ringspoly: ~ringspoly,
			ringsinternal: ~ringsinternal,
			ringseasteregg: ~ringseasteregg,
			out: ~out
		]
	)
}, {~ringsbright.notNil});
);

(
SynthDef("rings" ++ ~dirt.numChannels, { |out, ringsfreq=440,ringsstruct=0,ringsbright=0,ringsdamp=0.5,ringspos=0,ringsmodel=0,ringspoly=0,ringsinternal=0,ringseasteregg=0,ringsbypass=0|
	var signal = In.ar(out, ~dirt.numChannels);
	signal = MiRings.ar(
    signal,
    trig: ringsinternal,
    pit: ringsfreq.cpsmidi,
    struct: ringsstruct,
    bright: ringsbright,
    damp: ringsdamp,
    pos: ringspos,
    model: ringsmodel,
    poly: ringspoly,
    intern_exciter: ringsinternal,
    easteregg: ringseasteregg
  );
  ReplaceOut.ar(out, signal)
}).add;

(
SynthDef(\imp, { |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
	var env, sound, rate, phase;
	env = EnvGen.ar(Env.perc(0.01, 0.99, 1, -1), timeScale:sustain, doneAction:2);
	phase = Line.kr(begin, end, sustain);
	rate = (begin + 1) * (speed + Sweep.kr(1, accelerate));
	sound = Blip.ar(rate.linexp(0, 1, 1, freq) * [1, 1.25, 1.51, 1.42], ExpRand(80, 118) * phase).sum;
	Out.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, env)
	)
}).add
);

(
SynthDef(\psin, { |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset, modfreq = 40|
	var env, sound, rate, phase, amp;
	amp = AmpCompA.kr(freq);
	env = EnvGen.ar(Env.perc(0.002, sustain, 1, -1), doneAction:2);
	phase = Line.ar(begin, end, sustain);
	rate = speed + Sweep.kr(1, accelerate);
	sound = SinOsc.ar(freq, SinOsc.ar(modfreq * (1..5), 0, 1 - phase * 10 * env / (1..5), 0.5pi)).sum;
	Out.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, env)
	)
}).add
);

(
SynthDef(\pmsin, { |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
	var env, sound, rate, phase, modfreq, amp;
	freq = (MouseX.kr(30, 80).round + freq);
	modfreq = MouseY.kr(1, 200, 1);
	amp = AmpCompA.kr(freq);
	env = EnvGen.ar(Env.perc(0.002, sustain, 1, -1), doneAction:2);
	phase = Line.ar(begin, end, sustain);
	rate = speed + Sweep.kr(1, accelerate);
	sound = SinOsc.ar(freq, SinOsc.ar(modfreq * (1..5), 0, 1 - phase * 10 * env / (1..5), 0.5pi)).sum;
	Out.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan, env)
	)
}).add
);

// live audio input
(
SynthDef(\in, { |out, soundin = 0, sustain = 1, pan, inputFadeTime = 0.03|
	var env, sound;
	env = Env.linen(inputFadeTime, sustain - (2 * inputFadeTime), inputFadeTime).kr;
	sound = SoundIn.ar([0, 1] + soundin); // stereo in
	sound = sound * env;
	Out.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan)
	)
}).add
);

(
SynthDef(\in1, { |out, soundin = 0, sustain = 1, pan, inputFadeTime = 0.03|
	var env, sound;
	env = Env.linen(inputFadeTime, sustain - (2 * inputFadeTime), inputFadeTime).kr;
	sound = SoundIn.ar(soundin); // mono in
	sound = sound * env;
	Out.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan)
	)
}).add
);

(
SynthDef(\dirt_from, { |out, sustain = 1, in, pan, inputFadeTime = 0.03|
	var env, sound;
	env = Env.linen(inputFadeTime, sustain - (2 * inputFadeTime), inputFadeTime).kr;
	sound = InFeedback.ar(in, ~dirt.numChannels);
	sound = sound * env;
	Out.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan)
	)
}).add;

~dirt.soundLibrary.addSynth(\from,
	(
		instrument: \dirt_from,
		in: {
			~dirt.audioRoutingBusses.wrapAt(~from ? 0).index
		}
	)
)
);

(
SynthDef(\inr, { |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset, inputFadeTime = 0.03|
	var env, sound, rate, phase;
	env = Env.linen(inputFadeTime, sustain - (2 * inputFadeTime), inputFadeTime).kr;
	phase = Line.ar(begin, end, sustain);
	rate = (begin + 1) * (speed + Sweep.kr(1, accelerate)) * freq / 440;
	sound = SoundIn.ar([0, 1]); // stereo in
	sound = sound * env;
	sound = PitchShift.ar(sound, 0.1, rate, 0.02, 0.01);
	Out.ar(out,
		DirtPan.ar(sound, ~dirt.numChannels, pan)
	)
}).add
);

(
SynthDef(\debug, { |begin = -1, end = -1, delta = -1, sustain = -1, unitDuration = -1, cycle = -1, speed = 1, accelerate = 0|
	var trig = Impulse.kr(0);
	cycle.poll(trig, label: "cycle");
	begin.poll(trig, label: "begin");
	end.poll(trig, label: "end");
	delta.poll(trig, label: "delta");
	sustain.poll(trig, label: "sustain");
	unitDuration.poll(trig, label: "unitDuration");
	speed.poll(trig, label: "speed");
	accelerate.poll(trig, label: "accelerate");
	DC.kr(0).poll(trig, label: "\n\n");
}).add
);

(
~dirt.soundLibrary.addSynth(\superpanic, (play: { ~dirt.orbits.do(_.freeSynths) }))
);

)
