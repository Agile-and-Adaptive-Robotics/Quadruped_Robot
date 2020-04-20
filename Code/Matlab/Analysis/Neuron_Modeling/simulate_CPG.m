clear all
clc

dt = 1;
time = 3e3;

C = 5; %nF
R = 1; %M ohm
Gm = 5; %uS
Eca = 200; %mV 
Vr = -60; %mV 
Tm = 2; %ms
Sm = .1; % <=================================
VmidM = -40; %mV
Th = 1000; %ms
Sh = -.1; % <=================================
VmidH = -100; %mV
V_noise = 0*.1; %mV
del_t = dt;
V_r = -60; %mV
I_stim = 4; %nA

G = 2; %uS
V_eq = -70; %mV
V_th_low = -60; %mV
V_th_high = -40; %mV

nprops = zeros(4,13,round(time/dt));
%Put these values into the proper form.
%Each row of nprops outlines the properties of another neuron
nprops(1,:,1) = [C;R;Gm;Eca;Vr;Tm;Sm;VmidM;Th;Sh;VmidH;V_noise;I_stim]';
nprops(2,:,1) = [C;R;Gm;Eca;Vr;Tm;Sm;VmidM;Th;Sh;VmidH;V_noise;I_stim]';
nprops(3,:,1) = [C;R;0;Eca;Vr;Tm;Sm;VmidM;Th;Sh;VmidH;0;0]';
nprops(4,:,1) = [C;R;0;Eca;Vr;Tm;Sm;VmidM;Th;Sh;VmidH;0;0]';

%for nstate we have (property index, time step, neuron)
nstate = zeros(6,time/dt,4);

%assign the initial condition
n_init(:,1,1) = [V_r+1;0;0;0;0;0]; %V(t),m,h,time,I_ext,h_inf
n_init(:,1,2) = [V_r;0;0;0;0;0];
n_init(:,1,3) = [V_r;0;0;0;0;0]; %V(t),m,h,time,I_ext
n_init(:,1,4) = [V_r;0;0;0;0;0];

nstate(:,1,:) = n_init;

sprops = zeros(4,4,round(time/dt));

%Each row of sprops outlines the properties of another neuron
sprops(1,:,1) = [G;-40;V_th_low;V_th_high]; 
sprops(2,:,1) = [G;-40;V_th_low;V_th_high];
sprops(3,:,1) = [G;-70;V_th_low;V_th_high];
sprops(4,:,1) = [G;-70;V_th_low;V_th_high]; 

sstate = zeros(3,time/dt,4);
%sstate is filled like nstate: (property index, time step, neuron)
s_init(:,1,1) = [0;0;0];%V_pre, V_post, Current %1 -> 3
s_init(:,1,2) = [0;0;0];%V_pre, V_post, Current %2 -> 4
s_init(:,1,3) = [0;0;0];%V_pre, V_post, Current %3 -> 2
s_init(:,1,4) = [0;0;0];%V_pre, V_post, Current %4 -> 1

sstate(:,1,:) = s_init;

conn_map = [1 3;2 4;3 2;4 1];

ext_stim = zeros(time/dt,4);
ext_cond{1} = ext_stim;
% ext_stim(:,1) = linspace(0,5,time/dt);

nstate = simulate(nstate,nprops,sstate,sprops,conn_map,ext_cond,time,dt);

figure(3)
clf
hold on
plot(nstate(1,:,1),'Linewidth',2)
plot(nstate(1,:,2),'g','Linewidth',2)
plot(nstate(1,:,3),'cyan','Linewidth',2)
plot(nstate(1,:,4),'r','Linewidth',2)
grid on
legend('Neuron 1','Neuron 2','Neuron 3','Neuron 4');
xlabel('time (ms)')
ylabel('voltage (mV)')
title('CPG Voltage')
hold off

% %Pull out V-H_inf relationships
% %Neuron 1 (property, timeslice, neuron)
% v = nstate(1,1:end-1,1);
% h = nstate(6,2:end,1);
% figure(4)
% clf
% hold on
% plot(v,h,'r.','Linewidth',3)
% hold off


disp('simulation done.')