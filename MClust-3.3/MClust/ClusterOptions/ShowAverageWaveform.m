function ShowAverageWaveform(iClust)

% ShowWaveformDensity(iClust)
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

        global MClust_TTData MClust_Clusters MClust_FeatureData
        global MClust_Colors
        
        run_avg_waveform = 1;
        
        [f MClust_Clusters{iClust}] = FindInCluster(MClust_Clusters{iClust}, MClust_FeatureData);
        
        % modified ncst 23 May 02
        %         if length(f) > 150000
        %             ButtonName=questdlg([ 'There are ' num2str(length(f)) ' points in this cluster. MClust may crash. Are you sure you want to check clusters?'], ...
        %                 'MClust', 'Yes','No','No');
        %             if strcmpi(ButtonName,'No')
        %                 run_avg_waveform = 0;
        %             end
        %         else
        if length(f) == 0
            run_avg_waveform = 0;
            msgbox('No points in cluster.')
        end
 
        if run_avg_waveform
            clustTT = ExtractCluster(MClust_TTData, f);
            [mWV sWV] = AverageWaveform(clustTT); 
            AveWVFig = figure; 
               for it = 1:4
                  xrange = (34 * (it-1)) + (1:32); 
                  figure(AveWVFig);
                  hold on;
                  plot(xrange, mWV(it,:));
                  errorbar(xrange,mWV(it,:),sWV(it,:)) %,'blue'); 
                  set(findobj(gcf,'Type','line'),'Color',MClust_Colors(iClust + 1,:));
               end
               axis off
               axis([0 140 -2100 2100])
               hold off
                title(['Average Waveform: Cluster ' num2str(iClust)]);
        end
