function [PvData, PvNames, PvPars] = feature_PV(V, ttChannelValidity,Params)

% MClust
% [PvData, PvNames] = feature_PV(V, ttChannelValidity)
% Calculate pv feature max value for each channel
%
% INPUTS
%    V = TT tsd
%    ttChannelValidity = nCh x 1 of booleans
%
% OUTPUTS
%    Data - nSpikes x nCh pv values
%    Names - "Pv: Ch"
%
% ADR April 1998
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

TTData = Data(V);
[nSpikes, nCh, nSamp] = size(TTData);

f = find(ttChannelValidity);

PvData = zeros(nSpikes, length(f));
PvNames = cell(length(f), 1);
PvPars = {};

for iCh = 1:length(f)
   PvData(:, iCh) = max(squeeze(TTData(:, f(iCh), :)), [], 2) - ...
       min(squeeze(TTData(:, f(iCh), :)), [], 2);
   PvNames{iCh} = ['peakValleyRatio: ' num2str(f(iCh))];
end
