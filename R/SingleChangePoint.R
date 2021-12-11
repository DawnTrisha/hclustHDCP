# Function to detect Single Change Point when it is known that only one change point exists

# Inputs:
# Data matrix X (n X d) : whose rows are the d dimensional observations
# dist.method : Linkage method to be used in the hierarchical clustering (single, average or complete)

# Output:
# detectcp: Detected single change-point location

#' Detecting single change-point
#'
#' @param X Data matrix (n X p) where n denotes number of observations. Each row is a p dimensional observation vector. n observations are arranged in chronological order.
#' @param D Distance matrix (n X n) corresponding to the data matrix. Either the data matrix or the distance matrix should be supplied. Default is the Euclidean distance to construct the distance matrix when data matrix is supplied.
#' @param dist.method Linkage method to use in hierarchical clustering for calculating the distances between consecutive clusters.  This must be one of "single", "average" or "complete". Default is "average".
#'
#' @return Returns integer value denoting estimated change-point location
#' @export
#'
#' @examples
#' # Example 1
#' set.seed(1)
#' # Generate data matrix
#' X1 = matrix(rnorm((15 * 50), mean = 0, sd = 1), nrow = 15, ncol = 50)
#' X2 = matrix(rnorm((15 * 50), mean = 4, sd = 1), nrow = 15, ncol = 50)
#' X = rbind(X1, X2)
#'
#' detect_single_cp(X = X)  # Detect single change-point with default average linkage
#' detect_single_cp(X = X, dist.method = "single") # Detect single change-point with single linkage
#'
#' # Example 2
#' X1 = matrix(rnorm((15 * 50), mean = 0, sd = 1), nrow = 15, ncol = 50)
#' X2 = matrix(rnorm((15 * 50), mean = 4, sd = 1), nrow = 15, ncol = 50)
#' X = rbind(X1, X2)
#'
#' # Calculate distance matrix
#' D_mat = as.matrix(stats::dist(X, method = "euclidean"))
#' # Only distance matrix is supplied
#' # Detect single change-point with default average linkage
#' detect_single_cp(D = D_mat)
#' # Detect single change-point with complete linkage
#' detect_single_cp(D = D_mat, dist.method = "complete")
detect_single_cp = function(X = NULL, D = NULL, dist.method = "average")
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

    # Distance matrix
    dist_mat = D
  }else{
    # Calculate distance matrix
    dist_mat = as.matrix(stats::dist(X, method = "euclidean"))
  }

  # Number of observations
  n = nrow(dist_mat)

  # Initialize the matrix with zeroes which will monitor merging of clusters
  trackclust_mat = matrix(0, n, n)

  # At initial stage one observation corresponds to one cluster
  trackclust_mat[1, ] = 1:n

  # Running loop till n-1 (since we need pairwise distances)
  for(j in 1:(n-1))
  {
    # Since at each stage the number of clusters decreases by 1
    l = n - j

    # looking at current stage of number of clusters
    current_track = trackclust_mat[j, ]

    # Calculating linkage distances
    link_dist = sapply(1:l, function(i) {

      # Considering two clusters at a time
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

  # Detected single change-point
  detect.single.cp = trackclust_mat[n-1, 1:2] - 1
  detect.single.cp = detect.single.cp[detect.single.cp != 0]

  # Return detected single change-point location
  return(detect.single.cp)
}
