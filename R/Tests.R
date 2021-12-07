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

# Multiple change-point
d = 5
X1 = matrix(rnorm((5 * 5), mean = 0, sd = 1), nrow = 5, ncol = d)
X2 = matrix(rnorm((5 * 5), mean = 4, sd = 1), nrow = 5, ncol = d)
X3 = matrix(rnorm((5 * 5), mean = 8, sd = 1), nrow = 5, ncol = d)
X = rbind(X1, X2, X3)

D = as.matrix(dist(X, method = "euclidean"))

detect_estimated_cp(D = D, p = d)

# Single change-point
d = 5
X1 = matrix(rnorm((5 * 5), mean = 0, sd = 1), nrow = 5, ncol = d)
X2 = matrix(rnorm((5 * 5), mean = 4, sd = 1), nrow = 5, ncol = d)
X = rbind(X1, X2)

D = as.matrix(dist(X, method = "euclidean"))


# Check if MADD or gen MADD works
X1 = matrix(rnorm((10*15), mean = 0, sd = 2), nrow = 10, ncol = 15)
X2 = matrix(stats::rt(10*15, df = 4, ncp = 0),nrow = 10, ncol = 15)
X = rbind(X1, X2)

D = distmat_HDLSS(X = X, option = "genMADD")
detect_single_cp(D = D)

detect_estimated_cp(D = D, p = 15)

# Example in documentation for single chnage-point
X1 = matrix(rnorm((15 * 50), mean = 0, sd = 1), nrow = 15, ncol = 50)
X2 = matrix(rnorm((15 * 50), mean = 4, sd = 1), nrow = 15, ncol = 50)
X = rbind(X1, X2)

detect_single_cp(X = X)
detect_single_cp(X = X, dist.method = "single")

# Example in documentation for single chnage-point
X1 = matrix(rnorm((15 * 50), mean = 0, sd = 1), nrow = 15, ncol = 50)
X2 = matrix(rnorm((15 * 50), mean = 1, sd = 1), nrow = 15, ncol = 50)
X3 = matrix(rnorm((15 * 50), mean = 2, sd = 1), nrow = 15, ncol = 50)
X = rbind(X1, X2, X3)

detect_multiple_cp(X = X, numcp = 2)
detect_multiple_cp(X = X, numcp = 4, dist.method = "complete")


X1 = matrix(rnorm((15 * 50), mean = 0, sd = 1), nrow = 15, ncol = 50)
X2 = matrix(rnorm((15 * 50), mean = 1, sd = 1), nrow = 15, ncol = 50)
X3 = matrix(rnorm((15 * 50), mean = 2, sd = 1), nrow = 15, ncol = 50)
X = rbind(X1, X2, X3)

detect_multiple_cp(X = X, numcp = 2)
detect_multiple_cp(X = X, numcp = 4, dist.method = "complete")

X1 = matrix(rnorm((15 * 200), mean = 0, sd = 1), nrow = 15, ncol = 200)
X2 = matrix(rnorm((15 * 200), mean = 5, sd = 1), nrow = 15, ncol = 200)
X3 = matrix(rnorm((15 * 200), mean = 10, sd = 1), nrow = 15, ncol = 200)
X = rbind(X1, X2, X3)

detect_estimated_cp(X = X)
detect_estimated_cp(X = X, dist.method = "complete")
