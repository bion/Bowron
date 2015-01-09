// --------------------------------------------------------------- sources

  IdentityDictionary[
   \def -> \proccc,
   \outbus -> 0,
   \start -> [37, 1.75],
   \end -> [41, 0],
   \amp -> 2,
   \seed_buf -> \fb_one,
   \env -> List[
    [12, -24, 0, -60, -60, 0, -4].dbamp,
    [ [37, 2], [38, 3], [38, 3.125], [38, 3.5 - ~trs], [38, 3.5], [39, 2]],
    [\exp, 10, 12, \exp, \exp, \exp, \exp] ],
   \grain_shape -> \hann,
   \grain_dur -> 0.08,

   \p_pos -> List[ [-1, -1, 1, 1, 0].neg, [[38, 1], [38, 3], [38, 3.5], [39, 0]], [1, 5, 0, 1] ],
   \p_spread -> List[ [1, 0, 0, 0, 1], [[38, 1], [38, 3], [38, 3.5], [39, 0]], [1, -5, 0, 1] ],
   \rate_hi -> 1,
   \rate_lo -> 1.1,
   \overlap -> List[ [2, 2, 5], [[38, 3.5], [39, 0]], [1, 1] ]
  ],

  IdentityDictionary[
   \def -> \cross_hiss,
   \outbus -> \verb,
   \start -> [34, 0],
   \end -> [35, 0],
   \buf -> \light,
   \amp -> CtkControl.lfo(LFNoise2, 5, 0.1, 0.5),
   \env -> List[
    [0, 1, 1, 0],
    [[34, 1], [34, 3], [35, 0]],
    \sin],
   \rq -> CtkControl.lfo(LFNoise2, 2, 0.15, 0.4),
   \freq -> 6000,
   \freq2 -> CtkControl.lfo(LFNoise2, 3, 0.8, 1.2)
  ],

  IdentityDictionary[
   \track -> 3,
   \def -> \dandan,
   \outbus -> \vowel,
   \start -> [30, 0],
   \end -> [33, 1],
   \amp -> 0.dbamp, // absolute
   \freqs -> [ // must use PC, wrap in an array
     List[
      [PC(\c, 4), PC(\c, 4), PC(\c, 4)],
      [[31, 0], [33, 0]],
      \sin
     ],
    ],
   \freq_muls -> ~harm_patterns["m7_3i"],
   \harm_amps -> (1!7),
   \p_pos -> 0,
   \p_spread -> 1,
   \env_buf -> -1,
   \env -> List[
     [0, 0.1, 1, 0],
     [ [30, 1], [33, 0], [33, 1] ],
     \sin
   ],
   \trigLFOfreq -> 0.25,
   \trigLFOMul -> 1.5,
   \trigLFOrange -> 20,
   \trig_overlap -> 4,
   \gp -> 0.12,

   \vibe_rate -> 6.5,
   \vibe_width -> 0.0125,

   \harmLFOfreq -> 1,
   \harmLFOlo -> -0.01 // db
  ],

  IdentityDictionary[
   \track -> 1,
   \def -> \gv,
   \outbus -> 0,
   \start -> [37, 1.75],
   \end -> [41, 0],
   \e_amp -> 6.dbamp,
   \e_env -> List[
    [0, -12, 0, -60, -60, 0, -4].dbamp,
    [ [37, 2.25], [38, 3], [38, 3.125], [38, 3.5 - ~trs], [38, 3.5], [39, 2]],
    [\exp, 7, 12, \exp, \exp, \exp, \exp], \NO_CTKCONTROL ],
   \g_amp_low -> -26,
   \rate_tend -> Tendency(1, 0.1, 0.5, 0.5),
   \dt_hi -> List[
    [0.0005, 0.001, 0.00005, 0.00005, 0.0008],
    ~dp[\gv_1][0],
    ~dp[\gv_1][1], \NO_CONTROL ],
   \dt_lo -> List[
    [0.0001, 0.0001, 0.00001, 0.00001, 0.0004],
    ~dp[\gv_1][0],
    ~dp[\gv_1][1], \NO_CONTROL ],
   \p_spread_env -> List[
    [1, 0, 0.2, 0.2, 1],
    ~dp[\gv_1][0],
    ~dp[\gv_1][1], \NO_CONTROL ],
   \p_pos_env -> List[
    [-1, -1, 1, 1, 0],
    ~dp[\gv_1][0],
    ~dp[\gv_1][1], \NO_CONTROL ],

   \v_one_k -> 0,
   \v_one_dryL -> List[
    [1, 0.5, 0.5, 0.5, 0],
    ~dp[\gv_1][0],
    ~dp[\gv_1][1] ],
   \v_one_verbL -> List[
    [0, 1, 0.5, 0.5, 1],
    ~dp[\gv_1][0],
    ~dp[\gv_1][1] ],

   \k_pitch -> 1,
   \conv_fade -> 0,

   \v_two_k -> List[
    [1, 0, 1, 0, -1],
    ~dp[\gv_1][0],
    ~dp[\gv_1][1] ],
   \v_two_dryL -> List[
    [1, 0.5, 1, 0.5, 0.125],
    ~dp[\gv_1][0],
    ~dp[\gv_1][1] ],
   \v_one_verbL -> List[
    [0, 0, 0, 0.5, 1],
    ~dp[\gv_1][0],
    ~dp[\gv_1][1] ],

   \diss -> 1
  ]

// --------------------------------------------------------------- filters

  IdentityDictionary[
   \def -> \leslie,
   \inbus -> \lez,
   \outbus ->  0,
   \start -> [38, 1],
   \end -> [47, 1],
   \amp -> 1,
   \speed -> List[
    [(60/432), (60/432), (60/648)].reciprocal,
    [[46, 0], [46, 0.01]],
    \lin],
   \max -> List[
    [0.002, 0.08, 0.002, 0.12],
    [[38, 2], [39, 1], [46, 1]],
    \sin],
   \fade -> -1
  ],

  IdentityDictionary[
   \def -> \vowel,
   \inbus -> \vowel,
   \outbus -> 0,
   \start -> [30, 0],
   \end -> [33, 1],
   \fade -> -1,
   \vowels -> ~choirize.(\u)
  ]

  IdentityDictionary[
   \def -> \reverb,
   \inbus -> \verb,
   \dry_out -> 0,
   \verb_out -> 0,
   \start -> [34, 0],
   \end -> [36, 0],
   \dryL -> 0.25,
   \verbL -> 1,
   \verbK -> 0.5
  ]
