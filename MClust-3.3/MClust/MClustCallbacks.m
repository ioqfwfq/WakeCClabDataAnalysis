function MClustCallbacks(varargin)

% MClustCallbacks
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
% PL 2000
% modified for manual editing of BBClust clusters
%%%%%% ------ modified batta 5/7/01 -----------------------
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.
% M3.01 NCST 19 Jun 2002 fixed .dat file extension assumption
% NCST 11 Oct 02 modified to preserve cluster names and colors after saving
% and reloading

% global variables
global MClust_Directory     % directory where the MClust (BBClust) main function and features reside
global MClust_TTfn         % file name for tt file
global MClust_FDfn         % file name for fd file
global MClust_TTdn         % directory name for tt file
global MClust_FDdn         % directory name for fd file
global MClust_TTData       % data from tt file
global MClust_fn           % file prefix for tetrode and fd
global MClust_FeatureIndex % used to match spikes in split files back to the original file
global MClust_CurrentFeatures % used to keep track of which features are currently in memory
global MClust_FeatureData  % features calculated from tt data
global MClust_FeatureNames % names of features
global MClust_FeaturesToUse % names of features to use (for feature calculation)
global MClust_FeatureTimestamps 
global MClust_ChannelValidity % 4 x 1 array of channel on (1) or off (0) flags
global MClust_Clusters     % cell array of cluster objects 
global MClust_NeuralLoadingFunction

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

% case 'InputType'
%    ChHandle1 = findobj(figHandle, 'Tag', 'TTValidity1');
%    ChHandle2 = findobj(figHandle, 'Tag', 'TTValidity2');
%    ChHandle3 = findobj(figHandle, 'Tag', 'TTValidity3');
%    ChHandle4 = findobj(figHandle, 'Tag', 'TTValidity4');
%    
%    switch get(cboHandle, 'value') 
%    case {1,2} % TT 
%       set(ChHandle1, 'value', 1, 'enable', 'on');
%       set(ChHandle2, 'value', 1, 'enable', 'on');
%       set(ChHandle3, 'value', 1, 'enable', 'on');
%       set(ChHandle4, 'value', 1, 'enable', 'on');
%    case 3 % ST
%       set(ChHandle1, 'value', 1, 'enable', 'on');
%       set(ChHandle2, 'value', 1, 'enable', 'on');
%       set(ChHandle3, 'value', 0, 'enable', 'off');
%       set(ChHandle4, 'value', 0, 'enable', 'off');
%    case 4 % SE
%       set(ChHandle1, 'value', 1, 'enable', 'on');
%       set(ChHandle2, 'value', 0, 'enable', 'off');
%       set(ChHandle3, 'value', 0, 'enable', 'off');
%       set(ChHandle4, 'value', 0, 'enable', 'off');
%  otherwise
%       error('Internal error: Unknown Input type');
%    end
   
%  case 'LoadTTFileButton'
%    InputTypeHandle = findobj(figHandle, 'Tag', 'InputType');
%    InputValue = get(InputTypeHandle, 'value');
%    switch InputValue
%    case 1 % TT sun
%       expExtension = '*.tt';
%    case 4 % SE nt
%       expExtension = 'SE*.dat';
%    case 3 % ST nt
%       expExtension = 'ST*.dat';
%    case 2 % TT nt
%       expExtension = 'TT*.dat';
%    otherwise
%       error('Internal error: Unknown input file type.');
%    end
%    
%    [MClust_TTfn, MClust_TTdn] = uigetfile(expExtension, 'TT file');
%    if isempty(MClust_TTfn)
%        return;   % user hit Cancel button
%    end
%    %%%%%% ------ modified batta 5/7/01 -----------------------
%    BBClustFileDir = MClust_TTdn;
%    [pp,nn,ee] = fileparts(MClust_TTfn);
%    BBClustFilePrefix = nn;
   
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

%    fnTextObj = findobj(figHandle, 'Tag', 'TTFileName');
%    set(fnTextObj, 'String', MClust_TTfn);
%    MClust_TTfn = fullfile(MClust_TTdn, MClust_TTfn);
% 
% %%%%%% ------ modified batta 5/7/01 -----------------------
%    
%    MClustCallbacks('LoadFeaturesButton');
%    BBClustDecisionWindow;
%    RescaleFigure(gcf,[0.05 0.05 0.9 0.9], 1);
%    drawnow;
%    BBClustCallbacks('LoadBBFiles');
%    BBClustCallbacks('RedrawBubbleTree');
%    BBClustCallbacks('Add BB');
   
   
   
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
   

case 'SelectLoadingEngine'
    global MClust_NeuralLoadingFunction

    value = get(cboHandle, 'Value');
    LoadingEngines = get(cboHandle, 'String');
    MClust_NeuralLoadingFunction = LoadingEngines{value};
   
case 'LoadFeaturesButton'
   % load Feature Data Files (*.fd)  
%%%%%% ------ modified batta 5/7/01 -----------------------
%%%%%% ------ modified ncst 15 May 02 -----------------------

MClust_TText = '.dat';
MClust_FDext = '.fd';

set(findobj(figHandle, 'Tag', 'LoadFeaturesButton'), 'Value', 0);

%%%%%  Set up all file and directory names
if isempty(MClust_FDfn)
    % modified ncst 19 Jun 02
    [fn, dn] = uigetfile('*.fd;*T*.dat;*.ntt;*.nse;*.nst;*.tt', ['Select the .dat or a .fd from the desired tetrode',... 
            ' (only files *.fd or spike data files)']);
    if ~isempty(dn)
        dn = dn(1:end-1);  % remove filesep
    end
    if fn == 0    % User hit cancel
        return
    end
    [p n e] = fileparts(fn);
    
    % if it is an FD file, may have an "_feature" in name
	% modified by ADR on request from SCOWEN
    if strcmp(e,'fd')
        UndScore = findstr(n,'_');
        if ~isempty(UndScore)
            if length(UndScore) == 1
                n = n(1:UndScore -1);
            end
        end
    end
    
    % check the file extension
    if ~strcmp(e,MClust_TText) & ~strcmp(e,MClust_FDext)  % if the extension doesn't match either default
        MClust_TText = e;                                 % assume it is the tetrode extension
    end
    
    MClust_fn = n;
    MClust_FDfn = [n MClust_FDext];
    IsSplit = findstr(n,'b');
    if ~isempty(IsSplit)
        n = n(1:IsSplit -1)
    end
    
    % modified ncst 19 Jun 02
    if ~strcmp(e,MClust_TText) & ~strcmp(e,MClust_FDext)
        MClust_TText = e;
    end
    
    MClust_TTfn = [n MClust_TText];
    
    if strcmp(e,MClust_TText)
        MClust_TTdn = dn;
        pushdir(MClust_TTdn);
        if exist('FD','dir')
            MClust_FDdn = [dn filesep 'FD'];
        else
            MClust_FDdn = dn;
        end
        popdir;
    elseif strcmp(e,MClust_FDext)
        MClust_FDdn = dn;
        pushdir(MClust_FDdn);
        
        % modified ncst 19 Jun 02
        % Checks for a TT_file_name field to use to find the right data file extension
        temp = load([dn filesep fn],'-mat');
        TempFields = fieldnames(temp);
        for iX = 1:length(TempFields)
            if strcmp(TempFields{iX},'TT_file_name')
                [p n e] = fileparts(temp.TT_file_name);
                MClust_TText = e;
            end
        end
        MClust_TTfn = [n MClust_TText];
        if ~exist(MClust_TTfn)
            pushdir('..');
            if ~exist(MClust_TTfn)
                disp(['Error: did not find file: ' MClust_TTfn]);
                popdir;
                popdir;
                return;
            else
                MClust_TTdn = pwd;
            end
            popdir;
        else
            MClust_TTdn = pwd;
        end
        popdir;
    end
end

if isempty(MClust_Directory);
    % need to define MClust_Directory (where to find the feature_*.m files)
    MClust_Directory = fileparts(which('MClust.m'));
end

BBClust.FDffn = fullfile(MClust_FDdn,MClust_FDfn);
BBClustFilePrefix = MClust_fn;
BBClustFileDir = MClust_FDdn;


% try
%     temp = load(MClust_FDfn,'-mat');
% catch
%     temp = [];
% end
%    
% if ~isempty(temp)  % If we found FDfn
%    MClust_FeatureIndex = temp.FeatureIndex;
%    MClust_ChannelValidity = temp.ChannelValidity;
%    MClust_FeatureTimestamps = temp.FeatureTimestamps; 
% end
       
% UndScore = find(BBFile_name == '_');
% if ~isempty(UndScore) & length(UndScore) == 1
%     BBFile_name = BBFile_name(1:UndScore - 1);   % if it is a TT_feature.fd file, get rid of the _feature
%     BBClustFilePrefix = BBFile_name;
% end
% MClust_FDfn = fullfile(FDdn,[BBFile_name '.fd']);
% 
% IsFDdir = findstr(FDdn,'FD');
% if ~isempty(IsFDdir)
%     TTdn = FDdn(1:IsFDdir - 2);
% else
%     TTdn = FDdn;
% end

% IsSplit = findstr(BBFile_name,'b');
% if ~isempty(IsSplit) %BBFile_name(end-1) == 'b'  % if the file name contains a b, consider it a split file and find the name of the original TT file
%     MClust_TTfn = fullfile(TTdn,[BBFile_name(1:IsSplit - 1) MClust_TText]); 
% else
%     MClust_TTfn = fullfile(TTdn,[BBFile_name MClust_TText]); 
% end

FeaturesUseListbox = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
MClust_FeaturesToUse = get(FeaturesUseListbox, 'String')';


% Modified ncst 20 May 02
% find the user set channel validities
MClust_ChannelValidity(1) = get(findobj(figHandle, 'Tag', 'TTValidity1'), 'Value');
MClust_ChannelValidity(2) = get(findobj(figHandle, 'Tag', 'TTValidity2'), 'Value');
MClust_ChannelValidity(3) = get(findobj(figHandle, 'Tag', 'TTValidity3'), 'Value');
MClust_ChannelValidity(4) = get(findobj(figHandle, 'Tag', 'TTValidity4'), 'Value');

pushdir(MClust_FDdn);

% find all FD files for the current tetrode
% ExistingFDs = FindFiles([MClust_fn '*.fd']);
% changed ncst 6 Sep 02 to eliminate problems with confusing TT1 with TTs 10 11 12
ExistingFDs = [FindFiles([MClust_fn '_*.fd']); FindFiles([MClust_fn '.fd'])];
if ~isempty(ExistingFDs)
   temp = load(ExistingFDs{1},'-mat');
   if ~all(MClust_ChannelValidity == temp.ChannelValidity);
       ChanValidityToUse = questdlg({'User defined channel validities do not match those found in the FD files'; ...
               'Which to use?'; ['User = ' num2str(MClust_ChannelValidity(1)) ' ' num2str(MClust_ChannelValidity(2)) ' ' ...
                   num2str(MClust_ChannelValidity(3)) ' ' num2str(MClust_ChannelValidity(4))]; ...
               ['FD file = ' num2str(temp.ChannelValidity(1)) ' ' num2str(temp.ChannelValidity(2)) ' ' ...
                   num2str(temp.ChannelValidity(3)) ' ' num2str(temp.ChannelValidity(4))] }, ...
               'Select Channel Validity', 'User', 'FD','Cancel', 'FD');
       switch ChanValidityToUse
       case 'FD'
           MClust_ChannelValidity = temp.ChannelValidity;
       case 'User'
           % check to see if the user defined channels exist in the fd files
           if ~all(MClust_ChannelValidity(find(MClust_ChannelValidity)) == temp.ChannelValidity(find(MClust_ChannelValidity)))
               % if not, ask the user to recalculate or use different channels
               errordlg({'The user defined channels are not all present in these feature data files'; ...
                       'Delete these FD files and recalculate them, or use different channel validities'}, 'MClust error', 'modal');
               disp('MClust_ChannelValidity');
               disp(MClust_ChannelValidity); disp(' ');
               disp(['Channel Validity for: ' ExistingFDs{1}]);
               disp(temp.ChannelValidity); disp(' ');
               MClustCallbacks('ClearWKSPC');
               return
           end
       case 'Cancel'
           MClustCallbacks('ClearWKSPC');
           return
       end
   end
end
       
global MClust_max_records_to_load

if ~isempty(MClust_max_records_to_load)
	record_block_size = MClust_max_records_to_load;
else
	record_block_size = 80000;  % maximum number of spikes to load into memory at one time
end

% AddFeatureFiles = FindFiles(fullfile(MClust_FDdn, [MClust_fn '_*' MClust_FDext]));
for iMCF = 1:length(MClust_FeaturesToUse)
    if isempty(strmatch('time',MClust_FeaturesToUse{iMCF}))
%         AddFeatureFile = FindFiles(fullfile(MClust_FDdn, [MClust_fn '_' MClust_FeaturesToUse{iMCF} MClust_FDext]));
        if ~exist([MClust_FDdn filesep MClust_fn '_' MClust_FeaturesToUse{iMCF} MClust_FDext]) % isempty(AddFeatureFile)
            
            template_matching = 0;
            disp(' ')
            disp(['FD file ' MClust_fn '_' MClust_FeaturesToUse{iMCF} '.fd does not exist; creating...'])
            disp(' ')
            Write_fd_file(fullfile(MClust_FDdn, [MClust_fn '_' MClust_FeaturesToUse{iMCF} '.fd']), [MClust_TTdn filesep MClust_TTfn], ...
                MClust_FeaturesToUse(iMCF), MClust_ChannelValidity, record_block_size, template_matching)
        end            
        temp = load([MClust_FDdn filesep MClust_fn '_' MClust_FeaturesToUse{iMCF} MClust_FDext],'-mat');
        
        % Check to make certain that the loaded file has the correct channels 
        if ~all(MClust_ChannelValidity(find(MClust_ChannelValidity)) == temp.ChannelValidity(find(MClust_ChannelValidity)))
            % if not, ask the user to recalculate or use different channels
            errordlg({'The user defined channels are not all present in all of these feature data files'; ...
                    'Delete these FD files and recalculate them, or use different channel validities'}, 'MClust error', 'modal');
            disp('MClust_ChannelValidity');
            disp(MClust_ChannelValidity); disp(' ');
            disp(['Channel Validity for: ' MClust_fn '_' MClust_FeaturesToUse{iMCF} MClust_FDext]);
            disp(temp.ChannelValidity); disp(' ');
            MClustCallbacks('ClearWKSPC');
            return
        end
        
        MClust_FeaturesToUse = [MClust_FeaturesToUse temp.FeaturesToUse];
        if size(MClust_FeatureData,2) < 3
            for iAdd = 1:size(temp.FeatureData,2)
                if size(MClust_FeatureData,2) < 3
                    Name = temp.FeatureNames{iAdd};
                    ChannelNum = str2num(Name(end));
                    if MClust_ChannelValidity(ChannelNum)
                        MClust_FeatureData = [MClust_FeatureData temp.FeatureData(:,iAdd)];
                        MClust_CurrentFeatures = [MClust_CurrentFeatures temp.FeatureNames(iAdd)];
                    end
                end
            end
        end
        for iFN = 1:length(temp.FeatureNames)
            Name = temp.FeatureNames{iFN};
            ChannelNum = str2num(Name(end));
            if MClust_ChannelValidity(ChannelNum)
                MClust_FeatureNames = [MClust_FeatureNames; temp.FeatureNames(iFN)];
            end
        end
        
        if isempty(MClust_FeatureTimestamps)
            MClust_FeatureIndex = temp.FeatureIndex;
            %MClust_ChannelValidity = temp.ChannelValidity;
            MClust_FeatureTimestamps = temp.FeatureTimestamps; 
        end     
    end
end

MClust_FeatureNames(end+1) = {'time'};

clear temp

set(findobj(figHandle, 'Tag', 'LoadFeaturesButton'), 'Value', 1,'Enable','off');

set(findobj(figHandle, 'Tag', 'FeaturesIgnoreListbox'), 'Enable','off');
set(findobj(figHandle, 'Tag', 'FeaturesUseListbox'), 'Enable','off');
   
% Modified ncst 20 May 02
% update Channel Validity Checkboxes with used channels in featurefile
set(findobj(figHandle, 'Tag', 'TTValidity1'), 'Value', MClust_ChannelValidity(1),'Enable','off');
set(findobj(figHandle, 'Tag', 'TTValidity2'), 'Value', MClust_ChannelValidity(2),'Enable','off');
set(findobj(figHandle, 'Tag', 'TTValidity3'), 'Value', MClust_ChannelValidity(3),'Enable','off');
set(findobj(figHandle, 'Tag', 'TTValidity4'), 'Value', MClust_ChannelValidity(4),'Enable','off');

set(findobj(figHandle, 'Tag', 'TTFileName'), 'String', MClust_fn);


% case 'CalculateFeaturesButton'
%     % get channel validity
%     for iCh = 1:4
%         TTValidityButton = findobj(figHandle, 'Tag', ['TTValidity' num2str(iCh)]);
%         MClust_ChannelValidity(iCh) = get(TTValidityButton, 'Value');
%    end
%    FeaturesUseListbox = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
%    FeaturesToUse = get(FeaturesUseListbox, 'String');
%    MClust_FeatureData = [];
%    MClust_FeatureNames = {};
%    setptr(gcf, 'watch');
%    nFeatures = length(FeaturesToUse);
%    for iF = 1:nFeatures
%        fprintf(2, 'Calculating feature: %s ... ', FeaturesToUse{iF});
%        [nextFeatureData, nextFeatureNames] = ...
%            feval(['feature_', FeaturesToUse{iF}], MClust_TTData, MClust_ChannelValidity);
%       MClust_FeatureData = [MClust_FeatureData nextFeatureData];
%       MClust_FeatureNames = [MClust_FeatureNames; nextFeatureNames];
%       fprintf(2, 'done.\n'); 
%   end
%    setptr(gcf, 'arrow');
%    set(cboHandle, 'Value', 1);
   
   
case 'BBClustSelection'
    
   global MClust_fn;
   global MClust_dn;
   global MClust_FeatureData
   if isempty(MClust_FeatureData)
       errordlg('No features calculated.', 'MClust error', 'modal');
       return
   end
   
   [fn1, dn1] = fileparts(MClust_fn);
   
    % load Bubble Tree file
   if isempty(MClust_fn)
     [fn1, dn1] = uigetfile('*.bbt', 'Full bubble tree file');
   else
     fn1 = [MClust_fn '.bbt'];
     dn1 = MClust_FDdn;
   end
   
   if fn1
      if dn1
          pushdir(dn1); 
      end
      if ~exist(fn1,'file')
          [fn1, dn1] = uigetfile('*.bbt', 'Full bubble tree file');
          if fn1
              [p n e] = fileparts(fn1);
              MClust_fn = n;
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
     
    global KlustaKwik_Clusters
    global MClust_FDdn % FeatureDataFileName
    global MClust_fn
    global MClust_FeatureData
    if isempty(MClust_FeatureData)
        errordlg('No features calculated.', 'MClust error', 'modal');
        return
    end
    
    pushdir(MClust_FDdn);
    expExtension = [MClust_fn '.clu.*'];
    CLUfiles = FindFiles([MClust_fn '.clu.*']); % Can we figure out the correct file?
    if length(CLUfiles) ~= 1     % NO
        [fn, fdir] = uigetfile(expExtension);
        % Get the file and remove any . extensions (there are 
        % more than one so you need to run this a couple times).
    else                         % YES
        [fdir fn fext] = fileparts(CLUfiles{1});
    end
    popdir;
    
    if isempty(fn)
        return
    end
    
    [p rootname e ] = fileparts(fn);
    [p rootname e ] = fileparts(rootname);
    [p rootname e ] = fileparts(rootname);
    
    
    if rootname       
		% Load in the clusters from KlustaKwik
		file_no = 1;
		clu_file = [fullfile(fdir,rootname) '.clu.' num2str(file_no)];
		KlustaKwik_Clusters = KlustaImport(clu_file);
    end
       
    if ~isempty(KlustaKwik_Clusters)
        KlustaKwikDecisionWindow; % create window
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
   global MClust_FeatureData
   if isempty(MClust_FeatureData)
      errordlg('No features calculated.', 'MClust error', 'modal');
   else
      ViewClusters;
   end
   
      
case 'LoadCut'
   global MClust_Clusters MClust_TTdn
   fn = uigetfile([MClust_TTdn '*.cut']);
   if fn
      MClust_Clusters = LoadPreCut(fn);
   end
   
case 'SaveClusters'
    global MClust_TTdn MClust_fn
    global MClust_Clusters MClust_Colors MClust_ClusterFileNames
    
    if isempty(MClust_Clusters)
        errordlg('No clusters exist.', 'MClust error', 'modal');
        return
    end
    
   switch computer
   case 'SOL2', [fn,dn] = uiputfile([MClust_TTdn '.clusters']);
   case 'PCWIN', [fn,dn] = uiputfile(fullfile(MClust_TTdn, [MClust_fn '.clusters']));
   end
   if fn
      featureToUseHandle = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
      featuresToUse = get(featureToUseHandle, 'String');
      global MClust_FeatureIndex
      featureindex = MClust_FeatureIndex;
      save(fullfile(dn,fn), 'MClust_Clusters', 'MClust_FeatureNames', ...
         'MClust_ChannelValidity','MClust_Colors','MClust_ClusterFileNames','featuresToUse','featureindex','-mat');
      msgbox('Clusters saved successfully.', 'MClust msg');
   end
   
case 'LoadClusters'
    global MClust_TTdn MClust_Clusters
    global MClust_FeatureData MClust_Colors MClust_ClusterFileNames
    
    if isempty(MClust_FeatureData)
        errordlg('No features calculated.', 'MClust error', 'modal');
        return
    end
    [fn,dn] = uigetfile(fullfile(MClust_TTdn, '*.clusters'));
    
    if fn
        [fpath fname fext] = fileparts(fn);
        currentFeatureNames = MClust_FeatureNames;
        msg = {};
        MC_C = MClust_Clusters;
		MC_Colors = MClust_Colors;
		MC_CNames = MClust_ClusterFileNames;
		MClust_ClusterFileNames = {};
		MClust_Colors = [];
		
        global MClust_FeatureIndex 
        msg{end + 1} = ['Loading clusters from ' fn];
		
		tClust = load(fullfile(dn,fn),'-mat');
		tClustFields = fields(tClust);
		
		for iF = 1:length(tClustFields)
			if ~strcmp(tClustFields{iF},'MClust_ChannelValidity')
				eval([tClustFields{iF} ' = tClust.' tClustFields{iF} ';']);
			end
		end
		
%         try
%             load(fullfile(dn,fn), 'MClust_Clusters', 'MClust_FeatureNames','MClust_Colors','MClust_ClusterFileNames','featureindex', '-mat');
%         catch
%             load(fullfile(dn,fn), 'MClust_Clusters', 'MClust_FeatureNames', '-mat');
%         end
        
        if exist('featureindex','var')
			if length(featureindex) > 0
				if length(MClust_FeatureIndex) > length(featureindex) 
					if (sum(MClust_FeatureIndex(1:length(featureindex)) == featureindex)/length(featureindex)) ~= 1
						msg{end + 1} = 'Converting clusters to current feature index';
						for iC = 1:length(MClust_Clusters)
							MClust_Clusters{iC} = ConvertFI(MClust_Clusters{iC},featureindex);
						end
					else
						if (sum(MClust_FeatureIndex(1:100) == featureindex(1:100))/100) ~= 1
							msg{end + 1} = 'Converting clusters to current feature index';
							for iC = 1:length(MClust_Clusters)
								MClust_Clusters{iC} = ConvertFI(MClust_Clusters{iC},featureindex);
							end
						end
					end
				end
			end
		else
			msg{end + 1} = 'No featureindex found; continuing without index conversion';
		end
		
			
	  nClustersFromFile = length(MClust_Clusters);
	  newMC_C = MClust_Clusters;
      MClust_Clusters = [MC_C MClust_Clusters];
	  if length(newMC_C) == length(MClust_ClusterFileNames)
		  MClust_ClusterFileNames = [MC_CNames MClust_ClusterFileNames];
	  else
		  MClust_ClusterFileNames = MC_CNames;
		  for iC = 1:nClustersFromFile
			  MClust_ClusterFileNames{length(MC_C) + iC} = [fname ' Cluster ' num2str(iC)];
		  end
	  end
	  newMC_Colors = MClust_Colors;
	  MClust_Colors = MC_Colors;
	  if ~isempty(newMC_Colors)
		  MClust_Colors(length(MC_C) + 2:length(MC_C) + nClustersFromFile + 1,:) = newMC_Colors(2:nClustersFromFile+1,:);
	  end
		  
      if length(MClust_FeatureNames) ~= length(currentFeatureNames) | ~all(strcmp(currentFeatureNames, MClust_FeatureNames))
          msg{end + 1} = 'Feature name mismatch!';
          msg{end + 1} =  'Attempting conversion to current feature names.';
		  msg{end + 1} = ' ';
          WereErrors = 0;
          for iC = 1:length(MClust_Clusters)
              [MClust_Clusters{iC} ConversionError] = ConvertCluster(MClust_Clusters{iC},MClust_FeatureNames,currentFeatureNames);
              if ~isempty(ConversionError)
                  disp(['Cluster ' num2str(iC) ' has the following limits which require features not currently used: '])
                  for iX = 1:size(ConversionError,1)
                      disp([MClust_FeatureNames{ConversionError(iX,1)} ' x ' MClust_FeatureNames{ConversionError(iX,2)}]);
                  end
                  WereErrors = WereErrors + sum(size(ConversionError,1));
              end
          end
          MClust_FeatureNames = currentFeatureNames;
          if WereErrors > 0
              msg{end + 1} = [num2str(WereErrors) ' conversion errors occurred'];
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
    global MClust_FDfn MClust_FDdn MClust_FeatureData
    
    if isempty(MClust_FeatureData)
        errordlg('No features calculated.', 'MClust error', 'modal');
        return
    end
    [p,n,e] = fileparts(MClust_FDfn);
    expExtension = [MClust_FDdn filesep n '*.clu.*'];
    
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
    global MClust_TTfn MClust_TTdnMClust_FeatureData
    
    if isempty(MClust_FeatureData)
        errordlg('No features calculated.', 'MClust error', 'modal');
        return
    end
  
    [p,n,e] = fileparts(MClust_TTfn);
    spikefile = [MClust_TTdn filesep n '*.t'];
    [fn, fdir] = uigetfile(spikefile);
    
    if fn == 0
        return
    end
    
    spikes = loadspikes({[fdir filesep fn]},'tsflag','ts');
    stimes = Data(spikes{1});
    
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
    
    global MClust_TTdn
    
    if ~isempty(MClust_TTdn)
        popdir all;
        pushdir(MClust_TTdn);
    end
    
    global MClust_Colors MClust_NeuralLoadingFunction
    LoadingFunction = MClust_NeuralLoadingFunction;
    MCColors = MClust_Colors;
    clear global BBClust* MClust_Clusters MClust_Co* MClust_Cu* MClust_D* MClust_F* MClust_H* MClust_N* MClust_T* MClust_U* MClust_f* KK* KlustaKwik_*
    
    global MClust_FeaturesToUse MClust_Colors MClust_NeuralLoadingFunction MClust_FilesWrittenYN
    MClust_FilesWrittenYN = 'no';
    MClust_NeuralLoadingFunction = LoadingFunction;
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
    
    set(findobj(figHandle, 'Tag', 'LoadFeaturesButton'), 'Value', 0,'Enable','on');
    
    set(findobj(figHandle, 'Tag', 'FeaturesIgnoreListbox'), 'Enable','on');
    set(findobj(figHandle, 'Tag', 'FeaturesUseListbox'), 'Enable','on');
    
    % update Channel Validity Checkboxes with used channels in featurefile
    set(findobj(figHandle, 'Tag', 'TTValidity1'), 'Value', 1, 'Enable', 'on');
    set(findobj(figHandle, 'Tag', 'TTValidity2'), 'Value', 1, 'Enable', 'on');
    set(findobj(figHandle, 'Tag', 'TTValidity3'), 'Value', 1, 'Enable', 'on');
    set(findobj(figHandle, 'Tag', 'TTValidity4'), 'Value', 1, 'Enable', 'on');
    
    set(findobj(figHandle, 'Tag', 'TTFileName'), 'String', []);
    
    KKWindow = findobj('Type', 'figure', 'Tag', 'KKDecisionWindow');
    if ~isempty(KKWindow)
        close(KKWindow);
    end
    BBWindow = findobj('Type','figure','Tag', 'BBClustDecisionWindow');
    if ~isempty(BBWindow)
        close(BBWindow);
    end
    
    pack
   
case 'ClearWorkspaceOnly'
    global MClust_FilesWrittenYN
   
    if ~strcmp(MClust_FilesWrittenYN,'yes')
        ynWrite = questdlg('Are you sure?  No undo is possible', 'ExitQuestion', 'Yes', 'Cancel','Cancel');
        switch ynWrite
        case 'Cancel'
            return
        end
    end
        
    MClustCallbacks('ClearWKSPC'); 

    
% case 'ClearWorkspaceOnly'
%     ynClose = questdlg('Clearing workspace.  No undo available. Are you sure?', 'ClearQuestion', 'Yes', 'Cancel', 'Cancel');
%     if strcmp(ynClose,'Yes')
%         ynWriteFiles = questdlg('Write files before clearing workspace?', 'ClearQuestion', 'Yes', 'No', 'Yes');
%         if strcmp(ynWriteFiles,'Yes')
%             MClustCallbacks('WriteFiles');
%         end
%         MClustCallbacks('ClearWKSPC');
%     end
%   
   
case 'SaveDefaults'
   global MClust_Colors MClust_ChannelValidity
   global MClust_Directory MClust_ClusterSeparationFeatures
   global MClust_ClusterCutWindow_Pos
   global MClust_CHDrawingAxisWindow_Pos
   global MClust_KKDecisionWindow_Pos
   global MClust_KK2D_Pos 
   global MClust_KK3D_Pos
   global MClust_KKContour_Pos
   global MClust_ClusterCutWindow_Marker
   global MClust_ClusterCutWindow_MarkerSize
   
   [fn,dn] = uiputfile('defaults.mclust');
   if fn     
      featureToUseHandle = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
      featuresToUse = get(featureToUseHandle, 'String');
      filetypeHandle = findobj(figHandle, 'Tag', 'InputType');
      MClust_FileType = get(filetypeHandle, 'value');
      save(fullfile(dn,fn), ...
          'MClust_Colors', ...
          'featuresToUse', 'MClust_ChannelValidity', 'MClust_FileType', ...
          'MClust_NeuralLoadingFunction','MClust_ClusterSeparationFeatures', ...
          'MClust_ClusterCutWindow_Pos','MClust_CHDrawingAxisWindow_Pos',...
          'MClust_KKDecisionWindow_Pos','MClust_KK2D_Pos','MClust_KK3D_Pos','MClust_KKContour_Pos','MClust_ClusterCutWindow_Marker', ...
          'MClust_ClusterCutWindow_MarkerSize','-mat');
      msgbox('Defaults saved successfully.', 'MClust msg');
   end
   
case 'LoadDefaults'
   global MClust_Colors MClust_ChannelValidity
   global MClust_Directory
   MClust_FileType = [];
   [fn,dn] = uigetfile('*.mclust');
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
    global MClust_Clusters MClust_FeatureData MClust_FilesWrittenYN
    global MClust_TTdn MClust_TTfn MClust_Colors MClust_ClusterFileNames
    if isempty(MClust_Clusters)
        errordlg('No clusters exist.', 'MClust error', 'modal');
        return
    end
    clusterIndex = ProcessClusters(MClust_FeatureData, MClust_Clusters);
    featureToUseHandle = findobj(figHandle, 'Tag', 'FeaturesUseListbox');
    featuresToUse = get(featureToUseHandle, 'String');
    global MClust_FeatureIndex
    featureindex = MClust_FeatureIndex;
    save([fullfile(MClust_TTdn, MClust_fn), '.clusters'], 'MClust_Clusters', 'MClust_FeatureNames', ...
         'MClust_ChannelValidity','MClust_Colors','MClust_ClusterFileNames','featuresToUse','featureindex','-mat');
    WriteClusterIndexFile([fullfile(MClust_TTdn, MClust_fn), '.cut'], clusterIndex);
    WriteTFiles(fullfile(MClust_TTdn, MClust_fn), MClust_TTData, MClust_FeatureData, MClust_Clusters);
    msgbox('Files written.', 'MClust msg');
    MClust_FilesWrittenYN = 'yes';
    
case 'About'
  helpwin MClust
  
case 'ExitOnlyButton'    
   global MClust_FilesWrittenYN
   
   if ~strcmp(MClust_FilesWrittenYN,'yes')
       ynWrite = questdlg('Are you sure?', 'ExitQuestion', 'Yes','Cancel', 'Cancel');
       switch ynWrite
       case 'Cancel'
           return
       end
   end
   MClustCallbacks('ClearWKSPC');
   clear global MClust_*
   close(figHandle);
   
% case 'ExitButton'
%    % automatically write all files and close window
%    MClustCallbacks('WriteFiles');
%    MClustCallbacks('ClearWKSPC');
%    close(figHandle);
   
otherwise
   warndlg('Sorry, feature not yet implemented.');  
end % switch