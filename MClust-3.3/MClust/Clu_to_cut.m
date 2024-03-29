function A = Clu_to_cut(clu_file, output_file)
%function A = Clu_to_cut(clu_file, output_file)
%%%%%%%%%%%%%%%%%%%%%%
% Load the cluster file generated by KKwick and save as a .cut file.
%%%%%%%%%%%%%%%%%%%%%%
% INPUT: a .clu.n file from KK
% OUTPUT: a .cut file.
% 
% cowen
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

clusters = load(clu_file);
clusters = clusters(2:end);
unique_clusters = unique(clusters);
n_clusters = length(unique_clusters);

fp = fopen(output_file,'w');
WriteHeader(fp,'Note: Cluster IDs from KlustaKwik',...
    ['n clusters: ' num2str(n_clusters)],...
    ['n points: ' num2str(length(clusters))]);
fprintf(fp,'%d\n',clusters);
fclose(fp);