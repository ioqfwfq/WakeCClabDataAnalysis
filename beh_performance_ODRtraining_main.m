% clear
[Neurons_num, Neurons_txt] = xlsread('C:\Users\juzhu\Documents\MATLAB\beh_data_files\index.xlsx','uni');
warning off MATLAB:divideByZero
p_correct=[];
for n = 1: length(Neurons_txt)
    stcd=[];
    filenameday=[Neurons_txt{n} '_'];
    f=dir([filenameday '*.mat']);
    flist={f.name};
    for ses = 1:length(flist)
        filename = string(flist(ses));
        stcd1 = beh_performance_ODRtraining(filename);
        stcd = [stcd; stcd1];
    end
    p_correct(n) = length(find(stcd==5))/(length(find(stcd==5))+length(find(stcd==4)));
end