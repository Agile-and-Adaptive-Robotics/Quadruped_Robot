function [ s ] = GetsDesignPoints( omegan, zeta )

%Compute the damped frequency.
omegad = omegan*sqrt(1 - (zeta.^2));

%Compute the design points.
if omegad ~= 0                          %If there is an imaginary component to the design point...
    %Compute the two desigin points.
    s(1) = -zeta*omegan + 1i*omegad;
    s(2) = -zeta*omegan - 1i*omegad;
else
    %Compute the single design point.
    s = -zeta*omegan;
end

end

