function [ R1_crit, R2_crit, C_crit, Kp_crit, Kd_crit ] = GetPDCircuitComponents( rs, cs, Kp, Kd, bRestrictRange )

%By default, consider the entire provided resistor and capacitor range.
if nargin < 5, bRestrictRange = false; end

%If requested, restrict the range of available resistors and capacitors to the ideal range.
if bRestrictRange, [rs, cs] = deal( rs((rs >= 5000) & (rs <= 50000)), cs((cs >= 0.01e-6) & (cs <= 1e-6)) ); end

%Turn the desired Kp & Kd values into a vector.
Ktarget = [Kp; Kd];

%Create a grid of the available resistors and capacitors.
[Rs1, Rs2, Cs] = meshgrid( rs, rs, cs );

%Generate all possible Kp & Kd Values.
Kp = Rs2./Rs1; Kd = Rs2.*Cs;

%Define the total number of options.
numopts = size(Kp, 1)*size(Kp, 2)*size(Kp, 3);

%Preallocate a vector to store the error values.
Err = zeros(1, numopts);

%Compute the error associated with each choice of resistors and capacitor.
for k = 1:numopts                       %Iterate through each of the resistor / capacitor options...

   %Create a vector from the current Kp & Kd values.
   Ks = [Kp(k); Kd(k)]; 
    
   %Compute an error vector for the current Kp & Kd values.
   Kerr = Ks - Ktarget;
   
   %Get the magnitude of the error vector.
   Err(k) = norm(Kerr);
   
end
    
%Get the minimum error location.
[~, index] = min(Err);

%Retrieve the Kp & Ki values that are most similar to the target values.
Kp_crit = Kp(index); Kd_crit = Kd(index);

%Retrieve the resistors and capacitor values that achieve the most accurate target values.
R1_crit = Rs1(index); R2_crit = Rs2(index); C_crit = Cs(index);


end

