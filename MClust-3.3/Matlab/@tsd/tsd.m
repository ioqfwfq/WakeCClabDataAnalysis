function tsa = tsd(t, qData, tUnits)
%
% tsa = tsd(t,data)
% tsa = tsd(t,data, units)  e.g. units = {'ts','sec', or 'ms'; assumes 'sec'}
%
% tsd is a class of "timestamped arrays"
% 	It includes a list of timestamps
% 	and data (possibly an array).  
%    The first dimension of Data correspond to the
%    timestamps given.  The timestamps must be sequential,
% 	but do not have to be continuous.
%
% Methods
%    tsd/Range     - Timestamps used
%    tsd/Data      - Returns the data component
%    tsd/DT        - Returns the DT value (mean diff(timestamps))
%    tsd/StartTime - First timestamp
%    tsd/EndTime   - Last timestamp
%    tsd/Restrict  - Keep data within a certain range
%    tsd/CheckTS   - Makes sure that a set of tsd & ctsd objects have identical start and end times
%    tsd/cat       - Concatenate ctsd and tsd objects
%    tsd/Mask      - Make all non-mask values NaN
%
% 	It is completely compatible with ctsd.
%  Note: data can be 2-dimensional, then time is the second axis.
%
% ADR 
% version L5.0
% v 5.0: JCJ 12/19/2002 includes support for time units 
%
% Status: IN PROGRESS 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.
% tsa.t = NaN;
% tsa.data = NaN;
% tsa.units= NaN;
switch nargin
   
case 0
 tsa.t = [];
 tsa.data = [];
 tsa.units= [];


case 1
   if isa(t, 'tsd')
      tsa = t;
      return;
   elseif isa(t, 'ctsd')
      tsa.t = Range(t);
      tsa.data = Data(t);
      if isempty(strmatch('units',fieldnames(t)))
          warning('units not specified' )
      else
          tsa.units=units(t);
      end
      
  elseif isa(t,'struct')
      tsa.t=t.t;
      tsa.data=t.data;
      if isempty(strmatch('units',fieldnames(t)))
          warning('units not specified' )
      else
          tsa.units=t.units;
      end
      
  else
      error('Unknown copy-from object');
  end
   
case 2
   tsa.t = t;
   tsa.data = qData;
   tsa.units= 'sec';
case 3
   tsa.t = t;
   tsa.data = qData;
   tsa.units= tUnits;   
otherwise
   error('Constructor error tsd');
end

tsa = class(tsa, 'tsd');
   
