function MCC = DeleteLimit(MCC, xdim, ydim)

% MCCluster/DeleteLimit(MCC, xdim, ydim)
%
% INPUTS
%    xdim - xdimension
%    ydim - ydimension
%
% PL 2000-2002
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

global MClust_FeatureData

if ~isempty(MCC.xdims)
   iL = find(MCC.xdims == xdim & MCC.ydims == ydim);
   if ~isempty(iL)
      MCC.xdims = MCC.xdims([1:(iL-1) (iL+1):end]);
      MCC.ydims = MCC.ydims([1:(iL-1) (iL+1):end]);
      MCC.cx    = MCC.cx([1:(iL-1) (iL+1):end]);
      MCC.cy    = MCC.cy([1:(iL-1) (iL+1):end]);
   end
end

% recalculate myPoints
MCC.recalc = 1; % things have changed;  
MCC.myPoints = FindInCluster(MCC, MClust_FeatureData);


