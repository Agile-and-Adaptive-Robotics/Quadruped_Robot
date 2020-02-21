function [ tr ] = omegan2RiseTime( omegan, zeta, Type )

%Set the default arguments.
if nargin < 3, Type = 'Quadratic'; end
if nargin < 2, zeta = 1; end

%Validate the zeta input.
if ~((zeta >= 0) && (zeta <= 1)), error('Invalid zeta value.  Valid zetas are 0 < zeta <= 1.'); end

%Compute the rise time.
if strcmp(Type, 'Linear')
    tr = (0.8 + 2.5*zeta)./omegan;
elseif strcmp(Type, 'Quadratic')
    tr = (1 - 0.4167*zeta + 2.917*(zeta.^2))./omegan;
else
    error('Invalid approximation type. Valid Types are ''Linear'' and ''Quadratic''. ')
end


end

