function GeneralizedCutter(currentClusters, featureData, featureNames, clusterType)

% GeneralizedCutter(currentClusters, featureData, featureNames)
% 
% INPUTS
%     currentClusters 
%     featureData = nS x nD data
%     featureNames = names of feature data dimensions
%
% OUTPUTS
%     modifies MClust_Clusters
%
% ADR 1998
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

global MClust_Autosave
global MClust_Clusters MClust_FeatureData MClust_FeaturesToUse MClust_FeatureTimestamps 
global MClust_TTData MClust_TTfn MClust_ChannelValidity
global MClust_FeatureIndex MClust_ClusterFileNames

MClust_Autosave = 10;

%--------------------------------
% constants to make everything identical

uicHeight = 0.05;
uicWidth  = 0.175;
uicWidth0 = 0.075;
uicWidth1 = 0.10;
dX = 0.3;
XLocs = [0.05 0.40:uicWidth1:0.9];
dY = 0.05;
YLocs = 0.9:-dY:0.05;
FrameBorder = 0.01;

% -------------------------------
% if given clusters, convert to BBClust mixed point and convex hull representations
MClust_Clusters = {};
nClusters = length(currentClusters);
if ~isempty(currentClusters)
    for iC = 1:nClusters
        DisplayProgress(iC, nClusters, 'Title', 'Converting pre-clusters to MClust clusters');
        if isa(currentClusters{iC}, clusterType)  
            MClust_Clusters{iC} = currentClusters{iC};
        elseif isa(currentClusters{iC}, 'precut')
            MClust_Clusters{iC} = feval(clusterType, currentClusters{iC});
%             MClust_Clusters{iC} = feval(clusterType, MClust_FeatureData( FindInCluster(currentClusters{iC}) ,:) );
        elseif isa(currentClusters{iC}, 'bbconvexhull')
            
            tempClust = BBConvexHullToStruct(currentClusters{iC}); 
            MClust_Clusters{iC} = mcconvexhull(tempClust);
%             MClust_Clusters{iC} =currentClusters{iC};
            %feval(clusterType, currentClusters{iC});
        else 
            error([' Generalized Cutter Error: ' class(clusterType) ' is a unknown cluster type'])  
        end
        if length(MClust_ClusterFileNames) < iC
            MClust_ClusterFileNames{iC} = ['Precluster no. ' num2str(iC)];
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If, for instance when exporting from BBCLust, there are no feature timestamps, 
% generate them by getting them from either the TT data or from the file itself.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(MClust_FeatureTimestamps)
    % determine if time is a feature. If so, assign MClust_featurestimestamps
    % to that value.
    time_index = 0;
    n_features = length(MClust_FeaturesToUse);
    for ii = 1:n_features
        if strcmpi(MClust_FeaturesToUse{ii},'time')
            time_index = ii;
        end
    end
    % If time is a feaure, use it for FeatureTImestamps
    if time_index & isempty(MClust_FeatureTimestamps)
        % Determine which column time is in the FD 
        index_in_FD = sum(MClust_ChannelValidity)*(n_features-1) + 1;
        MClust_FeatureTimestamps = MClust_FeatureData(:,index_in_FD);
    else
        % if not, create time from the TT file or from the TTdata in memory.
        if isempty(MClust_TTData)
            % MClust_FeatureTimestamps = LoadTT0_nt(MClust_TTfn);
            % REPLACED ADR 14 May 2002
            MClust_FeatureTimestamps = MClust_LoadNeuralData(MClust_TTfn);            
        else
            MClust_FeatureTimestamps = Range(MClust_TTData,'ts');
        end
    end
end


%-------------------------------
% figure
global MClust_ClusterCutWindow_Pos

figHandle = figure(...
    'Name', ['Cluster Cutting Control Window (', clusterType, ')'],...
    'NumberTitle', 'off', ...
    'Tag', 'ClusterCutWindow', ...
    'HandleVisibility', 'Callback', ...
    'UserData', featureData, ...
    'Position', MClust_ClusterCutWindow_Pos, ...
    'CreateFcn', 'GeneralizedCutterCallbacks');

% -------------------------------
% axes
global MClust_TTfn

uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(1) uicWidth0 + uicWidth uicHeight], ...
    'Style', 'text', 'String', {MClust_TTfn, 'Axes'});
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(2) uicWidth0 uicHeight], ...
    'Style', 'text', 'String', ' X: ');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1)+uicWidth0 YLocs(2) uicWidth uicHeight],...
    'Style', 'popupmenu', 'Tag', 'xdim', 'String', featureNames, ...
    'Callback', 'GeneralizedCutterCallbacks', 'Value', 1, ...
    'TooltipString', 'Select x dimension');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(3) uicWidth0 uicHeight], ...
    'Style', 'text', 'String', ' Y: ');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1)+uicWidth0 YLocs(3) uicWidth uicHeight],...
    'Style', 'popupmenu', 'Tag', 'ydim', 'String', featureNames, ...
    'Callback', 'GeneralizedCutterCallbacks', 'Value', 2, ...
    'TooltipString', 'Select y dimension');

uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(4) uicWidth0 uicHeight], ...
    'Style', 'pushbutton', 'Tag', 'PrevAxis', 'String', '<', 'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString', 'Step backwards');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1)+uicWidth0 YLocs(4) uicWidth-uicWidth0 uicHeight], ...
    'Style', 'text', 'String', 'Axis');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1)+uicWidth YLocs(4) uicWidth0 uicHeight], ...
    'Style', 'pushbutton', 'Tag', 'NextAxis', 'String', '>', 'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString', 'Step forwards');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(5) uicWidth+uicWidth0 uicHeight], ...
    'Style', 'checkbox', 'Tag', 'ViewAllDimensions', 'String', 'View all dimensions', ...
    'Value', 0, 'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString','Continuously step through all dimension pairs');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(6) uicWidth+uicWidth0 uicHeight], ...
    'Style', 'checkbox','Value', 0, 'Tag', 'RedrawAxes', 'String', 'Redraw Axes', ...
    'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString', 'If checked, redraw axes with each update.  Uncheck and recheck to redraw axes now.');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(7) uicWidth-uicWidth0 uicHeight], ...
    'Style', 'text', 'String', 'Marker');

global MClust_ClusterCutWindow_Marker
global MClust_ClusterCutWindow_MarkerSize

uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [uicWidth+XLocs(1)-uicWidth0 YLocs(7) uicWidth0 uicHeight], ...
    'Style', 'popupmenu', 'Value', MClust_ClusterCutWindow_Marker, 'Tag', 'PlotMarker', ...
    'String', {'.','o','x','+','*','s','d','v','^','<','>','p','h'}, ...
    'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString', 'Change marker');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [uicWidth+XLocs(1) YLocs(7) uicWidth0 uicHeight], ...
    'Style', 'popupmenu', 'Value', MClust_ClusterCutWindow_MarkerSize, 'Tag', 'PlotMarkerSize', ...
    'String', {1,2,3,4,5,10,15,20,25}, ...
    'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString', 'Change marker size');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(8) uicWidth+uicWidth0 uicHeight], ...
    'Style', 'pushbutton', 'String', 'ShowContourPlot', 'Tag', 'ContourPlot', ...
    'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString', 'Contour plot of current axis');

%----------------------------------
% general control
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(10) (uicWidth+uicWidth0)/2 uicHeight], ...
    'UserData', clusterType, ...
    'Style', 'pushbutton', 'String', 'Add', 'Tag', 'Add Cluster', ...
    'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString', 'Add a cluster object');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1)+(uicWidth+uicWidth0)/2 YLocs(10) (uicWidth+uicWidth0)/2 uicHeight], ...
    'Style', 'pushbutton', 'String', 'Pack', 'Tag', 'Pack Clusters', ...
    'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString', 'Pack clusters; clear unused clusters');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(11) (uicWidth+uicWidth0)/2 uicHeight], ...
    'Style', 'pushbutton', 'String', 'Hide', 'Tag', 'HideAll', ...
    'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString', 'Hide all clusters');
uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1)+(uicWidth+uicWidth0)/2 YLocs(11) (uicWidth+uicWidth0)/2 uicHeight], ...
    'Style', 'pushbutton', 'String', 'Show', 'Tag', 'ShowAll', ...
    'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString', 'Show all clusters');

uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(12) uicWidth+uicWidth0 uicHeight], ...
    'Style', 'pushbutton', 'String', 'Undo', 'Tag', 'Undo', ...
    'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString', 'Undo one step');

% Cutter optiosn
global MClust_Directory
pushdir([MClust_Directory filesep 'GeneralizedCutterOptions' filesep]);
CutterOptionsFiles = FindFiles('*.m','CheckSubdirs',0);
Extra_Options = {};
for iCOF = 1:length(CutterOptionsFiles)
	[dummy_fd Extra_Options{iCOF} ext] = fileparts(CutterOptionsFiles{iCOF});
end
popdir;

uicontrol('Parent', figHandle, ...
	'Units', 'Normalized', 'Position', [XLocs(1) YLocs(14) uicWidth+uicWidth0 uicHeight],...
	'Style', 'popupmenu', 'Tag', 'CutterFunctions', 'String', cat(2, {'------------------'},Extra_Options), ...
	'Callback', 'GeneralizedCutterCallbacks');

% uicontrol('Parent', figHandle, ...
%     'Units', 'Normalized', 'Position', [XLocs(1) YLocs(13) uicWidth+uicWidth0 uicHeight], ...
%     'Style', 'pushbutton','Tag', 'ChangeClusterSeparation', 'String', {'Cluster separation'; 'features'}, 'Callback', 'GeneralizedCutterCallbacks', ...
%     'TooltipString', 'Select what features are used for the cluster separation measure');
% 
% uicontrol('Parent', figHandle, ...
%     'Units', 'Normalized', 'Position', [XLocs(1) YLocs(15) uicWidth+uicWidth0 uicHeight], ...
%     'Style', 'pushbutton','Tag', 'CheckClusters', 'String', 'Check clusters', 'Callback', 'GeneralizedCutterCallbacks', ...
%     'TooltipString', 'Check all clusters');
% 
% uicontrol('Parent', figHandle, ...
%     'Units', 'Normalized', 'Position', [XLocs(1) YLocs(16) uicWidth+uicWidth0 uicHeight], ...
%     'Style', 'pushbutton','Tag', 'EvalOverlap', 'String', 'Eval overlap', 'Callback', 'GeneralizedCutterCallbacks', ...
%     'TooltipString', 'Eval overlap between all cluster pairs');

uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(17) uicWidth+uicWidth0 uicHeight], ... 
    'Style', 'pushbutton', 'Tag', 'Autosave', 'String', ['Autosave in ' num2str(MClust_Autosave)], ...
    'Callback', 'GeneralizedCutterCallbacks', ... 
    'TooltipString', 'Count steps to autosave'); 

uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(1) YLocs(end) uicWidth+uicWidth0 uicHeight], ...
    'Style', 'pushbutton', 'Tag', 'Exit', 'String', 'Exit', ...
    'Callback', 'GeneralizedCutterCallbacks', ...
    'TooltipString', 'Return to main window');

uicontrol('Parent', figHandle, ...
    'Units', 'Normalized', 'Position', [XLocs(end) YLocs(end) uicWidth0/2 length(YLocs) * dY], ...
    'Style', 'slider', 'Tag', 'ScrollClusters', 'Callback', 'GeneralizedCutterCallbacks', ...
    'Value', 0', 'Min', -99, 'Max', 0, ...
    'TooltipString', 'Scroll clusters');

curchildren = get(figHandle, 'children');
for i = 1:length(curchildren);
    set(curchildren(i), 'Fontname', 'Ariel');
    set(curchildren(i), 'Fontsize', 8);
end;