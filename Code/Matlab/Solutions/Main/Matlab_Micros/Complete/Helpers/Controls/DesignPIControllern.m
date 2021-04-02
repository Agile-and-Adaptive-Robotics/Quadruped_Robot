function [ Pm_crit ] = DesignPIControllern( Gs, Hs, TimeType, t_crit, PMO_crit, bPlotStepResponseStats )
%% Set Default Parameters.

%Turn off the plotting option by default.
if nargin < 6, bPlotStepResponseStats = false; end

%Ensure that the TimeType setting is recognized.
if (~strcmp(TimeType, 'SettlingTime')) && (~strcmp(TimeType, 'RiseTime'))
    error('Requirement type not recognized.  Must be either "SettlingTime" or "RiseTime." Defaulting to "SettlingTime."')
end

%Define the target vector.
V_target = [t_crit; PMO_crit];

%% Define the Initial Values for the Secant Method.

%Compute the original phase margin of the system.
[~, Pm0] = margin(Hs*Gs);

%Compute a second initial value for the secant method.
if (Pm0 + 10) < 360
    Pm1 = Pm0 + 10;
else
    Pm1 = Pm0 - 10;
end

%Define the starting guess values.
Pms0 = [Pm0 Pm1];

%% Determine the Phase Margin that Produces the Best Match for the Target Vector.

Pm = linspace(30, 60, 10);
err_mag = zeros(1, length(Pm));
for k = 1:length(Pm)
    err_mag(k) = GetStepError(Gs, Hs, Pm(k), TimeType, V_target);
end


options = optimset('TolX', 1e1);

Pm_crit = fzero(@(x) GetStepError(Gs, Hs, x, TimeType, V_target), 45, options);



%% Define the Function whose Root we Want to Find

    function err_mag = GetStepError(Gs, Hs, Pm, TimeType, V_target)
        
        %Get the PI controller associated with this phase margin.
        Cpi = GetPIController( Hs*Gs, Pm );
        
        %Compute the closed loop transfer function.
        Gs_picl = feedback(Cpi*Gs, Hs);
        
        %Compute the step response characteristics associated this PI-Controlled Closed Loop System.
        stepdata = stepinfo(Gs_picl);
        
        %Retrieve the PMO value.
        PMO = stepdata.Overshoot;
        
        %Retrieve the required time value (either settling time or rise time).
        if strcmp(TimeType, 'SettlingTIme')
            Time = stepdata.SettlingTime;
        else
            Time = stepdata.RiseTime;
        end
        
        %Create a vector from these values.
        V_result = [Time; PMO];
        
        %Compute the error vector.
        V_err = V_result - V_target;
        
        %Compute the magnitude of this vector.
        err_mag = norm(V_err);
        
    end


end