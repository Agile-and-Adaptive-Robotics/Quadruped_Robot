dataN1 = data-data(1);
dataN1 = dataN1/dataN1(end);
%%
dataN2 = data - data(1);
dataN2 = dataN2/dataN2(end);
%%
dataN3 = data - data(1);
dataN3 = dataN3/dataN3(end);
%%
dataN4 = data - data(1);
dataN4 = dataN4/dataN4(end);
%%
figure
hold on
plot(dataN1)
plot(dataN2)
plot(dataN3)
plot(dataN4)
ylabel('Angular Deflection (º)')
xlabel('Time (ms x10)')
legend('test 1','test 2', 'test 3')
xlim([0 300])