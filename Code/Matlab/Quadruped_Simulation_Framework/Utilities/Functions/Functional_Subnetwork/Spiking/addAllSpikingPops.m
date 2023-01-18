% Nicholas Szczecinski 2019
% 27 Feb 19
% CWRU EMAE 689, Synthetic Nervous Systems

%Units are nF, uS, mV, ms, nA

%Spiking neurons - U3 = U1 + U2
n = 50; %neurons per population
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
k = 1/n; % U3 = K*(U1 + U2)

%User doesn't program this! This is based on design rules.
delEsyn = 100;
gNS = k*R/(delEsyn - k*R);
if gNS < 0
    error('gMax must be greater than 0. Increase Esyn.')
end
gMax = gNS/(tauS*Fmax); %same as -1/log(epsilon).

fprintf('gMax = %1.3f, delEsyn = %1.3f\n',gMax,delEsyn);

dt = .1;
tmax = 1000;
tStart = tmax*1/4;

t = 0:dt:tmax;
numSteps = length(t);

%Compute V1(t) and V2(t) with simulation
Usim = zeros(3*n,length(t));
% for i=1:n
%     Usim(i,1) = (i-1)*theta/n;
%     Usim(n+i,1) = (i-1)*theta/n;
%     Usim(2*n+i,1) = (i-1)*theta/n;
% end
Usim(1:3*n,1) = rand(3*n,1);
spikeOccurred = false(size(Usim));
spikeInds = NaN(size(Usim));
fsp = NaN(size(Usim));

synMap = zeros(2*n^2,3*n);
for i=1:2*n
    synMap((i-1)*n+1:n*i,i) = 1;
end

gsim = zeros(2*n^2,length(t));

U1spike = false(size(t));
U2spike = false(size(t));
U3spike = false(size(t));

Ustar = zeros(3*n,length(t));

Iapp3 = zeros(size(t));
Iapp3(t >= tStart) = I3;
fsp3 = zeros(3*n,length(t));
gtotal = Gm+zeros(3*n,length(t));
tau = zeros(3*n,length(t));
inputs = [Iapp1 + zeros(n,1); Iapp2 + zeros(n,1); zeros(n,1)];

nSpikes = zeros(3*n,1);

for i=2:numSteps
    %Update membrane voltage
    for j=1:n
        Usim(j,i) = Usim(j,i-1) + dt/Cm*(Iapp1 - Gm*Usim(j,i-1));
        gtotal(j,i) = Gm;
    end
    for j=1:n
        Usim(n+j,i) = Usim(n+j,i-1) + dt/Cm*(Iapp2 - Gm*Usim(n+j,i-1));
        gtotal(n+j,i) = Gm;
    end
    for j=1:n
        synInds = [(j-1)+(1:n:n^2),n^2+(j-1)+(1:n:n^2)];
        Usim(2*n+j,i) = Usim(2*n+j,i-1) + dt/Cm*(Iapp3(i) - Gm*Usim(2*n+j,i-1) + sum(gsim(synInds,i-1))*(delEsyn - Usim(2*n+j,i-1)));
    end
    
    %Determine if any spikes occured
    spikeOccurred(:,i) = (Usim(:,i) > theta);
    nSpikes = nSpikes + spikeOccurred(:,i);
    if any(spikeOccurred(:,i))
        spikeInds(spikeOccurred(:,i),nSpikes(spikeOccurred(:,i))) = i;
    end
    
    %Update synaptic conductance
    gsim(:,i) = gsim(:,i-1) + dt/tauS*(-gsim(:,i-1));
    
    %If presynaptic spikes occurred, reset syn cond to max value.
    %If spike occurs, reset U to 0.
    gsim(logical(synMap*spikeOccurred(:,i)),i) = gMax;
    Usim(spikeOccurred(:,i),i) = 0;
    
    for j=1:n
        synInds = [(j-1)+(1:n:n^2),n^2+(j-1)+(1:n:n^2)];
        gtotal(2*n+j,i) = Gm + sum(gsim(synInds,i));
        inputs(2*n+j) = Iapp3(i) + sum(gsim(synInds,i))*delEsyn;
    end
    tau(:,i) = Cm./gtotal(:,i);
    
    Ustar(:,i) = inputs./gtotal(:,i);
    
    if any(nSpikes > 1)
        inds = (nSpikes > 1);
        for j=1:3*n
            if inds(j)
                fsp(j,spikeInds(j,nSpikes(j)-1):spikeInds(j,nSpikes(j))) = 1./(dt*(spikeInds(j,nSpikes(j)) - spikeInds(j,nSpikes(j)-1)));
            else
                %do nothing
            end
        end
        
    end
end

Usim(spikeOccurred) = 5*theta;

xlims = [0,100];
% xlims = [0,tmax];

h = figure;
subplot(4,3,1)
plot(t,Usim(1:n,:),'linewidth',1)
hold on
plot(t,theta+zeros(size(t)))
ylabel('U (mV)')
xlim(xlims)
title(sprintf('Input population 1 (%i neurons)',n))

subplot(4,3,2)
plot(t,Usim(1+n:2*n,:),'linewidth',1)
hold on
plot(t,theta+zeros(size(t)))
ylabel('U (mV)')
xlim(xlims)
title(sprintf('Input population 2 (%i neurons)',n))

subplot(4,3,3)
plot(t,Usim(1+2*n:3*n,:),'linewidth',1)
hold on
plot(t,theta+zeros(size(t)))
ylabel('U (mV)')
xlim(xlims)
title(sprintf('Output population (%i neurons)',n))


subplot(4,3,4)
plot(t,gsim(1:n:n^2,:),'linewidth',1)
ylabel('G_{syn} (\muS)')
xlim(xlims)

subplot(4,3,5)
plot(t,gsim(n^2+(1:n:n^2),:),'linewidth',1)
ylabel('G_{syn} (\muS)')
xlim(xlims)


subplot(4,3,7)
plot(t,Ustar(1:n,:),'linewidth',1)
ylabel('U* (mV)')
xlim(xlims)

subplot(4,3,8)
plot(t,Ustar(1+n:2*n,:),'linewidth',1)
ylabel('U* (mV)')
xlim(xlims)

subplot(4,3,9)
plot(t,Ustar(1+2*n:3*n,:),'linewidth',1)
ylabel('U* (mV)')
xlim(xlims)

subplot(4,3,10)
plot(t,1e3*fsp(1:n,:),'linewidth',1)
hold on
ylabel('f_{sp} (Hz)')
xlim(xlims)
ylim([0,1e3*max(fsp(:))])

subplot(4,3,11)
plot(t,1e3*fsp(1+n:2*n,:),'linewidth',1)
hold on
ylabel('f_{sp} (Hz)')
xlim(xlims)
ylim([0,1e3*max(fsp(:))])

subplot(4,3,12)
plot(t,1e3*fsp(2*n+1:3*n,:),'linewidth',1)
hold on
opm = plot(t,1e3*mean(fsp(2*n+1:3*n,:),1),'k','linewidth',2);
legend(opm,'output mean ff')
ylabel('f_{sp} (Hz)')
xlim(xlims)
ylim([0,1e3*max(fsp(:))])

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