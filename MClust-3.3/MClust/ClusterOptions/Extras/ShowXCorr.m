function ShowXCorr(iClust)
 
% ShowXCorr(iClust)
%
% INPUTS
%    iClust
%
% OUTPUTS
%
% NONE
% TO USE WITH MCLUST, put this in the MClust/ClusterOptions folder

% ADR 2003
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.
% Extensively modified by ADR to accomodate new ClusterOptions methodology

        prompt={'Cluster to Compare:','bin size (msec):','Window width (msec):'};
        def={'','1','500'};
        dlgTitle='X Corr';
        lineNo=1;
        answer=inputdlg(prompt,dlgTitle,lineNo,def);
        if ~isempty(answer)
            figure;
            MClustXcorr(iClust, str2num(answer{1}),  str2num(answer{2}),  str2num(answer{3}));
        end
