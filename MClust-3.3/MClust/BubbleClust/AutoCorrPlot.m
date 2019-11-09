function fh = AutoCorrPlot(lvl,ie)
%
% fh = AutoCorrPlot(lvl,ie)
%

[H1, binsUsed1, H2, binsUsed2] = GetAutoCorr(lvl,ie);

fh = figure;
subplot(1,2,1);
bar(binsUsed1,H1);
title(['(' num2str(lvl) ',' num2str(ie) ')']);
xy = axis;
ymin = xy(3);
ymax = xy(4);
xlabel('msec');
ylabel('Spikes/sec');
subplot(1,2,2);
bar(binsUsed2,H2);
xy = axis;
axis([ xy(1) xy(2) ymin ymax]);
xlabel('msec');
