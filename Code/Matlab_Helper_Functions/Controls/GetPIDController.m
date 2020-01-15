function [ Gc, Kp, Ki, Kd ] = GetPIDController( Gs, Pm_crit )

%Get a general purpose PD controller for our system transfer function.
[ Gcpd, Kpd, Kdd ] = GetPDController( Gs );

%Get a PI controller with the specified phase margin.
[ ~, Kpi, Kii ] = GetPIController( Gcpd*Gs, Pm_crit );

%Compute the overall PID constants.
Kp = Kpd*Kpi + Kdd*Kii;
Kd = Kdd*Kpi;
Ki = Kpd*Kii;

%Define a transfer function variable.
s = tf('s');

%Define the controller transfer function.
Gc = Kp + Ki/s + Kd*s;

end