% Nicholas Szczecinski 2019
% 11 Feb 19
% CWRU EMAE 689, Synthetic Nervous Systems

clear
% close all

%Units are nF, uS, mV, ms, nA
Cm = 5;
Gm = 1;
Iapp1 = 0; %modulatory neuron - control U1
Er = -60;
Esyn = Er - 1;

R = 20;

%User doesn't program this! This is based on design rules.
delEsyn = Esyn - Er;
gMax = -R/delEsyn;
if gMax < 0
    error('gMax must be greater than 0. Increase Esyn.')
end

fprintf('gMax = %1.3f, delEsyn1 = %1.3f\n',gMax,delEsyn);

Iapp2 = R;

%Simulation setup
dt = .1;
tmax = 200;

t = 0:dt:tmax;
numSteps = length(t);
Isignal = 10+zeros(size(t))+10*sin(2*pi*.020*t);

%Compute V1(t) and V2(t) with simulation
U1sim = zeros(size(t));
U2sim = zeros(size(t));
U3sim = zeros(size(t));

U1sim(1) = 0;
U2sim(1) = 0;
U3sim(1) = 0;

for i=2:numSteps
    U1sim(i) = U1sim(i-1) + dt/Cm*(Iapp1 - Gm*U1sim(i-1));
    gSyn1 = min(max(U1sim(i-1)/R,0),1)*gMax;
    U2sim(i) = U2sim(i-1) + dt/Cm*(gSyn1*(delEsyn - U2sim(i-1)) - Gm*U2sim(i-1) + Iapp2);
    gSyn2 = min(max(U2sim(i-1)/R,0),1)*gMax;
    U3sim(i) = U3sim(i-1) + dt/Cm*(Isignal(i-1) + gSyn2*(delEsyn - U3sim(i-1)) - Gm*U3sim(i-1));
end
V1sim = U1sim + Er;
V2sim = U2sim + Er;
V3sim = U3sim + Er;

h = figure;
subplot(3,1,1)
plot(t,Iapp1+zeros(size(t)),'linewidth',2)
hold on
plot(t,Isignal,'--','linewidth',2)
ylabel('I_{app} (nA)')
xlim([min(t),max(t)])

subplot(3,1,2)
plot(t,U1sim,'linewidth',2)
hold on
plot(t,U2sim,'--','linewidth',2)
ylim([0,R])
legend('U_1','U_2')
ylabel('U (mV)')
xlim([min(t),max(t)])

subplot(3,1,3)
plot(t,U3sim,'linewidth',2)
ylim([0,R])
hold on
grid on
xlim([min(t),max(t)])
ylabel('U_3 (mV)')
xlabel('time (ms)')

figure(h);
