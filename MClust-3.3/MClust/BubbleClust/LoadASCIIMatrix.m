function mtx = LoadASCIIMatrix(fn)

% bbtm = LoadASCIIMatrix(fn)
%
% general purpose function to load an ascii matrix into matlab on 
% both SUN/SOLARIS and PC/NT platforms
%
% INPUTS
%      fn = filename of an ASCII N x M matrix 
%
% OUTPUTS
%      bbtm = full Bubble tree matrix

% ADR/LIPA 1999
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

load(fn, '-ascii');
[dn,fn0,ext] = fileparts(fn);
eval([ 'mtx = ' fn0 ';']);
