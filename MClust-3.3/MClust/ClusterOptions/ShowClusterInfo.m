function ShowClusterInfo(iClust)
% ShowClusterInfo(iClust)
%
% INPUTS
%    iClust
%
% OUTPUTS
%
% NONE
% TO USE WITH MCLUST, put this in the MClust/ClusterOptions folder

% ADR 2003
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.
% Extensively modified by ADR to accomodate new ClusterOptions methodology

global MClust_Clusters
msgbox(GetInfo(MClust_Clusters{iClust}), ['Cluster ', num2str(iClust)]);
