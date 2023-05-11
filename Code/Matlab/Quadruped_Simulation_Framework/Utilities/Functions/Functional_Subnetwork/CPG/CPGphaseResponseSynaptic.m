% Nicholas Szczecinski 2019
% 13 Feb 19
% CWRU EMAE 689, Synthetic Nervous Systems

clear
% close all

%Units are nF, uS, mV, ms, nA
C = 5;
tauM = 1;
tauH = 500;
Gm = 1;
Ena = 50;
delta = .001;
Er = -60;
k = -1;
gStim = .05;
eStim = 20; %0 for inhibitory, 20 for excitatory.
numPhase = 20;

numNeurons = 2;

%Time info
dtSim = 1;
tmax = 10000;
R = 20;

%Time vectors
tSim = 0:dtSim:tmax;
numSteps = length(tSim);

%Design the synapse
Einh = -100;
delEsyn = Einh - Er;

period = NaN(numPhase+1,1);

h = figure;
xlabel('time (ms)')
ylabel('U (mV)')

for i=1:numPhase+1
    gPert = zeros(size(tSim));

    %Assemble the persistent sodium (NaP) channel
    S = .05; %.1; %Slope of the sigmoid of hInf, mInf.
    delEna = Ena - Er;
    Utest = -R:1:3*R;
    htest = 0:.1:1;
    delEm = 2*R; %R;
    delEh = 0;
    mInf = @(U) 1./(1 + exp(S*(delEm-U))); %Steady-state value of m, as a function of U.
    hInf = @(U) 1./(1 + .5*exp(S*(U-delEh))); %Steady-state value of h, as a function of U.
    tauh = @(U) tauH*hInf(U).*sqrt(.5*exp(S*(U-delEh))); %Time constant of h, as a function of U.

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
    if any(imag(eigs(J)))
        warning('on')
        warning('The active neuron has complex eigenvalues, which may complicate analysis.')
    end

    %Now that all of the neuron parameters have been set, here is a function of
    %dU/dt, as a function of U. This will be helpful for finding equilibrium
    %states of this nonlinear system.
    dU_dt = @(U,h) 1/C*(-Gm*U + Gna.*mInf(U).*h.*(delEna - U));
    dh_dt = @(U,h) 1/tauh(U)*(hInf(U) - h);

    if numNeurons == 2
        gSyn = (-delta - delta*Gna*mInf(delta)*hInf(delta) + Gna*mInf(delta)*hInf(delta)*delEna)/(delta - delEsyn);
        gSim = gSyn+zeros(size(tSim));
    elseif numNeurons == 1
        gSyn = 0;
        gSim = gSyn+zeros(size(tSim));
    else
        error('numNeurons must be 1 or 2.')
    end

    hUnull = @(U,gSyn) (Gm*U - gSyn*(delEsyn - U))./(Gna*mInf(U).*(delEna - U));

    %Compute U(t) with simulation
    Usim1 = NaN(size(tSim));
    Usim1(1) = 0;
    Usim2 = NaN(size(tSim));
    Usim2(1) = R;
    hSim1 = NaN(size(tSim));
    hSim1(1) = hInf(Usim1(1));
    hSim2 = NaN(size(tSim));
    hSim2(1) = hInf(Usim2(1));

    numCrossings = 0;
    crossing = NaN(1,2);
    k = 1;
    j = 2;
    
    if i > 1
        iStim = round(tStim(i-1)/dtSim);
        gPert(iStim:iStim+10) = gStim;
    end
    
    while(j <= numSteps && numCrossings < 2)
        g = @(U) gSim(j)*min(max(U/R,0),1);
        
        Usim1(j) = Usim1(j-1) + dtSim/C*(-Gm*Usim1(j-1) + g(Usim2(j-1))*(delEsyn-Usim1(j-1)) + Gna*mInf(Usim1(j-1))*hSim1(j-1)*(delEna-Usim1(j-1)) + gPert(j-1)*(eStim - Usim1(j-1)));
        hSim1(j) = hSim1(j-1) + dtSim/tauh(Usim1(j-1))*(hInf(Usim1(j-1)) - hSim1(j-1));
        Usim2(j) = Usim2(j-1) + dtSim/C*(-Gm*Usim2(j-1) + g(Usim1(j-1))*(delEsyn-Usim2(j-1)) + Gna*mInf(Usim2(j-1))*hSim2(j-1)*(delEna-Usim2(j-1)));
        hSim2(j) = hSim2(j-1) + dtSim/tauh(Usim2(j-1))*(hInf(Usim2(j-1)) - hSim2(j-1));
        if Usim1(j-1) < 2*R && Usim1(j) >= 2*R
            crossing(k) = tSim(j);
            k = k + 1;
            numCrossings = numCrossings + 1;
        end
        j = j + 1;
    end
    
    period(i) = crossing(2) - crossing(1);
    
    if i == 1
        tStim = crossing(1) + (1:numPhase)/numPhase*period(1);
    end
    
    figure(h)
    hold on
    plot(tSim,Usim1);
end



figure
plot((1:numPhase)/numPhase,(period(2:end)-period(1))/period(1))
xlabel('Phase')
ylabel('\Delta phase')
xlim([0,1])
ylim([-1,1])