function stcd= beh_performance_ODRrecording(filename)
% loc=[];
ch = load(filename);
MatData=ch.AllData;
stcd=[];

for i =1:numel([MatData.trials])
    if isfield(MatData.trials(i),'Class') && isfield(MatData.trials(i),'Statecode')
        if isempty(MatData.trials(i).Class)==0 && isempty(MatData.trials(i).Statecode)==0
            %             loc(i)=AllData.trials(i).Class;
            stcd(i)=MatData.trials(i).Statecode;
        else
            %             loc(i)=nan;
            stcd(i)=nan;
        end
    end
end