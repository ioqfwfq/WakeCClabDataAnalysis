function fh = CrossCorrPlot(lvl1,ie1,lvl2,ie2)
%
% fh = CrossCorrPlot(lvl1,ie1,lvl2,ie2)
%
%
% Status: PROMOTED (Release version) 
% See documentation for copyright (owned by original authors) and warranties (none!).
% This code released as part of MClust 3.0.
% Version control M3.0.

[H1, binsUsed1, H2, binsUsed2] = GetCrossCorr(lvl1,ie1,lvl2,ie2);

fh = figure;
subplot(1,2,1);
bar(binsUsed1,H1);
title(['(' num2str(lvl1) ',' num2str(ie1) ') x (' num2str(lvl2) ',' num2str(ie2) ')']);
axis tight;
xy = axis;
ymin = 0;
ymax = xy(4)*1.1;
axis([ xy(1) xy(2) ymin ymax]);
xlabel('msec');
ylabel('Spikes/sec');
subplot(1,2,2);
bar(binsUsed2,H2);
axis tight;
xy = axis;
axis([ xy(1) xy(2) ymin ymax]);
xlabel('msec');
