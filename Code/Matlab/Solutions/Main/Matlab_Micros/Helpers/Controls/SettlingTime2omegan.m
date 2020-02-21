function [ omegan ] = SettlingTime2omegan( ts, zeta )

%Set the default damping ratio.
if nargin < 2, zeta = 1; end

%Compute the natural frequency associated with the given settling time and damping ratio.
if (zeta > 0.69) && (zeta <= 1)             %If zeta is between 0.69 and 1...
    omegan = (4.5*zeta)./ts;                %Use the first formula.
elseif (zeta > 0) && (zeta <= 0.69)         %If zeta is between 0 and 0.69...
    omegan = 3.2./(zeta.*ts);               %Use the second formula.
else
   error('Invalid zeta value.  Valid zetas are 0 < zeta <= 1.')
end

end

