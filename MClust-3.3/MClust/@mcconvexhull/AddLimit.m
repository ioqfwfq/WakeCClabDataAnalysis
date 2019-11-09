function MCC = AddLimit(MCC, xdim, ydim, axisHandle)

% MCCluster/AddLimit(MCC, xdim, ydim, axisHandle)
%
% INPUTS
%    xdim - xdimension
%    ydim - ydimension
%    axisHandle - axis on which to draw convex hull
%
% ADR 1998
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

if isempty(MCC.xdims)
   iL = 1;
else
   iL = find(MCC.xdims == xdim & MCC.ydims == ydim);
   if isempty(iL)
      iL = length(MCC.xdims)+1;
   end
end

axes(axisHandle);
[chx,chy] = DrawConvexHull;

MCC.xdims(iL) = xdim;
MCC.ydims(iL) = ydim;
MCC.cx{iL} = chx;
MCC.cy{iL} = chy;

if MCC.recalc == 0
   MCC.recalc = 1; % things have changed
end
