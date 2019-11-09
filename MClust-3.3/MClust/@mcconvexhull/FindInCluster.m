function [f, MCC] = FindInCluster(MCC, data, varargin)

% f = FindInCluster(MCC, data)
%
% INPUTS
%     MCC - a MCCluster
%     data - nS x nD data
%
% OUTPUTS
%     f - indices of all points in the cluster
%
% ADR 1999
% version 1.2
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

% Modified ncst 02 March 03, removed xlbls and ylbls, added cowen's mod for
%   ForbiddenPoints, and to use the MClust_FDdn if the current directory is
%   changed.

global MClust_FDfn MClust_FeatureNames MClust_FDdn MClust_FeatureTimestamps

if MCC.recalc == 0
   f = MCC.myPoints; 
   return
end

MCCFields = fields(MCC);

% Older versions of MClust don't use ForbiddenPoints, so add the field if
% it is absent.
if ~strmatch('ForbiddenPoints',MCCFields)  
	MCC.ForbiddenPoints = [];
end
nBounds = length(MCC.xdims);
if nBounds ~= length(MCC.ydims)
   error('Unaligned data in FindInCluster');
end
if nBounds ~= length(MCC.cx)
   error('Unaligned data in FindInCluster');
end
if nBounds ~= length(MCC.cy)
   error('Unaligned data in FindInCluster');
end

%[nSamps, nDims] = size(data);

if ~strmatch('myOrigPoints',MCCFields)
	MCC.myOrigPoints = [];
end

if nBounds == 0
   f = MCC.myOrigPoints;
else
   f = MCC.myOrigPoints;
   for iB = 1:nBounds
      xd = MCC.xdims(iB);
      yd = MCC.ydims(iB);
	  CurrPtr = getptr(gcf);
      setptr(gcf, 'watch');
      if ~isempty(MClust_FeatureNames)
			if strcmpi(MClust_FeatureNames{yd}(1:4), 'time')
			    data(:,2) = MClust_FeatureTimestamps; %data(:,3);
			else
			    [fpath fname fext] = fileparts(MClust_FDfn);
			    FeatureToGet = MClust_FeatureNames{yd};
			    FindColon = find(FeatureToGet == ':');
			    temp = load(fullfile(MClust_FDdn, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
			    FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
			    data(:,2) = temp.FeatureData(:,FeatureIndex);
			end;
			if strcmpi(MClust_FeatureNames{xd}(1:4), 'time')
			    data(:,1) = MClust_FeatureTimestamps; %data(:,3);
			else
			    [fpath fname fext] = fileparts(MClust_FDfn);
			    FeatureToGet = MClust_FeatureNames{xd};
			    FindColon = find(FeatureToGet == ':');
			    temp = load(fullfile(MClust_FDdn, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
			    FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
			    data(:,1) = temp.FeatureData(:,FeatureIndex);
			end;
	  end;

      if exist('f', 'var')
	      f0 = find(InPolygon(data(f,1), data(f,2), MCC.cx{iB}, MCC.cy{iB}));
         %f0 = find(InConvexHull(data(f,xd), data(f,yd), MCC.cx{iB}, MCC.cy{iB}));
         f = f(f0);
      else
	     f = find(InPolygon(data(:,1), data(:,2), MCC.cx{iB}, MCC.cy{iB}));
        %f = find(InConvexHull(data(:,xd), data(:,yd), MCC.cx{iB}, MCC.cy{iB}));
      end
	  setptr(gcf, CurrPtr{2});
      if isempty(f)
         break;
      end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check to see if the set of valid points has been limited. If so, get
% rid of those points that have been verboten. This is useful if you use
% some other method of cutting or criteria that is not covered by the cluster
% boundaries.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strmatch('ForbiddenPoints',MCCFields)  % only if the cluster has a ForbiddenPoints field
	if isempty(f) | isempty(MCC.ForbiddenPoints)
	else
		[goodf, goodidx] = setdiff(f,MCC.ForbiddenPoints);
		f =  f(goodidx);
	end
end

if MCC.recalc == 1
   MCC.myPoints = f; 
   MCC.recalc = 0;
end

f = sort(f);