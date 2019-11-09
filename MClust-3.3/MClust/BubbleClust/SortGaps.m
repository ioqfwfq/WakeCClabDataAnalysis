function [indx, gapsize] = SortGaps(gap)
% return an index array so that gap{indx} is sorted in decesendig
% order of gapsize
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.


% sort gaps according to gapsize
nGaps = length(gap);
gapsize = zeros(1,nGaps);     % row vector
for ig = 1:nGaps
   gapsize(ig) = gap{ig}.Size;  
end%for
[x, i_ascending] = sort(gapsize);
indx = fliplr(i_ascending);

%%gap = gap(i_descending);      % sorted gap in descending order of gapsize
