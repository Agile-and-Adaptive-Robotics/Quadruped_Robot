function [ R1_crit, R2_crit, Kp_crit ] = GetPCircuitComponents( rs, Kp_target, bRestrictRange )

%By default, consider the entire provided resistor and capacitor range.
if nargin < 5, bRestrictRange = false; end

%If requested, restrict the range of available resistors and capacitors to the ideal range.
if bRestrictRange, rs = rs((rs >= 5000) & (rs <= 50000)); end

%Create a grid of the available resistors and capacitors.
[Rs1, Rs2] = meshgrid( rs, rs );

%Generate all possible Kp values.
Kp = Rs2./Rs1;

%Define the total number of options.
numopts = size(Kp, 1)*size(Kp, 2);

%Preallocate a vector to store the error values.
Err = zeros(1, numopts);

%Compute the error associated with each choice of resistors.
for k = 1:numopts                       %Iterate through each of the resistor options...
   Err(k) = abs(Kp(k) - Kp_target);
end
    
%Get the minimum error location.
[~, index] = min(Err);

%Retrieve the Kp values that are most similar to the target values.
Kp_crit = Kp(index);

%Retrieve the resistor values that achieve the most accurate target values.
R1_crit = Rs1(index); R2_crit = Rs2(index);

end