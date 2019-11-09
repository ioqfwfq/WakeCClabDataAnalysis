function AutoCluster3TRI(varargin)
% 6-2-05
% AutoCluster automatically runs the cluster analysis program KlustaKwik
% using the mclust batch file RunClustBatch.  The program has been altered
% so that parameters can be inputed into RunClustBatch without the
% Batch.txt file.  This is done using autoBatch.mat, which contains the
% three parameters that are generated from Batch.txt, 'gPar fPar def'
% An example of altering gPar; if you need to automate clustering of data
% using a minCluster of 1 and maxCluster of 10, then load autoBatch.mat,
% change the minCluster and maxCluster values in the gPar fPar and def
% variables, then save them back into the autoBatch.mat file and run
% AutoCluster. TM

global trials

monkey = 'TRI';
eval(['cd C:\Users\juzhu\Documents\MATLAB\DA\Data\' monkey ''])
load('C:\Users\juzhu\Documents\MATLAB\DA\Data\KEN\autoBatch.mat');

if nargin > 0
    minn = length(varargin)-1;
    maxn = length(varargin);
    gPar.UseFeatures = varargin(1:minn-1);
    def.KKwikMinClusters = varargin{minn};
    def.MinClusters = varargin{minn};
    fPar{1}.KKwikMinClusters = varargin{minn};
    fPar{1}.MinClusters = varargin{minn};
    gPar.KKwikMinClusters = varargin{minn};
    
    def.KKwikMaxClusters = varargin{maxn};
    def.MaxClusters = varargin{maxn};
    fPar{1}.KKwikMaxClusters = varargin{maxn};
    fPar{1}.MaxClusters = varargin{maxn};
    gPar.KKwikMaxClusters = varargin{maxn};
end
fns = dir([monkey,'*.apm']);
def.KKwikMaxClusters =15;
fPar{1}.KKwikMaxClusters=15;
n_stop = 0;
for n = 1:length(fns)
    try
        if n > n_stop
            n_start = n;
            while (n+1) <= length(fns)
                if fns(n).name(1:6) == fns(n+1).name(1:6)
                    n = n+1;
                else
                    break
                end
            end
            n_stop = n;
            trials = [];
            new_trials = [];
            task_ends = [];
            
            if ~isempty(which([fns(n_start).name(1:8),'CAT.mat']));
                disp('Loading Concatinated T file')
                load([fns(n_start).name(1:8),'CAT.mat']);
            else
                
                for l = n_start:n_stop
                    if ~isempty(which([fns(l).name(1:8),'T.mat']));
                        disp('Loading T file')
                        load([fns(l).name(1:8),'T.mat']);
                    else
                        %                         l = n_start;
                        trials = APMReadUserData(fns(l).name);
                        %                         save(['.\T_file\',fns(l).name(1:8),'T.mat'], 'trials');
                    end
                    new_trials = [new_trials trials];
                    task_ends = [task_ends length(new_trials)];
                end
                trials = new_trials;
                save(['.\T_file\',fns(n_start).name(1:8),'CAT.mat'], 'trials', 'task_ends');
                clear new_trials
            end
            poss_channels = CheckChannels(trials);
            %             poss_channels = [2];
            spike_ends = Extract_Wave(fns(n_start).name(1:8),trials,task_ends);
            save(['.\T_file\',fns(n_start).name(1:8),'CAT.mat'], 'trials', 'spike_ends','task_ends');
            for m = 1:length(poss_channels)
                fn_dir = ['.\Clusters\', fns(n_start).name(1:8),'_channel_',num2str(poss_channels(m)),'_CAT'];
                if exist(fn_dir) == 7
                    dos(['copy ',['.\',fn_dir,'\*.fd'],' .\FD'])
                else
                    dos(['mkdir ',['.\Clusters\', fns(n_start).name(1:8),'_channel_',num2str(poss_channels(m)),'_CAT']]);
                end
                SetAPM(poss_channels(m),7e6);
                pause(1)
                fPar{1}.FileName = fns(n_start).name;
                gPar.SearchString = fns(n_start).name;
                gPar.FileList = {fns(n_start).name};
                %                  gPar.UseFeatures = { 'peak'  'slopeR' 'wavePC1'};
                %                 gPar.UseFeatures = {'wavePC1' 'peak' 'valley' 'slopeR' 'slopeF'};
                gPar.UseFeatures = {'wavePC1' 'peak' 'valley'};
                def.KKwikMaxClusters =10;
                fPar{1}.KKwikMaxClusters=10;
                % save('D:\researchdata\Data\LEM\autoBatch.mat','gPar','fPar','def','fns')
                save('C:\Users\juzhu\Documents\MATLAB\DA\Data\ken\autoBatch.mat','gPar','fPar','def','fns')
                try
                    RunClustBatch2
                catch
                    lasterr
                    disp('error running RunClustBatch2')
                    log = ['error running ',fns(n_start).name(1:8)];
                    save log.mat log
                end
                dos(['move /Y .\FD\*.* ',['.\Clusters\', fns(n_start).name(1:8),'_channel_',num2str(poss_channels(m)),'_CAT']]);
                pause(1)
            end
        end
    catch
        lasterr
        disp(['Error in ',fns(n_start).name])
    end
end
disp('Finished automating clusters')