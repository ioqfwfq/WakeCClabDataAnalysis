function Neuron_Data_PSTH_BestCueFrom4Locs_AlignCue_FSRT(Excel_neurons)
% for AntiSaccade task
% find best cue location for ProSac, then plot bestcue trials for AntiSac (3 conditions)
% for the 3 conditon, divide the Reaction Time (RT) to two group, F(fast) group: <.23; S (slow) group: >.29
% 13-Dec-2011, xzhou

[Neurons_num Neurons_txt] = xlsread([Excel_neurons '.xlsx']);
warning off MATLAB:divideByZero
Neurons = [Neurons_txt(:,1) num2cell(Neurons_num(:,1))];

Best_Cue = Get_Maxes(Neurons);
opp_index = [5 6 7 8 1 2 3 4 9];
for n = 1:length(Best_Cue)
    Opp_Cue(n) = opp_index(Best_Cue(n));
end

RealBest_Cue = Get_RealMaxes(Neurons);
for n = 1:length(RealBest_Cue)
    RealOpp_Cue(n) = opp_index(RealBest_Cue(n));
end


for n = 1:length(Neurons)
    Antifilename = [Neurons{n,1}([1:6]),'_2_',num2str(Neurons{n,2})];
    Profilename = [Neurons{n,1},'_',num2str(Neurons{n,2})];
    try
        [psth_temp_fast psth_temp_slow] = Get_PsthM_fastslowRT(Antifilename,Best_Cue(n));
        psth1_fast(n,:) = psth_temp_fast;
        psth1_slow(n,:) = psth_temp_slow;
    catch
        disp(['error processing neuron  ', Antifilename   '  Dir=' num2str(Best_Cue(n))])
    end
    try
        [psth_temp_fast psth_temp_slow] = Get_PsthM_fastslowRT(Antifilename,Best_Cue(n)+8);
        psth2_fast(n,:) = psth_temp_fast;
        psth2_slow(n,:) = psth_temp_slow;
    catch
        disp(['error processing neuron  ', Antifilename   '  Dir=' num2str(Best_Cue(n)+8)])
    end
    try
        [psth_temp_fast psth_temp_slow] = Get_PsthM_fastslowRT(Antifilename,Best_Cue(n)+16);
        psth3_fast(n,:) = psth_temp_fast;
        psth3_slow(n,:) = psth_temp_slow;
    catch
        disp(['error processing neuron  ', Antifilename   '  Dir=' num2str(Best_Cue(n)+16)])
    end
   
    try
        [psth_temp_fast psth_temp_slow] = Get_PsthM_fastslowRT(Antifilename,Opp_Cue(n));
        psth4_fast(n,:) = psth_temp_fast;
        psth4_slow(n,:) = psth_temp_slow;
    catch
        disp(['error processing neuron  ', Antifilename   '  Dir=' num2str(Opp_Cue(n))])
    end
    try
        [psth_temp_fast psth_temp_slow] = Get_PsthM_fastslowRT(Antifilename,Opp_Cue(n)+8);
        psth5_fast(n,:) = psth_temp_fast;
        psth5_slow(n,:) = psth_temp_slow;
    catch
        disp(['error processing neuron  ', Antifilename   '  Dir=' num2str(Opp_Cue(n)+8)])
    end
    try
        [psth_temp_fast psth_temp_slow] = Get_PsthM_fastslowRT(Antifilename,Opp_Cue(n)+16);
        psth6_fast(n,:) = psth_temp_fast;
        psth6_slow(n,:) = psth_temp_slow;
    catch
        disp(['error processing neuron  ', Antifilename   '  Dir=' num2str(Opp_Cue(n)+16)])
    end
    
    try
        Propsth1(n,:) = Get_PsthM(Profilename,Best_Cue(n));
    catch
    end
    try
        Propsth2(n,:) = Get_PsthM(Profilename,Opp_Cue(n));
    catch
    end
    try
        Propsth3(n,:) = Get_PsthM(Profilename,RealBest_Cue(n));
    catch
    end
    try
        Propsth4(n,:) = Get_PsthM(Profilename,RealOpp_Cue(n));
    catch
    end
    %         meanvarfix1(n,:)= Neuron_Data_baseline(Antifilename,Best_Cue(n));
    
end


definepsthmax=50;
figure
% subplot(2,2,1)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;
hold on

lengthii=size(psth1_fast);
for ii=1:lengthii(1,1)
    if sum(psth1_fast(ii,:)) == 0
        psth1_fast(ii,:) = nan;
    end
end
lengthii=size(psth1_slow);
for ii=1:lengthii(1,1)
    if sum(psth1_slow(ii,:)) == 0
        psth1_slow(ii,:) = nan;
    end
end
lengthii=size(psth2_fast);
for ii=1:lengthii(1,1)
    if sum(psth2_fast(ii,:)) == 0
        psth2_fast(ii,:) = nan;
    end
end
lengthii=size(psth2_slow);
for ii=1:lengthii(1,1)
    if sum(psth2_slow(ii,:)) == 0
        psth2_slow(ii,:) = nan;
    end
end
lengthii=size(psth3_fast);
for ii=1:lengthii(1,1)
    if sum(psth3_fast(ii,:)) == 0
        psth3_fast(ii,:) = nan;
    end
end
lengthii=size(psth3_slow);
for ii=1:lengthii(1,1)
    if sum(psth3_slow(ii,:)) == 0
        psth3_slow(ii,:) = nan;
    end
end
psth1_fast = nanmean(psth1_fast);
psth1_slow = nanmean(psth1_slow);
psth2_fast = nanmean(psth2_fast);
psth2_slow = nanmean(psth2_slow);
psth3_fast = nanmean(psth3_fast);
psth3_slow = nanmean(psth3_slow);
plot(bins,psth1_slow,'b','LineWidth',2); % overlap
plot(bins,psth1_fast,'b--','LineWidth',2); % overlap
plot(bins,psth2_slow,'r','LineWidth',2); % zero gap
plot(bins,psth2_fast,'r--','LineWidth',2); % zero gap
plot(bins,psth3_slow,'g','LineWidth',2); % gap
plot(bins,psth3_fast,'g--','LineWidth',2); % gap
line([0 0], [0 60],'color','k')
axis([-0.8 1.5 0 definepsthmax+0.2])
xlabel('Time s')
ylabel('Firing Rate spikes/s')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
% subplot(2,2,3)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;
hold on
lengthii=size(psth4_fast);
for ii=1:lengthii(1,1)
    if sum(psth4_fast(ii,:)) == 0
        psth4_fast(ii,:) = nan;
    end
end
lengthii=size(psth4_slow);
for ii=1:lengthii(1,1)
    if sum(psth4_slow(ii,:)) == 0
        psth4_slow(ii,:) = nan;
    end
end
lengthii=size(psth5_fast);
for ii=1:lengthii(1,1)
    if sum(psth5_fast(ii,:)) == 0
        psth5_fast(ii,:) = nan;
    end
end
lengthii=size(psth5_slow);
for ii=1:lengthii(1,1)
    if sum(psth5_slow(ii,:)) == 0
        psth5_slow(ii,:) = nan;
    end
end
lengthii=size(psth6_fast);
for ii=1:lengthii(1,1)
    if sum(psth6_fast(ii,:)) == 0
        psth6_fast(ii,:) = nan;
    end
end
lengthii=size(psth6_slow);
for ii=1:lengthii(1,1)
    if sum(psth6_slow(ii,:)) == 0
        psth6_slow(ii,:) = nan;
    end
end
psth4_fast = nanmean(psth4_fast);
psth4_slow = nanmean(psth4_slow);
psth5_fast = nanmean(psth5_fast);
psth5_slow = nanmean(psth5_slow);
psth6_fast = nanmean(psth6_fast);
psth6_slow = nanmean(psth6_slow);
plot(bins,psth4_slow,'b','LineWidth',2); % overlap
plot(bins,psth4_fast,'b--','LineWidth',2); % overlap
plot(bins,psth5_slow,'r','LineWidth',2); % zero gap
plot(bins,psth5_fast,'r--','LineWidth',2); % zero gap
plot(bins,psth6_slow,'g','LineWidth',2); % gap
plot(bins,psth6_fast,'g--','LineWidth',2); % gap
line([0 0], [0 60],'color','k')
axis([-0.8 1.5 0 definepsthmax+0.2])
xlabel('Time s')
ylabel('Firing Rate spikes/s')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subplot(2,2,2)
% colors = 'rgb';
% bin_width = 0.05;  % 50 milliseconds bin
% bin_edges_Pro=-1:bin_width:3;
% bins_Pro = bin_edges_Pro+0.5*bin_width;
% 
% hold on
% Propsth1 = mean(Propsth1);
% Propsth2 = mean(Propsth2);
% plot(bins_Pro,Propsth1,'b','LineWidth',2);
% plot(bins_Pro,Propsth2,'r','LineWidth',2);
% line([0 0], [0 60],'color','k')
% line([.5 .5], [0 60],'color','k')
% axis([-1 3 0 definepsthmax+0.2])
% xlabel('Time s')
% ylabel('Firing Rate spikes/s')

% subplot(2,2,4)
% colors = 'rgb';
% bin_width = 0.05;  % 50 milliseconds bin
% bin_edges_Pro=-1:bin_width:2;
% bins_Pro = bin_edges_Pro+0.5*bin_width;
% 
% hold on
% Propsth3 = mean(Propsth3);
% Propsth4 = mean(Propsth4);
% plot(bins_Pro,Propsth3,'b','LineWidth',3);
% plot(bins_Pro,Propsth4,'r','LineWidth',3);
% maxpsth4=max([max(Propsth3) max(Propsth4)]);
% line([0 0], [0 60],'color','k')
% line([.5 .5], [0 60],'color','k')
% axis([-1 2 0 definepsthmax+0.2])
% xlabel('Time s')
% ylabel('Firing Rate spikes/s')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function max_results = Get_Maxes(Neurons)
max_result(1:length(Neurons),1:3) = NaN;
for n = 1:length(Neurons)
    Profilename = [Neurons{n,1},'_',num2str(Neurons{n,2})];
    Antifilename = [Neurons{n,1}([1:6]),'_2_',num2str(Neurons{n,2})];
    temp = Neuron_Data_Maxcuerate_ProFrom4LOC(Profilename,Antifilename);
    max_results(n,1:length(temp)) = temp(1);
end

function Realmax_results = Get_RealMaxes(Neurons)
Realmax_result(1:length(Neurons),1:3) = NaN;
for n = 1:length(Neurons)
    filename = [Neurons{n,1},'_',num2str(Neurons{n,2})];    
    temp = Neuron_Data_Maxcuerate_ProFrom8LOC(filename);
    Realmax_results(n,1:length(temp)) = temp(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psth_temp = Get_PsthM(filename,class_num)     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%change
load(filename)
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;
bin_edges_Pro=-1:bin_width:3;
bins_Pro = bin_edges_Pro+0.5*bin_width;

allTS = [];
m_counter = 0;
if length(MatData.class)>8 %24  % AntiSac
    if ~isempty(MatData)
        for m = 1:length(MatData.class(class_num).ntr)
            if ~isempty(MatData.class(class_num).ntr(m).alignSac_onT)
                try

                    TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).Cue_onT;
                    allTS = [allTS TS];
                    m_counter = m_counter + 1;
                catch
                end
            end
        end
        ntrs = m_counter;
    else
        disp('Empty MatData File!!!');
    end
    psth_temp =histc(allTS,bin_edges)/(bin_width*ntrs);
end

if length(MatData.class)== 8  % ProSac
    if ~isempty(MatData)
        for m = 1:length(MatData.class(class_num).ntr)
            try
                TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).Cue_onT;

                allTS = [allTS TS];
                m_counter = m_counter + 1;
            catch
            end
        end
        ntrs = m_counter;
    else
        disp('Empty MatData File!!!');
    end
    psth_temp =histc(allTS,bin_edges_Pro)/(bin_width*ntrs);
end

function [psth_temp_fast psth_temp_slow] = Get_PsthM_fastslowRT(filename,class_num)     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%change
load(filename)
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;

allTS_fast = [];
m_counter_fast = 0;
allTS_slow = [];
m_counter_slow = 0;

fastThreshold = .25;
slowThreshold = .25;
if length(MatData.class)>8 %24  % AntiSac
    if ~isempty(MatData)
        for m = 1:length(MatData.class(class_num).ntr)
            if MatData.class(class_num).ntr(m).RT <= fastThreshold
                if ~isempty(MatData.class(class_num).ntr(m).Saccade_onT)
                    try    
                        TS=[];
                        TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).Cue_onT;
                        allTS_fast = [allTS_fast TS];
                        m_counter_fast = m_counter_fast + 1;
                    catch
                    end
                end                
            end
            if MatData.class(class_num).ntr(m).RT > slowThreshold
                if ~isempty(MatData.class(class_num).ntr(m).Saccade_onT)
                    try  
                        TS=[];
                        TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).Cue_onT;
                        allTS_slow = [allTS_slow TS];
                        m_counter_slow = m_counter_slow + 1;
                    catch
                    end
                end                
            end
        end
        ntrs_fast = m_counter_fast;
        ntrs_slow = m_counter_slow;
    else
        disp('Empty MatData File!!!');
    end
%     if (ntrs_fast == 0) | (ntrs_slow ==0)
%         psth_temp_fast =[];
%         psth_temp_slow =[];
%     else
        psth_temp_fast =histc(allTS_fast,bin_edges)/(bin_width*ntrs_fast);
        psth_temp_slow =histc(allTS_slow,bin_edges)/(bin_width*ntrs_slow);
%     end
end



