hcg = get(0,'children');
hcg = sort(hcg);
for n = 1:length(hcg)
    figure(hcg(n))
    axis([1 70 -10000 10000])
end