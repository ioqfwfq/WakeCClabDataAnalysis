function MCC = mcconvexhull(ClusterData)

% MCC = MCConvexHull(ClusterData)
% Cluster
% 
% object containing three aligned cell arrays:
%    obj.x = xdimension 
%    obj.y = ydimension
%    obj.cx = convex hull x coords in x dimenion
%    obj.cy = convex hull y coords in y dimension
%
% Possible constructors
%    with no args, creates an empty cluster
%    with 1 arg  ClusterData = points in cluster:  generates cluster from the data
%    
% ADR 1998
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

switch nargin
   
case 0
   MCC.xdims = [];
   MCC.ydims = [];
   MCC.cx = {};
   MCC.cy = {};
   
case 1
   [nS, nD] = size(ClusterData);
   if nD < 2, warning('ClusterData must have at least 2 dimensions'); end%if
   if nS < 3, warning('ClusterData must have at least 3 sample points'); end%if
   MCC.xdims = []; MCC.ydims = []; 
   MCC.cx = {}; MCC.cy = {};
   for iX = 1:nD
      for iY = (iX+1):nD
         MCC.xdims(end+1) = iX;
         MCC.ydims(end+1) = iY;
         %k = convhull(ClusterData(:,iX), ClusterData(:,iY));
	      k = convexhull(ClusterData(:,iX), ClusterData(:,iY));
         MCC.cx{end+1} = ClusterData(k,iX);
         MCC.cy{end+1} = ClusterData(k,iY);
      end
   end

   
otherwise
   error('Incorrect number of inputs to MCConvexHull');
         
end

MCC.recalc = -1;
MCC.myPoints = [];
MCC = class(MCC, 'mcconvexhull');