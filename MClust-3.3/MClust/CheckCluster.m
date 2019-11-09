function CheckCluster(fn, WV, StartingTime, EndingTime, PrintFlag, title_string, was_scaled, varargin)
T = ts(Range(WV, 'ts'));pk = Peak(WV);
nPlot = 4;
% PLOT: AvgWaveform
subplot(nPlot,mPlot,1);
  h=errorbar(xrange(1:2:end),mWV(1:2:end),sWV(1:2:end),'.');   
axis([0 4*(nWVSamples + 2) -2100 2100]);
else
h=text(0,0.5, msgstr);
axis off;
subplot(nPlot, mPlot, 3);