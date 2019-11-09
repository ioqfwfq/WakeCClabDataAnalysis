function EvalOverlap()

    global MClust_Clusters MClust_FeatureData
    [nS, nD] = size(MClust_FeatureData);
    nClust = length(MClust_Clusters);
    
    % ncst added 16 may 02
    if nClust == 1
        errordlg('Only one cluster exists.', 'MClust error', 'modal');
        return
    end
    
    nToDo = nClust * (nClust-1)/2;
    iDone = 0;
    overlap = zeros(nClust);
    for iC = 1:nClust
        iSpikes = zeros(nS, 1);
        [fI MClust_Clusters{iC}] = FindInCluster(MClust_Clusters{iC}, MClust_FeatureData);
        iSpikes(fI) = 1;
        for jC = (iC+1):nClust
            iDone = iDone +1;
            DisplayProgress(iDone, nToDo, 'Title', 'Evaluating overlap');
            jSpikes = zeros(nS, 1);
            [fJ MClust_Clusters{jC}] = FindInCluster(MClust_Clusters{jC}, MClust_FeatureData);
            jSpikes(fJ) = 1;
            overlap(iC,jC) = sum(iSpikes & jSpikes);
            overlap(jC,iC) = overlap(iC,jC);
        end
    end
    overlap = [(0:nClust)', [1:nClust; overlap]]
    msgbox(num2str(overlap), 'Overlap');
    
