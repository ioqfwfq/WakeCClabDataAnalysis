function [slopeData, slopeNames, slopePars] = feature_slopeR(V, ttChannelValidity, Params)

% MClust
% interpolation to improve resolution.
%
% JCJ Sept 2002


TTData = Data(V);

[nSpikes, nCh, nSamp] = size(TTData);

f = find(ttChannelValidity);

slopeData = zeros(nSpikes, length(f));
slopeNames = cell(length(f), 1);
slopePars = {};

Res=4;
TempY =zeros(nSamp+4,nSpikes);
TempX =[1:nSamp+4]';
TempXX=[1:(1/Res):nSamp+4]';
TempYY =zeros(Res*(nSamp+4),nSpikes);


for iCh = 1:length(f)
   
   TempY([3:nSamp+2],:)=squeeze(TTData(:, f(iCh), :))';
   TempYY = INTERP1(TempX,TempY,TempXX,'cubic');
   dwv = diff(TempYY,1,1);

   slopeData(:, iCh) = shiftdim(max(dwv, [], 1));

   slopeNames{iCh} = ['slopeR: ' num2str(f(iCh))];
end