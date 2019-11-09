function ViewClustersCallbacks()

% ViewClustersCallbacks
%
% Callbacks for view clusters window
%
% ADR 1998
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

%------------------------------------
% handles global MClust_Clusters MClust_FeatureData MClust_FeaturesToUse MClust_FeatureTimestamps MClust_TTData MClust_TTfn MClust_ChannelValidity
cboHandle = gcbo;
figHandle = ParentFigureHandle(cboHandle);
redrawAxesHandle = findobj(figHandle, 'Tag', 'RedrawAxes');
redrawAxesFlag = get(redrawAxesHandle, 'Value');

%--------------------------------------
% main switch
switch get(cboHandle, 'Tag')
   
case 'ViewClustersWindow'
   RedrawClusterKeys(cboHandle, 0);
   
case {'xdim', 'ydim', 'zdim', 'RedrawAxes'}
   if redrawAxesFlag
      RedrawAxes(figHandle)
   end
   
case 'HideAll'
   global MClust_Hide
   MClust_Hide = ones(size(MClust_Hide));
   hideObjects = findobj(figHandle, 'Style', 'checkbox', 'Tag', 'HideCluster');
   set(hideObjects, 'Value', 1);
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end
   
case 'ShowAll'
   global MClust_Hide
   MClust_Hide = zeros(size(MClust_Hide));
   hideObjects = findobj(figHandle, 'Style', 'checkbox', 'Tag', 'HideCluster');
   set(hideObjects, 'Value', 0);
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end
      
case {'Rotate'}
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'VCDrawingAxisWindow');  % figure to draw in
   if isempty(drawingFigHandle)
      RedrawAxes(figHandle)
   else
      figure(drawingFigHandle);
   end
   set(gca, 'CameraViewAngleMode', 'manual');
   [az, el] = view;
   % ncst added 16 may 02
   if az > 700
       az = 0;
   end
   while az<720 & get(cboHandle, 'Value') == 1
      figure(drawingFigHandle);
      az = az + 5;
      view(az, el);
      drawnow
      pause(0.2)
   end
   
case 'AxLimDlg'
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'VCDrawingAxisWindow');  % figure to draw in
   if ~isempty(drawingFigHandle)
      figure(drawingFigHandle);
      axlimdlg;
   end
   
case {'ViewAllDimensions'}
   global MClust_FeatureData MClust_FeatureNames
   nD = length(MClust_FeatureNames);
   VADHandle = figure('NumberTitle', 'off', 'Name', 'View all dimensions');        
   for iD = 1:nD
      for jD = (iD+1):nD   
         if get(cboHandle, 'Value')
            plot(MClust_FeatureData(:,iD), MClust_FeatureData(:,jD), '.');
            xlabel(MClust_FeatureNames{iD});
            ylabel(MClust_FeatureNames{jD});
            drawnow
            pause(1);
         end
      end   end   set(cboHandle, 'Value', 0);   close(VADHandle)
case 'CheckClusters'
    global MClust_TTData MClust_Clusters MClust_FeatureData MClust_TTfn
	global MClust_xlbls
	global MClust_ylbls
    [curdn,curfn] = fileparts(MClust_TTfn);
    save_jpegs = 0;
    for iClust = length(MClust_Clusters):-1:1     
        [clustTT, was_scaled] = ExtractCluster(MClust_TTData, FindInCluster(MClust_Clusters{iClust}, MClust_FeatureData,'xlbls',MClust_xlbls,'ylbls',MClust_ylbls));
        if was_scaled
            title_string = [ 'Only ' num2str(size(clustTT,1)) ' of ' num2str(was_scaled) ' spikes shown.'];
        else
            title_string = [];
        end
        if ~isempty(data(clustTT))
            CheckCluster([curfn, '--Cluster', num2str(iClust)], clustTT, MClust_FeatureTimestamps(1), MClust_FeatureTimestamps(end), save_jpegs, title_string);
        else
            msgbox(['Cluster ' num2str(iClust) ' is empty']);
        end
    end
    
case 'EvalOverlap'
   global MClust_Clusters MClust_FeatureData
   [nS, nD] = size(MClust_FeatureData);
   nClust = length(MClust_Clusters);
   nToDo = nClust * (nClust-1)/2;
   iDone = 0;
   overlap = zeros(nClust);
   
   % ncst added 16 may 02
   if nClust == 1
        errordlg('Only one cluster exists.', 'MClust error', 'modal');
       return
   end
   
   for iC = 1:nClust
      iSpikes = zeros(nS, 1);
      fI = FindInCluster(MClust_Clusters{iC}, MClust_FeatureData);
      iSpikes(fI) = 1;
      for jC = (iC+1):nClust
         iDone = iDone +1;
         DisplayProgress(iDone, nToDo, 'Title', 'Evaluating overlap');
         jSpikes = zeros(nS, 1);
         fJ = FindInCluster(MClust_Clusters{jC}, MClust_FeatureData);
         jSpikes(fJ) = 1;
         overlap(iC,jC) = sum(iSpikes & jSpikes);
         overlap(jC,iC) = overlap(iC,jC);
      end
   end
   overlap = [(0:nClust)', [1:nClust; overlap]]
   msgbox(num2str(overlap), 'Overlap');
   
   
case 'UpdateClusters'
   ClearClusterKeys(figHandle);
   RedrawClusterKeys(figHandle);
   
% CLUSTER KEYS

case 'ScrollClusters'
   global MClust_Clusters
   for iC = 0:length(MClust_Clusters)
      clusterKeys = findobj(figHandle, 'UserData', iC);
      for iK = 1:length(clusterKeys)
         delete(clusterKeys(iK))
      end
   end
   startCluster = floor(-get(cboHandle, 'Value'));
   endCluster = floor(min(startCluster + 15, length(MClust_Clusters)));
   for iC = startCluster:endCluster
      CreateClusterKeys(figHandle, iC, 0.4, 0.9 - 0.05 * (iC - startCluster), 'ViewClustersCallbacks', ...
               'Average waveform', 'Hist ISI', 'Autocorrelation', 'Spike width', 'Peak:Valley Ratio', 'Check cluster', 'Show info');

   end

case 'ChooseColor'
   global MClust_Colors    
   iClust = get(cboHandle, 'UserData')+1;
   MClust_Colors(iClust,:) = uisetcolor(MClust_Colors(iClust,:), 'Set Cluster Color');
   set(cboHandle, 'BackgroundColor', MClust_Colors(iClust,:));
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end
   
case 'HideCluster'
   global MClust_Hide
   iClust = get(cboHandle, 'UserData');
   MClust_Hide(iClust + 1) = get(cboHandle, 'Value');
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end
   
case 'UnaccountedForOnly'
   global MClust_UnaccountedForOnly
   MClust_UnaccountedForOnly = get(cboHandle, 'Value');
   if redrawAxesFlag
      RedrawAxes(figHandle);
   end   
   
% FUNCTIONS
case 'ClusterFunctions'
   cboString = get(cboHandle, 'String');
   cboValue = get(cboHandle, 'Value');
   
   switch cboString{cboValue}      
      
   case 'Check cluster'
      global MClust_TTData MClust_Clusters MClust_FeatureData MClust_TTfn
	  global MClust_ChannelValidity MClust_TTdn MClust_TTfn
      iClust = get(cboHandle, 'UserData');
	      
	  [f MClust_Clusters{iClust}] = FindInCluster(MClust_Clusters{iClust}, MClust_FeatureData);
	  [L_Extra,L_Ratio,IsolationDist,Dists] = ClusterSeparation(f,[MClust_TTdn filesep MClust_TTfn],...
		  MClust_ChannelValidity,iClust);
      % modified ncst 23 May 02
      %         if length(f) > 150000
      %             ButtonName=questdlg([ 'There are ' num2str(length(f)) ' points in this cluster. MClust may crash. Are you sure you want to check clusters?'], ...
      %                 'MClust', 'Yes','No','No');
      %             if strcmpi(ButtonName,'No')
      %                 run_checkclust = 0;
      %             end
      %         else
      run_checkclust = 1;
	  
      if length(f) == 0
          run_checkclust = 0;
          msgbox('No points in cluster.')
      end
      
      if run_checkclust
          save_jpegs = 0; 
          if iClust == 0
              clustTT = MClust_TTData;
          else
              [clustTT, was_scaled] = ExtractCluster(MClust_TTData, f);
          end
          [curdn,curfn] = fileparts(MClust_TTfn);
          if was_scaled
              title_string = [ 'Only ' num2str(length(Range(clustTT,'ts'))) ' of ' num2str(was_scaled) ' spikes shown.'];
          else
              title_string = [];
          end
          ClustInd = repmat(0,size(MClust_FeatureTimestamps));
		  ClustInd(f) = 1;
		  CheckCluster([curfn, '--Cluster', num2str(iClust)], clustTT, MClust_FeatureTimestamps(1), MClust_FeatureTimestamps(end), save_jpegs,...
			  title_string, was_scaled,'L_Extra',L_Extra,'L_Ratio',L_Ratio,'IsolationDist',IsolationDist,...
			  'Dists',Dists,'ClustInd',ClustInd);
		end
  case 'Show info'
      global MClust_Clusters
      iClust = get(cboHandle, 'UserData');
      msgbox(GetInfo(MClust_Clusters{iClust}), ['Cluster ', num2str(iClust)]);    
      
   otherwise
      warndlg({'View Clusters is still under construction.',cboString{cboValue}, 'Function not yet implemented.'});
   
   end
   set(cboHandle, 'Value', 1);
      
% EXIT
case {'Exit'}
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'VCDrawingAxisWindow');  % figure to draw in
   if ~isempty(drawingFigHandle)
      close(drawingFigHandle)
   end
   close(figHandle);

otherwise
   warndlg({'View Clusters is still under construction.',get(cboHandle, 'Tag'), 'Feature not yet implemented.'});
   
end % switch

%----------------------------------------
% SUBFUNCTION

%------------
% Redraw Axes
function RedrawAxes(figHandle)

% globals
global MClust_Clusters MClust_Colors MClust_FeatureData MClust_Hide MClust_UnaccountedForOnly
global MClust_CurrentFeatures MClust_FDfn MClust_FeatureTimestamps
global MClust_xlbls
global MClust_ylbls
global MClust_zlbls

% get keys
xHandle = findobj(figHandle, 'Tag', 'xdim');
xDim = get(xHandle, 'Value');
xLabels = get(xHandle, 'String');
MClust_xlbls = xLabels;
xFeatureName = xLabels(xDim);
yHandle = findobj(figHandle, 'Tag', 'ydim');
yDim = get(yHandle, 'Value');
yLabels = get(yHandle, 'String');
MClust_ylbls = yLabels;
yFeatureName = yLabels(yDim);
zHandle = findobj(figHandle, 'Tag', 'zdim');
zDim = get(zHandle, 'Value');
zLabels = get(zHandle, 'String');
MClust_zlbls = zLabels;
zFeatureName = zLabels(zDim);

setptr(gcf, 'watch');
if ~strcmp(MClust_ylbls(yDim), MClust_CurrentFeatures(2))
   if strcmpi(MClust_ylbls{yDim}(1:4), 'time')
       MClust_FeatureData(:,2) = MClust_FeatureTimestamps;
       MClust_CurrentFeatures(2) = MClust_ylbls(yDim);
   else
       [fpath fname fext] = fileparts(MClust_FDfn);
       FeatureToGet = MClust_ylbls{yDim};
       FindColon = find(FeatureToGet == ':');
       temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
       FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
       MClust_FeatureData(:,2) = temp.FeatureData(:,FeatureIndex);
       MClust_CurrentFeatures(2) = temp.FeatureNames(FeatureIndex); 
   end;
end;
if ~strcmp(MClust_xlbls(xDim), MClust_CurrentFeatures(1))
   if strcmpi(MClust_xlbls{xDim}(1:4), 'time')
       MClust_FeatureData(:,1) = MClust_FeatureTimestamps;
       MClust_CurrentFeatures(1) = MClust_xlbls(xDim);
   else
       [fpath fname fext] = fileparts(MClust_FDfn);
       FeatureToGet = MClust_xlbls{xDim};
       FindColon = find(FeatureToGet == ':');
       temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
       FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
       MClust_FeatureData(:,1) = temp.FeatureData(:,FeatureIndex);
       MClust_CurrentFeatures(1) = temp.FeatureNames(FeatureIndex); 
   end;
end;
if ~strcmp(MClust_zlbls(zDim), MClust_CurrentFeatures(3))
   if strcmpi(MClust_zlbls{zDim}(1:4), 'time')
       MClust_FeatureData(:,3) = MClust_FeatureTimestamps;
       MClust_CurrentFeatures(3) = MClust_zlbls(zDim);
   else
       [fpath fname fext] = fileparts(MClust_FDfn);
       FeatureToGet = MClust_zlbls{zDim};
       FindColon = find(FeatureToGet == ':');
       temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
       FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
       MClust_FeatureData(:,3) = temp.FeatureData(:,FeatureIndex);
       MClust_CurrentFeatures(3) = temp.FeatureNames(FeatureIndex); 
   end;
end;
setptr(gcf, 'arrow');

% find drawing figure
drawingFigHandle = findobj('Type', 'figure', 'Tag', 'VCDrawingAxisWindow');  % figure to draw in

if isempty(drawingFigHandle)
   % create new drawing figure
   drawingFigHandle = figure('Name', 'Clusters: 3d plot',...
   'NumberTitle', 'off', ...
   'Tag', 'VCDrawingAxisWindow');
   view(3); [az,el] = view;
else
   % figure already exists -- select it
   figure(drawingFigHandle);
   [az,el] = view;
end

clf;
hold on;
nClust = length(MClust_Clusters);

for iC = 0:nClust  
   HideClusterHandle = findobj(figHandle, 'Tag', 'HideCluster', 'UserData', iC);
   if ~MClust_Hide(iC+1)
      if iC == 0
         if MClust_UnaccountedForOnly
            clusterIndex = ProcessClusters(MClust_FeatureData, MClust_Clusters);
            f = find(clusterIndex == 0);
            h = plot3(MClust_FeatureData(f,1), MClust_FeatureData(f,2), MClust_FeatureData(f,3), '.');
         else
            h = plot3(MClust_FeatureData(:,1), MClust_FeatureData(:,2), MClust_FeatureData(:,3), '.');
         end
      else         
         [f, MCC] = FindInCluster(MClust_Clusters{iC}, MClust_FeatureData);
         if isempty(f) & ~isempty(HideClusterHandle)
            set(HideClusterHandle, 'Enable', 'off');
         else 
            set(HideClusterHandle, 'Enable', 'on');
         end
         h = plot3(MClust_FeatureData(f,1), MClust_FeatureData(f,2), MClust_FeatureData(f,3), '.');
      end
      set(h, 'Color', MClust_Colors(iC+1,:));
      set(h, 'MarkerSize', 1);

   end
end
set(gca, 'XLim', [min(MClust_FeatureData(:,1)) max(MClust_FeatureData(:, 1))]);
set(gca, 'YLim', [min(MClust_FeatureData(:,2)) max(MClust_FeatureData(:, 2))]);
set(gca, 'ZLim', [min(MClust_FeatureData(:,3)) max(MClust_FeatureData(:, 3))]);
xlabel(xFeatureName);
ylabel(yFeatureName);
zlabel(zFeatureName);
view(az,el);
rotate3d on;

%=========================
function ClearClusterKeys(figHandle)
global MClust_Clusters
for iC = 0:100
   clusterKeys = findobj(figHandle, 'UserData', iC);
   for iK = 1:length(clusterKeys)
      delete(clusterKeys(iK))
   end
end

function RedrawClusterKeys(figHandle, startCluster)
global MClust_Clusters
if nargin == 1
  sliderHandle = findobj(figHandle, 'Tag', 'ScrollClusters');
  startCluster = floor(-get(sliderHandle, 'Value'));
end
endCluster = floor(min(startCluster + 15, length(MClust_Clusters)));
for iC = startCluster:endCluster
   CreateClusterKeys(figHandle, iC, 0.4, 0.9 - 0.05 * (iC - startCluster), 'ViewClustersCallbacks', ...
     'Check cluster', 'Show info');end