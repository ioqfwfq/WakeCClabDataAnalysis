function RunWaveformCutter(iClust)
% RunWaveformCutter(iClust)
%
% INPUTS
%    iClust
%
% OUTPUTS
%
% NONE
% TO USE WITH MCLUST, put this in the MClust/ClusterOptions folder

% ADR 2003
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.
% Extensively modified by ADR to accomodate new ClusterOptions methodology

global MClust_Clusters MClust_FeatureData MClust_TTData MClust_ChannelValidity
%warning('MClust:WaveformCutter', 'Any edits done on waveform will be lost when features are recalculated\n or cluster boundaries altered for this cluster.\n Editing the waveform should be the last step of cluster cutting.')  

subf = FindInCluster(MClust_Clusters{iClust}, MClust_FeatureData);

wv = ExtractCluster(MClust_TTData, subf);
t  = Range(wv,'ts');
wv = Data(wv);
WaveformCutter(t,wv,MClust_ChannelValidity,iClust,subf);

