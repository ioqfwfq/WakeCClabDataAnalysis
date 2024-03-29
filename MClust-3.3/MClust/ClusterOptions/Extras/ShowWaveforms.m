function ShowWaveforms(iClust)
% ShowWaveforms(iClust)
%
%
% INPUTS
%    wv -- tsd of tt or waveform data
%
% OUTPUTS
%
% NONE% TO USE WITH MCLUST, put this in the MClust/ClusterOptions folder% NCST 2002
%% Status: PROMOTED (Release version) % See documentation for copyright (owned by original authors) and warranties (none!).% This code released as part of MClust 3.0.% Version control M3.0.% Extensively modified by ADR to accomodate new ClusterOptions methodologyglobal MClust_TTData MClust_Clusters MClust_FeatureDataglobal MClust_Colors        [f MClust_Clusters{iClust}] = FindInCluster(MClust_Clusters{iClust});if length(f) == 0	msgbox('No points in cluster.')	returnend[clustTT was_scaled] = ExtractCluster(MClust_TTData, f); if was_scaled == 0	nSpikes = size(Data(clustTT),1);else	nSpikes = was_scaled;endDoPlotYN= 'yes';WV = clustTT;Color = MClust_Colors(iClust + 1,:);
WVD = Data(WV);mWV = zeros(4,size(WVD,3));sWV = zeros(4,size(WVD,3));mWV = squeeze(mean(WVD,1));sWV = squeeze(std(WVD,1));
if length(WVD(:,1,1)) > 1000    maxPts = 1000;    Pts = randperm(size(WVD,1));    Pts = Pts(1:1000);else    maxPts = size(WVD,1);    Pts = 1:size(WVD,1);end
if nargout == 0 | strcmp(DoPlotYN,'yes')  % no output args, plot it    if strcmp(DoPlotYN,'yes')        ShowWVFig = figure;    end
    for it = 1:4
        xrange = ((size(WVD,3) + 2) * (it-1)) + (1:size(WVD,3));         if strcmp(DoPlotYN,'yes')            figure(ShowWVFig);        end
        hold on;        plot(xrange,squeeze(WVD(Pts,it,:))','color',Color);        plot(xrange, mWV(it,:),'w');
    end    
    axis off
    axis([0 4*(size(WVD,3) + 2) -2100 2100])
    title(['Waveforms -- ' num2str(maxPts) ' of ' num2str(length(WVD(:,1,1))) ' waveforms shown']);
    hold off
end