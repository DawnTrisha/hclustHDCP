#' Detecting change-point location(s) for unknown number of change-points
#'
#' @param X Data matrix (n X p) where n denotes number of observations. Each row is a p dimensional observation vector. n observations are arranged in chronological order.
#' @param D Distance matrix (n X n) corresponding to the data matrix. Either the data matrix or the distance matrix should be supplied. Default is the Euclidean distance to construct the distance matrix when data matrix is supplied.
#' @param p Dimension of the observations. Should be supplied if distance matrix D is supplied instead of data matrix X.
#' @param dist.method Linkage method to use in hierarchical clustering for calculating the distances between consecutive clusters. This must be one of "single", "average" or "complete". Default is "average".
#' @param lambda Penalty parameter. Default is 0.02.
#'
#' @return Returns a integer or a numeric vector denoting estimated change-point location(s) depending on single or multiple change-point(s) is/are detected. Returns the last observation number (time point) in case of non-detection.
#' @export
#'
#' @examples
#'  # Example 1
#' set.seed(1)
#' # Generate data matrix
#' X1 = matrix(rnorm((15 * 200), mean = 0, sd = 1), nrow = 15, ncol = 200)
#' X2 = matrix(rnorm((15 * 200), mean = 5, sd = 1), nrow = 15, ncol = 200)
#' X3 = matrix(rnorm((15 * 200), mean = 10, sd = 1), nrow = 15, ncol = 200)
#' X = rbind(X1, X2, X3)
#'
#'  # Detect change-points with default average linkage
#' detect_estimated_cp(X = X)
#'
#' # Detect change-points with complete linkage
#' detect_estimated_cp(X = X, dist.method = "complete")
#'
#' # Example 2
#' set.seed(1)
#' # Generate data matrix
#' X1 = matrix(rnorm((15 * 200), mean = 0, sd = 1), nrow = 15, ncol = 200)
#' X2 = matrix(rnorm((15 * 200), mean = 5, sd = 1), nrow = 15, ncol = 200)
#' X3 = matrix(rnorm((15 * 200), mean = 10, sd = 1), nrow = 15, ncol = 200)
#' X = rbind(X1, X2, X3)
#'
#' # Calculate distance matrix
#' D_mat = as.matrix(stats::dist(X, method = "euclidean"))
#'
#' # Only distance matrix is supplied
#' # Detect multiple change-points
#' detect_estimated_cp(D = D_mat, p = 200)  # correct change-points are detected
detect_estimated_cp = function(X = NULL, D = NULL, p = NULL, dist.method = "average", lambda = 0.02)
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

    if(is.null(p) == TRUE)
    {
      stop("Supply dimension of the observations")
    }

    # Distance matrix
    dist_mat = D
  }else{
    # Calculate distance matrix
    dist_mat = as.matrix(stats::dist(X, method = "euclidean"))

    # Dimension of observations
    p = ncol(X)
  }

  # Number of observations
  n = nrow(dist_mat)


  # Make a copy of distance matrix to be used after at the time of recalculation of dsitance matrix after cluster update
  dist_mat_copy = dist_mat

  # Initialize the matrix with zeroes which will monitor merging of clusters
  trackclust_mat = matrix(0, n, n)

  # At initial stage one observation corresponds to one cluster
  trackclust_mat[1, ] = 1:n

  # Calculating penalized dunn index at the first stage when number of clusters same as number of observations
  penalized_dunn = c(-lambda * n * log(p), numeric(n - 1))

  # Running entire loop till n - 1 (since desired number of clusters is estimated_cp + 1)
  for(j in 1:(n - 1))
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

    # Deleting the row and column from the stored distance matrix for that observation which got merged with the previous one
    dist_mat_copy = as.matrix(dist_mat_copy[-(current_changepoint + 1), -(current_changepoint + 1)])

    # Recalculate the distance matrix based on the changed clusters
    vec1 = trackclust_mat[j + 1, ]

    # Select all those observations in one cluster which got merged in this step (hence vec1[current_changepoint + 1] - 1 just to stop before the next cluster starts)
    cluster_ind1 = vec1[current_changepoint]:(ifelse(current_changepoint < l, vec1[current_changepoint + 1] - 1, n))

    # Counting the total number of observations those got merged
    len_cluster_ind_1 = length(cluster_ind1)


    updated_dist = sapply(1:l, function(i){
      # Considering existing clusters and calling it cluster_ind2
      cluster_ind2 = vec1[i]:(ifelse( i < l, vec1[i+1] - 1, n))

      # Calculating length of clusters each time
      len_cluster_ind_2 = length(cluster_ind2)

      # Recalculating the distance with updated clusters to be used in penalized dunn index
      dist_val = sum(dist_mat[cluster_ind1, cluster_ind2])
      return(ifelse(i == current_changepoint, dist_val/(len_cluster_ind_1*(len_cluster_ind_1 - 1)), dist_val/(len_cluster_ind_1*len_cluster_ind_2)))

    })

    # Updated distance matrix after clustering
    dist_mat_copy[current_changepoint, ] = updated_dist
    dist_mat_copy[ , current_changepoint] = updated_dist

    # Calculation of penalized dunn index in each stage of updated cluster
    # Numerator for the first term
    W_current_clust = max(diag(dist_mat_copy))
    # Denominator for the first term
    B_current_clust = ifelse(l > 1, min(dist_mat_copy[upper.tri(dist_mat_copy)]), B_current_clust)

    # Using penalty function as (lambda * l * log(p))
    penalized_dunn[j + 1] = (B_current_clust/W_current_clust) - (lambda * l * log(p))
  }

  # estimated number of clusters based on maximum penalized dunn index
  estimated.clust = which.max(penalized_dunn)

  # Estimated change-point locations based estimated clusters based on penalized dunn index
  if(estimated.clust == n) #if no change-point is detected
  {
    # then returns the last observation number
    detect.cp = n
  }else{
    # else returns the location of the change-point
    detect.cp = trackclust_mat[estimated.clust, 2:(n - estimated.clust + 1)] - 1
  }

  # Returning estimated change-point locations
  return(detect.cp)

}
