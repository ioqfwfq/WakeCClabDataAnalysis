
[Neurons_num, Neurons_txt] = xlsread('C:\Users\juzhu\Documents\MATLAB\beh_data_files\index.xlsx','uni');
warning off MATLAB:divideByZero
p_correct1=[];
for n = 1: length(Neurons_txt)
    stcd=[];
    filenameday=[Neurons_txt{n} '_'];
    f=dir([filenameday '*.mat']);
    flist={f.name};
    for ses = 1:length(flist)
        filename = string(flist(ses));
        stcd1 = beh_performance_ODRrecording(filename);
        stcd = [stcd stcd1];
    end
    
    if length(find(stcd==7))+length(find(stcd==6))==0
        p_correct1(n) = 0;
    else
        p_correct1(n) = length(find(stcd==7))/(length(find(stcd==7))+length(find(stcd==6)));
    end
end