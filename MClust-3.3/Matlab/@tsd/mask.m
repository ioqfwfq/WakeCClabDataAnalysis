function mTSD = Mask(tsd, varargin)
%
% mTSD = tsd/Mask(tsd, TrialPairs....)
%
% INPUTS:
%    tsd = tsd object
%    TrialPairs = pairs of start/end times (can be matrices of n x 2)
%                 NOTE: must be SAME units as tsd!
%
% OUTPUTS:
%    mtsd = tsd object with times *not* in TrialPairs set to NaN
%
% ADR 1998
% version L4.0 
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

% Unwrap trial pairs
MaskOFF = [StartTime(tsd)-1];
MaskON = []; 
for iTP = 1:length(varargin)
   curMask = varargin{iTP};
   MaskOFF = cat(1, MaskOFF, curMask(:,2));
   MaskON = cat(1,MaskON, curMask(:,1));
end
MaskON = cat(1, MaskON, EndTime(tsd)+1);
nTransitions = length(MaskON);
MaskON = sort(MaskON);
MaskOFF = sort(MaskOFF);

% Construction output tsd
mTSD = tsd;

% Now implement mask
for iT = 1:nTransitions
   f = find(mTSD.t > MaskOFF(iT) & mTSD.t < MaskON(iT));
   mTSD.data(f) = NaN;
end
