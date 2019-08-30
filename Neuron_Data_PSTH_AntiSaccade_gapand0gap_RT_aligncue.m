% for AntiSaccade task
% plot result from zero gap and gap trials together(4 groups of RT, 1 condition for each group)
% align by cue
% last edit 30-Aug-2019, J Zhu


[Neurons_num Neurons_txt] = xlsread('test.xlsx','adult');
warning off MATLAB:divideByZero
Neurons = [Neurons_txt(:,1) num2cell(Neurons_num(:,1))];

Best_Cue = Get_Maxes(Neurons);
Best_target = Get_Maxes_sac(Neurons);
opp_index = [5 6 7 8 1 2 3 4 9];
for n = 1:length(Best_Cue)
    Opp_Cue(n) = opp_index(Best_Cue(n));
end

for n = 1:length(Neurons)
    Antifilename = [Neurons{n,1}([1:6]),'_2_',num2str(Neurons{n,2})];
    Profilename = [Neurons{n,1}([1:6]),'_1_',num2str(Neurons{n,2})];
    try
        [psth_temp1, psth_temp2, psth_temp3, psth_temp4, ntrs_temp] = Get_PsthM_RT(Antifilename,Best_Cue(n)+8);
        psth1(n,:) = psth_temp1;
        psth3(n,:) = psth_temp2;
        psth5(n,:) = psth_temp3;
        psth7(n,:) = psth_temp4;
        ntrs1(n,:) = ntrs_temp;
    catch
        disp(['error processing neuron  ', Antifilename  '  Dir=' num2str(Best_Cue(n))+8])
    end
    try
        [psth_temp1, psth_temp2, psth_temp3, psth_temp4, ntrs_temp] = Get_PsthM_RT(Antifilename,Best_Cue(n)+16);
        psth2(n,:) = psth_temp1;
        psth4(n,:) = psth_temp2;
        psth6(n,:) = psth_temp3;
        psth8(n,:) = psth_temp4;
        ntrs2(n,:) = ntrs_temp;
    catch
        disp(['error processing neuron  ', Antifilename  '  Dir=' num2str(Best_Cue(n))+16])
    end
end

psth1all = [psth1;psth2];
psth2all = [psth3;psth4];
psth3all = [psth5;psth6];
psth4all = [psth7;psth8];
ntrs=[ntrs1;ntrs2];
nn=sum(ntrs~=0);
ntrs=sum(ntrs);
definepsthmax=50;

fig=openfig('figure2');
% figure
% set( gcf, 'Color', 'White', 'Unit', 'Normalized', ...
%     'Position', [0.1,0.1,0.6,0.6] ) ;
subplot(2,4,1)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;
hold on
try
    psth1mean = sum(psth1all)/nn(1);
catch
end
try
    plot(bins,psth1mean,'r','LineWidth',3); % best target
catch
end
try
    maxpsth1=max(psth1mean);
catch
end
line([0 0], [0 50],'color','k')
axis([-0.5 1.5 0 definepsthmax+0.2])
xlim([-0.5 0.5])
xlabel('Time s')
ylabel('Firing Rate spikes/s')
title(['0-0.075s n= ' num2str(nn(1)) ' neurons ' num2str(ntrs(1)) ' trials'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,4,2)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;
hold on

try
    psth2mean = sum(psth2all)/nn(2);
catch
end
try
    plot(bins,psth2mean,'r','LineWidth',3);
catch
end
try
    maxpsth2=max(psth2mean);
catch
end
line([0 0], [0 50],'color','k')
axis([-0.5 1.5 0 definepsthmax+0.2])
xlim([-0.5 0.5])
xlabel('Time s')
ylabel('Firing Rate spikes/s')
title(['0.075-0.120s n = ' num2str(nn(2)) ' neurons ' num2str(ntrs(2)) ' trials'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,4,3)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;
hold on

try
    psth3mean = sum(psth3all)/nn(3);
catch
end
try
    plot(bins,psth3mean,'r','LineWidth',3);
catch
end
try
    maxpsth3=max(psth3mean);
catch
end
line([0 0], [0 50],'color','k')
axis([-0.5 1.5 0 definepsthmax+0.2])
xlim([-0.5 0.5])
xlabel('Time s')
ylabel('Firing Rate spikes/s')
title(['0.120-0.150s n = ' num2str(nn(3)) ' neurons ' num2str(ntrs(3)) ' trials'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,4,4)
colors = 'rgb';
bin_width = 0.05;  % 50 milliseconds bin
bin_edges=-.8:bin_width:1.5;
bins = bin_edges+0.5*bin_width;
hold on

try
    psth4mean = sum(psth4all)/nn(4);
catch
end
try
    plot(bins,psth4mean,'r','LineWidth',3);
catch
end
try
    maxpsth4=max(psth4mean);
catch
end
line([0 0], [0 50],'color','k')
axis([-0.5 1.5 0 definepsthmax+0.2])
xlim([-0.5 0.5])
xlabel('Time s')
ylabel('Firing Rate spikes/s')
title(['>0.150s n = ' num2str(nn(4)) ' neurons ' num2str(ntrs(4)) ' trials'])

axes( 'Position', [0, 0.95, 1, 0.05] ) ;
set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None' ) ;
text( 0.5, 0, 'Zero gap and gap trials All neurons AlignCue', 'FontSize', 12', 'FontWeight', 'Bold', ...
    'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' )
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
function max_results = Get_Maxes_sac(Neurons)
max_result(1:length(Neurons),1:3) = NaN;
for n = 1:length(Neurons)
    Profilename = [Neurons{n,1}([1:6]),'_1_',num2str(Neurons{n,2})];
    Antifilename = [Neurons{n,1}([1:6]),'_2_',num2str(Neurons{n,2})];
    temp = Neuron_Data_Maxsacrate_ProFrom4LOC(Profilename,Antifilename);
    max_results(n,1:length(temp)) = temp(1);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [psth_temp1, psth_temp2, psth_temp3, psth_temp4, ntrs_temp] = Get_PsthM_RT(filename,class_num)
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
    ntrs_temp = [ntrs1 ntrs2 ntrs3 ntrs4];
end
end