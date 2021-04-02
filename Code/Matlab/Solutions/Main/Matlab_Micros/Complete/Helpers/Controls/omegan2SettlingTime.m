function [ ts ] = omegan2SettlingTime( omegan, zeta )

%Set the default damping ratio.
if nargin < 2, zeta = 1; end

%Compute the setting time associated with the given natural frequency and damping ratio.
if (zeta > 0.69) && (zeta <= 1)             %If zeta is between 0.69 and 1...
    ts = (4.5*zeta)./omegan;                %Use the first formula.
elseif (zeta > 0) && (zeta <= 0.69)         %If zeta is between 0 and 0.69...
    ts = 3.2./(zeta.*omegan);               %Use the second formula.
else
   error('Invalid zeta value.  Valid zetas are 0 < zeta <= 1.')
end


end

