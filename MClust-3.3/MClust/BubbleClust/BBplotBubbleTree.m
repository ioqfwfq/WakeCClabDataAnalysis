function fhbb = BBplotBubbleTree(bb)

% function fhbb = BBplotBubbleTree(bb)
%
% Construct Bars for each bubble tree node whith lenght proportional to 
% its number ob members
%
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.


[NL, NelMax] = size(bb.LevelElements);
fhbb = zeros(NL,NelMax);
BBsize = zeros(NL,NelMax);
ISAmerger = zeros(NL,NelMax);
BarL = zeros(NL,NelMax);
BarR = zeros(NL,NelMax);
BarC = zeros(NL,NelMax);
Rho = zeros(NL,NelMax);

% loop over levels starting from top lvl = 1
lvl = 1;  
BBTotSize = 0;
Nel = bb.NelementsAtLevel{lvl};
for ie = 1:Nel
   jj = bb.LevelElementsIndx{lvl,ie};
   el = bb.LevelElements{lvl,ie};
   Rho(lvl,ie) = 1/bb.R_i(bb.k2i(el));
   % check if element is a Merger or Kernel
   if(jj <= bb.Nmergers), if(bb.mergers(jj) == el) ISAmerger(lvl,ie) = 1; end; end;
   if(ISAmerger(lvl,ie))
      BBsize(lvl,ie) = length(bb.MergerMembers{jj});
   else
      BBsize(lvl,ie) = length(bb.KernelMembers{jj});
   end%if
   BBTotSize = BBTotSize + BBsize(lvl,ie);
end%for
Norm = 1/BBTotSize;
%make Bars for first level
for ie = 1:Nel
   if ie == 1
      BarL(lvl,ie) = 0.0;
   else
      BarL(lvl,ie) = BarR(lvl,ie-1);
   end%if
   BarR(lvl,ie) = BarL(lvl,ie) + Norm*BBsize(lvl,ie);
   BarC(lvl,ie) = (BarL(lvl,ie) + BarR(lvl,ie))/2;
end%for

%make Bars for lower levels
for lvl = 2:NL
   % loop over parent elements at previous levels
   ice1 = 0;
   ice2 = 0;
   Nel = bb.NelementsAtLevel{lvl-1};
   for ie = 1:Nel
      pjj = bb.LevelElementsIndx{lvl-1,ie};
      pel = bb.LevelElements{lvl-1,ie};
      % check if parent element is a Merger or Kernel
      if(ISAmerger(lvl-1,ie))
         % loop over Children of merger element
         BBChSumSize = 0;
         for ic=1:bb.Nchildren(pjj)
            ice1 = ice1 + 1;
            el = bb.Children{pjj,ic};
            jj = bb.ChildrenIndx{pjj,ic};
            Rho(lvl,ice1) = 1/bb.R_i(bb.k2i(el));
            % check if element is a Merger or Kernel
            if(jj <= bb.Nmergers), if(bb.mergers(jj) == el) ISAmerger(lvl,ice1) = 1; end; end;
            if(ISAmerger(lvl,ice1))
               BBsize(lvl,ice1) = length(bb.MergerMembers{jj});
            else
               BBsize(lvl,ice1) = length(bb.KernelMembers{jj});
            end%if
            BBChSumSize = BBChSumSize + BBsize(lvl,ice1);
         end%for
         for ic=1:bb.Nchildren(pjj)
            ice2 = ice2 + 1;
            if ic == 1
               BarL(lvl,ice2) = BarC(lvl-1,ie) - Norm*BBChSumSize/2;
            else
               BarL(lvl,ice2) = BarR(lvl,ice2-1);
            end%if
            BarR(lvl,ice2) = BarL(lvl,ice2) + Norm*BBsize(lvl,ice2);
            BarC(lvl,ice2) = (BarL(lvl,ice2) + BarR(lvl,ice2))/2;
         end%for         
      end%if
      
   end%for ie = 1:Nel
      
end% for lvl = 2:NL

bb.ISAmerger = ISAmerger;

%%%% plot Bar Tree
ncols = 120;
colormap(hot(ncols));         % make 'hot' colormap for density coding
cmap = colormap;              % retrieve cmap = [ncols x 3] color matrix 

axis([ -0.02 1.02 0 NL+1]); 
%%% axis ij;                    % revert y axis to matrix representation
fha = gca;                  % get axes handle
%set(fha,'Units','points');  % measure everything in points units
%pos = get(fha, 'Position'); % pos = [left bottom width height] of axes
%lw = pos(4)/(NL+1);         % linewidth in point units
dy = 1/2;                   % linehalfwidth in y-axis units

RhoMin = 1/max(bb.R_i);
RhoMax = 1/min(bb.R_i);   
if isnan(RhoMin), RhoMin = eps; end
if isnan(RhoMax), RhoMax = REALMAX; end
dr = (RhoMax - RhoMin)/(ncols-1); % increments for Density color coding
if(dr < eps)
    dr = eps;
end

for lvl = 1:NL
   for ie = 1:bb.NelementsAtLevel{lvl}
     
     
%%%%%% ------ modified batta 5/7/01 -----------------------


      
      ir = 1 + floor( (Rho(lvl,ie)-RhoMin)/dr ); 
      ccm = cmap(ir,:);
      if lvl == 1
	    ccm = [0 0 0];
      end
      %%%      fhl = line([BarL(lvl,ie) BarR(lvl,ie)], [lvl lvl], 'LineWidth', lw, 'Color',cmap(ir,:));
      fhl = patch([BarL(lvl,ie); BarR(lvl,ie); BarR(lvl,ie); BarL(lvl,ie)], ... 
                 [lvl + dy;     lvl + dy;     lvl - dy;     lvl - dy], ...
                 ccm, ... 
                 'LineWidth', 0.1, ...                
                 'SelectionHighlight', 'on');
      fhbb(lvl,ie) = fhl;
      set(fhl, 'UserData', ...
         [lvl ie BBsize(lvl,ie) ISAmerger(lvl,ie) ...  
          BarL(lvl,ie) BarR(lvl,ie) dy ...
          ccm(1), ccm(2), ccm(3)]);
      set(fhl, 'ButtonDownFcn', ' BBClustCallbacks');
      set(fhl, 'Tag', 'CurrentBubble');
      
      %%fhl = line([BarL(lvl,ie) BarL(lvl,ie)], [lvl-dy lvl+dy], 'LineWidth', 0.2, 'Color','k');
      %%set(fhl, 'Tag', 'BubbleOutline', 'UserData', [lvl ie]);
      %%fhl = line([BarR(lvl,ie) BarR(lvl,ie)], [lvl-dy lvl+dy], 'LineWidth', 0.2, 'Color','k');
      %%set(fhl, 'Tag', 'BubbleOutline', 'UserData', [lvl ie]);
      %%fhl = line([BarL(lvl,ie) BarR(lvl,ie)], [lvl-dy lvl-dy], 'LineWidth', 0.2, 'Color','k');
      %%set(fhl, 'Tag', 'BubbleOutline', 'UserData', [lvl ie]);
      %%fhl = line([BarL(lvl,ie) BarR(lvl,ie)], [lvl+dy lvl+dy], 'LineWidth', 0.2, 'Color','k');
      %%set(fhl, 'Tag', 'BubbleOutline', 'UserData', [lvl ie]);
   end%for ie
end%for lvl
