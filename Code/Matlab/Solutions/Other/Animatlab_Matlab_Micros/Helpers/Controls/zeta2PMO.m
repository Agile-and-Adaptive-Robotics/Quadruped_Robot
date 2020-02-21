function [ PMO ] = zeta2PMO( zeta )

%Compute the PMO.
if (zeta >= 0) && (zeta <= 1)                           %If the zeta value is valid...
    PMO = 100*exp((-pi*zeta)./sqrt(1 - zeta.^2));       %Compute the PMO.
else
    error('Invalid zeta value.  Valid zetas are 0 < zeta <= 1.')
end

end

