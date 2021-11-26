# Calculation of MADD distance and generalized MADD distance between two vectors

# Number of observations considered
n = nrow(X)

# Calculation of Mean Absolute Deviation of Distances (MADD) between two observations (two vectors here)
# Y here stands for the observations except the two vectors between which the distance is calculated
MADD_dist = function(u,v,Y)
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

