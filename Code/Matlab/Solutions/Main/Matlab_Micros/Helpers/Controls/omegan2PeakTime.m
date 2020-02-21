function [ tp ] = omegan2PeakTime( omegan, zeta )

%Set the default damping ratio.
if nargin < 2, zeta = 1; end

%Validate the zeta input.
if ~((zeta >= 0) && (zeta <= 1)), error('Invalid zeta value.  Valid zetas are 0 < zeta <= 1.'); end

%Compute the peak time.
tp = pi./(omegan.*sqrt(1 - (zeta.^2)));

end

