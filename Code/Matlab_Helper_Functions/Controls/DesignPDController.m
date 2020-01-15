function [ Kd, TimeStat_crit, PMO_crit ] = DesignPDController( Gs, Hs, Freqs, dt, TimeType, t_crit, PMO_crit, bPlotStepResponseStats )

%JUST TAKE MAG, PHASE, WOUT, AND PM_CRIT AS INPUT.
%MAKE SURE TO VERIFY THAT PM_CRIT IS A POSSIBLE PHASE MARGIN.

%Turn off the plotting option by default.
if nargin < 8, bPlotStepResponseStats = false; end

%Ensure that the TimeType setting is recognized.
if (~strcmp(TimeType, 'SettlingTime')) && (~strcmp(TimeType, 'RiseTime'))
    error('Requirement type not recognized.  Must be either "SettlingTime" or "RiseTime." Defaulting to "SettlingTime."')
end


%% Compute the Step Response Characteristics at Each Phase Margin.

%Define the angular frequency domain over which to consider the frequency response.
ws = (2*pi*Freqs(1)):dt:(2*pi*Freqs(2));

%Preallocate a vector to store the step response characteristics.
[RiseTime, SettlingTime, PMO, Kds] = deal( zeros(1, length(ws) ) );

%Define the proportional constant.
Kp = 1;

%Compute the step response characteristics for each phase margin.
for k = 1:length(ws)                                             %Iterate through all of the phase margins...
    
    %Compute the derivative constant.
    Kds(k) = 1/ws(k);
    
    %Define the PI controller transfer function.
    Gc = tf([Kds(k) Kp], 1);
    
    %Get the PI controller closed loop transfer function.
    Gcl = feedback(Gc*Gs, Hs);
    
    %Generate the step response characteristics for the PI controlled closed loop system.
    StepData = stepinfo(Gcl);
    
    %Store the desired step response characteristics in arrays.
    RiseTime(k) = StepData.RiseTime;
    SettlingTime(k) = StepData.SettlingTime;
    PMO(k) = StepData.Overshoot;
    
end

%Store the step data in a structure for reference.
StepData = [];
StepData.Kd = Kds;
StepData.RiseTime = RiseTime;
StepData.SettlingTime = SettlingTime;
StepData.PMO = PMO;

%% Determine the Phase Margin that Best Satisfies the Design Requirements.

%Determine which time of type of time requirement should be considered.
if strcmp(TimeType, 'SettlingTime')
    TimeStat = StepData.SettlingTime;
else
    TimeStat = StepData.RiseTime;
end

%Compute the time stat error and PMO error.
t_err = TimeStat - t_crit;
PMO_err = StepData.PMO - PMO_crit;

%Store the errors as a column vector in the matrices.
err_mat = [t_err; PMO_err];

%Compute the magnitude of the error.
err_mag = vecnorm(err_mat);

%Determine the location of the minimum error.
[~, index] = min(err_mag);

%Retrieve the associated time statistic, PMO, and phase margin.
Kd = StepData.Kd(index);
TimeStat_crit = TimeStat(index);
PMO_crit = StepData.PMO(index);


%% Plot the Step Response Characteristics vs Phase Margin, if Requested.

%Plot the step response charactersitics vs phase margin, if requested.
if bPlotStepResponseStats
    figure, hold on, grid on, title('Rise Time vs Derivative Constant'), xlabel('Derivative Constant [-]'), ylabel('Rise Time [s]'), plot(StepData.Kd, StepData.RiseTime)
    figure, hold on, grid on, title('Settling Time vs Derivative Constant'), xlabel('Derivative Constant [-]'), ylabel('Settling Time [s]'), plot(StepData.Kd, StepData.SettlingTime)
    figure, hold on, grid on, title('PMO Time vs Derivative Constant'), xlabel('Derivative Constant [-]'), ylabel('PMO [%]'), plot(StepData.Kd, StepData.PMO)
end


end