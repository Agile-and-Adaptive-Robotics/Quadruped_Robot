function [ sys, hsv ] = DERA(impulse_data, dt, mode, parameter)

%Generate the ERA system matrices.
if nargin == 4
    [A, B, C, D, hsv] = ERA(impulse_data, mode, parameter);
elseif nargin == 3
    [A, B, C, D, hsv] = ERA(impulse_data, mode);
elseif nargin == 2
    [A, B, C, D, hsv] = ERA(impulse_data);
else
    error('Not enough input arugments')
end

%Create a discrete state space model from the ERA system matrices.
sys = ss(A, B, dt*C, dt*D, dt);

end

