function GeneralizedCutterRedrawClusterKeys(figHandle, startCluster)

% GeneralizedCutterRedrawClusterKeys(figHandle, startCluster)

global MClust_Clusters MClust_Colors MClust_Directory
if nargin == 1
    sliderHandle = findobj(figHandle, 'Tag', 'ScrollClusters');
    startCluster = floor(-get(sliderHandle, 'Value'));
end

endCluster = floor(min(startCluster + 16, length(MClust_Clusters)));

pushdir([MClust_Directory filesep 'ClusterOptions' filesep]);
ClusterOptionsFiles = FindFiles('*.m','CheckSubdirs',0);
Extra_Options = {};
for iCOF = 1:length(ClusterOptionsFiles)
	[dummy_fd Extra_Options{iCOF} ext] = fileparts(ClusterOptionsFiles{iCOF});
end
popdir;


for iC = startCluster:endCluster
	if iC+1 > size(MClust_Colors,1)
		MClust_Colors(end+1,:) = MClust_Colors(end,:);
	end
    ClusterClass = 'mcconvexhull';  %default is mcconvexhull type for manual cluster cutting
    if iC > 0
        ClusterClass = class(MClust_Clusters{iC});  %if there are imported clusters, use their cluster type!
    end;
	CreateClusterKeys(figHandle, iC, 0.35, 0.9 - 0.05 * (iC - startCluster), 'GeneralizedCutterCallbacks', ...
		'Add limit', 'Add points',...
		'Delete limit', 'Delete all limits', 'Delete Cluster', ...
		'Copy cluster', 'Merge with', 'Rename Cluster',...
		'Check Cluster','---------------------',...
		Extra_Options{:});
end
