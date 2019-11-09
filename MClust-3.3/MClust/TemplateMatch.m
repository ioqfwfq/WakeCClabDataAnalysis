function [fDmax,fData,fNames,tmpl_n,wstd] = TemplateMatch(tmpl,wvtsd,ttChannelValidity)
%
%  [fDmax,fData,fNames,tmpl_n,wstd] = TemplateMatch(tmpl,wvtsd,ttChannelValidity)
%
%  template matching 
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

[nSamp_t,nPC] = size(tmpl); 

%normalize template array 
av=mean(tmpl);      % average across 32 sample points
sdev=std(tmpl);     % standard deviation of the 32 sample points
norm = repmat(sdev,nSamp_t,1);     % l2 norm
tmpl_n = (tmpl-repmat(av,nSamp_t,1))./norm;  % waveform normalized to zero mean and unit variance

% allow wvtsd to be either a tsd or double nSpikes*nCh*nSamp array
if strcmpi(class(wvtsd), 'tsd')
   TTData = Data(wvtsd);
else
   TTData = wvtsd;
end
[nSpikes, nCh, nSamp] = size(TTData);

if nSamp ~= nSamp_t
   error('TemplateMatch Error: Number of sample points of data and templates do NOT match !');
end


f = find(ttChannelValidity);
lf = length(f);

fNames = cell(lf, 1); 
fData  = zeros(nSpikes, lf);

for iC = 1:lf
   w = squeeze(TTData(:,f(iC),:));    % get data in nSpikes x nSamp array
   
 	% normalize waveforms to unit L2 norm (so that only their SHAPE or
 	% relative angles but not their length (energy) matters)
   av = mean(w,2);                %  mean vector  (nSikes x 1 col vector
 	l2norms = std(w,0,2);            % standard deviation (nSpikes x 1 col vector)
   wstd = (w-repmat(av,1,nSamp))./repmat(l2norms,1,nSamp);
    
   wpc = wstd*tmpl_n/(nSamp-1);  % project data onto templates component axes and normalize as unbiased estimator
   fData(:,(iC-1)*nPC+1:iC*nPC) = wpc(:,1:nPC);
   for iPC = 1:nPC
     fNames{(iC-1)*nPC + iPC} = ['Tmpl' num2str(iPC) ': ' num2str(f(iC))];
   end
end
fDmax = max(fData')';   % find the maximum overlap among all templates