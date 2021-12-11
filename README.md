
# R Package - hclustHDCP

# Description

This package deals with one of the classical problem in statistics,
called change-point detection method. It attempts to detect abrupt
significant changes in probability distributions for a sequence of
observations arranged in chronological order. We implement change-point
detection for high dimensional observations. This method detects
change-points based on hierarchical clustering. The algorithm initially
considers each observation as a cluster and at each subsequent step
merges two closest consecutive clusters based on linkages (single,
average or complete). Hence the number of clusters decreases by one in
each step of the algorithm. In case the number of change-points to be
detected is known, the algorithm stops when the desired number of
clusters is reached. It returns the change-point locations where the
cluster membership changes. However, if the number of change-points to
detect is unknown, then we make use of some clustering evaluation
algorithm like Penalized Dunn index to estimate optimal number of
change-points. Here we also implement the algorithm using a different
distance function, called the mean absolute deviation of distances (MADD
distance) instead of usual Euclidean distance while calculating the
linkage methods. This enables the method to perform well in low sample
size situations as well for most of the occasions. Specifically when the
changes in the observations are not in one dimensional marginal
distributions and usual Euclidean distance fails to retain the
neighbouhood structure of the observations.

# Installation Instruction

devtools::install\_github(“DawnTrisha/hclustHDCP”)

# Use of the functions

As described earlier this package is intended to detect change-points
specially in high dimensional low sample size regime when the changes
are beyond mean change of the observations. There are three functions
available for change-point detection and one function for calculating
distance matrix using some different dissimilarity measures. First we
illustrate how to use *distmat\_HDLSS* since it can be used with
combination with other functions.

## distmat\_HDLSS :

Mean absolute deviation of distances(MADD) is used using Euclidean
distance as well as more generalized distance function to construct
distance matrix.

``` r
library(hclustHDCP)
set.seed(1)
# Generating n = 10 observations from t distribution with dimension p = 5
X = matrix(stats::rt((10*5), ncp = 0, df = 4), nrow = 10, ncol = 5)

# Distance matrix
D_mat1 = distmat_HDLSS(X = X) # using default generalized MADD distance ("genMADD")
D_mat2 = distmat_HDLSS(X = X, option = "MADD") # using MADD distance ("MADD")
```

Now we note that we need to consider the following points while using
the functions,

-   The user need to enter either the data matrix (X) or the distance
    matrix (D).

-   The function by default uses Euclidean distance to implement the
    algorithm.

-   If the one wants to use *genMADD distance* or *MADD distance*, use
    *distmat\_HDLSS* function to first compute the distance matrix and
    then supply the distance matrix to the function *detect\_single\_cp*
    (See Example 2).

## detect\_single\_cp :

Detects single change-point in a data sequence arranged chronologically.
Here are the points to consider while using the function

``` r
# Example 1
set.seed(1)
# Generate data matrix
X1 = matrix(rnorm((15 * 50), mean = 0, sd = 1), nrow = 15, ncol = 50)
X2 = matrix(rnorm((15 * 50), mean = 4, sd = 1), nrow = 15, ncol = 50)
X = rbind(X1, X2)

detect_single_cp(X = X)  # Detect single change-point with default average linkage
```

    ## [1] 15

``` r
detect_single_cp(X = X, dist.method = "single") # Detect single change-point with single linkage
```

    ## [1] 15

``` r
# Example 2
set.seed(1)
# Generate data matrix
X1 = matrix(rnorm((15 * 50), mean = 0, sd = 1), nrow = 15, ncol = 50)
X2 = matrix(rnorm((15 * 50), mean = 4, sd = 1), nrow = 15, ncol = 50)
X = rbind(X1, X2)

# Distance matrix (MADD distance)
D_mat = distmat_HDLSS(X = X, option = "MADD")

detect_single_cp(D = D_mat, dist.method = "complete")  # Detect single change-point with MADD distance matrix and complete linkage
```

    ## [1] 15

## detect\_multiple\_cp :

Detects multiple change-points in a data sequence arranged
chronologically. Here also we need to consider the same three points
that we used for detect\_single\_cp function. Additionally we also need
to supply the number of change-points to detect (1 &lt; numcp &lt; n).
Here is an illustration.

``` r
# Example 3
set.seed(1)
# Generate data matrix
X1 = matrix(rnorm((15 * 50), mean = 0, sd = 1), nrow = 15, ncol = 50)
X2 = matrix(rnorm((15 * 50), mean = 1, sd = 1), nrow = 15, ncol = 50)
X3 = matrix(rnorm((15 * 50), mean = 2, sd = 1), nrow = 15, ncol = 50)
X = rbind(X1, X2, X3)

# Detect two change-points with default average linkage
detect_multiple_cp(X = X, numcp = 2)
```

    ## [1] 15 30

``` r
# Distance matrix (genMADD distance)
D_mat = distmat_HDLSS(X = X, option = "MADD")

# Detect two change-points with default average linkage
detect_multiple_cp(D = D_mat, numcp = 2)
```

    ## [1] 15 30

## detect\_estimated\_cp :

This function is used to detect change-point(s) in a data sequence
arranged over time. The difference with the previous functions is that
the user need not supply the number of change-points to detect which is
a more realistic situation. Here also we need to consider the three
points that we considered at the beginning. Additionally we also need to
supply the dimension of the observations if distance matrix is used as
input instead of data matrix. Here is an illustration.

``` r
# Example 4
set.seed(1)
# Generate data matrix
X1 = matrix(rnorm((15 * 200), mean = 0, sd = 1), nrow = 15, ncol = 200)
X2 = matrix(rnorm((15 * 200), mean = 5, sd = 1), nrow = 15, ncol = 200)
X3 = matrix(rnorm((15 * 200), mean = 10, sd = 1), nrow = 15, ncol = 200)
X = rbind(X1, X2, X3)

# Detect change-points with default average linkage without supplying distance matrix
detect_estimated_cp(X = X)
```

    ## [1] 15 30

``` r
# Calculation of distance matrix
D_mat = as.matrix(stats::dist(X, method = "euclidean"))

# Data matrix is used so supply the dimension of the data
detect_estimated_cp(D = D_mat, p = 200)
```

    ## [1] 15 30

We note that the **detect\_estimated\_cp** also uses penalty parameter
*λ* = 0.02 as the default value to be used in penalized Dunn index. The
value of the parameter is supplied based on the empirical studies (when
the change is beyond mean change) and expected to provide good result.
However, the user can change it if required. For example in example 4,

``` r
# Data matrix is used so supply the dimension of the data
detect_estimated_cp(D = D_mat, p = 200, lambda = 0.1)
```

    ## [1] 15 30
