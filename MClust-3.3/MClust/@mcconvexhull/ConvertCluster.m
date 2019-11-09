function [MCC, ErrorOut] = ConvertCluster(Cluster,Cluster_FeatureNames,Current_FeatureNames)

% [MCC, ErrorOut] = ConvertCluster(Cluster,Cluster_FeatureNames,Current_FeatureNames)
% Cluster
% 
% object containing three aligned cell arrays, one element for each of the n possible projections:
%    obj.x(n) = xdimension 
%    obj.y(n) = ydimension
%    obj.cx{n} = convex hull x coords in x dimenion
%    obj.cy{n} = convex hull y coords in y dimension
%    obj.AddFlag(n) = 1 for EXCLusive, 2 for INCLusive, 3 for SHOWn only
%
% Possible constructors
%    with no args, creates an empty cluster
%    with 1 arg (ClusterData = points in cluster), generates cluster from the data
%                              with no initial boundaries
%    
% PL 2000-2002
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

% modified ncst 24 Jul 02 to not enter 0's for missing limits

ErrorOut = [];

MCC.xdims = [];
MCC.ydims = []; 
MCC.cx = {}; 
MCC.cy = {};

if ~isempty(Cluster.xdims) 
	for iX = 1:length(Cluster.xdims)
        if Cluster.xdims(iX) > 0 & Cluster.ydims(iX) > 0
            FeatureIndex_x = strmatch(Cluster_FeatureNames(Cluster.xdims(iX)),Current_FeatureNames);
            FeatureIndex_y = strmatch(Cluster_FeatureNames(Cluster.ydims(iX)),Current_FeatureNames);
            if ~isempty(FeatureIndex_x) & ~isempty(FeatureIndex_y)
                MCC.xdims(end+1) = FeatureIndex_x; 
                MCC.ydims(end+1) = FeatureIndex_y; 
                MCC.cx(end+1) = Cluster.cx(iX); 
                MCC.cy(end+1) = Cluster.cy(iX);
            else
                ErrorOut = [ErrorOut; [Cluster.xdims(iX) Cluster.ydims(iX)]];
            end
        end
	end
end

% modified ncst 27 Mar 03 to account for possible new fields added.

fields_MCC = fields(MCC);
fields_Cluster = fields(Cluster);

for iF = 1:length(fields_Cluster)
	if isempty(strmatch(fields_Cluster{iF},fields_MCC))
		eval(['MCC.' fields_Cluster{iF} ' = Cluster.' fields_Cluster{iF} ';']);
	end
end
% MCC.AddFlag = Cluster.AddFlag;
% MCC.recalc = Cluster.recalc;
% MCC.myPoints = Cluster.myPoints;
% MCC.myOrigPoints = Cluster.myOrigPoints;

MCC = class(MCC, 'mcconvexhull');