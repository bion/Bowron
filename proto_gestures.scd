	IdentityDictionary[
		\def -> \buf_read_pitch_shift,
		\track -> 4,
		\group -> \five,
//		\subname -> nil,
		\outbus -> 0,
		\amp -> 0.dbamp,
		\env -> List[
			[],
			[],
			\exp
		],
		\buf -> \fb_one,
		\pitch -> 1,
		\pan -> 0,
		\rate -> 1
	],
	
		IdentityDictionary[
			\def -> \diss,
			\group -> \three,
			\inbus -> ,
			\outbus -> 0,
			\diss -> 1
		],
	
	IdentityDictionary[
		\track -> 1,
		\group -> \five,
//		\subname -> nil,
		\def -> \gv,
		\outbus -> \cross_2,
		\start -> [4, 2],
		\end -> [10, 0],
		\envbuf -> \rect,
		\e_amp -> amp.dbamp,
		\conv_buf -> \fb_one,
		\e_env -> List[
			[-6, -12, 0, -60, -60, -60, -40].dbamp, 
			[ [4, 2], [5, 3.5], [6, 3.125], [7, 3.5], [8, 3.5], [9, 2]], 
			[\exp, 7, 12, \exp, \exp, \exp, \exp] ],
		\g_amp_low -> -26,
		\dt_hi -> 0.0001,
		\dt_lo -> 0.000001,
		\p_spread_env -> 0,
		\p_pos_env -> 0,
		
		\v_one_k -> 1,
		\v_one_dryL -> 1,
		\v_one_verbL -> 0,
		
		\k_pitch -> k_pitch,
		\conv_fade -> -1,
		
		\v_two_k -> 0.5,
		\v_two_dryL -> 0.5,
		\v_one_verbL -> 0,
			
		\diss -> 1
	]
	
		IdentityDictionary[
			\def -> \dandan,
			\outbus -> \cross_1,
			\group -> \five,
			\start -> [4, 2],
			\end -> [10, 0],
			\amp -> -1.dbamp, // absolute
			\env -> List[
				[-6, -12, 0, -60, -60, -60, -40].dbamp, 
				[ [4, 2], [5, 3.5], [6, 3.125], [7, 3.5], [8, 3.5], [9, 2]], 
				[\exp, 7, 12, \exp, \exp, \exp, \exp] ],
			\freqs -> [ // must use PC, wrap in an array
					pc
				],
			\freq_muls -> [0.5, 1, 2],
			\freq_muls_2 -> [1],
			\harm_amps -> Array.geom(7, 1, 0.5),
			\p_pos -> 0,
			\p_spread -> 0,
			\grain_shape -> \hann,
			\trigLFOfreq -> 2.5,
			\trigLFOMul -> 1,
			\trigLFOrange -> 50,
			\trig_overlap -> 1.4,
			\gp -> 0.12,
		
			\vibe_rate -> 6.5,
			\vibe_width -> 0.0125,
		 
			\harmLFOfreq -> 5,
			\harmLFOlo -> -26 // db
		]
		
	IdentityDictionary[
			\def -> \cross,
			\group -> \three,
			\outbus -> \to_comp,
			\sig_one_bus -> \cross_1,
			\sig_two_bus -> \cross_2,
			\start -> [4, 2],
			\end -> [10, 0]
		]
		
	IdentityDictionary[
			\def -> \fft_comp,
			\group -> \two,
			\inbus -> \to_comp,
			\outbus -> 0,
			\start -> [4, 2],
			\end -> [10, 0],
			\thresh -> 20,
			\s_above -> 0.1,
			\s_below -> 1
		]
		
	IdentityDictionary[
		\def -> \reverb,
		\start -> [1, 0],
		\end -> [3, 0],
		\inbus -> \hv_in,
		\group -> \three,
		\dry_out -> 0,
		\verb_out -> 0,
		\verbK -> List[
			[1, 1, -1],
			[ [1, 1.5], [1, 2] ],
			\lin],
		\verbL -> 1,
		\dryL -> 1
	],
	
		IdentityDictionary[
			\def -> \perc,
			\track -> \perc_wist,
			\group -> \five,
			\outbus -> 0,
			\pan -> 0, // can be arrayenv
			\buf -> nil,
			\amp -> -6.dbamp,
			\env -> nil, // [ [-10, 0].dbamp, [ [1, 3] ], \exp],
			\starts -> [ [1, 0, \h_0], [1, 1, \h_1], [1, 2, \h_2], [1, 3, \h_3], [1, 4, \h_4] ], // must be array
		],
	
	\perc_one_kick -> [
		IdentityDictionary[
			\def -> \perc,
			\track -> \perc_kick,
			\group -> \five,
			\outbus -> 0,
			\pan -> 0,
			\buf -> \k_1,
			\amp -> -6.dbamp,
			\starts -> [ [1, 4.5], [2, 0] ], // must be array
			\env -> nil
		],
