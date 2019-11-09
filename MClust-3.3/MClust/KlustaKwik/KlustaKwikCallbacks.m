function KlustaKwikCallbacks(varargin)

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

% handles 
global MClust_Clusters MClust_FeatureData MClust_FeaturesToUse MClust_FeatureTimestamps
global MClust_TTData MClust_TTfn MClust_ChannelValidity

global KKClust


global MClust_KKDecisionWindow_Pos
global MClust_KK2D_Pos 
global MClust_KK3D_Pos
global MClust_KKContour_Pos

GChandle = findobj('Tag', 'KKDecisionWindow');
if ~isempty(GChandle)
    MClust_KKDecisionWindow_Pos = get(GChandle,'Position');
end

GChandle = findobj('Tag', 'KK2D');
if ~isempty(GChandle)
    MClust_KK2D_Pos = get(GChandle,'Position');
end

GChandle = findobj('Tag', 'KK3D');
if ~isempty(GChandle)
    MClust_KK3D_Pos = get(GChandle,'Position');
end

GChandle = findobj('Tag', 'KKContour');
if ~isempty(GChandle)
    MClust_KKContour_Pos = get(GChandle,'Position');
end


if ~isempty(varargin)
  figHandle = findobj('Tag', 'KKDecisionWindow');
  callbackTag = varargin{1};
  if length(varargin) > 1
      cboHandle = varargin{2};
  else
      cboHandle = [];
  end
else  
  cboHandle = gcbo;
  figHandle = gcf;
  callbackTag = get(cboHandle, 'Tag');
end

%--------------------------------------
% main switch
switch callbackTag
    
case 'ExportClustersSeparate'
    global MClust_Colors  MClust_FeatureData MClust_Clusters MClust_FeatureNames
    global KlustaKwik_Clusters
      
    MClust_Clusters = {};
    for iC = 1:length(KlustaKwik_Clusters)
        iC0 = length(MClust_Clusters);
        KeepYN = get(findobj(figHandle, 'Tag', 'KeepCluster', 'UserData', iC), 'Value');
        Color = get(findobj(figHandle, 'Tag', 'ChooseColor', 'UserData', iC), 'BackgroundColor');
        if KeepYN
            MClust_Colors(iC0+2,:) = Color;
            MClust_Clusters(end+1) = KlustaKwik_Clusters(iC);
        end%if   
    end%for
    
    
   
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KK2D'); 
   if ~isempty(drawingFigHandle)
       close(drawingFigHandle);
   end    
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KK3D');  
   if ~isempty(drawingFigHandle)
       close(drawingFigHandle);
   end    
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KKContour');  
   if ~isempty(drawingFigHandle)
       close(drawingFigHandle);
   end
    
   if isempty(MClust_FeatureData)
      errordlg('No features calculated.', 'MClust error', 'modal');
   else
      GeneralizedCutter(MClust_Clusters, MClust_FeatureData, MClust_FeatureNames, 'mcconvexhull');
   end

case 'ExportClustersMerge'
    global MClust_Colors  MClust_FeatureData MClust_Clusters MClust_FeatureNames
    global KlustaKwik_Clusters
    
    nC = length(KlustaKwik_Clusters);
    MClust_Clusters = {};
    for iC = 1:nC;
        KeepYN(iC) = get(findobj(figHandle, 'Tag', 'KeepCluster', 'UserData', iC), 'Value');
        Color(iC,:) = get(findobj(figHandle, 'Tag', 'ChooseColor', 'UserData', iC), 'BackgroundColor');
    end
    
    for iC = 1:nC
        pointsInCluster = []; 
        iC0 = length(MClust_Clusters);
        if KeepYN(iC)
            for jC = iC:nC
                if KeepYN(jC) & all(Color(jC,:) == Color(iC,:))
                    pointsInCluster = cat(1, pointsInCluster, FindInCluster(KlustaKwik_Clusters{jC},MClust_FeatureData));
                    KeepYN(jC) = 0;
                end                
            end
            MClust_Colors(iC0+2,:) = Color(iC,:);
            pointsInCluster = sort(pointsInCluster);
            MClust_Clusters{end+1} = precut(pointsInCluster, 'indices');            
            end%if   
    end%for
    
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KK2D'); 
   if ~isempty(drawingFigHandle)
       close(drawingFigHandle);
   end    
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KK3D');  
   if ~isempty(drawingFigHandle)
       close(drawingFigHandle);
   end    
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KKContour');  
   if ~isempty(drawingFigHandle)
       close(drawingFigHandle);
   end
    
   if isempty(MClust_FeatureData)
      errordlg('No features calculated.', 'MClust error', 'modal');
   else
      GeneralizedCutter(MClust_Clusters, MClust_FeatureData, MClust_FeatureNames, 'mcconvexhull');
   end
   
case 'HoldCluster'
    global KlustaKwik_Clusters
    
    ClusterUserData = get(cboHandle,'UserData');
    newC = ClusterUserData{1};
    KlustaKwik_AllHold = ClusterUserData{2};
    
    % Check for holds before updating
    
    HoldNum = [];
    
    for iClust = 1:length(KlustaKwik_Clusters)
        HoldYN = get(findobj(figHandle, 'Tag', 'HoldCluster', 'UserData', {iClust, KlustaKwik_AllHold}), 'Value');
        if HoldYN % if we find a hold
            HoldNum = [HoldNum iClust];
        end
    end
    
	for iC = 1:length(KlustaKwik_Clusters)
        set(findobj(figHandle, 'Tag', 'HoldCluster', 'UserData', {iC, KlustaKwik_AllHold}), 'Value', 0);
	end
     if ~isempty(HoldNum) % if HoldNum is empty, either no button is selected, or we have turned off the one we were holding
        set(findobj(figHandle, 'Tag', 'HoldCluster', 'UserData', {newC KlustaKwik_AllHold}), 'Value',1);
    end
    KlustaKwikCallbacks('SelectCluster',cboHandle)
	CheckRedraw('Selection', figHandle);
    
case 'ChooseColor'
    col = get(cboHandle,'BackgroundColor');  % find the current color
    set(cboHandle,'backgroundcolor',get(0,'defaultuicontrolbackgroundcolor'))
    col = uisetcolor(col, 'Select a color'); % pass in the current color, if the user cancels, will not change color
    set(cboHandle, 'BackgroundColor', col);
	CheckRedraw('Selection', figHandle);

case 'SelectCluster'
    global KKClust KlustaKwik_AllHold
    
    % get ID
    iC = get(cboHandle, 'UserData');
    
    if ~isa(iC,'cell') % if the user data is a cell, this function has been called by HoldCluster
        set(cboHandle,'backgroundcolor',get(0,'defaultuicontrolbackgroundcolor'))
        selectedHandle = findobj(figHandle,'Tag','SelectCluster','BackgroundColor','c');
        if ~isempty(selectedHandle)
            set(selectedHandle,'backgroundcolor',get(0,'defaultuicontrolbackgroundcolor'))
        end
        set(cboHandle,'BackgroundColor','c')
    end
    
    CheckRedraw('Selection', figHandle);

    % Check for holds before updating window
    
    SelectedCluster = get(findobj(figHandle,'Tag','SelectCluster','BackgroundColor','c'),'UserData');
    
    HeldCluster = findobj(figHandle, 'Tag', 'HoldCluster', 'Value', 1);
    if isempty(HeldCluster)
        HoldNum = 0;
    else
        HoldNum = get(HeldCluster, 'UserData');
        HoldNum = HoldNum{1};
    end
       
    % change stats text
    objHandle = findobj(figHandle, 'Tag', 'StatisticsText');
    set(objHandle, 'String', KKClust.Stats{SelectedCluster});
    
    % plot average waveform
    AverageWaveformAxisHandle = findobj(figHandle, 'Tag', 'AverageWaveformAxis');
    axes(AverageWaveformAxisHandle); cla;
    
    if HoldNum
        mANDerr = KKClust.WaveForms{HoldNum};
        wfm = mANDerr{1};
        wferr = mANDerr{2};

		nWVSamples = size(wfm,2);
		
        for it = 1:4
            xrange = ((nWVSamples + 2) * (it-1)) + (1:nWVSamples); 
            hold on;
            plot(xrange, wfm(it,:));
            errorbar(xrange,wfm(it,:),wferr(it,:),'r'); 
        end
        hold on
    end
    
    mANDerr = KKClust.WaveForms{SelectedCluster};
    wfm = mANDerr{1};
    wferr = mANDerr{2};

	nWVSamples = size(wfm,2);
	
    for it = 1:4
        xrange = ((nWVSamples + 2) * (it-1)) + (1:nWVSamples); 
        hold on;
        plot(xrange, wfm(it,:));
        if MClust_ChannelValidity(it)
            errorbar(xrange,wfm(it,:),wferr(it,:)); 
        else
            errorbar(xrange,wfm(it,:),wferr(it,:),'k'); 
        end
    end

	set(gca,'Xlim',[0 4*(nWVSamples + 2)])
    title('Average Waveform');
    hold off
    set(gca, 'Tag', 'AverageWaveformAxis');
   
    % ISI histograms
    HistISIHandle = findobj(figHandle, 'Tag', 'ISIHistAxis');
    axes(HistISIHandle); cla;
    
    if HoldNum
        hist = KKClust.ISI{HoldNum};
        H = hist{1};
        binsUsed = hist{2};
        plot(binsUsed, H, 'r'); 
        hold on
    end
    
    hist = KKClust.ISI{SelectedCluster};
    H = hist{1};
    binsUsed = hist{2};
    plot(binsUsed, H); 
    xlabel('ISI, ms');
    set(gca, 'XScale', 'log');
    set(gca, 'YTick', max(H));
    set(gca, 'Tag', 'ISIHistAxis');
    hold off;   
    
    % If the correlation checkbox is checked, update correlations    
    DoCorrYN = get(findobj(figHandle,'Tag','CorrelationCheckBox'),'Value');
    if DoCorrYN
        KlustaKwikCallbacks('ShowCorrelation');
    end

case 'ShowCorrelation'
    global KlustaKwik_Clusters KKClust
    
    % get ID
    CurrentCluster = get(findobj(figHandle,'Tag','SelectCluster','Backgroundcolor',[0 1 1]),'UserData');
        
    mANDerr = KKClust.WaveForms{CurrentCluster};
    wfm = mANDerr{1};
    
    if CurrentCluster ~= 0
        ClusterCorr = KKClust.WaveFormCorr(CurrentCluster,:);
        for iC = 1:length(KlustaKwik_Clusters)
            if iC ~= CurrentCluster
                set(findobj(figHandle, 'Tag', 'Correlation', 'UserData', iC), 'String',num2str(ClusterCorr(iC),'%.2f'));
            else
                set(findobj(figHandle, 'Tag', 'Correlation', 'UserData', iC), 'String','----');
            end
        end
    end
    
case 'KeepCluster'
	CheckRedraw('Keep', figHandle);
	
% WINDOW PLOTTING FUNCTIONS
case {'xdim', 'ydim', 'Show0', 'ShowKeeps', 'CheckRedraw'}
	view2D = findobj(figHandle, 'Tag', 'View2D');
	if get(view2D, 'Value')
		Redraw2D(figHandle);
	end
	
	view3D = findobj(figHandle, 'Tag', 'View3D');
	if get(view3D, 'Value')
		Redraw3D(figHandle);
	end
	
	viewContour = findobj(figHandle, 'Tag', 'ViewContour');
	if get(viewContour, 'Value')
		RedrawContour(figHandle);
	end
	
case 'zdim'
	view3D = findobj(figHandle, 'Tag', 'View3D');
	if get(view3D, 'Value')
		Redraw3D(figHandle);
	end

case 'View2D'
	if get(cboHandle, 'Value')
		Redraw2D(figHandle);
	end
	
case 'View3D'
	RotateButton = findobj(figHandle, 'Tag', 'Rotate3D');
	if get(cboHandle, 'Value')
		set(RotateButton, 'Enable', 'on');
		Redraw3D(figHandle);
	else
		set(RotateButton, 'Enable', 'off');
	end		
	
case 'ViewContour'
	if get(cboHandle, 'Value')
		RedrawContour(figHandle);
	end
	
case 'Rotate3D'
    drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KK3D');  % figure to draw in
    if ~isempty(drawingFigHandle)
        figure(drawingFigHandle);
        [az,el] = view;
        for iZ = 1:10:360
            figure(drawingFigHandle)
            view(az+iZ,el);
            drawnow;
        end
        set(cboHandle, 'value', 0);
    end
	
case 'Exit'
   close(figHandle);  
   
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KK2D'); 
   if ~isempty(drawingFigHandle)
       close(drawingFigHandle);
   end    
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KK3D');  
   if ~isempty(drawingFigHandle)
       close(drawingFigHandle);
   end    
   drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KKContour');  
   if ~isempty(drawingFigHandle)
       close(drawingFigHandle);
   end

end


%------------------------------------
function CheckRedraw(key, figHandle)

view2D = get(findobj(figHandle, 'Tag', 'View2D'), 'Value');
view3D = get(findobj(figHandle, 'Tag', 'View3D'), 'Value');
viewContour = get(findobj(figHandle, 'Tag', 'ViewContour'), 'Value');
show0 = get(findobj(figHandle, 'Tag', 'Show0'), 'Value');
showKeeps = get(findobj(figHandle, 'Tag', 'ShowKeeps'), 'Value');
switch key
case 'Keep' % changed a keep
	if showKeeps & view2D; Redraw2D(figHandle); end
	if showKeeps & view3D; Redraw3D(figHandle); end
	if showKeeps & viewContour & ~show0; RedrawContour(figHandle); end	
case 'Selection' % only change selection
	if view2D; Redraw2D(figHandle); end
	if view3D; Redraw3D(figHandle); end
    if viewContour & ~show0; RedrawContour(figHandle); end
otherwise
    error('Reached otherwise in KlustaKwikCallbacks::CheckRedraw.');
end
	
%------------------------------------
function Redraw2D(figHandle)

% -- get variables
global KlustaKwik_Clusters MClust_FeatureData MClust_FDfn MClust_CurrentFeatures
global MClust_FeatureTimestamps MClust_FDdn
nClust = length(KlustaKwik_Clusters);

DirChange = 0;
if ~strcmp(pwd,MClust_FDdn)
	pushdir(MClust_FDdn);
	DirChange = 1;
end

drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KK2D');  % figure to draw in

global MClust_KK2D_Pos 

if isempty(drawingFigHandle)
	drawingFigHandle = figure('Name', '2D KlustaKwik viewer',...
        'NumberTitle', 'off', 'Tag', 'KK2D','Position', MClust_KK2D_Pos);
end

xdimHandle = findobj(figHandle, 'Tag', 'xdim'); xdim = get(xdimHandle, 'Value');           % x dimemsion to plot
ydimHandle = findobj(figHandle, 'Tag', 'ydim'); ydim = get(ydimHandle, 'Value');           % y dimension to plot
xlbls = get(xdimHandle, 'String');         % x labels
ylbls = get(ydimHandle, 'String');         % y lables

if ~strcmp(ylbls(ydim), MClust_CurrentFeatures(2))
   if strcmpi(ylbls{ydim}(1:4), 'time')
       MClust_FeatureData(:,2) = MClust_FeatureTimestamps;
       MClust_CurrentFeatures(2) = ylbls(ydim);
   else
       [fpath fname fext] = fileparts(MClust_FDfn);
       FeatureToGet = ylbls{ydim};
       FindColon = find(FeatureToGet == ':');
       temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
       FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
       MClust_FeatureData(:,2) = temp.FeatureData(:,FeatureIndex);
       MClust_CurrentFeatures(2) = temp.FeatureNames(FeatureIndex); %MClust_ylbls(ydim);
   end;
end;
if ~strcmp(xlbls(xdim), MClust_CurrentFeatures(1))
   if strcmpi(xlbls{xdim}(1:4), 'time')
       MClust_FeatureData(:,1) = MClust_FeatureTimestamps;
       MClust_CurrentFeatures(1) = xlbls(xdim);
   else
       [fpath fname fext] = fileparts(MClust_FDfn);
       FeatureToGet = xlbls{xdim};
       FindColon = find(FeatureToGet == ':');
       temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
       FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
       MClust_FeatureData(:,1) = temp.FeatureData(:,FeatureIndex);
       MClust_CurrentFeatures(1) = temp.FeatureNames(FeatureIndex); %MClust_ylbls(ydim);
   end;
end;

% figure already exists -- select it
figure(drawingFigHandle); cla; hold on;

% plot all points
if get(findobj(figHandle, 'Tag', 'Show0'), 'value')
	h = plot(MClust_FeatureData(:,1), MClust_FeatureData(:,2), '.k','MarkerSize', 1);
end
% plot all keeps
if get(findobj(figHandle, 'Tag', 'ShowKeeps'), 'value')
	for iC = 1:length(KlustaKwik_Clusters)
		KeepYN = get(findobj(figHandle, 'Tag', 'KeepCluster', 'UserData', iC), 'Value');
		if KeepYN
			col = get(findobj(figHandle,'Tag','ChooseColor','UserData',iC),'Backgroundcolor');			
			[f,MCC] = FindInCluster(KlustaKwik_Clusters{iC}, MClust_FeatureData,'xlbls',xlbls,'ylbls',ylbls);
			figure(drawingFigHandle);
			h = plot(MClust_FeatureData(f,1), MClust_FeatureData(f,2), '.', 'MarkerSize',1, 'Color', col);
		end
	end
end
% plot selection
selectedCluster = findobj(figHandle,'Tag','SelectCluster','Backgroundcolor', [0 1 1]);
if ~isempty(selectedCluster)
	iC = get(selectedCluster, 'UserData');
	col = get(findobj(figHandle,'Tag','ChooseColor','UserData',iC),'Backgroundcolor');			
	[f,MCC] = FindInCluster(KlustaKwik_Clusters{iC}, MClust_FeatureData,'xlbls',xlbls,'ylbls',ylbls);
	figure(drawingFigHandle);
	h = plot(MClust_FeatureData(f,1), MClust_FeatureData(f,2), '.', 'MarkerSize',10, 'Color', col);
end
% plot hold
heldCluster = findobj(figHandle,'Tag','HoldCluster','Value',1);
if ~isempty(heldCluster)
	iC = get(heldCluster, 'UserData'); iC = iC{1};
	col = get(findobj(figHandle,'Tag','ChooseColor','UserData',iC),'Backgroundcolor');			
	[f,MCC] = FindInCluster(KlustaKwik_Clusters{iC}, MClust_FeatureData,'xlbls',xlbls,'ylbls',ylbls);
	figure(drawingFigHandle);
	h = plot(MClust_FeatureData(f,1), MClust_FeatureData(f,2), 'x', 'MarkerSize',10, 'Color', col);
end
figure(drawingFigHandle);
set(gca, 'XLim', [min(MClust_FeatureData(:,1)) max(MClust_FeatureData(:, 1))+0.0001]);
set(gca, 'YLim', [min(MClust_FeatureData(:,2)) max(MClust_FeatureData(:, 2))+0.0001]);
xlabel(MClust_CurrentFeatures{1});
ylabel(MClust_CurrentFeatures{2});
zoom on

if DirChange
	popdir;
end

%-------------------------------------------------------
function Redraw3D(figHandle)

% -- get variables
global KlustaKwik_Clusters MClust_FeatureData MClust_FDfn MClust_CurrentFeatures
global MClust_FeatureTimestamps
nClust = length(KlustaKwik_Clusters);

global MClust_KK3D_Pos

drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KK3D');  % figure to draw in
if isempty(drawingFigHandle)
	drawingFigHandle = figure('Name', '3D KlustaKwik viewer',...
        'NumberTitle', 'off', 'Tag', 'KK3D','Position', MClust_KK3D_Pos);
end

xdimHandle = findobj(figHandle, 'Tag', 'xdim'); xdim = get(xdimHandle, 'Value');           % x dimemsion to plot
ydimHandle = findobj(figHandle, 'Tag', 'ydim'); ydim = get(ydimHandle, 'Value');           % y dimension to plot
zdimHandle = findobj(figHandle, 'Tag', 'zdim'); zdim = get(zdimHandle, 'Value');           % y dimension to plot
xlbls = get(xdimHandle, 'String');         % x labels
ylbls = get(ydimHandle, 'String');         % y labels
zlbls = get(zdimHandle, 'String');         % z labels

if ~strcmp(zlbls(zdim), MClust_CurrentFeatures(3))
   if strcmpi(zlbls{zdim}(1:4), 'time')
       MClust_FeatureData(:,3) = MClust_FeatureTimestamps;
       MClust_CurrentFeatures(3) = zlbls(zdim);
   else
       [fpath fname fext] = fileparts(MClust_FDfn);
       FeatureToGet = zlbls{zdim};
       FindColon = find(FeatureToGet == ':');
       temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
       FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
       MClust_FeatureData(:,3) = temp.FeatureData(:,FeatureIndex);
       MClust_CurrentFeatures(3) = temp.FeatureNames(FeatureIndex); %MClust_zlbls(zdim);
   end;
end;
if ~strcmp(ylbls(ydim), MClust_CurrentFeatures(2))
   if strcmpi(ylbls{ydim}(1:4), 'time')
       MClust_FeatureData(:,2) = MClust_FeatureTimestamps;
       MClust_CurrentFeatures(2) = ylbls(ydim);
   else
       [fpath fname fext] = fileparts(MClust_FDfn);
       FeatureToGet = ylbls{ydim};
       FindColon = find(FeatureToGet == ':');
       temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
       FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
       MClust_FeatureData(:,2) = temp.FeatureData(:,FeatureIndex);
       MClust_CurrentFeatures(2) = temp.FeatureNames(FeatureIndex); %MClust_ylbls(ydim);
   end;
end;
if ~strcmp(xlbls(xdim), MClust_CurrentFeatures(1))
   if strcmpi(xlbls{xdim}(1:4), 'time')
       MClust_FeatureData(:,1) = MClust_FeatureTimestamps;
       MClust_CurrentFeatures(1) = xlbls(xdim);
   else
       [fpath fname fext] = fileparts(MClust_FDfn);
       FeatureToGet = xlbls{xdim};
       FindColon = find(FeatureToGet == ':');
       temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
       FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
       MClust_FeatureData(:,1) = temp.FeatureData(:,FeatureIndex);
       MClust_CurrentFeatures(1) = temp.FeatureNames(FeatureIndex); %MClust_ylbls(ydim);
   end;
end;

% figure already exists -- select it
figure(drawingFigHandle); cla; hold on;

% plot all points
if get(findobj(figHandle, 'Tag', 'Show0'), 'value')
	h = plot3(MClust_FeatureData(:,1), MClust_FeatureData(:,2), MClust_FeatureData(:,3), '.k','MarkerSize', 1);
end
% plot all keeps
if get(findobj(figHandle, 'Tag', 'ShowKeeps'), 'value')
	for iC = 1:length(KlustaKwik_Clusters)
		KeepYN = get(findobj(figHandle, 'Tag', 'KeepCluster', 'UserData', iC), 'Value');
		if KeepYN
			col = get(findobj(figHandle,'Tag','ChooseColor','UserData',iC),'Backgroundcolor');			
			[f,MCC] = FindInCluster(KlustaKwik_Clusters{iC}, MClust_FeatureData,'xlbls',xlbls,'ylbls',ylbls);
			figure(drawingFigHandle);
			h = plot3(MClust_FeatureData(f,1), MClust_FeatureData(f,2), MClust_FeatureData(f,3), '.', 'MarkerSize',1, 'Color', col);
		end
	end
end
% plot selection
selectedCluster = findobj(figHandle,'Tag','SelectCluster','Backgroundcolor', [0 1 1]);
if ~isempty(selectedCluster)
	iC = get(selectedCluster, 'UserData');
	col = get(findobj(figHandle,'Tag','ChooseColor','UserData',iC),'Backgroundcolor');			
	[f,MCC] = FindInCluster(KlustaKwik_Clusters{iC}, MClust_FeatureData,'xlbls',xlbls,'ylbls',ylbls);
	figure(drawingFigHandle);
	h = plot3(MClust_FeatureData(f,1), MClust_FeatureData(f,2), MClust_FeatureData(f,3), '.', 'MarkerSize',10, 'Color', col);
end
% plot hold
heldCluster = findobj(figHandle,'Tag','HoldCluster','Value',1);
if ~isempty(heldCluster)
	iC = get(heldCluster, 'UserData'); iC = iC{1};
	col = get(findobj(figHandle,'Tag','ChooseColor','UserData',iC),'Backgroundcolor');			
	[f,MCC] = FindInCluster(KlustaKwik_Clusters{iC}, MClust_FeatureData,'xlbls',xlbls,'ylbls',ylbls);
	figure(drawingFigHandle);
	h = plot3(MClust_FeatureData(f,1), MClust_FeatureData(f,2), MClust_FeatureData(f,3), 'x', 'MarkerSize',10, 'Color', col);
end
figure(drawingFigHandle);
set(gca, 'XLim', [min(MClust_FeatureData(:,1)) max(MClust_FeatureData(:, 1))+0.0001]);
set(gca, 'YLim', [min(MClust_FeatureData(:,2)) max(MClust_FeatureData(:, 2))+0.0001]);
set(gca, 'ZLim', [min(MClust_FeatureData(:,3)) max(MClust_FeatureData(:, 3))+0.0001]);
xlabel(MClust_CurrentFeatures{1});
ylabel(MClust_CurrentFeatures{2});
zlabel(MClust_CurrentFeatures{3});
view(3)
rotate3D on

%--------------------------------------------------
function RedrawContour(figHandle)

% -- get variables
global KlustaKwik_Clusters MClust_FeatureData MClust_FDfn MClust_CurrentFeatures
global MClust_FeatureTimestamps
nClust = length(KlustaKwik_Clusters);

global MClust_KKContour_Pos

drawingFigHandle = findobj('Type', 'figure', 'Tag', 'KKContour');  % figure to draw in
if isempty(drawingFigHandle)
	drawingFigHandle = figure('Name', 'Contour KlustaKwik viewer',...
        'NumberTitle', 'off', 'Tag', 'KKContour','Position', MClust_KKContour_Pos);
end

xdimHandle = findobj(figHandle, 'Tag', 'xdim'); xdim = get(xdimHandle, 'Value');           % x dimemsion to plot
ydimHandle = findobj(figHandle, 'Tag', 'ydim'); ydim = get(ydimHandle, 'Value');           % y dimension to plot
xlbls = get(xdimHandle, 'String');         % x labels
ylbls = get(ydimHandle, 'String');         % y lables

if ~strcmp(ylbls(ydim), MClust_CurrentFeatures(2))
   if strcmpi(ylbls{ydim}(1:4), 'time')
       MClust_FeatureData(:,2) = MClust_FeatureTimestamps;
       MClust_CurrentFeatures(2) = ylbls(ydim);
   else
       [fpath fname fext] = fileparts(MClust_FDfn);
       FeatureToGet = ylbls{ydim};
       FindColon = find(FeatureToGet == ':');
       temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
       FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
       MClust_FeatureData(:,2) = temp.FeatureData(:,FeatureIndex);
       MClust_CurrentFeatures(2) = temp.FeatureNames(FeatureIndex); %MClust_ylbls(ydim);
   end;
end;
if ~strcmp(xlbls(xdim), MClust_CurrentFeatures(1))
   if strcmpi(xlbls{xdim}(1:4), 'time')
       MClust_FeatureData(:,1) = MClust_FeatureTimestamps;
       MClust_CurrentFeatures(1) = xlbls(xdim);
   else
       [fpath fname fext] = fileparts(MClust_FDfn);
       FeatureToGet = xlbls{xdim};
       FindColon = find(FeatureToGet == ':');
       temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
       FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
       MClust_FeatureData(:,1) = temp.FeatureData(:,FeatureIndex);
       MClust_CurrentFeatures(1) = temp.FeatureNames(FeatureIndex); %MClust_ylbls(ydim);
   end;
end;

% figure already exists -- select it
figure(drawingFigHandle); cla;

XData = []; 
YData = [];
% plot all points 
if get(findobj(figHandle, 'Tag', 'Show0'), 'value')
	XData = MClust_FeatureData(:,1)';
	YData = MClust_FeatureData(:,2)';
else
	f = [];
	% for all clusters include y/n
	% keeps
	if get(findobj(figHandle, 'Tag', 'ShowKeeps'), 'value');        
        for iC = 1:nClust
            if get(findobj(figHandle, 'Tag', 'KeepCluster', 'UserData', iC), 'value')
                f = cat(1, f, FindInCluster(KlustaKwik_Clusters{iC}));
            end
        end	
    end
	selectedCluster = findobj(figHandle,'Tag','SelectCluster','Backgroundcolor', [0 1 1]);
	if ~isempty(selectedCluster)
		iC = get(selectedCluster, 'UserData');
		f = cat(1, f, FindInCluster(KlustaKwik_Clusters{iC}));
    end
	heldCluster = findobj(figHandle,'Tag','HoldCluster','Value',1);
	if ~isempty(heldCluster)
		iC = get(heldCluster, 'UserData'); iC = iC{1};
		f = cat(1, f, FindInCluster(KlustaKwik_Clusters{iC}));
	end
    if ~isempty(f)
        XData = MClust_FeatureData(f,1)';
        YData = MClust_FeatureData(f,2)';
    end
end
% make the plot
nX = 100; nY = 100;
H = [];

xmin = min(MClust_FeatureData(:,1))+0.0001; 
xmax = max(MClust_FeatureData(:,1))+0.0001; 
ymin = min(MClust_FeatureData(:,2))+0.0001; 
ymax = max(MClust_FeatureData(:,2))+0.0001; 

if ~isempty(XData)
    H = ndhist([XData; YData], [nX; nY], [xmin; ymin], [xmax; ymax])';
    H0 = Hsmooth(H);
    H0 = fixedLog(H,-1);
    if any(H0(:)>-1)
        H = H0;
    end
    [nX, nY] = size(H);
    X = linspace(xmin, xmax,nX);
    Y = linspace(ymin, ymax,nY);
end

figure(drawingFigHandle);
if isempty(XData) | isempty(H) | all(H(:)==H(1))    
    cla;
    set(gca, 'XTick', [], 'YTick', []);
else
    Cont = contourf(X, Y , H, 15);
    set(gca, 'xlim', [xmin xmax], 'ylim', [ymin ymax], 'XTick', [], 'YTick', []);
end
xlabel(MClust_CurrentFeatures{1});
ylabel(MClust_CurrentFeatures{2});
zoom on;

%==========================================================
function fL = fixedLog(H, infimum)

%  returns the log(H) with H a N-dim array 
%  where the NaNs of log(x<=0) of H are replaced by infimum
%

fL = H;
negs = find(fL <0); 
fL(negs) = 0;
warning off;
fL = log(fL);
warning on;

nans = find(fL <= infimum);
fL(nans) = infimum;

return;


%==========================================
function [S, bb] = Hsmooth(H)
%
%  [S, bb] = Hsmooth(H)
%
% smoothes a 2D histogram H (= 2D array)
% with a 6-th order double low pass firls bb (linear phase least-square FIR filter)
%

% create filter
if exist('firls')
	b = firls(6, [0 .5 .5 1], [1 .5 .5 0]);  
	bb = kron(b',b);    % 2D filter = tensor product of 1D filters
	
	S = filter2(bb,H);  % first pass (introduces a linear phase shift)
	S = filter2(bb',S);  % second pass (compensates phase shift)
else
	S = H;
end