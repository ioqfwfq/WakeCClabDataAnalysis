function bb = BubbleMergerTree(bbm, bbtm)
% bb = BubbleMergerTree(bbm, bbtm)
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

bb.kernels = bbm(:,2);    % kernel ID's
bb.kp = bbm(:,3);         % kernel parents
bb.mergers = bbm(:,4);    % merger ID's
bb.mp = bbm(:,5);         % merger parents

bb.k2i = bbtm(:,2);
bb.i2k = bbtm(:,3);
bb.R_i = bbtm(:,4);
bb.id  = bbtm(:,5);

% strip off trailing 0's 
if(bb.kernels(end) == 0)
   zindx = find(bb.kernels == 0);
   bb.kernels(zindx) = [];
   bb.kp(zindx) = [];
elseif(bb.mergers(end) == 0)
   zindx = find(bb.mergers == 0);
   bb.mergers(zindx) = [];
   bb.mp(zindx) = [];
end%if

Nkernels = length(bb.kernels);
Nmergers = length(bb.mergers);
bb.Nkernels = length(bb.kernels);
bb.Nmergers = length(bb.mergers);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Make Children List (top down)
% find Tree tops and make children lists from parent list
bb.Ntops = 0;
bb.Nchildren = zeros(Nmergers,1);
for ii=1:Nmergers
   if(bb.mergers(ii) ~= bb.mp(ii))   % exclude self counts of tree tops
      jj = find(bb.mergers == bb.mp(ii));                
      bb.Nchildren(jj) = bb.Nchildren(jj) + 1;
      bb.ChildrenIndx{jj, bb.Nchildren(jj)} = ii;
      bb.Children{jj, bb.Nchildren(jj)} = bb.mergers(ii);
   else                              % count and log tree tops
      bb.Ntops = bb.Ntops + 1;
      bb.TreeTops{bb.Ntops} = bb.mergers(ii);
      bb.TreeTopsIndx{bb.Ntops} = ii;
   end%if
end%for
for ii=1:Nkernels
    jj = find(bb.mergers == bb.kp(ii));  
    if ~isempty(jj)
        bb.Nchildren(jj) = bb.Nchildren(jj) + 1;
        bb.ChildrenIndx{jj, bb.Nchildren(jj)} = ii;
        bb.Children{jj, bb.Nchildren(jj)} = bb.kernels(ii);
    else                              % count and log tree tops
        bb.Ntops = bb.Ntops + 1;
        bb.TreeTops{bb.Ntops} = bb.kernels(ii);
        bb.TreeTopsIndx{bb.Ntops} = ii;
    end%if
end%for


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Make Level List (top down)
% find and collect elements for each level
bb.Nlevels = 1;
bb.NelementsAtLevel{1} = 0;
%first, fill tree tops into first levels
for it=1:bb.Ntops
   bb.NelementsAtLevel{1} = bb.NelementsAtLevel{1} + 1;
   bb.LevelElements{bb.Nlevels,it} = bb.TreeTops{it};
   bb.LevelElementsIndx{bb.Nlevels,it} = bb.TreeTopsIndx{it};
end%for
% then, for each level, collect children of all parent level elements
while(1)
   bb.Nlevels = bb.Nlevels+1;
   bb.NelementsAtLevel{bb.Nlevels} = 0;
   for ie=1:bb.NelementsAtLevel{bb.Nlevels-1}
      el = bb.LevelElements{bb.Nlevels-1,ie};
      jj = bb.LevelElementsIndx{bb.Nlevels-1,ie};
      ISAmerger = 0;
      if(jj<= Nmergers), if(el == bb.mergers(jj)), ISAmerger = 1; end, end 
      if(ISAmerger)      % kernels don't have any children
         for ic=1:bb.Nchildren(jj)
            bb.NelementsAtLevel{bb.Nlevels} = bb.NelementsAtLevel{bb.Nlevels} + 1;
            nn = bb.NelementsAtLevel{bb.Nlevels};
            bb.LevelElements{bb.Nlevels,nn} = bb.Children{jj,ic};
            bb.LevelElementsIndx{bb.Nlevels,nn} = bb.ChildrenIndx{jj,ic};
         end%for
      end%if
   end%for
   % if there are no elements at this level it was the last one; 
   % discard it and exit while loop;
   if(bb.NelementsAtLevel{bb.Nlevels} == 0); 
      bb.NelementsAtLevel(bb.Nlevels) = [];
      bb.Nlevels = bb.Nlevels -1;
      break;   % end of while loop
   end%if
end%while

bb.ISAmerger = zeros(size(bb.LevelElements));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Member Lists (bottom up)
% find all members for each node (kernels and mergers) of a bubble tree bb
% from the bubble tree matrix bbtm
%
% start to find members of lowest levels and then at progress upwards
for lvl = bb.Nlevels:-1:1
   Nel = bb.NelementsAtLevel{lvl};
   for ie=1:Nel
      el = bb.LevelElements{lvl,ie};
      jj = bb.LevelElementsIndx{lvl,ie};
      ISAkernel = 0;
      if(jj <= bb.Nkernels), if(bb.kernels(jj) == el) ISAkernel = 1; end; end;
      if(ISAkernel)
         kIndx = find( bb.id == el );
         bb.KernelMembers{jj} = bb.k2i(kIndx);
      else % it's a merger with children
         bb.ISAmerger(lvl,ie) = 1;
         kIndx = find( bb.id == el );
         bb.MergerMembers{jj} = bb.k2i(kIndx);
         for ic = 1:bb.Nchildren(jj)
            el = bb.Children{jj,ic};
            elIndx = bb.ChildrenIndx{jj,ic};
            ISAmerger = 0;
            if(elIndx <= bb.Nmergers), if(bb.mergers(elIndx) == el) ISAmerger = 1; end; end;
            if(ISAmerger) % child it is a merger at lower level
               bb.MergerMembers{jj} = [ bb.MergerMembers{jj} ; bb.MergerMembers{elIndx} ];
            else % child is a kernel at lower level
               bb.MergerMembers{jj} = [ bb.MergerMembers{jj} ; bb.KernelMembers{elIndx} ];            
            end%if
         end%for
      end%if
      if (ISAkernel)
         bb.KernelMembers{jj} = sort(bb.KernelMembers{jj});
      else
         bb.MergerMembers{jj} = sort(bb.MergerMembers{jj});
      end%if
   end%for ie=1:Nel
end%for lvl

bb = MakeElement2LvlElLists(bb);

return




%----------------------------------------------------------------------------------------------\
function bb = MakeElement2LvlElLists(bb)
% 
% make reverse tree navigation lists 
%  bb.Merger_JJ2LvlEl{1..Nmergers} and
%  bb.Kernel_JJ2LvlEl{1..Nkernels} as well as
%  bb.ISAMerger(lvl,el),
%  bb.ISAKernel(lvl,el), 
%  bb.Rho(lvl,el) lookup array
%
% 
% that associate Kernel and Mergers 
% indexed by their position jj in bb.LevelElementsIndx{lvl,el} with their 
% position (lvl,el) in the BubbleMergerTreeGraph.
% These are the reverse lists to bb.LevelElementsIndx{lvl,el}
% and return the vector [lvl,ie] for each kernel or merger with label jj=1..Nkernels or Nmergers
%

[NL, NelMax] = size(bb.LevelElements);
bb.ISAmerger = zeros(NL,NelMax);
bb.ISAkernel = zeros(NL,NelMax);
bb.Rho = zeros(NL,NelMax);

% loop over levels starting from top lvl = 1
for lvl = 1:NL;  
    Nel = bb.NelementsAtLevel{lvl};
    for ie = 1:Nel
        jj = bb.LevelElementsIndx{lvl,ie};
        el = bb.LevelElements{lvl,ie};
        % check for anomalous high densities
        if bb.R_i(bb.k2i(el)) < eps                  % eps is matlab built in distance between 1.0 and next higher floating point number
            bb.R_i(bb.k2i(el)) = eps;          %(eps = 2.2204e-016 on 32bit machines with IEEE doubles)            
        end
        bb.Rho(lvl,ie) = 1/bb.R_i(bb.k2i(el));
        % check if element is a Merger or Kernel
        if(jj <= bb.Nmergers), if(bb.mergers(jj) == el) bb.ISAmerger(lvl,ie) = 1; end; end;
        if(bb.ISAmerger(lvl,ie))
            bb.Merger_JJ2LvlEl{jj} = [lvl ie];
        else
            bb.ISAkernel(lvl,ie) = 1;
            bb.Kernel_JJ2LvlEl{jj} = [lvl ie];
        end%if
    end%for   
end

%check for consistency
for jj=1:bb.Nkernels
   if isempty(bb.Kernel_JJ2LvlEl{jj})
      warning(['bb.Kernel_JJ2LvlEl{' num2str(jj) '} is empty!']);
   end
end
for jj=1:bb.Nmergers
   if isempty(bb.Merger_JJ2LvlEl{jj})
      warning(['bb.Merger_JJ2LvlEl{' num2str(jj) '} is empty!']);
   end
end

return
