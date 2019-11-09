function CheckAllClusters()
    global MClust_TTData MClust_Clusters MClust_FeatureData MClust_TTfn MClust_FeatureTimestamps MClust_TTdn
	global MClust_ChannelValidity
    [curdn,curfn] = fileparts(MClust_TTfn);
    save_jpegs = 0;
    for iClust = length(MClust_Clusters):-1:1     
		[f MClust_Clusters{iClust}] = FindInCluster(MClust_Clusters{iClust}, MClust_FeatureData);
        [clustTT, was_scaled] = ExtractCluster(MClust_TTData, f);
        if was_scaled
            title_string = [ 'Only ' num2str(size(clustTT,1)) ' of ' num2str(was_scaled) ' spikes shown.'];
        else
            title_string = [];
        end
        if ~isempty(Data(clustTT))
			ClustInd = repmat(0,size(MClust_FeatureTimestamps));
			ClustInd(f) = 1;
			[L_Extra,L_Ratio,IsolationDist,Dists] = ClusterSeparation(f,[MClust_TTdn filesep MClust_TTfn],MClust_ChannelValidity,iClust);
            CheckCluster([curfn, '--Cluster', num2str(iClust)], clustTT, MClust_FeatureTimestamps(1), MClust_FeatureTimestamps(end), save_jpegs,...
				title_string, was_scaled,'L_Extra',L_Extra,'L_Ratio',L_Ratio,'IsolationDist',IsolationDist,...
				'Dists',Dists,'ClustInd',ClustInd);
        else
            msgbox(['Cluster ' num2str(iClust) ' is empty']);
        end
    end
