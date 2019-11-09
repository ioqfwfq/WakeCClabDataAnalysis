function tsdOUT = cat(varargin)

% tsdOUT = tsd/cat(tsd1, tsd2, ..., tsdn);
%
% INPUTS: 
%      tsd1, tsd2, ... tsdn -- each one is either a ctsd or tsd 
%
% OUTPUTS:
%      tsdOUT -- a tsd (not ctsd) that is a concatenation of all the inputs
%                with the same units as tsd1.
%
% ADR 1998
% version L5.0
% v4.2 17 nov 98 fullifies Data to correctly handle sparse matrices
% v5.0 JCJ 3/2/2003 includes support for time units
%


if ~isa(varargin{1}, 'tsd') & ~isa(varargin{1}, 'ctsd')
   error(['Initial tsd is not of type "[c]tsd".']);
end

tsa=varargin{1};
   
tsdOUT = tsd(Range(tsa,tsa.units), full(Data(tsa)),tsa.units);

for iTSD = 2:length(varargin)
   % First, all inputs must be tsd or ctsd 
   if ~isa(varargin{iTSD}, 'tsd') & ~isa(varargin{iTSD}, 'ctsd')
      error(['Input ', num2str(iTSD), 'is not a "[c]tsd"']);
   end
   % then all Data must be same dimension in non-time D
   szOUT = size(Data(tsdOUT));
   szTSD = size(Data(varargin{iTSD}));   
   if szOUT(2:length(szOUT)) ~= szTSD(2:length(szTSD))
      error(['Data size mismatch: input ', num2str(iTSD), '.']);
   end   
   % check to make sure times ok
   if StartTime(varargin{iTSD},tsa.units) < EndTime(tsdOUT,tsa.units)
      error(['Time mismatch: input ', num2str(iTSD), 'starts before previous data ends.']);
   end
   
   tsdOUT = tsd(...
      cat(1,Range(tsdOUT,tsa.units), Range(varargin{iTSD},tsa.units)), ...
      cat(1,Data(tsdOUT), full(Data(varargin{iTSD}))),...
      tsa.units);
   
end
