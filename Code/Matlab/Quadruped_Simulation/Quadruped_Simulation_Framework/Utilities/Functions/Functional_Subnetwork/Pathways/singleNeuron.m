% Nicholas Szczecinski 2019
% 23 Jan 19
% CWRU EMAE 689, Synthetic Nervous Systems

%Units are nF, uS, mV, ms, nA
Cm = 10;
Gm = 1;
Iapp = 10;
Er = -60;
dt = .1;
tmax = 100;

t = 0:dt:tmax;
numSteps = length(t);

%First, compute V(t) explicitly
tau = Cm/Gm;
Uexp = Iapp/Gm*(1-exp(-t/tau));
Vexp = Uexp + Er;

%Next, compute V(t) with simulation
Usim = zeros(size(t));
Usim(1) = 0;

for i=2:numSteps
    Usim(i) = Usim(i-1) + dt/Cm*(Iapp - Gm*Usim(i-1));
end
Vsim = Usim + Er;

figure
subplot(4,1,1)
plot(t,Iapp+zeros(size(t)),'linewidth',2)
ylabel('I_{app} (nA)')

subplot(4,1,2)
plot(t,Uexp,'linewidth',2)
hold on
plot(t,Usim,'--','linewidth',1)
ylabel('U (mV)')
legend('explicit','simulated')

subplot(4,1,3)
plot(t,Vexp,'linewidth',2)
hold on
plot(t,Vsim,'--','linewidth',1)
ylabel('V (mV)')
legend('explicit','simulated')

subplot(4,1,4)
plot(t,Vexp-Vsim,'linewidth',2)
ylabel('\DeltaV (mV)')
xlabel('time (ms)')
