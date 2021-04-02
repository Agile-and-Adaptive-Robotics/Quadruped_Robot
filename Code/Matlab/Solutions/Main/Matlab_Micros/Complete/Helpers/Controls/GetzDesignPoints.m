function [ z ] = GetzDesignPoints( omegan, zeta, T )

%Compute the damped frequency.
omegad = omegan*sqrt(1 - (zeta.^2));

%Compute the real and imaginary components of the design point.
rez = exp(-T*zeta*omegan)*cos(omegad*T);
imz = exp(-T*zeta*omegan)*sin(omegad*T);

%Compute the design points.
if imz ~= 0                          %If there is an imaginary component to the design point...
    %Compute the two desigin points.
    z(1) = rez + 1i*imz;
    z(2) = rez - 1i*imz;
else
    %Compute the single design point.
    z = rez;
end

end

