
X1 = matrix(rnorm(5*2, mean = 0, sd = 1), nrow = 5, ncol = 2)
X2 = matrix(rnorm(5*2, mean = 3, sd = 1), nrow = 5, ncol = 2)
X3 = matrix(rnorm(5*2, mean = 6, sd = 1), nrow = 5, ncol = 2)


X = rbind(X1, X2, X3)

cl1=cutree(hclust(dist(X),method="single"),k=3)
cl1
which(cl1==1)
which(cl1==2)
which(cl1==3)

par(mar=c(3.75,3.4,2,1),mgp=c(2.3,0.5,0),oma=c(0.5,0.5,0.5,0.5),mfrow=c(2,2))

plot(X, pch = 1, xlim = c(1,30), ylim = c(-3,15),
     xlab = "t", ylab = expression(paste("PC"[1])),
     #xaxt = "n",
     #yaxt = "n",
     axes = F,
     #frame.plot = F, main = expression(paste("(a) ", mu," = 0", " (Before Clustering)"))
     frame.plot = F, main = expression(paste("(a) ", " Before Clustering")))
text(X, labels = 1:nrow(X), cex = 0.9)
axis(side = 1, at = c(1,10,20,30), tck = -0.03)
axis(side = 2, at = c(-3,0,3), las = 2, tck = -0.03)
#points(X2, pch = 16)
#points(X3, pch = 16)
#abline(h = -3, v = 0)
box()
