function WriteClusterIndexFile(fn, clusterIndex)
% WriteClusterIndexFile(fn, clusterIndex)
fp = fopen(fn, 'wt');
WriteHeader(fp, ...