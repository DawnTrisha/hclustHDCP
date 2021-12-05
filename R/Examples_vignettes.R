
X1 = matrix(rnorm(8*20, mean = 0, sd = 1), nrow = 8, ncol = 20)
X2 = matrix(rnorm(8*20, mean = 3, sd = 1), nrow = 8, ncol = 20)
X3 = matrix(rnorm(8*20, mean = 6, sd = 1), nrow = 8, ncol = 20)


X = rbind(X1, X2, X3)

X.pca  = prcomp(X, center = T, scale. = T)
M = X.pca$x[ , 1]

par(mar=c(3.75,3.4,2,1),mgp=c(2.3,0.5,0),oma=c(0.5,0.5,0.5,0.5),mfrow=c(2,2))

plot(M, pch = 1, xlim = c(1,24), ylim = c(-8,8),
     xlab = "t", ylab = expression(paste("PC"[1])),
     #xaxt = "n",
     #yaxt = "n",
     axes = F,
     #frame.plot = F, main = expression(paste("(a) ", mu," = 0", " (Before Clustering)"))
     frame.plot = F, main = expression(paste("(a) ", " Before Clustering")))
axis(side = 1, at = c(1,8,16,24), tck = -0.03)
axis(side = 2, at = c(-8,0,8), las = 2, tck = -0.03)
#points(X2, pch = 16)
#abline(h = -3, v = 0)
box()

cl1=cutree(hclust(dist(X),method="average"),k=3)
cl1
which(cl1==1)
which(cl1==2)
which(cl1==3)

z1 = as.vector(which(cl1==1))
z2 = as.vector(which(cl1==2))
z3 = as.vector(which(cl1==3))
y1 = NA
y2 = NA
y3 = NA
y1[z1] = -8
y2[z2] = -8
y3[z3] = -8

v1 = NA
v2 = NA
v3 = NA
v1[z1] = M[z1]
v2[z2] = M[z2]
v3[z3] = M[z3]

plot(y1, pch = 16, xlim = c(1,24), ylim = c(-8,8),
     xlab = "t", ylab = expression(paste("PC"[1])),
     #xaxt = "n",
     #yaxt = "n",
     axes = F,
     frame.plot = F, col = "red", main = expression(paste("(b) ", "Average Linkage")))
axis(side = 1, at = c(1,8,16,24),tck = -0.03)
axis(side = 2, at = c(-8,0,8), las = 2, tck = -0.03)
points(y2, pch = 16, col = "blue")
points(y3, pch = 16, col = "green")
points(v1, pch = 16, col = "red")
points(v2, pch = 16, col = "blue")
points(v3, pch = 16, col = "green")
#abline(h = -3, v = 0)
box()
