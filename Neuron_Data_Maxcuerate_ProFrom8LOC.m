
%max_class(1): class #
%max_class(2): maximum mean cuerate

function max_class = Neuron_Data_Maxcuerate_ProFrom8LOC(filename)
load(filename)
if ~isempty(MatData)
    for n = 1:8
        var(n) = 0;
        if length(MatData.class(n).ntr)>0
            var(n)=mean([MatData.class(n).ntr.cuerate]);
        end
    end
    temp_class = find(var == max(var));
    max_class(1) = temp_class(1);
    max_class(2) = var(temp_class(1));    
else
    max_class = [];

end