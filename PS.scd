~trh = 4/3;
~trq = 2/3;
~tre = 1/3;
~trs = 0.5/3;

~busdict = IdentityDictionary[];

~assignbus = {|name|
	if(~busdict.includesKey(name), { ~busdict[name] }, { ~busdict.put(name, Bus.audio(s, 2))[name] } );
};

// pre: m_number, post: duration of one beat
~beat2sec = {|meas_num|
	if((meas_num-1) > ~timebase.size, { "~beat2sec func: measure number out of range".throw });
	60/~timebase[meas_num-1][1];
};

// timebase == measures [ [eighthnotes per measure, tempo] ], pre: m_number, post: offset in seconds
~meas2sec = {|meas_num|
	var offset = 0;
	if((meas_num-1) > ~timebase.size, { "~meas2sec func: measure number out of range".throw });
	(meas_num-1).do {|i| offset = offset + (~timebase[i][0] * (60/~timebase[i][1]) / 2) };
	offset;
};

// pre: start [measure, beat], end [measure, beat], post: [starttime, duration]
~c_start_dur = {|start, end|
	var	start_n = ~meas2sec.(start[0]) + (start[1] * ~beat2sec.(start[0])),
		dur = ~meas2sec.(end[0]) + (end[1] * ~beat2sec.(end[0])) - start_n;
	[start_n, dur]
};

~c_start = {|start| ~meas2sec.(start[0]) + (start[1] * ~beat2sec.(start[0])) };

~harm_patterns = Dictionary[
	"m_0i" -> [0, 3, 7],
	"m_1i" -> [0, 3, -5],
	"m_2i" -> [0, -9, -5],
	"m7_0i" -> [0, 3, 7, 10],
	"m7_1i" -> [0, 3, 7, -2],
	"m7_2i" -> [0, 3, -5, -2],
	"m7_3i"-> [0, -9, -5, -2],
	"M_0i" -> [0, 4, 7],
	"M_1i" -> [0, 4, -5],
	"M_2i" -> [0, -8, -5],
	"M7_0i" -> [0, 4, 7, 11],
	"M7_1i" -> [0, 4, 7, -1],
	"M7_2i" -> [0, 4, -5, -1],
	"M7_3i" -> [0, -8, -5, -1],
	"m7_0i" -> [0, 3, 7, 10],
	"m7_1i" -> [0, 3, 7, -2],
	"m7_2i" -> [0, 3, -5, -2],
	"m7_3i" -> [0, -9, -5, -2],
	"dom7_0i" -> [0, 4, 7, 10],
	"dom7_1i" -> [0, 4, 7, -2],
	"dom7_2i" -> [0, 4, -5, -2],
	"dom7_3i" -> [0, -8, -5, -2],
	"dim_0i" -> [0, 3, 6, 9],
	"dim_1i" -> [0, 3, 6, -3],
	"dim_2i" -> [0, 3, -6, -3],
	"dim_3i" -> [0, -9, -6, -3],
	"hdim_0i" -> [0, 3, 6, 10],
	"hdim_1i" -> [0, 3, 6, -2],
	"hdim_2i" -> [0, 3, -6, -2],
	"hdim_3i" -> [0, -9, -6, -2]
].keysValuesChange({|key, value| value.midiratio });

~choirize = {|vowel|
	[\bass, \counterTenor, \tenor, \alto, \soprano]
		.collect {|register| Vowel(vowel, register) }
};

// ~env.( [levels, beats, curves], start_dur )
// beats = [bp2beat, bp3beat, etc...
~env = {|array, start_dur, mul|
	var	beats = array[1], times=[], last_time=start_dur[0], levels=array[0];
	if(array.size<3, {"List env size is too small".throw } );
	if(array[0][0].isMemberOf(PC), { levels = array[0].collect {|pc| pc.freq} });
	if(mul.notNil, { levels = levels * mul} );

	beats.do {|beat|
		var this_time = ~meas2sec.(beat[0]) + (~beat2sec.(beat[0])  * beat[1]);
		times = times ++ (this_time-last_time);
		last_time = this_time;
	};
	if(array[3].notNil, { Env(levels, times, array[2]) }, { CtkControl.env(Env(levels, times, array[2])); } );
};

~perc_env = {|array|
	var	beats = array[1], times=[], last_time=0, levels=array[0];

	beats.do {|beat|
		var this_time = ~meas2sec.(beat[0]) + (~beat2sec.(beat[0])  * beat[1]);
		times = times ++ (this_time-last_time);
		last_time = this_time;
	};

	Env(levels, times, array[2]);
};

~groups = IdentityDictionary[];

~run_this_fucker = {|array|
	fork{
	array.do {|key|
		var	score=CtkScore.new, bundle=~gestures[key], t_name, path, subname, last_group=nil;

		[\one, \two, \three, \four, \five].do {|key|
			var group;
			if(last_group.notNil,
				{ group = CtkGroup(target: last_group, addAction: \addAfter, server: s).addTo(score) },
				{ group = CtkGroup(server: s, addAction: \addToHead).addTo(score) } );
			~groups.put(key, group);
		};

		if(bundle.isMemberOf(IdentityDictionary), { bundle=[bundle] });

		~grain_shapes_func.(score);

		bundle.flat.do {|dict, i|
			var	def=dict[\def], start_dur, n_dict=IdentityDictionary.new;

			if(dict[\start].notNil,
				{start_dur = ~c_start_dur.(dict[\start], dict[\end])}
			);

			dict.keysValuesDo {|key, value|
				if(value.isMemberOf(List),
					{ (key++" list to env...").post; n_dict.put(key, ~env.(value, start_dur)); "done".postln; },
					{n_dict.put(key, value) } );
			};

			[\inbus, \outbus, \sig_two_bus, \sig_one_bus, \target_bus, \kernel_bus,\dry_out, \verb_out,
				\inbus1, \inbus2]
			.do {|param|
				if(dict[param].isMemberOf(Symbol), { n_dict.put(param, ~assignbus.(dict[param])) })
			};

			~ps[def].(score);
			~sm[def].(n_dict, score, start_dur);
			if(t_name.isNil, {t_name = dict[\track] ? 3 });
			dict[\subname] !? {subname=dict[\subname]};
		};

		path = "/Digital_"++t_name;
		if(subname.notNil, {path = "/"++t_name++"/"++path++"_"++subname});

		0.5.wait;
		("WRITING:  " ++ ~base_dir++"/"++~name++path++".aiff").postln;
		score.write(~base_dir++"/"++~name++path++".aiff",
			sampleRate: 44100, sampleFormat: \float,
			options: ServerOptions.new.memSize_(2**18)
				.numOutputBusChannels_(2).maxNodes_(2**12));

		CmdPeriod.doOnce({
			~busdict.keysValuesDo {|key, value| value.free };
			~busdict=IdentityDictionary[];
		});
	};
}};

~mix = {|section, track|
	var	mp = ~base_dir,
		render_path=mp++"/"++section++"/"++track++".aiff",
		source_dir_path=mp++"/"++section++"/"++track++"/*",
		score=CtkScore.new, buffers=[],
		def=CtkSynthDef(\mixer,{|buf|Out.ar(0,PlayBuf.ar(2,buf,BufRateScale.ir(buf)))});
		buffers=source_dir_path.pathMatch.collect {|path| CtkBuffer(path).addTo(score)};
		buffers.do{|buf|def.note(0,buf.duration).buf_(buf).addTo(score)};
		score.write(render_path, sampleRate: 44100, sampleFormat: \float,
			options: ServerOptions.new.numOutputBusChannels_(2));
};


"###########".postln;
"PS executed".postln;
"###########".postln;