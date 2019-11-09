function out_tsd = TruncateWaveForms(in_tsd, chVal, tmpl, minTh, nSpikes_out)
%
% out_tsd = TrunctateWaveForms(in_tsd,tmpl,[minTh,NSpikes_out])
%
% truncates an input TSD of waveforms (nSpikes x 4 x nSamp) to the approximate
% number of output Spikes, nSpikes_out by selecting only the appropriate number
% of spikes who best match the array of template waveforms (tmpl).
%
%  INPUT:  in_tsd   ... input waveform TSD
%          chVal    ... 1x4 row vector with Channel Validity flags 
%                       (1 = valid, 0 = invalid tetrode channel)
%          tmpl     ... (nSamp x nTemlates) array of waveform templates, one column each 
%                       (nSamp = 32 by default)
%          minTh    ... minum threshold for accepted waveforms (def = 0.8)
%          nSpikes_out ... desired approximate number of output spikes 
%
%  OUTPUT: out_tsd .... truncated (subsampled) output TSD
%
% PL 2000
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.



% match waveforms to templates
% fDmax is the best matching overlap array (nSpikes x 1) in range[-1,...,1] of the waveform and the
% the best matching template
%

%process input and set default parameters
switch nargin 
case 0,1,2
   error('TruncateWaveForms needs at least 3 input arguments!');
case 3
   minTh = 0.8;         % default minum threshold for accepted waveforms
   nSpikes_out = 0;     % cut at default threshold; do NOT subsample
case 4
   nSpikes_out = 0;
case 5
   % do nothing
otherwise
   error('TruncateWaveForms was called with more than 5 input arguments!');
end

threshold = minTh;

% calculate overlaps of waveforms with best template (fDmax in range -1...1) 
fDmax = TemplateMatch(tmpl,in_tsd,chVal);

%unpack in_tsd
ts = Range(in_tsd,'ts');
wv = Data(in_tsd);
[nSpikes, nCh, nSamp] = size(wv);

if nSpikes_out > 0
   % compute threshold so that a cut in overlap produces approximately nSpikes_out output spikes
   [nn,xx] = hist(fDmax,500);
   nnsum= cumsum(nn);
   if nSpikes_out <= nSpikes 
      icut = max(find(nnsum < nSpikes - nSpikes_out))-1;
      threshold = xx(icut);
      if isempty(threshold), threshold = minTh; end;
   end
   
   % truncate all waveforms with best matching overlap < minTh
   if threshold < minTh
      threshold = minTh;
   end
end

indx_good = find(fDmax > threshold);

%make out_tsd
out_tsd = tsd(ts(indx_good), wv(indx_good,:,:));
