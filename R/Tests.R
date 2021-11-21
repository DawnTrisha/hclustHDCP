test1 = function(a)
{
  if(a == "ori")
  {
    x = 1
  }else{
    x = 0
  }

  return(x)
}

test1("wgt")

d = 5
X1 = mvtnorm::rmvnorm(10, mean = rep(0, d), sigma = diag(d))
X2 = mvtnorm::rmvnorm(10, mean = rep(4, d), sigma = diag(d))
X3 = mvtnorm::rmvnorm(10, mean = rep(8, d), sigma = diag(d))
X = rbind(X1, X2, X3)

detect_multiple_cp(X = X, numcp = 2, dist.method = "average")

#source("SingleChangePoint.R")

#source("MultipleChangePoint_NumKnown.R")

