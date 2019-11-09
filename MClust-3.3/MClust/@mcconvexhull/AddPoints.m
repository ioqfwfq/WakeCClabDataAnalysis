function [MCC] = AddLimit(MCC, data, axisHandle)

% f = AddPoints(MCC, data, axisHandle)
%
% INPUTS
%     MCC - a MCCluster
%     data - nS x nD data
%     axisHandle - drawingaxis
%
% OUTPUTS
%     MCC - The updated cluster
%
% 
% ncst 26 Nov 02
%

global MClust_FeatureNames MClust_FeatureTimestamps %MClust_xlbls MClust_ylbls

axes(axisHandle);
[chx,chy] = DrawConvexHull;


f = MCC.myOrigPoints;

f_new = find(InPolygon(data(:,1), data(:,2), chx, chy));
	  
MCC.recalc = 1;
MCC.myOrigPoints = unique([f; f_new]);