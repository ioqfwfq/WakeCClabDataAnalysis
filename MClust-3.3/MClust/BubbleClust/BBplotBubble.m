function BBplotBubble(bb,ffd,level,element,col)
% BBplotBubble(bb,ffd,level,element,col)
%
% LIPA 1999
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

jj = bb.LevelElementsIndx{level,element};
el = bb.LevelElements{level,element};
if isempty(jj) 
   disp(' Element at given level is empty !');
   return;
end

% check if element is a Merger or Kernel
ISAmerger = 0;
if(jj <= bb.Nmergers), if(bb.mergers(jj) == el) ISAmerger = 1; end; end;

if(ISAmerger)
   ii = bb.MergerMembers{jj};
else
   ii = bb.KernelMembers{jj};
end%if

plot(ffd(ii,1),ffd(ii,2),'o','Markersize',1,'Color',col);

