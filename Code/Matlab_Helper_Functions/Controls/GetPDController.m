function [ Gc, Kp, Kd ] = GetPDController( Gs )

%JUST TAKE MAG, PHASE, WOUT, AND PM_CRIT AS INPUT.
%MAKE SURE TO VERIFY THAT PM_CRIT IS A POSSIBLE PHASE MARGIN.

%% Define the Controller Parameters.

%Retrieve the gain margin, phase margin, gain cross-over frequency, and phase cross-over frequency.
[~, ~, ~, Wgc] = margin(Gs);

%Compute the PD controller constants.
Kp = 1;
Kd = 1/Wgc;

%Define the PD controller.
Gc = tf([Kd Kp], 1);

end

