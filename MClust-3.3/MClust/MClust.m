function MClust

% MClust main window
% 
% Each uicontrol is given a Tag that is descriptive of its
% role.  All callbacks are sent to MClustCallbacks.  There
% a switch statement will case on the Tag to run each routine.
%
% ADR 1998
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.
%
  
%
% modified for manual editing of MClust clusters
% PL 05/08/2001
% version BB0.2
%
%
% modified to use feature data files instead of loading TT data into memory
% and to be able to load .clu files from KlustaKwik output
% and to only keep feature data in memory from 3 features (1 for each axis in the View Clusters 3D plot)
% when axes are changed, the new feature data is loaded from file.
% Each file has one _(feature) file for each feature that is used.  As many features as are desired can be used for cutting
% Choose features before loading the feature data file.  If you choose a feature that does not have a feature data file yet,
% one will be created.
%
% Also, if a FD is too large to use BubbleClust or KlustaKwik on it, it can be split into multiple files by RunClustBatch.m.  
% For each case, if you select pre clusters from the split files and save these clusters, then you can load the original (unsplit)
% feature data file into memory (just choose one of the feature data files (such as TT6_peak.fd)) and then load each of the sets of clusters 
% into memory.  Each file of clusters is tagged with the filename in the Generalized Cutter, so that it is easier to keep clusters straight.
%
% You can use wavePC1, 2 and 3.  For these features, the principal components are calculated using the first block of spikes loaded into memory, 
% and then applied to the rest of the blocks that are loaded (Per a suggestion in Write_fd_file.m).
% 
% ncst 20 Jan 02
% adr 20 may 02 added engine listbox
% ncst Jan 03: multiple changes: added cluster separation, added global
%   variables to keep track of window positions and marker types and sizes.
%   Saved clusters include cluster names and colors.  Standard cluster type
%   is mcconvexhull.  Added cowen's Waveform_density and WaveformCutter
%----------------------------------


% set up global variables
global MClust_max_records_to_load
MClust_max_records_to_load = 20000;

global MClust_TTData MClust_FeatureData
global MClust_Clusters;
MClust_Clusters = {};

global MClust_Colors
MClust_Colors = colorcube; close;
featuresToUse = [];

global MClust_Hide MClust_UnaccountedForOnly
MClust_Hide = zeros(64,1);
MClust_UnaccountedForOnly = 0;

MClust_FileType = [];

global MClust_Directory
MClust_Directory = fileparts(which('MClust.m'));

global MClust_FilesWrittenYN
MClust_FilesWrittenYN = 'no';

global MClust_ClusterSeparationFeatures 
MClust_ClusterSeparationFeatures{end+1} = 'energy';

global MClust_ClusterCutWindow_Pos
MClust_ClusterCutWindow_Pos= [10 60 450 650];

global MClust_CHDrawingAxisWindow_Pos
MClust_CHDrawingAxisWindow_Pos= [500 200 650 650];

global MClust_KKDecisionWindow_Pos
MClust_KKDecisionWindow_Pos = [10 60 600 780];

global MClust_KK2D_Pos 
MClust_KK2D_Pos = [629 379 515 409];

global MClust_KK3D_Pos
MClust_KK3D_Pos = [633 300 510 363];

global MClust_KKContour_Pos
MClust_KKContour_Pos = [702 44 391 249];

global MClust_ClusterCutWindow_Marker
global MClust_ClusterCutWindow_MarkerSize

MClust_ClusterCutWindow_Marker = 1;
MClust_ClusterCutWindow_MarkerSize = 1;
%%%%%% ------ modified batta 5/7/01 -----------------------
global BBClustFilePrefix;
global BBClustFileDir;
BBClustFilePrefix = [];

% read defaults if available
fp = fopen('defaults.mclust');
if fp == -1
   pushdir(MClust_Directory);
   fp = fopen('defaults.mclust');
else 
   pushdir;
end
if fp ~= -1
   fclose(fp);
   load defaults.mclust -mat
end
popdir;

% resize windows if necessary
ScSize = get(0, 'ScreenSize');
maxX = ScSize(3);
maxY = ScSize(4);
WindowList = {};
WindowList{end+1} = 'MClust_ClusterCutWindow_Pos';
WindowList{end+1} = 'MClust_CHDrawingAxisWindow_Pos';
WindowList{end+1} = 'MClust_KKDecisionWindow_Pos';
WindowList{end+1} = 'MClust_KK2D_Pos';
WindowList{end+1} = 'MClust_KK3D_Pos';
WindowList{end+1} = 'MClust_KKContour_Pos';

for iW = 1:length(WindowList)
	if eval(['sum(' WindowList{iW} '([1 3])) > maxX'])
		eval([WindowList{iW} '([1 3]) = [maxX - 500 400];']);
	end
	if eval(['sum(' WindowList{iW} '([2 4])) > maxY'])
		eval([WindowList{iW} '([2 4]) = [maxY - 500 400];']);
	end
end
%----------------------------------
% main window

MClustMainFigureHandle = figure(...
   'Name','MClust', ...
   'NumberTitle','off', ...   
   'Tag','MClustMainWindow', ...,
   'Resize', 'Off', ...
   'Units', 'Normalized', ...
   'HandleVisibility', 'Callback');
% resize
X = get(MClustMainFigureHandle, 'Position');
set(MClustMainFigureHandle, 'Position', [X(1) X(2)-.25 X(3) X(4)+.25]); 

%-------------------------------
% Alignment variables

uicHeight = 0.04;
uicWidth  = 0.25;
dX = 0.3;
XLocs = 0.1:dX:0.9;
dY = 0.04;
YLocs = 0.9:-dY:0.1;
FrameBorder = 0.01;


% Buttons and status

uicontrol('Parent', MClustMainFigureHandle, ... 
   'Units', 'Normalized', 'Position', [XLocs(1)-FrameBorder YLocs(end)-FrameBorder dX 0.85+2*FrameBorder], ...
   'Style', 'frame');

% loading engine
global MClust_NeuralLoadingFunction

LoadingEngineDirectory = fullfile(MClust_Directory, 'LoadingEngines');
LoadingEnginesM = FindFiles('*.m', 'StartingDirectory', LoadingEngineDirectory);
LoadingEnginesDLL = FindFiles('*.dll', 'StartingDirectory', LoadingEngineDirectory);
LoadingEngines = sort(cat(1, LoadingEnginesM, LoadingEnginesDLL));
for iV = 1:length(LoadingEngines)
    [d f] = fileparts(LoadingEngines{iV});
    LoadingEngines{iV} = f;
end
if isempty(LoadingEngines)
    close(MClustManFigureHandle)
    error('No Loading Engines found.');
end
if ~isempty(MClust_NeuralLoadingFunction) 
    LoadingEngineValue = strmatch(MClust_NeuralLoadingFunction,LoadingEngines);
else
    LoadingEngineValue = [];
end 
if isempty(LoadingEngineValue) 
    MClust_NeuralLoadingFunction = LoadingEngines{1};
    LoadingEngineValue = 1;
end

uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(1) YLocs(1) uicWidth uicHeight], ...
   'Style', 'Popupmenu', 'Tag', 'SelectLoadingEngine', 'Callback', 'MClustCallbacks', ...
   'String', LoadingEngines, 'Value', LoadingEngineValue, ...
   'TooltipString', 'Select loading engine to use for input to MClust');

% onward
global MClust_TTfn
if ~isempty(MClust_TTfn)
   [curdn, curfn] = fileparts(MClust_TTfn);
else
   curfn = [];
end
uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(1) YLocs(3) uicWidth uicHeight], ...
   'Style', 'Text', 'String', curfn, 'Tag', 'TTFileName')

ui_ChooseFeaturesButton = ...
   uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(1) YLocs(4) uicWidth uicHeight], ...
   'Style', 'CheckBox', 'String', 'Create/Load FD files (*.fd)', 'Tag', 'LoadFeaturesButton', ...
   'Callback', 'MClustCallbacks','Value', ~isempty(MClust_FeatureData), ...
   'TooltipString', 'Choose tetrode .dat or feature data file to use as input to MClust');

uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(1)+0.02 YLocs(7) uicWidth-0.04 uicHeight], ...
   'Style', 'PushButton', 'String', 'BBClust Selection', 'Tag', 'BBClustSelection', ...
   'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Select pre-clusters from BBClust hierarchical contour merging tree');

uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(1)+0.02 YLocs(8) uicWidth-0.04 uicHeight], ...
   'Style', 'PushButton', 'String', 'KlustaKwik Selection', 'Tag', 'KlustaKwikSelection', ...
   'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Select clusters from KlustaKwik .clu files');

uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(1) YLocs(10) uicWidth uicHeight], ...
   'Style', 'PushButton', 'String', 'ManualCut: Convex hull', 'Tag', 'CutPreClusters', ...
   'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Edit pre-clusters by adding convex hulls selected pairs of dimensions');

uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(1) YLocs(19) uicWidth uicHeight], ...
   'Style', 'PushButton', 'String', 'Write Files', 'Tag', 'WriteFiles', 'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Write clusters to disk.  Writes t-files, cluster-files, and cut-files.');

uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(1) YLocs(20) uicWidth uicHeight], ...
   'Style', 'PushButton', 'String', 'Exit', 'Tag', 'ExitOnlyButton', 'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Exit MClust');


uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(1) YLocs(14) uicWidth uicHeight], ...
   'Style', 'PushButton', 'String', 'View Clusters 3D', 'Tag', 'ViewClusters', ...
   'Callback', 'MClustCallbacks', ...
   'TooltipString', 'View already cut clusters');

% Features to use

% Create Feature Listboxes
uicontrol('Parent', MClustMainFigureHandle,...
   'Style', 'text', 'String', 'FEATURES', 'Units', 'Normalized', 'Position', [XLocs(2) YLocs(1) 2*uicWidth uicHeight]);
uicontrol('Parent', MClustMainFigureHandle,...
   'Style', 'text', 'String', 'available', 'Units', 'Normalized', 'Position', [XLocs(2) YLocs(2) uicWidth uicHeight]);
ui_featuresIgnoreLB =  uicontrol('Parent', MClustMainFigureHandle,...
   'Units', 'Normalized', 'Position', [XLocs(2) YLocs(8) uicWidth 6*uicHeight],...
   'Style', 'listbox', 'Tag', 'FeaturesIgnoreListbox',...
   'Callback', 'MClustCallbacks',...
   'HorizontalAlignment', 'right', ...
   'Enable','on', ...
   'TooltipString', 'These are features which are not included but are also available.');
uicontrol('Parent', MClustMainFigureHandle,...
   'Style', 'text', 'String', 'used', 'Units', 'Normalized', 'Position', [XLocs(2)+uicWidth YLocs(2) uicWidth uicHeight]);
ui_featuresUseLB = uicontrol('Parent', MClustMainFigureHandle,...
   'Units', 'Normalized', 'Position', [XLocs(2)+uicWidth YLocs(8) uicWidth 6*uicHeight],...
   'Style', 'listbox', 'Tag', 'FeaturesUseListbox',...
   'Callback', 'MClustCallbacks',...
   'HorizontalAlignment', 'right', ...
   'Enable','on', ...
   'TooltipString', 'These features will be used.');
set(ui_featuresIgnoreLB, 'UserData', ui_featuresUseLB);
set(ui_featuresUseLB,    'UserData', ui_featuresIgnoreLB);

% Locate and load the names of feature files
featureFiles =  sortcell(FindFiles('feature_*.m', ...
    'StartingDirectory', fullfile(MClust_Directory, 'Features') ,'CheckSubdirs', 0));
featureIgnoreString = {};
featureUseString = {};
for iF = 1:length(featureFiles)
   [dummy, featureFiles{iF}] = fileparts(featureFiles{iF});
   featureFiles{iF} = featureFiles{iF}(9:end); % cut "feature_" off front for display
   if any(strcmp(featureFiles{iF}, featuresToUse))
      featureUseString = cat(1, featureUseString, featureFiles(iF));
   else
      featureIgnoreString = cat(1, featureIgnoreString, featureFiles(iF));
   end
end
set(ui_featuresIgnoreLB, 'String', featureIgnoreString);
set(ui_featuresUseLB, 'String', featureUseString);
%if ~isempty(ui_featuresUseLB)
  % set(ui_ChooseFeaturesButton, 'Value', 1);
   %end



% tetrode validity
uicontrol('Parent', MClustMainFigureHandle,...
   'Units', 'Normalized', 'Position', [XLocs(2) YLocs(9) 2*uicWidth uicHeight],...
   'Style', 'text', 'String', 'CHANNEL VALIDITY');
uicontrol('Parent', MClustMainFigureHandle,...
   'Units', 'Normalized', 'Position', [XLocs(2)+0*uicWidth/2 YLocs(10) uicWidth/2 uicHeight],...   
   'Style', 'checkbox', 'String', 'Ch 1', 'Tag', 'TTValidity1', 'Value', 1, 'HorizontalAlignment', 'left', ...
    'Enable','on', 'TooltipString', 'Include channel 1 in feature calculation.');
uicontrol('Parent', MClustMainFigureHandle,...
   'Units', 'Normalized', 'Position', [XLocs(2)+1*uicWidth/2 YLocs(10) uicWidth/2 uicHeight],...   
   'Style', 'checkbox', 'String', 'Ch 2', 'Tag', 'TTValidity2', 'Value', 1, 'HorizontalAlignment', 'left', ...
    'Enable','on', 'TooltipString', 'Include channel 2 in feature calculation.');
uicontrol('Parent', MClustMainFigureHandle,...
   'Units', 'Normalized', 'Position', [XLocs(2)+2*uicWidth/2 YLocs(10) uicWidth/2 uicHeight],...   
   'Style', 'checkbox', 'String', 'Ch 3', 'Tag', 'TTValidity3', 'Value', 1, 'HorizontalAlignment', 'left', ...
    'Enable','on', 'TooltipString', 'Include channel 3 in feature calculation.');
uicontrol('Parent', MClustMainFigureHandle,...
   'Units', 'Normalized', 'Position', [XLocs(2)+3*uicWidth/2 YLocs(10) uicWidth/2 uicHeight],...   
   'Style', 'checkbox', 'String', 'Ch 4', 'Tag', 'TTValidity4', 'Value', 1, 'HorizontalAlignment', 'left', ...
    'Enable','on', 'TooltipString', 'Include channel 4 in feature calculation.');




% Loading and saving components
uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(2)-FrameBorder YLocs(end)-FrameBorder 2*(uicWidth+FrameBorder) uicHeight*11], ...
   'Style', 'frame');

uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(2) YLocs(12) uicWidth uicHeight], ...
   'Style', 'PushButton', 'String', 'Load clusters', 'Tag', 'LoadClusters', 'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Load already cut clusters. Features and channel validity MUST BE identical to previous session.');
uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(2) YLocs(13) uicWidth uicHeight], ...
   'Style', 'PushButton', 'String', ' Load KKwik .clu', 'Tag', 'LoadKKCut', 'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Load already cut clusters from KlustaKwik. No boundary (convex hull) info is included in .clu.* files');
uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(2) YLocs(14) uicWidth uicHeight], ...
   'Style', 'PushButton', 'String', 'Create cluster from .t', 'Tag', 'LoadTfile', 'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Load already cut clusters from a .t file. No boundary (convex hull) info is included in .clu.* files');
uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(2) YLocs(16) uicWidth uicHeight], ...
   'Style', 'PushButton', 'String', 'Save clusters', 'Tag', 'SaveClusters', 'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Save clusters but do not write t-files.');
uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(2) YLocs(17) uicWidth uicHeight], ...
   'Style', 'PushButton', 'String', 'Clear Clusters', 'Tag', 'ClearClusters', ...
   'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Clear clusters.  No undo available.');
uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(2) YLocs(18) uicWidth uicHeight], ...
   'Style', 'PushButton', 'String', 'Clear Workspace', 'Tag', 'ClearWorkspaceOnly', ...
   'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Remove all clusters and feature data files currently in memory');


uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(2) YLocs(20) uicWidth uicHeight], ...
   'Style', 'PushButton', 'String', 'Load defaults', 'Tag', 'LoadDefaults', 'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Load defaults.  Defaults include color scheme, features, and channel validity.');
uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(2) YLocs(21) uicWidth uicHeight], ...
   'Style', 'PushButton', 'String', 'Save defaults', 'Tag', 'SaveDefaults', 'Callback', 'MClustCallbacks', ...
   'TooltipString', 'Save defaults.  Defaults include color scheme, features, and channel validity.');

uicontrol('Parent', MClustMainFigureHandle, ...
   'Units', 'Normalized', 'Position', [XLocs(2)+uicWidth YLocs(21) uicWidth uicHeight * 10], ...
   'Style', 'text', ...
   'String', { 'MClust 3.21', '2003', '', 'By AD Redish', ' ', ...
       ' with modifications by ', 'P Lipa', 'S Cowen', 'JC Jackson', 'NC Schmitzer-Torbert', 'F Battaglia', ...
       ' ', ' BubbleClust by P. Lipa', ' ', ' KlustaKwik by K. Harris'
   });