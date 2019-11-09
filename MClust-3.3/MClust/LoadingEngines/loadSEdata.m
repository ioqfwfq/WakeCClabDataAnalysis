function [t,varargout]=loadSEdata(filename, varargin)

%this is an interimistic loading engine for MClust. You must change the
%apm channel to load from (specified below) before using and also switch off
%channel validity for MClust channels 2 through 4.

data = ApmReadUserData(filename);
t_stamps = [];
for n=1:length(data)
    t_stamps = [t_stamps data(n).channels(2).spikes.timestamp].*(25/1000000); %in secs
end

wv = [];
for m=1:length(data)
    for n=1:length(data(m).channels(2).spikes)
        wv = [wv data(m).channels(2).spikes(n).waveform' zeros(1,3*length(data(m).channels(2).spikes(n).waveform)];
    end
end

if nargin==1 & nargout==1, t = t_stamps; end
if nargin==1 & nargout==2, t = t_stamps;, varargout = wv; end

%if nargin==2, disp('not enough input!'), end

if nargin==3
    switch varargin{2}
        case(1) %this one is a little tricky because the same timestamp might occur more than one time... for now, I pick the first match
            t = varargin{1};
            wv2 = [];
            match = [];
                for n=1:length(t_stamps)
                    if any(t_stamps(n)==varargin{1}) & ~any(t_stamps(n)==match),...
                       wv2 = [wv2 wv(((n-1)*70*4+1):((n-1)*70*4)+4*70)]; match = [match t_stamps(n)]; end
                end
            end
            varargout = wv2;
            
        case(2)
