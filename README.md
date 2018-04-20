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


