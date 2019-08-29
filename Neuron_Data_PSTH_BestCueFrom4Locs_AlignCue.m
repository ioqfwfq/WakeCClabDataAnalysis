% function Neuron_Data_PSTH_BestCueFrom4Locs_AlignCue(Excel_neurons)
% for AntiSaccade task
% find best cue location for ProSac, then plot bestcue trials for AntiSac (3 conditions)
% 10-Oct-2011, xzhou

[Neurons_num Neurons_txt] = xlsread(['test.xlsx']);
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
    Profilename = [Neurons{n,1}([1:6]),'_1_',num2str(Neurons{n,2})];
    try
        psth1(n,:) = Get_PsthM(Antifilename,Best_Cue(n));
        meanvarfix1(n,:)= Neuron_Data_baseline(Antifilename,Best_Cue(n));
    catch
        disp(['error processing neuron  ', Antifilename   '  Dir=' num2str(Best_Cue(n))])
    end
    try
        psth2(n,:) = Get_PsthM(Antifilename,Best_Cue(n)+8);
        meanvarfix2(n,:)= Neuron_Data_baseline(Antifilename,Best_Cue(n)+8);
    catch
        disp(['error processing neuron  ', Antifilename   '  Dir=' num2str(Best_Cue(n)+8)])
    end
    try
        psth3(n,:) = Get_PsthM(Antifilename,Best_Cue(n)+16);
        meanvarfix3(n,:)= Neuron_Data_baseline(Antifilename,Best_Cue(n)+16);
    catch
        disp(['error processing neuron  ', Antifilename   '  Dir=' num2str(Best_Cue(n)+16)])
    end
    try
        psth4(n,:) = Get_PsthM(Antifilename,Opp_Cue(n));
        meanvarfix4(n,:)= Neuron_Data_baseline(Antifilename,Opp_Cue(n));
    catch
        disp(['error processing neuron  ', Antifilename   '  Dir=' num2str(Opp_Cue(n))])
    end
    try
        psth5(n,:) = Get_PsthM(Antifilename,Opp_Cue(n)+8);
        meanvarfix5(n,:)= Neuron_Data_baseline(Antifilename,Opp_Cue(n)+8);
    catch
        disp(['error processing neuron  ', Antifilename   '  Dir=' num2str(Opp_Cue(n)+8)])
    end
    try
        psth6(n,:) = Get_PsthM(Antifilename,Opp_Cue(n)+16);
        meanvarfix6(n,:)= Neuron_Data_baseline(Antifilename,Opp_Cue(n)+16);
    catch
        disp(['error processing neuron  ', Antifilename   '  Dir=' num2str(Opp_Cue(n)+16)])
    end
    try
        Propsth1(n,:) = Get_PsthM(Profilename,Best_Cue(n));
        promeanvarfix1(n,:)= Neuron_Data_baseline(Profilename,Best_Cue(n));
    catch
    end
    try
        Propsth2(n,:) = Get_PsthM(Profilename,Opp_Cue(n));
        promeanvarfix2(n,:)= Neuron_Data_baseline(Profilename,Opp_Cue(n));
    catch
    end
    try
        Propsth3(n,:) = Get_PsthM(Profilename,RealBest_Cue(n));
        promeanvarfix3(n,:)= Neuron_Data_baseline(Profilename,RealBest_Cue(n));
       
    catch
    end
    try
        Propsth4(n,:) = Get_PsthM(Profilename,RealOpp_Cue(n));
        promeanvarfix4(n,:)= Neuron_Data_baseline(Profilename,RealOpp_Cue(n));
    catch
    end
   
end


definepsthmax=45;
figure
meanvarfix1=mean(meanvarfix1);
meanvarfix2=mean(meanvarfix2);
meanvarfix3=mean(meanvarfix3);
meanvarfix123 = mean([meanvarfix1 meanvarfix2 meanvarfix3]);

meanvarfix4=mean(meanvarfix4);
meanvarfix5=mean(meanvarfix5);
meanvarfix6=mean(meanvarfix6);
meanvarfix456 = mean([meanvarfix4 meanvarfix5 meanvarfix6]);

promeanvarfix1=mean(promeanvarfix1);
promeanvarfix2=mean(promeanvarfix2);
promeanvarfix3=mean(promeanvarfix3);
promeanvarfix4=mean(promeanvarfix4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,2,1)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-1:bin_width:1.5;   % -0.8
bins = bin_edges+0.5*bin_width;

hold on
psth1 = mean(psth1);
psth2 = mean(psth2);
psth3 = mean(psth3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Normalize firingrate from baseline %%%%%%%
% psth1 = psth1/meanvarfix1;
% psth2 = psth2/meanvarfix2;
% psth3 = psth3/meanvarfix3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot(bins,psth1,'b','LineWidth',1.5)%,'linestyle','- -'); % overlap
plot(bins,psth2,'r','LineWidth',1.5)%,'linestyle','- -'); % zero gap
plot(bins,psth3,'g','LineWidth',1.5)%,'linestyle','- -'); % gap
maxpsth1=max([max(psth1) max(psth2) max(psth3)]);
% baseline = ones(1,length(bins));
% plot(bins,baseline,'k--','LineWidth',2);
line(bin_edges,meanvarfix123*ones(1,length(bin_edges)),'linestyle','- -','color','k');
% line(bin_edges,meanvarfix2*ones(1,length(bin_edges)),'linestyle','- -','color','r');
line([0 0], [0 60],'color','k')
% line([0.08 0.08], [0 60],'color','k')
axis([-1 1.5 0 definepsthmax+0.2])
xlabel('Time s')
ylabel('Firing Rate spikes/s')
% ylim([0 4])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,2,3)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-1:bin_width:1.5;
bins = bin_edges+0.5*bin_width;

hold on
psth4 = mean(psth4);
psth5 = mean(psth5);
psth6 = mean(psth6);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%% Normalize firingrate from baseline %%%%%%%
% psth4 = psth4/meanvarfix4;
% psth5 = psth5/meanvarfix5;
% psth6 = psth6/meanvarfix6;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot(bins,psth4,'b','LineWidth',1.5)%,'linestyle','- -'); % overlap
plot(bins,psth5,'r','LineWidth',1.5)%,'linestyle','- -'); % zero gap
plot(bins,psth6,'g','LineWidth',1.5)%,'linestyle','- -'); % gap
maxpsth2=max([max(psth4) max(psth5) max(psth6)]);
% baseline = ones(1,length(bins));
% plot(bins,baseline,'k--','LineWidth',2);
line(bin_edges,meanvarfix456*ones(1,length(bin_edges)),'linestyle','- -','color','k');
line([0 0], [0 50],'color','k')
axis([-1 1.5 0 definepsthmax+0.2])
xlabel('Time s')
ylabel('Firing Rate spikes/s')
% ylim([0 4])
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,2,2)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges_Pro=-1:bin_width:3;
bins_Pro = bin_edges_Pro+0.5*bin_width;

hold on
Propsth1 = mean(Propsth1);
Propsth2 = mean(Propsth2);
plot(bins_Pro,Propsth1,'b','LineWidth',1.5)%,'linestyle','- -');
plot(bins_Pro,Propsth2,'r','LineWidth',1.5)%,'linestyle','- -');
maxpsth3=max([max(Propsth1) max(Propsth2)]);
line([0 0], [0 60],'color','k')
line([2 2], [0 60],'color','k')
axis([-1 3 0 definepsthmax+0.2])
xlabel('Time s')
ylabel('Firing Rate spikes/s')
subplot(2,2,4)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges_Pro=-1:bin_width:3;
bins_Pro = bin_edges_Pro+0.5*bin_width;

hold on
Propsth3 = mean(Propsth3);
Propsth4 = mean(Propsth4);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%% Normalize firingrate from baseline %%%%%%%
% Propsth3 = Propsth3/promeanvarfix3;
% Propsth4 = Propsth4/promeanvarfix4;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(bins_Pro,Propsth3,'b','LineWidth',1.5)%,'linestyle','- -');
plot(bins_Pro,Propsth4,'r','LineWidth',1.5)%,'linestyle','- -');
maxpsth4=max([max(Propsth3) max(Propsth4)]);
line([0 0], [0 60],'color','k')
% line([1 1], [0 60],'color','k')
line([2 2], [0 60],'color','k')
% baseline = ones(1,length(bins_Pro));
% plot(bins_Pro,baseline,'k--','LineWidth',2);
axis([-1 3 0 definepsthmax+0.2])
xlabel('Time s')
ylabel('Firing Rate spikes/s')
% ylim([0 4])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function max_results = Get_Maxes(Neurons)
max_result(1:length(Neurons),1:3) = NaN;
for n = 1:length(Neurons)
    Profilename = [Neurons{n,1}([1:6]),'_1_',num2str(Neurons{n,2})];
    Antifilename = [Neurons{n,1}([1:6]),'_2_',num2str(Neurons{n,2})];  
    temp = Neuron_Data_Maxcuerate_ProFrom4LOC(Profilename,Antifilename);
    max_results(n,1:length(temp)) = temp(1);
end
end

function Realmax_results = Get_RealMaxes(Neurons)
Realmax_result(1:length(Neurons),1:3) = NaN;
for n = 1:length(Neurons)
    filename = [Neurons{n,1}([1:6]),'_1_',num2str(Neurons{n,2})];
    temp = Neuron_Data_Maxcuerate_ProFrom8LOC(filename);
    Realmax_results(n,1:length(temp)) = temp(1);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function psth_temp = Get_PsthM(filename,class_num)     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%change
load(filename)
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-1:bin_width:1.5;
bins = bin_edges+0.5*bin_width;
bin_edges_Pro=-1:bin_width:3;
bins_Pro = bin_edges_Pro+0.5*bin_width;

allTS = [];
m_counter = 0;
if length(MatData.class)>8 %24  % AntiSac
    if ~isempty(MatData)
        for m = 1:length(MatData.class(class_num).ntr)
            if ~isempty(MatData.class(class_num).ntr(m).Saccade_onT)
                try
%                     TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).alignR_onT;
%                     TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).alignSac_onT;
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
%                 TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).alignSac_onT;
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
end


function meanvarfix = Neuron_Data_baseline(filename,class_num)
load(filename)

meanvarfix= mean([MatData.class(class_num).ntr.fixrate]);

end


