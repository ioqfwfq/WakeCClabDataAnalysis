function poss_chan = CheckChannels(trials)
% global trials
poss_chan = 0;
for n = 1:length(trials(1).channels)
    try
        if length(trials(1).channels(n).spikes) > 0
            poss_chan(n,1) = n;
        end
    end
end
poss_chan = unique(poss_chan(poss_chan ~= 0));