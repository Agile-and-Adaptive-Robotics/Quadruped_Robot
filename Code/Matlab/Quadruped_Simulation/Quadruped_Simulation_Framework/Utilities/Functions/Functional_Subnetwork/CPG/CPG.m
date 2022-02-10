% Nicholas Szczecinski 2019
% 13 Feb 19
% CWRU EMAE 689, Synthetic Nervous Systems

clear
% close all

%Units are nF, uS, mV, ms, nA
C = 5;
% tauM = 1;
tauHmax = 300; %900;
Gm = 1;
Ena = 50;

I = 2;
tStart = 1000;
tEnd = 4000;
Er = -60;
k = -1;
tTail = 2500; %plot tTail ms "tail" on the phase plot

numNeurons = 2;
%Delta 
delta = .01;

%Time info
dtExact = .1;
dtSim = 1;
tmax = 5000;
R = 20;

%Time vectors
tSim = 0:dtSim:tmax;
numSteps = length(tSim);

Iapp = I*(tSim >= tStart & tSim <= tEnd);
Ipert = zeros(size(tSim));
Ipert(1) = 1;
% Ipert(tSim == 3000) = 50;

%Design the synapse
Einh = -100;
delEsyn = Einh - Er;

%Assemble the persistent sodium (NaP) channel
S = .05; %Slope of the sigmoid of hInf, mInf.
delEna = Ena - Er; %50 mV
Utest = -R:.1:3*R;
mInf = @(U) 1./(1 + exp(S*(R-U))); %Steady-state value of m, as a function of U.
hInf = @(U) 1./(1 + .5*exp(S*U)); %Steady-state value of h, as a function of U.
tauh = @(U) tauHmax*hInf(U).*sqrt(.5*exp(S*U)); %Time constant of h, as a function of U.

%Solve for the conductance of the NaP channel to get U* = R, with no
%external current or synaptic inputs.
Gna = Gm*R/(mInf(R)*hInf(R)*(delEna - R));

%Now we know that U* = R, and we can find h* and m* based on that.
Ustar = R;
mStar = mInf(Ustar);
hStar = hInf(Ustar);

%Once we know all of the equilibrium states, we can compute the Jacobian
%matrix and its eigenvalues. This will tell us about the stability of each
%neuron in the network (although not about the system as a whole).
%Specifically, we want to avoid complex eigenvalues, because this will
%cause unwanted oscillations that will make our analysis fail.
dU = 1e-3;
dm_dU = @(U) (mInf(U+dU) - mInf(U))/dU;
dh_dU = @(U) (hInf(U+dU) - hInf(U))/dU;
dtauh_dU = @(U) (tauh(U+dU) - tauh(U))/dU;

dUdot_dU = 1/C*(-1 + dm_dU(Ustar)*Gna*hStar*(delEna - Ustar) - Gna*mStar*hStar);
dUdot_dh = 1/C*(Gna*mStar*(delEna - Ustar));
%dhdot_dU = (tauh(Ustar)*dh_dU(Ustar) - (hInf(Ustar) - hStar)*(dtauh_dU(Ustar)))/(tauh(Ustar)^2)
dhdot_dU = dh_dU(Ustar)/tauh(Ustar);
dhdot_dh = -1/tauh(Ustar);

J = [   dUdot_dU   dUdot_dh;...
        dhdot_dU   dhdot_dh];

%Warn the user if the Jacobian has complex eigenvalues.
eigs(J)
if any(imag(eigs(J)))
    warning('on')
    warning('The active neuron has complex eigenvalues, which may complicate analysis.')
end

%Now that all of the neuron parameters have been set, here is a function of
%dU/dt, as a function of U. This will be helpful for finding equilibrium
%states of this nonlinear system.
dUdt = @(U) -Gm*U + Gna.*mInf(U).*hInf(U).*(delEna - U);



if numNeurons == 2
    gSyn = (-delta - delta*Gna*mInf(delta)*hInf(delta) + Gna*mInf(delta)*hInf(delta)*delEna)/(delta - delEsyn);
elseif numNeurons == 1
    gSyn = 0;
else
    error('numNeurons must be 1 or 2.')
end

hUnull = @(U,I) (Gm*U - gSyn*(delEsyn - U) - I)./(Gna*mInf(U).*(delEna - U));

%Compute U(t) with simulation
Usim1 = zeros(size(tSim));
Usim1(1) = 0;
Usim2 = zeros(size(tSim));
Usim2(1) = 0;
hSim1 = zeros(size(tSim));
hSim1(1) = hInf(Usim1(1));
hSim2 = zeros(size(tSim));
hSim2(1) = hInf(Usim2(1));

g = @(U) min(max(U/R,0),1)*gSyn;

Gsyn1 = zeros(size(tSim));
Gsyn1(1) = g(Usim1(1));
Gsyn2 = zeros(size(tSim));
Gsyn2(1) = g(Usim2(1));

for i=2:numSteps    
%     Usim1(i) = Usim1(i-1) + dtSim/C*(-Gm*Usim1(i-1) + g(Usim2(i-1))*(delEsyn-Usim1(i-1)) + Gna*mInf(Usim1(i-1))*hSim1(i-1)*(delEna-Usim1(i-1)) + Iapp(i-1) + Ipert(i-1));
    Usim1(i) = Usim1(i-1) + dtSim/C*(-Gm*Usim1(i-1) + Gsyn2(i-1)*(delEsyn-Usim1(i-1)) + Gna*mInf(Usim1(i-1))*hSim1(i-1)*(delEna-Usim1(i-1)) + Iapp(i-1) + Ipert(i-1));
    hSim1(i) = hSim1(i-1) + dtSim/tauh(Usim1(i-1))*(hInf(Usim1(i-1)) - hSim1(i-1));
    Gsyn1(i) = g(Usim1(i));
%     Usim2(i) = Usim2(i-1) + dtSim/C*(-Gm*Usim2(i-1) + g(Usim1(i-1))*(delEsyn-Usim2(i-1)) + Gna*mInf(Usim2(i-1))*hSim2(i-1)*(delEna-Usim2(i-1)) + Iapp(i-1));
    Usim2(i) = Usim2(i-1) + dtSim/C*(-Gm*Usim2(i-1) + Gsyn1(i-1)*(delEsyn-Usim2(i-1)) + Gna*mInf(Usim2(i-1))*hSim2(i-1)*(delEna-Usim2(i-1)) + Iapp(i-1));
    hSim2(i) = hSim2(i-1) + dtSim/tauh(Usim2(i-1))*(hInf(Usim2(i-1)) - hSim2(i-1));
    Gsyn2(i) = g(Usim2(i));
end

h = figure;
subplot(4,2,1)
hold on
pIapp1 = plot(tSim(1),Iapp(1)+Ipert(1),'linewidth',2);
if numNeurons == 2
    pIapp2 = plot(tSim(1),Iapp(1),'linewidth',2);
end
xlim([min(tSim),max(tSim)])
ylim([0,2*R])
ylabel('I_{app} (nA)')
grid on

subplot(4,2,3)
hold on
pU1 = plot(tSim(1),Usim1(1),'linewidth',2);
if numNeurons == 2
    pU2 = plot(tSim(1),Usim2(1),'--','linewidth',2);
end
ylabel('U (mV)')
xlim([min(tSim),max(tSim)])
ylim([-R,3*R])
grid on

subplot(4,2,5)
hold on
ph1 = plot(tSim(1),hSim1(1),'linewidth',2);
if numNeurons == 2
    ph2 = plot(tSim(1),hSim2(1),'--','linewidth',2);
end
ylabel('h')
xlim([min(tSim),max(tSim)])
ylim([0,1])
grid on

subplot(4,2,7)
hold on
pG1 = plot(tSim(1),Gsyn1(1),'linewidth',2);
if numNeurons == 2
    pG2 = plot(tSim(1),Gsyn2(1),'--','linewidth',2);
end
ylabel('G (\muS)')
xlim([min(tSim),max(tSim)])
ylim([0,gSyn])
grid on

hh = subplot(4,2,[2,4,6,8]);
xlim([-R,3*R])
ylim([0,1])
hold on
axis square
grid on
pX1s = plot(Usim1(1),hSim1(1),'linewidth',2);
hh.ColorOrderIndex = 1;
pX1 = plot(Usim1(1),hSim1(1),'o','markersize',10,'linewidth',2);
if numNeurons == 2
    pX2s = plot(Usim2(1),hSim2(1),'linewidth',2);
    hh.ColorOrderIndex = 2;
    pX2 = plot(Usim2(1),hSim2(1),'o','markersize',10,'linewidth',2);
end
plot(Utest,hInf(Utest),':','linewidth',2)
pUnull = plot(Utest,hUnull(Utest,Iapp(1)),':','linewidth',2);
plot([0,0],[0,1],'k:','linewidth',2)
xlabel('U (mV)')
ylabel('h (mV)')
% legend('N_1 state history','N_1 state present','N_2 state history','N_2 state present','h nullcline','U nullcline when inhibited','synaptic threshold','location','southoutside')

iTail = round(tTail/dtSim);

input('ready?\n')

set(h,'Position',[1,41,1536,748])
shg
pause(.5);

for i=2:20:numSteps
    pIapp1.XData = tSim(1:i);
    pIapp1.YData = Iapp(1:i)+Ipert(1:i);
    
    pU1.XData = tSim(1:i);
    pU1.YData = Usim1(1:i);
    
    pG1.XData = tSim(1:i);
    pG1.YData = Gsyn1(1:i);
    
    ph1.XData = tSim(1:i);
    ph1.YData = hSim1(1:i);
    
    pX1s.XData = Usim1(max(1,i-iTail):i);
    pX1s.YData = hSim1(max(1,i-iTail):i);
    
    pX1.XData = Usim1(i);
    pX1.YData = hSim1(i);
    
    if numNeurons == 2
        pU2.XData = tSim(1:i);
        pU2.YData = Usim2(1:i);
        
        pG2.XData = tSim(1:i);
        pG2.YData = Gsyn2(1:i);
        
        ph2.XData = tSim(1:i);
        ph2.YData = hSim2(1:i);
        
        pX2s.XData = Usim2(max(1,i-iTail):i);
        pX2s.YData = hSim2(max(1,i-iTail):i);
        
        pX2.XData = Usim2(i);
        pX2.YData = hSim2(i);
    end
    
    if(Iapp(i) ~= Iapp(i-1))
        pUnull.YData = hUnull(Utest,Iapp(i));
    end
    
    drawnow
    
%     pause(2e-3);
end







