function spikedisplay(fn,channel,trials,task_ends,spike_ends)
% spikedisplay(filename) displays the waveforms within your data file
% according to the clusters calculated by KlustaKwik and located within the
% directory \'filename'
% 5-11-05, TM
% edited from DA_CusterPlot3
% Take out variable ' spike_index': the original programm put all waveform
% in an array named spike_index, which consuming memory.
% This for displaying waveform for CAT file only
% Jun-1-09, XQ 
%%%%%%%%%%%%%%%%%%%%% Dont Clear last figures %%%%%%%%%%%%%%%%%%%%%%%%%%
fig_position={[5 700 400 300];[430 700 400 300];[860 700 400 300];[5 370 400 300];...
    [430 370 400 300];[860 370 400 300];[5 40 400 300];[430 40 400 300];...
    [860 40 400 300];[650 200 400 300]};    %XQ
monkey = fn(1:3);
wf_min = -5000;
wf_max = 5000;
spikecounter = 1;                     % Counter for total waveforms
KeepFig = 0; %0 overwrite ;1 new plot
% following line comment out on Jun 19 2007
% cluext = '.clu.1';
% if str2num(fn(4:6) )> 114
%     fn_cluext = ['.\',fn,'_channel_',num2str(channel),'_CAT\',fn,cluext];  % full path and filename for .clu file
% else
%     fn_cluext = ['.\',fn,'_channel_',num2str(channel),'\',fn,cluext];  % full path and filename for .clu file
% end
% if ~length(fn_cluext)
%     disp('could not find clu cluster files')
%     cal_Clusters = 2;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Load cluster information %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(fn)>10
    %when input file name is 'CAT', display all
    try
        clusters = load(['C:\Users\juzhu\Documents\MATLAB\DA\Data\' monkey '\clusters\' fn(1:8) '_channel_' num2str(channel) '_CAT\' fn(1:8) '.clu.1']); 
        task_type = [1 : length(task_ends)];
         if fn(8)>1
            KeepFig = 1;
        else
            KeepFig = 0;
        end
    catch
        disp(['no CAT clu file for: ' fn '_channel_' num2str(channel)]);
        return
    end
elseif  length(fn)<10
    try
        %when input file name is 'T', try to find T clu file. some file
        %only  display clusters for 1 file
        clusters = load(['C:\Users\juzhu\Documents\MATLAB\DA\Data\' monkey '\clusters\' fn(1:8) '_channel_' num2str(channel) '\' fn(1:8) '.clu.1']); 
        task_type = 1;
        KeepFig = 1;
    catch
        %Only display slusters for 1 file
        disp(['no T clu file for: ' fn '_channel_' num2str(channel)]);
        try
            %input file name is 'T', try to find CAT clu file availible
            clusters = load(['C:\Users\juzhu\Documents\MATLAB\DA\Data\' monkey  '\clusters\' fn(1:7) '1_channel  ' num2str(channel) '_CAT\' fn(1:7) '1.clu.1']); % Adr
            task_type = str2num(fn(8));
            KeepFig = 2;
        catch
            disp(['no CAT clu file availible for: ' fn '_channel_' num2str(channel)]);
            return
        end
    end
end

clusters = clusters(2:end);           % Remnant of mclust KlustaImport
if ~isempty(spike_ends)
    channeln = find(spike_ends(:,1)== channel);
    if length(task_type) > 1 | task_type==1
        spikecounter = 1;                     % Counter for total waveforms
    else
        spikecounter = spike_ends(channeln,task_type)+1; % Counter for total waveforms
    end
else
    spikecounter = 1;
end
spikecounter1 = spikecounter;

%  spikeindex = zeros(length(clusters),74);

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

for l = task_type%1:length(task_ends)

    x = 1:wf_length;

    % Display data
    try
        for cluster_id = 1:n_clusters   
            spikecounter = spikecounter1;
            figure(cluster_id + length(hgf))
            set(gcf,'Name',[fn(1:8)  '_ch' num2str(channel) '_clu:' num2str(abs(unique_clusters(cluster_id)))],'NumberTitle','off');
            if cluster_id > 10
                set(gcf,'Position',[650 200 400 300],'menubar','none')
            else
                set(gcf,'Position',fig_position{cluster_id},'menubar','none');
            end

            % Setup figure
            colordef(0,'black');
            spikeColors={[0.5 0.5 0.5],[1 1 0],[1 0 0],[0 1 1],[0 0 1],[0 1 0]};
            hold on;
            box on;
            grid on;
            for n = n_start:task_ends(l)
                try
                    if isfield(trials(n).channels(channel),'spikes')
                        idx = find([clusters(spikecounter:spikecounter + length(trials(n).channels(channel).spikes)-1)] == unique_clusters(cluster_id));
                        if ~isempty(idx)
                            %                             idx = idx - spikecounter;
                            for nn = 1  : length(idx)
                                if trials(n).channels(channel).spikes(idx(nn)).unit == 1
                                    line(x,trials(n).channels(channel).spikes(idx(nn)).waveform(1:wf_length),'Color',spikeColors{l+1})
                                else
                                    line(x,trials(n).channels(channel).spikes(idx(nn)).waveform(1:wf_length),'Color',[0.5 0.5 0.5])
                                end
                                %                             spikecounter1 = spikecounter1 + 1;
                            end
                        end
                    end
                    spikecounter = spikecounter + length(trials(n).channels(channel).spikes);
                    %                     spikecounter2 = spikecounter2 + length(trials(n).channels(channel).spikes);
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
    if ~isempty(task_ends) & length(task_ends) >= l
    n_start = task_ends(l)+1;
    end
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