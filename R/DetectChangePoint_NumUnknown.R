#' Title
#'
#' @param X
#' @param D
#' @param d
#' @param dist.method
#' @param lambda
#'
#' @return
#' @export
#'
#' @examples
detect_estimated_cp = function(X = NULL, D = NULL, d = NULL, dist.method = "average", lambda = 0.02)
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
    dist_mat = as.matrix(stats::dist(X), method = "euclidean")

    # Dimension of observations
    d = ncol(X)
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
  penalized_dunn = c(-lambda * n * log(d), numeric(n - 1))

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

      # Recalculating the distance matrix with updated clusters
      dist_val = sum(dist_mat[cluster_ind1, cluster_ind2])

      return(ifelse(i == current_changepoint, dist_val/(len_cluster_ind_1*(len_cluster_ind_1-1)), dist_val/(len_cluster_ind_1*len_cluster_ind_2)))
    })

    # Updated distance matrix after clustering
    dist_mat_copy[current_changepoint, ] = updated_dist
    dist_mat_copy[ , current_changepoint] = updated_dist

    # Calculation of penalized dunn index in each stage of updated cluster
    # Numerator for the first term
    W_current_clust = max(diag(dist_mat_copy))
    # Denominator for the first term
    B_current_clust = ifelse(l > 1, min(dist_mat_copy[upper.tri(dist_mat_copy)]), B_current_clust)

    # Using penalty function as (lambda * l * log(d))
    penalized_dunn[j + 1] = (B_current_clust/W_current_clust) - (lambda * l * log(d))
  }

  # estimated number of clusters based on minimum penalized dunn index
  estimated.clust = which.max(penalized_dunn)

  # Estimated change-point locations based estimated clusters based on penalized dunn index
  detect.cp = trackclust_mat[estimated.clust, 2:(n - estimated.clust + 1)] - 1

  # Returning estimated change-point locations
  return(detect.cp)

}
