function BBMClustCallbacks(varargin)

%%%%%% ------ modified batta 5/7/01 -----------------------

% BBClust
% BBMClustCallbacks
% 
% Contains all callbacks for the BBClust main window (see BBClust)
%
% This program stores a number of key parameters as global variables.
% All global variables start with the tag "MClust_".  The variables are
%    MClust_TTfn         % file name for tt file
%    MClust_TTdn         % directory name for tt file
%    MClust_TTData       % data from tt file
%    MClust_FeatureData  % features calculated from tt data
%    MClust_FeatureNames % names of features
%    MClust_ChannelValidity % 4 x 1 array of channel on (1) or off (0) flags
%    MClust_Clusters     % cell array of cluster objects 
% 
% See also
%    MClust
%
% ADR 1998
%
% modified for manual editing of BBClust clusters
% PL 2000
% version BB0.1
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.


% global variables
global MClust_Directory     % directory where the MClust (BBClust) main function and features reside
global MClust_TTfn         % file name for tt file
global MClust_FDfn         % file name for fd file
global MClust_TTdn         % directory name for tt file
global MClust_TTData       % data from tt file
global MClust_FeatureIndex % used to match spikes in split files back to the original file
global MClust_CurrentFeatures % used to keep track of which features are currently in memory
global MClust_FeatureData  % features calculated from tt data
global MClust_FeatureNames % names of features
global MClust_FeaturesToUse % names of features to use (for feature calculation)
global MClust_FeatureTimestamps 
global MClust_ChannelValidity % 4 x 1 array of channel on (1) or off (0) flags
global MClust_Clusters     % cell array of cluster objects 

%%%%%% ------ modified batta 5/7/01 -----------------------
global BBClustFilePrefix;
global BBClustFileDir;


%%%%%% ------ modified batta 5/7/01 -----------------------
if ~isempty(varargin)
  ssw = varargin(1);
  ssw = ssw{1};
  figHandle = findobj('Tag', 'MClustMainWindow');
  cboHandle = [];
else
  cboHandle = gcbo;                          % current uicontrol handle
  figHandle = ParentFigureHandle(cboHandle); % current figure handle

  ssw = get(cboHandle, 'Tag');
end

switch ssw

case 'InputType'
   ChHandle1 = findobj(figHandle, 'Tag', 'TTValidity1');
   ChHandle2 = findobj(figHandle, 'Tag', 'TTValidity2');
   ChHandle3 = findobj(figHandle, 'Tag', 'TTValidity3');
   ChHandle4 = findobj(figHandle, 'Tag', 'TTValidity4');
   
   switch get(cboHandle, 'value') 
   case {1,2} % TT 
      set(ChHandle1, 'value', 1, 'enable', 'on');
      set(ChHandle2, 'value', 1, 'enable', 'on');
      set(ChHandle3, 'value', 1, 'enable', 'on');
      set(ChHandle4, 'value', 1, 'enable', 'on');
   case 3 % ST
      set(ChHandle1, 'value', 1, 'enable', 'on');
      set(ChHandle2, 'value', 1, 'enable', 'on');
      set(ChHandle3, 'value', 0, 'enable', 'off');
      set(ChHandle4, 'value', 0, 'enable', 'off');
   case 4 % SE
      set(ChHandle1, 'value', 1, 'enable', 'on');
      set(ChHandle2, 'value', 0, 'enable', 'off');
      set(ChHandle3, 'value', 0, 'enable', 'off');
      set(ChHandle4, 'value', 0, 'enable', 'off');
 otherwise
      error('Internal error: Unknown Input type');
   end
   
 case 'LoadTTFileButton'
   InputTypeHandle = findobj(figHandle, 'Tag', 'InputType');
   InputValue = get(InputTypeHandle, 'value');
   switch InputValue
   case 1 % TT sun
      expExtension = '*.tt';
   case 4 % SE nt
      expExtension = 'SE*.dat';
   case 3 % ST nt
      expExtension = 'ST*.dat';
   case 2 % TT nt
      expExtension = 'TT*.dat';
   otherwise
      error('Internal error: Unknown input file type.');
   end
   
   [MClust_TTfn, MClust_TTdn] = uigetfile(expExtension, 'TT file');
   if isempty(MClust_TTfn)
       return;   % user hit Cancel button
   end
   %%%%%% ------ modified batta 5/7/01 -----------------------
   BBClustFileDir = MClust_TTdn;
   [pp,nn,ee] = fileparts(MClust_TTfn);
   BBClustFilePrefix = nn;
   
%    if MClust_TTfn
%       setptr(gcf, 'watch');
%       [dn,fn,ext] = fileparts(MClust_TTfn);
%       switch InputValue
%       case 1 % TT sun
%          MClust_TTData = LoadTT(fullfile(MClust_TTdn, MClust_TTfn));
%       case 2 % TT nt
%          MClust_TTData = LoadTT(fullfile(MClust_TTdn, MClust_TTfn));
%       case 3 % ST nt
%          MClust_TTData = LoadTT(fullfile(MClust_TTdn, MClust_TTfn));
%       case 4 % SE nt
%          MClust_TTData = LoadTT(fullfile(MClust_TTdn, MClust_TTfn));
%       end
%          
%       setptr(gcf, 'arrow');
%       set(cboHandle, 'Value', 1);
%    else
%       set(cboHandle, 'Value', 0);
%    end

   fnTextObj = findobj(figHandle, 'Tag', 'TTFileName');
   set(fnTextObj, 'String', MClust_TTfn);
   MClust_TTfn = fullfile(MClust_TTdn, MClust_TTfn);

%%%%%% ------ modified batta 5/7/01 -----------------------
   
   BBMClustCallbacks('LoadFeaturesButton');
   BBClustDecisionWindow;
   RescaleFigure(gcf,[0.05 0.05 0.9 0.9], 1);
   drawnow;
   BBClustCallbacks('LoadBBFiles');
   BBClustCallbacks('RedrawBubbleTree');
   BBClustCallbacks('Add BB');
   
   
   
case {'FeaturesUseListbox', 'FeaturesIgnoreListbox'}
   TransferBetweenListboxes;
   FeaturesUseListbox = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
   ChooseFeaturesButton = findobj(figHandle, 'Tag', 'ChooseFeaturesButton');
   if ~isempty(get(FeaturesUseListbox, 'String'))
      set(ChooseFeaturesButton, 'Value', 1);
   else
      set(ChooseFeaturesButton, 'Value', 0);
   end
   CalcFeaturesButton = findobj(figHandle, 'Tag', 'CalculateFeaturesButton');
   set(CalcFeaturesButton, 'Value', 0);   
   
   

   
case 'LoadFeaturesButton'
   % load Feature Data File (*.fd) used for BubbleClust.exe  
%%%%%% ------ modified batta 5/7/01 -----------------------
%%%%%% ------ modified ncst 20 Jan 02 -----------------------

MClust_TText = '.dat';

if isempty(BBClustFilePrefix)
    [FDfn, FDdn] = uigetfile('*.fd;TT*.dat', ['Select the .dat or a .fd from the desired tetrode',... 
            ' (only files *.fd or TT*.dat)']);
    if FDfn == 0    % User hit cancel
        return
    end
    [BBFile_path BBFile_name BBFile_ext] = fileparts(FDfn); %ncst 1/9/02
    if ~strcmp(BBFile_ext,'.fd')
        if strcmp(BBFile_ext,'.tt')
            MClust_TText = '.tt';
        end
        BBFile_ext = '.fd';
        FDfn = [BBFile_name '.fd'];
        if exist(fullfile(FDdn,'FD'),'dir')
            FDdn = fullfile(FDdn,'FD');
        end
    end
    BBClustFilePrefix = BBFile_name;
    BBClustFileDir = FDdn;
else 
    FDfn = [BBClustFilePrefix '.fd'];
    FDdn = BBClustFileDir;
end

BBClust.FDffn = fullfile(FDdn,FDfn);
try
    temp = load(BBClust.FDffn,'-mat');
catch
    temp = [];
end
   
if ~isempty(temp)  % If we found FDfn
   MClust_FeatureIndex = temp.FeatureIndex;
   MClust_ChannelValidity = temp.ChannelValidity;
   MClust_FeatureTimestamps = temp.FeatureTimestamps; 
end
       
UndScore = find(BBFile_name == '_');
if ~isempty(UndScore) & length(UndScore) == 1
    BBFile_name = BBFile_name(1:UndScore - 1);   % if it is a TT_feature.fd file, get rid of the _feature
    BBClustFilePrefix = BBFile_name;
end
MClust_FDfn = fullfile(FDdn,[BBFile_name '.fd']);

IsFDdir = findstr(FDdn,'FD');
if ~isempty(IsFDdir)
    TTdn = FDdn(1:IsFDdir - 2);
else
    TTdn = FDdn;
end

IsSplit = findstr(BBFile_name,'b');
if ~isempty(IsSplit) %BBFile_name(end-1) == 'b'  % if the file name contains a b, consider it a split file and find the name of the original TT file
    MClust_TTfn = fullfile(TTdn,[BBFile_name(1:IsSplit - 1) MClust_TText]); 
else
    MClust_TTfn = fullfile(TTdn,[BBFile_name MClust_TText]); 
end

FeaturesUseListbox = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
MClust_FeaturesToUse = get(FeaturesUseListbox, 'String')';
   
setptr(gcf, 'watch');
AddFeatureFiles = FindFiles(fullfile(BBFile_path, [BBFile_name '_*' BBFile_ext]));
for iMCF = 1:length(MClust_FeaturesToUse)
    if isempty(strmatch('time',MClust_FeaturesToUse{iMCF}))
        AddFeatureFile = FindFiles(fullfile(FDdn, [BBFile_name '_' MClust_FeaturesToUse{iMCF} BBFile_ext]));
        if isempty(AddFeatureFile)
            record_block_size = 80000;
            template_matching = 0;
            disp(' ')
            disp(['FD file ' BBFile_name '_' MClust_FeaturesToUse{iMCF} '.fd does not exist; creating...'])
            disp(' ')
            Write_fd_file(fullfile(BBClustFileDir, [BBFile_name '_' MClust_FeaturesToUse{iMCF} '.fd']), MClust_TTfn, MClust_FeaturesToUse(iMCF), MClust_ChannelValidity, record_block_size, template_matching)
        end            
        temp = load(fullfile(FDdn, [BBFile_name '_' MClust_FeaturesToUse{iMCF} BBFile_ext]),'-mat');
        MClust_FeaturesToUse = [MClust_FeaturesToUse temp.FeaturesToUse];
        if size(MClust_FeatureData,2) < 3
            for iAdd = 1:size(temp.FeatureData,2)
                if size(MClust_FeatureData,2) < 3
                    MClust_FeatureData = [MClust_FeatureData temp.FeatureData(:,iAdd)];
                    MClust_CurrentFeatures = [MClust_CurrentFeatures temp.FeatureNames(iAdd)];
                end
            end
        end
        MClust_FeatureNames = [MClust_FeatureNames; temp.FeatureNames];
        if isempty(MClust_FeatureTimestamps)
            MClust_FeatureIndex = temp.FeatureIndex;
            MClust_ChannelValidity = temp.ChannelValidity;
            MClust_FeatureTimestamps = temp.FeatureTimestamps; 
        end     
    end
end

MClust_FeatureNames(end+1) = {'time'};
setptr(gcf, 'arrow');

clear temp

LoadFeaturesButton = findobj(figHandle, 'Tag', 'LoadFeaturesButton');
set(LoadFeaturesButton, 'Value', 1);  

if ~isempty(cboHandle)
    set(cboHandle, 'Value', 1);
end

% update Feature Listboxes with used features in featurefile
if isempty(MClust_Directory);
    % need to define MClust_Directory (where to find the feature_*.m files)
    MClust_Directory = fileparts(which('BBClust.m'));
end
% featureFiles =  sortcell(FindFiles('feature_*.m', 'StartingDirectory', MClust_Directory,'CheckSubdirs', 0));
% featureIgnoreString = {};
% featureUseString = {};
% for iF = 1:length(featureFiles)
%     [dummy, featureFiles{iF}] = fileparts(featureFiles{iF});
%     featureFiles{iF} = featureFiles{iF}(9:end); % cut "feature_" off front for display
%     if any(strcmp(featureFiles{iF}, MClust_FeaturesToUse))
%         featureUseString = cat(1, featureUseString, featureFiles(iF));
%     else
%         featureIgnoreString = cat(1, featureIgnoreString, featureFiles(iF));
%     end
% end
% set(findobj(figHandle, 'Tag', 'FeaturesIgnoreListbox'), 'String', featureIgnoreString);
set(findobj(figHandle, 'Tag', 'FeaturesIgnoreListbox'), 'Enable','off');
% set(findobj(figHandle, 'Tag', 'FeaturesUseListbox'), 'String', featureUseString);
set(findobj(figHandle, 'Tag', 'FeaturesUseListbox'), 'Enable','off');
   
% update Channel Validity Checkboxes with used channels in featurefile
set(findobj(figHandle, 'Tag', 'TTValidity1'), 'Value', MClust_ChannelValidity(1));
set(findobj(figHandle, 'Tag', 'TTValidity2'), 'Value', MClust_ChannelValidity(2));
set(findobj(figHandle, 'Tag', 'TTValidity3'), 'Value', MClust_ChannelValidity(3));
set(findobj(figHandle, 'Tag', 'TTValidity4'), 'Value', MClust_ChannelValidity(4));

[p n e] = fileparts(MClust_TTfn);
set(findobj(figHandle, 'Tag', 'TTFileName'), 'String', n);





case 'CalculateFeaturesButton'
    % get channel validity
    for iCh = 1:4
        TTValidityButton = findobj(figHandle, 'Tag', ['TTValidity' num2str(iCh)]);
        MClust_ChannelValidity(iCh) = get(TTValidityButton, 'Value');
   end
   FeaturesUseListbox = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
   FeaturesToUse = get(FeaturesUseListbox, 'String');
   MClust_FeatureData = [];
   MClust_FeatureNames = {};
   setptr(gcf, 'watch');
   nFeatures = length(FeaturesToUse);
   for iF = 1:nFeatures
       fprintf(2, 'Calculating feature: %s ... ', FeaturesToUse{iF});
       [nextFeatureData, nextFeatureNames] = ...
           feval(['feature_', FeaturesToUse{iF}], MClust_TTData, MClust_ChannelValidity);
      MClust_FeatureData = [MClust_FeatureData nextFeatureData];
      MClust_FeatureNames = [MClust_FeatureNames; nextFeatureNames];
      fprintf(2, 'done.\n'); 
  end
   setptr(gcf, 'arrow');
   set(cboHandle, 'Value', 1);
   
   
case 'BBClustSelection'
    
   global BBClustFilePrefix;
   global BBClustFileDir;

   [fn1, dn1] = fileparts(BBClustFilePrefix);
   
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
      if ~exist(fn1,'file')
          [fn1, dn1] = uigetfile('*.bbt', 'Full bubble tree file');
          if fn1
              [p n e] = fileparts(fn1);
              BBClustFilePrefix = n;
          else
              return
          end
      end
   else
      return;
   end%if
   
   BBClustDecisionWindow;
   RescaleFigure(gcf,[0.05 0.05 0.9 0.9], 1);
   drawnow;
   
   BBClustCallbacks('LoadBBFiles');
   BBClustCallbacks('RedrawBubbleTree');
   BBClustCallbacks('Add BB');
   
case 'KlustaKwikSelection'
   KlustaKwikDecisionWindow;
   RescaleFigure(gcf,[0.05 0.05 0.9 0.9], 1);
   drawnow;
    global KlustaKwik_Clusters
    global MClust_FDfn
    [p,n,e] = fileparts(MClust_FDfn);
    expExtension = [p filesep n '.clu.*'];
    pushdir(p);
    CLUfiles = FindFiles([n '.clu.*']);
    if length(CLUfiles) ~= 1
    
        [fn, fdir] = uigetfile(expExtension);
        % Get the file and remove any . extensions (there are 
        % more than one so you need to run this a couple times).
    else
        [fdir fn fext] = fileparts(CLUfiles{1});
    end
    
    [p rootname e ] = fileparts(fn);
    [p rootname e ] = fileparts(rootname);
    [p rootname e ] = fileparts(rootname);
    
    popdir;
    
    if rootname
        %KlustaLoad(fullfile(fdir, rootname));
        
		% Load in the clusters from KlustaKwik
		file_no = 1;
		clu_file = [fullfile(fdir,rootname) '.clu.' num2str(file_no)];
		KlustaKwik_Clusters = KlustaImport(clu_file);
    end
       
    if ~isempty(KlustaKwik_Clusters)
       KlustaKwikCallbacks('ConvertKKCut');
       KlustaKwikCallbacks('RedrawBubbleTree');
       %KlustaKwikCallbacks('Show BB');
       KlustaKwikCallbacks('Redraw axes');
       %KlustaKwikCallbacks('DoStats');
   end

case 'CutPreClusters'
   global MClust_FeatureData
   if isempty(MClust_FeatureData)
      errordlg('No features calculated.', 'MClust error', 'modal');
   else
      GeneralizedCutter(MClust_Clusters, MClust_FeatureData, MClust_FeatureNames, 'mcconvexhull');
   end


case 'CutWithConvexHulls'
   global MClust_FeatureData
   if isempty(MClust_FeatureData)
      errordlg('No features calculated.', 'MClust error', 'modal');
   else
      GeneralizedCutter(MClust_Clusters, MClust_FeatureData, MClust_FeatureNames, 'mcconvexhull');
   end
   
   
case 'ViewClusters'
   ViewClusters;
   
      
case 'LoadCut'
   global MClust_Clusters
   fn = uigetfile('*.cut');
   if fn
      MClust_Clusters = LoadPreCut(fn);
   end
   
case 'SaveClusters'
   [basedn, basefn, ext] = fileparts(MClust_TTfn);
   switch computer
   case 'SOL2', [fn,dn] = uiputfile([basefn '.clusters']);
   case 'PCWIN', [fn,dn] = uiputfile(fullfile(basedn, [basefn '.clusters']));
   end
   if fn
      featureToUseHandle = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
      featuresToUse = get(featureToUseHandle, 'String');
      global MClust_FeatureIndex
      featureindex = MClust_FeatureIndex;
      save(fullfile(dn,fn), 'MClust_Clusters', 'MClust_FeatureNames', ...
         'MClust_ChannelValidity','featuresToUse','featureindex','-mat');
      msgbox('Clusters saved successfully.', 'MClust msg');
   end
   
case 'LoadClusters'
   [basedn, basefn, ext] = fileparts(MClust_TTfn);
   [fn,dn] = uigetfile(fullfile(basedn, '*.clusters'));
   
   if fn
      [fpath fname fext] = fileparts(fn);
      currentFeatureNames = MClust_FeatureNames;
      msg = {};
      MC_C = MClust_Clusters;
      global MClust_FeatureIndex
      global MClust_ClusterFileNames
      msg{end + 1} = ['Loading clusters from ' fn];
      try
          load(fullfile(dn,fn), 'MClust_Clusters', 'MClust_FeatureNames','featureindex', '-mat');
      catch
          load(fullfile(dn,fn), 'MClust_Clusters', 'MClust_FeatureNames', '-mat');
      end
      for iC = 1:length(MClust_Clusters)
          MClust_ClusterFileNames{length(MC_C) + iC} = [fname ' Cluster ' num2str(iC)];
      end
      
      if exist('featureindex','var')
          if length(MClust_FeatureIndex) > length(featureindex)
              if (sum(MClust_FeatureIndex(1:length(featureindex)) == featureindex)/length(featureindex)) ~= 1
                  msg{end + 1} = 'Converting clusters to current feature index';
                  for iC = 1:length(MClust_Clusters)
                      MClust_Clusters{iC} = ConvertFI(MClust_Clusters{iC},featureindex);
                  end
              end 
          else
              if (sum(MClust_FeatureIndex(1:100) == featureindex(1:100))/100) ~= 1
                  msg{end + 1} = 'Converting clusters to current feature index';
                  for iC = 1:length(MClust_Clusters)
                      MClust_Clusters{iC} = ConvertFI(MClust_Clusters{iC},featureindex);
                  end
              end
          end
      else
          msg{end + 1} = 'No featureindex found; continuing without index conversion';
      end
      MClust_Clusters = [MC_C MClust_Clusters];
      if length(MClust_FeatureNames) ~= length(currentFeatureNames) | ~all(strcmp(currentFeatureNames, MClust_FeatureNames))
         msg{end + 1} = 'Feature name mismatch!';
         msg{end + 1} =  'Attempting conversion to current feature names.';
         WereErrors = [];
         for iC = 1:length(MClust_Clusters)
              [MClust_Clusters{iC} ConversionError] = ConvertCluster(MClust_Clusters{iC},MClust_FeatureNames,currentFeatureNames);
              if ~isempty(ConversionError)
                  disp(['Cluster ' num2str(iC) ' has the following limits which require features not currently used: '])
                  for iX = 1:size(ConversionError,1)
                      disp([MClust_FeatureNames{ConversionError(iX,1)} ' x ' MClust_FeatureNames{ConversionError(iX,2)}]);
                  end
                  WereErrors = [WereErrors size(ConversionError,1)];
              end
         end
         MClust_FeatureNames = currentFeatureNames;
         if ~isempty(WereErrors)
             msg{end + 1} = [num2str(sum(WereErrors)) ' Conversion errors were found'];
             msg{end + 1} = 'Clusters were not successfully loaded, not all limits from original clusters are being used';
         else    
            msg{end + 1} = 'Clusters converted successfully.';
         end
      else
         msg{end + 1} = 'Clusters converted successfully.';
      end
    msgbox(msg,'MClust msg');
   end
   
   
case 'LoadKKCut'
    % does not currently allow you to load more that one set of *.clu into memory at one time
    global MClust_Clusters
    global MClust_FDfn
    [p,n,e] = fileparts(MClust_FDfn);
    expExtension = [p filesep n '*.clu.*'];
    
    [fn, fdir] = uigetfile(expExtension);
    
    if fn == 0
        return
    end
    % Get the file and remove any . extensions (there are 
    % more than one so you need to run this a couple times).
    [p rootname e ] = fileparts(fn);
    [p rootname e ] = fileparts(rootname);
    [p rootname e ] = fileparts(rootname);
    
    if rootname
		% Load in the clusters from KlustaKwik
		file_no = 1;
		clu_file = [fullfile(fdir,rootname) '.clu.' num2str(file_no)];
		MClust_Clusters = KlustaImport(clu_file);
    end
    
% Creat a cluster from a .t file
case 'LoadTfile'
    global MClust_Clusters MClust_FeatureTimestamps MClust_ClusterFileNames
    global MClust_TTfn
    [p,n,e] = fileparts(MClust_TTfn);
    spikefile = [p filesep n '*.t'];
    [fn, fdir] = uigetfile(spikefile);
    
    if fn == 0
        return
    end
    
    spikes = loadspikes({[fdir filesep fn]},'tsflag','ts');
    stimes = data(spikes{1});
    
    ix = zeros(size(stimes));
	for iIX = 1:length(stimes)
		ix(iIX) = binsearch(MClust_FeatureTimestamps, stimes(iIX));
	end
    
    MClust_Clusters{end+1} = precut(ix,'indices');
    MClust_ClusterFileNames{end + 1} = ['From ' fn];
    
case 'ClearClusters'
   ynClose = questdlg('Clearing clusters.  No undo available. Are you sure?', 'ClearQuestion', 'Yes', 'Cancel', 'Cancel');
   if strcmp(ynClose,'Yes')
      MClust_Clusters = {};
      global MClust_ClusterFileNames
      MClust_ClusterFileNames = [];
   end
  
case 'ClearWKSPC'
    
   global MClust_Colors
   MCColors = MClust_Colors;
   clear global BBClust* MClust_* KK* KlustaKwik_*
        
   global MClust_FeaturesToUse MClust_Colors
   MClust_Colors = MCColors;
   FeaturesUseListbox = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
   FeaturesToUse = get(FeaturesUseListbox, 'String')';
   MClust_FeaturesToUse = FeaturesToUse;
   
   global MClust_Clusters;
   MClust_Clusters = {};
   
   global MClust_Hide MClust_UnaccountedForOnly
   MClust_Hide = zeros(64,1);
   MClust_UnaccountedForOnly = 0;
        
   MClust_FileType = [];
   
   set(findobj(figHandle, 'Tag', 'LoadFeaturesButton'), 'Value', 0);  
   
   set(findobj(figHandle, 'Tag', 'FeaturesIgnoreListbox'), 'Enable','on');
   set(findobj(figHandle, 'Tag', 'FeaturesUseListbox'), 'Enable','on');
   
   % update Channel Validity Checkboxes with used channels in featurefile
   set(findobj(figHandle, 'Tag', 'TTValidity1'), 'Value', 1);
   set(findobj(figHandle, 'Tag', 'TTValidity2'), 'Value', 1);
   set(findobj(figHandle, 'Tag', 'TTValidity3'), 'Value', 1);
   set(findobj(figHandle, 'Tag', 'TTValidity4'), 'Value', 1);
        
   set(findobj(figHandle, 'Tag', 'TTFileName'), 'String', []);
   
case 'ClearWorkspace'
    ynClose = questdlg('Clearing workspace.  No undo available. Are you sure?', 'ClearQuestion', 'Yes', 'Cancel', 'Cancel');
    if strcmp(ynClose,'Yes')
        BBMClustCallbacks('WriteFiles');
        BBMClustCallbacks('ClearWKSPC');
    end
    
case 'ClearWorkspaceOnly'
    ynClose = questdlg('Clearing workspace.  No undo available. Are you sure?', 'ClearQuestion', 'Yes', 'Cancel', 'Cancel');
    if strcmp(ynClose,'Yes')
        ynWriteFiles = questdlg('Write files before clearing workspace?', 'ClearQuestion', 'Yes', 'No', 'Yes');
        if strcmp(ynWriteFiles,'Yes')
            BBMClustCallbacks('WriteFiles');
        end
        BBMClustCallbacks('ClearWKSPC');
    end
  
   
case 'SaveDefaults'
   global MClust_Colors MClust_ChannelValidity
   global MClust_Directory
   pushdir(MClust_Directory);
   [fn,dn] = uiputfile('defaults.mclust');
   popdir;
   if fn     
      featureToUseHandle = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
      featuresToUse = get(featureToUseHandle, 'String');
      filetypeHandle = findobj(figHandle, 'Tag', 'InputType');
      MClust_FileType = get(filetypeHandle, 'value');
      save(fullfile(dn,fn), 'MClust_Colors', 'featuresToUse', 'MClust_ChannelValidity', 'MClust_FileType', '-mat');
      msgbox('Defaults saved successfully.', 'MClust msg');
   end
   
case 'LoadDefaults'
   global MClust_Colors MClust_ChannelValidity
   global MClust_Directory
   MClust_FileType = [];
   pushdir(MClust_Directory);
   [fn,dn] = uigetfile('*.mclust');
   popdir;
   if fn
      load(fullfile(dn, fn), '-mat');
      
      % file type
      if ~isempty(MClust_FileType)
          filetypeHandle = findobj(figHandle, 'Tag', 'InputType');
          set(filetypeHandle, 'value', MClust_FileType);
      end
      
      % fix features to use boxen
      uifeaturesIgnoreHandle = findobj(figHandle, 'Tag', 'FeaturesIgnoreListbox');
      uifeaturesUseHandle = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
      uiChooseFeaturesButton = findobj(figHandle, 'Tag', 'ChooseFeatures');
      allFeatures = [get(uifeaturesIgnoreHandle, 'String'); get(uifeaturesUseHandle, 'String')];
      featureIgnoreString = {};
      featureUseString = {};
      for iF = 1:length(allFeatures)
          if any(strcmp(allFeatures{iF}, featuresToUse))
              featureUseString = cat(1, featureUseString, allFeatures(iF));
          else
              featureIgnoreString = cat(1, featureIgnoreString, allFeatures(iF));
          end
      end
      set(uifeaturesIgnoreHandle, 'String', featureIgnoreString);
      set(uifeaturesUseHandle, 'String', featureUseString);
      if ~isempty(featureUseString)
          set(uiChooseFeaturesButton, 'Value', 1);
      end
      
      % fix channel validity 
      uich1 = findobj(figHandle, 'Tag', 'TTValidity1');
      uich2 = findobj(figHandle, 'Tag', 'TTValidity2');
      uich3 = findobj(figHandle, 'Tag', 'TTValidity3');
      uich4 = findobj(figHandle, 'Tag', 'TTValidity4');
      switch get(cboHandle, 'value') 
      case {1,2} % TT 
          set(uich1, 'value', 1, 'enable', 'on');
          set(uich2, 'value', 1, 'enable', 'on');
          set(uich3, 'value', 1, 'enable', 'on');
          set(uich4, 'value', 1, 'enable', 'on');
      case 3 % ST
          set(uich1, 'value', 1, 'enable', 'on');
          set(uich2, 'value', 1, 'enable', 'on');
          set(uich3, 'value', 0, 'enable', 'off');
          set(uich4, 'value', 0, 'enable', 'off');
      case 4 % SE
          set(uich1, 'value', 1, 'enable', 'on');
          set(uich2, 'value', 0, 'enable', 'off');
          set(uich3, 'value', 0, 'enable', 'off');
          set(uich4, 'value', 0, 'enable', 'off');
      otherwise
          error('Internal error: Unknown Input type');
      end
      
      set(uich1, 'Value', MClust_ChannelValidity(1));
      set(uich2, 'Value', MClust_ChannelValidity(2));
      set(uich3, 'Value', MClust_ChannelValidity(3));
      set(uich4, 'Value', MClust_ChannelValidity(4));
  end
  
case 'WriteFiles'
   clusterIndex = ProcessClusters(MClust_FeatureData, MClust_Clusters);
   [basedn, basefn, ext] = fileparts(MClust_TTfn);
   featureToUseHandle = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
   featuresToUse = get(featureToUseHandle, 'String');
   global MClust_FeatureIndex
   featureindex = MClust_FeatureIndex;
   save([fullfile(basedn, basefn), '.clusters'], 'MClust_Clusters', ...
      'MClust_FeatureNames', 'MClust_ChannelValidity', 'featuresToUse','featureindex', '-mat');
   WriteClusterIndexFile([fullfile(basedn, basefn), '.cut'], clusterIndex);
   WriteTFiles(fullfile(basedn, basefn), MClust_TTData, MClust_FeatureData, MClust_Clusters);
   msgbox('Files written.', 'MClust msg');
   
case 'About'
  helpwin MClust
  
case 'ExitOnlyButton'    
   ynClose = questdlg('Exiting BBClust without automatic Write Files.  Are you sure? Did you save all clusters?', 'ExitQuestion', 'Yes', 'Cancel', 'Cancel');
   if strcmp(ynClose,'Yes')
      BBMClustCallbacks('ClearWKSPC');
      close(figHandle);
   end

   
case 'ExitButton'
   % automatically write all files and close window
   BBMClustCallbacks('WriteFiles');
   BBMClustCallbacks('ClearWKSPC');
   close(figHandle);
   
otherwise
   warndlg('Sorry, feature not yet implemented.');  
end % switch