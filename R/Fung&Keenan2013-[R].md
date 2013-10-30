<center>
Fung & Keenan 2013: Description of R functions used to calculate  confidence intervals
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
This document describes the functionality of the R code converted from the _Mathematica_ code used in Fung & Keenan 2013. The code was written and tested using _Mathematica_ v5.0[1] and subsequently converted and tested in `R`. This document describes four separate function named, `pmfSamplingDistYiN`, `AcceptanceRegion`, `CIforpiCasePiiUnknown` and `CIforpiCasePiiknown`. The original _Mathematica_ version of this workbook can be found @ http://rpubs.com/kkeenan02/Fung-Keenan-Mathematica

## pmfSamplingDistYiN
This function returns $P(Y_{i,N} = y_{i,N})$ as specified by equation (9) in the main text, given $M$, $N$, $p_{i}$, $P_{ii}$ and $y_{i,n}$. Here, $Y_{i,N}$ is the random variable specifying the number of copies of allele $A_{i}$ in a sample of size $N$ taken from a finite diploid population of size $M$, with the frequency of allele $A_{i}$ in the population being $p_{i}$ and the frequency of homozygotes of allele $A_{i}$ in the population being $P_{ii}$.




### pmfSamplingDistYiN source code (`R`)

```r
pmfSamplingDistYiN <- function(M, NN, p_i, P_ii, yiN){
  MaxFunc <- max((yiN/2) - (M*p_i) + (M*P_ii), yiN - NN, 0)
  MinFunc <- min(M*P_ii, yiN/2, M-NN+yiN-(2*M*p_i)+(M*P_ii))
  LowerBound <- ceiling(MaxFunc)
  UpperBound <- floor(MinFunc)
  
  # Calculate P(YiN = yiN) according to eqn 9
  Numerator1 <- 0
  
  for(i in LowerBound:UpperBound){
    Summand <- choose(M*P_ii, i)*choose(2*M*(p_i-P_ii), yiN-(2*i))*
      choose(M+(M*P_ii)-(2*M*p_i), NN+i-yiN)
    Numerator1 <- Numerator1 + Summand
  }
  
  probOut <- Numerator1/choose(M, NN)
  return(probOut)
}
```


### pmfSamplingDistYiN example

```r
# test timing
system.time(res <- pmfSamplingDistYiN(1000, 10, 0.1, 0.04, 1))
```

```
   user  system elapsed 
      0       0       0 
```

```r
# print results
print(res)
```

```
[1] 0.250394
```


## AcceptanceRegion
This function tests the null hypothesis $H_{o}:p_{i}=p_{i,0}, P_{ii}=P_{ii,0}$ for an observed value of $y_{i,N}$, $latex \hat{y}_{i,N}$, given the sampling scenario considered. It does this by calculating the acceptance region for a specified significance level, $latex \alpha$, and then determining whether $latex \hat{y}_{i,N}$ lies within this region. The outputs are bounds of the acceptance region and an indication of whether $latex \hat{y}_{i,N}$ falls within this region or not ('1' == TRUE, '0' == FALSE, respectively).


### AcceptanceRegion source code (`R`)

```r
AcceptanceRegion <- function(M, NN, p_i0, P_ii0, yiNobs, alpha){
  
  # find the lower bound of the acceptance region
  SumProb <- 0
  yiNlow <- 0
  dummy1 <- 0
  while(SumProb <= (alpha/2)){
    dummy1 <- pmfSamplingDistYiN(M, NN, p_i0, P_ii0, yiNlow)
    SumProb <- SumProb + dummy1
    yiNlow <- yiNlow + 1
  }
  yiNlow <- yiNlow - 1
  dummy1 <- pmfSamplingDistYiN(M, NN, p_i0, P_ii0, yiNlow)
  SumProb <- SumProb - dummy1
  # find the upper bound of the acceptance region
  SumProb2 <- 1
  yiNup <- 2*NN
  while(SumProb2 >= (1-(alpha/2))){
    dummy1 <- pmfSamplingDistYiN(M, NN, p_i0, P_ii0, yiNup)
    SumProb2 <- SumProb2 - dummy1
    yiNup <- yiNup - 1
  }
  yiNup <- yiNup + 1
  dummy1 <- pmfSamplingDistYiN(M, NN, p_i0, P_ii0, yiNup)
  SumProb2 <- SumProb2 + dummy1
  # Test if yiNobs is with in the accptance region
  test <- yiNobs >= yiNlow && yiNobs <= yiNup
  out <- list(lowerbound = yiNlow, 
              upperbound = yiNup,
              result = test)
  return(unlist(out))
}
```


### AcceptanceRegion example

```r
# test timing
system.time(res <- AcceptanceRegion(1000, 30, 0.625, 0.25, 50, 0.05))
```

```
   user  system elapsed 
      0       0       0 
```

```r
# print results
print(res)
```

```
lowerbound upperbound     result 
        33         42          0 
```


## CIforpiCasePiiUnknown
This function calculates $latex \geq 100(1-\alpha) %$ confidence intervals (CI's) for $p_i$ and $P_{ii}$ given $M$, $N$ and $latex \hat{y}_{i,N}$. These CI's are computed using equation (14a) and (14b) in the main text, and uses `pmfSamplingDistYiN` and `AcceptanceRegion`. The outputs are the lower and upper limits of the CI for $p_i$ followed by those of the CI for $P_{ii}$.

### CIforpiCasePiiUnknown source code (`R`)

```r
CIforpiCasePiiUnknown <- function(M, NN, yiNobs, alpha){
  pi0List <- vector()
  Pii0List <- vector()
  out <- matrix()
  i = 0
  while(i  <= (2*M)){
    p_i0 <- i/(2*M)
    if((p_i0 >= (yiNobs/(2*M))) && (p_i0 <= (1 - (((2*NN)-yiNobs)/(2*M))))){
      k=0
      while(k <= i){
        P_ii0 <- k/(2*M)
        if((P_ii0 >= max(0, (2*p_i0)-1)) && (P_ii0 <= p_i0)){
          out1 <- AcceptanceRegion(M, NN, p_i0, P_ii0, yiNobs, alpha)
          if(out1[3] == 1L){
            pi0List <- c(pi0List, p_i0)
            Pii0List <- c(Pii0List, P_ii0)
          }
          out2 <- c(out1,p_i0, P_ii0)
          if(all(is.na(out))){
            out <- out2
          } else{
            out <- rbind(out, out2) 
          }
        }
        k <- k + 1
      }
    }
    i <- i + 1
  }
  if(length(pi0List) > 0){
    piCIlow <- min(pi0List)
    piCIup <- max(pi0List)
    PiiCIlow <- min(Pii0List)
    PiiCIup <- max(Pii0List)
  } else if(length(pi0List) == 0){
    largestAlpha <- 0
    outCounter <- 1
    while(i <= (2*M)){
      p_i0 <- i/(2*M)
      if((p_i0 >= (yiNobs/(2*M))) && (p_i0 <= (1 - (((2*NN)-yiNobs)/(2*M))))){
        while(k <= i){
          P_ii0 <- k/(2*M)
          if((P_ii0 = max[0, (2*p_i0) - 1]) && (P_ii0 = p_i0)){
            if(yiNobs < out[outCounter, 1]){
              Sumprob <- 0
              m = 0
              while(m <= (yiNobs - 1)){
                Sumprob <- Sumprob + pmfSamplingDistYiN(M, NN, p_i0List[i],
                                                        P_ii0List[i], m)
                m <- m + 1
              }
              largestAlpha <- c(largestAlpha, Sumprob*2) 
            }
            if(yiNobs > out[outCounter, 2]){
              Sumprob2 <- 0
              m = (2*NN)
              while(m >= (yiNobs +1)){
                Sumprob2 <- Sumprob2 + pmfSamplingDistYiN(M, NN, p_i0List[i],
                                                          P_ii0List[i], m)
                m <- m - 1
              }
              largestAlpha <- c(largestAlpha, Sumprob2*2)
            }            
          }
          outCounter <- outCounter + 1
        }
      }
    }
    alphaMax <- -1
    alphaMaxIdx <- -1
    j = 1
    while(j <= length(largestAlpha)){
      if(largestAlpha[j] > alphaMax){
        alphaMax <- largestAlpha[j]
        alphaMaxIdx <- j
      }
      j <- j+1
    }
    piCIlow <- out[alphaMaxIdx, 4]
    piCIup <- piCIlow
    PiiCIlow <- out[alphaMaxIdx, 5]
    PiiCIup <- out[alphaMaxIdx, 5]
  }
  list(piCI = c(piCIlow, piCIup), 
       PiiCI = c(PiiCIlow, PiiCIup))
}
```


### CIforpiCasePiiUnknown example

```r
# test timing
system.time(res <- CIforpiCasePiiUnknown(100, 30, 5, 0.05))
```

```
   user  system elapsed 
  57.00    0.04   58.32 
```

```r
# print results
print(res)
```

```
$piCI
[1] 0.025 0.200

$PiiCI
[1] 0.000 0.195
```


## CIforpiCasePiiKnown

This function a $latex \geq 100(1-\alpha)% $ CI for $p_{i}$, given $M$, $N$ and
$latex \hat{y}_{i,N}$, for a population with maximum homozygosity ($p_{i}=P_{ii}$). The function uses equation (13) in the main text to calculate the CI, and uses `pmfSamplingDistYiN` and `AcceptanceRegion`. The outputs are the lower and upper bounds for the CI. The code of `CIforpiCasePiiKnown` can be easily adapted to calculate CI's under the scenario of HWE or the Scenario of minimum homozygosity, by altering two lines indicated within the code.

### CIforpiCasePiiKnown source code (`R`)

```r
CIforpiCasePiiKnown <- function(M, NN, yiNobs, alpha){
  out <- matrix()
  pi0List <- vector()
  i <- 0
  while(i <= (2*M)){
    p_i0 <- i/(2*M)
    if((p_i0 >= (yiNobs/(2*M))) && (p_i0 <= (1-(((2*NN)-yiNobs)/(2*M))))){
      # Max homoxygosity (Pii0 <- pi0)
      # HWE (Pii0 <- pi0^2)
      # Min homozygosity (Pii0 <- max(0, (2^pi0)-1))
      P_ii0 <- p_i0
      # make sure Pii * M is an integer
      if((P_ii0 >= max(0, (2*p_i0)-1)) && (P_ii0 <= p_i0) && (P_ii0*M == as.integer(P_ii0*M))){
        out1 <- AcceptanceRegion(M, NN, p_i0, P_ii0, yiNobs, alpha)
        if(out1[3] == 1L){
          pi0List <- c(pi0List, p_i0)
          out2 <- c(out1 , p_i0, P_ii0) 
          if(all(is.na(out))){
            out <- out2
          } else{
            out <- rbind(out, out2) 
          }
        }
      }
    }
    i <- i+1
  }
  if(length(pi0List) > 0){
    piCIlow <- min(pi0List)
    piCIup <- max(pi0List)
  } else if(length(pi0List) == 0){
    largestAlpha <- 0
    outCounter <- 1
    i <- 1
    while(i <= (2*M)){
      p_i0 <- i/(2*M)
      if((p_i0 >= (yiNobs/(2*M))) && (p_i0 <= (1- (((2*NN)-yiNobs)/(2*M))))){
        # Max homoxygosity (Pii0 == pi0)
        # HWE (Pii0 == pi0^2)
        # Min homozygosity (Pii0 == max(0, (2^pi0)-1))
        P_ii0 <- p_i0
        # make sure Pii * M is an integer
        if((P_ii0 >= max(0, (2*p_i0)-1)) && (P_ii0 <= p_i0) && (P_ii0*M == as.integer(P_ii0*M))){
          if(yiNobs <= out[outCounter, 1]){
            Sumprob <- 0
            m <- 0
            while(m <= (yiNobs - 1)){
              Sumprob <- Sumprob + pmfSamplingDistYiN(M, NN, p_i0List[i],
                                                      P_ii0List[i], m)
              m <- m+1
            }
            largestAlpha <- c(largestAlpha, Sumprob*2) 
          }
          if(yiNobs > out[largestAlpha, 2]){
            Sumprob2 <- 0
            m <- (2*NN)
            while(m >= (yiNobs + 1)){
              Sumprob2 <- Sumprob2 + pmfSamplingDistYiN(M, NN, p_i0List[i],
                                                        P_ii0List[i], m)
              m <- m - 1
            }
            largestAlpha <- c(largestAlpha, Sumprob2*2)
          }
          outCounter <- outCounter + 1
        }
      }
      i <- i + 1
    }
    alphaMax <- -1
    alphaMaxIdx <- -1
    j <- 1
    while(j <= length(largestAlpha)){
      if(largestAlpha[j] > alphaMax){
        alphaMax <- largestAlpha[j]
        alphaMaxIdx <- j
      }
      j <- j + 1
    }
    piCIlow <- out[alphaMaxIdx, 4]
    piCIup <- piCIlow
  }
  res <- list(piCIlower = piCIlow,
              piCIupper = piCIup)
  return(unlist(res))
}  
```


### CIforpiCasePiiKnown example

```r
# test timing
system.time({res <- CIforpiCasePiiKnown(438, 53, 1, 0.05/3)})
```

```
   user  system elapsed 
   1.96    0.00    1.98 
```

```r
# print results
print(res)
```

```
 piCIlower  piCIupper 
0.00228311 0.07990868 
```
