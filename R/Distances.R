# Calculation of MADD distance and generalized MADD distance matrix
# Number of observations considered
# n = nrow(X)

# Calculation of Mean Absolute Deviation of Distances (MADD) between two observations (two vectors here)
# Y here stands for the observations except the two vectors between which the distance is calculated
MADD_dist = function(n, u, v, Y)
{

  temp = 0

  for(k in 1:(n-2))
  {
    d1 = 0
    d2 = 0

    # Euclidean Distance between u and other observations
    d1 = stats::dist(as.matrix(rbind(u,Y[k,])), method = "euclidean")
    # Euclidean Distance between v and other observations
    d2 = stats::dist(as.matrix(rbind(v,Y[k,])), method = "euclidean")

    # Sum of absolute differences
    temp = temp + abs(d1 - d2)
  }

  # Mean of the absolute deviation of distances
  dist = (1/(n-2))*temp

  # Returning the distance
  return(as.vector(dist))
}

# Calculation of MADD distance matrix
MADD_distmat = function(X)
{
  # Number of observations
  n = nrow(X)

  # Initialization of distance matrix to which value will be stored
  dist_matrix = array(0, dim = c(n,n))

  # For any observation
  for(i in 1:(n-1))
  {
    # Fix that observations
    u = X[i,]

    # Run the loop for all the other observations
    for(j in (i+1):n)
    {
      # Other observations
      v = X[j,]
      # Other observations eliminating the two chosen observations
      Y = X[-c(i,j),]

      # Call the MADD_dist function between the two observations
      dist_matrix[i,j] = (MADD_dist(n, u, v, Y))^2
      # Since symmetric
      dist_matrix[j,i] = dist_matrix[i,j]
    }
  }

  # Return distance matrix
  return(dist_matrix)
}

#######################################################

# Code for generalized distance function to be used instead of Euclidean distance during the calculation of MADD distance
# x, y : be two observations
# d : dimension of x and y
gen_f = function(x, y, d)
{
  h = sum(1 - exp(-abs(x - y)))/d

  # Returning scalar h
  return(h)
}

# Calculation of generalized MADD distance between two observations
gen_MADD_dist = function(n, u, v, Y)
{

  temp = 0

  for(k in 1:(n-2))
  {
    d1 = 0
    d2 = 0

    # Generalized Distance between u and other observations
    d1 = gen_f(u, Y[k, ], length(u))
    # Generalized Distance between v and other observations
    d2 = gen_f(v, Y[k, ], length(v))

    # Sum of absolute differences
    temp = temp + abs(d1 - d2)
  }

  # Mean of the absolute deviation of distances
  dist = (1/(n-2))*temp

  # Returning the distance
  return(as.vector(dist))
}

# Calculation of Generalized MADD distance matrix
genMADD_distmat = function(X)
{
  # Number of observations
  n = nrow(X)

  # Initialization of distance matrix to which value will be stored
  dist_matrix = array(0, dim = c(n,n))

  # For any observation
  for(i in 1:(n-1))
  {
    # Fix that observations
    u = X[i,]

    # Run the loop for all the other observations
    for(j in (i+1):n)
    {
      # Other observations
      v = X[j,]
      # Other observations eliminating the two chosen observations
      Y = X[-c(i,j),]

      # Call the MADD_dist function between the two observations
      dist_matrix[i,j] = (gen_MADD_dist(n, u, v, Y))^2
      # Since symmetric
      dist_matrix[j,i] = dist_matrix[i,j]
    }
  }

  # Return distance matrix
  return(dist_matrix)
}

# To construct distance matrix using MADD or generalized MADD
# MADD distance or Generalized MADD distance matrix to accommodate change in
# higher order marginals in High Dimensional Low Sample Size (HDLSS) situation
#' Distance matrix calculation using Mean Absolute Deviation of Distances (genMADD or MADD distance)
#'
#' @param X Data matrix (n X p) where n denotes number of observations. Each row is a p dimensional observation vector.
#' @param option Distance function to use. Should be one of "genMADD" or "MADD". The default is "genMADD". For the exact mathematical form of the distance functions, refer to the vignette or \url{https://ieeexplore.ieee.org/document/8695805}
#'
#' @return Returns a (n X n) matrix containing the distance between the observations.
#' @export
#'
#' @examples
#' set.seed(1)
#' # Generating n = 10 observations from t distribution with dimension p = 5
#' X = matrix(stats::rt((10*5), ncp = 0, df = 4), nrow = 10, ncol = 5)
#'
#' # Distance matrix
#' D_mat1 = distmat_HDLSS(X = X) # using default generalized MADD distance ("genMADD")
#' D_mat2 = distmat_HDLSS(X = X, option = "MADD") # using MADD distance ("MADD")
distmat_HDLSS = function(X, option = c("genMADD","MADD"))
{
  option = match.arg(option)

  # Asks user if want to use MADD or generalized MADD
  if(option == "genMADD"){
    return(genMADD_distmat(X))
  }else{
    return(MADD_distmat(X))
  }
}
