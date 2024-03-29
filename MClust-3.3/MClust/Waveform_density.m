function [H, mxwv, mnwv] = Waveform_density(wv,interpolate,limit,varargin);
%function h = Waveform_density_plot(wv,limit);
% A 2D density plot of overlayed waveforms.
%
% INPUT: a matrix of rows = time, col = waveform
%        interpolate- if it's >0, then the waveform density plot will be interpolated for better resolution.
%        limit- the max number of waveforms to histogram at one time-- if too large
%        you will run out of memory.
% OUTPUT: if no argout, a density plot and a handle to it. 
%         if argout, the histogram is returned as well as the max and min values
%
% TO USE WITH MCLUST, put this in the MClust/ClusterOptions folder
% cowen 11/20/02
% ADR 19 aug 2003 Changed log to be log+1 - displays fine, but with no
% errors

mxwv = max(wv(:));
mnwv = min(wv(:));
maxc = 100; % The maximum number of colors to show. 100 is about right -- more than that and the low
            % stuff disappears.
xlim = 512;

extract_varargin;

if isempty(wv)
    H = [];
    return
end

if nargin < 2
    interpolate = 1;
    limit = 2000;
end
if nargin < 3
    limit = 2000;
end
n = size(wv,1);
H = zeros(1000,xlim);

if interpolate
    if n > limit
        nblocks = ceil(n/limit);
        for ii = 1:nblocks
            fprintf('.')
            idx = ((ii-1)*limit + 1):limit*ii;
            idx(find(idx>n)) = [];
            wvi = interp1([1:32]',wv(idx,:)',linspace(1,32,xlim),'spline')';
            [r,c] = find(wvi);
            [idx] = find(wvi);
            H = H + ndhist([c'; wvi(idx)'],[xlim 1000]',[1 mnwv ]',[xlim mxwv]')';
        end
    else
        wvi = interp1([1:32]',wv',linspace(1,32,xlim),'spline')';
        [r,c] = find(wvi);
        [idx] = find(wvi);
        H = ndhist([c'; wvi(idx)'],[xlim 1000]',[1 mnwv ]',[xlim mxwv]')';
    end
else
    xlim = 32;
    [idx] = find(wv);
    H = ndhist([c'; wv(idx)'],[32 1000]',[1 mnwv ]',[xlim mxwv]')';
end
%H = Hsmooth(H); % Do this if you want it smoother.

if nargout == 0
    % s = sum(H');
    % H(find(s==0),:) = [];
    H = log(H+1);
    mn = min(H(find(H>-100)));
    H(find(H < -100)) = mn;
    imagesc(Hsmooth(H));
    %caxis([min(H(:)) min([round(mean(H(:)) + 3*std(H(:))) maxc])])
    %colormap(1-gray)
    %axis off
    axis xy
    rng = 1:100:size(H,1);
    set(gca,'YTick',rng)
    set(gca,'YTickLabel',round(linspace(mnwv,mxwv,length(rng))))
    %figure 
    set(gca,'XTickLabel',round(32*(str2num(get(gca,'XTickLabel'))/xlim)))
    %contour(H,10) slow and doesn't doo much
end
