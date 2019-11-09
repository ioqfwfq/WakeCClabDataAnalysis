function RasterPlot(varargin)

% RasterPlot computers rasters, histrograms of neural data from APM format.
% Syntax: RasterPlot('filename',[clusters],channel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Changes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4-20-05, Altered program to process apm files with only 2 photodiode
% values by removing videosync information and adding the switch to
% if-statement on line 67, TM.
% 5-12-05, plotting the waveform as well as the rasters and histos, TM
% 5-20-05, Altered the program to incorporate clusters.  Now there can be
% two input arguments, 1-filename and 2-cluster value.  If no cluster value
% is given, the program will display histograms and rasters related to the
% timestamps.  Giving the Cluster value will result plotting the waveforms
% related to the clusters.  TM
% 3-4-06, (1) Can now use either diode timestamps or diode TTL pulses on
% channel 5. (2) Ignores extra time stamps due to Time Reversals. (3)
% Searches for apm and cluster files rather than assuming where they are.
% (4) Can accept either class or direction values from APM messages, if
% class values are detected, then they are converted to directions.  TM

% persistent trials trials2 lastfn
filename = [varargin{1},'.apm'];
channel = varargin{3};
trials = varargin{4}; % added 2006 dec 04
task_ends = varargin{5};

% the following 17 lines comment out on 2006 Dec 04
% if (isempty(trials) | ~isequal(lastfn, filename))
%     if ~isempty(which([varargin{1},'T.mat']));
%         disp('Loading T file')
%         load([varargin{1},'T.mat']);
%         trials2 = trials;
%         lastfn = filename;
%     else
%         trials = apmreaduserdata(filename);
%         trials2 = trials;
%         lastfn = filename;
%         save(['..\',varargin{1},'T.mat'], 'trials');
%     end
% else
%     trials = trials2;
%     disp('using original data file')
%     lastfn = filename;
% end

which_clusters = varargin{2};
if isempty(varargin{2})
    cal_Clusters = 2;
else
    cal_Clusters = 1;
end
maxTrLen = 0.00001;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute what cluster the waveforms belong to and put that information
% back into trails in, trials.channel.spikes.cluster.  05-10-05,TM

spikecounter = 1;
fn = filename(1:8);
monkey = fn(1:3);
cluext = '.clu.1';
% if str2num(fn(4:6) )> 114
%     fn_cluext = ['.\clusters\',fn,'_channel_',num2str(channel),'_CAT\',fn,cluext];  % full path and filename for .clu file
% else
%     fn_cluext = ['.\clusters\',fn,'_channel_',num2str(channel),'\',fn,cluext];  % full path and filename for .clu file
% end

% the follow 4 lines comment out on 2006 dec 4
% fn_cluext = which([fn,'_channel_',num2str(channel),'\',fn cluext]);
% if ~length(fn_cluext)
%     disp('could not find clu cluster files')
%     cal_Clusters = 2;
% end
conv_rate = 25/142.0455; % Constant to convert TTL Hz to diode Hz
los_counter = 0;         % Counts how many trials were lost
sal_counter = 0;         % Counts how many trials were salvaged

if length(unique([trials.dir])) > 9
    conv_dirs = 1;
else
    conv_dirs = 0;
end

dir_list = unique([trials.dir]);
if max(dir_list) < 1
    for n = 1 : length(trials)
        trials(n).dir = trials(n).dir .* 100 - 10;
    end
end

Ref_trial = 0;% XQ 2007 0104
for n = 1:100
    if trials(n).rewarded
        try
            trials(n).channels(channel).spikes(1).waveform;
            Ref_trial = n;
        end
    end
    if Ref_trial > 0
        break
    end
end

if isfield(trials(Ref_trial).channels(5),'events1') & isempty(trials(Ref_trial).channels(5).events1)
    if length(trials(Ref_trial).channels(5).timestamp) <5
        diode_loc = 'trials(n).channels(5).timestamp';
        diode_Hz = 142.0455;
    else
        diode_loc = 'trials(n).channels(5).events1';
        diode_Hz = 25;
    end
else
    diode_loc = 'trials(n).channels(5).events1';
    diode_Hz = 25;
end

if strncmpi(filename,'elv',3) & (str2num(filename(4:6)) == 235 | str2num(filename(4:6)) == 236)
    diode_loc = 'trials(n).channels(4).events1';
    diode_Hz = 25;
end

if cal_Clusters == 1
    try
        clusters = load(['C:\Users\juzhu\Documents\MATLAB\DA\Data\' monkey  '\clusters\' fn(1:7) '1_channel_' num2str(channel) '_CAT\' fn(1:7) '1.clu.1']);
    catch
        try
            clusters = load(['C:\Users\juzhu\Documents\MATLAB\DA\Data\' monkey  '\clusters\' fn(1:8) '_channel_' num2str(channel) '\' fn(1:8) '.clu.1']);
        catch
            disp(['no clu file availible for: ' fn '_channel_' num2str(channel)]);
            return
        end
    end
    
    clusters = clusters(2:end);
    unique_clusters = unique(clusters);
    n_clusters = length(unique_clusters);
    
    wf_length = length(trials(Ref_trial).channels(channel).spikes(1).waveform);
    
    for n = 1:length(trials)
        if ~isempty(trials(n).channels) & length(trials(n).channels)>=5 &  isfield(trials(n).channels(channel), 'spikes') % add ~isempty(trials(n).channels) on 2006 dec 05
            for m = 1:length(trials(n).channels(channel).spikes)
                try
                    if clusters(spikecounter) ~= which_clusters
                        trials(n).channels(channel).spikes(m).timestamp = [];
                        %                     else
                        %                         ptrials(n).channels(channel).spikes(m).waveform = trials(n).channels(channel).spikes(m).waveform;
                    end
                catch
                    disp('here')
                end
                spikecounter = spikecounter + 1;
            end
        end
        
        if conv_dirs
            if floor(mod(trials(n).dir,9)) >0
                trials(n).dir = int8(floor(mod(trials(n).dir,9)));
            else
                trials(n).dir = int8(9);
            end
            %             trials(n).dir = ceil(trials(n).dir/4);
        else
            trials(n).dir = int8(trials(n).dir);
        end
    end
else
    for n = 1:length(trials)
        if conv_dirs
            if floor(mod(trials(n).dir,9)) >0
                trials(n).dir = int8(floor(mod(trials(n).dir,9)));
            else
                trials(n).dir = int8(9);
            end
            %             trials(n).dir = ceil(trials(n).dir/4);
        else
            trials(n).dir = int8(trials(n).dir);
        end
    end
end
disp(' ')
disp(['Using channel ', num2str(channel)])
disp(' ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot here the last 100 trials. The global variable ptr is pointing to the
% last trial to be plotted
% prevptr=max([1,ptr-100]);
% nTrials=ptr-prevptr +1;
prevptr=1; %length(trials)-100
% ptr=length(trials)-1;
ptr = task_ends(1);% XQ
%ptr=20;
nTrials= ptr-prevptr+1;
dchannels=channel;
channels=channel;
tuningCurve = [];
photodiode_channel = 2;
% Local parameters
dirs = unique([trials.dir]);
numdirs = length(dirs);
maxNtr = 0;

for ch=dchannels
    maxTrLen = 5; % change from 5.1 to 7
    max_resp=0;
    hpsth=zeros(size(dirs));
    for d=dirs
        TS = [];
        TSS = [];
        % Rasters
        sel_resp=0;
        prevptr=1;
        for fn_counter = 1 : length(task_ends)
            ptr = task_ends(fn_counter);
            maxNtr = 0;
            ntr=0;
            eval(['allTS' num2str(fn_counter) ' = [];']);
            for n=prevptr:ptr
                if ((ch<=length(trials(n).channels)) & (~isempty(trials(n).dir)))      % Some channels may not be active
                    try
                        if ((trials(n).dir==d) & (trials(n).rewarded) & (length(eval(diode_loc)) > 0))% plotting fumi's set
                            ntr=ntr+1;
                            %                         allData.dir(d).ntr(ntr).syncs1 = eval(diode_loc)*diode_Hz*1e-6;
                            eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).syncs1 = eval(diode_loc)*diode_Hz*1e-6;']);% XQ
                            %                       num_syncs = length(allData.dir(d).ntr(ntr).syncs1);
                            eval(['num_syncs = length(allData' num2str(fn_counter) '.dir(d).ntr(ntr).syncs1);']); % XQ
                            %                         cue = ((allData.dir(d).ntr(ntr).syncs1(1)-1));
                            eval(['cue = ((allData' num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(1)-1));']); %XQ
                            switch cal_Clusters
                                case 1
                                    if isfield(trials(n).channels(ch), 'spikes') && ~isempty([trials(n).channels(ch).spikes])
                                        if isfield(trials(n).channels(ch), 'reversal')
                                            r_ts = 1;
                                            %                                         allData.dir(d).ntr(ntr).TS(r_ts)= (trials(n).channels(ch).spikes(r_ts).timestamp*25*1e-6)-cue;
                                            eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS(r_ts)=(trials(n).channels(ch).spikes(r_ts).timestamp*25*1e-6)-cue;']);%XQ
                                            %                                         last_ts = allData.dir(d).ntr(ntr).TS(r_ts);
                                            eval(['last_ts = allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS(r_ts);']) % XQ
                                            r_ts = r_ts + 1;
                                            while ((trials(n).channels(ch).spikes(r_ts).timestamp*25*1e-6)-cue) > last_ts
                                                %                                             allData.dir(d).ntr(ntr).TS(r_ts)=(trials(n).channels(ch).spikes(r_ts).timestamp*25*1e-6)-cue;
                                                eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS(r_ts)=(trials(n).channels(ch).spikes(r_ts).timestamp*25*1e-6)-cue;']) % XQ
                                                %                                             last_ts = allData.dir(d).ntr(ntr).TS(r_ts);
                                                eval(['last_ts = allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS(r_ts);']) % XQ
                                                r_ts = r_ts + 1;
                                            end
                                        else
                                            %                                         allData.dir(d).ntr(ntr).TS=([trials(n).channels(ch).spikes.timestamp]*25*1e-6)-cue;
                                            eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS=([trials(n).channels(ch).spikes.timestamp]*25*1e-6)-cue;']) % XQ
                                        end
                                    else
                                        eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS=[];']) % XQ
                                    end;
                                case 2
                                    if ~isempty(trials(n).channels(ch).timestamp)
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %  Check for time reversals
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        if isfield(trials(n).channels(ch), 'reversal')
                                            r_ts = 1;
                                            %allData.dir(d).ntr(ntr).TS(r_ts)=(trials(n).channels(ch).spikes(r_ts).timestamp*25*1e-6)-cue;
                                            eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS(r_ts)=(trials(n).channels(ch).spikes(r_ts).timestamp*25*1e-6)-cue;']);%XQ
                                            % last_ts = allData.dir(d).ntr(ntr).TS(1);
                                            eval(['last_ts = allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS(r_ts);']) % XQ
                                            r_ts = r_ts + 1;
                                            while allData.dir(d).ntr(ntr).TS(r_ts)>last_ts
                                                %                                             allData.dir(d).ntr(ntr).TS(r_ts)=(trials(n).channels(ch).spikes(r_ts).timestamp*25*1e-6)-cue;
                                                %                                             last_ts = allData.dir(d).ntr(ntr).TS(r_ts);
                                                eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS(r_ts)=(trials(n).channels(ch).spikes(r_ts).timestamp*25*1e-6)-cue;']) % XQ
                                                eval(['last_ts = allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS(r_ts);']) % XQ
                                                r_ts = r_ts + 1;
                                            end
                                        else
                                            % allData.dir(d).ntr(ntr).TS=([trials(n).channels(ch).spikes.timestamp]*25*1e-6)-cue;
                                            eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS=([trials(n).channels(ch).spikes.timestamp]*25*1e-6)-cue;']) % XQ
                                        end
                                        %allData.dir(d).ntr(ntr).TS=(trials(n).channels(ch).timestamp*25*1e-6)-cue;
                                        eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS=(trials(n).channels(ch).timestamp*25*1e-6)-cue;']); % XQ
                                    else
                                        %allData.dir(d).ntr(ntr).TS=[];
                                        eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS=[];']) % XQ
                                    end;
                            end
                            %                         allTS=[allTS allData.dir(d).ntr(ntr).TS];   % Put together all timestamp in a single vector
                            eval(['allTS' num2str(fn_counter) '=[allTS' num2str(fn_counter) ' allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS];']) % XQ
                            % Timestamps between videosync 2 and 3
                            if eval(['(~isempty(allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS))'])
                                eval(['ix=find((allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS>1.1) & (allData' num2str(fn_counter) '.dir(d).ntr(ntr).TS<(1.6)));']);
                                eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).sel_resp = length(ix)/.5;']);
                            end;
                            
                            if eval(['~isempty(allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1)'])
                                 eval(['allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs=[allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1-cue];']);
%                                 switch num_syncs
%                                     case 4 % change case from 3 to 4 on 2006 Dec 4 that's for the new added syncs of reaction time
%                                         eval(['allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs=[allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(1)-cue (allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(1)-cue)+.5 allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(2)-cue (allData' num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(2)-cue)+.5 allData' num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(3)-cue allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(4)-cue];']);
%                                     case 3 % add case 3 back on 2006 Dec 4, that's for the old syncs without reaction time
%                                         %                                         disp(['There were only 3 diode values on trial ',num2str(ntr)]);
%                                         eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).syncs=[allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(1)-cue (allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(1)-cue)+.5 allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(2)-cue (allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(2)-cue)+.5 allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(3)-cue];']);
%                                     case 2 % for trials without sample
%                                         %                                         disp(['There were only 2 diode values on trial ',num2str(ntr) '  trials: ', num2str(n)]);
%                                         eval(['allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs=[-1 -1 allData' num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(1)-cue (allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(1)-cue)+.5 allData' num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(2)-cue];']);
%                                     case 1 % for fumi's set
%                                         eval(['allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs=[allData' num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(1)-cue (allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(1)-cue)+.5 allData' num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(1)+1.5];' ]);
%                                     otherwise
%                                         disp(['There were more than 4 diode values on trial ',num2str(ntr), 'copy diode time from previous trial.....'])
%                                         eval(['allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs=[allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(1)-cue (allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(1)-cue)+.5 allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(2)-cue (allData' num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(2)-cue)+.5 allData' num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(3)-cue allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs1(4)-cue];']);
%                                         %                                         eval(['allData'  num2str(fn_counter) '.dir(d).ntr(ntr).syncs=allData'  num2str(fn_counter) '.dir(d).ntr(ntr-1).syncs;']);
%                                 end
                            else
                                TSS=[];
                            end;
                        end
                    catch
                        disp([lasterr,' on trial ',num2str(n)])
                    end
                end
            end;
            maxNtr = max(maxNtr, ntr);
            %Histogram
            if eval(['(~isempty(allTS' num2str(fn_counter) '))'])
                bin_width = 0.100;  % 50 milliseconds bin
                bin_edges=0:bin_width:maxTrLen;
                eval(['psth=histc(allTS' num2str(fn_counter) ',bin_edges)/(bin_width*ntr);']);
                eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).psth = psth;']);
                eval(['allData' num2str(fn_counter) '.dir(d).ntr(ntr).bins = bin_edges+0.5*bin_width;']);
            end;
            prevptr = task_ends(fn_counter) + 1;
        end
    end
end;
allData.maxTrLen = maxTrLen;

clear trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% This section is displays the data %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

max_resp = 0;
subindex = [9 3 2 1 7 13 14 15 8];
findex = ['YCDHNPST'];

for fn_counter = 1 : length( task_ends)
    max_resp = 0;
    hf = figure;
    if length(filename)> 14
        set(hf,'name',[filename(1:6) '_' num2str(fn_counter) '_channel_' num2str(channel) '_Rasters: ',num2str(which_clusters)], 'numbertitle','off')
    else
        set(hf,'name',[filename(1:8) '_channel_' num2str(channel) '_Rasters: ',num2str(which_clusters)], 'numbertitle','off')
    end
    
    clf
    eval(['dirs = 1 : length(allData' num2str(fn_counter) '.dir);']);
    for o = dirs
        try
            eval(['max_resp = max(max_resp, max([allData' num2str(fn_counter) '.dir(o).ntr(:).psth]));']);
        end
    end
    
    for m = dirs
        try
            hold on
            for n = 1:eval(['length(allData' num2str(fn_counter) '.dir(m).ntr)'])
                subplot(6,3,subindex(m))
                eval(['allData' num2str(fn_counter) '.dir(m).ntr(n).TS(find(isempty(allData' num2str(fn_counter) '.dir(m).ntr(n).TS))) = 0;']);
                
                for o = 1: eval(['length(allData' num2str(fn_counter) '.dir(m).ntr(n).TS)'])
                    eval(['line([allData' num2str(fn_counter) '.dir(m).ntr(n).TS(o),allData' num2str(fn_counter) '.dir(m).ntr(n).TS(o)],[n-.9,n-.1],''Color'', ''y'')']);
                end
                for o = 1:eval(['length(allData' num2str(fn_counter) '.dir(m).ntr(n).syncs)'])
                    eval(['line([allData' num2str(fn_counter) '.dir(m).ntr(n).syncs(o) allData' num2str(fn_counter) '.dir(m).ntr(n).syncs(o)],[n-1 n],''Color'',''k'')']);
                end
            end
            axis([0 allData.maxTrLen 0 n+1])
            axis off
            hold off
            subplot(6,3,subindex(m)+3)
            hold on
            eval(['hb = bar(allData' num2str(fn_counter) '.dir(m).ntr(n).bins,allData' num2str(fn_counter) '.dir(m).ntr(n).psth);']);
            line([0 0],[0 max_resp], 'LineWidth', 3, 'Color', 'k')
            axis([0 allData.maxTrLen -1 max_resp])
            set(hb,'EdgeColor','w');
            set(hb,'FaceColor','w');
            axis off
            %         if length(dirs) == 8
            %             title(findex(m))
            %         end
            hold off
        catch
            lasterr
        end
    end
    set(hf,'Color',[.5 .5 .5])
end