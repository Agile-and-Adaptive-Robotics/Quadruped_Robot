% Nicholas Szczecinski 2019
% 11 Feb 19
% CWRU EMAE 689, Synthetic Nervous Systems

close all

%Units are nF, uS, mV, ms, nA
Cm = 20;
Gm = 1;
b = 100e-3;
Er = -60;
dtExact = .1;
dtSim = 1;
tmax = 200;

tExact = 0:dtExact:tmax;
tSim = 0:dtSim:tmax;
numSteps = length(tSim);

Iapp = b*tSim;

%First, compute V(t) explicitly
tau = Cm/Gm;
% Uexp = Iapp/Gm*(1-exp(-t/tau));
Uexp = b*(tExact - tau) + b*tau*exp(-tExact/tau);
Vexp = Uexp + Er;

%Next, compute V(t) with simulation
Usim = zeros(size(tSim));
Usim(1) = 0;

for i=2:numSteps
    Usim(i) = Usim(i-1) + dtSim/Cm*(Iapp(i-1) - Gm*Usim(i-1));
end
Vsim = Usim + Er;

figure
subplot(3,1,1)
plot(tSim,Iapp+zeros(size(tSim)),'linewidth',2)
ylabel('I_{app} (nA)')

subplot(3,1,2)
plot(tExact,Uexp,'linewidth',2)
hold on
plot(tSim,Usim,'linewidth',1)
plot(tSim,Iapp,'k')
ylabel('U (mV)')
legend('explicit','simulated','I_{app}/G_m')
grid on

subplot(3,1,3)
plot(tSim,(Iapp/Gm - Usim)/b,'linewidth',2)
hold on
pp = plot(tSim,Cm+zeros(size(tSim)),'--');
legend(pp,'\tau_m')
ylabel('(I_{app}/G_m - U)/b (mV)')
xlabel('time (ms)')
