% Nicholas Szczecinski 2019
% 11 Feb 19
% CWRU EMAE 689, Synthetic Nervous Systems

clear
close all

%Units are nF, uS, mV, ms, nA
Cm = 50;
Gm = 1;
I = 1;
tStart = 200;
tEnd = 700;
Er = -60;
dtExact = .1;
dtSim = 10;
tmax = 1000;
R = 20;

%Time vectors
tSim = 0:dtSim:tmax;
numSteps = length(tSim);

Iapp = I*(tSim >= tStart & tSim <= tEnd);

%Design the synapse
Einh = -65;
delE = Einh - Er;
g = -R/delE;

%Calculate k_i
kiLL = 1/(Cm*(2+g));
kiUL = (1+g)/(Cm*(2+g));
kiMean = 1/(2*Cm);

%Calculate the equilibrium manifold.
U1 = 0:.1:R;
U2 = delE*(R - U1)./(delE - U1);

%Compute U(t) with simulation
Usim1 = zeros(size(tSim));
Usim1(1) = 0;
Usim2 = zeros(size(tSim));
Usim2(1) = 0;

for i=2:numSteps
    Usim1(i) = Usim1(i-1) + dtSim/Cm*(-Gm*Usim1(i-1) + min(max(Usim2(i-1)/R,0),1)*g*(delE-Usim1(i-1)) + Iapp(i-1) + R);
    Usim2(i) = Usim2(i-1) + dtSim/Cm*(-Gm*Usim2(i-1) + min(max(Usim1(i-1)/R,0),1)*g*(delE-Usim2(i-1)) + R);
end

h = figure;
subplot(2,2,1)
hold on
pIapp = stairs(tSim(1),Iapp(1),'linewidth',2);
xlim([min(tSim),max(tSim)])
ylim([0,R])
ylabel('I_{app} (nA)')
grid on

subplot(2,2,3)
hold on
pU1 = plot(tSim(1),Usim1(1),'linewidth',2);
pU2 = plot(tSim(1),Usim2(1),'--','linewidth',2);
tPred = tStart:dtSim:tEnd;
UpredLL = Usim1(round(tStart/dtSim))+kiLL*I*(tPred-tStart);
UpredUL = Usim1(round(tStart/dtSim))+kiUL*I*(tPred-tStart);
UpredMean = Usim1(round(tStart/dtSim))+kiMean*I*(tPred-tStart);
plot(tPred,UpredMean)
plot(tPred,UpredLL)
plot(tPred,UpredUL)
legend('U_1','U_2','mean pred.','low pred.','upper pred.','location','east')
ylabel('U (mV)')
xlim([min(tSim),max(tSim)])
ylim([0,R])
grid on

hh = subplot(2,2,[2,4]);
hh.ColorOrderIndex = 3;
xlim([0,R])
ylim([0,R])
hold on
axis square
grid on
plot(U1,U2,':','linewidth',2);
pUs = plot(Usim1(1),Usim2(1),'linewidth',2);
xlabel('U_1 (mV)')
ylabel('U_2 (mV)')

input('ready?\n')

set(h,'Position',[1,41,1536,748])
shg
pause(2.5);

for i=2:numSteps
    pIapp.XData = tSim(1:i);
    pIapp.YData = Iapp(1:i);
    
    pU1.XData = tSim(1:i);
    pU1.YData = Usim1(1:i);
    
    pU2.XData = tSim(1:i);
    pU2.YData = Usim2(1:i);
    
    pUs.XData = Usim1(1:i);
    pUs.YData = Usim2(1:i);
    
    pause(.0005);
end







