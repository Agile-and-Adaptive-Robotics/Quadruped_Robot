% Nicholas Szczecinski 2019
% 23 Jan 19
% CWRU EMAE 689, Synthetic Nervous Systems

%Units are nF, uS, mV, ms, nA
Cm = 10;
Gm = 1;
Iapp1 = 20;
Iapp2 = 20;
Er = -60;

R = 20;
c = .2;

%User doesn't program this! This is based on design rules.
Esyn = Er;
delEsyn = Esyn - Er;
gMax = 1/c-1;
if gMax < 0
    error('gMax must be greater than 0. Increase Esyn.')
end

dt = .01;
tmax = 100;

t = 0:dt:tmax;
numSteps = length(t);

%Compute V1(t) and V2(t) with simulation
U1sim = zeros(size(t));
U2sim = zeros(size(t));
U1sim(1) = 0;
U2sim(1) = 0;

for i=2:numSteps
    U1sim(i) = U1sim(i-1) + dt/Cm*(Iapp1 - Gm*U1sim(i-1));
    gSyn = U1sim(i-1)/R*gMax;
    U2sim(i) = U2sim(i-1) + dt/Cm*(Iapp2 + gSyn*(delEsyn - U2sim(i-1)) - Gm*U2sim(i-1));
end
V1sim = U1sim + Er;
v2sim = U2sim + Er;

figure
subplot(3,1,1)
plot(t,Iapp1+zeros(size(t)),'linewidth',2)
hold on
plot(t,Iapp2+zeros(size(t)),'--','linewidth',2)
legend('I_{app,1}','I_{app,2}')
ylabel('I_{app} (nA)')

subplot(3,1,2)
plot(t,U1sim,'linewidth',2)
ylabel('U_1 (mV)')

subplot(3,1,3)
plot(t,U2sim,'linewidth',2)
hold on
plot(t,Iapp2/Gm+zeros(size(t)),'--','linewidth',2)
legend('U_2','expected')
ylabel('U_2 (mV)')

U1star = linspace(0,R,101);
U2star = Iapp2./(Gm + gMax/R*U1star);
figure
plot(U1star,U2star,'linewidth',2)
hold on
plot(U1star,c*R+zeros(size(U1star)),'k--')
ylim([0,R])
xlim([0,R])
xlabel('U_1*')
ylabel('U_2*')

