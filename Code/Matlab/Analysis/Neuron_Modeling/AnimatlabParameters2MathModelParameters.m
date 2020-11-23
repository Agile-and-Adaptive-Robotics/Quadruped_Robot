%% Animatlab Parameters -> Mathematical Model Parameters

% Clear Everything.
clear, close('all'), clc


%%  Define the Animatlab Parameters.

% Read in the Animatlab neuron data.
animatlab_neuron_data = readtable('C:\Users\USER\Documents\GitHub\Quadruped_Robot\Animatlab\Quadruped_Models\Quadruped_Multistate_CPG\AnimatlabProperties.xlsx', 'Sheet', 'Neuron_Properties', 'DataRange', 'A3', 'VariableNamesRange', 'A2');

% Read in the Animatlab syanpse data.
animatlab_synapse_data = readtable('C:\Users\USER\Documents\GitHub\Quadruped_Robot\Animatlab\Quadruped_Models\Quadruped_Multistate_CPG\AnimatlabProperties.xlsx', 'Sheet', 'Synapse_Properties', 'DataRange', 'A2', 'VariableNamesRange', 'A1');


%% Convert the Animatlab Parameters to Mathematical Model Parameters.

% Retrieve the number of neurons.
num_neurons = size(animatlab_neuron_data, 1);

% Retrieve the number of synapses.
num_synapses = size(animatlab_synapse_data, 1);

% Preallocate variables to store the synapse properties.
[Rs, gsyn_maxs, dEsyns] = deal( zeros(num_neurons, num_neurons) );

% Convert the neuron properties.
Ers = animatlab_neuron_data.RestingPotential;
Gms = (1e-6)*ones(num_neurons, 1);
Cms = animatlab_neuron_data.TimeConstant.*Gms;
Ams = ones(num_neurons);
Sms = -(10^3)*animatlab_neuron_data.CaActivationSlope;
dEms = animatlab_neuron_data.CaActivationMidPoint - Ers;
Ahs = 0.5*ones(num_neurons);
Shs = -(10^3)*animatlab_neuron_data.CaDeactivationSlope;
dEhs = animatlab_neuron_data.CaDeactivationMidPoint - Ers;
tauh_maxs = animatlab_neuron_data.CaDeactivationTimeConstant;
Gnas = animatlab_neuron_data.MaxCaConductance;
dEnas = animatlab_neuron_data.CaEquilPotential;

% Convert the synapse properties.
for k = 1:num_synapses                      % Iterate through each of the synapses...
    
    % Retrieve the row and column indexes where we intend to store these values.
    row = animatlab_synapse_data.To(k);
    col = animatlab_synapse_data.From(k);
    
    % Convert the properties of this synapse.
    Rs(row, col) = animatlab_synapse_data.Pre_SynapticSaturationLevel(k) - animatlab_synapse_data.Pre_SynapticThreshold(k);
    gsyn_maxs(row, col) = animatlab_synapse_data.MaxSynapticConductance(k);
    dEsyns(row, col) = animatlab_synapse_data.EquilibriumPotential(k) - animatlab_neuron_data.RestingPotential(col);
    
end

