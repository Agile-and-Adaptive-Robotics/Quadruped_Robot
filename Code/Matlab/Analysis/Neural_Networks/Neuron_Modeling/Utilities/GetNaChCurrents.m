function [Inas, minfs, hinfs, tauhs] = GetNaChCurrents(Us, hs, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas)

% This function computes the sodium channel current for each neuron in a network.

% Inputs:
    % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potential.
    % hs = num_neurons x 1 vector of neuron sodium channel deactivation parameters.
    % Ams = num_neurons x 1 vector of sodium channel activation A parameter values.
    % Sms = num_neurons x 1 vector of sodium channel activation S parameter values.
    % dEms = num_neurons x 1 vector of sodium channel activation parameter reversal potentials.
    % Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
    % Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
    % dEhs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
    % tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
    % Gnas = num_neurons x 1 vector of sodium channel conductances for each neuron.
    % dEnas = num_neurons x 1 vector of sodium channel reversal potentials for each neuron.
    
% Outputs:
    % Inas = num_neurons x 1 vector of sodium channel currents for each neuron.
    % minfs = num_neurons x 1 vector of neuron steady state sodium channel activation values.
    % hinfs = num_neurons x 1 vector of neuron steady state sodium channel deactivation values.
    % tauhs = num_neurons x 1 vector of sodium channel deactivation parameter time constants.

% Compute the steady state sodium channel activation parameters.
minfs = GetSteadyStateNaActDeactValue(Us, Ams, Sms, dEms);

% Compute the steady state sodium channel deactivation parameters.
hinfs = GetSteadyStateNaActDeactValue(Us, Ahs, Shs, dEhs);

% Compute the sodium channel deactivation time constants.
tauhs = GetNaDeactTimeConst(Us, tauh_maxs, hinfs, Ahs, Shs, dEhs);

% Compute the sodium channel currents.
Inas = Gnas.*minfs.*hs.*(dEnas - Us);

end

