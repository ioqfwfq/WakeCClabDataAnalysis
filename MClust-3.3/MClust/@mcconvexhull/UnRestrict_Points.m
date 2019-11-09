function MCC = UnRestrict_Points(MCC)

% INPUT: MCC object
% OUTPUT: MCC object 
%
% Clear the list of illegal points (points not allowed in the cluster.
%
% cowen 2002 
% modified ncst 02 May 03

MCC.ForbiddenPoints = []; 
MCC.recalc = 1;