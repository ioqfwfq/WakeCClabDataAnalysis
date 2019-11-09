function RescaleFigure(fh, Pos, rescaleable)
% RescaleFigure(fh, Pos, rescaleable)
%
% rescale a figure with handle fh and all its children to a matlab 
% position vector Pos = [left, bottom, width, height] 
% given in normalized units (i.e. full screen Pos = [ 0 0 1 1])
%
% 'rescalable' ~= 0 means that all units stay in normalized state
%                   otherwise the original state is restored before exit
%
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

% switch everything to normalized units:
fhall = findobj(fh);    % find all children handles in figure
saved_Units = get(fhall, 'Units');
saved_FontUnits = get(fhall(2:end), 'FontUnits');
set(fhall, 'Units', 'normalized');

% now rescale figure
set(fh, 'Position', Pos);

% switch everything back to original units:
if rescaleable; return; end
set(fhall(1), 'Units', saved_Units{1});
for ih = 2:length(fhall)
   set(fhall(ih), 'Units', saved_Units{ih});
   set(fhall(ih), 'FontUnits', saved_FontUnits{ih-1});
end%for