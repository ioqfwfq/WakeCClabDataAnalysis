function MCC = mcconvexhull(Cluster)

% MCC = BBConvexHull(Cluster)
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
% cowen 2002 added a restriction -- ForbiddenPoints - great if you need to exclude points cut out by non hull bound criteria.
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

global MClust_FeatureData


MCC.xdims = []; 
MCC.ydims = []; 
MCC.cx = {}; 
MCC.cy = {};
MCC.AddFlag = [];
MCC.recalc = -1;
MCC.myPoints = [];
MCC.myOrigPoints = [];
MCC.ForbiddenPoints = []; % cowen 2002 restrict results to a subset, regardless of convex hulls.


switch nargin   
case 0
   MCC.myPoints = [];
case 1
    if ~isa(Cluster,'struct')
		MCC.myPoints = FindInCluster(Cluster,MClust_FeatureData);
		MCC.myOrigPoints = MCC.myPoints;
	else
		ClusterFields = fields(Cluster);

		for iF = 1:length(ClusterFields)
			eval(['MCC.' ClusterFields{iF} ' = Cluster.' ClusterFields{iF} ';']);
		end
	end
otherwise
   error('Incorrect number of inputs to MCConvexHull');
end

MCC.recalc = 1;

MCC = class(MCC, 'mcconvexhull');