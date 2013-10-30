(* M is the population size;
  NN is the sample size;
  
  pi is the frequency of allele Ai in the population;
  Pii is the frequency of homozygotes with allele Ai in the population;
  yiN is a particular value of the number of copies of allele Ai in the sample *)
pmfSamplingDistYiN[M_, NN_, pi_, Pii_, yiN _]:=
  
Module[{Maxfunc, Minfunc, Lowerbound, Upperbound, Numerator1, Summand, Prob, xii},
    
    

  (* The lower and upper bounds for xii are specified according to equation (8) *)
    
  Maxfunc = Max[(yiN/2) - (M*pi) + (M*Pii), yiN - NN, 0];
    
  Minfunc = Min[M*Pii, yiN/2, M - NN + yiN - (2*M*pi) + (M*Pii)];
    
  Lowerbound = Ceiling[Maxfunc];
    
  Upperbound = Floor[Minfunc];
    

  (* P(YiN = yiN) is calculated according to equation (9) *)
    
  (* First, numerator is computed. *)
    
  Numerator1 = 0.0;
    
  For[xii = Lowerbound, xii ≤ Upperbound, xii++,
      
    Summand = Binomial[M*Pii, xii]*Binomial[2*M*(pi - Pii), yiN - (2*xii)]*Binomial[M + (M*Pii) -  
      (2*M*pi), NN + xii - yiN];
      
    Numerator1 = Numerator1 + Summand;
      
  ];
    
  (* Second, numerator is divided by denominator *)
    
  Prob = Numerator1/Binomial[M, NN];
    
  Return[Prob];
    
    
];

(* Example Run and Output *)
pmfSamplingDistYiN[1000, 10, 0.1, 0.04, 1] // Timing
{0.005244 Second, 0.250394}
 

(* M is the population size;
  
  NN is the sample size;
  
  pi0 is a possible value for the frequency of allele Ai in the population;
  
  Pii0 is a possible value for the frequency of homozygotes with allele Ai in
the population;
  
  yiNobs is the observed number of copies of allele Ai in the sample;
  
  alpha is the significance level *)
AcceptanceRegion[M_, NN_, pi0_, Pii0_, yiNobs_, alpha_]:=
  
Module[{Sumprob, yiNlower, dummy1, Sumprob2, yiNupper, TestyiNobs, Output},
    
    

  (* First, determine lower bound of acceptance region *)
    
  Sumprob = 0.0;
    
  yiNlower = 0;
    
  dummy1 = 0.0;
    
  While[Sumprob ≤ (alpha/2), dummy1 = pmfSamplingDistYiN[M, NN, pi0, Pii0, yiNlower]; 
    Sumprob = Sumprob + dummy1; yiNlower = yiNlower + 1;];

 yiNlower = yiNlower - 1;
    
  dummy1 = pmfSamplingDistYiN[M, NN, pi0, Pii0, yiNlower];
    
  Sumprob = Sumprob - dummy1;
    
    

  (* Second, determine upper bound of acceptance region *)
    
  Sumprob2 = 1.0;
    
  yiNupper = 2*NN;
    
  While[Sumprob2 ≥ (1 - (alpha/2)), dummy1 = pmfSamplingDistYiN[M, NN, pi0, Pii0, yiNupper]; 
    Sumprob2 = Sumprob2 - dummy1; yiNupper = yiNupper - 1;];
    
  yiNupper = yiNupper + 1;
    
  dummy1 = pmfSamplingDistYiN[M, NN, pi0, Pii0, yiNupper];
    
  Sumprob2 = Sumprob2 + dummy1;
    
    
    
  (* Test if yiNobs is in acceptance region *)
    
  TestyiNobs = (yiNobs ≥ yiNlower) && (yiNobs ≤ yiNupper);
    
  Output = {yiNlower, yiNupper, TestyiNobs};
    
    

  Return[Output];

    
    
];

(* Example Run and Outputs *)
AcceptanceRegion[1000, 30, 0.625, 0.25, 50, 0.05] // Timing
{0.089199 Second, {33, 42, False}}


(* M is the population size;
  
  NN is the sample size;
  
  yiNobs is the observed number of copies of allele Ai in the sample;
  
  alpha is the significance level *)
CIforpiCasePiiUnknown[M_, NN_, yiNobs_, alpha_]:=
  
Module[{Output, pi0List, Pii0List, j, pi0, Pii0, k, Output1, Output2, piCIlowerlimit, piCIupperlimit,   
  PiiCIlowerlimit, PiiCIupperlimit, largestalphaList, Outputcounter, alphaMax, alphaMaxIndex},
    
  
     
  Output = {};
    
  pi0List = {};
    
  Pii0List = {};
    
    

  (* Loop over all possible values of pi, denoted by pi0 *)
    
  For[j = 0, j ≤ (2*M), j++,
      
    pi0 = j/(2*M);
      
    (* Only go further if constraints on pi0 are met. *)
      
    If[(pi0 ≥ (yiNobs/(2*M))) && (pi0 ≤ (1 - (((2*NN) - yiNobs)/(2*M)))),

     (* Loop over all possible values of Pii, denoted by Pii0 *)
        
      For[k = 0, k ≤ j, k++,
          
        Pii0 = k/(2*M);
          
        (* Only go further if constraints on Pii0 are met. *)
          
        If[(Pii0 ≥ Max[0, (2*pi0) - 1]) && (Pii0 ≤ pi0),
            
          (* For given pi0 and Pii0, test if yiNobs is in acceptance region;
              
            if so, append pi0 and Pii0 to pi0list 
              and Pii0list respectively *)
              
          Output1 = AcceptanceRegion[M, NN, pi0, Pii0, yiNobs, alpha];
          If[Output1[[3]] == True, AppendTo[pi0List, pi0 //N]; AppendTo[Pii0List, Pii0 //N];];
            
          (* Regardless of whether yiNobs falls within acceptance region, pi0 and Pii0 are 
          
                    
            appended to Output together with Output1 - this is used in below code if necessary *)
            
          Output2 = Join[{pi0 //N, Pii0 //N}, Output1];
            
          AppendTo[Output, Output2];

       ];
          
      ];
        
    ];
      
  ];
    
    

  (* If there is at least one pair of pi0 and Pii0 for which yiNobs falls within corresponding
        
    acceptance region, then CI's for pi and Pii are defined according to equations (14a) and (14b) *)
    
  If[Length[pi0List] > 0, 
      
    piCIlowerlimit = Min[pi0List];
      
    piCIupperlimit = Max[pi0List];
      
    PiiCIlowerlimit = Min[Pii0List];
      
    PiiCIupperlimit = Max[Pii0List];
      
  ];
    
    

  (* If there are no pairs of pi0 and Pii0 for which yiNobs falls within corresponding acceptance 
    region, then alpha is decreased until yiNobs falls within one acceptance region *)
      
  If[Length[pi0List] == 0, 
      
    (* Loop over all pi0 and Pii0 again and for each pair that meet the constraints, determine 
      largest alpha value for which yiNobs falls within acceptance region *)
      
    (* largestalphaList is list of largest alpha's needed to cover yiNobs's. *)
      
    largestalphaList = {};
      
    Outputcounter = 1;
      
    For[j = 1, j ≤ (2*M), j++,
      pi0 = j/(2*M);
        
      If[(pi0 ≥ (yiNobs/(2*M))) && (pi0 ≤ (1 - (((2*NN) - yiNobs)/(2*M)))),

       For[k = 0, k ≤ j, k++,

         Pii0 = k/(2*M);
            
          If[(Pii0 ≥ Max[0, (2*pi0) - 1]) && (Pii0 ≤ pi0),
              
            (* Calculate alpha value needed to cover yiNobs.
           
                                 
              There are two subcases, yiNobs below and above acceptance region. *)
              
            If[yiNobs < Output[[Outputcounter, 3]],
                
              Sumprob = 0.0;
                
              For[m = 0, m ≤ (yiNobs - 1), m++,
             
                     
                Sumprob = Sumprob + pmfSamplingDistYiN[M, NN, pi0[[j]], Pii0[[j]], m];
                    
              ];
                
              AppendTo[largestalphaList, Sumprob*2];

           ];
              
            If[yiNobs > Output[[Outputcounter, 4]],

             Sumprob2 = 0.0;
                
              For[m = (2*NN), m ≥ (yiNobs + 1), m--,
                Sumprob2 = Sumprob2 + pmfSamplingDistYiN[M, NN, pi0[[j]], Pii0[[j]], m];
                    
              ];
                
              AppendTo[largestalphaList, Sumprob2*2];
                
            ];
              
            Outputcounter = Outputcounter + 1;
              
          ];
            
        ];
          
      ];
        
    ];
      
    (* From largestalphaList, find largest value, representing largest alpha for which yiNobs falls 
      within an acceptance region, considering all possible values of pi and Pii *)
      
    alphaMax = -1;
      
    alphaMaxIndex = -1;
      
    For[j = 1, j ≤ Length[largestalphaList], j++,

     If[largestalphaList[[j]] > alphaMax, alphaMax = largestalphaList[[j]]; alphaMaxIndex = j];
          
    ];
      
    (* Define lower and upper limits for pi and Pii given largest alpha *)
      
    piCIlowerlimit = Output[[alphaMaxIndex, 1]];
      
    piCIupperlimit = Output[[alphaMaxIndex, 1]];
      
    PiiCIlowerlimit = Output[[alphaMaxIndex, 2]];
      
    PiiCIupperlimit = Output[[alphaMaxIndex, 2]];
      
  ];
    
    

  Return[{{piCIlowerlimit, piCIupperlimit}, {PiiCIlowerlimit, PiiCIupperlimit}}];
    
    

];
 
(* Example Run and Outputs *)
CIforpiCasePiiUnknown[100, 30, 5, 0.05] // Timing
{268.678 Second, {{0.025, 0.2}, {0., 0.195}}}


(* M is the population size;
  
  NN is the sample size;
  
  yiNobs is the observed number of copies of allele Ai in the sample;
  
  alpha is the significance level *)
CIforpiCasePiiKnown[M_, NN_, yiNobs_, alpha_]:=
  
Module[{Output, pi0List, j, pi0, Pii0, Output1, Output2, piCIlowerlimit, piCIupperlimit,   
  largestalphaList, Outputcounter, alphaMax, alphaMaxIndex},
    
    

  Output = {};
    
  pi0List = {};
    
    

  For[j = 0, j ≤ (2*M), j++,
    pi0 = j/(2*M);
      
    If[(pi0 ≥ (yiNobs/(2*M))) && (pi0 ≤ (1 - (((2*NN) - yiNobs)/(2*M)))),
        
      (* Max homozygosity case *)
        
      Pii0 = pi0;
        
      (* Replace with Pii0 = pi0^2 for HWE case *)
        
      (* Replace with Pii0 = Max[0, (2*pi0) - 1] for Min homozygosity case *)
        
      (* Extra constraint for Pii0 to ensure that Pii0*M, the number of homozygotes in the population,
        is an integer *)
        
      If[(Pii0 ≥ Max[0, (2*pi0) - 1]) && (Pii0 ≤ pi0) && (Head[Pii0*M] == Integer),
          
        Output1 = AcceptanceRegion[M, NN, pi0, Pii0, yiNobs, alpha];
          
        If[Output1[[3]] == True, AppendTo[pi0List, pi0 //N]];
          
        Output2 = Join[{pi0 //N, Pii0 //N}, Output1];
          
        AppendTo[Output, Output2];
          
          
      ];
        
    ];
      
  ];
    
    

  (* If there is at least one pair of pi0 and Pii0 for which yiNobs falls within corresponding
        
    acceptance region, then CI's for pi and Pii are defined according to equation (13) *)
    
  If[Length[pi0List] > 0, 
      
    piCIlowerlimit = Min[pi0List];
      
    piCIupperlimit = Max[pi0List];
      
  ];
    
    

  (* If there are no pairs of pi0 and Pii0 for which yiNobs falls within corresponding acceptance 
    region, then alpha is decreased until yiNobs falls within one acceptance region *)
    
  If[Length[pi0List] == 0, 
      
    largestalphaList = {};
      
    Outputcounter = 1;
      
    For[j = 1, j ≤ (2*M), j++, 
      pi0 = j/(2*M);
        
      If[(pi0 ≥ (yiNobs/(2*M))) && (pi0 ≤ (1 - (((2*NN) - yiNobs)/(2*M)))),
          
        (* Max homozygosity case *)
          
        Pii0 = pi0;
          
        (* Replace with Pii0 = pi0^2 for HWE case *)
          
        (* Replace with Pii0 = Max[0, (2*pi0) - 1] for Min homozygosity case *)
          
                     
        If[(Pii0 ≥ Max[0, (2*pi0) - 1]) && (Pii0 ≤ pi0) && (Head[Pii0*M] == Integer),
            
          If[yiNobs < Output[[Outputcounter, 3]],
              
            Sumprob = 0.0;
              
            For[m = 0, m ≤ (yiNobs - 1), m++, 
              Sumprob = Sumprob + pmfSamplingDistYiN[M, NN, pi0[[j]], Pii0[[j]], m];
                
            ];
              
            AppendTo[largestalphaList, Sumprob*2];
              
          ];
            
          If[yiNobs > Output[[Outputcounter, 4]],
              
            Sumprob2 = 0.0;
              
            For[m = (2*NN), m ≥ (yiNobs + 1), m--,
              Sumprob2 = Sumprob2 + pmfSamplingDistYiN[M, NN, pi0[[j]], Pii0[[j]], m];
                       
            ];
              
            AppendTo[largestalphaList, Sumprob2*2];
              
          ];
            
          Outputcounter = Outputcounter + 1;
            
        ];
          
      ];
        
    ];
      
    (* From largestalphaList, find largest value, representing largest alpha for which
          
        
      yiNobs falls within an acceptance region, considering all possible values of pi and Pii *)
      
    alphaMax = -1;
      
    alphaMaxIndex = -1;
      
    For[j = 1, j ≤ Length[largestalphaList], j++,
        
      If[largestalphaList[[j]] > alphaMax, alphaMax = largestalphaList[[j]]; alphaMaxIndex = j];
          
    ];
      
    (* Define lower and upper limits for pi and Pii given largest alpha *)
      
    piCIlowerlimit = Output[[alphaMaxIndex, 1]];
      
    piCIupperlimit = Output[[alphaMaxIndex, 1]];
      
  ];
    
    

  Return[{piCIlowerlimit, piCIupperlimit}];
    
    
];

(* Example Run and Outputs *)
CIforpiCasePiiKnown[438, 53, 1, 0.05/3] // Timing
{8.96702 Second, {0.00228311, 0.0799087}}


(* Find CI's for p1, p2 and p3, for Prasto population *)
CIforp1Prasto = CIforpiCasePiiKnown[2*219, 53, 1, 0.05/3];
CIforp2Prasto = CIforpiCasePiiKnown[2*219, 53, 80, 0.05/3];
CIforp3Prasto = CIforpiCasePiiKnown[2*219, 53, 24, 0.05/3];
(* Find CI's for q1, q2 and q3, for Finstrom population *)
CIforq1Finstrom = CIforpiCasePiiKnown[7*219, 74, 4, 0.05/3];
CIforq2Finstrom = CIforpiCasePiiKnown[7*219, 74, 123, 0.05/3];
CIforq3Finstrom = CIforpiCasePiiKnown[7*219, 74, 4, 0.05/3];
(* Define Jost's D *)
plist = {p1, p2, p3, 1 - p1 - p2 - p3};
qlist = {q1, q2, q3, 1 - q1 - q2 - q3};
JostS = (Sum[plist[[k]]*plist[[k]], {k, 1, 4}] + Sum[qlist[[k]]*qlist[[k]], {k, 1, 4}])/2;
JostT = Sum[((plist[[k]] + qlist[[k]])/2)^2, {k, 1, 4}];
JostD = ((JostT/JostS) - 1)/((1/2) - 1);
(* Find lower bound of CI for Jost's D *)
Minimize[JostD, (p1 > CIforp1Prasto[[1]]) && (p1 < CIforp1Prasto[[2]]) && (p2 > CIforp2Prasto[[1]]) 
  && (p2 < CIforp2Prasto[[2]]) && (p3 > CIforp3Prasto[[1]]) && (p3 < CIforp3Prasto[[2]]) 
  && (q1 > CIforq1Finstrom[[1]]) && (q1 < CIforq1Finstrom[[2]]) && (q2 > CIforq2Finstrom[[1]]) 
  && (q2 < CIforq2Finstrom[[2]]) && (q3 > CIforq3Finstrom[[1]]) && (q3 < CIforq3Finstrom[[2]]) 
  && (p1 + p2 + p3 ≤ 1) && (q1 + q2 + q3 ≤ 1), {p1, p2, p3, q1, q2, q3}]
(* Find upper bound of CI for Jost's D *)
Maximize[JostD, (p1 > CIforp1Prasto[[1]]) && (p1 < CIforp1Prasto[[2]]) && (p2 > CIforp2Prasto[[1]]) 
  && (p2 < CIforp2Prasto[[2]]) && (p3 >
CIforp3Prasto[[1]]) && (p3 < CIforp3Prasto[[2]]) 
  && (q1 > CIforq1Finstrom[[1]]) && (q1 < CIforq1Finstrom[[2]]) && (q2 > CIforq2Finstrom[[1]]) 
  && (q2 < CIforq2Finstrom[[2]]) && (q3 >
CIforq3Finstrom[[1]]) && (q3 < CIforq3Finstrom[[2]]) 
  && (p1 + p2 + p3 ≤ 1) && (q1 + q2 + q3 ≤ 1), {p1, p2, p3, q1, q2, q3}]
