function dagui_autocluster(varargin)
global trials
filename = varargin{1};
monkey = filename(1:3);
channel = varargin{2};
features = varargin(4:length(varargin));
diode_chan = 5;
eval(['cd C:\Users\juzhu\Documents\MATLAB\DA\Data\',monkey])
load autoBatch
gPar.UseFeatures = features{1:length(features)};
fPar{1}.FileName = [filename,'.apm'];
fPar{1}.KKwikMinClusters = varargin{3}.min;
fPar{1}.KKwikMaxClusters = varargin{3}.max;
gPar.SearchString = [filename,'.apm'];
gPar.FileList = {[filename,'.apm']};
save('autoBatch.mat','gPar','fPar','def')
trials = [];
if ~isempty(which([filename,'CAT.mat']));
    disp('Loading CAT file')
    load([filename,'CAT.mat']);
else
    if ~isempty(which([filename,'T.mat']));
        disp('Loading T file')
        load([filename,'T.mat']);
    else
        disp(['No CAT or T file '])
        return
        %     trials = apmreaduserdata(fns(n).name);
    end
end
poss_channels = channel;
% poss_channels = poss_channels(poss_channels ~= diode_chan) % remove diode channel  
for m = 1:length(poss_channels)
    fn_dir = [filename,'_channel_',num2str(poss_channels(m))];
    if exist(fn_dir) == 7
        dos(['copy ',['.\',fn_dir,'\*.fd'],' .\FD']); % XQ 2007 Jan 03
    else
        dos(['mkdir ',[filename,'_channel_',num2str(poss_channels(m))]]);
    end    
    SetAPM(poss_channels(m),5e6); % case sensitive
    try
        RunClustBatch2
    catch
        disp('error running RunClustBatch2')
        log = ['error running ',filename];
        save log.mat log
    end
    dos(['move /Y FD\*.* ',[filename,'_channel_',num2str(poss_channels(m))]]);
    WaitSecs(1)
end