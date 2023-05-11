% Nicholas Szczecinski 2019
% 23 Jan 19
% CWRU EMAE 689, Synthetic Nervous Systems

%Units are nF, uS, mV, ms, nA
Cm = 10;
Gm = 1;
Iapp = 20;
Er = -60;
R = 20;
gMax = 0.5;
Esyn = 0;

dt = .01;
tmax = 100;

t = 0:dt:tmax;
numSteps = length(t);

delEsyn = Esyn - Er;

%Compute V1(t) and V2(t) with simulation
U1sim = zeros(size(t));
U2sim = zeros(size(t));
U1sim(1) = 0;
U2sim(1) = 0;

for i=2:numSteps
    U1sim(i) = U1sim(i-1) + dt/Cm*(Iapp - Gm*U1sim(i-1));
    gSyn = U1sim(i-1)/R*gMax;
    U2sim(i) = U2sim(i-1) + dt/Cm*(gSyn*(delEsyn - U2sim(i-1)) - Gm*U2sim(i-1));
end
V1sim = U1sim + Er;
v2sim = U2sim + Er;

figure
subplot(3,1,1)
plot(t,Iapp+zeros(size(t)),'linewidth',2)
ylabel('I_{app} (nA)')

subplot(3,1,2)
plot(t,U1sim,'linewidth',2)
ylabel('U_1 (mV)')

subplot(3,1,3)
plot(t,U2sim,'linewidth',2)
ylabel('U_2 (mV)')
