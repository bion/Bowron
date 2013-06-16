
s.boot;
z = Buffer.read(s, "/Users/bion/Documents/sound projects/Current/W Jon/Water/water_medium_intensity.aiff");
x = Buffer.read(s, "/Users/bion/Documents/sound projects/Current/W Jon/aggs/horns/horns_n_drums.aif");

(
x = SynthDef(\specMap, {arg sndBuf, freeze = 0;
	var a, b, chain1, chain2, out;
	a = LocalBuf.new(2048);
	b = LocalBuf.new(2048);
	chain1 = FFT(a, PlayBuf.ar(2, x, BufRateScale.ir(x)).mean); // to be filtered
	chain2 = FFT(b, PlayBuf.ar(1, z, 1, loop: 1));
	// mouse x to play with floor.
	chain1 = PV_SpectralMap(chain1, chain2, 0.0, freeze, MouseX.kr(-1, 1), -1);
	out = IFFT(chain1);
	Out.ar(0, out.dup*0.05);
}).play(s, [\sndBuf, z, \freeze, 0])
)

(
c = SynthDef(\tester, {
	arg inBus, specBus, outBus, smear, map, env;
	var in, specIn, out, chains, specChain, water;
	chains = PlayBuf.ar(2, inBuf, BufRateScale.ir(inBus), loop: 1);
	specChain = In.ar(specBus, 1);
	specChain = specChain + PinkNoise.ar(0.30);
	chains = chains.collect {arg chan; FFT(LocalBuf(2**11), chan, 0.25) };
	chains = chains.collect {arg chan; PV_MagSmear(chan, smear) };
	specChain = FFT(LocalBuf(2**11), specChain, 0.25);
	specChain = PV_MagSquared(specChain);
	chains = chains.collect {arg chan; PV_SpectralMap(chan, specChain, 0.05, freeze, map, -1) };
	chains = chains.collect {arg chan; IFFT(chan)};
	out = chains;
	Out.ar(0, out*env);
})
)


x.set(\freeze, 1)
x.set(\freeze, 0);

x.free;

z.free;