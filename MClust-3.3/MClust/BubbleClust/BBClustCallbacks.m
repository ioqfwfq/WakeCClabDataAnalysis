function BBClustCallbacks(varargin)

% Callbacks for BBClustDecisionWindow


% Persistent variables
global BBClust 

% Callback object's handle
%%%%%% ------ modified batta 5/7/01 -----------------------
if ~isempty(varargin)
  figHandle = findobj('Tag', 'BBClustDecisionWindow');
  cboHandle = [];
  callbackTag = varargin{1};
else
  
  cboHandle = gcbo;
  figHandle = gcf;
  callbackTag = get(cboHandle, 'Tag');
end

switch callbackTag 

case 'BBClustDecisionWindow'
   % turn off Waveform Axes 
%%   fha = findobj('Tag', 'AverageWaveformAxis'); 
%%   axes(fha); 
%%   axis off;

case 'LoadBBFiles'
    
    global MClust_FeatureData MClust_ChannelValidity MClust_FeaturesToUse ...
    MClust_FeatureNames MClust_TTfn MClust_TTData

    %%%%%% ------ modified batta 5/7/01 -----------------------
    global BBClustFilePrefix;
    global BBClustFileDir;

    % load Bubble Tree file
   if isempty(BBClustFilePrefix)
     [fn1, dn1] = uigetfile('*.bbt', 'Full bubble tree file');
   else
     fn1 = [BBClustFilePrefix '.bbt'];
     dn1 = BBClustFileDir;
   end
   if fn1
      if dn1
          pushdir(dn1); 
      end
      if exist(fn1,'file')
          BBClust.bbtm = LoadASCIIMatrix(fn1);
      else
          [fn1, dn1] = uigetfile('*.bbt', 'Full bubble tree file');
          if fn1
              BBClust.bbtm = LoadASCIIMatrix(fn1);
          else
              return
          end
      end
   else
      return;
   end%if
   %load Bubble Tree Nodes and Merger file
   [dn, fn, ext] = fileparts(fn1);
   
   if isempty(BBClustFilePrefix)
     [fn2, dn2] = uigetfile('*.bbn', 'Bubble tree nodes file');
   else
     fn2 = [BBClustFilePrefix '.bbn'];
     dn2 = BBClustFileDir;
   end
     
     
   if fn2
      if dn2; cd(dn2); end
      BBClust.bbnm = LoadASCIIMatrix(fn2);
      set(cboHandle, 'Value', 1);
      set(cboHandle, 'String', ['(' fn1 ', ' fn2 ')']);
   else
      set(cboHandle, 'Value', 0);
      set(cboHandle, 'String', ['Load Bubble Tree files']);
      return;
   end
   setptr(gcf, 'watch');
   BBClust.bb = BubbleMergerTree(BBClust.bbnm, BBClust.bbtm);
   
   % initialze global BBClust
   if ~isempty(dn1)
       BBClust.Fname = fullfile(dn1,fn);
   else
       BBClust.Fname = fn;
   end
   BBClust.FnameString = get(findobj(figHandle,'Tag','LoadBBFiles'), 'String');
   [NL, NelMax] = size(BBClust.bb.LevelElements);
   BBClust.keep = zeros(NL,NelMax);
   BBClust.show = zeros(NL,NelMax);
   BBClust.showcolors = zeros(NL,NelMax,3);
   BBClust.WaveForms = cell(NL,NelMax);
   BBClust.ISI = cell(NL,NelMax);
   BBClust.Stats = cell(NL,NelMax);
   BBClust.fhbbdots = cell(NL,NelMax);
   BBClust.hold = cell(2,2);
   % initialze zoom state
   BBClust.ZoomON = 0;
   zoom off;
   set(findobj(figHandle, 'Tag', 'Zoom'), 'Value', 0);
   % clear all axes from previous sessions
   fhaxes = findobj(figHandle, 'Type', 'axes');
   for ia = 1:length(fhaxes)
      axes(fhaxes(ia));
      cla;
   end
   % clear Stats, Keep, Level and ID boxes
   StatsTextHandle = findobj(figHandle, 'Tag', 'StatisticsText');
   set(StatsTextHandle, 'String', '');
   keepHandle = findobj(figHandle, 'Tag', 'KeepBubble');
   set(keepHandle, 'Value', 0);
   LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
   set(LevelEditHandle, 'String', '');
   IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
   set(IDEditHandle, 'String', '');
   set(findobj(figHandle, 'Tag','Hold 1'), 'Value', 0);
   set(findobj(figHandle, 'Tag','Hold 2'), 'Value', 0);

   % load Axes ListBoxes
   fhlb = findobj(figHandle, 'Tag', 'FeatureX');
   set(fhlb, 'String', MClust_FeatureNames);
   BBClust.xdim = 1;                           % x dimemsion to plot
   fhlb = findobj(figHandle, 'Tag', 'FeatureY');
   set(fhlb, 'String', MClust_FeatureNames);
   BBClust.ydim = 2;   
   set(fhlb, 'Value', BBClust.ydim );    % y dimemsion to plot
   setptr(gcf, 'arrow');




case 'RedrawBubbleTree'

   global MClust_FeatureNames

   setptr(figHandle, 'watch');
   % clear all axes from previous sessions
   fhaxes = findobj(figHandle, 'Type', 'axes');
   for ia = 1:length(fhaxes)
      axes(fhaxes(ia));
      cla;
   end
   fha = findobj(figHandle, 'Tag', 'BubblePlotAxes');
   axes(fha);
   set(fha, 'XLimMode','auto','YLimMode','auto');
   % reinitialze zoom state
   BBClust.ZoomON = 0;
   zoom off;
   set(findobj(figHandle, 'Tag', 'Zoom'), 'Value', 0);
   % clear Stats, Keep, Level and ID boxes
   StatsTextHandle = findobj(figHandle, 'Tag', 'StatisticsText');

   set(StatsTextHandle, 'String', '');
   [NL, NelMax] = size(BBClust.bb.LevelElements);
   BBClust.keep = zeros(NL,NelMax);
   keepHandle = findobj(figHandle, 'Tag', 'KeepBubble');
   set(keepHandle, 'Value', 0);
   LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
%%%%%% ------ modified batta 5/7/01 -----------------------
   set(LevelEditHandle, 'String', '1');
   IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
%%%%%% ------ modified batta 5/7/01 -----------------------
   set(IDEditHandle, 'String', '1');
   set(findobj(figHandle, 'Tag','Hold 1'), 'Value', 0);
   set(findobj(figHandle, 'Tag','Hold 2'), 'Value', 0);
   %unhighlight last Current Bubble
   last_fhbb = findobj(figHandle, 'Tag', 'CurrentBubble', 'Selected', 'on');
   if ~isempty(last_fhbb) set(last_fhbb , 'Selected', 'off'); end;
   % setup BubblePlotAxes
   fha = findobj(figHandle, 'Tag', 'BubblePlotAxes');
   axes(fha);
   for lvl = 1:BBClust.bb.Nlevels
      for ie = 1:BBClust.bb.NelementsAtLevel{lvl}
         BBClust.fhbbdots{lvl,ie} = ...
            line(0, 0, ...
            'Marker', '.', 'MarkerSize', 1,...
            'LineStyle', 'none',...
            'Color', 'k',...
            'ButtonDownFcn', 'BBClustCallbacks',...
            'SelectionHighlight', 'on', ...
            'Tag', 'BubbleDots');
      end%for ie
   end%for lvl
   % load Axes ListBoxes
   fhlb = findobj(figHandle, 'Tag', 'FeatureX');
   set(fhlb, 'String', MClust_FeatureNames);
   BBClust.xdim = 1;                           % x dimemsion to plot

   fhlb = findobj(figHandle, 'Tag', 'FeatureY');
   set(fhlb, 'String', MClust_FeatureNames);
   BBClust.ydim = 2;
   set(fhlb, 'Value', BBClust.ydim );    % y dimemsion to plot

   % plot Bubble Tree
   fha = findobj(figHandle, 'Tag', 'DecisionTree');  
   axes(fha);
   BBClust.fhbb = BBplotBubbleTree(BBClust.bb);
   if BBClust.ZoomON
      setptr(figHandle, 'glass');
   else
      setptr(figHandle, 'arrow');
   end%if


case 'Save'
   global BBClustFileDir BBClustFilePrefix
   % Save current state of window
   setptr(figHandle,'watch');   
   % first turn off zoom (just in case)
   zoom off;
   BBClust.ZoomON = 0;
   % save SHOWS and their colors
   for lvl = 1:BBClust.bb.Nlevels
      for ie = 1:BBClust.bb.NelementsAtLevel{lvl}
         if(length(get(BBClust.fhbbdots{lvl,ie}, 'XData')) ~= 1)
            BBClust.show(lvl,ie) = 1;
            BBClust.showcolors(lvl,ie,:) = get(BBClust.fhbb(lvl,ie), 'FaceColor');
         end%if   
      end%for
   end%for
   % now do the actual save of the  global BBClust struct
   fn = [BBClustFileDir filesep BBClustFilePrefix]; %BBClust.Fname;
   fn
   [fn1, dn1] = uiputfile([fn '.bbd'], 'Save BuBBle Decision file');
   if fn1
      save_fname = fullfile(dn1,fn1);
      save(save_fname, 'BBClust');
   end%if
   setptr(figHandle,'arrow');   

   

case 'Load'

   global MClust_FeatureData MClust_FeatureNames

   setptr(gcf, 'watch');
   [fn1, dn1] = uigetfile('*.bbd', 'BuBBle Decision file');
   if fn1
      if dn1; cd(dn1); end
      load(fn1,'-mat');
      fhFileChkBox = findobj(figHandle,'Tag','LoadBBFiles');
      set(fhFileChkBox, 'Value', 1);
      set(fhFileChkBox, 'String', BBClust.FnameString);
   else
      setptr(gcf, 'arrow');
      return;
   end
   % initialze zoom state
   BBClust.ZoomON = 0;
   zoom off;
   set(findobj(figHandle, 'Tag', 'Zoom'), 'Value', 0);
   % clear all axes from previous sessions
   fhaxes = findobj(figHandle, 'Type', 'axes');
   for ia = 1:length(fhaxes)
      axes(fhaxes(ia));
      cla;
   end
   % clear Stats, Keep, Level and ID boxes
   StatsTextHandle = findobj(figHandle, 'Tag', 'StatisticsText');
   set(StatsTextHandle, 'String', '');
   keepHandle = findobj(figHandle, 'Tag', 'KeepBubble');
   set(keepHandle, 'Value', 0);
   LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
   set(LevelEditHandle, 'String', '');

   IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
   set(IDEditHandle, 'String', '');
   set(findobj(figHandle, 'Tag','Hold 1'), 'Value', 0);
   set(findobj(figHandle, 'Tag','Hold 2'), 'Value', 0);
   %unhighlight last Current Bubble
   last_fhbb = findobj(figHandle, 'Tag', 'CurrentBubble', 'Selected', 'on');
   if ~isempty(last_fhbb) set(last_fhbb , 'Selected', 'off'); end;
   % restore Bubble Tree and its colors
   fha = findobj(figHandle, 'Tag', 'DecisionTree');  
   axes(fha);

   BBClust.fhbb = BBplotBubbleTree(BBClust.bb);
   for lvl = 1:BBClust.bb.Nlevels
      for ie = 1:BBClust.bb.NelementsAtLevel{lvl}
         if BBClust.keep(lvl,ie)
            set(BBClust.fhbb(lvl,ie), 'LineWidth', 3, 'EdgeColor', 'g');
         end%if
         if BBClust.show(lvl,ie)
            set(BBClust.fhbb(lvl,ie), 'FaceColor', BBClust.showcolors(lvl,ie,:));
         end%if          
      end%for
   end%for
   % load Axes ListBoxes
   fhlb = findobj(figHandle, 'Tag', 'FeatureX');
   set(fhlb, 'String', MClust_FeatureNames);
   BBClust.xdim = 1;                           % x dimemsion to plot

   fhlb = findobj(figHandle, 'Tag', 'FeatureY');
   set(fhlb, 'String', MClust_FeatureNames);
   BBClust.ydim = 2;
   set(fhlb, 'Value', BBClust.ydim );    % y dimemsion to plot

   % setup BubblePlotAxes
   fha = findobj(figHandle, 'Tag', 'BubblePlotAxes');
   axes(fha);
   for lvl = 1:BBClust.bb.Nlevels
      for ie = 1:BBClust.bb.NelementsAtLevel{lvl}
         BBClust.fhbbdots{lvl,ie} = ...
            line(0, 0, ...
            'Marker', '.', 'MarkerSize', 1,...
            'LineStyle', 'none',...
            'Color', 'k',...
            'ButtonDownFcn', 'BBClustCallbacks',...
            'SelectionHighlight', 'on', ...
            'Tag', 'BubbleDots');

         if BBClust.show(lvl,ie)
            col = get(BBClust.fhbb(lvl,ie), 'FaceColor');
            bbData = get(BBClust.fhbb(lvl,ie), 'UserData');             
            ISAmerger = bbData(4);
            jj = BBClust.bb.LevelElementsIndx{lvl,ie};

            if(ISAmerger)
               Bubble = BBClust.bb.MergerMembers{jj};
            else
               Bubble = BBClust.bb.KernelMembers{jj};      
            end
            set( BBClust.fhbbdots{lvl,ie}, ... 
               'XData', MClust_FeatureData(Bubble,BBClust.xdim),...
               'YData', MClust_FeatureData(Bubble,BBClust.ydim),...
               'Marker', '.', 'MarkerSize', 1, ...
               'LineStyle', 'none',...
               'Color', col, ...
               'MarkerFaceColor', col);
         end%if   
      end%for ie
   end%for lvl
   setptr(gcf, 'arrow');
   
   
   
   
   
case 'ExportClusters'
   global MClust_Colors  MClust_FeatureData MClust_Clusters MClust_FeatureNames

   ibb = 0;
   for lvl = 1:BBClust.bb.Nlevels
      for ie = 1:BBClust.bb.NelementsAtLevel{lvl}
         if BBClust.keep(lvl,ie)
            ibb = ibb + 1;
            bblist{ibb} =  {lvl, ie};
            MClust_Colors(ibb+1,:) = get(BBClust.fhbb(lvl,ie), 'FaceColor');
         end%if   
      end%for
   end%for
   ExportClusters(bblist);
   if isempty(MClust_FeatureData)
      errordlg('No features calculated.', 'MClust error', 'modal');
   else
      GeneralizedCutter(MClust_Clusters, MClust_FeatureData, MClust_FeatureNames, 'bbconvexhull');
   end
   


   

case 'Exit'   
   close(figHandle);
   

case 'KeepBubble'  
   LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
   lvl = str2num(get(LevelEditHandle, 'String'));   
   if isempty(lvl); return; end

   IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
   ie = str2num(get(IDEditHandle, 'String'));
   fha = findobj(figHandle, 'Tag', 'DecisionTree');  
   axes(fha);

   bbData = get(BBClust.fhbb(lvl,ie), 'UserData');
   BarL = bbData(5);
   BarR = bbData(6);
   dy   = bbData(7);

   if get(cboHandle, 'Value')
      %draw fat green outline
      BBClust.keep(lvl,ie) = 1;
      set(BBClust.fhbb(lvl,ie), 'LineWidth', 3, 'EdgeColor', 'g');
   else
      %draw thin black outline
      BBClust.keep(lvl,ie) = 0;
      set(BBClust.fhbb(lvl,ie), 'LineWidth', 0.1, 'EdgeColor', 'k');
   end
      

   

case 'CurrentBubble'

   % clear Stats of old bubble
   StatsTextHandle = findobj(figHandle, 'Tag', 'StatisticsText');
   set(StatsTextHandle, 'String', '');
   AverageWaveformAxisHandle = findobj(figHandle, 'Tag', 'AverageWaveformAxis');
   axes(AverageWaveformAxisHandle); cla;
   HistISIHandle = findobj(figHandle, 'Tag', 'ISIHistAxis');
   axes(HistISIHandle); cla;
   % get lvl and ie from selected bubble
   bbData = get(cboHandle, 'UserData'); 
   lvl = bbData(1);
   ie  = bbData(2);
   % set Level and ID boxes
   LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
   set(LevelEditHandle, 'String', num2str(lvl));
   IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
   set(IDEditHandle, 'String', num2str(ie));
   %highlight Current Bubble
   last_fhbb = findobj(figHandle, 'Tag', 'CurrentBubble', 'Selected', 'on');
   if ~isempty(last_fhbb)
      set(last_fhbb , 'Selected', 'off'); 
   end
   set(BBClust.fhbb(lvl,ie), 'Selected', 'on');      % synch Keep checkbox
   keepHandle = findobj(figHandle, 'Tag', 'KeepBubble');
   if BBClust.keep(lvl,ie)
      set(keepHandle, 'Value', 1);
   else
      set(keepHandle, 'Value', 0);
   end
   %check AutoStatistics box
   if get(findobj(figHandle, 'Tag','AutoStatistics'),'Value')
      BBClustCallbacks('Statistics');    
   end
   
   
   
case 'DecisionTree'
   % user 'Button Down' in white background of DecisionTree axes 
   
      

case 'Statistics'
   global MClust_TTData
   global MClust_FeatureIndex %ncst
   setptr(gcf, 'watch');
   LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
   IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
   lvl = str2num(get(LevelEditHandle, 'String'));   
   if isempty(lvl); setptr(gcf, 'arrow'); return; end
   ie = str2num(get(IDEditHandle, 'String')); 
   % make a Bubble tsd object if necessary 
   if(isempty(BBClust.WaveForms{lvl,ie}) | ... 
         isempty(BBClust.ISI{lvl,ie}) | ...
         isempty(BBClust.Stats{lvl,ie}))     
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
   end%if  

% Statistics text
if(isempty(BBClust.Stats{lvl,ie}))
   msgstr = BubbleStats(bubbleTT);
   BBClust.Stats{lvl,ie} = msgstr;
   else
      msgstr = BBClust.Stats{lvl,ie};
   end%if      
   StatsTextHandle = findobj(figHandle, 'Tag', 'StatisticsText');
   set(StatsTextHandle, 'String', msgstr);
   
   % Average Waveforms
   AverageWaveformAxisHandle = findobj(figHandle, 'Tag', 'AverageWaveformAxis');
   axes(AverageWaveformAxisHandle); cla;
   if BBClust.hold{2,1}
      lvl_ie = BBClust.hold{2,2};
      lvlh = lvl_ie(1);
      ieh  = lvl_ie(2);
      if(isempty(BBClust.WaveForms{lvlh,ieh}))
         warndlg({'There are no waveform data for Hold 2 available yet! ', ...
               'Please select the Hold 2 Bubble again an press the STATISTICS button ', ...
               'to calculate the waveform data first!'}, ...
            'BBClust Warning');
            wfm = zeros(4,32) ;
            wferr = zeros(4,32);
      else
         mANDerr = BBClust.WaveForms{lvlh,ieh};
         wfm = mANDerr{1};
         wferr = mANDerr{2};
      end%if
      for it = 1:4
         xrange = (34 * (it-1)) + (1:32) + 2/3; 
         hold on;
         plot(xrange, wfm(it,:), 'Color', 'g');
         errorbar(xrange,wfm(it,:), wferr(it,:), 'g'); 
      end
   end%if

   if BBClust.hold{1,1}
      lvl_ie = BBClust.hold{1,2};
      lvlh = lvl_ie(1);
      ieh  = lvl_ie(2);
      if(isempty(BBClust.WaveForms{lvlh,ieh}))
         warndlg({'There are no waveform data for Hold 1 available yet! ', ...
               'Please select the Hold 1 Bubble again an press the STATISTICS button ', ...
               'to calculate the waveform data first!'}, ...
            'BBClust Warning');
         wfm = zeros(4,32) ;
         wferr = zeros(4,32);
      else
         mANDerr = BBClust.WaveForms{lvlh,ieh};
         wfm = mANDerr{1};
         wferr = mANDerr{2};
      end%if
      for it = 1:4
         xrange = (34 * (it-1)) + (1:32) + 1/3; 
         hold on;
         plot(xrange, wfm(it,:), 'Color', 'r');
         errorbar(xrange,wfm(it,:),wferr(it,:), 'r'); 
      end
   end%if
   if(isempty(BBClust.WaveForms{lvl,ie}))
      [wfm wferr] = AverageWaveform(bubbleTT);
      BBClust.WaveForms{lvl,ie} = {wfm, wferr};
   else
      mANDerr = BBClust.WaveForms{lvl,ie};
      wfm = mANDerr{1};
      wferr = mANDerr{2};
   end%if

   for it = 1:4
      xrange = (34 * (it-1)) + (1:32); 
      hold on;
      plot(xrange, wfm(it,:));
      errorbar(xrange,wfm(it,:),wferr(it,:)); 
   end

   axis([0 140 -2100 2100])
   title('Average Waveform');
   hold off
   set(gca, 'Tag', 'AverageWaveformAxis');
   
   % ISI histograms
   HistISIHandle = findobj(figHandle, 'Tag', 'ISIHistAxis');
   axes(HistISIHandle); cla;


   if BBClust.hold{2,1}
      lvl_ie = BBClust.hold{2,2};
      lvlh = lvl_ie(1);
      ieh  = lvl_ie(2);
      if(isempty(BBClust.WaveForms{lvlh,ieh}))
         warndlg({'There are no ISIHist data for Hold 2 available yet! ', ...
               'Please select the Hold 2 Bubble again an press the STATISTICS button ', ...
               'to calculate the data first!'}, ...
            'BBClust Warning');
         H = 0 ;
         binsUsed = 1;

      else
         hist = BBClust.ISI{lvlh,ieh};
         H = hist{1};
         binsUsed = hist{2};
      end%if
      hold on;
      plot(binsUsed, H, 'Color', 'g'); 
   end%if   
   if BBClust.hold{1,1}
      lvl_ie = BBClust.hold{1,2};
      lvlh = lvl_ie(1);
      ieh  = lvl_ie(2);
      if(isempty(BBClust.WaveForms{lvlh,ieh}))
         warndlg({'There are no ISIHist data for Hold 1 available yet! ', ...
               'Please select the Hold 1 Bubble again an press the STATISTICS button ', ...
               'to calculate the data first!'}, ...
            'BBClust Warning');
         H = 0 ;
         binsUsed = 1;
      else
         hist = BBClust.ISI{lvlh,ieh};
         H = hist{1};
         binsUsed = hist{2};
      end%if
      hold on;
      plot(binsUsed, H, 'Color', 'r'); 
   end%if 
   
   if(isempty(BBClust.ISI{lvl,ie}))
      [H binsUsed] = HistISI(bubbleTS);
      BBClust.ISI{lvl,ie} = {H, binsUsed};
   else
      hist = BBClust.ISI{lvl,ie};
      H = hist{1};
      binsUsed = hist{2};
   end%if      
   plot(binsUsed, H); 
   xlabel('ISI, ms');
   set(gca, 'XScale', 'log');
   set(gca, 'YTick', max(H));
   set(gca, 'Tag', 'ISIHistAxis');
   hold off;
   
   % pointer
   if BBClust.ZoomON
      setptr(figHandle, 'glass');
   else
      setptr(figHandle, 'arrow');
   end%if



case 'LevelEdit'
   % highlight Current Bubble
   LevelEditHandle = cboHandle;   
   IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
   lvl = str2num(get(LevelEditHandle, 'String'));      
   ie = str2num(get(IDEditHandle, 'String'));      
   last_fhbb = findobj(figHandle, 'Tag', 'CurrentBubble', 'Selected', 'on');
   if ~isempty(last_fhbb) set(last_fhbb , 'Selected', 'off'); end;
   set(BBClust.fhbb(lvl,ie), 'Selected', 'on');
   % synch Keep checkbox
   keepHandle = findobj(figHandle, 'Tag', 'KeepBubble');
   if BBClust.keep(lvl,ie)
      set(keepHandle, 'Value', 1);
   else
      set(keepHandle, 'Value', 0);
   end   


case 'IDEdit'
   % highlight Current Bubble
   LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
   IDEditHandle = cboHandle;
   lvl = str2num(get(LevelEditHandle, 'String'));   
   ie = str2num(get(IDEditHandle, 'String'));      
   last_fhbb = findobj(figHandle, 'Tag', 'CurrentBubble', 'Selected', 'on');
   if ~isempty(last_fhbb) set(last_fhbb , 'Selected', 'off'); end;   
   set(BBClust.fhbb(lvl,ie), 'Selected', 'on');

   % synch Keep checkbox
   keepHandle = findobj(figHandle, 'Tag', 'KeepBubble');
   if BBClust.keep(lvl,ie)
      set(keepHandle, 'Value', 1);
   else
      set(keepHandle, 'Value', 0);
   end   

   
case 'AutoCorr'
   LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
   IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
   lvl = str2num(get(LevelEditHandle, 'String'));   
   if isempty(lvl); setptr(gcf, 'arrow'); return; end
   ie = str2num(get(IDEditHandle, 'String')); 
   AutoCorrPlot(lvl,ie);
    
case 'XCorr'
   LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
   IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
   lvl = str2num(get(LevelEditHandle, 'String'));   
   if isempty(lvl); setptr(gcf, 'arrow'); return; end
   ie = str2num(get(IDEditHandle, 'String')); 
   ielvl2 = inputdlg(['XCorr BB' num2str(lvl) ',' num2str(ie) ' with ...? (Enter the Level (first) and ID (second) of another BB with a blank separator)']);
   if isempty(ielvl2), return, end
   ielvl2 = str2num(ielvl2{1});     
   CrossCorrPlot(lvl,ie,ielvl2(1),ielvl2(2));
    
case 'CheckBB'
    global MClust_TTData MClust_TTfn MClust_FeatureTimestamps
    setptr(figHandle, 'watch');
    LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
    IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
    lvl = str2num(get(LevelEditHandle, 'String'));   
    if isempty(lvl); setptr(gcf, 'arrow'); return; end
    ie = str2num(get(IDEditHandle, 'String')); 
    % make a Bubble tsd object  
    bbData = get(BBClust.fhbb(lvl,ie), 'UserData'); 
    ISAmerger = bbData(4);
    jj = BBClust.bb.LevelElementsIndx{lvl,ie};
    if(ISAmerger)
        Bubble = BBClust.bb.MergerMembers{jj};
    else
        Bubble = BBClust.bb.KernelMembers{jj};      
    end
    bubbleTT = ExtractBubbleFromTT(Bubble, MClust_TTData);
    [curdn,curfn] = fileparts(MClust_TTfn);
    CheckCluster([curfn, ' -- Bubble: ', num2str(lvl) ', ' num2str(ie)], bubbleTT,MClust_FeatureTimestamps(1), MClust_FeatureTimestamps(end));
    setptr(figHandle, 'arrow');

    
   
case 'Hold 1'
   if get(cboHandle, 'Value')
      LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
      IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
      lvl = str2num(get(LevelEditHandle, 'String'));   
      ie = str2num(get(IDEditHandle, 'String'));
      % put flag 1 onto current bubble patch
      bbData = get(BBClust.fhbb(lvl,ie), 'UserData');
      BarL = bbData(5);
      BarR = bbData(6);
      dy   = bbData(7);
      BarC = (BarL + BarR)/2;
      fha = findobj(figHandle, 'Tag', 'DecisionTree');  

      axes(fha);
      XYminmax = axis;

      textsize = 2*dy/(XYminmax(4) -XYminmax(3));
      text('String', '1', ... 
         'Position', [BarC, lvl] , ...
         'FontUnits', 'normalized', ...
         'FontSize', textsize, ...
         'FontWeight', 'bold', ...
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'middle', ...
         'Tag', 'Hold1Flag');
      % store hold state

      BBClust.hold{1,1} = 1;
      BBClust.hold{1,2} = [lvl ie];
   else
      fhtxt = findobj(figHandle, 'Tag', 'Hold1Flag');
      delete(fhtxt);
      BBClust.hold{1,1} = 0;
      BBClust.hold{1,2} = [];
   end

  

   

   

case 'Hold 2'
   if get(cboHandle, 'Value')
      LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
      IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
      lvl = str2num(get(LevelEditHandle, 'String'));   
      ie = str2num(get(IDEditHandle, 'String'));   
      % put flag 2 onto current bubble patch
      bbData = get(BBClust.fhbb(lvl,ie), 'UserData');
      BarL = bbData(5);
      BarR = bbData(6);
      dy   = bbData(7);
      BarC = (BarL + BarR)/2;
      fha = findobj(figHandle, 'Tag', 'DecisionTree');  
      axes(fha);
      XYminmax = axis;
      textsize = 2*dy/(XYminmax(4) -XYminmax(3));
      text('String', '2', ... 
         'Position', [BarC, lvl] , ...
         'FontUnits', 'normalized', ...
         'FontSize', textsize, ...
         'FontWeight', 'bold', ...
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'middle', ...
         'Tag', 'Hold2Flag');
      % store hold state      
      BBClust.hold{2,1} = 1;
      BBClust.hold{2,2} = [lvl ie];
   else
      fhtxt = findobj(figHandle, 'Tag', 'Hold2Flag');
      delete(fhtxt);
      BBClust.hold{2,1} = 0;
      BBClust.hold{2,2} = [];
   end
   

   

case 'ColorButton'
   Nr = get(cboHandle,'UserData');   
   fhCF = findobj(figHandle,'Tag', ['CF' num2str(Nr)]);
   col = get(fhCF, 'BackgroundColor');
   LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
   lvl = str2num(get(LevelEditHandle, 'String')); 
   if isempty(lvl); return; end
   IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
   ie = str2num(get(IDEditHandle, 'String'));   
   if(Nr == 14)
      col = uisetcolor(col, 'Select a color');
      set(fhCF, 'BackgroundColor', col);
   end%if
   if(Nr == 15)
      bbData = get(BBClust.fhbb(lvl,ie), 'UserData');
      col = bbData(8:10);
   end%if
   set(BBClust.fhbb(lvl,ie), 'FaceColor', col);
   set(BBClust.fhbbdots{lvl,ie}, 'Color', col);
   
  

case 'Zoom'
   if get(cboHandle, 'Value')
      zoom on;
      BBClust.ZoomON = 1;
      setptr(figHandle,'glass');
   else
      zoom off;
      BBClust.ZoomON = 0;
      setptr(figHandle,'arrow');
   end
   

case 'FeatureX'
   xdimHandle = findobj(figHandle, 'Tag', 'FeatureX');
   BBClust.xdim = get(xdimHandle, 'Value');           % x dimemsion to plot
   BBClust.xlbls = get(xdimHandle, 'String');         % x labels
   BBClustCallbacks('Redraw Axes');


case 'FeatureY'
   ydimHandle = findobj(figHandle, 'Tag', 'FeatureY');
   BBClust.ydim = get(ydimHandle, 'Value');           % y dimension to plot
   BBClust.ylbls = get(ydimHandle, 'String');         % y lables
   BBClustCallbacks('Redraw Axes');
   
   
case 'Redraw Axes'
   global MClust_FeatureData
   global MClust_CurrentFeatures
   global MClust_FDfn
   setptr(figHandle, 'watch');
   fha = findobj(figHandle, 'Tag', 'BubblePlotAxes');
   axes(fha);
   xdimHandle = findobj(figHandle, 'Tag', 'FeatureX');
   BBClust.xdim = get(xdimHandle, 'Value');           % x dimemsion to plot
   BBClust.xlbls = get(xdimHandle, 'String');         % x labels
   ydimHandle = findobj(figHandle, 'Tag', 'FeatureY');
   BBClust.ydim = get(ydimHandle, 'Value');           % y dimension to plot
   BBClust.ylbls = get(ydimHandle, 'String');         % y labels
   
   if ~strcmp(BBClust.ylbls(BBClust.ydim), MClust_CurrentFeatures(2))
       setptr(gcf, 'watch');
       if strcmpi(BBClust.ylbls{BBClust.ydim}(1:4), 'time')
           MClust_FeatureData(:,2) = MClust_FeatureData(:,3);
           MClust_CurrentFeatures(2) = BBClust.ylbls(BBClust.ydim);
       else
           [fpath fname fext] = fileparts(MClust_FDfn);
           FeatureToGet = BBClust.ylbls{BBClust.ydim};
           FindColon = find(FeatureToGet == ':');
           temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
           FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
           MClust_FeatureData(:,2) = temp.FeatureData(:,FeatureIndex);
           MClust_CurrentFeatures(2) = temp.FeatureNames(FeatureIndex); %BBClust.ylbls(BBClust.ydim);
       end;
       setptr(gcf, 'arrow');
   end;
   if ~strcmp(BBClust.xlbls(BBClust.xdim), MClust_CurrentFeatures(1))
       setptr(gcf, 'watch');
       if strcmpi(BBClust.xlbls{BBClust.xdim}(1:4), 'time')
           MClust_FeatureData(:,1) = MClust_FeatureData(:,3);
           MClust_CurrentFeatures(1) = BBClust.xlbls(BBClust.xdim);
       else
           [fpath fname fext] = fileparts(MClust_FDfn);
           FeatureToGet = BBClust.xlbls{BBClust.xdim};
           FindColon = find(FeatureToGet == ':');
           temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
           FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
           MClust_FeatureData(:,1) = temp.FeatureData(:,FeatureIndex);
           MClust_CurrentFeatures(1) = temp.FeatureNames(FeatureIndex); %BBClust.ylbls(BBClust.ydim);
       end;
       setptr(gcf, 'arrow');
   end;
   
   if strcmpi(BBClust.xlbls{BBClust.xdim}(1:4), 'time')
      set(fha, 'XLimMode','manual','YLimMode','auto');  
      set(fha, 'XLim', [MClust_FeatureData(1,3) MClust_FeatureData(end,3)]);
   elseif strcmpi(BBClust.ylbls{BBClust.ydim}(1:4), 'time')
      set(fha, 'XLimMode','auto','YLimMode','manual');  
      set(fha, 'YLim', [MClust_FeatureData(1,3) MClust_FeatureData(end,3)]);
   else
      set(fha, 'XLimMode','auto','YLimMode','auto');
   end
   for lvl = 1:BBClust.bb.Nlevels
      for ie = 1:BBClust.bb.NelementsAtLevel{lvl}
         if(length(get(BBClust.fhbbdots{lvl,ie}, 'XData')) ~= 1)            
            bbData = get(BBClust.fhbb(lvl,ie), 'UserData');
            ISAmerger = bbData(4);
            jj = BBClust.bb.LevelElementsIndx{lvl,ie};
            if(ISAmerger)
               Bubble = BBClust.bb.MergerMembers{jj};
            else
               Bubble = BBClust.bb.KernelMembers{jj};      
            end
            %set( BBClust.fhbbdots{lvl,ie}, ... 
            %  'XData', MClust_FeatureData(Bubble,BBClust.xdim),...
            %  'YData', MClust_FeatureData(Bubble,BBClust.ydim));
            set( BBClust.fhbbdots{lvl,ie}, ... 
              'XData', MClust_FeatureData(Bubble,1),...
              'YData', MClust_FeatureData(Bubble,2));
         end%if
      end%for ie
   end%for lvl
   if BBClust.ZoomON
      setptr(figHandle, 'glass');
   else
      setptr(figHandle, 'arrow');
   end%if

   
case 'Add BB'
   global MClust_FeatureData
   setptr(gcf, 'watch');   LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
   lvl = str2num(get(LevelEditHandle, 'String'));  
   IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');

   ie = str2num(get(IDEditHandle, 'String'));
   col = get(BBClust.fhbb(lvl,ie), 'FaceColor');
   bbData = get(BBClust.fhbb(lvl,ie), 'UserData'); 
   ISAmerger = bbData(4);
   jj = BBClust.bb.LevelElementsIndx{lvl,ie};
   if(ISAmerger)
      Bubble = BBClust.bb.MergerMembers{jj};
   else
      Bubble = BBClust.bb.KernelMembers{jj};      
   end
   fha = findobj(figHandle, 'Tag', 'BubblePlotAxes');
   axes(fha);
   %% set(fha, 'XLimMode','auto','YLimMode','auto');
   set( BBClust.fhbbdots{lvl,ie}, ... 
      'XData', MClust_FeatureData(Bubble,1),...
      'YData', MClust_FeatureData(Bubble,2),...
      'Marker', '.', 'MarkerSize', 1, ...
      'LineStyle', 'none',...
      'Color', col, ...
      'MarkerFaceColor', col);
   if BBClust.ZoomON
      setptr(figHandle, 'glass');
   else
      setptr(figHandle, 'arrow');
   end%if

case 'Remove BB'

   global MClust_FeatureData
   fha = findobj(figHandle, 'Tag', 'BubblePlotAxes');
   axes(fha);
   fh_sel = findobj(fha, 'Tag', 'BubbleDots', 'Selected', 'on');
   if isempty(fh_sel)
      LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
      lvl = str2num(get(LevelEditHandle, 'String'));   
      IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
      ie = str2num(get(IDEditHandle, 'String'));   
      set( BBClust.fhbbdots{lvl,ie}, ... 
         'XData', 0,...
         'YData', 0);
   else
      for is=1:length(fh_sel)
         set( fh_sel(is), ... 
            'XData', 0, 'YData', 0, 'Selected', 'off');
      end
   end

case {'Show KEEPs', 'Show KEEPs only'}

   global MClust_FeatureData
   setptr(gcf, 'watch');
   if strcmp(callbackTag, 'Show KEEPs only')
      % clear BubblePlot window first
      fha = findobj(figHandle, 'Tag', 'BubblePlotAxes');
      axes(fha);
      [NL, NelMax] = size(BBClust.bb.LevelElements);
      for lvl = 1:NL
         for ie = 1:NelMax
            if ~isempty(BBClust.bb.LevelElements{lvl,ie})
               set( BBClust.fhbbdots{lvl,ie}, ... 
                  'XData', 0,...
                  'YData', 0);
            end%if
         end%for ie
      end%for lvl      
   end%if
   
   for lvl = 1:BBClust.bb.Nlevels
      for ie = 1:BBClust.bb.NelementsAtLevel{lvl}
         if BBClust.keep(lvl,ie)
            col = get(BBClust.fhbb(lvl,ie), 'FaceColor');
            bbData = get(BBClust.fhbb(lvl,ie), 'UserData'); 
            ISAmerger = bbData(4);
            jj = BBClust.bb.LevelElementsIndx{lvl,ie};
            if(ISAmerger)
               Bubble = BBClust.bb.MergerMembers{jj};
            else
               Bubble = BBClust.bb.KernelMembers{jj};      
            end
            set( BBClust.fhbbdots{lvl,ie}, ... 
               'XData', MClust_FeatureData(Bubble,1),...
               'YData', MClust_FeatureData(Bubble,2),...
               'Marker', '.', 'MarkerSize', 1, ...
               'LineStyle', 'none',...
               'Color', col, ...
               'MarkerFaceColor', col);
         end%if   
      end%for
   end%for
   if BBClust.ZoomON
      setptr(figHandle, 'glass');
   else
      setptr(figHandle, 'arrow');
   end%if
   
case 'Find BB'

   global MClust_FeatureData
   % find Feature_Data index of member closest to the user input point (xx,yy)
   [xx, yy] = ginput(1);
   x = xx - MClust_FeatureData(:,BBClust.xdim);
   y = yy - MClust_FeatureData(:,BBClust.ydim);
   d2 = x.*x + y.*y;
   [dmin, ii] = min(d2);
   kk = BBClust.bb.i2k(ii);
   id = BBClust.bb.id(kk);
   %find id in BubbleTree
   exitloop = 0;
   for lvl = 1:BBClust.bb.Nlevels
      for ie = 1:BBClust.bb.NelementsAtLevel{lvl}
         if(BBClust.bb.LevelElements{lvl,ie} == id )
            % highlight Current Bubble
            LevelEditHandle = findobj(figHandle, 'Tag', 'LevelEdit');
            IDEditHandle = findobj(figHandle, 'Tag', 'IDEdit');
            set(LevelEditHandle, 'String',num2str(lvl));   
            set(IDEditHandle, 'String',num2str(ie));   
            last_fhbb = findobj(figHandle, 'Tag', 'CurrentBubble', 'Selected', 'on');
            if ~isempty(last_fhbb) set(last_fhbb , 'Selected', 'off'); end;
            set(BBClust.fhbb(lvl,ie), 'Selected', 'on');
            % synch Keep checkbox
            keepHandle = findobj(figHandle, 'Tag', 'KeepBubble');
            if BBClust.keep(lvl,ie)
               set(keepHandle, 'Value', 1);
            else
               set(keepHandle, 'Value', 0);
            end   
            exitloop = 1;
            break;
         end%if   
      end%for
      
      if exitloop; break; end
   end%for
   
case 'View 3D'
   global MClust_Colors
   ibb = 0;
   for lvl = 1:BBClust.bb.Nlevels
      for ie = 1:BBClust.bb.NelementsAtLevel{lvl}
         if(length(get(BBClust.fhbbdots{lvl,ie}, 'XData')) ~= 1)
            ibb = ibb + 1;
            bblist{ibb} =  {lvl, ie};
            MClust_Colors(ibb+1,:) = get(BBClust.fhbb(lvl,ie), 'FaceColor');
         end%if   
      end%for
   end%for
   ExportClusters(bblist);
   ViewClusters;

case 'ContourPlot'
   % collect all bubbles in current BubblePlot
   setptr(figHandle, 'watch');
   fha = findobj(figHandle, 'Tag', 'BubblePlotAxes');
   %mkContours(100,100, 'AxesHandle', fha);
   mkContours(fha);
   if BBClust.ZoomON
      setptr(figHandle, 'glass');
   else
      setptr(figHandle, 'arrow');
   end%if
   
   
  
case 'Clear'
   fha = findobj(figHandle, 'Tag', 'BubblePlotAxes');
   axes(fha);
   [NL, NelMax] = size(BBClust.bb.LevelElements);
   for lvl = 1:NL
      for ie = 1:NelMax
         if ~isempty(BBClust.bb.LevelElements{lvl,ie})
               set( BBClust.fhbbdots{lvl,ie}, ... 
                  'XData', 0,...
                  'YData', 0);
         end%if
      end%for ie
   end%for lvl

   
   
case 'BubbleDots'
   sel = get(cboHandle, 'Selected');
   if strcmp(sel,'on')
      set(cboHandle, 'Selected', 'off');
   else
      set(cboHandle, 'Selected', 'on')
   end     
   
end % switch


%==========================================================
function bubbleTT = ExtractBubbleFromTT(bubble, TT)

if ~isempty(TT)
	TIME = Range(TT, 'ts');
	DATA = Data(TT);
	bubbleTT = tsd(TIME(bubble), DATA(bubble, :, :));
else
    bubbleTT = ExtractCluster(TT,bubble);
end;


%=============================================================
function msgstr = BubbleStats(TT)

msgstr = {};
nSpikes = length(Range(TT, 'ts'));
msgstr{end+1} = sprintf('%.0f spikes ', nSpikes);
dts = diff(Range(TT, 'ts'));
mISI = mean(dts)/10000;
msgstr{end+1} = sprintf('inv mean ISI = %.4f spikes/sec ', 1/mISI);
mdISI = median(dts)/10000;
msgstr{end+1} = sprintf('inv med. ISI = %.4f spikes/sec ', 1/mdISI);
fr = 10000 * nSpikes/(EndTime(TT) - StartTime(TT));
msgstr{end+1} = sprintf('firing rate = %.4f spikes/sec ', fr);

%sw = SpikeWidth(TT);
%mSW = mean(sw,1);
%vSW = std(sw, 1);
%msgstr{end+1}   = sprintf('spikewidth (Ch1) = %5.2f +/- %5.2f', mSW(1), vSW(1));
%msgstr{end+1}   = sprintf('spikewidth (Ch2) = %5.2f +/- %5.2f', mSW(2), vSW(2));
%msgstr{end+1}   = sprintf('spikewidth (Ch3) = %5.2f +/- %5.2f', mSW(3), vSW(3));
%msgstr{end+1}   = sprintf('spikewidth (Ch4) = %5.2f +/- %5.2f', mSW(4), vSW(4));


%================================================================
function ExportClusters(bblist)

% bblist is a list of {lvl, ie} pairs, one per bubble to export
% bblist = { {lvl1, ie1}, {lvl2, ie2}, ... }
global MClust_Clusters MClust_Hide BBClust

MClust_Hide = zeros(size(MClust_Hide));
MClust_Clusters = {};

for ibb = 1:length(bblist)
   DisplayProgress(ibb, length(bblist), 'Title', 'Converting to cluster objects');
   bb = bblist{ibb};
   lvl = bb{1};
   ie  = bb{2};
   bbData = get(BBClust.fhbb(lvl,ie), 'UserData'); 

   ISAmerger = bbData(4);
   jj = BBClust.bb.LevelElementsIndx{lvl,ie};
   if(ISAmerger)
      Bubble = BBClust.bb.MergerMembers{jj};
   else
      Bubble = BBClust.bb.KernelMembers{jj};      
   end
   MClust_Clusters{end+1} = precut(Bubble, 'indices');
end%for ibb
DisplayProgress close;






