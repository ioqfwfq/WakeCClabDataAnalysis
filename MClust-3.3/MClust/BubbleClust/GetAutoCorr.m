function [H1, binsUsed1, H2, binsUsed2] = GetAutoCorr(lvl,ie)
%   
% get or calculate ISI histos 
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

global BBClust MClust_TTData MClust_FeatureTimestamps

if ~exist('BBClust.AutoCorr'), BBClust.AutoCorr = cell(size(BBClust.bb.LevelElements)); end

if(isempty(BBClust.AutoCorr{lvl,ie}))
   jj = BBClust.bb.LevelElementsIndx{lvl,ie};
   if(BBClust.bb.ISAmerger(lvl,ie))
      Bubble = BBClust.bb.MergerMembers{jj};
   else
      Bubble = BBClust.bb.KernelMembers{jj};      
   end
   bubbleTT = MClust_FeatureTimestamps; %ncst 14 Jan 02 Range(MClust_TTData,'ts');
   bubbleTS = bubbleTT(Bubble);
   
   [H1, binsUsed1] = AutoCorr(bubbleTS,0.2,100);
   [H2, binsUsed2] = AutoCorr(bubbleTS,2,500);
   BBClust.AutoCorr{lvl,ie} = {H1, binsUsed1, H2, binsUsed2};
else
   hist = BBClust.AutoCorr{lvl,ie};
   H1 = hist{1};
   binsUsed1 = hist{2};
   H2 = hist{3};
   binsUsed2 = hist{4};
end%if      
return

