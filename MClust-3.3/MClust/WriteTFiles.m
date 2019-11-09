function WriteTFiles(basefn, TT, featureData, clusters)
%
global MClust_FeatureTimestamps
nClust = length(clusters);
	if isa(TT,'double')
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