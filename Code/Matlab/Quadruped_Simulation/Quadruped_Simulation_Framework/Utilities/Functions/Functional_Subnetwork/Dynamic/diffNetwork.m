% Nicholas Szczecinski 2019
% 11 Feb 19
% CWRU EMAE 689, Synthetic Nervous Systems

clear
close all

%Units are nF, uS, mV, ms, nA
Cm1 = 5;
Cm2 = 55;
Cm3 = 5;
Gm = 1;
b = 10e-3; %nA/ms
c = 10;
Er = -60;
dtExact = .1;
dtSim = 1;
tmax = 1000;
R = 20;

tExact = 0:dtExact:tmax;
tSim = 0:dtSim:tmax;
numSteps = length(tSim);

% Iapp = b*tSim;
% Iapp = b*tSim + (tSim > tmax/2).*(b*(tSim-tmax/2));
% Iapp = b*tSim - (tSim > tmax/2).*(b*(tSim-tmax/2));
Iapp = c*(tSim > tmax/2);

%First, compute V(t) explicitly
tau1 = Cm1/Gm;
tau2 = Cm2/Gm;
% Uexp = Iapp/Gm*(1-exp(-t/tau));
Uexp1 = b*(tExact - tau1) + b*tau1*exp(-tExact/tau1);
Uexp2 = b*(tExact - tau2) + b*tau2*exp(-tExact/tau2);

%Next, compute V(t) with simulation
Usim1 = zeros(size(tSim));
Usim1(1) = 0;
Usim2 = zeros(size(tSim));
Usim2(1) = 0;
Usim3 = zeros(size(tSim));
Usim3(1) = 0;

%Assemble subtraction network
Eexc = 100;
Einh = -100;
k = 1;

delEexc = Eexc - Er;
delEinh = Einh - Er;

Gexc = k*R/(delEexc - k*R);
Ginh = -Gexc*delEexc/delEinh;

for i=2:numSteps
    Usim1(i) = Usim1(i-1) + dtSim/Cm1*(Iapp(i-1) - Gm*Usim1(i-1));
    Usim2(i) = Usim2(i-1) + dtSim/Cm2*(Iapp(i-1) - Gm*Usim2(i-1));
    Usim3(i) = Usim3(i-1) + dtSim/Cm3*(min(max(Usim1(i-1)/R,0),1)*Gexc*(delEexc - Usim3(i-1)) + min(max(Usim2(i-1)/R,0),1)*Ginh*(delEinh - Usim3(i-1)) - Gm*Usim3(i-1));
end

h = figure;
subplot(4,1,1)
plot(tSim,Iapp+zeros(size(tSim)),'linewidth',2)
ylabel('I_{app} (nA)')

subplot(4,1,2)
plot(tExact,Uexp1,'linewidth',2)
hold on
plot(tSim,Usim1,'linewidth',1)
plot(tExact,Uexp2,'linewidth',2)
plot(tSim,Usim2,'linewidth',1)
plot(tSim,Iapp,'k')
ylabel('U (mV)')
legend('U_{expl,1}','U_{sim,1}','U_{exp,2}','U_{sim,2}','I_{app}/G_m')
grid on

subplot(4,1,3)
% plot(tSim,Iapp/Gm - Usim1,'linewidth',2)
plot(tSim,Usim1 - Usim2,'linewidth',2)
hold on
plot(tSim,b*(tau2 - tau1)+zeros(size(tSim)),'--')
ylabel('U_1 - U_2 (mV)')

subplot(4,1,4)
plot(tSim,Usim3,'linewidth',2)
hold on
plot(tSim,b*(tau2 - tau1)+zeros(size(tSim)),'--')
ylabel('U_3 (mV)')
xlabel('time (ms)')

set(h,'Position',[770,52,766,741])