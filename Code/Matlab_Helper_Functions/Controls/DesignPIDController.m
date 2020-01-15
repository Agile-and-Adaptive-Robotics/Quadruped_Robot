function [ Gc, Kp, Ki, Kd ] = DesignPIDController( Gs, Hs, Freqs, dt, TimeType, t_crit, PMO_crit, bPlotStepResponseStats )

%Define a transfer function variable.
s = tf('s');

%Design the PD controller.
Kdd = DesignPDController( Gs, Hs, Freqs, dt, TimeType, t_crit, PMO_crit, bPlotStepResponseStats );

%Define the proportional constant for the derivative controller.
Kpd = 1;

%Define the PD controller.
Gcpd = 1 + Kdd*s;

%Design the PI controller.
PI_PhaseMargin = DesignPIController( Gcpd*Gs, Hs, Freqs, dt, TimeType, t_crit, PMO_crit, bPlotStepResponseStats );

%Retrieve the PI controller associated with this phase margin.
[ ~, Kpi, Kii ] = GetPIController( Gcpd*Gs, PI_PhaseMargin, Freqs, dt );

%Compute the overall PID constants.
Kp = Kpd*Kpi + Kdd*Kii;
Kd = Kdd*Kpi;
Ki = Kpd*Kii;

%Define a transfer function variable.
s = tf('s');

%Define the controller transfer function.
Gc = Kp + Ki/s + Kd*s;

end