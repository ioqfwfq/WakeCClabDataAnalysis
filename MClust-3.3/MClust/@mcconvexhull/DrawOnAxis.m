function DrawConvexHull(MCC, xdim, ydim, color)

% mcconvexhull/DrawConvexHull(MCC, xd, yd, color)
%
% ADR 1998
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

if ~isempty(MCC.xdims)
   iL = find(MCC.xdims == xdim & MCC.ydims == ydim);
   if ~isempty(iL)
      h = plot(MCC.cx{iL}, MCC.cy{iL}, '-');
      set(h, 'Color', color);
   end
end
