function max_class = Neuron_Data_Maxcuerate_ProFrom4LOC(Profilename,Antifilename)
% last edited(24-Oct-2011),xzhou
try
    load(Antifilename)
    for ij = 1:length(MatData.class)
        if ~isempty(MatData.class(ij).ntr)
            if mod(ij,2)== 1
                Dirs = [1 3 5 7];
                break;
            else
                Dirs = [2 4 6 8];
                break;
            end
        end
    end
    clear MatData
    load(Profilename)
    if length(MatData.class)==8
        if ~isempty(MatData)
            try
                for n = Dirs
                    var(n) = mean([MatData.class(n).ntr.cuerate]);
                end
                temp_class = find(var == max(var([Dirs])));
                max_class(1) = temp_class(1);
                max_class(2) = var(temp_class(1));
            catch
                max_class = nan(1,2);
                
            end
        else
            max_class = nan(1,2);
        end
    else
        disp('wrong prosac total classes')
    end
    
catch
    lasterr
end