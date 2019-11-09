function CandList = BBFindCandidates()
%
%  CandList is a cellarray of [lvl,ie] coordinates of good pre-cluster candidates
%
% Gap cellarray of structs:
% 	gap{ig}.LvlElParent = [lvl ie];        	% parent (merger) coordinates in BubbleMergerTree   
% 	gap{ig}.LvlEl1 = [lvl ie];             	% child_1 coordinates in BubbleMergerTree 
% 	gap{ig}.LvlEl2 = [lvl ie];             	% child_2 coordinates in BubbleMergerTree 
% 	gap{ig}.TopLvlEl1 = [lvl ie];        		% top of Child_1 coordinates in BubbleMergerTree 
% 	gap{ig}.TopLvlEl2 = [lvl ie];          	% top of Child_2 coordinates in BubbleMergerTree 
% 	gap{ig}.Size = gapsize;             		% size of gap (1...Nlevels) = smaller distance to top of both children 
%
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

global BBClust 
global MClust_FeatureData MClust_ChannelValidity MClust_FeaturesToUse MClust_FeatureNames 
global MClust_TTfn MClust_TTData

% Thresholds
wfQ_th = 300;       % waveform Peak-Valley threshold
isiQ_th = 50;       % number of allowed spikes pairs in 3 msec window
WFDist1_th = 1;     % minimum required distance between waveforms at a gap
FSz_th  = 2.0;        % minimum required z-value of smaller to bigger bubble in feature space
bb = BBClust.bb;   % abbreviate for ease of typing

[NL, NelMax] = size(BBClust.bb.LevelElements);
BBClust.Candidates = zeros(NL,NelMax);


% make sorted list of Gaps in BubbleMergerTree
gap = FindGaps;
[indx, gapsize] = SortGaps(gap);


% check each pair in a gap for ISIquality, WaveForm size and separation in mean and variance
CandList{1} = [];
nCands = 0;
nGaps = length(gap);
for isorted = 1:nGaps
   ig = indx(isorted);
   disp([' Gap ' num2str(ig)]);
   keep1 = 1;
   keep2 = 1;
   lvlelc1 = gap{ig}.LvlEl1;
   lvlelc2 = gap{ig}.LvlEl2;
   
   % check WaveForm size of Children
   gap{ig}.wfQ1 = CheckWaveforms(lvlelc1);
   gap{ig}.wfQ2 = CheckWaveforms(lvlelc2);
   if gap{ig}.wfQ1(3) < wfQ_th, keep1 = 0; end    % reject c1 if waveform is too small 
   if gap{ig}.wfQ2(3) < wfQ_th, keep2 = 0; end    % reject c2 if waveform is too small 
   
   % check ISIQuality of Children
   gap{ig}.isiQ1 = CheckISI(lvlelc1);
   gap{ig}.isiQ2 = CheckISI(lvlelc2);
   if gap{ig}.isiQ1(3) > isiQ_th, keep1 = 0; end    % reject c1 if isi is dirty 
   if gap{ig}.isiQ2(3) > isiQ_th, keep2 = 0; end    % reject c2 if isi is dirty 

   % get bubble properties in feature space

   [gap{ig}.WFDist1, gap{ig}.WFDist2] = WaveformDistance(lvlelc1, lvlelc2);
   if gap{ig}.WFDist1 < WFDist1_th
      % reject both bubbles if their waveforms overlap completely
      keep1 = 0; 
      keep2 = 0; 
   end     
   
   [gap{ig}.FSDist, gap{ig}.dAv, gap{ig}.sig1, gap{ig}.sig2] = FeatureSpaceDistance(lvlelc1, lvlelc2);
   gap{ig}.FSz = gap{ig}.dAv / max(gap{ig}.sig1,gap{ig}.sig2);
   if gap{ig}.FSz < FSz_th
      % reject both bubbles if their Feature Space z distance is smaller then threshold
      keep1 = 0; 
      keep2 = 0; 
   end     

   
   % put Candidates in list
   if keep1
      nCands = nCands+1;
      CandList{nCands} = lvlelc1;
   end
   if keep2
      nCands = nCands+1;
      CandList{nCands} = lvlelc2;
   end
      
end% for ig


%Keep only Candidates at lowest levels
ic = 0;
while 1
   nCands = length(CandList);
   ic = ic + 1;
   if ic > nCands, break; end;
   plvlel = CandList{ic};
   ChildList = FindChildren(plvlel, CandList);
   CandList(ChildList) = [];               % remove children from list
end

BBClust.Gap = gap;

return


%--------------------------------------------------------------------------------------------
function WFQuality = CheckWaveforms(lvlel)
% WFQuality = [ r1 r2 r3] where
% r1 = max amplitude (size of largest peak)
% r2 = min amplitude (depth of deepest valley)
% r3 = r1-r2 , Peak - Valley
%  
global MClust_ChannelValidity

lvl = lvlel(1);
ie = lvlel(2);

chv = find(MClust_ChannelValidity == 1);
[wfm wferr] = GetWaveforms(lvl,ie);
w = wfm(chv,:);  
r1 = max(max(w));
r2 = min(min(w));
r3 = r1-r2;
WFQuality = [ r1 r2 r3];
return


%--------------------------------------------------------------------------------------------
function [WFDist1, WFDist2] = WaveformDistance(lvlel1, lvlel2)
% Distance 1 between two waveforms is defined as
% the maximum of the absolute differences of their means divided by 
% the SMALLER of their variances (essentiall analogous to the maximum zscore 
% of the smaller bubble with respect to larger one (smaller variances))
% 
% Distance 2 is analogous to distance 1 but the differences of means are
% divided by the LARGER of their variances (maximum zscore of the larger bubble with 
% respect to the smaller one (larger variances))
%
global MClust_ChannelValidity

chv = find(MClust_ChannelValidity == 1);
lvl1 = lvlel1(1);
ie1 = lvlel1(2);
lvl2 = lvlel2(1);
ie2 = lvlel2(2);

[wfm1, wferr1] = GetWaveforms(lvl1,ie1);
[wfm2, wferr2] = GetWaveforms(lvl2,ie2);
z12 = abs(wfm1(chv,:)-wfm2(chv,:));  
stdmin = min(wferr1(chv,:),wferr2(chv,:));
stdmax = max(wferr1(chv,:),wferr2(chv,:));
WFDist1 = max(max(z12./stdmin));
WFDist2 = max(max(z12./stdmax));
return


%--------------------------------------------------------------------------------------------
function [FSDist, dAv, sig1, sig2] = FeatureSpaceDistance(lvlel1, lvlel2)
% Distance  between two bubbles is defined as
% the length of the vector between their means  minus 
% the SUM of their standard deviations in direction of the line between the means.
% In geometrical terms: the length of segment of the line connecting the two
% bubble means which is in between the std = 1 hyperellipsiods.
% If the FSDist is negative, the two ellipsoids overlap!
% 
% dAv = length of distance between the two means
% sig1 = std of bubble 1 in direction of vector that connects the two means
% sig2 = std of bubble 2 in direction of vector that connects the two means

[fav1, fcov1] = GetFeaturesAvCov(lvlel1);
[fav2, fcov2] = GetFeaturesAvCov(lvlel2);

rvec12 = fav2 - fav1;
dAv = norm(rvec12);
rvec12 = rvec12/dAv;
sig1 = sqrt(rvec12*fcov1*rvec12');
sig2 = sqrt(rvec12*fcov2*rvec12');
FSDist = dAv - sig1 - sig2;
return



%--------------------------------------------------------------------------------------------
function ISIQuality = CheckISI(lvlel)
% ISIQuality = [ n1 n2 n3] where
% n1 = percentage  of ISIs in bins < 1 msec
% n2 = percentage of ISIs in bins < 2 msec
% n3 = percentage of ISIs in bins < 3 msec
%  
global BBClust

lvl = lvlel(1);
ie = lvlel(2);

if ~exist('BBClust.bb.nMembers')
   BBClust.bb.nMembers = zeros(size(BBClust.bb.LevelElements));
end

jj = BBClust.bb.LevelElementsIndx{lvl,ie};
if BBClust.bb.ISAmerger(lvl,ie)
   BBClust.bb.nMembers(lvl,ie) = length(BBClust.bb.MergerMembers{jj});
else
   BBClust.bb.nMembers(lvl,ie) = length(BBClust.bb.KernelMembers{jj});
end

[H, binsUsed] = GetISI(lvl,ie);
ISIQuality = zeros(1,3);
for isec = 1:3 
   ISIQuality(isec) = 100*sum(H(find(binsUsed <= isec)))/BBClust.bb.nMembers(lvl,ie);
end
return
  
  
  
  
%--------------------------------------------------------------------------------------------
function [wfm, wferr] = GetWaveforms(lvl,ie)
%
% get or calculate waveforms
global BBClust MClust_TTData

if(isempty(BBClust.WaveForms{lvl,ie}))
   bbData = get(BBClust.fhbb(lvl,ie), 'UserData'); 
   ISAmerger = bbData(4);
   jj = BBClust.bb.LevelElementsIndx{lvl,ie};
   if(ISAmerger)
      Bubble = BBClust.bb.MergerMembers{jj};
   else
      Bubble = BBClust.bb.KernelMembers{jj};      
   end
   bubbleTT = ExtractBubbleFromTT(Bubble, MClust_TTData);
   
   [wfm, wferr] = AverageWaveform(bubbleTT);
   BBClust.WaveForms{lvl,ie} = {wfm, wferr};
else
   mANDerr = BBClust.WaveForms{lvl,ie};
   wfm = mANDerr{1};
   wferr = mANDerr{2};
end%if
return


%--------------------------------------------------------------------------------------------
function [fav, fcov] = GetFeaturesAvCov(lvlel)
%
% get or calculate means fav and covariances fcov for the bubbles featuredata
global BBClust MClust_FeatureData

lvl = lvlel(1);
ie = lvlel(2);

if ~exist('BBClust.FdAvCov','var')
   [NL, NelMax] = size(BBClust.bb.LevelElements);
   BBClust.FdAv = cell(NL,NelMax);
   BBClust.FdCov = cell(NL,NelMax);
end

if(isempty(BBClust.FdAv{lvl,ie}))
   bbData = get(BBClust.fhbb(lvl,ie), 'UserData'); 
   ISAmerger = bbData(4);
   jj = BBClust.bb.LevelElementsIndx{lvl,ie};
   if(ISAmerger)
      Bubble = BBClust.bb.MergerMembers{jj};
   else
      Bubble = BBClust.bb.KernelMembers{jj};      
   end
   bubbleFD = MClust_FeatureData(Bubble,:);
   fav = mean(bubbleFD);
   fcov = cov(bubbleFD);
   BBClust.FdAv{lvl,ie} = fav;
   BBClust.FdCov{lvl,ie} = fcov;
else
   fav = BBClust.FdAv{lvl,ie};
   fcov = BBClust.FdCov{lvl,ie};
end%if
return



%--------------------------------------------------------------------------------------------
function [H, binsUsed] = GetISI(lvl,ie)
%   
% get or calculate ISI histos 
global BBClust MClust_TTData

if(isempty(BBClust.ISI{lvl,ie}))
   bbData = get(BBClust.fhbb(lvl,ie), 'UserData'); 
   ISAmerger = bbData(4);
   jj = BBClust.bb.LevelElementsIndx{lvl,ie};
   if(ISAmerger)
      Bubble = BBClust.bb.MergerMembers{jj};
   else
      Bubble = BBClust.bb.KernelMembers{jj};      
   end
   bubbleTT = ExtractBubbleFromTT(Bubble, MClust_TTData);
   bubbleTS = ts(Range(bubbleTT, 'ts'));
   
   [H, binsUsed] = HistISI(bubbleTS);
   BBClust.ISI{lvl,ie} = {H, binsUsed};
else
   hist = BBClust.ISI{lvl,ie};
   H = hist{1};
   binsUsed = hist{2};
end%if      
return



%---------------------------------------------------------------------------------------------
function true = IsAChild(plvl,pie, clvl,cie)
%
% tests if the bubble at clvl,cie is a child of the (parent) bubble plvl,pie
%  
%  true .... 1 (yes)
%            0  (no)
%
% requires BBPlotBubbleTree to be executed first!

global BBClust 

true = 0;

if (plvl >= clvl)
   true = 0;
   warning([ 'Parent level ' plvl ' is >=  child level ' clvl '. Comparison is meaningless!']);
   return   
end	


%get parent info 
bbData = get(BBClust.fhbb(plvl,pie), 'UserData'); 
p_ISAmerger = bbData(4);
p_BarL = bbData(5);
p_BarR = bbData(6);
if ~p_ISAmerger
   % if parent is not a merger, it can't have any children!
   true = 0;
   return
end

%get child info 
bbData = get(BBClust.fhbb(clvl,cie), 'UserData'); 
c_BarL = bbData(5);
c_BarR = bbData(6);
c_BarC = (c_BarL + c_BarR)/2;

% if center of bubble is within the parent bar it is a child
if c_BarC >= p_BarL & c_BarC <= p_BarR
   true = 1;
end

return


%--------------------------------------------------------------------------------------------
function ChildList = FindChildren(plvlel,CandList)
% Finds adresses of all children of a parent Bubble lvlel = [lvl ie] in CandList
%
ChildList = [];
for ic = 1:length(CandList)
   clvlel = CandList{ic}; 
   if clvlel(1) > plvlel(1) 
	  if  IsAChild(plvlel(1),plvlel(2), clvlel(1),clvlel(2))
   	  ChildList(end+1) = ic; 
     end
   end
end
return



%---------------------------------------------------------------------------------------------
function [clvl,cie] = FindTopLevel(plvl,pie)
%
% returns the first kernel with highest level rank that is also a child of bubble (plvl,pie).
% Essentially returns the kernel which is the 'highest top' in the BubbleTree plot.
% If there are several child kernels at the same level, the 'most left' (smallest cie) is returned.
%
% This function is inteded as a service for the GAP finder
%
% requires BBPlotBubbleTree to be executed first!

global BBClust;

% in case no top child exists, return the parent element (which must be a kernel) 
clvl = plvl;
cie = pie;

%loop over all elements  from the TOP towards the Parent until a child is found
% this child must be the highest TOP child
for lvl = BBClust.bb.Nlevels:-1:plvl-1 
	 for ie = 1:BBClust.bb.NelementsAtLevel{lvl}
      if IsAChild(plvl,pie, lvl,ie)
         clvl = lvl;
         cie = ie;
         return
      end%if
    end
end


%---------------------------------------------------------------------------------------------
function gap = FindGaps()
%
% returns a sorted list of 'Gaps' in the Bubble Tree.
%
% A GAP between two children of a merger is defined by the smaller number of levels
% from each child to its respective top (i.e. the smaller of numbers of bars on top of each child).
% If at least ONE of the two children is a kernel, the GAP is 1 (no bars o top of a kernel).
% If both are mergers, the GAP is at least 1 and equals.
%
%
% requires BBPlotBubbleTree to be executed first!

global BBClust;

bb = BBClust.bb;
[NL, NelMax] = size(bb.LevelElements);

% define gap list of structs
gap{1}.LvlElParent = [];    
gap{1}.LvlEl1 = [];
gap{1}.LvlEl2 = [];
gap{1}.TopLvlEl1 = [];
gap{1}.TopLvlEl2 = [];
gap{1}.Size = 0;
nGaps = 0;

% loop over levels starting from bottom lvl = 1
for lvl = 1:NL;  
   Nel = bb.NelementsAtLevel{lvl};
   for ie = 1:Nel
      jj = bb.LevelElementsIndx{lvl,ie};
      el = bb.LevelElements{lvl,ie};
      % check if element is a Merger or Kernel
      if(bb.ISAkernel(lvl,ie))
         % it is a kernel with no children;
      else
         % it is a merger with at least 2 children and gap >= 1
         % loop over all pairs of children
         for ic1 = 1:bb.Nchildren(jj)-1
            jj_c1 = bb.ChildrenIndx{jj,ic1};
            el_c1 = bb.Children{jj,ic1};
            % check if element is a Merger or Kernel
            ISAmerger=0; if(jj_c1 <= bb.Nmergers), if(bb.mergers(jj_c1) == el_c1) ISAmerger = 1; end; end;
            if(ISAmerger)
               lvlel = bb.Merger_JJ2LvlEl{jj_c1};
               lvl_c1 = lvlel(1);
               ie_c1 = lvlel(2); 
               [lvl_c1top,ie_c1top] = FindTopLevel(lvl_c1,ie_c1);
            else
               % kernels are their own tops
               lvlel = bb.Kernel_JJ2LvlEl{jj_c1};
               lvl_c1 = lvlel(1);
               ie_c1 = lvlel(2); 
               lvl_c1top = lvl_c1;    
               ie_c1top = ie_c1;
            end%if
            
            %loop over all children ahead of ic1
            for ic2 = ic1+1:bb.Nchildren(jj)
               jj_c2 = bb.ChildrenIndx{jj,ic2};
               el_c2 = bb.Children{jj,ic2};
               % check if element is a Merger or Kernel
               ISAmerger=0; if(jj_c2 <= bb.Nmergers), if(bb.mergers(jj_c2) == el_c2) ISAmerger = 1; end; end;
               if(ISAmerger)
                  lvlel = bb.Merger_JJ2LvlEl{jj_c2};
                  lvl_c2 = lvlel(1);
                  ie_c2 = lvlel(2); 
                  [lvl_c2top,ie_c2top] = FindTopLevel(lvl_c2,ie_c2);
               else
                  % kernels are their own tops
                  lvlel = bb.Kernel_JJ2LvlEl{jj_c2};
                  lvl_c2 = lvlel(1);
                  ie_c2 = lvlel(2); 
                  lvl_c2top = lvl_c2;    
                  ie_c2top = ie_c2;
               end%if
               
               % check level consistency
               if lvl_c1 ~= lvl_c2
                  warning(['Inconsistent Child levels ' num2str(lvl_c1) ' ' num2str(lvl_c2) ' in gap search!']);
               end
               
               % now compare child ic1 with ic2 and record gap >= 1
               nGaps = nGaps + 1;
               gap{nGaps}.LvlElParent = [lvl,ie];
				   gap{nGaps}.LvlEl1 = [lvl_c1,ie_c1];
               gap{nGaps}.LvlEl2 = [lvl_c2,ie_c2];
               gap{nGaps}.TopLvlEl1 = [lvl_c1top,ie_c1top];
               gap{nGaps}.TopLvlEl2 = [lvl_c2top,ie_c2top];
               gap{nGaps}.Size = 1 + min(lvl_c1top-lvl_c1, lvl_c2top-lvl_c2);
               
            end%for ic2
         end%for ic1
         
      end%if ISAkernel
   end%for ie
end%for lvl

% sort gaps according to gapsize
%%gapsize = zeros(1,nGaps);     % row vector
%%for ig = 1:nGaps
%%   gapsize(ig) = gap{ig}.Size;  
%%end%for
%%[x, i_ascending] = sort(gapsize);
%%i_descending = fliplr(i_ascending);
%%gap = gap(i_descending);      % sorted gap in descending order of gapsize

return


%==========================================================
function bubbleTT = ExtractBubbleFromTT(bubble, TT)

TIME = Range(TT, 'ts');
DATA = Data(TT);
bubbleTT = tsd(TIME(bubble), DATA(bubble, :, :));

   