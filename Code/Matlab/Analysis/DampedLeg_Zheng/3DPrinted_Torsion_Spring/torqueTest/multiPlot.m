t = linspace(0,length(S2L3LT4ST37T.T20.CW.trial1)/100,length(S2L3LT4ST37T.T20.CW.trial1));

figure
hold on
for ii = 1:2:7
    field = strcat('trial',num2str(ii));
    data = S2L3LT4ST37T.T20.CCW.(field);
    plot(t,data);
end
hold off

figure
hold on
for ii = 2:2:8
    field = strcat('trial',num2str(ii));
    data = S2L3LT4ST37T.T20.CCW.(field);
    plot(t,data);
end
hold off