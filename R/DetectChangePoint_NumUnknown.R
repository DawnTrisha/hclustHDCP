detect_estimated_cp = function(X, D = NULL, dist.method = "average", lambda = 0.02)
{
  # Number of observations
  n = nrow(X)

  # Dimension of observations
  d = ncol(X)

  # Check if Distance matrix is supplied or not, if supplied
  if(is.null(D) == FALSE)
  {
    if((nrow(D) != n) || (ncol(D) != n))
    {
      stop("Incorrect supplied distance matrix")
    }
  }

  # Calculate distance matrix
  dist_mat = as.matrix(dist(X), method = "euclidean")

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


  }




  # # Extracting the detected multiple change-points (desired clusters numcp + 1)
  # detect.multiple.cp = trackclust_mat[n - (numcp + 1) + 1, 1:(numcp + 1)] - 1
  # detect.multiple.cp = detect.multiple.cp[detect.multiple.cp != 0]
  #
  # #Return detected change-points
  # return(detect.multiple.cp)
}
