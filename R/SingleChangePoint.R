# Function to detect Single Change Point when it is known that only one change point exists

# Inputs:
# Data matrix X (n X d) : whose rows are the d dimensional observations
# dist.method : Linkage method to be used in the hierarchical clustering (single, average or complete)

# Output:
# detectcp: Detected single change-point location
#' Title
#'
#' @param X
#' @param dist.method
#'
#' @return
#' @export
#'
#' @examples
detect_single_cp = function(X, dist.method)
{
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
    dist_mat = as.matrix(dist(X), method = "euclidean")
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
    current_changepoint = which.min(distvec)

    # Merging the clusters and storing the numbers from which only new clusters start
    trackclust_mat[j+1, ] = c(current_track[-(current_changepoint + 1)], 0)
  }

  # Detected single change-point
  detect.single.cp = trackclust_mat[n, 1:2] - 1
  detect.single.cp = detect.single.cp[detect.single.cp != 0]

  # Return detected single change-point location
  return(detect.single.cp)
}
