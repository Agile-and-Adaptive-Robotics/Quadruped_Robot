% Nicholas Szczecinski 2019
% 19 Mar 19
% CWRU EMAE 689, Synthetic Nervous Systems

close all
clear all
clc

%Units are nF, uS, mV, ms, nA

%Nonspiking neurons - U3 = U1 + U2
Cm = 10;
Gm = 1;
Iapp1 = 0;
Iapp2 = 0;

%Spiking neuron, U3
I3 = 20;
theta0 = 1; %1;

m = 1; 
tauTheta = 300; 
% m = -5; %2;
% tauTheta = 30; %50;
% m = 1;
% tauTheta = 500;
% m = .5;
% tauTheta = 500;

R = 20; %mV

%Design addition node synapses
k = 1; % U3 = K*(U1 + U2)

%User doesn't program this! This is based on design rules.
delEsyn = 100;
gMax = k*R/(delEsyn - k*R);
if gMax < 0
    error('gMax must be greater than 0. Increase Esyn.')
end

%We set R and Fmax, and then calculate Cm.

Fmax = .1; %kHz (because it's 1/ms)
%Design Cm3 to ensure that when U* = R, fsp = Fmax. If m != 0, then we need
%to also scale Fmax based on our prediction of theta*.
Cm3 = 1/Fmax*((1 - m/2)*R/theta0 - 1/2);
% Cm3 = 5;
if Cm3 <= 0
    Cm3 = Gm*R/(Fmax*theta0);
end

fprintf('gMax = %1.3f, delEsyn = %1.3f\n',gMax,delEsyn);

dt = .1;
tmax = 10000;
tStart = tmax*1/4;

t = 0:dt:tmax;
numSteps = length(t);

%Compute V1(t) and V2(t) with simulation
U1sim = zeros(size(t));
U2sim = zeros(size(t));
U3sim = zeros(size(t));
U3spike = false(size(t));
U3star = zeros(size(t));
theta3 = zeros(size(t));
Iapp3 = zeros(size(t));
Iapp3(t >= tStart) = I3;
fsp3 = NaN(size(t));
g3total = zeros(size(t));
tau3 = zeros(size(t));

U1sim(1) = 0;
U2sim(1) = 0;
U3sim(1) = 0;
theta3(1) = theta0;

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
    theta3(i) = theta3(i-1) + dt/tauTheta*(-theta3(i-1) + theta0 + m*U3sim(i-1));
    if U3sim(i) > theta3(i)
        U3sim(i) = 0;
        theta3(i) = max(0,theta3(i));
        U3spike(i) = true;
        nSpikes = nSpikes + 1;
        spikeInds(nSpikes) = i; %#ok<SAGROW>
    end
    
    
    if(nSpikes > 1)
        fsp3(spikeInds(nSpikes-1):spikeInds(nSpikes)) = 1./(dt*(spikeInds(nSpikes) - spikeInds(nSpikes-1)));
    end
end

U3sim(U3spike) = 2*R; %5*theta0;
taum = Cm3/Gm;

%define our function to predict theta*_\infty. Given a value of U*, we can
%find theta* that sets f = 0.
if taum == tauTheta
    f = @(th,U) -th + theta0 + m*U + (th - theta0 - m*U).*(1 - th./U).^(taum/tauTheta) + m*U*taum/tauTheta*log(1 - th./U).*(1 - th./U).^(taum/tauTheta);
else
    f = @(th,U) -th + theta0 + m*U + (th - theta0 - m*U).*(1 - th./U).^(taum/tauTheta) + m*U*taum/(tauTheta - taum).*((1 - th./U) - (1 - th./U).^(taum/tauTheta));
end

%define the slope of f, which will be necessary to determine if the
%solution we find is stable or not.
df = @(th,U) (f(th+.001,U) - f(th,U))/.001;

%If the slope of f is positive at its zero, then this is an unstable
%solution.
slopePositive = true;
thStart = theta0/(1 - m/2);
counter = 1;
%Find the steady state threshold for the final value of U*. If m!=0, then
%this will not be true throughout the simulation, because theta* will
%change. But this is at least one way to check our claculation of theta*.
if ~isinf(thStart) && thStart > 0
    while slopePositive && counter < 10
        %solve f to find a candidate theta* value.
        thStar = fzero(@(th)f(th,U3star(end)),thStart);
        if df(thStar,U3star(end)) < 0
            %This means the solution is stable, and we can stop searching.
            slopePositive = false;
        else
            %This means the solution is unstable, and we need to keep
            %searching. Change the starting point and try again.
            thStart = thStart + 1;
        end
        counter = counter + 1;
    end

    if slopePositive
        warning('No solution for the steady state firing frequency could be found.')
    end
else
    thStar = NaN;
end

%Repeat the above process for multiple values of U*, to find the dependence
%of theta* on U*. This will also let us compare our approximate value
%theta*=theta0/(1-m/2) to the actual value.
Utry = 0:.1:R;
thStarVec = NaN(size(Utry));
for i=1:length(Utry)
    slopePositive = true;
    thStart = theta0;
    counter = 1;
    while slopePositive && counter < 10
        try thStarVec(i) = fzero(@(th)f(th,Utry(i)),thStart);
        catch
            counter = 10;
        end
        if df(thStarVec(i),Utry(i)) < 0
            slopePositive = false;
        else
            thStart = thStart + 1;
        end
        counter = counter + 1;
    end

    if slopePositive
        warning('No solution for the steady state firing frequency could be found.')
    end
end

thStarApprox = theta0/(1 - m/2)+zeros(size(Utry));


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
stairs(t,U3sim,'linewidth',2)
hold on
stairs(t,theta3)
ylabel('U_3 (mV)')

subplot(4,1,4)
hold on
plot(t(t > tStart),zeros(size(t(t > tStart)))+1e3*-1./(tau3(end)*log(1 - thStar/U3star(end))))
plot(t(t > tStart),zeros(size(t(t > tStart)))+1e3*-1./(tau3(end)*log(1 - interp1(Utry,thStarApprox,U3star(end))/U3star(end))))
ff = plot(t,1e3*fsp3,'linewidth',2);
ylabel('f_{sp} (Hz)')
xlabel('time (ms)')
if max(fsp3) > 0
    ylim([0,Inf])
end
xlim([0,tmax])
legend('f based on numerical \theta*_\infty','f based on approximate \theta*_\infty','f measured from sim','location','west')
set(h,'Position',[1 41 1536 748])


thSamp = linspace(0,10);
figure
plot(thSamp,f(thSamp,U3star(end)));
hold on
if exist('thStar','var')
    plot(thStar,f(thStar,U3star(end)),'r*')
end
grid on
xlabel('\theta^*')
ylabel('f')

figure
plot(Utry,thStarVec,'linewidth',2)
hold on
plot(Utry,thStarApprox,'--')
ylim([0,Inf])
xlabel('U*')
ylabel('\theta^*_\infty')

