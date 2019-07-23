function stcd= beh_performance_ODRtraining(filename)
% loc=NaN(numel([AllData.block]),8);
ch = load(filename);
MatData=ch.AllData;
stcd=NaN(numel([MatData.block]),8);

for i =1:numel([MatData.block])
    for j = 1:numel([MatData.block(i).trial])
        if isfield(MatData.block(i).trial(j),'degree') && isfield(MatData.block(i).trial(j),'Statecode')
            if isempty(MatData.block(i).trial(j).degree)==0 && isempty(MatData.block(i).trial(j).Statecode)==0
                %             loc(i,j)=AllData.block(i).trial(j).degree;
                stcd(i,j)=MatData.block(i).trial(j).Statecode;
            else
                %             loc(i,j)=nan;
                stcd(i,j)=nan;
            end
        end
    end
end