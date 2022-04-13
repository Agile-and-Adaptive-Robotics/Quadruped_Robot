% Nicholas Szczecinski 2019
% 27 Feb 19
% CWRU EMAE 689, Synthetic Nervous Systems

%Units are nF, uS, mV, ms, nA

%Spiking neurons - U3 = U1 + U2
Gm = 1;
Iapp1 = 5;
Iapp2 = 5;

%Spiking neuron, U3
I3 = 0;
theta = 1;

%We set R and Fmax, and then calculate Cm.
R = 20; %mV
Fmax = 0.1; %kHz (because it's 1/ms)
Cm = Gm*R/(Fmax*theta);
epsilon = .01;
tauS = -1/(Fmax*log(epsilon));

%Design addition node synapses
k = 1; % U3 = K*(U1 + U2)

%User doesn't program this! This is based on design rules.
delEsyn = 200;
gNS = k*R/(delEsyn - k*R);
if gNS < 0
    error('gMax must be greater than 0. Increase Esyn.')
end
gMax = gNS/(tauS*Fmax); %same as -1/log(epsilon).

fprintf('gMax = %1.3f, delEsyn = %1.3f\n',gMax,delEsyn);

dt = .01;
tmax = 1000;
tStart = tmax*1/4;

t = 0:dt:tmax;
numSteps = length(t);

%Compute V1(t) and V2(t) with simulation
Usim = zeros(3,length(t));
Usim(2,1) = theta/2;
spikeOccurred = false(size(Usim));
spikeInds = NaN(size(Usim));
fsp = NaN(size(Usim));

synMap = [1,0,0;0,1,0];

gsim = zeros(2,length(t));

U1spike = false(size(t));
U2spike = false(size(t));
U3spike = false(size(t));

Ustar = zeros(3,length(t));

Iapp3 = zeros(size(t));
Iapp3(t >= tStart) = I3;
fsp3 = zeros(3,length(t));
gtotal = zeros(3,length(t));
tau = zeros(3,length(t));


nSpikes = zeros(3,1);

for i=2:numSteps
    %Update membrane voltage
    Usim(1,i) = Usim(1,i-1) + dt/Cm*(Iapp1 - Gm*Usim(1,i-1));
    Usim(2,i) = Usim(2,i-1) + dt/Cm*(Iapp2 - Gm*Usim(2,i-1));
    Usim(3,i) = Usim(3,i-1) + dt/Cm*(Iapp3(i) - Gm*Usim(3,i-1) + gsim(1,i-1)*(delEsyn - Usim(3,i-1)) + gsim(2,i-1)*(delEsyn - Usim(3,i-1)));
    
    %Determine if any spikes occured
    spikeOccurred(:,i) = (Usim(:,i) > theta);
    nSpikes = nSpikes + spikeOccurred(:,i);
    if any(spikeOccurred(:,i))
        spikeInds(spikeOccurred(:,i),nSpikes(spikeOccurred(:,i))) = i;
    end
    
    %Update synaptic conductance
    gsim(1,i) = gsim(1,i-1) + dt/tauS*(-gsim(1,i-1));
    gsim(2,i) = gsim(2,i-1) + dt/tauS*(-gsim(2,i-1));
    
    %If presynaptic spikes occurred, reset syn cond to max value.
    %If spike occurs, reset U to 0.
    gsim(logical(synMap*spikeOccurred(:,i)),i) = gMax;
    Usim(spikeOccurred(:,i),i) = 0;
    
    gtotal(:,i) = [Gm; Gm; Gm + gsim(1,i) + gsim(2,i)];
    tau(:,i) = Cm./gtotal(:,i);
    
    inputs = [Iapp1; Iapp2; Iapp3(i) + gsim(1,i)*delEsyn + gsim(2,i)*delEsyn];
    Ustar(:,i) = inputs./gtotal(:,i);
    
    if any(nSpikes > 1)
        inds = (nSpikes > 1);
        for j=1:3
            if inds(j)
                fsp(j,spikeInds(j,nSpikes(j)-1):spikeInds(j,nSpikes(j))) = 1./(dt*(spikeInds(j,nSpikes(j)) - spikeInds(j,nSpikes(j)-1)));
            else
                %do nothing
            end
        end
        
    end
end

Usim(spikeOccurred) = 5*theta;

% xlims = [100,200];
xlims = [0,tmax];

h = figure;
subplot(4,1,1)
plot(t,Usim,'linewidth',2)
hold on
plot(t,theta+zeros(size(t)))
legend('U_1','U_2','U_3')
ylabel('U (mV)')
xlim(xlims)

subplot(4,1,2)
plot(t,gsim,'linewidth',2)
ylabel('G_{syn} (\muS)')
xlim(xlims)

subplot(4,1,3)
% plot(t,Iapp3+zeros(size(t)),'linewidth',2)
% hold on
plot(t,Ustar,'linewidth',2)
ylabel('U* (mV)')
legend('U*_1','U*_2','U*_3','location','southeast')
xlim(xlims)

subplot(4,1,4)
plot(t,1e3*fsp,'linewidth',2)
legend('f_{sp,1}','f_{sp,2}','f_{sp,3}')
ylabel('f_{sp} (Hz)')
xlim(xlims)
ylim([0,inf])

% subplot(4,1,4)
% hold on
% ul = 1e3*Ustar./(tau*theta);
% ll = 1e3*(Ustar./(tau*theta) - 1./tau);
% aa = area(t,ul,'edgealpha',0,'facealpha',.3);
% area(t,ll,'facecolor',[1,1,1],'edgealpha',0)
% ff = plot(t,1e3*fsp3,'linewidth',2);
% legend([aa,ff],{'estimated range','actual'},'location','southeast')
% ylabel('f_{sp} (Hz)')
% xlabel('time (ms)')
% ylim([0,1e3*Fmax])

set(h,'Position',[1 41 1536 748])