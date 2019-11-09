function Write_fd_file(FDfname, TT_file_name, FeaturesToUse, ChannelValidity, record_block_size, use_template_matching,NormalizeYN)
%function Write_fd_file(TT_file_name, FeaturesToUse, ChannelValidity, record_block_size, use_template_matching)
%
% This function creates feature data files from a TT file of ANY size.
% It does this by breaking the TT file into pieces.
%
% INPUT:
%   FDfname                 Name of output file.
%   TT_file_name            Name of the TT file.
%   FeaturesToUse           a cell array of string specifying the features to use {'energy', 'wavePC1'}
%                           the size in MB of the blocks to use.
%   ChannelValidity         [ 1 1 1 1 ]
%   record_block_size       block size in records
%   use_template_matching)  whether or not to use template matching
%
% OUTPUT: 
%     A feature data file with the same name as the tt file but with a .fd extension
%     This .fd file has the additional variable-- FeatureTimestamps. This contains the timestamps
%       for each feature, freeing us from a dependence on the large TT file for giving us our timestamps.
%   
% NOTE: The use of PCA is NOT recommended for this function as PCA will be
%       calculated on subsets of the data and not the entire set. 
%

% NOTES: Needed to change feature_peak.m so that it returns 3 arguments instead of 2. - done for wavePC1,2,3
%        To do: get this routine to do template matching as well
%               apply the PCA components generated from the first block to the rest. This
%                 is quite valid.
%
% Cowen
% Modified by NCST
% Mofidied by ADR/NCST
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

if nargin < 4
    valid_channels = [ 1 1 1 1];
end
if nargin < 5
    record_block_size = 100000; % Most computers should be able to handle 80000 spikes.
end
if nargin < 6
    use_template_matching = 0;
end
if nargin < 7
	NormalizeYN = 'no';
end

cnt = 1;
for ii = 1:length(FeaturesToUse)
    if strcmpi(FeaturesToUse{ii},'time')
        msgbox('Time is not a valid feature at this time. Ignoring it.')
        FeaturesToUse{ii} = [];
    else 
        X{cnt} = FeaturesToUse{ii};
        cnt = cnt + 1;
    end
end
FeaturesToUse = X; % Get rid of the time feature.

n_features = length(FeaturesToUse);
n_valid_channels = sum(ChannelValidity);

% --------------------------------------------------------
% Find the size of the TT file
% --------------------------------------------------------
n_records = MClust_CountSpikes(TT_file_name);

% --------------------------------------------------------
% Initialize the variables used for storing the feature output.
% --------------------------------------------------------
FeatureData = zeros(n_records,n_features*n_valid_channels)*nan;
FeatureTimestamps = zeros(n_records,1)*nan;
FeaturePar = {};

% --------------------------------------------------------
% Load in the template file if use_template_matching was selected
% --------------------------------------------------------
if use_template_matching
    minTh = .8;
    tmpl_fname = 'tmpl.mat';
    disp([' Loading waveform template file: ' tmpl_fname ]); 
    disp(' ');
    load('tmpl.mat','-mat');
    if ~exist('tmpl')
        disp('WARNING: Templates files did not load correctly! Skipping template matching.');
        use_template_matching = 0;
    end   
end


% --------------------------------------------------------
% Determine how many blocks in which to load the file.
% --------------------------------------------------------

n_blocks = ceil(n_records/record_block_size);
C = round(linspace(1 ,n_records, n_blocks+1));
starts = C(1:end-1)+1;
starts(1) = 1;
ends = C(2:end);

% --------------------------------------------------------
% Load each block, calcuate features and accumulate them across files
% --------------------------------------------------------
disp(['Loading ' num2str(n_blocks) ' blocks.'])
start_idx = 1; % Index of the first row of a block of feature data.
for block = 1:n_blocks
    
    FeatureNames = {};
    % [block_t,wv] = LoadTT0_nt(TT_file_name,[starts(block) ends(block)],4);
    % REPLACED ADR 14 May 2002
    [block_t,wv] = MClust_LoadNeuralData(TT_file_name,[starts(block) ends(block)],4);
    % --------------------------------------------------------
    % Do template matching
    % --------------------------------------------------------
    if use_template_matching
        n_recs_in_block = length(block_t);
        % --------------------------------------------------------
        % Save some memory by overwriting the wv variable.
        % --------------------------------------------------------
        wv = TruncateWaveForms(tsd(block_t,wv), ChannelValidity, tmpl, minTh);
        block_t = Range(wv,'ts');
        wv = Data(wv);
        if length(FeatureTimestamps) < 100       
            error('Template matching left less than 100 good spikes')
        end
        disp([num2str(block) ': Removed ' num2str(n_recs_in_block - length(block_t)) ' bad records.'])
    end
    % --------------------------------------------------------
    % Generate each feature.
    % --------------------------------------------------------
    for iF = 1:n_features
        if strcmp(FeaturesToUse{iF}(1:2),'wa')  %added ncst 17 Jan 02 to use wavePCA pars if this is not the first block
            if exist('wavePCApars','var')   % Currently works for at least wavePC1,2,&3
                [nextFeatureData, nextFeatureNames, nextFeaturePar] = ...
                    feval(['feature_', FeaturesToUse{iF}], tsd(block_t,wv), ChannelValidity,wavePCApars);
            else
                [nextFeatureData, nextFeatureNames, nextFeaturePar] = ...
                    feval(['feature_', FeaturesToUse{iF}], tsd(block_t,wv), ChannelValidity);
                wavePCApars = nextFeaturePar;
            end
        else
            [nextFeatureData, nextFeatureNames, nextFeaturePar] = ...
                feval(['feature_', FeaturesToUse{iF}], tsd(block_t,wv), ChannelValidity);
        end
        
        FeatureData(start_idx:(start_idx + length(block_t)-1),(iF-1)*n_valid_channels+1:iF*n_valid_channels) = nextFeatureData;
        FeatureTimestamps(start_idx:(start_idx + length(block_t)-1)) = block_t;
 
        FeatureNames = [FeatureNames; nextFeatureNames];
        if isempty(nextFeaturePar), nextFeaturePar = 'empty'; end%if
        
        FeaturePar{iF} = nextFeaturePar; 
    end%for
    start_idx = start_idx + length(block_t);
end

if use_template_matching
    % --------------------------------------------------------
    % Get rid of the unused portion of FeatureData and FeatureTimes
    % --------------------------------------------------------
    idx = find(~isnan(FeatureTimestamps));
    FeatureData = FeatureData(idx,:);
    FeatureTimestamps = FeatureTimestamps(idx,:);
    disp([' Template matching removed a total of ' num2str(n_records - length(idx)) ' bad records.'])
end


FD_av = mean(FeatureData);                % row mean vector
FD_sd = std(FeatureData)+eps;                 % row std vector
if strcmpi(NormalizeYN,'yes')
	% --------------------------------------------------------
	% normalize data to zero mean and unit variance
	% --------------------------------------------------------
	[nSpikes,nF] = size(FeatureData);
	FeatureData =(FeatureData-repmat(FD_av,nSpikes,1))./repmat(FD_sd,nSpikes,1); % standardize data to zero mean and unit variance
end

% --------------------------------------------------------
% Save the feature data file.
% --------------------------------------------------------
%[fpath, fname, ext] = fileparts(TT_file_name);
%FDfname = fullfile(fpath , [fname '.fd']);

FeatureIndex = 1:length(FeatureTimestamps);

% modified ncst 19 Jun 02 to save TT_file_name
save(FDfname, 'FeatureIndex','FeatureTimestamps','FeatureData', 'FeaturesToUse', 'ChannelValidity', 'FeatureNames', ... 
    'FeaturePar','FD_av','FD_sd', 'TT_file_name', '-mat');
disp([  ' Wrote ' FDfname ' as a .mat formatted file']);
