<center>
Supporting Webpage 2a for Fung & Keenan (2014): A Description of an amended version of the function `pmfSamplingDistYiN`, allowing the use of big integers
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
This document describes the functionality of an amended version of the `pmfSamplingDistYiN` function from [Fung & Keenan, (2014)](http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0085925), originally described [here](http://rpubs.com/kkeenan02/Fung-Keenan-R). The amended version, `pmfSamplingDistYiN_2` uses the package, [`gmp`](http://cran.stat.ucla.edu/web/packages/gmp/index.html), when calculating binomial coefficients to allow for the use of `bigz` integer variables, for which `choose` generally returns `Inf`.

This difference is demonstrated in the below code for the example:
    $$latex \binom{5000}{600}$$
    
In the original function, `pmfSamplingDistYiN_2`, this would be resolved as follows:    

```r
# use the base function, choose
choose(5000, 600)
```

```
[1] Inf
```

We can see that choose returns the value `Inf` (infinity) for this calculation. The reason for this is within the `choose` function one of the calculations results in an integer larger than `R` can represent (The current version of `R` still uses 32bit for integer storage, independent of system architecture), thus the function returns `Inf`.

To solve this limitation, we have implemented the use of `bigz` variables as defined in the `gmp` package. The new method for the calculation of binomial coefficients is as follows:


```r
# load gmp package for large interger conversion
library(gmp)

# define a recursive function to calculate the binomial coefficinet
BinomCoeff <- function(nn,rr){
  if(rr==0 || rr==nn){
    return(1)
  }
  # Recur
  return(BinomCoeff(nn-1, rr-1)*(nn/rr))
}

# implement the function using bigz variables
coef <- BinomCoeff(as.bigz(5000), as.bigz(600))
# test that the output of BinomCoeff is numeric
asNumeric(coef/coef)
```

```
[1] 1
```


From this simple test, we see that dividing the output from `BinomCoeff` by itself and converting the output back into a standard integer we get 1. If we tried to divide `Inf ` by `Inf` in `R` we would get `NaN`.

Now that we are able to calculate the binomial coefficient for very large expansion terms, we can incorporate the method into the new function, `pmfSamplingDistYiN_2`.

#### `pmfSamplingDistYiN_2` source code (`R`)


```r
# New version of pmfSamplingDistYiN that works for large integers
pmfSamplingDistYiN_2 <- function(M, NN, p_i, P_ii, yiN){
  # define the big integer choose function
  BinomCoeff <- function(nn,rr){
  if(rr==0 || rr==nn){
    return(1)
  }
  # Recur
  return(BinomCoeff(nn-1, rr-1)*(nn/rr))
  }
  # check for gmp package and install if needed
  if("gmp" %in% rownames(installed.packages()) == FALSE){ 
  install.packages("gmp", repo = "http://cran.rstudio.com",
                   dep = TRUE)
  }
  library("gmp")
  MaxFunc <- max((yiN/2) - (M*p_i) + (M*P_ii), yiN - NN, 0)
  MinFunc <- min(M*P_ii, yiN/2, M-NN+yiN-(2*M*p_i)+(M*P_ii))
  LowerBound <- ceiling(MaxFunc)
  UpperBound <- floor(MinFunc)
  # Calculate P(YiN = yiN) according to eqn 9
  Numerator1 <- 0
  for(i in LowerBound:UpperBound){
    Summand <- BinomCoeff(as.bigz(M*P_ii), as.bigz(i))*BinomCoeff(as.bigz(2*M*(p_i-P_ii)), as.bigz(yiN-(2*i)))*BinomCoeff(as.bigz(M+(M*P_ii)-(2*M*p_i)), as.bigz(NN+i-yiN))
    
    Numerator1 <- Numerator1 + Summand
  }
  
  probOut <- Numerator1/BinomCoeff(as.bigz(M), as.bigz(NN))
  return(asNumeric(probOut))
}
```


#### Testing `pmfSamplingDistYiN_2`
Below are a few simple tests to ensure that `pmfSamplingDistYiN_2` returns the same results as `pmfSamplingDistYiN` (for instances where `choose` can calculate the binomial coefficient).





```r
# Check that the output of both functions is the same for suitable integers
# test 1_a
pmfSamplingDistYiN(1000, 10, 0.1, 0.04, 1)
```

```
[1] 0.250394
```

```r
pmfSamplingDistYiN_2(1000, 10, 0.1, 0.04, 1)
```

```
[1] 0.250394
```

```r
# test 1_b
pmfSamplingDistYiN(1000, 50, 0.05, 0.02, 1)
```

```
[1] 0.0477062
```

```r
pmfSamplingDistYiN_2(1000, 50, 0.05, 0.02, 1)
```

```
[1] 0.0477062
```

We can clearly see that both functions return identical results.

We can also see compare how both function behave when large sample sizes (`NN`) are used.


```r
# Check that pmfSamplingDistYiN_2 will work for large integers
# test 2_a
pmfSamplingDistYiN(5000, 600, 0.02, 0.02^2, 0)
```

```
[1] NaN
```

```r
pmfSamplingDistYiN_2(5000, 600, 0.02, 0.02^2, 0)
```

```
[1] 5.8865e-12
```

```r
# test 2_b
pmfSamplingDistYiN(10000, 1000, 0.01, 0.01^2, 0)
```

```
[1] NaN
```

```r
pmfSamplingDistYiN_2(10000, 1000, 0.01, 0.01^2, 0)
```

```
[1] 6.27832e-10
```

