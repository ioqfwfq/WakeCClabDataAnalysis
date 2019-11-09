function mTSD = Mask(tsd, varargin)
%
% mTSD = ctsd/Mask(tsd, TrialPairs....)
%
% INPUTS:
%    tsd        = tsd object
%    TrialPairs = pairs of start/end times (can be matrices of n x 2)
%    NOTE: remember to use the same units as tsd!
%
% OUTPUTS:
%    mTSD = ctsd object with times *not* in TrialPairs set to NaN
%
% ADR 1998
% version L5.0
% v5.0 JCJ 2/27/2003 includes support for time units


% Unwrap trial pairs
MaskOFF = [StartTime(tsd)-1];
MaskON  = []; 
for iTP = 1:length(varargin)
   curMask = varargin{iTP};
   MaskOFF = cat(1, MaskOFF, curMask(:,2));
   MaskON  = cat(1,MaskON, curMask(:,1));
end
MaskON = cat(1, MaskON, EndTime(tsd)+1);
nTransitions = length(MaskON);
MaskON = sort(MaskON);
MaskOFF = sort(MaskOFF);

% Construction output tsd
mTSD = tsd;

% Now implement mask
for iT = 1:nTransitions
    %     if (MaskOFF(iT)<=tsd.(end))&(MaskON(iT)>=tsd.t(1))
    m0  = max(1,findAlignment(tsd, MaskOFF(iT), tsd.units));
    m1  = min(length(tsd.data), findAlignment(tsd, MaskON(iT), tsd.units));
    if m0 <= 1; 
        m0 = 1;
    elseif findTime(tsd, m0) == MaskOFF(iT)
        m0 = m0 + 1;
    end       % really want > not >=
    if m1 >= length(tsd.data)
        m1 = length(tsd.data);
    elseif findTime(tsd, m1) == MaskON(iT)
        m1 = m1 - 1;
    end       % really want < not <=
    if ~(((m0==1) & (m1==1)) | ((m0==length(tsd.data)) & (m1==length(tsd.data))))  % both MaskON and MaskOFF were less than the first time or greater than the last time
        mTSD.data(m0:m1) = NaN;
    end
    %     end
    
end
