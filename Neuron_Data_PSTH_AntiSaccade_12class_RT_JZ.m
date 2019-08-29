% for AntiSaccade task
% plot all 12 classes for AntiSac (4 groups of RT, 3 condition for each group)
% 10-Oct-2011, xzhou
% 20-Aug-2019, J Zhu

[Neurons_num Neurons_txt] = xlsread(['test.xlsx']);
warning off MATLAB:divideByZero
Neurons = [Neurons_txt(:,1) num2cell(Neurons_num(:,1))];

Best_Cue = Get_Maxes(Neurons);
opp_index = [5 6 7 8 1 2 3 4 9];
for n = 1:length(Best_Cue)
    Opp_Cue(n) = opp_index(Best_Cue(n));
end

Directions = Get_Dir(Neurons);

for n = 1:length(Neurons)
    Dirs = Directions(n,:);
    Dirs = Dirs([1:4]);
    Antifilename = [Neurons{n,1}([1:6]),'_2_',num2str(Neurons{n,2})];
    Profilename = [Neurons{n,1}([1:6]),'_1_',num2str(Neurons{n,2})];
    indx = ismember(Dirs,[Best_Cue(n) Opp_Cue(n)]);
    MidDir = Dirs(find(indx == 0));
    try
        [psth_temp1, psth_temp2, psth_temp3, psth_temp4] = Get_PsthM_RT(Antifilename,Best_Cue(n));
        psth1(n,:) = psth_temp1;
        psth4(n,:) = psth_temp2;
        psth7(n,:) = psth_temp3;
        psth10(n,:) = psth_temp4;
    catch
        disp(['error processing neuron  ', Antifilename  '  Dir=' num2str(Best_Cue(n))])
    end
    try
        [psth_temp1, psth_temp2, psth_temp3, psth_temp4] = Get_PsthM_RT(Antifilename,Best_Cue(n)+8);
        psth2(n,:) = psth_temp1;
        psth5(n,:) = psth_temp2;
        psth8(n,:) = psth_temp3;
        psth11(n,:) = psth_temp4;
    catch
        disp(['error processing neuron  ', Antifilename  '  Dir=' num2str(Best_Cue(n)+8)])
    end
    try
        [psth_temp1, psth_temp2, psth_temp3, psth_temp4] = Get_PsthM_RT(Antifilename,Best_Cue(n)+16);
        psth3(n,:) = psth_temp1;
        psth6(n,:) = psth_temp2;
        psth9(n,:) = psth_temp3;
        psth12(n,:) = psth_temp4;
    catch
        disp(['error processing neuron  ', Antifilename  '  Dir=' num2str(Best_Cue(n)+16)])
    end
end


definepsthmax=50;
figure
subplot(2,2,1)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;
hold on
try
    psth1 = mean(psth1);
catch
end
try
    psth2 = mean(psth2);
catch
end
try
    psth3 = mean(psth3);
catch
end

% meanvarfix1=mean(meanvarfix1);
% meanvarfix2=mean(meanvarfix2);
try
    plot(bins,psth1,'b','LineWidth',3); % overlap
catch
end
try
    plot(bins,psth2,'r','LineWidth',3); % zero gap
catch
end
try
    plot(bins,psth3,'g','LineWidth',3); % gap
catch
end
try
    maxpsth1=max([max(psth1) max(psth2) max(psth3)]);
catch
end
% line(bin_edges,meanvarfix1*ones(1,length(bin_edges)),'linestyle','- -','color','b');
% line(bin_edges,meanvarfix2*ones(1,length(bin_edges)),'linestyle','- -','color','r');
line([0 0], [0 50],'color','k')
axis([-0.5 1.5 0 definepsthmax+0.2])
xlabel('Time s')
ylabel('Firing Rate spikes/s')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,2,4)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;

hold on

try
    psth4 = mean(psth4);
catch
end
try
    psth5 = mean(psth5);
catch
end
try
    psth6 = mean(psth6);
catch
end
try
    plot(bins,psth4,'b','LineWidth',3); %overlap
catch
end
try
    plot(bins,psth5,'r','LineWidth',3); % zero gap
catch
end
try
    plot(bins,psth6,'g','LineWidth',3); % gap
catch
end
try
    maxpsth2=max([max(psth4) max(psth5) max(psth6)]);
catch
end
line([0 0], [0 50],'color','k')
axis([-0.5 1.5 0 definepsthmax+0.2])
xlabel('Time s')
ylabel('Firing Rate spikes/s')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,2,2)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;

hold on
try
    psth7 = mean(psth7);
catch
end
try
    psth8 = mean(psth8);
catch
end
try
    psth9 = mean(psth9);
catch
end
try
    plot(bins,psth7,'b','LineWidth',3); %overlap
catch
end
try
    plot(bins,psth8,'r','LineWidth',3); % zero gap
catch
end
try
    plot(bins,psth9,'g','LineWidth',3); % gap
catch
end
try
    maxpsth2=max([max(psth7) max(psth8) max(psth9)]);
catch
end
line([0 0], [0 50],'color','k')
axis([-0.5 1.5 0 definepsthmax+0.2])
xlabel('Time s')
ylabel('Firing Rate spikes/s')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,2,3)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;

hold on
try
    psth10 = mean(psth10);
catch
end
try
    psth11 = mean(psth11);
catch
end
try
    psth12 = mean(psth12);
catch
end
try
    plot(bins,psth10,'b','LineWidth',3); %overlap
catch
end
try
    plot(bins,psth11,'r','LineWidth',3); % zero gap
catch
end
try
    plot(bins,psth12,'g','LineWidth',3); % gap
catch
end
try
    maxpsth2=max([max(psth10) max(psth11) max(psth12)]);
catch
end
line([0 0], [0 50],'color','k')
axis([-0.5 1.5 0 definepsthmax+0.2])
xlabel('Time s')
ylabel('Firing Rate spikes/s')

% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Directions = Get_Dir(Neurons)
Directions(1:length(Neurons),1:12) = NaN;
for n = 1:length(Neurons)
    Antifilename = [Neurons{n,1}([1:6]),'_2_',num2str(Neurons{n,2})];
    fn_matext = ([Antifilename([1:8]),'.mat']);
    load(fn_matext);
    Direction= unique([AllData.trials(:).Class]);
    Directions(n,1:12) = Direction(1:12);
end
end

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
if length(MatData.class)> 8  % 24  AntiSac
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
end
function [psth_temp1, psth_temp2, psth_temp3, psth_temp4] = Get_PsthM_RT(filename,class_num)     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%change
load(filename)
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;

allTS1 = []; % 0-0.075s
allTS2 = []; % 0.075-0.120s
allTS3 = []; % 0.120-0.150s
allTS4 = []; % >0.150s
m_counter1 = 0;
m_counter2 = 0;
m_counter3 = 0;
m_counter4 = 0;

Threshold1 = 0.075;
Threshold2 = 0.12;
Threshold3 = 0.15;

if length(MatData.class)>8 %24  % AntiSac
    if ~isempty(MatData)
        for m = 1:length(MatData.class(class_num).ntr)
            if MatData.class(class_num).ntr(m).RT < Threshold1
                if ~isempty(MatData.class(class_num).ntr(m).Saccade_onT)
                    try
                        TS=[];
                        TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).Cue_onT;
                        allTS1 = [allTS1 TS];
                        m_counter1 = m_counter1 + 1;
                    catch
                    end
                end
            end
            if MatData.class(class_num).ntr(m).RT >= Threshold1 && MatData.class(class_num).ntr(m).RT < Threshold2
                if ~isempty(MatData.class(class_num).ntr(m).Saccade_onT)
                    try
                        TS=[];
                        TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).Cue_onT;
                        allTS2 = [allTS2 TS];
                        m_counter2 = m_counter2 + 1;
                    catch
                    end
                end
            end
            if  MatData.class(class_num).ntr(m).RT >= Threshold2 && MatData.class(class_num).ntr(m).RT < Threshold3
                if ~isempty(MatData.class(class_num).ntr(m).Saccade_onT)
                    try
                        TS=[];
                        TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).Cue_onT;
                        allTS3 = [allTS3 TS];
                        m_counter3 = m_counter3 + 1;
                    catch
                    end
                end
            end
            if MatData.class(class_num).ntr(m).RT >= Threshold3
                if ~isempty(MatData.class(class_num).ntr(m).Saccade_onT)
                    try
                        TS=[];
                        TS = MatData.class(class_num).ntr(m).TS-MatData.class(class_num).ntr(m).Cue_onT;
                        allTS4 = [allTS4 TS];
                        m_counter4 = m_counter4 + 1;
                    catch
                    end
                end
            end
        end
        ntrs1 = m_counter1;
        ntrs2 = m_counter2;
        ntrs3 = m_counter3;
        ntrs4 = m_counter4;
    else
        disp('Empty MatData File!!!');
    end

    psth_temp1 =histc(allTS1,bin_edges)/(bin_width*ntrs1);
    if isempty(psth_temp1)
        psth_temp1 = zeros(1,47);
    end
    psth_temp2 =histc(allTS2,bin_edges)/(bin_width*ntrs2);
        if isempty(psth_temp2)
        psth_temp2 = zeros(1,47);
    end
    psth_temp3 =histc(allTS3,bin_edges)/(bin_width*ntrs3);
        if isempty(psth_temp3)
        psth_temp3 = zeros(1,47);
    end
    psth_temp4 =histc(allTS4,bin_edges)/(bin_width*ntrs4);
        if isempty(psth_temp4)
        psth_temp4 = zeros(1,47);
    end
end
end