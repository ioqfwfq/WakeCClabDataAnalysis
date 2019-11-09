function [slopeData, slopeNames, slopePars] = feature_slopeF(V, ttChannelValidity, Params)

% MClust
% [slopeData, slopeNames, slopePars] = feature_slopeF(V, ttChannelValidity, Params)
% Calculate maximum falling slope. Performs cubic spline
% interpolation to improve resolution.
%
% INPUTS
%    V = TT tsd
%    ttChannelValidity = nCh x 1 of booleans
%
% OUTPUTS
%    slopeData - nSpikes x nCh slope values
%    slopeNames - "slopeFall: Ch"
%
% JCJ Sept 2002
%


TTData = Data(V);
[nSpikes, nCh, nSamp] = size(TTData);

f = find(ttChannelValidity);
slopeData = zeros(nSpikes, length(f));slopeNames = cell(length(f), 1);
slopePars = {};


Res=4;
TempY =zeros(nSamp+4,nSpikes);
TempX =[1:nSamp+4]';
TempXX=[1:(1/Res):nSamp+4]';
TempY2 =zeros(Res*(nSamp+4),nSpikes);


for iCh = 1:length(f)
   
   TempY([3:nSamp+2],:)=squeeze(TTData(:, f(iCh), :))';
   TempY2 = INTERP1(TempX,TempY,TempXX,'cubic');
   dwv = diff(TempY2,1,1);

   slopeData(:, iCh) = shiftdim(min(dwv, [], 1));

   slopeNames{iCh} = ['slopeF: ' num2str(f(iCh))];
end
