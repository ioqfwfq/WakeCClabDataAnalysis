function MCC = DeleteMembers(MCC)

% MCCluster/DeleteMembers(MCC)
%
% INPUTS
%      BBconvexhull cluster object
%
% PL 2000-2002
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.


MCC.myPoints = [];
MCC.myOrigPoints = [];

if MCC.recalc == 0
   MCC.recalc = 1;
end


