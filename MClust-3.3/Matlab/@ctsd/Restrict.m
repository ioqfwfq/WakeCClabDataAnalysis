function R = Restrict(D, A, B, C)

% ctsd/Restrict
% 	R = Restrict(tsa, t0, t1, units)
% 	R = Restrict(tsa, t0, t1)
% 	Returns a new tsa (ctsd) R so that D.Data is between 
%		timestamps t0 and t1, where t0 and t1 are in units
%
%    R = Restrict(tsa, t, units)
%    R = Restrict(tsa, t)
%    Returns a new tsd (not ctsd) R so that D.Data includes
%         only those timestamps in t, where t is in units
%
%   If units are not specified, assumes t has same units as D
%
%   NOTE: D will be returned in its original units!
%
% ADR 
% version L6.0
% v4.1 29 oct 1998 now can handle nargin=2
% v5.0 30 oct 1998 time dimension is always 1st dimension
% v5.1 19 jan 1998 now can handle t0 and t1 as arrays
% v6.0 JCJ 2/27/2003 includes support for time units
%


if isempty(strmatch('units',fieldnames(D)))
    warning('units not specified in tsa: assuming units = sec (converstions preformed)' )
    unit ='sec';
else
    unit = D.units;
    
end


switch nargin
case 2                             % R = Restrict(tsd, t)
   ix = findAlignment(D, A);
   tlist = Range(D,unit);       % should be 'sec' not 'ts' ~ JCJ:10/30/2002
   R = tsd(tlist(ix), SelectAlongFirstDimension(D.data, ix),unit);
   
case 3                             
    if isa(B,'char')               % units were specified R = Restrict(tsd, t, units)
        ix = findAlignment(D, A, B);
        tlist = Range(D,B);        % should be 'sec' not 'ts' ~ JCJ:10/30/2002
        R = tsd(tlist(ix), SelectAlongFirstDimension(D.data, ix),unit);
    else                           % units were NOT specified R = Restrict(tsd, t0, t1)
        if length(A) ~= length(B)
            error('t0 and t1 must be the same length.');
        end
        if length(A) == 1
            R0 = max(1, findAlignment(D, A));
            R1 = min(length(D.data), findAlignment(D, B));
            if ~(((R0==1) & (R1==1)) | ((R0==length(D.data)) & (R1==length(D.data))))  % both A(it) and B(it) were less than the first time or greater than the last time
                R = ctsd(A, D.dt, SelectAlongFirstDimension(D.data, R0:R1),unit);
            else
                R = ctsd([],[],[],unit);
            end
            
        else
            D.data = full(D.data);
            DATA = [];
            TIME = [];
            for it = 1:length(A)
                R0 = max(1, findAlignment(D, A(it)));
                R1 = min(length(D.data), findAlignment(D, B(it))); 
                if ~(((R0==1) & (R1==1)) | ((R0==length(D.data)) & (R1==length(D.data))))  % both A(it) and B(it) were less than the first time or greater than the last time
                    TIME = cat(2, TIME, findTime(D, R0):D.dt:findTime(D, R1));
                    DATA = cat(1, DATA, SelectAlongFirstDimension(D.data, R0:R1));
                end
            end
            R = tsd(TIME', DATA, unit);
        end
        
    end
case 4                             % units were  specified R = Restrict(tsd, t0, t1, units)
    if length(A) ~= length(B)  
        error('t0 and t1 must be the same length.');
    end
    if length(A) == 1
        R0 = max(1, findAlignment(D, A, C));
        R1 = min(length(D.data), findAlignment(D, B, C));
        if ~(((R0==1) & (R1==1)) | ((R0==length(D.data)) & (R1==length(D.data))))  % both A(it) and B(it) were less than the first time or greater than the last time
            R = ctsd(A, D.dt, SelectAlongFirstDimension(D.data, R0:R1),unit);
        else
            R = ctsd([],[],[],unit);
        end
    else
        D.data = full(D.data);
        DATA = [];
        TIME = [];
        for it = 1:length(A)
            R0 = max(1, findAlignment(D, A(it),C));
            R1 = min(length(D.data), findAlignment(D, B(it),C));
            if ~(((R0==1) & (R1==1)) | ((R0==length(D.data)) & (R1==length(D.data))))  % both A(it) and B(it) were less than the first time or greater than the last time
                TIME = cat(2, TIME, findTime(D, R0, unit):D.dt:findTime(D, R1, unit));
                DATA = cat(1, DATA, SelectAlongFirstDimension(D.data, R0:R1));
            end
            
        end
        R = tsd(TIME', DATA, unit);
    end
    
    
otherwise
    error('Unknown number of input arguments.');
   
end % switch
