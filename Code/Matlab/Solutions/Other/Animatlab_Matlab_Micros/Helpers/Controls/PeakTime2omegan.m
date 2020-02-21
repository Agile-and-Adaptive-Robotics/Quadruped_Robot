function [ omegan ] = PeakTime2omegan( tp, zeta )

%Set the default damping ratio.
if nargin < 2, zeta = 1; end

%Validate the zeta input.
if ~((zeta >= 0) && (zeta <= 1)), error('Invalid zeta value.  Valid zetas are 0 < zeta <= 1.'); end

%Compute the peak time.
omegan = pi./(tp.*sqrt(1 - (zeta.^2)));

end

