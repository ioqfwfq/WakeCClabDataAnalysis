function WriteTFiles(basefn, TT, featureData, clusters)% WriteTFiles(basefn, TT, featuredata, clusters)%% MClust%  writes a T-file for each cluster%% ADR 1998% version M1.0% RELEASED as part of MClust 2.0% See standard disclaimer in Contents.m%% cowen 2001. Modified so that you can send in a vector of timestamps in the% TT variable instead of a monstrous TT tsd.
%% Status: PROMOTED (Release version) % See documentation for copyright (owned by original authors) and warranties (none!).% This code released as part of MClust 3.0.% Version control M3.0.
global MClust_FeatureTimestamps    
nClust = length(clusters);if isempty(TT)    timestamps = MClust_FeatureTimestamps;else
	if isa(TT,'double')        timestamps = TT;	elseif isa(TT,'ts')        timestamps = Data(TT);	else        timestamps = Range(TT, 'ts');	endend
for iC = 1:nClust
   DisplayProgress(iC, nClust, 'Title', 'Writing T files');
   f = FindInCluster(clusters{iC}, featureData);
   if ~isempty(f)
      TS = timestamps(f);
      fn = [basefn '_' num2str(iC) '.t'];
      fp = fopen(fn, 'wb', 'b');
      if (fp == -1)
         errordlg(['Could not open file"' fn '".']);
         keyboard;
      end
      WriteHeader(fp, 'T-file', 'Output from MClust''Time of spiking stored in timestamps (tenths of msecs)', 'as unsigned integer');
      fwrite(fp, TS, 'uint32');
      fclose(fp);
   end
end