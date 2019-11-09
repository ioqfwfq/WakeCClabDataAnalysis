function varargout = DaGui(varargin)
% DAGUI M-file for DaGui.fig
%      DAGUI, by itself, creates a new DAGUI or raises the existing
%      singleton*.
%
%      H = DAGUI returns the handle to a new DAGUI or the handle to
%      the existing singleton*.
%
%      DAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DAGUI.M with the given input arguments.
%
%      DAGUI('Property','Value',...) creates a new DAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DaGui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DaGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DaGui

% Last Modified by GUIDE v2.5 13-Feb-2016 21:29:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DaGui_OpeningFcn, ...
    'gui_OutputFcn',  @DaGui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DaGui is made visible.
function DaGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DaGui (see VARARGIN)

% Choose default command line output for DaGui
handles.output = hObject;
handles.use_FD = 0;
handles.lastfn =[];
handles.trials = [];

% Update handles structure
guidata(hObject, handles);

set(handles.figure1,'color',[0 .5 .255]);

% UIWAIT makes DaGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% load_listbox('D:\researchdata\Data\LEM\',handles) % add 'elv' on Jan 03 2007
load_listbox('C:\Users\juzhu\Documents\MATLAB\DA\Data\VIK\',handles)

% --- Outputs from this function are returned to the command line.
function varargout = DaGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc %%ISPC True for the PC (Windows) version of MATLAB.
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

%%%%%%%%%%%%refresh directory everytime%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get(handles.figure1,'SelectionType');
dir_struct = dir; % comment out on 2007 Jan 03
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = [sorted_index];
if strcmp(get(handles.figure1,'SelectionType'),'open')
    %     if strcmp(get(handles.figure1,'SelectionType'),'normal')
    index_selected = get(handles.listbox1,'Value');
    file_list = get(handles.listbox1,'String');
    filename = file_list{index_selected};
    if  handles.is_dir(handles.sorted_index(index_selected))
        cd (filename)
        load_listbox(pwd,handles)
    else
        [path,name,ext] = fileparts(filename);
        if strcmpi(ext,'.apm') | strcmpi(ext,'.mat')
            handles.filename = name;
            set(handles.text3,'String',name)
            set(handles.radiobutton1,'Enable','on')
            set(handles.radiobutton2,'Enable','on')
        else
            disp(['File type error, must be with an ext name apm or mat'])
            return
        end
    end
end

guidata(hObject,handles)

function load_listbox(dir_path,handles)
cd (dir_path)
dir_struct = dir;
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = [sorted_index];
guidata(handles.figure1,handles)
set(handles.listbox1,'String',handles.file_names,...
    'Value',1)
set(handles.text1,'String',pwd)

% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


set(hObject,'String',pwd)


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1

set(handles.radiobutton2,'Value',0)
set(handles.edit1,'Enable','off')
set(handles.popupmenu1,'Enable','on')
handles.plotter = 'Clusters';
guidata(hObject,handles)

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2

set(handles.radiobutton1,'Value',0)
set(handles.edit1,'Enable','on')
set(handles.popupmenu1,'Enable','on')
handles.plotter = 'Rasters';
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

val = get(hObject, 'Value');
str = get(hObject, 'String');
handles.channel = str2num(str{val});
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

handles.clusters = ['[',get(hObject,'String'),']',];
guidata(hObject, handles)

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% persistent trials task_ends  spike_ends;

% tempdir = 'C:\datafiles';

%CAT file only availible for Elvis file 90 and others after >114; Benny
if ~isempty(handles.trials) & (strcmpi(handles.lastfn,[handles.filename(1:8) 'CAT.mat']) | strcmpi(handles.lastfn,[handles.filename(1:8) 'T.mat']))
    disp(['using last file: ' handles.lastfn]);
    disp(['channel: ' num2str(handles.channel)]);
else
    %     clear trials task_ends  spike_ends;
    if length(handles.filename) > 10
        try
            disp(['Loading CAT file : ' handles.filename '  Please wait']);
            load(['C:\Users\juzhu\Documents\MATLAB\DA\Data\' handles.filename(1:3)  '\T_FILE\' handles.filename(1:7) '1CAT.mat']);%something wrong here;
            handles.lastfn =  [handles.filename(1:8) 'CAT.mat'];
            handles.trials = trials;
            handles.task_ends = task_ends;
            try
                handles.spike_ends = spike_ends;
            catch
                handles.spike_ends = [];
                disp('no SPIKE_ENDS');
            end
            disp(['channel: ' num2str(handles.channel)]);
        catch
            lasterr
        end
    else
        try
            disp(['Loading T file : ' handles.filename '  Please wait~~']);
            load(['C:\Users\juzhu\Documents\MATLAB\DA\Data\' handles.filename(1:3) '\T_FILE\' handles.filename(1:8) 'T.mat']); %something wrong here;%% T->CAT
            handles.lastfn =  [handles.filename(1:8) 'T.mat'];
            task_ends = length(trials);
            spike_ends= [];
            handles.trials = trials;
            handles.task_ends = task_ends;
            handles.spike_ends = spike_ends;
            disp(['channel: ' num2str(handles.channel)]);
        catch
            disp(['no T file availible for: ' handles.filename]);
            try
                disp(['Loading CAT file : ' handles.filename '  Please wait~~']);
                load(['C:\Users\juzhu\Documents\MATLAB\DA\Data\' handles.filename(1:3)  '\T_FILE\' handles.filename(1:7) '1CAT.mat']);
                handles.lastfn =  [handles.filename(1:7) '1CAT.mat'];
                handles.trials = trials;
                handles.task_ends = task_ends;
                handles.spike_ends = spike_ends;

            catch
                return
            end
            %            trials = APMReadUserData([handles.filename(1:8) '.apm'])
            %             save(['C:\Matlab2006B\work\Data_Analysis\APM_Data\'
        end
    end
end

%  following lines comment out on 2007 Jun 19
% if str2num(handles.filename(4:6)) > 114 | str2num(handles.filename(4:6)) ==90
%     fn_T_mat = ['.\T_FILE\' handles.filename 'CAT.mat'];
%     if (isempty(trials) | ~isequal(handles.lastfn, fn_T_mat))
%         clear trials task_ends;
%         load(fn_T_mat);
%     end
%     lastfn = fn_T_mat;
% else
%     fn_T_mat=['.\T_FILE\' handles.filename 'T.mat'];
%     %revised on 2007 May 03
%     if (isempty(handles.trials) | ~isequal(handles.lastfn, handles.filename))
%         handles.trials = [];
%         load(fn_T_mat);
%         handles.lastfn = handles.filename;
%         handles.trials = trials;
%         clear trials
%     %     try temp=load(['.\T_FILE\' fn_T_mat]);
%     %         disp(['Loading T file : ' fn_T_mat]);
%     %     catch  trials = APMReadUserData([handles.filename '.apm']);
%     %         save(['.\T_FILE\' fn_T_mat], 'trials');
%     %     end
%     %     lastfn=handles.filename;
%     %     trials=temp.trials;
%     % else lastfn
%     % end
%
%     %the following  line edited on 2006 Dec 4 comment out on 2007 May 3
% %     if (isempty(trials) | ~isequal(lastfn, handles.filename))
% %         %      eval(['trials' num2str(handles.filename(8))]);
% %         if eval(['isempty(trials' num2str(handles.filename(8)) ')']) | eval(['~strcmpi(lastfn' handles.filename(8) ', handles.filename)'])
% %             eval(['trials' handles.filename(8) '=' 'load(''' fn_T_mat ''');' ]);
% %             disp(['Loading T file : ' fn_T_mat]);
% %             eval(['lastfn' handles.filename(8) '= handles.filename']);
% %             eval(['trials = trials' handles.filename(8) '.trials;']);
% %         else
% %             eval(['lastfn' handles.filename(8)]);
% %             eval(['trials = trials' handles.filename(8) '.trials;']);
% %         end
% %         lastfn = handles.filename
%     else handles.lastfn
%     end
% end
%
% try task_ends
% catch task_ends = length(handles.trials);
% end


guidata(hObject, handles)

% cwd = pwd;
% cd(tempdir);
% pack
% cd(cwd)

switch handles.plotter
    case 'Clusters'
                if isfield(handles,'use_FD') & handles.use_FD
                    dagui_autocluster(handles.filename,handles.channel,handles.KKmaxmin,handles.fd_selected)
                end

        %         DA_ClusterPlot_1(handles.filename,handles.channel,handles.trials,task_ends) %comment out on 2007 mar 16
        %                 DA_ClusterPlot4(handles.filename,handles.channel,trials,task_ends) % this one slow but save memory
        %         DA_ClusterPlot3(handles.filename,handles.channel,handles.trials,handles.task_ends,handles.spike_ends);
        if length(handles.filename) > 10
            DA_ClusterPlot3_byClusters(handles.filename,handles.channel,handles.trials,handles.task_ends,handles.spike_ends); % out of memory
        else
            DA_ClusterPlot1_byClusters(handles.filename(1:8),handles.channel,handles.trials,handles.task_ends)
        end
        
    case 'Rasters'
        %         DA_RasterPlot(trials,handles.filename,eval(handles.clusters),handles.channel)
%         DA_RasterPlot4_multistimuli(handles.filename,eval(handles.clusters),handles.channel,handles.trials,handles.task_ends,handles.spike_ends)
       
        DA_RasterPlot3_ODR(handles.filename,eval(handles.clusters),handles.channel,handles.trials,handles.task_ends,handles.spike_ends)
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
global fd_selected KKmaxmin
load autoBatch
KKmaxmin.min = fPar{1}.KKwikMinClusters;
KKmaxmin.max = fPar{1}.KKwikMaxClusters;
if get(handles.checkbox3,'Value') == 1
    hwait = fdgui(handles.filename,handles.channel);
    waitfor(hwait)
    handles.fd_selected = fd_selected;
    handles.KKmaxmin = KKmaxmin;
    handles.use_FD = 1;
else
    handles.use_FD = 0;
end

guidata(hObject, handles)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% write_fn(handles.filename,handles.channel,eval(handles.clusters))



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over listbox1.
function listbox1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object deletion, before destroying properties.
function listbox1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function radiobutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
