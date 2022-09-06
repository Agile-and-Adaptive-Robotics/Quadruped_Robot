function tauhs = GetNaDeactTimeConst(Us, tauh_maxs, hinfs, Ahs, Shs, dEhs)

% This function computes the sodium channel deactivation time constant associated with each neuron in a network.

% Inputs:
    % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potential.
    % tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
    % hinfs = num_neurons x 1 vector of steady state sodium channel deactivation parameter values.
    % Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
    % Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
    % dEhs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.

% Outputs:
    % tauhs = num_neurons x 1 vector of sodium channel deactivation parameter time constants.

% Compute the sodium channel deactivation time constant.
tauhs = tauh_maxs.*hinfs.*sqrt( Ahs.*exp( -Shs.*(dEhs - Us) ) );

end

