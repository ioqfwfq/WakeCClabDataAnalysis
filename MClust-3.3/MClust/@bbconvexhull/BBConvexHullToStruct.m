function MCC = BBConvexHullToMCConvexHull(BBC)

% Changes a bbconvexhull into a structure
% Used for transforming a bbconvexhull into a mcconvexhull
%
% Inputs: BBC -- a bbconvexhull
%
% Outputs: MCC -- a structure that can be converted into a mcconvexhull

% nsct 2 May 03

MCC.xdims = []; 
MCC.ydims = []; 
MCC.cx = {}; 
MCC.cy = {};
MCC.AddFlag = [];
MCC.recalc = -1;
MCC.myPoints = [];
MCC.myOrigPoints = [];
MCC.ForbiddenPoints = []; % cowen 2002 restrict results to a subset, regardless of convex hulls.

ClusterFields = fields(BBC);

for iF = 1:length(ClusterFields)
	eval(['MCC.' ClusterFields{iF} ' = BBC.' ClusterFields{iF} ';']);
end

% in case this is a cluster from MClust3.2 that was created manually,
% set myOrigPoints to myPoints (manually created clusters never had 
% a set of myOrigPoints defined, just used inclusive limits)
if size(MCC.myPoints,1) > size(MCC.myOrigPoints,1)
	MCC.myOrigPoints = MCC.myPoints;
end