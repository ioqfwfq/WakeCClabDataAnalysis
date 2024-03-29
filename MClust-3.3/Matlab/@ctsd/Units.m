function R = Units(tsa,tUnits)
%
% R = Units(tsa)
%	returns units of tsa
%
% R = Units(tsa,tUnits)
%   assigns tUnits to tsa, if units exist converts to tUnits
%% INPUTS%      tsa %
% version L1.0% v 1.0: JCJ 12/19/2002 includes support for time units 
% 
% Status: IN PROGRESS


switch nargin
    case 1
        if isempty(strmatch('units',fieldnames(tsa)))
            warning('tsa units not specified' )
            R=[];
        else
            R=tsa.units;
        end
    case 2
        if isempty(strmatch('units',fieldnames(tsa)))
            R=ctsd(starttime(tsa),dt(tsa),tsa.data,tUnits);
        else
            R=ctsd(starttime(tsa,tUnits),dt(tsa,tUnits),tsa.data,tUnits);
        end

    otherwise
        error('Unknown number of input arguments.');

end