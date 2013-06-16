~sm = IdentityDictionary[

	/* ------------------------------------ sources  ------------------------------------ */

	\buf_read_pitch_shift -> {|dict, score, start_dur|
		~sd[\play_mono_to_stereo_ps].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.outBus_(dict[\outbus]).amp_(dict[\amp]).env_(dict[\env])
			.buf_(~buf_read_pitch_shift_bufs[dict[\buf]])
			.pitch_(dict[\pitch]).pan_(dict[\pan]).rate_(dict[\rate])
		.addTo(score);
	},

	\fft_read -> {|dict, score, start_dur|
		var	scpv_buf = ~scpv_buf_func.(dict[\scpv_path], score);
		~sd[\fft_ana_read].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.amp_(dict[\amp]).outBus_(dict[\outbus]).env_(dict[\env])
			.anaFile_(scpv_buf).pointer_(dict[\pointer])
			.originalPitch_(dict[\o_pitch]).pitch_(dict[\pitch])
		.addTo(score);
	},

	\cymbal_1 -> {|dict, score, start_dur|
		~sd[\cymbal_1].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.amp_(dict[\amp]).outBus_(dict[\outbus]).dur_(dict[\dur])
		.addTo(score);
	},

	\play_mono -> {|dict, score, start_dur|
		~sd[\play_mono].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.amp_(dict[\amp]).outBus_(dict[\outbus]).env_(dict[\env])
			.buf_(~mono_bufs[dict[\buf]]).rate_(dict[\rate])
		.addTo(score);
	},

	\play_horn -> {|dict, score, start_dur|
		var buf = CtkBuffer(~base_dir++"/horns/"++dict[\horn]++".aif").addTo(score);

		~sd[\play_mono].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.amp_(dict[\amp]).outBus_(dict[\outbus]).env_(dict[\env])
			.buf_(buf).startPos_(start_dur[0]+4.12)
		.addTo(score);
	},

	\dandan -> {|dict, score, start_dur|
		var inFreqs = dict[\freqs], freqs, outAmp;

	case
		{inFreqs[0].isMemberOf(PC)} {
			freqs = flatten(dict[\freq_muls].collect {|mul|
				(inFreqs.collect {|pitchClass| pitchClass.freq}) * mul
			});
		}
		{inFreqs[0].isMemberOf(List)} {
			freqs = flatten(dict[\freq_muls].collect {|mul|
				inFreqs.collect {|env_info|
					~env.(env_info, start_dur, mul);
				}
			});
		}
		{inFreqs[0].isNumber} {
			freqs = flatten(dict[\freq_muls].collect {|mul|
				inFreqs.collect {|freq| freq * mul }
			});
		};

		outAmp = (dict[\amp] / (freqs.size * 1.5));

		freqs.do {|freq, i|
			var	freq_mul = dict[\freq_muls_2][i] ? 1,
				grain_shape = ~grain_shapes[dict[\grain_shape]] ? -1;
			if(freq_mul.isMemberOf(List), {freq_mul = ~env.(freq_mul, start_dur)});
			~sd[\dandan].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
				.outBus_(dict[\outbus]).amp_(outAmp).freq_(freq).env_(dict[\env]).freqMul_(freq_mul)
				.pPos_(dict[\p_pos]).pSpread_(dict[\p_spread]).envBuf_(grain_shape)
				.dur_(start_dur[1]).trigLFOfreq_(dict[\trigLFOfreq]).trigLFOMul_(dict[\trigLFOMul])
				.trigOverlap_(dict[\trig_overlap]).gp_(dict[\gp]).trigLFOrange_(dict[\trigLFOrange])
				.vibeRate_(dict[\vibe_rate]).vibeWidth_(dict[\vibe_width])
				.harmLFOfreq_(dict[\harmLFOfreq]).harmLFOlo_(dict[\harmLFOlo])
				.indexLFOfreq_(dict[\i_freq]).indexLFOlo_(dict[\i_lo]).indexLFOhi_(dict[\i_hi])
				.harmAmpArray_(dict[\harm_amps])
			.addTo(score)
		};
	},

	\cross_hiss -> {|dict, score, start_dur|
		~sd[\crossHiss].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.outBus_(dict[\outbus]).buf_(~cross_hiss_bufs[dict[\buf]])
			.env_(dict[\env]).amp_(dict[\amp]).rq_(dict[\rq])
			.freq_(dict[\freq]).freq2_(dict[\freq2])
		.addTo(score);
	},

	\verb_stretch -> {|dict, score, start_dur|
		~sd[\verb_stretch].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.inBus_(dict[\inbus])
			.outBus_(dict[\outbus]).amp_(dict[\amp])
			.env_(dict[\env]).roomsize_(dict[\roomsize])
			.verbtime_(dict[\verbtime]).spread_(dict[\spread])
		.addTo(score);
	},

	\proccc -> {|dict, score, start_dur|
		~sd[\proccc].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.amp_(dict[\amp]).outBus_(dict[\outbus]).env_(dict[\env])
			.buf_(~proccc_seed_bufs[dict[\seed_buf]])
			.bufDur_(~proccc_seed_bufs[dict[\seed_buf]].duration)
			.grainShape_(~grain_shapes[dict[\grain_shape]] ? -1)
			.pPos_(dict[\p_pos]).pSpread_(dict[\p_spread])
			.rateHi_(dict[\rate_hi]).rateLo_(dict[\rate_lo]).grainDur_(dict[\grain_dur])
			.overlap_(dict[\overlap])
		.addTo(score);
	},

	\gv -> {|dict, score, start_dur|
		var	source_group = CtkGroup(target: ~groups[\five], addAction: \addToHead, server: s).addTo(score),
			verb_group_one = CtkGroup(target: source_group, addAction: \after, server: s).addTo(score),
			conv_group = CtkGroup(target: verb_group_one, addAction: \after, server: s).addTo(score),
			verb_group_two = CtkGroup(target: conv_group, addAction: \after, server: s).addTo(score),
			diss_group = CtkGroup(target: verb_group_two, addAction: \after, server: s).addTo(score);
		var	density_tend, seed, envbuf,
			grit_start=start_dur[0], dur=start_dur[1];
		var	kernel_bus = CtkAudio(1, server: s), grit_out_bus = CtkAudio(2, server: s),
			verb_one_bus = CtkAudio(2, server: s), verb_two_bus = CtkAudio(2, server: s),
			conv_out_bus = CtkAudio(2, server: s);

		envbuf = dict[\envbuf];
		if( envbuf.isMemberOf(Symbol), { envbuf=~grain_shapes[envbuf] } );

		~sd[\play_mono_pitchshift].note(start_dur[0], start_dur[1], target: source_group, server: s)
			.buf_(~gv_bufs[dict[\conv_buf]]).pitch_(dict[\k_pitch]).amp_(dict[\kernel_amp]).outBus_(kernel_bus)
		.addTo(score);

		seed = ~gv_bufs[dict[\seed]];
		seed ? { seed=~gv_bufs[\grit] }.();

		~sd[\gv].note(grit_start, start_dur[1], target: source_group, server: s)
			.env_(dict[\e_env]).mAmp_(dict[\e_amp]).outBus_(grit_out_bus)
			.gAmpLo_(dict[\g_amp_low]).buf_(seed).bufDur_(seed.duration)
			.trigHi_(dict[\dt_hi]).trigLo_(dict[\dt_lo]).envbuf_(envbuf)
			.rateLo_(dict[\rate_lo]).rateHi_(dict[\rate_hi])
			.pSpread_(dict[\p_spread_env]).pPos_(dict[\p_pos_env])
		.addTo(score);

		~sd[\verb_1].note(grit_start, start_dur[1], target: verb_group_one, server: s)
			.inBus_(grit_out_bus).outBus_(verb_one_bus)
			.env_(dict[\v_one_k]).verbEnv_(dict[\v_one_verbL])
			.cleanEnv_(dict[\v_one_dryL])
		.addTo(score);

		~sd[\conv].note(grit_start, start_dur[1], target: conv_group, server: s)
			.kernel_(kernel_bus).target_(verb_one_bus)
			.fade_(dict[\conv_fade])
			.outBus_(conv_out_bus)
		.addTo(score);

		~sd[\verb_2].note(grit_start, start_dur[1]+3, target: verb_group_two, server: s)
			.inBus_(conv_out_bus).outBus_(verb_two_bus)
			.env_(dict[\v_two_k]).verbEnv_(dict[\v_one_verbL])
			.cleanEnv_(dict[\v_two_dryL])
		.addTo(score);

		~sd[\dissonancer_stereo].note(grit_start, start_dur[1]+3, target: diss_group, server: s)
			.inBus_(verb_two_bus).outBus_(dict[\outbus]).diss_(dict[\diss])
		.addTo(score);
	},

	\gs -> {|dict, score, start_dur|
		var seed, envbuf;
		seed = ~gs_bufs[dict[\seed]];
		envbuf = dict[\envbuf];
		if( envbuf.isMemberOf(Symbol), { envbuf=~grain_shapes[envbuf] } );
		~sd[\gv].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.env_(dict[\env]).mAmp_(dict[\amp]).outBus_(dict[\outbus])
			.gAmpLo_(dict[\g_amp_low]).buf_(seed).bufDur_(seed.duration)
			.trigHi_(dict[\dt_hi]).trigLo_(dict[\dt_lo]).envbuf_(envbuf)
			.rateLo_(dict[\rate_lo]).rateHi_(dict[\rate_hi])
			.pSpread_(dict[\p_spread]).pPos_(dict[\p_pos])
		.addTo(score);
	},

	\gv2 -> {|dict, score, start_dur|
		var seeds, envbuf, bufs, durs;
		seeds = dict[\seeds].collect {|name| ~gs_bufs[name] };
		durs = seeds.collect {|buf| buf.duration };
		envbuf = dict[\envbuf];
		if( envbuf.isMemberOf(Symbol), { envbuf=~grain_shapes[envbuf] } );
		~sd[\gv2++seeds.size].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.env_(dict[\env]).mAmp_(dict[\amp]).outBus_(dict[\outbus])
			.gAmpLo_(dict[\g_amp_low]).seeds_(seeds).grainDurs_(durs)
			.trigR_(dict[\g_r]).trigV_(dict[\g_v]).envbuf_(envbuf)
			.rateLo_(dict[\rate_lo]).rateHi_(dict[\rate_hi])
			.pSpread_(dict[\p_spread]).pPos_(dict[\p_pos])
		.addTo(score);
	},

	\perc -> {|dict, score, start_dur|
		var	env, starts, bufs, main_amp = dict[\amp], main_pan;

		if(dict[\env].notNil, {env = ~perc_env.(dict[\env])});
		if(dict[\pan].isMemberOf(Array), {main_pan = ~perc_env.(dict[\env])});

		case
		{ dict[\buf].isNil } {
			bufs = dict[\starts].collect {|start| start.pop };
			bufs = bufs.collect {|key| ~perc_bufs[key] };
			starts = dict[\starts].collect {|start| ~c_start.(start) };
			[starts, bufs].flop.do {|array|
				var	amp = main_amp, pan = main_pan, start=array[0], buf=array[1];
				env !? { amp = env.at(start) * amp };
				if(pan.isMemberOf(Env), {pan = main_pan.at(start)});
				~sd[\play_mono_to_stereo].note(start, buf.duration, target: ~groups[dict[\group]], server: s)
					.outBus_(dict[\outbus]).pan_(pan).rate_(1).amp_(amp).buf_(buf)
				.addTo(score) }
		}
		{ dict[\buf].notNil } {
			var	buf = ~perc_bufs[dict[\buf]];
			starts = dict[\starts].collect {|start| ~c_start.(start)};
			starts.do {|start|
				var	amp = main_amp, pan = main_pan;
				env !? { amp = env.at(start) * amp };
				if(pan.isMemberOf(Env), {pan = main_pan.at(start)});
				~sd[\play_mono_to_stereo].note(start, buf.duration, target: ~groups[dict[\group]], server: s)
					.outBus_(dict[\outbus]).pan_(pan).rate_(1).amp_(amp).buf_(buf)
				.addTo(score) }
		}
	},

	/* ------------------------------------ filters  ------------------------------------ */

	\route_m2s -> {|dict, score, start_dur|
		~sd[\route_m2s].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
		.inBus_(dict[\inbus]).outBus_(dict[\outbus]).amp_(dict[\amp])
		.addTo(score)
	},

	\enh_int -> {|dict, score, start_dur|
		~sd[\enh_int].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.inBus_(dict[\inbus]).outBus_(dict[\outbus])
			.fadeControl_(dict[\fade])
		.addTo(score)
	},

	\pv_morph -> {|dict, score, start_dur|
		~sd[\pv_morph].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.inBus1_(dict[\inbus1]).inBus2_(dict[\inbus2]).outBus_(dict[\outbus])
			.morphFactor_(dict[\morph_factor])
		.addTo(score)
	},

	\vowel -> {|dict, score, start_dur|
		dict[\vowels].do {|vowel|
			~sd[\vowel].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
				.inBus_(dict[\inbus]).outBus_(dict[\outbus])
				.inFreqs_(vowel.freqs).inWidths_(vowel.widths).indBs_(vowel.dBs.dbamp)
				.fade_(dict[\fade]).ampScale_(dict[\vowels].size.reciprocal*1.5)
			.addTo(score);
		};
	},

	\conv -> {|dict, score, start_dur|
		~sd[\conv].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.kernel_(dict[\kernel]).target_(dict[\target])
			.fade_(dict[\conv_fade])
			.outBus_(dict[\outbus])
		.addTo(score);
	},

	\diss -> {|dict, score, start_dur|
		~sd[\dissonancer_stereo].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.inBus_(dict[\inbus]).outBus_(dict[\outbus]).diss_(dict[\diss])
		.addTo(score);
	},

	\reverb -> {|dict, score, start_dur|
		~sd[\reverb].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.dryOut_(dict[\dry_out]).verbOut_(dict[\verb_out]).inBus_(dict[\inbus])
			.verbK_(dict[\verbK]).verbL_(dict[\verbL])
			.dryL_(dict[\dryL])
		.addTo(score);
	},

	\reverb2 -> {|dict, score, start_dur|
		~sd[\reverb2].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.dryOut_(dict[\dry_out]).verbOut_(dict[\verb_out]).inBus_(dict[\inbus])
			.verbL_(dict[\verbL]).dryL_(dict[\dryL])
			.size_(dict[\size]).revtime_(dict[\revtime]).inputbw_(dict[\inputbw])
			.damp_(dict[\damp]).earlyref_(dict[\earlyref]).tail_(dict[\tail])
		.addTo(score);
	},

	\dissolver -> {|dict, score, start_dur|
		~sd[\dissolver].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
		.inBuf_(~dissolver_bufs[dict[\inbuf]]).outBus_(dict[\outbus]).specBus_(dict[\kernel_bus])
		.env_(dict[\env]).smear_(dict[\smear]).map_(dict[\map])
		.addTo(score)
	},

	\chorus -> {|dict, score, start_dur|
		~sd[\chorus].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.inBus_(dict[\inbus]).outBus_(dict[\outbus]).maxdelay_(dict[\maxdelay])
		.addTo(score);
	},

	\decorrelate -> {|dict, score, start_dur|
		~sd[\decorrelate].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.inBus_(dict[\inbus]).outBus_(dict[\outbus]).noiseBuf_(~dc_bufs[dict[\noise_buf]])
			.delay_(dict[\delay])
		.addTo(score);
	},

	\reverb_mono_in -> {|dict, score, start_dur|
		~sd[\reverb_mono_in].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.dryOut_(dict[\dry_out]).verbOut_(dict[\verb_out]).inBus_(dict[\inbus])
			.verbK_(dict[\verbK]).verbL_(dict[\verbL])
			.dryL_(dict[\dryL]).pan_(dict[\pan])
		.addTo(score);
	},

	\leslie -> {|dict, score, start_dur|
		~sd[\leslie].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.outBus_(dict[\outbus]).inBus_(dict[\inbus]).amp_(dict[\amp])
			.speed_(dict[\speed]).max_(dict[\max]).fade_(dict[\fade])
		.addTo(score);
	},

	\cross -> {|dict, score, start_dur|
		~sd[\cross].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.outBus_(dict[\outbus]).amp_(dict[\amp])
			.sigOne_(dict[\sig_one_bus]).sigTwo_(dict[\sig_two_bus])
		.addTo(score);
	},

	\fft_comp -> {|dict, score, start_dur|
		~sd[\fft_compress].note(start_dur[0], start_dur[1], target: ~groups[dict[\group]], server: s)
			.outBus_(dict[\outbus]).inBus_(dict[\inbus])
			.thresh_(dict[\thresh]).sAbove_(dict[\s_above]).sBelow_(dict[\s_below])
		.addTo(score);
	}

];

/* ------------------------------------------- buffer management ------------------------------------------- */

~perc_dir = ~base_dir++"/perc_samps/";
~ps = IdentityDictionary[

	\play_mono -> {|score|
		var	path = ~base_dir++"/kernels/";
		~mono_bufs = IdentityDictionary[
			\h_0 -> CtkBuffer(~perc_dir++"h_0.aiff").addTo(score),
			\h_0r -> CtkBuffer(~perc_dir++"h_0r.aiff").addTo(score),
			\h_1 -> CtkBuffer(~perc_dir++"h_1.aiff").addTo(score),
			\h_2 -> CtkBuffer(~perc_dir++"h_2.aiff").addTo(score),
			\h_3 -> CtkBuffer(~perc_dir++"h_3.aiff").addTo(score),
			\h_3r -> CtkBuffer(~perc_dir++"h_3r.aiff").addTo(score),
			\h_4 -> CtkBuffer(~perc_dir++"h_4.aiff").addTo(score),
			\k_1 -> CtkBuffer(~perc_dir++"bh_k_1.aiff").addTo(score),
			\water_light -> CtkBuffer(path++"water_light_intensity.aiff").addTo(score),
			\water_light_medium -> CtkBuffer(path++"water_mediumLight_intensity.aiff").addTo(score),
			\water_medium -> CtkBuffer(path++"water_medium_intensity.aiff").addTo(score),
			\water_falling -> CtkBuffer(path++"water_small_waterfall.aiff").addTo(score),
			\water_bbc_rain -> CtkBuffer(path++"BBCRain.aiff").addTo(score),
		];
	},

	\dissolver -> {|score|
		~dissolver_bufs = IdentityDictionary[
			\end_horns -> CtkBuffer(~base_dir++"/horns/horns_n_drums.aif").addTo(score)
		];
	},

	\cross_hiss -> {|score|
		var	path = ~base_dir++"/kernels/";
		~cross_hiss_bufs = IdentityDictionary[
			\light -> CtkBuffer(path++"water_light_intensity.aiff").addTo(score),
			\medium -> CtkBuffer(path++"water_medium_intensity.aiff").addTo(score),
			\mediumLight -> CtkBuffer(path++"water_mediumLight_intensity.aiff").addTo(score),
			\smallWaterFall -> CtkBuffer(path++"water_small_waterfall.aiff").addTo(score),
			\rain -> CtkBuffer(path++"BBCRain.aiff").addTo(score),
			\fb_one -> CtkBuffer(~base_dir ++ "/kernels/feedback_noise_1.8k_cutoff_13s.aiff").addTo(score),

		];
	},

	\proccc -> {|score|
		~grain_shapes_func.(score);
		~proccc_seed_bufs = IdentityDictionary[
			\fb_one -> CtkBuffer(~base_dir ++ "/kernels/feedback_noise_1.8k_cutoff_13s.aiff").addTo(score)
		];
	},

	\gv -> {|score|
		~gv_bufs = IdentityDictionary[
			\water -> CtkBuffer(~base_dir++"/kernels/prep_water_sample_1.aiff").addTo(score),
			\fb_one -> CtkBuffer(~base_dir ++ "/kernels/feedback_noise_1.8k_cutoff_13s.aiff").addTo(score),
			\grit -> CtkBuffer(~base_dir++"/kernels/grit1.aiff").addTo(score),
			\h_0 -> CtkBuffer(~base_dir++"/perc_samps/h_0.aiff").addTo(score),
			\h_1 -> CtkBuffer(~base_dir++"/perc_samps/h_1.aiff").addTo(score),
			\h_2 -> CtkBuffer(~base_dir++"/perc_samps/h_2.aiff").addTo(score),
			\h_3 -> CtkBuffer(~base_dir++"/perc_samps/h_3.aiff").addTo(score),
			\h_4 -> CtkBuffer(~base_dir++"/perc_samps/h_4.aiff").addTo(score),
			\k_1 -> CtkBuffer(~base_dir++"/perc_samps/bh_k_1.aiff").addTo(score)
		];
	},

	\gs -> {|score|
		~gs_bufs = IdentityDictionary[
			\water -> CtkBuffer(~base_dir++"/kernels/prep_water_sample_1.aiff").addTo(score),
			\fb_one -> CtkBuffer(~base_dir ++ "/kernels/feedback_noise_1.8k_cutoff_13s.aiff").addTo(score),
			\grit -> CtkBuffer(~base_dir++"/kernels/grit1.aiff").addTo(score),
			\h_0 -> CtkBuffer(~base_dir++"/perc_samps/h_0.aiff").addTo(score),
			\h_1 -> CtkBuffer(~base_dir++"/perc_samps/h_1.aiff").addTo(score),
			\h_2 -> CtkBuffer(~base_dir++"/perc_samps/h_2.aiff").addTo(score),
			\h_3 -> CtkBuffer(~base_dir++"/perc_samps/h_3.aiff").addTo(score),
			\h_4 -> CtkBuffer(~base_dir++"/perc_samps/h_4.aiff").addTo(score),
			\k_1 -> CtkBuffer(~base_dir++"/perc_samps/bh_k_1.aiff").addTo(score)
		];
	},

	\gv2 -> {|score|
		~gs_bufs = IdentityDictionary[
			\water -> CtkBuffer(~base_dir++"/kernels/prep_water_sample_1.aiff").addTo(score),
			\fb_one -> CtkBuffer(~base_dir ++ "/kernels/feedback_noise_1.8k_cutoff_13s.aiff").addTo(score),
			\grit -> CtkBuffer(~base_dir++"/kernels/grit1.aiff").addTo(score),
			\h_0 -> CtkBuffer(~base_dir++"/perc_samps/h_0.aiff").addTo(score),
			\h_1 -> CtkBuffer(~base_dir++"/perc_samps/h_1.aiff").addTo(score),
			\h_2 -> CtkBuffer(~base_dir++"/perc_samps/h_2.aiff").addTo(score),
			\h_3 -> CtkBuffer(~base_dir++"/perc_samps/h_3.aiff").addTo(score),
			\h_4 -> CtkBuffer(~base_dir++"/perc_samps/h_4.aiff").addTo(score),
			\k_1 -> CtkBuffer(~base_dir++"/perc_samps/bh_k_1.aiff").addTo(score),
			\b_0 -> CtkBuffer(~base_dir++"/perc_samps/b_0.aiff").addTo(score)
		];
	},

	\buf_read_pitch_shift -> {|score|
		~buf_read_pitch_shift_bufs = IdentityDictionary[
			\fb_one -> CtkBuffer(~base_dir ++ "/kernels/feedback_noise_1.8k_cutoff_13s.aiff").addTo(score),
		];
	},

	\perc -> {|score|
		~perc_bufs = IdentityDictionary[
			\h_0 -> CtkBuffer(~base_dir++"/perc_samps/h_0.aiff").addTo(score),
			\h_0r -> CtkBuffer(~base_dir++"/perc_samps/h_0r.aiff").addTo(score),
			\h_1 -> CtkBuffer(~base_dir++"/perc_samps/h_1.aiff").addTo(score),
			\h_2 -> CtkBuffer(~base_dir++"/perc_samps/h_2.aiff").addTo(score),
			\h_3 -> CtkBuffer(~base_dir++"/perc_samps/h_3.aiff").addTo(score),
			\h_3r -> CtkBuffer(~base_dir++"/perc_samps/h_3r.aiff").addTo(score),
			\h_4 -> CtkBuffer(~base_dir++"/perc_samps/h_4.aiff").addTo(score),
			\k_1 -> CtkBuffer(~base_dir++"/perc_samps/bh_k_1.aiff").addTo(score),
			\s_0 -> CtkBuffer(~base_dir++"/perc_samps/snare.aiff").addTo(score),
			\s_1 -> CtkBuffer(~base_dir++"/perc_samps/snare_1.aiff").addTo(score)
		];
	},

	\decorrelate -> {|score|
		var	path = ~base_dir++"/kernels/";
		~dc_bufs = Dictionary[
			\w128 -> CtkBuffer(path++"NoiseClip128.aiff").addTo(score),
			\w256 -> CtkBuffer(path++"NoiseClip256.aiff").addTo(score),
			\w384 -> CtkBuffer(path++"NoiseClip384.aiff").addTo(score),
			\w512 -> CtkBuffer(path++"NoiseClip512.aiff").addTo(score),
			\w513 -> CtkBuffer(path++"NoiseClip513.aiff").addTo(score),
			\w561 -> CtkBuffer(path++"NoiseClip561.aiff").addTo(score),
			\w1024 -> CtkBuffer(path++"NoiseClip1024.aiff").addTo(score),
			\w2048 -> CtkBuffer(path++"NoiseClip2048.aiff").addTo(score)
		];
	}

];

~grain_shapes_func = {|score|
	~grain_shapes = IdentityDictionary[
			\expodec -> CtkBuffer.env(2**10, Env([-60, 0, -60].dbamp, [0.1, 1], \exp)).addTo(score),
			\expoat -> CtkBuffer.env(2**10, Env([-60, 0, -60].dbamp, [1, 0.1], \exp)).addTo(score),
			\hann -> CtkBuffer.env(2**10, Env([0, 1, 1, 0], [0.2, 0.6, 0.2], \sin)).addTo(score),
			\rect -> CtkBuffer.env(2**10,
				 Env([0, 1, 1, 0], [0.001, 1, 0.001].normalizeSum, \sin)).addTo(score)
		];
};

~scpv_buf_func = {|path, score| CtkBuffer(path).addTo(score) };



"###########".postln;
"SM executed".postln;
"###########".postln;