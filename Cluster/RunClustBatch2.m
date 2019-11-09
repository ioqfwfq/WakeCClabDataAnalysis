function RunClustBatch2(batchfile,varargin)
%
% RunClustBatch(batchfile)
%          or
% RunClustBatch(batchfile,'prevRunMat','batchfilename.mat')
% 
% Parses input lists from a text file 'batchfile'.
% The processing is logged in an output text file 'RunDD-MM-YYYY-HHMM.log' with the date and
% time in the filename (to distinguish multiple runs).
% The function also saves all parameters gPar,fPar, def, StartAtStep in a file 'RunDD-MM-YYYY-HHMM.log' so 
% that a batch run can be reloaded and reprocessed after a certain step (e.g. after creating the  
% feature data files or the splitting step). In this case 2 arguments need to be provided:
%
% INPUT: 
%   batchfile .... matlab string with the filename of the batch command file (usually Batch.txt)
%   prevRunMat ... matlab .mat file with saved gPar, fPar, def struct arrays from a previous run
%                  if some processing stages are to be skipped
%   Do_AutoClust...if 'yes' run KlustaKwik or BBClust, if 'no' stop after generating feature data files.
%
% Original code by PL 2000
% modified from RunBatch.m by NCST 2002.
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

% M3.01 NCST/ADR fixed TT_file_name save as with writeFD
% 
% NCST fixed deletion of summary .fd and .fet.1 after autoclustering
% ADR fixed CluNotDone flag errror (should have been ~)
% break -> return for warning off

Do_AutoClust = 'yes'; % Stop after initial processing (creation of FDs for BBClust)?
prevRunMat = [];
StartAtStep = 0;
extract_varargin; 

global MClust_Directory
MClustDir = which('MClust.m')
[MClust_Directory n e] = fileparts(MClustDir);

if nargin == 0
    batchfile = 'Batch.txt';
end

c = clock;
DateNow = datestr(now);
BatchName = ['Run-' DateNow([1:2 4:6 8:11]) '-' DateNow(13:14) '-' DateNow(16:17) '-' DateNow(19:20)];
logname = [BatchName '.log'];
% diary(logname);

disp(' ');
disp('==================================================');
disp([' Batch run: ' datestr(now)                       ]);
disp('==================================================');
disp(' ');

% process inputif nargin > 1
if ~isempty(prevRunMat)
   % resume processing at stage StartStep: load previous gPar,fPar and def
   load(prevRunMat);
else
   % only one input argument: start from scratch ....
   load('C:\Users\juzhu\Documents\MATLAB\DA\Data\KEN\autoBatch.mat');
end

%go to processing directory
pushdir(gPar.ProcessingDirectory);
pushdir(gPar.SpikeFilesSubDir);
if ~exist(gPar.FeatureDataDir,'dir')
    eval(['! mkdir ' gPar.FeatureDataDir]);
end

% Do not use time as a feature: wavePC1,2 and 3 are currently calculated using the PCs calculated 
% from the first block
UseFeatures = gPar.UseFeatures;
ExtraFeatures = gPar.ExtraFeatures; % used in cutting, but not sent to BubbleClust.exe
TotalFeatures = [UseFeatures ExtraFeatures];

% put loadingengine into global
global MClust_NeuralLoadingFunction
MClust_NeuralLoadingFunction = gPar.LoadingEngine;

%%%%%%%%%%%%%%%%%%%%%%%%%
% make feature data files
%%%%%%%%%%%%%%%%%%%%%%%%%
if StartAtStep <= 1
	disp(' ');
	disp('==================================================');
	disp(' Creating FeatureData files: '                     );
	disp('==================================================');
	disp(' ');
	
	files = gPar.FileList;
	nFiles = length(gPar.FileList);
	record_block_size = 40000;
	
	nFeatures = length(UseFeatures);
	
	template_matching = 0;
	
	for iTTfn = 1:nFiles
        CurrTTfile = files{iTTfn};
		[fpath, fname, fext] = fileparts(CurrTTfile);
        fpath = [pwd fpath filesep gPar.FeatureDataDir];
        FDfname = fullfile(fpath,[fname '_*' '.fd']);
        pushdir(fpath);
        FD_done = FindFiles([fname '_*.fd']); % capit fix adr 10/sept/03
        popdir;
        nSpikes = MClust_CountSpikes(CurrTTfile);
        if nSpikes == 0
            disp(['Warning: ' CurrTTfile ' contains no spikes, please remove this file from the batch list and rerun RunClustBatch']);
            return
        end
        if ~isempty(FD_done) & length(FD_done) == length(TotalFeatures)
            disp(['FD files for ' files{iTTfn} ' exists... using existing files.'])
        else
            Ch_Validity = fPar{iTTfn}.ChannelValidity;
            disp(' ')
            disp([' Starting ' fname fext])
            disp(' ')
            for iFD = 1:length(TotalFeatures)
                pushdir(fpath);
                FD_done = FindFiles([fname '_' TotalFeatures{iFD} '.fd']); % capit fix adr 10/sept/03
                popdir;
                if isempty(FD_done)
                    disp(['Writing ' fname '_' TotalFeatures{iFD} '.fd. Please wait.']);
                    Write_fd_file(fullfile(fpath,[fname '_' TotalFeatures{iFD} '.fd']), CurrTTfile, TotalFeatures(iFD), Ch_Validity, record_block_size, template_matching)
                else
                    disp(['FD file ' fname '_' TotalFeatures{iFD} '.fd exists... using existing file.'])
                end
                disp(' ')
            end
        end
        gPar.FeatureDataFileNames{iTTfn} = fullfile(fpath,FDfname);
        temp = load(fullfile(fpath,[fname '_' TotalFeatures{1} '.fd']),'-mat');  
        gPar.FeatureDataNumberOfSpikes{iTTfn} = length(temp.FeatureData(:,1));    
	end
    popdir;
    StartAtStep = 2;
%     save(BatchName, 'gPar', 'fPar', 'def','StartAtStep');
    pushdir(gPar.SpikeFilesSubDir);
end %step 1

%%%%%%%%%%%%%%%%%%%%%%%%%
%  STEP 2  
%  Split FD files if necessary 
%%%%%%%%%%%%%%%%%%%%%%%%%

if StartAtStep <=2
   
	disp(' ');
	disp('==================================================');
	disp(' Splitting FeatureData files: '           );
	disp('==================================================');
	disp(' ');
    
    gPar.SubsampledNumberOfSpikes = [];
    gPar.SubNN = [];
    gPar.SubChValidity = [];
	files = gPar.FileList;
	nFiles = length(gPar.FileList);
    for iSub = 1:nFiles
        
        ToSpikes = fPar{iSub}.SubsampleToNSpikes;
        nSpikes = gPar.FeatureDataNumberOfSpikes{iSub};
        CurrTTfile = files{iSub};
		[fpath, fname, fext] = fileparts(CurrTTfile);
        fpath = [pwd fpath filesep gPar.FeatureDataDir];
        FDfname = [fname '.fd'];
        
        if nSpikes > ToSpikes
            Overlap = 0;
            nFiles = min(find(repmat(nSpikes,1,20)./(1:20) < ToSpikes));
            ToSpikes = floor(nSpikes/nFiles);
            nSpikesPerExtendedBlock = floor(ToSpikes*(1+Overlap));

            %F = FindFiles(fullfile(fpath,[fname '_*.fd']));
            pushdir(fpath);
            F = FindFiles([fname '_*.fd']);
            popdir;
            FDFilesToSplit = [];
            for iF = 1:length(F)
			    [Fpath, Fname, Fext] = fileparts(F{iF});
                if isempty(find(Fname == 'b')) 
                    FDFilesToSplit{end + 1,1} = F{iF};
                end
            end
            
            for iSplit = 1:length(FDFilesToSplit)
			    [fpath, fname, fext] = fileparts(FDFilesToSplit{iSplit});
                disp([' Splitting ' fname '.fd into ' num2str(nFiles) ' files of size ' num2str(floor(ToSpikes/1000)) 'k spikes']);
                temp = load(FDFilesToSplit{iSplit},'-mat');
				for ii=1:nFiles
					% create index arrays
					ix = [];
					for ib = 1:nFiles 
						bstart = min(1+(ii-1)*ToSpikes+nFiles*(ib-1)*ToSpikes,nSpikes);
						bend = min(bstart+nSpikesPerExtendedBlock,nSpikes); 
						ix = [ix, bstart:bend];
						if bend == nSpikes
						    break;
						end%if
					end%ib
                    
                    FeatureIndex = ix;
                    FeatureTimestamps = temp.FeatureTimestamps(ix);
                    FeatureData = temp.FeatureData(ix,:);
                    FeaturesToUse = temp.FeaturesToUse;
                    ChannelValidity = temp.ChannelValidity;
                    FeatureNames = temp.FeatureNames;
                    FeaturePar = temp.FeaturePar;
                    FD_av = temp.FD_av;
                    FD_sd = temp.FD_sd;
               
                    FindUnderscore = find(fname == '_');
                    
                    if ~isempty(FindUnderscore) & length(FindUnderscore) == 1
    				    fnameout = fullfile(fpath, [fname(1:FindUnderscore -1) 'b' num2str(ii) fname(FindUnderscore:end) '.fd']);
                    else
                        fnameout = fullfile(fpath, [fname 'b' num2str(ii) '.fd']);
                    end
                    
                    if iSplit == 1
                        if ~isempty(FindUnderscore) & length(FindUnderscore) == 1
                            gPar.SubsampledFileNames{end + 1} = fullfile(fpath,[fname(1:FindUnderscore - 1) 'b' num2str(ii) '.fd']);
                        else
                            gPar.SubsampledFileNames{end + 1} = fullfile(fpath,[fname 'b' num2str(ii) '.fd']);
                        end
                        gPar.SubsampledNumberOfSpikes{end + 1} = length(ix);
                        gPar.SubNN{end + 1} = fPar{iSub}.NN;
                        gPar.SubChValidity{end + 1} = length(UseFeatures)*sum(fPar{iSub}.ChannelValidity);
                    end
                    
                    TT_file_name = temp.TT_file_name;
                    save(fnameout, 'TT_file_name', 'FeatureIndex', 'FeatureTimestamps','FeatureData', 'FeaturesToUse', 'ChannelValidity', 'FeatureNames', 'FeaturePar','FD_av','FD_sd', '-mat');
                    
			        [foutpath, foutname, foutext] = fileparts(fnameout);
                    disp([' Wrote ' foutname foutext ' as a .mat formatted file']);
				end%ii 
                disp(' ');
            end %iSplit
        else
            gPar.SubsampledFileNames{end + 1} = fullfile(fpath,FDfname);
            gPar.SubsampledNumberOfSpikes{end + 1} = gPar.FeatureDataNumberOfSpikes{iSub}; 
            gPar.SubNN{end+1} = fPar{iSub}.NN; 
            gPar.SubChValidity{end + 1} = length(UseFeatures)*sum(fPar{iSub}.ChannelValidity);
        end % if
    end % for
    popdir;
    StartAtStep = 3;
%     save(BatchName, 'gPar', 'fPar', 'def','StartAtStep');
    pushdir(gPar.SpikeFilesSubDir);
end  %step 2


%%%%%%%%%%%%%%%%%%%%%%%%%
%  STEP 3  
%  Create FDs  
%%%%%%%%%%%%%%%%%%%%%%%%%

if StartAtStep <= 3 & strcmp(Do_AutoClust,'yes')
   
	disp(' ');
	disp('==================================================');
	disp([' Creating FeatureData files for ' gPar.ClusterAlgorithm ': ']);
	disp('==================================================');
	disp(' ');
    
	files = gPar.SubsampledFileNames;
	nFiles = length(gPar.SubsampledFileNames); 
    
    for iCrFDs = 1:nFiles   
        FeaureIndex = [];
        FeatureTimestamps = [];
        FeatureData = [];
        FeaturesToUse = [];
        ChannelValidity = [];
        FeatureNames = [];
        FeaturePar = [];
        FD_av = [];
        FD_sd = [];
        for iG = 1:length(UseFeatures)
            [fpath fname fext] = fileparts(files{iCrFDs});
            temp = load(fullfile(fpath,[fname '_' UseFeatures{iG} '.fd']),'-mat');    
            FeatureIndex = temp.FeatureIndex;
            FeatureTimestamps = temp.FeatureTimestamps;
            FeatureData = [FeatureData temp.FeatureData];
            FeaturesToUse = [FeaturesToUse temp.FeaturesToUse];
            ChannelValidity = temp.ChannelValidity;
            FeatureNames = [FeatureNames temp.FeatureNames'];
            FeaturePar = temp.FeaturePar;
            FD_av = temp.FD_av;
            FD_sd = temp.FD_sd;         
        end %iG
        FeatureNames = FeatureNames';
  
        fnameout = fullfile(fpath,[fname '.fd']);
        TT_file_name = temp.TT_file_name;
%         save(fnameout, 'TT_file_name', 'FeatureTimestamps', 'FeatureIndex','FeatureData', 'FeaturesToUse', 'ChannelValidity', 'FeatureNames', 'FeaturePar','FD_av','FD_sd', '-mat'); 
      	if(strcmpi(gPar.ClusterAlgorithm,'KlustaKwik'))  
			FDTextFname = [fpath filesep fname];
			WriteFeatureData2TextFile(FDTextFname, FeatureData);
			gPar.SubsampledFileNames{iCrFDs} = FDTextFname ;
		end     
		
		UseFD_index{iCrFDs} = repmat(1,1,size(FeatureData,2));
        disp([' Wrote ' fnameout ' as a .mat formatted file']);   
    end % iCrFDs
    popdir;
    StartAtStep = 4;
%     save(BatchName, 'gPar', 'fPar', 'def','StartAtStep');
    pushdir(gPar.SpikeFilesSubDir);
end % step 3

% %%%%%%%%%%%%%%%%%%%%%%%%%
% %  STEP 4  
% %  Estimate Run Time
% %%%%%%%%%%%%%%%%%%%%%%%%%
% 
% if StartAtStep <= 4
% 
% 	disp(' ');
% 	disp('==================================================');
% 	disp(' Run duration estimate: '           );
% 	disp('==================================================');
% 	disp(' ');
% 
%     Do_plot = 0;
% 	nFiles = length(gPar.SubsampledFileNames);
%     nSpk = [];
%     nNN = [];
%     nDim = []; 
% 	for iEst = 1:nFiles
% 		IN = gPar.SubsampledFileNames{iEst};
% 		[INpath INname INext] = fileparts(IN);
%         if strcmpi(gPar.ClusterAlgorithm,'BBClust')
%             INdoneyet = FindFiles(fullfile(INpath, [INname '.bb*']));
%         elseif strcmpi(gPar.ClusterAlgorithm,'KlustaKwik')
%             INdoneyet = FindFiles(fullfile(INpath, [INname '.clu*']));
%         end
% 		if ~isempty(INdoneyet) & ((length(INdoneyet) >= 2 & strcmpi(gPar.ClusterAlgorithm,'BBClust')) | (length(INdoneyet) >= 1 & strcmpi(gPar.ClusterAlgorithm,'KlustaKwik')))
%             disp(['File ' IN ' has already been completed... Not using in estimate']);
%             nSpk = [nSpk 0];
%             nNN = [nNN 0]; 
%             nDim = [nDim 0];
%         else
%             nSpk = [nSpk gPar.SubsampledNumberOfSpikes{iEst}];
%             nNN = [nNN gPar.SubNN{iEst}]; 
%             nDim = [nDim gPar.SubChValidity{iEst}];
%         end;
% 	end;
%    
%     if strcmpi(gPar.ClusterAlgorithm,'BBClust')
%     	CalcBBPerform;
% 		EstDuration = polyval(LinFit,log10(nSpk.*nDim.*floor(nNN*0.0046.*sqrt(nSpk))));
%         EstDuration = (10.^EstDuration);
%         EstDur = sum(EstDuration)/60;
%     elseif strcmpi(gPar.ClusterAlgorithm,'KlustaKwik')
%         CalcKKPerform;
%         EstDuration = polyval(LinFit,nSpk.*nDim)/60;
%         EstDur = sum(EstDuration)/60;
%     end
% 	disp(' ')
% 	disp(['Estimated time required to run ' gPar.ClusterAlgorithm ' on these ' num2str(length(find(nSpk > 0))) ' files is ' num2str(EstDur) ' hours']);
% 	disp(' ')
% end %step 4

%%%%%%%%%%%%%%%%%%%%%%%%%
%  STEP 5  
%  Do Clustering 
%%%%%%%%%%%%%%%%%%%%%%%%%
cBubbleRun = clock;

if strcmp(Do_AutoClust,'yes')

   disp(' ');
   disp('==================================================');
   disp([' run ' gPar.ClusterAlgorithm ' on FeatureData files: ']);
   disp('==================================================');
   disp(' ');
  
   nFiles = length(gPar.SubsampledFileNames);
   % Find Clustering Algorithms
   if strcmpi('BBClust',gPar.ClusterAlgorithm)
       BBClustPath = which('BubbleClust.exe');       
       if ~isempty(BBClustPath)
           disp(['BBClustPath undefined, using ' BBClustPath]);
       else
           disp('Did not find BubbleClust.exe.');
           return
       end
   end
   if strcmpi('KlustaKwik',gPar.ClusterAlgorithm)
       KlustaKwikPath = which('KlustaKwik-1.5.exe');
       if ~isempty(KlustaKwikPath)
           disp(['KlustaKwikPath undefined, using ' KlustaKwikPath]);
       else
           disp('Did not find KlustaKwik.exe.');
           return
       end           
   end
   disp(' ');
   popdir;
   
   FinishedFiles = repmat(0,nFiles,1);
   IN = gPar.SubsampledFileNames{1};
   [INpath INname INext] = fileparts(IN);
   pushdir(INpath);
   if exist('FinishedFiles.mat')
	   load FinishedFiles.mat
   end
   popdir;
	   
   for i = 1:nFiles
	   
       CurrTime = datestr(now);
       CurrHour = str2num(CurrTime(end-7:end-6));
       IN = gPar.SubsampledFileNames{i};
       [INpath INname INext] = fileparts(IN);
       pushdir(INpath);
       if strcmpi(gPar.ClusterAlgorithm,'BBClust')
           INdoneyet = FindFiles([INname '.bb*']);
       elseif strcmpi(gPar.ClusterAlgorithm,'KlustaKwik')
           INdoneyet = FindFiles([INname '.clu*']);
       end
       popdir;
	   
	   CluNotDoneFlag = 1;
	   
% 	   if ~exist('FinishedFiles.mat') & (~isempty(INdoneyet) & ((length(INdoneyet) >= 2 & ...
% 			   strcmpi(gPar.ClusterAlgorithm,'BBClust')) | (length(INdoneyet) >= 1 & strcmpi(gPar.ClusterAlgorithm,'KlustaKwik'))))
% 		   CluNotDoneFlag = 0;
% 	   elseif FinishedFiles(i)
% 		   CluNotDoneFlag = 0;
% 	   end
	   
       if ~CluNotDoneFlag
           disp(' ')
           disp(['File ' IN ' has already been completed; skipping... ']);
           disp(' ')
           
       elseif(strcmpi(gPar.ClusterAlgorithm,'KlustaKwik')) 
           file_no = 1;
           parameter_string = ['-MinClusters ' num2str(fPar{i}.KKwikMinClusters) ...
				   ' -MaxClusters ' num2str(fPar{i}.KKwikMaxClusters) ...
				   ' -MaxPossibleClusters ' num2str(fPar{i}.KKwikMaxClusters) ' -UseFeatures ' num2str(UseFD_index{i}')'];
           COMMAND = ['! ' KlustaKwikPath ' "' IN '" ' num2str(file_no) ' ' parameter_string ];
           disp(IN);
           disp(['Number of spikes: ' num2str(gPar.SubsampledNumberOfSpikes{i})]);
           %                disp(['Estimated time required to run KlustaKwik.exe on this file is ' num2str(EstDuration(i)*60) ' seconds (or ' num2str(EstDuration(i)/60) 'hours)']);
           COMD_output = evalc(COMMAND);
           % Find the output that you are going to display
           COMD_filebase = findstr(COMD_output,'FileBase');
           COMD_dim = findstr(COMD_output,'dimension');
           COMD_time = findstr(COMD_output,'That took');
           
           try
               disp(COMD_output([COMD_filebase:COMD_dim + 13,COMD_time:end]));
           catch
               disp(['Did not find output that was searched for, all output shown:  ' COMD_output]);
           end
           
           disp(' ')
           
           % modified ncst 21 Jun 02 to remove summary .fd and .fet.1 
           dos(['del ' INpath filesep INname '.fet.1']);
           dos(['del ' INpath filesep INname '.fd']);
		   
		   pushdir(INpath);
		   FinishedFiles(i) = 1;
% 		   save('FinishedFiles.mat','FinishedFiles')
		   popdir;
		   
       elseif(strcmpi(gPar.ClusterAlgorithm,'BBClust')) 
           [fpath, INname, ext] = fileparts(IN);
           OUT = INname; %fullfile(fpath,IName);
           pushdir(fpath);
           nSpikes = gPar.SubsampledNumberOfSpikes{i};
           NNat5k = gPar.SubNN{i};  
           NN = max(15,floor(NNat5k*0.0046*sqrt(nSpikes)));    % scaling of NN smoothing proportional to sqrt(nSpikes)
           % 	           disp(['Estimated time required to run BBClust.exe on this file is ' num2str(EstDuration(i)) ' minutes (or ' num2str(EstDuration(i)/60) 'hours)']);
           COMMAND = ['! ' BBClustPath ' -fd ' [INname ext] ' -prefix ' OUT ' -nn ' num2str(NN)]; 
           disp(' ');
           disp(COMMAND);
           eval(COMMAND);
           dos(['del ' fpath filesep '*_nn.dat']);
           popdir;
           % modified ncst 21 Jun 02 to remove summary .fd file
           dos(['del ' INpath filesep INname '.fd']);
		   
		   pushdir(INpath);
		   FinishedFiles(i) = 1;
% 		   save('FinishedFiles.mat','FinishedFiles')
		   popdir;
       end %if
   end %if
   disp(' ')
end % run bbclust

disp(' ');
disp('==================================================');
disp([' End of Batch run: ' datestr(now)                 ]);
disp([' Run Duration: ' num2str(etime(clock,c)/3600) ]);
disp([' Time for ' gPar.ClusterAlgorithm ' run: ' num2str(etime(clock,cBubbleRun)/3600) ]);
disp('==================================================');
disp(' ');

popdir;
diary off;

%===============================================================================
function WriteFeatureData2TextFile(file_name, FeatureData)
%
% write featuredata from memory to a text file for input into KlustaKwick.exe
%
file_no = 1;
fid = fopen([ file_name '.fet.' num2str(file_no)],'w');
[n_points, n_features] = size(FeatureData);
fprintf(fid,'%3d \n',n_features);
for ii = 1:n_points
    fprintf(fid,'%f\t',FeatureData(ii,:));
    fprintf(fid,'\n');
end
fclose(fid);


