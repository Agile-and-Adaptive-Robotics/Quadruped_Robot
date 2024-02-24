function [dUs, dhs, Gsyns, Ileaks, Isyns, Inas, Itotals, minfs, hinfs, tauhs] = NetworkStep(Us, hs, Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapp)

% This function computes a single step of a neural network without sodium channels.

% Inputs:
    % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.
    % hs = num_neurons x 1 vector of neuron sodium channel deactivation parameters.
    % Gms = num_neurons x 1 vector of neuron membrane conductances.
    % Cms = num_neurons x 1 vector of neuron membrane capacitances.
    % Rs = num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
    % gsyn_maxs = num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
    % dEsyns = num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
    % Ams = num_neurons x 1 vector of sodium channel activation A parameter values.
    % Sms = num_neurons x 1 vector of sodium channel activation S parameter values.
    % dEms = num_neurons x 1 vector of sodium channel activation parameter reversal potentials.
    % Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
    % Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
    % dEhs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
    % tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
    % Gnas = num_neurons x 1 vector of sodium channel conductances for each neuron.
    % dEnas = num_neurons x 1 vector of sodium channel reversal potentials for each neuron.
    % Iapp = num_neurons x 1 vector of applied currents for each neuron.

% Outputs:
    % dUs = num_neurons x 1 vector of neuron membrane voltage derivatives w.r.t their resting potentials.
    % dhs = num_neurons x 1 vector of neuron sodium channel deactivation parameter derivatives.
    % Gsyns = num_neurons x num_neurons matrix of synaptic conductances.  Entry ij represents the synaptic conductance from neuron j to neuron i.
    % Ileaks = num_neurons x 1 vector of leak currents for each neuron.
    % Isyns = num_neurons x 1 vector of synaptic currents for each neuron.
    % Inas = num_neurons x 1 vector of sodium channel currents for each neuron.
    % Itotals = num_neurons x 1 vector of total currents for each neuron.
    % minfs = num_neurons x 1 vector of neuron steady state sodium channel activation values.
    % hinfs = num_neurons x 1 vector of neuron steady state sodium channel deactivation values.
    % tauhs = num_neurons x 1 vector of sodium channel deactivation parameter time constants.
    
% Compute the leak currents.
Ileaks = GetLeakCurrent(Us, Gms);

% Compute synaptic currents.
[Isyns, Gsyns] = GetSynapticCurrents(Us, Rs, gsyn_maxs, dEsyns);

% Compute the sodium channel currents.
[Inas, minfs, hinfs, tauhs] = GetNaChCurrents(Us, hs, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas);

% Compute the total currents.
Itotals = Ileaks + Isyns + Inas + Iapp;

% Compute the membrane voltage derivatives.
dUs = Itotals./Cms;

% Compute the sodium channel deactivation parameter derivatives.
dhs = (hinfs - hs)./tauhs;


end

