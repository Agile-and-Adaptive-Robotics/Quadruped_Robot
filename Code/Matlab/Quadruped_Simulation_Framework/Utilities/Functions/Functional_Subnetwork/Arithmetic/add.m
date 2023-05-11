% Nicholas Szczecinski 2019
% 23 Jan 19
% CWRU EMAE 689, Synthetic Nervous Systems

%Units are nF, uS, mV, ms, nA
Cm = 10;
Gm = 1;
Iapp1 = 5;
Iapp2 = 5;
Er = -60;
Esyn = 0;

R = 20;
k = 1; % U3 = K*(U1 + U2)

%User doesn't program this! This is based on design rules.
delEsyn = Esyn - Er;
gMax = k*R/(delEsyn - k*R);
if gMax < 0
    error('gMax must be greater than 0. Increase Esyn.')
end

fprintf('gMax = %1.3f, delEsyn = %1.3f\n',gMax,delEsyn);

dt = .01;
tmax = 100;

t = 0:dt:tmax;
numSteps = length(t);

%Compute V1(t) and V2(t) with simulation
U1sim = zeros(size(t));
U2sim = zeros(size(t));
U3sim = zeros(size(t));

U1sim(1) = 0;
U2sim(1) = 0;
U3sim(1) = 0;

for i=2:numSteps
    U1sim(i) = U1sim(i-1) + dt/Cm*(Iapp1 - Gm*U1sim(i-1));
    gSyn1 = U1sim(i-1)/R*gMax;
    U2sim(i) = U2sim(i-1) + dt/Cm*(Iapp2 - Gm*U2sim(i-1));
    gSyn2 = U2sim(i-1)/R*gMax;
    U3sim(i) = U3sim(i-1) + dt/Cm*(gSyn1*(delEsyn - U3sim(i-1)) + gSyn2*(delEsyn - U3sim(i-1)) - Gm*U3sim(i-1));
end
V1sim = U1sim + Er;
V2sim = U2sim + Er;
V3sim = U3sim + Er;

h = figure;
subplot(3,1,1)
plot(t,Iapp1+zeros(size(t)),'linewidth',2)
hold on
plot(t,Iapp2+zeros(size(t)),'--','linewidth',2)
ylabel('I_{app} (nA)')

subplot(3,1,2)
plot(t,U1sim,'linewidth',2)
hold on
plot(t,U2sim,'--','linewidth',2)
legend('U_1','U_2')
ylabel('U (mV)')

subplot(3,1,3)
plot(t,U3sim,'linewidth',2)
ylabel('U_3 (mV)')

U1star = linspace(0,R,101);
U2star = gMax*U1star/R*delEsyn./(1 + gMax*U1star/R);
figure
plot(U1star,U2star,'linewidth',2)
hold on
plot(U1star,k*U1star,'k--')
ylim([0,R])
xlim([0,R])
xlabel('U_1*')
ylabel('U_2*')

figure(h);
