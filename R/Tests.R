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
X1 = matrix(rnorm((10 * 5), mean = 0, sd = 1), nrow = 10, ncol = d)
X2 = matrix(rnorm((10 * 5), mean = 4, sd = 1), nrow = 10, ncol = d)
X3 = matrix(rnorm((10 * 5), mean = 8, sd = 1), nrow = 10, ncol = d)
X = rbind(X1, X2, X3)

detect_multiple_cp(X = X, numcp = 2, dist.method = "average")
#
# source("SingleChangePoint.R")
#
# source("MultipleChangePoint_NumKnown.R")

