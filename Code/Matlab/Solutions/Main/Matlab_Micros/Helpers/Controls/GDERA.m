function [ sys, hsv ] = GDERA( ys_arb, us_arb, dt, mode, parameter )
%% Reconstruct the Impulse Response from the Given Response.

%Generate the hankle matrix associated with the system input.
U = GetHankleMatrix( us_arb );

%Approximate the impulse response.
ys_impulse_okid = (ys_arb*pinv(U))/dt;

%% Apply ERA to the OKID Reconstructed Impulse Response.

%Generate the ERA system matrices.
if nargin == 5
[ sys, hsv ] = DERA(ys_impulse_okid', dt, mode, parameter);
elseif nargin == 4
[ sys, hsv ] = DERA(ys_impulse_okid', dt, mode);
elseif nargin == 3
    [ sys, hsv ] = DERA(ys_impulse_okid', dt);
else
    error('Not enough input arguments.')
end


end

