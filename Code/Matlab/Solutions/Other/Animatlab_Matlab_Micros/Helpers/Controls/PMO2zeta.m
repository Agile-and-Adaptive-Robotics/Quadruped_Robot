function [ zeta ] = PMO2zeta( PMO )

%Compute the damping ratio associated with the given PMO.
if PMO == 0                                                             %If we want zero overshoot...
    zeta = 1;                                                           %Set the damping ratio to 0.
elseif (PMO > 0) && (PMO <= 100)                                        %If the PMO is not zero but still valid...
    zeta = abs(log(PMO/100))./sqrt(pi^2 + log(PMO/100).^2);             %Compute the PMO with the given formula.
else
    error('Invalid PMO value.  Valid PMOs are 0 < PMO <= 100.')
end


end

