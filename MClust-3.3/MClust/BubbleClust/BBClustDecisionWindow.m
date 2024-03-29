function fig = BBClustDecisionWindow()

% fig = BBClustDecisionWindow()
%
% setup all gui elements for the BBClust Decision Window
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

% make a 400 x 300 grid (sreen aspect ration 4:3) 
dx = 1/400;
dy= 1/300;
xg = 0:dx:1;
yg = 0:dy:1; 

% set figure dimensions
sc = get(0,'ScreenSize');
width = sc(3);
height = sc(4);
FigPos = [ 0.025*width 0.025*height 0.95*width 0.9*height];

% define some colors
Grey = [0.8 0.8 0.8];
DarkGrey = Grey;
%DarkGrey = [0.752941176470588 0.752941176470588 0.752941176470588];

% main figure
h0 = figure('BackingStore','off', ...
	'Color',Grey, ...
	'CreateFcn','BBClustCallbacks', ...
	'Name','BBClust Decision Window', ...
	'NumberTitle','off', ...
	'Position',FigPos, ...
	'Tag','BBClustDecisionWindow');




% static text
%h1 = uicontrol('Parent',h0, ...
% 'Units','normalized', ...
%	'BackgroundColor',DarkGrey, ...
%	'HorizontalAlignment','left', ...
%	'ListboxTop',0, ...
%	'Position',[xg(6) yg(117) 243/width 66.75/height], ...
%	'String','blablal', ...
%	'Style','text', ...
%	'Tag','StatisticsText');



% Top left buttons

bw = 100*dx;
bh = 10 *dy;
ix = 10;                % ix =[1,400]  (left, right)
iy = 270;              % iy =[1,300]  (bottom, top)

% modified by ncst 20 May 02 to remove some buttons

% h1 = uicontrol('Parent',h0, ...
% 	'Units','normalized', ...
% 	'BackgroundColor',DarkGrey, ...
% 	'Callback','BBClustCallbacks', ...
% 	'ListboxTop',0, ...
% 	'Position',[xg(ix) yg(iy) bw bh], ...
% 	'String','Load Bubble Tree files', ...
% 	'Style','checkbox', ...
% 	'Tag','LoadBBFiles');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-bh bw bh], ...
	'String','Redraw Bubble Tree', ...
	'Tag','RedrawBubbleTree', ...
	'TooltipString','Draw/Redraw Bubble Tree from scratch');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-2*bh bw/2 bh], ...
	'String','Save', ...
	'Tag','Save', ...
	'TooltipString','Save current state of window');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix)+bw/2 yg(iy)-2*bh bw/2 bh],...
	'String','Load', ...
	'Tag','Load', ...
	'TooltipString','Load a saved state of window');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-3*bh bw bh], ...
	'String','Export clusters to MClust', ...
	'Tag','ExportClusters', ...
	'TooltipString','Export clusters to MClust');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-4*bh bw bh], ...
	'String','Exit', ...
	'Tag','Exit', ...
	'TooltipString','Close Window while keeping all data structures still in memory');


% current bubble box
bw = 120*dx;
bh = 8 *dy;
ix = 10;                % ix =[1,400]  (left, right)
iy = 170;              % iy =[1,300]  (bottom, top)

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'ListboxTop',0, ...
	'Position',[xg(ix)-3*dx yg(iy)-4*bh bw+6*dx 9*bh+3*dy], ...
	'Style','frame', ...
	'Tag','Frame1');
global MClust_TTfn

if ~isempty(MClust_TTfn)
    [p n e] = fileparts(MClust_TTfn);
else
    n = [];
end

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'Position',[xg(ix) yg(iy)+4*bh bw bh], ...
	'String',['Tetrode ' n ' : CURRENT BUBBLE'], ...
	'Style','text', ...
	'Tag','Text_CURRENT_BUBBLE');

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'Callback','BBClustCallbacks', ...
	'Position',[xg(ix) yg(iy)+3*bh bw/4 bh], ...
	'String','Keep', ...
	'Style','checkbox', ...
	'Tag','KeepBubble', ...
	'TooltipString','Flag current bubble as a KEEP bubble for later export  to  MClust');

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'HorizontalAlignment','left', ...
	'Position',[xg(ix) yg(iy)-3*bh 3*bw/4 5*bh], ...
	'String',' ', ...
	'Style','text', ...
	'Tag','StatisticsText');


h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'Position',[xg(ix)+10*bw/16 yg(iy)+3*bh bw/8 bh], ...
	'String','ID', ...
	'Style','text', ...
	'Tag','Text_ID');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','BBClustCallbacks', ...
	'Position',[xg(ix)+3*bw/4 yg(iy)+3*bh bw/4 bh], ...
	'Style','edit', ...
	'String', '1', ...       
	'Tag','IDEdit', ...
	'TooltipString','Show or select ID (= place # in x) of current bubble');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'Position',[xg(ix)+10*bw/16 yg(iy)+2*bh bw/8 bh], ...
	'String','Level', ...
	'Style','text', ...
	'Tag','Text_Level');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','BBClustCallbacks', ...
	'Position',[xg(ix)+3*bw/4 yg(iy)+2*bh bw/4 bh], ...
	'Style','edit', ...
	'String', '1', ...
	'Tag','LevelEdit', ...
	'TooltipString','Show or select Level  (= place # in y) of current bubble');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'Callback','BBClustCallbacks', ...
	'Position',[xg(ix)+11*bw/16 yg(iy)+bh bw/16 bh], ...
	'String','', ...
	'Style','checkbox', ...
	'Tag','AutoStatistics', ...
	'TooltipString','Keep Statistics button automatically pressed');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'Position',[xg(ix)+3*bw/4 yg(iy)+bh bw/4 bh], ...
	'String','Statistics', ...
	'Tag','Statistics', ...
	'TooltipString','Show statistics plot for current bubble');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'Position',[xg(ix)+3*bw/4 yg(iy)-bh bw/4 bh], ...
	'String','AutoCorr', ...
	'Tag','AutoCorr', ...
	'TooltipString','Show AutoCorrelation plot for current bubble');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'Position',[xg(ix)+3*bw/4 yg(iy)-2*bh bw/4 bh], ...
	'String','XCorr', ...
	'Tag','XCorr', ...
	'TooltipString','Show CrossCorrelation plot for current bubble with another bubble');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'Position',[xg(ix)+3*bw/4 yg(iy)-3*bh bw/4 bh], ...
	'String','CheckBB', ...
	'Tag','CheckBB', ...
	'TooltipString','Show CheckBubble plot for current bubble');





% Hold checkboxes
bw = 120*dx;
bh = 10 *dy;
ix = 10;                % ix =[1,400]  (left, right)
iy = 128;              % iy =[1,300]  (bottom, top)

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy) bw/4 bh], ...
	'String','Hold 1', ...
	'Style','checkbox', ...
	'Tag','Hold 1', ...
	'TooltipString','Hold statistics plots for current bubble');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix)+bw/4 yg(iy) bw/4 bh], ...
	'String','Hold 2', ...
	'Style','checkbox', ...
	'Tag','Hold 2', ...
	'TooltipString','Hold statisitcs plot of current bubble');





% axes
bw = 120*dx;
bh = 10 *dy;
ix = 10;                % ix =[1,400]  (left, right)
iy = 80;              % iy =[1,300]  (bottom, top)

h1 = axes('Parent',h0, ...
	'Units','normalized', ...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[1 1 1], ...
	'Position',[xg(ix) yg(iy) bw 5*bh], ...
	'Tag','AverageWaveformAxis', ...
	'TickDirMode','manual', ...
	'Visible','off', ...
	'XColor',[0 0 0], ...
	'XLim',[0 140], ...
	'XLimMode','manual', ...
	'YColor',[0 0 0], ...
	'YLim',[-2100 2100], ...
	'YLimMode','manual', ...
	'ZColor',[0 0 0]);

h1 = axes('Parent',h0, ...
	'Units','normalized', ...
	'Box','on', ...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[1 1 1], ...
	'Position',[xg(ix) yg(iy)-7*bh bw 6*bh], ...
	'Tag','ISIHistAxis', ...
	'XColor',[0 0 0], ...
	'XLim',[0.5 1], ...
	'XLimMode','manual', ...
	'XScale','log', ...
	'YColor',[0 0 0], ...
	'YLim',[0.37 0.62], ...
	'YLimMode','manual', ...
	'YTick',38, ...
	'YTickMode','manual', ...
	'ZColor',[0 0 0]);

bw = 200*dx;
bh = 135*dy;
ix = 195;                    % ix =[1,400]  (left, right)
iy = 150;                   % iy =[1,300]  (bottom, top)

h1 = axes('Parent',h0, ...
	'Units','normalized', ...
	'Box','on', ...
	'ButtonDownFcn','BBClustCallbacks', ...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[1 1 1], ...
	'Position',[xg(ix) yg(iy)+10*dx bw bh], ...
	'Tag','DecisionTree', ...
	'XColor',[0 0 0], ...
	'XLim',[-0.02 1.02], ...
	'XLimMode','manual', ...
	'YColor',[0 0 0], ...
	'YLim',[0 22], ...
	'YLimMode','manual', ...
	'ZColor',[0 0 0]);

h1 = axes('Parent',h0, ...
	'Units','normalized', ...
	'Box','on', ...
	'CameraUpVector',[0 1 0], ...
	'CameraUpVectorMode','manual', ...
	'Color',[1 1 1], ...
	'Position',[xg(ix) yg(iy-5)-bh bw bh], ...
	'Tag','BubblePlotAxes', ...
	'XColor',[0 0 0], ...
	'XLimMode','manual', ...
	'YColor',[0 0 0], ...
	'YLimMode','manual', ...
	'ZColor',[0 0 0]);




% colorbuttons
bw = 8*dx;
bh = 8*dy;
ix = 175;                  % ix =[1,400]  (left, right)
iy = 290;                   % iy =[1,300]  (bottom, top)

ddy = 5;
bgcol = {[0 0 1], ...
        [0 1 0], ...
        [1 0 0], ...
        [1 0 1], ...
        [1 0.501960784313725 0], ...
        [0 1 1], ...
        [0.501960784313725 0.501960784313725 0], ...
        [0 0.501960784313725 0], ...
        [0 0.501960784313725 1], ...
        [0.501960784313725 0 1], ...
        [1 0 0.501960784313725], ...
        [1 1 0], ...
        [1 0.501960784313725 0.501960784313725],...
        DarkGrey, ...
        [1 1 1], ...
        [0 0 0] ...
};
    
for ib = 1:16
    hh1(ib) = uicontrol('Parent',h0, ...
        'Units','normalized', ...
        'ButtonDownFcn','BBClustCallbacks', ...
        'Callback','BBClustCallbacks', ...
        'ForegroundColor',[1 1 1], ...
        'ListboxTop',0, ...
        'Position',[xg(ix) yg(iy)-ib*bh bw bh], ...
        'Tag','ColorButton', ...
        'UserData',ib);
    hh2(ib) = uicontrol('Parent',h0, ...
        'Units','normalized', ...
        'BackgroundColor',bgcol{ib}, ...
        'ButtonDownFcn','BBClustCallbacks', ...
        'Callback','BBClustCallbacks', ...
        'ListboxTop',0, ...
        'Position',[xg(ix)-3*bw yg(iy)-ib*bh 3*bw bh], ...
        'Style','frame', ...
        'Tag',['CF' num2str(ib)]);
end

set(hh1(14),'TooltipString','Select a jazzy color ... ');
set(hh2(14),'TooltipString','Select a jazzy color ... ');
set(hh2(14),'Style','Text');
set(hh2(14),'String','Select');

set(hh1(15),'TooltipString','Reset original color of current bubble');
set(hh2(15),'TooltipString','Reset original color of current bubble');
set(hh2(15),'Style','Text');
set(hh2(15),'String','Reset');

set(hh1(16),'TooltipString','Black is NOT a color!!!');
set(hh2(16),'TooltipString','Black is NOT a color!!!');



% bottom right buttons
bw = 4*8*dx;
bh = 8*dy;
ix = 150;                  % ix =[1,400]  (left, right)
iy = 150;                   % iy =[1,300]  (bottom, top)

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy) bw bh], ...
	'String','Zoom ON/OFF', ...
	'Style','checkbox', ...
	'Tag','Zoom', ...
	'TooltipString','Toggle Zoom ON/OFF for all axes');

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'ListboxTop',0, ...
	'Position',[xg(ix-8) yg(iy)-2*bh bw*1.25 bh], ...
	'String','Axes', ...
	'Style','text', ...
	'Tag','Text_Axes');


h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'ListboxTop',0, ...
	'Position',[xg(ix-8) yg(iy)-3*bh bw*0.25 bh], ...
	'String','X', ...
	'Style','text', ...
	'Tag','Text_X');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'BackgroundColor',DarkGrey, ...
	'ListboxTop',0, ...
	'Position',[xg(ix-8) yg(iy)-4*bh bw*0.25 bh], ...
	'String','Y', ...
	'Style','text', ...
	'Tag','Text_Y');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-3*bh bw bh], ...
	'String',' ', ...
	'Style','popupmenu', ...
	'Tag','FeatureX', ...
	'TooltipString','Select a feature for X axis', ...
	'Value',1);
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-4*bh bw bh], ...
	'String',' ', ...
	'Style','popupmenu', ...
	'Tag','FeatureY', ...
	'TooltipString','Select  a feature for Y axis', ...
	'Value',1);
% h1 = uicontrol('Parent',h0, ...
% 	'Units','normalized', ...
% 	'Callback','BBClustCallbacks', ...
% 	'ListboxTop',0, ...
% 	'Position',[xg(ix) yg(iy)-6*bh bw bh], ...
% 	'String','Redraw Axes', ...
% 	'Tag','Redraw Axes', ...
% 	'TooltipString','Redraw axes with currently selected features');



h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-8*bh bw bh], ...
	'String','Add BB', ...
	'Tag','Add BB', ...
	'TooltipString','Add current bubble to plot');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-9*bh bw bh], ...
	'String','Remove BB', ...
	'Tag','Remove BB', ...
	'TooltipString','Remove current bubble from plot''');


h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-11*bh bw bh], ...
	'String','Show KEEPs', ...
	'Tag','Show KEEPs', ...
	'TooltipString','Show all KEEP bubbles in current plot ');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-12*bh bw bh], ...
	'String','Show KEEPs only', ...
	'Tag','Show KEEPs only', ...
	'TooltipString','Show ONLY KEEP bubbles');

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-14*bh bw bh], ...
	'String','Find BB', ...
	'Tag','Find BB', ...
	'TooltipString','Find the BB correspoinding to a point you click on with the crossbar cursor');

% h1 = uicontrol('Parent',h0, ...
% 	'Units','normalized', ...
% 	'Callback','BBClustCallbacks', ...
% 	'ListboxTop',0, ...
% 	'Position',[xg(ix) yg(iy)-16*bh bw bh], ...
% 	'String','View 3D', ...
% 	'Tag','View 3D', ...
% 	'TooltipString','View current plot in 3D');
h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-17*bh bw bh], ...
	'String','ContourPlot', ...
	'Tag','ContourPlot', ...
	'TooltipString','Generate a contour plot from all  bubbles in current plot');

h1 = uicontrol('Parent',h0, ...
	'Units','normalized', ...
	'Callback','BBClustCallbacks', ...
	'ListboxTop',0, ...
	'Position',[xg(ix) yg(iy)-18*bh bw bh], ...
	'String','Clear', ...
	'Tag','Clear', ...
	'TooltipString','Clear all bubbles in current plot');





if nargout > 0, fig = h0; end
