function [energyData, energyNames, energyPars] = feature_energy(V, ttChannelValidity, Params)

% MClust
% [Data, Names, Params] = feature_energy(V, ttChannelValidity, Params)
% Calculate energy feature max value for each channel
%
% INPUTS
%    V = TT tsd
%    ttChannelValidity = nCh x 1 of booleans%    Params   = feature paramters  (none for energy) %% OUTPUTS%    Data - nSpikes x nCh of energy INSIDE curve (below peak and above valley) of each spike%    Names - "energy: Ch"

% ADR April 1998
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

TTData = Data(V);
[nSpikes, nCh, nSamp] = size(TTData);f = find(ttChannelValidity);
energyData = zeros(nSpikes, length(f));
energyNames = cell(length(f), 1);
energyPars = {};

for iCh = 1:length(f)
   energyData(:, iCh) = sqrt(sum(squeeze( TTData(:, f(iCh), :) .* TTData(:, f(iCh), :) ), 2));
   energyNames{iCh} = ['energy: ' num2str(f(iCh))];
end
