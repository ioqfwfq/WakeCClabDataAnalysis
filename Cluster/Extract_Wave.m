function spike_ends = Extract_Wave(filename,varargin)
if ~length(varargin) >1
    load([filename, 'CAT.mat']);
else
    trials = varargin{1};
    task_ends = varargin{2};
end

% global trials
% comment out Golbal trials by XQ
%add length(trials(n).channels) >= poss_channels(m) on line 15 by XQ
poss_channels = CheckChannels(trials);
n_start = 1;
spikecounter = zeros(length(poss_channels),length(task_ends)+1);
spike_ends = [];
try
    for l = 1:length(task_ends)
        for m = 1:length(poss_channels)
            spikecounter(m,1)= poss_channels(m);
            for n = n_start:task_ends(l)
                if length(trials(n).channels) >= poss_channels(m) & isfield(trials(n).channels(poss_channels(m)),'spikes')
                    spikecounter(m,l+1) = spikecounter(m,l+1) + length(trials(n).channels(poss_channels(m)).spikes);
                end
            end
        end
        n_start = task_ends(l)+1;
        try
            n_stop = task_ends(l+1);
        end
    end
catch
    lasterr
end
spike_ends(:,1:2) = spikecounter(:,1:2);
for m = 1:size(spikecounter,1)
    for n = 3:size(spikecounter,2)
        spike_ends(m,n) = sum(spikecounter(m,2:n));
    end
end
% full_filename = which([filename(1:7),'1CAT.mat']);
% save(full_filename, 'trials', 'task_ends','spike_ends')
save(['C:\Users\juzhu\Documents\MATLAB\DA\Data\'  filename(1:3) '\T_file\' filename(1:7) '1CATends.mat'], 'task_ends','spike_ends')
disp(['Finish collecting and saving spike_ends for file ',filename])