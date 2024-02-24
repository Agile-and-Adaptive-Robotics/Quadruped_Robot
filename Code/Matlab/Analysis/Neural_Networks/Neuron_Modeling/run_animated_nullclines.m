clear all
% close all
clc

to_simulate = true;
to_animate = false;
to_analyze_eigen = false;
to_plot = true;
to_save = false;

dt = 1;
time_duration = 2*.667e3; %ms
delta = -.001;
baseline_drive = 1; %3.5; %.015; 
ramp_mag = 0;

C = 5; %nF
Gmem = 1; %uS
Gca = 1.5; %.4 %4; %uS
Eca = 50; %50; %200; %mV 
Vr = -60; %mV 
Tm = 2; %ms
Sm = .04; %0.166; %.1; % <=================================
VmidM = -40; %mV
Th = 500; %500 %ms
Sh = -.6; %-.166; % -0.166; %-.1; % <=================================
VmidH = -60; %-70; %-100; %mV
V_noise = 0; %mV
del_t = dt;

G_syn = -1; %4; %uS -1 means we will design the synapse strength
V_eq_hyp = -70; %mV
V_eq_dep = -40;
V_th_low = -60; %mV
V_th_high = -25; %mV

nprops = zeros(4,13);
%Put these values into the proper form.
%Each row of nprops outlines the properties of another neuron
nprops(1,:) = [C,Gmem,Gca,Eca,Vr,Tm,Sm,VmidM,Th,Sh,VmidH,V_noise,0];
nprops(2,:) = [C,Gmem,Gca,Eca,Vr,Tm,Sm,VmidM,Th,Sh,VmidH,V_noise,0];
nprops(3,:) = [C,Gmem,0,Eca,Vr,Tm,Sm,VmidM,Th,Sh,VmidH,0,0];
nprops(4,:) = [C,Gmem,0,Eca,Vr,Tm,Sm,VmidM,Th,Sh,VmidH,0,0];
nprops(5,:) = [C,Gmem,0,Eca,Vr,Tm,Sm,VmidM,Th,Sh,VmidH,0,0];

sprops = zeros(4,4);
%Each row of sprops outlines the properties of another neuron
sprops(1,:) = [G_syn,V_eq_dep,V_th_low,V_th_high]; %1->3
sprops(2,:) = [G_syn,V_eq_dep,V_th_low,V_th_high]; %2->4
sprops(3,:) = [G_syn,V_eq_hyp,V_th_low,V_th_high]; %3->2
sprops(4,:) = [G_syn,V_eq_hyp,V_th_low,V_th_high]; %4->1
sprops(5,:) = [1.5,-20,-60,-40]; %5->1
sprops(6,:) = [1.5,-20,-60,-40]; %5->2

stim_mag = -.1*0;
stim_delay = 1;
stim_duration = 1;


[~,~,G_syn_designed] = f_animated_nullclines(nprops,sprops,delta,G_syn,baseline_drive,ramp_mag,stim_mag,stim_delay,stim_duration,time_duration,dt,to_simulate,to_analyze_eigen,to_plot,to_animate);

sprops(1:4,1) = G_syn_designed;

if to_save

    cur_time = datestr(clock,30);
    mkdir(cur_time)
    h = get(0,'children');
    for i=1:length(h)
      saveas(h(i), [cur_time,'\figure',num2str(i)], 'fig');
    end

    sim_data = struct;
    sim_data.nprops = nprops;
    sim_data.sprops = sprops;
    sim_data.dt = dt;
    sim_data.baseline_stim = baseline_drive;
    sim_data.delta = delta;
    sim_data.time_duration = time_duration;

    save([cur_time,'\sim_data'],'sim_data');
end