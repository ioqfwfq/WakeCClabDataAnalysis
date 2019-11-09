function ShowWaveforms(iClust)
% ShowWaveforms(iClust)
%
%
% INPUTS
%    wv -- tsd of tt or waveform data
%
% OUTPUTS
%
% NONE
%
WVD = Data(WV);
if length(WVD(:,1,1)) > 1000
if nargout == 0 | strcmp(DoPlotYN,'yes')  % no output args, plot it
    for it = 1:4
        xrange = ((size(WVD,3) + 2) * (it-1)) + (1:size(WVD,3)); 
        hold on;
    end
    axis off
    axis([0 4*(size(WVD,3) + 2) -2100 2100])
    title(['Waveforms -- ' num2str(maxPts) ' of ' num2str(length(WVD(:,1,1))) ' waveforms shown']);
    hold off
end