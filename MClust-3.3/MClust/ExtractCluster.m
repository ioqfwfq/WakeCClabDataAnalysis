function [clustTT, was_scaled] = ExtractCluster(TT, clusterIndex)
    TTtimestamps = Range(TT, 'ts');