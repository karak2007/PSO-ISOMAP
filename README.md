[Source Code]
ps_closest.R: the original PSO code
ps_closest_rwr.R: contains functions to read, write, and normlize the raw RWR data file
ps_closest_iso.R: use the angular coordinates (not normalized) to generate the PSO network

[data files]
real_rwr.csv: raw RWR data
normalized_rwr.csv
book1.csv: angular coordinates generated by ISOMAP matlab code

[plots] 
degree-dist-rwr-popsim-network-isomap-k-7.png: generated by ps_closest_iso.R
dist_angular_coords.png: angular coordinates distribution (from matlab using book1.csv)

[misc notes]
**************Matlab code**************
# random 10x10 matrix
x1 = randi([0, 100], [10,10])/100

#import data
A = importdata('real_rwr.csv',';')

#import csv file
M = csvread('normalized_rwr.csv')

#run isomap function
[Y, R, E]= Isomap(x1, 'k', 7)

**************R code:**************
write.csv(rwr_mat, file = "normalized_rwr.csv", row.names = FALSE,
          col.names = FALSE)
# write without column name
 write.table(rwr_mat, file = "normalized_rwr.csv",row.names=FALSE, na="",col.names=FALSE, sep=",")

**************Git:**************
- git remote add origin https://github.com/karak2007/PSO-ISOMAP.git

- git push -u origin master
git add README.md
git commit -m "first commit"
git push -u origin master 

