function GeneralizedCutterStoreUndo(funcname)

% GeneralizedCutterStoreUndo(funcname)

global MClust_Undo MClust_Clusters
MClust_Undo.clusters = MClust_Clusters;
MClust_Undo.funcname = funcname;

global MClust_FilesWrittenYN
MClust_FilesWrittenYN = 'no';

% count down autosave
GeneralizedCutterStepAutosave;
