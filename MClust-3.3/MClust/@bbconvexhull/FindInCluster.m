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
% PL 2000-2002
% ADR Added sort 16 May 2002
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

ylbls = [];
xlbls = [];
extract_varargin;

global MClust_FeatureNames MClust_FeatureTimestamps %MClust_xlbls MClust_ylbls

if ~isempty(MClust_FeatureNames) & isempty(xlbls)
    xlbls = MClust_FeatureNames;
    ylbls = MClust_FeatureNames;
end;

if MCC.recalc == 0
   f = MCC.myPoints; 
   return
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

[nSamps, nDims] = size(data);

if nBounds == 0
   f = MCC.myOrigPoints;
else
   f = MCC.myOrigPoints;
   for iB = 1:nBounds
      xd = MCC.xdims(iB);
      yd = MCC.ydims(iB);
      setptr(gcf, 'watch');
      if ~isempty(xlbls)
			global MClust_FDfn
			if strcmpi(ylbls{yd}(1:4), 'time')
			    data(:,2) = MClust_FeatureTimestamps;
			else
			    [fpath fname fext] = fileparts(MClust_FDfn);
			    FeatureToGet = ylbls{yd};
			    FindColon = find(FeatureToGet == ':');
			    temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
			    FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
			    data(:,2) = temp.FeatureData(:,FeatureIndex);
			end;
			if strcmpi(xlbls{xd}(1:4), 'time')
			    data(:,1) = MClust_FeatureTimestamps;
			else
			    [fpath fname fext] = fileparts(MClust_FDfn);
			    FeatureToGet = xlbls{xd};
			    FindColon = find(FeatureToGet == ':');
			    temp = load(fullfile(fpath, [fname '_' FeatureToGet(1:FindColon-1) '.fd']),'-mat');
			    FeatureIndex = strmatch(FeatureToGet,temp.FeatureNames);
			    data(:,1) = temp.FeatureData(:,FeatureIndex);
			end;
            xd = 1;
            yd = 2;
	  end;

      if (xd > nDims | yd > nDims)
         error('Data has too few dimensions in FindInCluster');
      end
      switch MCC.AddFlag(iB)
      case 1   % EXCLusive
  			f0 = find(InPolygon(data(f,xd), data(f,yd), MCC.cx{iB}, MCC.cy{iB}));
         %f0 = find(InConvexHull(data(f,xd), data(f,yd), MCC.cx{iB}, MCC.cy{iB}));
         f = f(f0);
         
      case 2   % INCLUSIVE (include ALL spikes)
         f = find(InPolygon(data(:,xd), data(:,yd), MCC.cx{iB}, MCC.cy{iB}));
   
		case 3   % Include only UNACcounted spikes
         f0 = find(MClust_ClusterIndex == 0);
         f = find(InPolygon(data(f0,xd), data(f0,yd), MCC.cx{iB}, MCC.cy{iB}));
              
      end%switch
	  setptr(gcf, 'arrow');
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
MCCFields = fields(MCC);
if strmatch('ForbiddenPoints',MCCFields)
	if isempty(f) | isempty(MCC.ForbiddenPoints)
	else
		[goodf, goodidx] = setdiff(f,MCC.ForbiddenPoints);
		f =  f(goodidx);
	end
end

f = sort(f);

if MCC.recalc == 1
   MCC.myPoints = f; 
   MCC.recalc = 0;
end
