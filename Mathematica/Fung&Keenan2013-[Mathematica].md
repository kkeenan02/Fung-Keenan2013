<center>
Fung & Keenan 2013: Description of _Mathematica_ programs used to calculate  confidence intervals
========================================================

Tak Fung^1,2 and Kevin Keenan^3
----------------------------------------------------

<h6>
<sup>1</sup> National University of Singapore, Department of Biological Sciences, 14 Science Drive 4, Singapore 117543

<sup>2</sup> Queens University Belfast, School of Biological Sciences, Belfast BT9 7BL, UK

<sup>3</sup> Queens University Belfast, Institute for Global Food Security, School of Biological Sciences, Belfast BT9 7BL, UK

</center>
</h6>

## Introduction
This document describes the functionality of the _Mathematica_ code used in Fung & Keenan 2013. The code was written and tested using _Mathematica_ v5.0[1]. This document describes four separate programs named, `pmfSamplingDistYiN`, `AcceptanceRegion`, `CIforpiCasePiiUnknown` and `CIforpiCasePiiknown`.
A `R` version of the code and examples can be found @ http://rpubs.com/kkeenan02/Fung-Keenan-R.

## pmfSamplingDistYiN
This program returns $P(Y_{i,N} = y_{i,N})$ as specified by equation (9) in the main text, given $M$, $N$, $p_{i}$, $P_{ii}$ and $y_{i,n}$. Here, $Y_{i,N}$ is the random variable specifying the number of copies of allele $A_{i}$ in a sample of size $N$ taken from a finite diploid population of size $M$, with the frequency of allele $A_{i}$ in the population being $p_{i}$ and the frequency of homozygotes of allele $A_{i}$ in the population being $P_{ii}$.

### pmfSamplingDistYiN source code (_Mathematica_)
```
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
    
  For[xii = Lowerbound, xii = Upperbound, xii++,
      
    Summand = Binomial[M*Pii, xii]*Binomial[2*M*(pi - Pii), yiN - (2*xii)]*Binomial[M + (M*Pii) -  
      (2*M*pi), NN + xii - yiN];
      
    Numerator1 = Numerator1 + Summand;
      
  ];
    
  (* Second, numerator is divided by denominator *)
    
  Prob = Numerator1/Binomial[M, NN];
    
  Return[Prob];
    
    
];
```

### pmfSamplingDistYiN example
```
(* Example Run and Output *)
pmfSamplingDistYiN[1000, 10, 0.1, 0.04, 1] // Timing
{0.005244 Second, 0.250394}
```

## AcceptanceRegion
This program tests the null hypothesis $H_{o}:p_{i}=p_{i,0}, P_{ii}=P_{ii,0}$ for an observed value of $y_{i,N}$, $latex \hat{y}_{i,N}$, given the sampling scenario considered. It does this by calculating the acceptance region for a specified significance level, $latex \alpha$, and then determining whether $latex \hat{y}_{i,N}$ lies within this region. The outputs are bounds of the acceptance region and an indication of whether $latex \hat{y}_{i,N}$ falls within this region or not ('1' == TRUE, '0' == FALSE, respectively).


### AcceptanceRegion source code (_Mathematica_)
```
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
    
  While[Sumprob = (alpha/2), dummy1 = pmfSamplingDistYiN[M, NN, pi0, Pii0, yiNlower]; 
    Sumprob = Sumprob + dummy1; yiNlower = yiNlower + 1;];

 yiNlower = yiNlower - 1;
    
  dummy1 = pmfSamplingDistYiN[M, NN, pi0, Pii0, yiNlower];
    
  Sumprob = Sumprob - dummy1;
    
    

  (* Second, determine upper bound of acceptance region *)
    
  Sumprob2 = 1.0;
    
  yiNupper = 2*NN;
    
  While[Sumprob2 = (1 - (alpha/2)), dummy1 = pmfSamplingDistYiN[M, NN, pi0, Pii0, yiNupper]; 
    Sumprob2 = Sumprob2 - dummy1; yiNupper = yiNupper - 1;];
    
  yiNupper = yiNupper + 1;
    
  dummy1 = pmfSamplingDistYiN[M, NN, pi0, Pii0, yiNupper];
    
  Sumprob2 = Sumprob2 + dummy1;
    
    
    
  (* Test if yiNobs is in acceptance region *)
    
  TestyiNobs = (yiNobs = yiNlower) && (yiNobs = yiNupper);
    
  Output = {yiNlower, yiNupper, TestyiNobs};
    
    

  Return[Output];

    
    
];
```

### AcceptanceRegion example
```
(* Example Run and Outputs *)
AcceptanceRegion[1000, 30, 0.625, 0.25, 50, 0.05] // Timing
{0.089199 Second, {33, 42, False}}
```

## CIforpiCasePiiUnknown
This program calculates $latex \geq 100(1-\alpha) %$ confidence intervals (CI's) for $p_i$ and $P_{ii}$ given $M$, $N$ and $latex \hat{y}_{i,N}$. These CI's are computed using equation (14a) and (14b) in the main text, and uses `pmfSamplingDistYiN` and `AcceptanceRegion`. The outputs are the lower and upper limits of the CI for $p_i$ followed by those of the CI for $P_{ii}$.

### CIforpiCasePiiUnknown source code (_Mathematica_)
```
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
    
  For[j = 0, j = (2*M), j++,
      
    pi0 = j/(2*M);
      
    (* Only go further if constraints on pi0 are met. *)
      
    If[(pi0 = (yiNobs/(2*M))) && (pi0 = (1 - (((2*NN) - yiNobs)/(2*M)))),

     (* Loop over all possible values of Pii, denoted by Pii0 *)
        
      For[k = 0, k = j, k++,
          
        Pii0 = k/(2*M);
          
        (* Only go further if constraints on Pii0 are met. *)
          
        If[(Pii0 = Max[0, (2*pi0) - 1]) && (Pii0 = pi0),
            
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
      
    For[j = 1, j = (2*M), j++,
      pi0 = j/(2*M);
        
      If[(pi0 = (yiNobs/(2*M))) && (pi0 = (1 - (((2*NN) - yiNobs)/(2*M)))),

       For[k = 0, k = j, k++,

         Pii0 = k/(2*M);
            
          If[(Pii0 = Max[0, (2*pi0) - 1]) && (Pii0 = pi0),
              
            (* Calculate alpha value needed to cover yiNobs.
           
                                 
              There are two subcases, yiNobs below and above acceptance region. *)
              
            If[yiNobs < Output[[Outputcounter, 3]],
                
              Sumprob = 0.0;
                
              For[m = 0, m = (yiNobs - 1), m++,
             
                     
                Sumprob = Sumprob + pmfSamplingDistYiN[M, NN, pi0[[j]], Pii0[[j]], m];
                    
              ];
                
              AppendTo[largestalphaList, Sumprob*2];

           ];
              
            If[yiNobs > Output[[Outputcounter, 4]],

             Sumprob2 = 0.0;
                
              For[m = (2*NN), m = (yiNobs + 1), m--,
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
      
    For[j = 1, j = Length[largestalphaList], j++,

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
```

### CIforpiCasePiiUnknown example
```
(* Example Run and Outputs *)
CIforpiCasePiiUnknown[100, 30, 5, 0.05] // Timing
{268.678 Second, {{0.025, 0.2}, {0., 0.195}}}
```

## CIforpiCasePiiKnown

This program a $latex \geq 100(1-\alpha)% $ CI for $p_{i}$, given $M$, $N$ and
$latex \hat{y}_{i,N}$, for a population with maximum homozygosity ($p_{i}=P_{ii}$). The program uses equation (13) in the main text to calculate the CI, and uses `pmfSamplingDistYiN` and `AcceptanceRegion`. The outputs are the lower and upper bounds for the CI. The code of `CIforpiCasePiiKnown` can be easily adapted to calculate CI's under the scenario of HWE or the Scenario of minimum homozygosity, by altering two lines indicated within the code.

### CIforpiCasePiiKnown source code (_Mathematica_)
```
(* M is the population size;
  
  NN is the sample size;
  
  yiNobs is the observed number of copies of allele Ai in the sample;
  
  alpha is the significance level *)
CIforpiCasePiiKnown[M_, NN_, yiNobs_, alpha_]:=
  
Module[{Output, pi0List, j, pi0, Pii0, Output1, Output2, piCIlowerlimit, piCIupperlimit,   
  largestalphaList, Outputcounter, alphaMax, alphaMaxIndex},
    
    

  Output = {};
    
  pi0List = {};
    
    

  For[j = 0, j = (2*M), j++,
    pi0 = j/(2*M);
      
    If[(pi0 = (yiNobs/(2*M))) && (pi0 = (1 - (((2*NN) - yiNobs)/(2*M)))),
        
      (* Max homozygosity case *)
        
      Pii0 = pi0;
        
      (* Replace with Pii0 = pi0^2 for HWE case *)
        
      (* Replace with Pii0 = Max[0, (2*pi0) - 1] for Min homozygosity case *)
        
      (* Extra constraint for Pii0 to ensure that Pii0*M, the number of homozygotes in the population,
        is an integer *)
        
      If[(Pii0 = Max[0, (2*pi0) - 1]) && (Pii0 = pi0) && (Head[Pii0*M] == Integer),
          
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
      
    For[j = 1, j = (2*M), j++, 
      pi0 = j/(2*M);
        
      If[(pi0 = (yiNobs/(2*M))) && (pi0 = (1 - (((2*NN) - yiNobs)/(2*M)))),
          
        (* Max homozygosity case *)
          
        Pii0 = pi0;
          
        (* Replace with Pii0 = pi0^2 for HWE case *)
          
        (* Replace with Pii0 = Max[0, (2*pi0) - 1] for Min homozygosity case *)
          
                     
        If[(Pii0 = Max[0, (2*pi0) - 1]) && (Pii0 = pi0) && (Head[Pii0*M] == Integer),
            
          If[yiNobs < Output[[Outputcounter, 3]],
              
            Sumprob = 0.0;
              
            For[m = 0, m = (yiNobs - 1), m++, 
              Sumprob = Sumprob + pmfSamplingDistYiN[M, NN, pi0[[j]], Pii0[[j]], m];
                
            ];
              
            AppendTo[largestalphaList, Sumprob*2];
              
          ];
            
          If[yiNobs > Output[[Outputcounter, 4]],
              
            Sumprob2 = 0.0;
              
            For[m = (2*NN), m = (yiNobs + 1), m--,
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
      
    For[j = 1, j = Length[largestalphaList], j++,
        
      If[largestalphaList[[j]] > alphaMax, alphaMax = largestalphaList[[j]]; alphaMaxIndex = j];
          
    ];
      
    (* Define lower and upper limits for pi and Pii given largest alpha *)
      
    piCIlowerlimit = Output[[alphaMaxIndex, 1]];
      
    piCIupperlimit = Output[[alphaMaxIndex, 1]];
      
  ];
    
    

  Return[{piCIlowerlimit, piCIupperlimit}];
    
    
];
```

### CIforpiCasePiiKnown example
```
(* Example Run and Outputs *)
CIforpiCasePiiKnown[438, 53, 1, 0.05/3] // Timing
{8.96702 Second, {0.00228311, 0.0799087}}
```