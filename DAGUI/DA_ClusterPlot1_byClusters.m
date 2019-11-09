function spikedisplay(fn,channel,trials,task_ends)
% spikedisplay(filename) displays the waveforms within your data file
% according to the clusters calculated by KlustaKwik and located within the
% directory \'filename'
% 5-11-05, TM
% edited from DA_CusterPlot3
% Take out variable ' spike_index': the original programm put all waveform
% in an array named spike_index, which consuming memory.
% This for displaying waveform for T file only
% Jun-1-09, XQ 

%%%%%%%%%%%%%%%%%%%%% Dont Clear last figures %%%%%%%%%%%%%%%%%%%%%%%%%%
fig_position={[5 700 400 300];[430 700 400 300];[860 700 400 300];[5 370 400 300];...
    [430 370 400 300];[860 370 400 300];[5 40 400 300];[430 40 400 300];...
    [860 40 400 300];[650 200 400 300]};    %XQ
monkey = fn(1:3);
% cd(['C:\Matlab2006B\work\Data_Analysis\APM_Data\' monkey '\t_file'])
% % Directory with .apm files comment out on Aug 2009 because of using cat
% file as file name list dir
spikecounter = 1;                     % Counter for total waveforms
KeepFig = 0; %0 overwrite ;1 new plot
wf_min = -5000;
wf_max = 5000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Load cluster information %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clusters = load(fn_cluext);           % load .clu file comment out on Jun 19 2007
try
    clusters = load(['C:\Users\juzhu\Documents\MATLAB\DA\Data\' monkey '\clusters\' fn(1:8) '_channel_' num2str(channel) '_CAT\' fn(1:8) '.clu.1']); % Adr
    task_type = 1;
    KeepFig = 1;
catch
    disp(['error in loading clu file :' lasterr]);
    return
end

clusters = clusters(2:end);           % Remnant of mclust KlustaImport

if KeepFig == 1
    hgf=get(0,'children');
else
    hgf = [];
end

unique_clusters = unique(clusters);   % list types of clusters
n_clusters = length(unique_clusters); % total number of clusters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Find Refrence Trial %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ref_trial = 0;
for n = 1:12
    try
        trials(n).channels(channel).spikes(1).waveform;
        Ref_trial = n;
        break
    end
end
% Clusters are in a vector, apm data in a structure so vectorize apm data
% to relate the two
wf_length = length(trials(Ref_trial).channels(channel).spikes(1).waveform);
% pack
n_start = 1;
spikecounter = 1;
spikecounter1 =1;

x = 1:wf_length;

% Display data
try
    for cluster_id = 1:n_clusters
        spikecounter = spikecounter1;
        figure
        set(gcf,'Name',[fn(1:8)  '_ch' num2str(channel) '_clu:' num2str(abs(unique_clusters(cluster_id)))],'NumberTitle','off');
        if cluster_id > 10
            set(gcf,'Position',[650 200 400 300],'menubar','none')
        else
            set(gcf,'Position',fig_position{cluster_id},'menubar','none');
        end

       % Setup figure
        colordef(0,'black');
        spikeColors={[0.5 0.5 0.5],[0.5 1 1],[1 1 0],[1 0 0],[0 1 1],[0 0 1],[0 1 0]};
        hold on;
        box on;
        grid on;

        for n = n_start:task_ends(1)
            try
                if isfield(trials(n).channels(channel),'spikes')
                    idx = find([clusters(spikecounter:spikecounter + length(trials(n).channels(channel).spikes)-1)] == unique_clusters(cluster_id));
                    if ~isempty(idx)
                        for nn = 1  : length(idx)
                            line(x,trials(n).channels(channel).spikes(idx(nn)).waveform(1:wf_length),'Color',spikeColors{trials(n).channels(channel).spikes(idx(nn)).unit+1})
                        end
                    end

                end
                spikecounter = spikecounter + length(trials(n).channels(channel).spikes);
            catch
                disp([fn ' trial ' num2str(n) ' '  lasterr])
            end
        end
        axis([1 wf_length wf_min wf_max])
    end
    spikecounter1 = spikecounter;
catch
    disp(['wrong data on displaying spike:  ' num2str(spikecounter)]);
end

hold off
drawnow
clear spikeindex trials

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% Adjust the scale %%%%%%%%%%%%%%%%%%%%%%%%
% hcg = get(0,'children');
% hcg = sort(hcg);
% for n = 1:(length(hcg))
%     figure(hcg(n))
%     axis([1 70 -4000 3000])
% end
% stepper_id = 3
% Cluster_stepper(spikeindex,cluster_id,clusters,wf_length,wf_min,wf_max)
disp('finished')