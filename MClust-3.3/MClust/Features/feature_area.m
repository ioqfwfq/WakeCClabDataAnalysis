function [AreaData, AreaNames, AreaPars] = feature_AREA(V, ttChannelValidity, Params)

% MClust% [Data, Names] = feature_AREA(V, ttChannelValidity)% Calculate area feature max value for each channel%% INPUTS%    V = TT tsd%    ttChannelValidity = nCh x 1 of booleans%% OUTPUTS%    Data - nSpikes x nCh of area INSIDE curve (below peak and above valley) of each spike%    Names - "Area: Ch"
%
% ADR April 1998%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.



TTData = Data(V);
[nSpikes, nCh, nSamp] = size(TTData);

f = find(ttChannelValidity);

AreaData = zeros(nSpikes, length(f));
AreaNames = cell(length(f), 1);
AreaPars = {};

for iCh = 1:length(f)
   AreaData(:, iCh) = sum(squeeze(abs(TTData(:, f(iCh), :))), 2);
   AreaNames{iCh} = ['Area: ' num2str(f(iCh))];
end
