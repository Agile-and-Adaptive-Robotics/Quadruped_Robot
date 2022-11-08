% Nicholas Szczecinski 2019
% 27 Feb 19
% CWRU EMAE 689, Synthetic Nervous Systems

%Units are nF, uS, mV, ms, nA

%Nonspiking neurons - U3 = U1 + U2
Cm = 10;
Gm = 1;
Iapp1 = 5;
Iapp2 = 0;

%Spiking neuron, U3
I3 = 5;
theta3 = 1;

%We set R and Fmax, and then calculate Cm.
R = 20; %mV
Fmax = 1; %kHz (because it's 1/ms)
Cm3 = Gm*R/(Fmax*theta3);

%Design addition node synapses
k = 1; % U3 = K*(U1 + U2)

%User doesn't program this! This is based on design rules.
delEsyn = 100;
gMax = k*R/(delEsyn - k*R);
if gMax < 0
    error('gMax must be greater than 0. Increase Esyn.')
end

fprintf('gMax = %1.3f, delEsyn = %1.3f\n',gMax,delEsyn);

dt = .01;
tmax = 1000;
tStart = tmax*1/4;

t = 0:dt:tmax;
numSteps = length(t);

%Compute V1(t) and V2(t) with simulation
U1sim = zeros(size(t));
U2sim = zeros(size(t));
U3sim = zeros(size(t));
U3spike = false(size(t));
U3star = zeros(size(t));
Iapp3 = zeros(size(t));
Iapp3(t >= tStart) = I3;
fsp3 = zeros(size(t));
g3total = zeros(size(t));

U1sim(1) = 0;
U2sim(1) = 0;
U3sim(1) = 0;

nSpikes = 0;

for i=2:numSteps
    U1sim(i) = U1sim(i-1) + dt/Cm*(Iapp1 - Gm*U1sim(i-1));
    gSyn1 = U1sim(i-1)/R*gMax;
    U2sim(i) = U2sim(i-1) + dt/Cm*(Iapp2 - Gm*U2sim(i-1));
    gSyn2 = U2sim(i-1)/R*gMax;
    
    g3total(i) = Gm + gSyn1 + gSyn2;
    tau3(i) = Cm3/g3total(i);
    U3star(i) = (Iapp3(i) + gSyn1*delEsyn + gSyn2*delEsyn)/g3total(i);
    
    U3sim(i) = U3sim(i-1) + dt/Cm3*(Iapp3(i) - Gm*U3sim(i-1) + gSyn1*(delEsyn - U3sim(i-1)) + gSyn2*(delEsyn - U3sim(i-1)));
    if U3sim(i) > theta3
        U3sim(i) = 0;
        U3spike(i) = true;
        nSpikes = nSpikes + 1;
        spikeInds(nSpikes) = i; %#ok<SAGROW>
    end
    
    if(nSpikes > 1)
        fsp3(spikeInds(nSpikes-1):spikeInds(nSpikes)) = 1./(dt*(spikeInds(nSpikes) - spikeInds(nSpikes-1)));
    end
end

U3sim(U3spike) = 5*theta3;


h = figure;
subplot(4,1,1)
plot(t,U1sim,'linewidth',2)
hold on
plot(t,U2sim,'--','linewidth',2)
legend('U_1','U_2')
ylabel('U (mV, nonspiking)')

subplot(4,1,2)
plot(t,Iapp3+zeros(size(t)),'linewidth',2)
hold on
plot(t,U3star,'--','linewidth',2)
legend('I_{app,3}','U*_3','location','southeast')

subplot(4,1,3)
plot(t,U3sim,'linewidth',2)
ylabel('U_3 (mV)')

subplot(4,1,4)
hold on
ul = 1e3*U3star./(tau3*theta3);
ll = 1e3*(U3star./(tau3*theta3) - 1./tau3);
aa = area(t,ul,'edgealpha',0,'facealpha',.3);
area(t,ll,'facecolor',[1,1,1],'edgealpha',0)
ff = plot(t,1e3*fsp3,'linewidth',2);
legend([aa,ff],{'estimated range','actual'},'location','southeast')
ylabel('f_{sp} (Hz)')
xlabel('time (ms)')
ylim([0,1e3*Fmax])

set(h,'Position',[1 41 1536 748])