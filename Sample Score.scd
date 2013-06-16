~name = "S2";

~base_dir = Document.current.dir;

if(~timebase.isNil, {
	["PS", "DP", ("TB_"++~name++""), "SD", "SM"].reverse.do {|item|
		("CURRENTLY LOADING  " ++ item).postln;
		(~base_dir++"/"++item++".scd").load;
	};
	"_____________ that shit is ready _____________".postln;
	"".postln;
});

~gestures = IdentityDictionary[

	\gv_four -> [
		IdentityDictionary[
			\track -> 2,
			\subname -> \four,
			\def -> \gv,
			\group -> \five,
			\outbus -> \gv_four_vowel,
			\start -> [10, 3],
			\end -> [18, 3],
			\envbuf -> \rect,
			\e_amp -> 0.dbamp,
			\conv_buf -> \water,
			\e_env -> List[
				[ -14, 0, -6, 0, 0, -16 ].dbamp,
				~dp[\times][\gv_four],
				[\exp, \welch, \exp, \exp, \exp, \exp] ],
			\g_amp_low -> -32.dbamp,
			\dt_hi -> List[
				[0.00005, 0.00005, 0.0005, 0.00005, 0.00005, 0.001],
				~dp[\times][\gv_four],
				\lin],
			\dt_lo -> List[
				[0.00001, 0.00001, 0.00005, 0.000001, 0.000001, 0.0001],
				~dp[\times][\gv_four],
				\lin],
			\p_spread_env -> List[
				[1, 0, 1, 0, 0, 1],
				~dp[\times][\gv_four],
				\lin],
			\p_pos_env -> 0,
			
			\v_one_k -> -1,
			\v_one_dryL -> 1,
			\v_one_verbL ->0,
			
			\k_pitch -> 8,
			\conv_fade -> 1,
			
			\v_two_k -> 1,
			\v_two_dryL -> -14.dbamp,
			\v_one_verbL -> -8.dbamp,
			
			\diss -> 0
		],
		
		IdentityDictionary[
			\track -> 2,
			\subname -> \four,
			\group -> \three,
			\def -> \vowel,
			\inbus -> \gv_four_vowel,
			\outbus -> 0,
			\start -> [10, 3],
			\end -> [18, 3],
			\fade -> List[
				[ 1, 1, 1, 1, 1, 1 ].neg, ~dp[\times][\gv_four], \sin
			],
			\vowels -> (~choirize.(\a) ++ ~choirize.(\i))
		]
	],
	
	
	\ch_six -> [
		IdentityDictionary[
			\def -> \cross_hiss,
			\track -> 4,
			\subname -> \ch_six,
			\outbus -> \ch_six_verb,
			\group -> \five,
			\start -> [42, 3],
			\end -> [51, 0],
			\amp -> -26.dbamp, // absolute
			\buf -> \smallWaterFall,
			\env -> List[
				[ -26, -14, -10, -3, -12, 0, 0, -56 ].dbamp,
				[ [ 43, 0 ], [ 44, 0 ], [ 45, 0 ], [ 46, 0 ], [ 47, 0 ], [ 49, 0 ], [50, 2], [ 51, 0 ] ],
				\exp],
			\rq -> CtkControl.lfo(LFNoise2, 1.5.reciprocal, 0.1, 0.25),
			\freq -> CtkControl.lfo(LFNoise2, 30, 8000, 9000),
			\freq2 -> 0.5
		],
		
		IdentityDictionary[
			\def -> \reverb, 
			\inbus -> \ch_six_verb,
			\group -> \four,
			\start -> [42, 3],
			\end -> [51, 0],
			\dry_out -> 0,
			\verb_out -> 0,
			\verbK -> -1,
			\verbL -> 0.dbamp,
			\dryL -> 0.dbamp
		]
	],

];

~run.(
	[
//		\gv_four,

//		\ch_six
	];
); 