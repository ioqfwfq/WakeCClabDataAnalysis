function GeneralizedCutterRecallUndo()

% GeneralizedCutterRecallUndo

global MClust_Undo MClust_Clusters
MClust_Clusters = MClust_Undo.clusters;
msgbox(['Undid function ', MClust_Undo.funcname], 'Undo', 'none', 'modal');
GeneralizedCutterStoreUndo('Undo');
