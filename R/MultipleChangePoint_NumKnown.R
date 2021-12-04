# Function to detect Single Change Point when it is known that only one change point exists

# Inputs:
# Data matrix X (n X d) : whose rows are the d dimensional observations
# dist.method : Linkage method to be used in the hierarchical clustering (single, average or complete)
# numcp : Number of change-points to be detected (should be more than 1)

# Output:
# detectcp: Detected location vector for detected multiple change-points
#' Detecting multiple change-point locations for known number of change-points
#'
#' @param X Data matrix (n X p) where n denotes number of observations. Each row is a p dimensional observation vector. n observations are arranged in chronological order.
#' @param D Distance matrix (n X n) corresponding to the data matrix. Either the data matrix or the distance matrix should be supplied.
#' @param numcp Number of change-points to detect
#' @param dist.method Linkage method to use in hierarchical clustering for calculating the distances between consecutive clusters. This must be one of "single", "average" or "complete". Default is "average".
#'
#' @return Returns a numeric vector denoting estimated change-point locations
#' @export
#'
#' @examples
detect_multiple_cp = function(X = NULL, D = NULL, numcp, dist.method = "average")
{
  # Check if either X or D is supplied or not
  if((is.null(X) == TRUE) && (is.null(D) == TRUE))
  {
    stop("Supply either data matrix or distance matrix")
  }

  # Check if Distance matrix is supplied or not, if supplied
  if(is.null(D) == FALSE)
  {
    if(nrow(D) != ncol(D))
    {
      stop("Incorrect supplied distance matrix")
    }

    dist_mat = D
  }else{
    # Calculate distance matrix
    dist_mat = as.matrix(stats::dist(X), method = "euclidean")
  }

  # Number of observations
  n = nrow(dist_mat)

  # Compatibility check if numcp greater than 1 and less than n
  if((numcp == 1) || (numcp >= n))
  {
    stop("Incorrect number of change-points to detect.")
  }




  # Initialize the matrix with zeroes which will monitor merging of clusters
  trackclust_mat = matrix(0, n, n)

  # At initial stage one observation corresponds to one cluster
  trackclust_mat[1, ] = 1:n

  # Running loop till n - (numcp + 1) (since desired number of clusters is numcp + 1)
  for(j in 1:(n - (numcp + 1)))
  {
    # Since at each stage the number of clusters decreases by 1
    l = n - j

    # looking at current stage of number of clusters
    current_track = trackclust_mat[j, ]

    # Calculating linkage distances
    # loop till 1:l at each stage because we need to work with two consecutive clusters at a time
    link_dist = sapply(1:l, function(i) {

      # Considering two consecutive clusters at a time
      # One cluster index
      clust_index_1 = current_track[i]:(current_track[i+1]-1)
      # Immediate next cluster index
      clust_index_2 = current_track[i+1]:(ifelse( i < l, current_track[i+2] - 1, n))

      # Distance between the two consecutive clusters

      if(dist.method == "single")
      {
        # return single linkage value
        return(min(dist_mat[clust_index_1,clust_index_2]))
      } else if(dist.method == "average") {
        # return average linkage value
        return(mean(dist_mat[clust_index_1,clust_index_2]))
      }else{
        # return complete linkage value
        return(max(dist_mat[clust_index_1,clust_index_2]))
      }
    })

    # detecting which clusters are closest
    current_changepoint = which.min(link_dist)

    # Merging the clusters and storing the numbers from which only new clusters start
    trackclust_mat[j+1, ] = c(current_track[-(current_changepoint + 1)], 0)
  }

  # Extracting the detected multiple change-points (desired clusters numcp + 1)
  detect.multiple.cp = trackclust_mat[n - (numcp + 1) + 1, 1:(numcp + 1)] - 1
  detect.multiple.cp = detect.multiple.cp[detect.multiple.cp != 0]

  #Return detected change-points
  return(detect.multiple.cp)
}


