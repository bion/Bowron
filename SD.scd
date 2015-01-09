~cymbal_amps = Object.readArchive("/Users/bion/Documents/sound projects/Current/W Jon/aggs/kernels/cymbal_amps_1");
~cymbal_freqs = Object.readArchive("/Users/bion/Documents/sound projects/Current/W Jon/aggs/kernels/cymbal_freqs_1");

~sd = CtkProtoNotes(

 /* ------------------------------------------------------------------------ sources  ------------------------------------------------------------------------ */

 SynthDef(\dandan, {
  |outBus, amp, pPos, pSpread, freq, envBuf, freqMul,
  env, dur, trigLFOfreq = 0.2, trigOverlap = 3.5,
  trigLFOrange = 20, trigLFOMul, gp = 0.12,
  vibeRate = 6.5, vibeWidth = 0.0125,
  harmLFOfreq = 0.5, harmLFOlo = -0.01,
  indexLFOfreq = 0.2, indexLFOlo = 0.5, indexLFOhi = 5|
  var grains, trig, pan, index, harmAmpLFOs, harmAmps,
   vib, rand, vibosc, vibwth, vibamp;

  vibamp = EnvGen.kr(Env([0.001, 1, 1, 0.001], [0.6, dur - 0.7, 0.1], \exp));
  vibwth = vibeWidth * vibamp;
  vibosc = SinOsc.kr(vibeRate + LFDNoise3.kr(2).range(0.9, 1.1), 0, vibwth);
  rand = LFNoise1.kr(1/6.5, vibwth);
  vib = vibosc + rand + 1;

  trig = Impulse.kr(
   (gp.reciprocal * trigOverlap) * (
    LFNoise2.kr(trigLFOfreq)
     .range(trigLFOrange / 2 * 0.01.neg, trigLFOrange / 2 * 0.01)
     * trigLFOMul + 1
    )
  );

  pan = (TRand.kr(-1, 1, trig) * pSpread) + pPos;

  index = LFNoise2.kr(indexLFOfreq).range(indexLFOlo, indexLFOhi);

  harmAmps = Control.names(\harmAmpArray).kr(7.collect { 0 });
  harmAmpLFOs = 7.collect { LFNoise2.kr(harmLFOfreq).range(harmLFOlo.dbamp, 1) };

  grains = GrainFM.ar(2, trig, gp,
   freq * vib * (1 .. 7) * freqMul,
   freq * vib * (1 .. 7) * freqMul, index,
   pan, envBuf, 128,
   harmAmps * harmAmpLFOs ).mean;

  grains = LeakDC.ar(grains);
  OffsetOut.ar(outBus, env * amp * grains);
 }),

 SynthDef(\fft_ana_read, {
  |anaFile, pointer, outBus, amp, env, originalPitch, pitch|
  var chain, out, pitchRatio=pitch/originalPitch;
  chain = PV_BufRd(LocalBuf(2**11), anaFile, pointer);
  chain = IFFT(chain);
  out = PitchShift.ar(chain, 0.1, pitchRatio, 0, 5.collect { Rand(0.0005, 0.01) }).mean;
  out = chain*env*amp ! 2;
  OffsetOut.ar( outBus, out );
 }),

 SynthDef(\cymbal_1, {|outBus, amp=1, dur|
  var lodriver, locutoffenv, hidriver, hicutoffenv, freqs, noise,
   res, thwack, out, loatt, hiatt, hidec, lfos, num_partials=100;
  RandID.ir(2);
  RandSeed.ir(1, 4531);
  noise = ClipNoise.ar(0.2);
  loatt = LinLin.kr(dur, 0.2, 6, 0.2, 1);
  hiatt = LinLin.kr(dur, 0.2, 6, 0.1, 2);
  locutoffenv = EnvGen.kr(Env.perc(loatt, dur - loatt)) * 20000;
  lodriver = DFM1.ar(noise, locutoffenv, 0, 1, 0.0, 0);
  hicutoffenv = 10001 - (EnvGen.kr(Env.perc(hiatt, dur * 0.66)) * 10000);
  hidriver = DFM1.ar(noise, hicutoffenv, 0, 1, 1.0, 0);
  hidriver = hidriver * EnvGen.kr(Env.perc(hiatt, dur * 0.7, 0.25));
  lfos = (num_partials/5).asInt.collect { LFNoise1.kr(rrand(1, 3)).range( 0.97, 1 ) };
  lfos = lfos ++ ((num_partials / 5 * 4).asInt.collect { rrand(0.9, 1) });
  lfos = lfos.scramble;
  res = Ringz.ar(hidriver+lodriver, ~cymbal_freqs*lfos, mul: ~cymbal_amps).mean;
  out = (res + (hidriver * 1) + (lodriver * 0.4));
  Out.ar( outBus, out * amp * 0.05 ! 2 );
 }),

 SynthDef(\play_mono, {
  |buf, amp, env=1, rate=1, startPos=0, outBus|
  OffsetOut.ar(outBus,
   PlayBuf.ar(1, buf, BufRateScale.ir(buf)*rate, startPos: startPos*BufSampleRate.ir(buf), loop: 1) )
 }),

 SynthDef(\play_mono_pitchshift, {
  |buf, pitch=1, amp=1, outBus|
  var play = PlayBuf.ar(1, buf, BufRateScale.ir(buf), loop: 1);
  play = Compander.ar(play, play, -8.dbamp, 1, 1/4, 0.002, 0.1);
  play = PitchShift.ar(play, 0.1, pitch, 0, 0.2);
  OffsetOut.ar(outBus, play*amp);
 }),

 SynthDef(\play_mono_to_stereo, {
  |buf, amp=1, env=1, rate=1, startPos=0, pan=0, outBus|
  OffsetOut.ar(outBus,
   Pan2.ar(
    PlayBuf.ar(1, buf, rate*BufRateScale.ir(buf), startPos: startPos*BufSampleRate.ir(buf) ),
    pan, amp*env));
 }),

 SynthDef(\play_mono_to_stereo_ps, {
  |buf, rate, amp, pan, env, pitch, outBus|
  OffsetOut.ar(outBus,
   Pan2.ar(
    PitchShift.ar(
     PlayBuf.ar(1, buf, rate*BufRateScale.ir(buf), loop: 0),
   0.2, pitch, 0, 0.04),
   pan, amp*env)
   );
 }),

 SynthDef(\gv, {
  |trigHi, trigLo, pSpread, pPos, env, mAmp, gAmpLo,
  buf, bufDur, outBus, envbuf, rateLo=0.1, rateHi=1|
  var grains, trig, grainDur, rate, pan, gAmp;

  trig = Duty.ar(Dwhite(trigLo, trigHi), 0, Dseq([-1, 1], inf));

  rate = TRand.ar(rateLo, rateHi, trig);
  pan = TRand.ar(-1, 1, trig) * pSpread + pPos;
  grainDur = rate.reciprocal * bufDur;
  gAmp = TRand.ar(gAmpLo, 1, trig);

  grains = GrainBuf.ar(2, trig, grainDur, buf, rate, 0, 4, pan, envbuf, 2**12, gAmp );

  OffsetOut.ar(outBus, grains * mAmp * env);
 }),

 SynthDef(\gv21, {
  |trigR, trigV, pSpread, pPos, env, mAmp, gAmpLo,
  outBus, envbuf, rateLo=0.1, rateHi=1|
  var grains, trig, grainDur, rate, pan, gAmp, trigLo, trigHi;

  trigLo = trigR.reciprocal; // trigR = hz, trigV = %spread
  trigV = trigV*0.005;
  trigHi = trigLo*(trigV+1);
  trigLo = trigLo*(trigV-1);
  trig = Duty.ar(Dwhite(trigLo, trigHi), 0, Dseq([-1, 1], inf));

  rate = TRand.ar(rateLo, rateHi, trig);
  pan = TRand.ar(-1, 1, trig) * pSpread + pPos;
  gAmp = TRand.ar(gAmpLo, 1, trig);

  grains = GrainBuf.ar(2, trig,
   Control.names([\grainDurs]).ir([1])*rate.reciprocal,
   Control.names([\seeds]).ir([1]),
   rate, 0, 4, pan, envbuf, 2**12, gAmp );

  OffsetOut.ar(outBus, grains * mAmp * env);
 }),

 SynthDef(\crossHiss, {
  |outBus, buf, env, amp, rq, freq, freq2|
  var play, fft1, fft2, filt, noise, out;
  var dampK, dryK, earlyK, timeK;
  play = PlayBuf.ar(1, buf, BufRateScale.ir(buf)*[0.2, 1, 2, 5], loop:1).mean;
  noise = HenonC.ar(44100/4, 1.34917, 0.281549);
  filt = BPF.ar(noise, freq*freq2, rq);
  fft1 = FFT(LocalBuf(2**12), play, 0.25, active: amp > -95.dbamp);
  fft1 = PV_MagSmear(fft1, 30);
  fft2 = FFT(LocalBuf(2**12), filt, 0.25, active: amp > -95.dbamp);
  fft1 = PV_Mul(fft1, fft2);
  out = IFFT(fft1)*env*amp;
  OffsetOut.ar(outBus, Splay.ar(out));
 }),

 SynthDef(\proccc, {
  |outBus, amp, buf, bufDur, grainDur, env, grainShape,
  pSpread, pPos, rateHi, rateLo, overlap|
  var chain, trig, dur, rate, position, pan,
   revK, dampK, c_env, r_env, rk_env, verb;

  position = LFSaw.kr(bufDur.reciprocal, 1).range(0, 1);
  trig = grainDur.reciprocal*LFNoise2.kr(20).range(0.7, 1.3)*overlap;
  trig = Impulse.ar(trig);
  pan = TRand.ar(-1, 1, trig) * pSpread+ pPos;
  rate = TRand.ar(rateLo, rateHi, trig);

  chain = GrainBuf.ar(2, trig, grainDur, buf, rate*BufRateScale.ir(buf),
   position, 4, pan, grainShape, 512, env*amp);

  OffsetOut.ar(outBus, chain);
 }),

 /* ------------------------------------------------------------------------ filters  ------------------------------------------------------------------------ */

 SynthDef(\route_m2s, {
  arg inBus, outBus, amp=1;
  Out.ar(outBus, In.ar(inBus, 1)*amp!2);
 }),

 SynthDef(\enh_int, {
  |inBus, outBus, fadeControl=1|
  var in, filt;
  in = In.ar(inBus, 1);
  filt = FFT(LocalBuf(2**12), in, 0.25);
  filt = PV_SpectralEnhance(filt, 2, 2, 0.7);
  filt = IFFT(filt);
  filt = Integrator.ar(filt, 0.8);
  filt = HPF.ar(filt, 200);
  filt = filt * (-18.dbamp);
  filt = XFade2.ar(in, filt, fadeControl);
  Out.ar(outBus, filt);
 }),

 SynthDef(\pv_morph, {
  |inBus1, inBus2, outBus, morphFactor|
  var in1=In.ar(inBus1, 2), in2=In.ar(inBus2, 2),
   chain10, chain11, chain20, chain21,
   out, morphOut;
  chain10 = FFT(LocalBuf(2**11), in1[0], 0.25,
   active:  (0 < morphFactor) * (morphFactor < 1));
  chain11 = FFT(LocalBuf(2**11), in1[1], 0.25,
   active:   (0 < morphFactor) * (morphFactor < 1));
  chain20 = FFT(LocalBuf(2**11), in2[0], 0.25,
   active:  (0 < morphFactor) * (morphFactor < 1));
  chain21 = FFT(LocalBuf(2**11), in2[1], 0.25,   active:   (0 < morphFactor) * (morphFactor < 1));

  chain10 = PV_Morph(chain10, chain20, morphFactor);
  chain11 = PV_Morph(chain11, chain21, morphFactor);

  morphOut = [IFFT.ar(chain10), IFFT.ar(chain11)];

  out = morphOut * (0 < morphFactor).lag3(0.1) * (morphFactor < 1).lag3(0.1);
  out = in1 * (morphFactor <=0).lag3(0.05) + out;
  out = in2 * (morphFactor >=1).lag3(0.05) + out;
  Out.ar(outBus, out );
 }),

 SynthDef(\verb_stretch, {
  |outBus, inBus, amp, env, roomsize, verbtime, spread|
  var chain = In.ar(inBus, 1);
  chain = GVerb.ar(chain, roomsize, verbtime, 0.5, 0.5, spread, 0, 0, 1)*10;
  chain = Compander.ar(chain, chain, 0.3, 1, 1/20, 0.002, 0.2);
  chain = LeakDC.ar(chain);
  Out.ar(outBus, chain*amp*env);
 }),

 SynthDef(\vowel, {
  |inBus, outBus, fade=1, ampScale=1|
  var in, out, filt = [nil, nil], freqs, widths, dBs;
  in = In.ar(inBus, 2);
  freqs = Control.names(\inFreqs).kr(5.collect {1} );
  widths = Control.names(\inWidths).kr(5.collect {1} );
  dBs = Control.names(\indBs).kr(5.collect {1} );
  2.do {|i|
   filt[i] = Resonz.ar(in[i], freqs, widths/freqs, dBs).sum;
   filt[i] = BPF.ar(in[i], freqs, widths/freqs, dBs).sum;
  };
  filt = XFade2.ar(filt, in, fade);
  OffsetOut.ar(outBus, filt);
 }),

 SynthDef(\verb_1, {
  |inBus, outBus, env, verbEnv=1, cleanEnv=1|
  var in, revK, dampK, reverb;
  in = In.ar(inBus, 2);

  revK = LinLin.kr(env, -1, 1, 2.4, 0.1);
  dampK = LinLin.kr(env, -1, 1, -22.dbamp, -2.dbamp);

  reverb = GVerb.ar(in.mean, roomsize: 200, revtime: revK, inputbw: dampK,
   spread: 90, damping: dampK, drylevel: 0, taillevel: -8.dbamp, earlyreflevel: -12.dbamp);

  OffsetOut.ar(outBus, (in * cleanEnv) + (reverb * verbEnv));
 }),

 SynthDef(\verb_2, {
  |inBus, outBus, env, verbEnv=1, cleanEnv=1|
  var in, revK, dampK, reverb;
  in = In.ar(inBus, 2);

  revK = LinLin.kr(env, -1, 1, 2.4, 0.1);
  dampK = LinLin.kr(env, -1, 1, -22.dbamp, -8.dbamp);

  reverb = GVerb.ar(in.mean, roomsize: 200, revtime: revK, inputbw: dampK,
   spread: 90, damping: dampK, drylevel: 0, taillevel: -80.dbamp, earlyreflevel: -12.dbamp);

  OffsetOut.ar(outBus, (in * cleanEnv) + (reverb * verbEnv));
 }),

 SynthDef(\dissolver, {
  arg inBuf, specBus, outBus, smear, map, env;
  var in, specIn, out, chains, specChain, water;
  chains = PlayBuf.ar(2, inBuf, BufRateScale.ir(inBuf), loop: 1);
  specChain = In.ar(specBus, 1);
  specChain = specChain + PinkNoise.ar(0.30);
  chains = chains.collect {arg chan; FFT(LocalBuf(2**11), chan, 0.25) };
  chains = chains.collect {arg chan; PV_MagSmear(chan, smear) };
  specChain = FFT(LocalBuf(2**11), specChain, 0.25);
  specChain = PV_MagSquared(specChain);
  chains = chains.collect {arg chan; PV_SpectralMap(chan, specChain, 0.05, 0, map, -1) };
  chains = chains.collect {arg chan; IFFT(chan)};
  out = chains;
  Out.ar(0, out*env);
 }),

 SynthDef(\dissonancer_stereo, {|inBus, outBus, diss|
  var in, out;
  in = In.ar(inBus, 2);
  out = Array.fill(6*4, {|i|
   var centerFreq = (36+(i*4)).midicps,
    modFreq = 2.27*(centerFreq**4.77);
    ((1.0-diss) + (diss*SinOsc.kr(modFreq*0.5,2pi.rand)))*BPF.ar(in, centerFreq, 0.29);
  }).sum;
  out = LeakDC.ar(out);
  out = Compander.ar(out, out, -4.dbamp, 1, 1/3, 0.002, 0.04);
  OffsetOut.ar(outBus, out );
 }),

 SynthDef(\reverb, {
  |inBus, dryOut, verbOut, verbK, dryL, verbL|
  var in=In.ar(inBus, 2), verb, out, dampK, revK;

  verbK = Line.kr(0, 0.01, 0.2);
  revK = LinLin.kr(verbK, -1, 1, 2.4, 0.1);
  dampK = LinExp.kr(verbK, -1, 1, -22.dbamp, -6.dbamp);

  verb = GVerb.ar(in, roomsize: 200, revtime: revK, inputbw: dampK,
    spread: 90, damping: dampK*2, drylevel: 0, taillevel: 0.dbamp,
    earlyreflevel: -20.dbamp);

  OffsetOut.ar(verbOut, verb.sum*verbL);
  OffsetOut.ar(dryOut, in*dryL);
 }),

 SynthDef(\reverb2, {
  |inBus, dryOut, verbOut, size, revtime, inputbw, tail, damp, earlyref, dryL, verbL|
  var in=In.ar(inBus, 2), verb, out;

  verb = GVerb.ar(in, size, revtime, inputbw,
    spread: 90, damping: damp, drylevel: 0, taillevel: tail,
    earlyreflevel: earlyref);

  OffsetOut.ar(verbOut, verb.sum*verbL);
  OffsetOut.ar(dryOut, in*dryL);
 }),

 SynthDef(\chorus, {
  |inBus, outBus, maxdelay=0.02|
  var in, chorus, out;
  in = In.ar(inBus, 1);
  chorus = Array.fill(8, {|i|
   DelayC.ar(in, maxdelay, LFNoise1.kr([0.1, 0.2412, 0.331, 0.46767].wrapAt(i),
    0.25*maxdelay, 0.75*maxdelay))
  });
  out = chorus + in;
  OffsetOut.ar(outBus, out.mean);
 }),

 SynthDef(\decorrelate, {
  |inBus, outBus, noiseBuf, delay=0|
  var in = In.ar(inBus, 1), out;

  out = Convolution2.ar(in, noiseBuf, framesize: 2**10);
  out = DelayC.ar(out, delay);
  out = Integrator.ar(out, 0.8);
  out = LeakDC.ar(out)*0.05;

  Out.ar( outBus, out );
 }),

 SynthDef(\reverb_mono_in, {
  |inBus, dryOut, verbOut, verbK, dryL, verbL, pan|
  var in=In.ar(inBus, 1), verb, out, dampK, revK;

  verbK = Line.kr(0, 0.01, 0.2);
  revK = LinLin.kr(verbK, -1, 1, 2.4, 0.1);
  dampK = LinExp.kr(verbK, -1, 1, -22.dbamp, -6.dbamp);

  verb = GVerb.ar(in, roomsize: 200, revtime: revK, inputbw: dampK,
    spread: 90, damping: dampK*2, drylevel: 0, taillevel: 0.dbamp,
    earlyreflevel: -20.dbamp);

  OffsetOut.ar(verbOut, verb*verbL);
  OffsetOut.ar(dryOut, Pan2.ar(in, pan, dryL));
 }),

 SynthDef(\conv, {
  |kernel, target, outBus, fade=0, amp=1|
  kernel = In.ar(kernel, 1);
  target = In.ar(target, 2);
  OffsetOut.ar(outBus,
   XFade2.ar(
    LeakDC.ar(Convolution.ar(target, kernel, 2**11)),
    target, fade)*amp
  );
 }),

 SynthDef(\cross, {
  |sigOne, sigTwo, outBus, amp=1|
  sigOne = In.ar(sigOne, 2);
  sigTwo = In.ar(sigTwo, 2);
  sigOne = FFT([LocalBuf(2**11), LocalBuf(2**11)], sigOne, 0.25);
  sigTwo = FFT([LocalBuf(2**11), LocalBuf(2**11)], sigTwo, 0.25);
  sigOne = PV_MagMul(sigOne, sigTwo);
  OffsetOut.ar(outBus, amp*IFFT(sigOne) );
 }),

 SynthDef(\leslie, {
  |inBus, outBus, speed, max, fade, amp=1|
  var in = In.ar(inBus, 2), rotate, outhorn, cabinet, out;
  rotate = SinOsc.kr(speed, [0, 0.5pi]).range(0, max);
  outhorn = DelayC.ar(in, 0.3, rotate).mean;
  [1, 1, 1, 1, 2, 2, 3, 4].do {|time|
   FbC({|fb|
    fb = -10.dbamp * fb;
    fb = LPF.ar(fb, 1200*time);
    fb = Resonz.ar(fb, 171.5*7.collect(_+1*Rand(0.95, 1.05)), 0.2);
    cabinet = outhorn + fb;
   }, 0.01, time * (330.reciprocal * 2));
  };
  out =XFade2.ar(LeakDC.ar(cabinet), in, fade);
  OffsetOut.ar(outBus, Spreader.ar(out*amp));
 }),

 SynthDef(\fft_compress, {
  |inBus, outBus, thresh, sAbove, sBelow|
  var chain = In.ar(inBus, 2);
  chain = FFT([LocalBuf(2**11), LocalBuf(2**11)], chain, 0.25);
  chain = PV_Compander(chain, thresh, sBelow, sAbove);
  OffsetOut.ar( outBus, IFFT(chain) );
 })
);

5.do {|i|
 ~sd.add(
  SynthDef(\gv2++(i+2), {
   |trigR, trigV, pSpread, pPos, env, mAmp, gAmpLo,
   outBus, envbuf, rateLo=0.1, rateHi=1|
   var grains, trig, grainDur, rate, pan, gAmp, trigLo, trigHi;

   trigLo = trigR.reciprocal; // trigR = hz, trigV = %spread
   trigV = trigV*0.005;
   trigHi = trigLo*(trigV+1);
   trigLo = trigLo*(trigV-1);
   trig = Duty.ar(Dwhite(trigLo, trigHi), 0, Dseq([-1, 1], inf));

   rate = TRand.ar(rateLo, rateHi, trig);
   pan = TRand.ar(-1, 1, trig) * pSpread + pPos;
   gAmp = TRand.ar(gAmpLo, 1, trig);

   grains = GrainBuf.ar(2, PulseDivider.ar(trig, i+2),
    Control.names([\grainDurs]).ir((1 .. (i+2)))*rate.reciprocal,
    Control.names([\seeds]).ir((1 .. (i+2))),
    rate, 0, 4, pan, envbuf, 2**12, gAmp ).sum;

   OffsetOut.ar(outBus, grains * mAmp * env);
  })
 )
};
"###########".postln;
"SD executed".postln;
"###########".postln;
