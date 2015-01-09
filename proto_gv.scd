
 SynthDef(\gv, {
  |trigHi, trigLo, pSpread, pPos, env, mAmp, gAmpLo, buf, bufDur,
  outbus, envbuf|
  var grains, trig, grainDur, rate, pan, gAmp;

  trig = Duty.kr(Dwhite(trigLo, trigHi), 0, Dseq([-1, 1], inf));

  rate = TRand.kr(0.1, 1, trig);
  pan = TRand.kr(-1, 1, trig) * pSpread + pPos;
  grainDur = rate.reciprocal * bufDur;
  gAmp = TRand.kr(gAmpLo, 1, trig);

  grains = GrainBuf.ar(2, trig, grainDur, buf, rate, 0, 4, pan, envbuf, 512, gAmp);

  OffsetOut.ar(outbus, grains * mAmp * env);
 })