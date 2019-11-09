function [H1, binsUsed1, H2, binsUsed2] = GetCrossCorr(lvl1,ie1, lvl2,ie2)
%
%   [H1, binsUsed1, H2, binsUsed2] = GetCrossCorr(lvl1,ie1, lvl2,ie2)
%
%     get or calculate CrossCorrelation histos 
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

global BBClust MClust_TTData MClust_FeatureTimestamps


jj = BBClust.bb.LevelElementsIndx{lvl1,ie1};
if isempty(jj), error('Wrong lvl and ie index given!'); end%if
if(BBClust.bb.ISAmerger(lvl1,ie1))
   Bubble = BBClust.bb.MergerMembers{jj};
else
   Bubble = BBClust.bb.KernelMembers{jj};      
end
bubbleTT = MClust_FeatureTimestamps; % ncst 14 Jan 02 Range(MClust_TTData,'ts');
bubbleTS1 = bubbleTT(Bubble);

jj = BBClust.bb.LevelElementsIndx{lvl2,ie2};
if(BBClust.bb.ISAmerger(lvl2,ie2))
   Bubble = BBClust.bb.MergerMembers{jj};
else
   Bubble = BBClust.bb.KernelMembers{jj};      
end
bubbleTS2 = bubbleTT(Bubble);


[H1, binsUsed1] = CrossCorr(bubbleTS1,bubbleTS2,0.1,400);
[H2, binsUsed2] = CrossCorr(bubbleTS1,bubbleTS2,2,500);
return

