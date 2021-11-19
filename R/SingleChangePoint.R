# Function to detect Single Change Point

# Inputs:
# Data matrix X (n X d) : whose rows are the d dimensional observations
# numcp : Number of change-points to detect (integer between 1 to n-1)
detect_single_cp = function(X, numcp)
{
  # Number of observations
  n = nrow(X)

  # Calculate distance matrix
  dist_mat = as.matrix(dist(X), method = "euclidean")

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

      # return average linkage value
      return(mean(dist_mat[clust_index_1,clust_index_2]))

      #return(min(DX[clus1ind,clus2ind]))               #single linkage
      #return(max(DX[clus1ind,clus2ind]))               #complete linkage
    })

    # detecting which clusters are closest
    current_changepoint = which.min(distvec)

    # Merging the clusters and storing the numbers from which only new clusters start
    trackclust_mat[j+1, ] = c(current_track[-(current_changepoint + 1)], 0)
  }

}
