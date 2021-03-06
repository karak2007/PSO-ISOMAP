# this is the isomap dimension-reduced version

library ("igraph")
library ("ggplot2")
library("wordspace")
library("matrixLaplacian")

#set path to the location of your code and data
setwd("C:/Users/jiyu/Documents/GitHub/Simpop-ola")



# Read and Process matrix
read_matrix<-function() {

  data<-read.table("book1.csv", header=FALSE, sep=",", stringsAsFactors=FALSE)
  
  # make all the data points positive
  data <- data - min(data)
  
  #scale to 0..1
  data <-data/max(data)
  
  #scale to 0..pi
  data <- data*pi

  return(data)
}


ps_model2 <- function(N = 8, avg.k = 2, gma = 3){
  #read sim data.....
  sim<-read_matrix()
  
  
  # Make sure that all parameters are valid
  check_ps_parameters(N, avg.k, gma)
  
  
  beta <- 1 / (gma - 1) # Determine the value of beta, a parameter controlling popularity fading
  m <- round(avg.k/2)    # use average degree to estimate m or remove this and put m direct
  
  # Initialise the node data frame and add the first node to the network
  nodes <- data.frame(r = vector("numeric", length = N), theta = vector("numeric", length = N))
  
  nodes$r[1] <- 0 # add frist node 
  
  #nodes$theta[1] <- stats::runif(1, min = 0, max = 2pi)# give a random pi to the first node 
  #we use the theta from the input data, which is the reduced 1-D coordinates of a node
  nodes$theta[1] <- sim[1,1]
  
 # Initialise the network adjacency matrix
  net <- matrix(0, nrow = N, ncol = N)
  diag(net) <- 1 #Trick to avoid a node choosing itself as interactor in the process
  
  # Dummy variable
  m_count <- 0
  
  # Add the rest of the nodes and connections to the network
  for(t in 2:N){
    
    # Move all nodes to their new radial coordinates to simulate popularity fading
    nodes$r[1:(t - 1)] <- beta * 2 * log(1:(t - 1)) + (1 - beta) * 2 * log(t)
    
    # New node is added to the network and acquires polar coordinates
    nodes$r[t] <- 2*log(t)
 
    #nodes$theta[t] <- stats::runif(1, min = 0, max = 2*pi)
    nodes$theta[t] <- sim[1,t]
    
    # Hyperbolic distance between new node and all existing nodes
    d <- hyperbolic_dist(nodes[t, ], nodes[1:(t - 1), ])
    
    # Since Temp = 0, simply connect to the m hyperbolically closest nodes
    s <- sort(d, index.return = T)
    if(length(d) < m){
      net[t, s$ix] <- 1
    }else{
      net[t, s$ix[1:m]] <- 1
    }
    
  }
  diag(net) <- 0
  net <- net + t(net)
  net <- graph_from_adjacency_matrix(net, mode = "undirected", diag = FALSE)
  return(list(network = net, polar = nodes))
}


#hyperbolic distance.....
hyperbolic_dist <- function(ZI, ZJ){
  
  #delta <- pi - abs(pi - abs(ZI$theta - ZJ$theta)) # Angular separation between points
  
  delta <- abs(ZI$theta - ZJ$theta) #now theta is between 0..pi, delta is just the distance between
  
  d <- cosh(ZI$r)*cosh(ZJ$r) - sinh(ZI$r)*sinh(ZJ$r)*cos(delta)
  
  # Due to precision problems, numbers d < 1 should be set to 1 to get the right final hyperbolic distance of 0
  d[d < 1] <- 1
  
  d <- acosh(d)
  
  #In addition, if ZI == ZJ, d should be 0
  d[ZI$r == ZJ$r & ZI$theta == ZJ$theta] <- 0
  
  return(d)
}



#' Generate a log10-linearly spaced sequence
#' 
#' Generates a sequence of \code{n} logarithmically spaced points between \code{s} and \code{e}, inclusive.
#' 
#' @param s numeric; The sequence starting point.
#' @param e numeric; The sequence ending point.
#' @param n integer; The number of points to be generated.
#' 
#' @return A numeric vector with \code{n} logarithmically spaced points between \code{s} and \code{e}.


log_seq <- function(s, e, n){
  s <- log10(s)
  e <- log10(e)
  return(exp(log(10) * seq(s, e, length.out = n)))
}


#plot degree distribution.....

plot_degree_distr <- function(network, bins = 100){
  # Calculate degrees for each node
  d <- degree(network, mode = "all")
  
  # Bin the degrees using logarithmic spacing
  breaks = log_seq(min(d), max(d), bins + 1)
  cuts <- cut(d, breaks = breaks, labels = breaks[-length(breaks)], include.lowest = T)
  stats <- data.frame(deg = as.numeric(levels(cuts)), 
                      prob = as.numeric(table(cuts))/sum(as.numeric(table(cuts))), 
                      stringsAsFactors = F)
  stats <- stats[stats$prob > 0, ]
  
  return(ggplot(stats, aes_(~deg, ~prob)) + geom_point() + 
           scale_x_log10(breaks = scales::trans_breaks("log10", function(x) 10^x), 
                         labels = scales::trans_format("log10", scales::math_format())) + 
           scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x), 
                         labels = scales::trans_format("log10", scales::math_format())) + 
           annotation_logticks() + labs(x = "Node degree", y = "Probability") + theme_bw() +
           theme(panel.grid.minor = element_blank()))
}




#check parameters used in ps_model2

check_ps_parameters <- function(N, avg.k, gma){
  
  ### N (Number of network nodes)
  if(is.na(N) | N < 2){
    stop("The number of network nodes N was not specified or is not a valid integer >= 2.")
  }
  
  ### AVG.K (Average node degree)
  if(is.na(avg.k) | avg.k < 2){
    stop("The target average node degree avg.k was not specified or is not a valid number >= 2.")
  }
  
  ### GAMMA (Network's scaling exponent)
  if(is.na(gma) | gma < 2 | gma > 3){
    stop("The target network scaling exponent gma was not specified or is outside the valid range [2, 3].")
  }
  
}