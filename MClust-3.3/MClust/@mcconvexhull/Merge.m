function MCC = Merge(MCC1, MCC2)

% BBCluster/Merge(MCC1, MCC2)
%
% INPUTS
%    MCC1, MCC2 two bbconvexhull cluster objects
%
% PL 2000-2002
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.
%
%
% modified ncst 26 Nov 02

global MClust_FeatureData

MCC = mcconvexhull;

%merge the members of the clusters and remove double members if any
sMCC1 = size(MCC1.myPoints);
sMCC2 = size(MCC2.myPoints);
if sMCC1(2) > 1
    MCC1.myPoints = MCC1.myPoints';
end
if sMCC2(2) > 1
    MCC2.myPoints = MCC2.myPoints';
end

MCC.myOrigPoints = unique([MCC1.myPoints ; MCC2.myPoints]);
MCC.myPoints = MCC.myOrigPoints;

MCC.recalc = 1; % things have changed;  




