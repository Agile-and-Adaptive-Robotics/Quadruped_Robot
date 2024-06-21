dataSpring(:,32) = data;

%%
for ii = 1:32
    figure
    plot(dataSpring(:,ii))
    xlim([0 300])
    title(ii)
end