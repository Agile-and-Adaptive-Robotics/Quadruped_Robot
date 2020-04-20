# --------------------------- SYNAPTIC CONDUCTANCE FUNCTION APPROXIMATION ---------------------------

# This script tests a methods of approximating the synaptic conductance function.


# --------------------------- IMPORT LIBRARIES ---------------------------

# Import standard python libraries.
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt

# Import nengo libraries.
import nengo
import nengo_dl
from nengo.processes import Piecewise
import nengo_extras.graphviz as gvz
from graphviz import Source
from nengo.utils.matplotlib import rasterplot
from nengo.dists import Choice
from nengo.utils.ensemble import response_curves, tuning_curves
import tensorflow as tf


# --------------------------- DEFINE THE CPG PARAMETERS ---------------------------

# Define the voltage range over which the CPG will oscillator over.
R = 20e-3                       # [V] Biphasic Equilibrium Voltage Range.

# Define membrane properties.
Cm = 5e-9                      # [F] Membrane Capacitance.
Gm = 1e-6                      # [S] Membrane Conductance.
Er = -60e-3                    # [V] Membrane Reversal Potential.

# Define synapse properties.
Elo = Er                        # [V] Synapse Voltage Lower Bound.
Ehi = Elo + R                   # [V] Synapse Voltage Upper Bound.
Es = -100e-3                    # [V] Synaptic Reversal Potential.
Es_tilde = Es - Er              # [V] Synaptic Reversal Potential w.r.t Membrane Reversal Potential.
delta = 0.01e-3                 # [V] Voltage Difference Between Inhibited Neuron's Equilibrium Potential & the Presynaptic Threshold.

# Define sodium channel activation properties.
Am = 1                          # [-] First Sodium Channel Activation Parameter.
Sm = -50                        # [1/V] Second Sodium Channel Activation Parameter.
Em = Ehi                        # [V] Third Sodium Channel Activation Parameter.
Em_tilde = Em - Er              # [V] Third Sodium Channel Activation Parameter w.r.t Membrane Reversal Potential.

# Define sodium channel deactivation properties.
Ah = 0.5                        # [-] First Sodium Channel Deactivation Parameter.
Sh = 50                         # [1/V] Second Sodium Channel Deactivation Parameter.
Eh = Elo                        # [V] Third Sodium Channel Deactivation Parameter.
Eh_tilde = Eh - Er              # [V] Third Sodium Channel Deactivation Parameter w.r.t Membrane Reversal Potential.

# Define the steady state sodium channel activation & deactivation parameters.
minf_func = lambda U:  1/(1 + Am*np.exp(-Sm*(Em_tilde - U)))            # [-] Lambda Function for the Steady State Sodium Channel Activation Parameter.
hinf_func = lambda U: 1/(1 + Ah*np.exp(-Sh*(Eh_tilde - U)))             # [-] Lambda Function for the Steady State Sodium Channel Deactivation Parameter.

# Define the sodium channel reversal potential.
Ena = 50e-3                 # [V] Sodium Channel Reversal Potential.
Ena_tilde = Ena - Er        # [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.

# Compute the sodium channel conductance.
Gna = (Gm*R)/(minf_func(R)*hinf_func(R)*(Ena_tilde - R))       # [S] Sodium Channel Conductance.

# Define the maximum & minimum sodium channel time constant.
tauhmax = 0.3               # [s] Maximum Sodium Channel Time Constant.
tauhmin = tauhmax/100       # [s] Minimum Sodium Channel Time Constant.

# Define a function to compute the sodium channel deactivation time constant.
tauh_func = lambda U: tauhmax*hinf_func(U)*np.sqrt(Ah*np.exp(-Sh*(Eh_tilde - U)))        # [s] Sodium Channel Time Constant.

# Compute the maximum synaptic conductance.
gsynmax = (-delta*(10**(-6)) - delta*Gna*minf_func(delta)*hinf_func(delta) + Gna*minf_func(delta)*hinf_func(delta)*Ena_tilde)/(delta - Es_tilde)

# Define the network initial conditions.
U0 = 0                      # [V] Initial Membrane Voltage w.r.t. Resting Potential.
# h0 = hinf_func(U0)          # [-] Initial Sodium Channel Deactivation Parameter.
h0 = 0          # [-] Initial Sodium Channel Deactivation Parameter.


# --------------------------- DEFINE NETWORK PROPERTIES ---------------------------

# Define simulation properties.
dt_sim = 0.001                                                      # [s] Simulation Step Size.
t_sim_duration = 3                                                  # [s] Total Simulation Duration.

# Define the LIF amplitude.
LIF_amplitude = 0.001

# Define the synaptic conductance ensemble properties.
gsyn_neurons = 100
gsyn_dimensions = 1
gsyn_radius = 2*R

# Define network properties.
seed = 0                                                            # [-] Seed for Random Number Generation.
# tau_synapse = 0.001                                                 # [s] Post-Synaptic Time Constant.
tau_synapse = None                                                 # [s] Post-Synaptic Time Constant.
tau_probe = 0.1                                                     # [s] Probe Time Constant.

# Define the input function.
def input_func(x):

    # Return the desired function.
    return R*(x - 1)

# Define the synaptic conductance function.
def synaptic_conductance_func(x):

    # Return the first rectified linear function.
    return gsynmax*np.minimum(np.maximum(x/R, 0), 1)
    # return np.minimum(np.maximum(x/R, 0), 1)
    # return np.sin(x)*x


# --------------------------- DEFINE TRAINING PROPERTIES ---------------------------

# Define training properties.
batch_size_train = 10000
minibatch_size_train = 50
n_train_epochs = 50
# learning_rate = 0.001
# learning_rate = 0.0001
learning_rate = 0.005*gsynmax


# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=LIF_amplitude)  # [-] Sets the neuron model to LIF.

# Build the network.
with network:

    # -------------------- Create the Network Components --------------------

    input_node = nengo.Node(output=input_func, label='Input Node')
    gsyn_ens = nengo.Ensemble(n_neurons=gsyn_neurons, dimensions=gsyn_dimensions, radius=gsyn_radius, seed=seed, label='gsyn Ensemble')
    output_node = nengo.Node(output=None, size_in=1, label='Output Node')

    # -------------------- Connect the Network Components --------------------

    nengo.Connection(input_node, gsyn_ens, synapse=tau_synapse)
    gsyn_conn = nengo.Connection(gsyn_ens, output_node, synapse=tau_synapse, function=synaptic_conductance_func)

    # -------------------- Collect Data From the Network --------------------

    input_probe = nengo.Probe(input_node, synapse=tau_probe)
    gsyn_probe = nengo.Probe(gsyn_ens, synapse=tau_probe)
    output_probe = nengo.Probe(output_node, synapse=tau_probe)
    output_probe_nofilt = nengo.Probe(output_node)

# Generate the contents of a .dot file that describes the network.
network_contents = gvz.net_diagram(network)

# Create a graphviz document using the network contents.
gvz_source = Source(network_contents, filename="network_diagram", format="jpg")


# --------------------------- SIMULATE THE UNTRAINED NETWORK ---------------------------

# Simulate the untrained network.
with nengo_dl.Simulator(network=network, dt=dt_sim) as sim:

    # Run the simulation.
    sim.run(t_sim_duration)

    # Retrieve the tuning curve data.
    gsyn_evals, gsyn_activites = tuning_curves(gsyn_ens, sim)


# --------------------------- PLOT THE UNTRAINED NETWORK RESULTS ---------------------------

# Retrieve the untrained network data.
ts_untrained = sim.trange()
gsyns_untrained = sim.data[output_probe]

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the network input and output.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Input [-]'); plt.title(r'Network Input vs Time (UNTRAINED)')
plt.plot(sim.trange(), sim.data[input_probe], label=r'Input')

plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Output [-]'); plt.title(r'Network Output vs Time (UNTRAINED)')
plt.plot(sim.trange(), sim.data[output_probe], label=r'Output')
plt.plot(sim.trange(), synaptic_conductance_func(sim.data[input_probe]), label=r'Output')

# Plot the tuning curves associated with the second rectified linear ensemble.
plt.figure(); plt.xlabel('Input [-]'); plt.ylabel('Firing Frequency [Hz]'); plt.title('Firing Frequency vs Input (UNTRAINED)')
plt.plot(gsyn_evals, gsyn_activites)


# ------------------------------------------- GENERATE NETWORK TRAINING DATA -------------------------------------------

# Create the training data inputs.
xs_training_input = input_func(np.random.uniform(0, t_sim_duration, size=(batch_size_train, 1, 1)))

# Compute the training data outputs.
ys_training_output = synaptic_conductance_func(xs_training_input)
# ys_training_output = 2*synaptic_conductance_func(xs_training_input)

# Training data dictionary.
input_training = {input_node: xs_training_input}
target_training = {output_probe_nofilt: ys_training_output}


# ------------------------------------------------- TRAIN THE NETWORK --------------------------------------------------

# Set the trainable aspects of the network.
with network:
    # Make all aspects of the network untrainable.
    nengo_dl.configure_settings(trainable=False)

    # Make the specific ensemble and connection of interest trainable.
    network.config[gsyn_ens].trainable = True
    network.config[gsyn_conn].trainable = True

with nengo_dl.Simulator(network=network, minibatch_size=minibatch_size_train) as sim:

    # Define the objective function we will use when training our SNN. (Note that the SNN will be converted to an ANN for training.)
    def train_objective(outputs, targets):

        # # Retrieve the symbolic input tensor.
        # inputs = sim.tensor_graph.input_ph[x_node]
        #
        # # Compute the gradient of the network output with respect to the input.
        # dydx = tf.transpose(tf.gradients(outputs, inputs)[0], (2, 0, 1))  # This is no longer None!
        #
        # # Print dydx (for debugging).
        # print('dydx =', dydx)

        # Compute the loss of this output.
        return tf.reduce_mean(tf.square(outputs - targets))     # Standard MSE.  This works fine.
        # return tf.reduce_mean(tf.square(dydx))                    # Example error that uses gradient term.  This yields "TypeError: Second-order gradient for while loops not supported."

    # Setup the optimizer and loss functions.
    # sim.compile(optimizer=tf.optimizers.RMSprop(0.01), loss={output_probe_nofilt: tf.losses.mse})
    sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={output_probe_nofilt: train_objective})

    # Train the network.
    sim.fit(input_training, target_training, epochs=n_train_epochs)

    # Freeze the parameters.
    sim.freeze_params(network)


# -------------------------------------------- SIMULATE THE TRAINED NETWORK --------------------------------------------

# Setup the simulation.
with nengo_dl.Simulator(network=network, dt=dt_sim) as sim:

    # Run the simulation.
    sim.run(t_sim_duration)


# --------------------------- PLOT THE TRAINED NETWORK RESULTS ---------------------------

# Plot the network input and output.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Input [-]'); plt.title(r'Network Input vs Time (TRAINED)')
plt.plot(sim.trange(), sim.data[input_probe], label=r'Input')

plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Output [-]'); plt.title(r'Network Output vs Time (TRAINED)')
plt.plot(ts_untrained, gsyns_untrained, label=r'Untrained SNN')
plt.plot(sim.trange(), sim.data[output_probe], label=r'Trained SNN')
plt.plot(sim.trange(), synaptic_conductance_func(sim.data[input_probe]), label=r'True')
# plt.plot(sim.trange(), 2*synaptic_conductance_func(sim.data[input_probe]), label=r'True')
plt.legend()

# Plot the tuning curves associated with the second rectified linear ensemble.
plt.figure(); plt.xlabel('Input [-]'); plt.ylabel('Firing Frequency [Hz]'); plt.title('Firing Frequency vs Input (TRAINED)')
plt.plot(gsyn_evals, gsyn_activites)



# # Show the network.
# gvz_source.view()

# Display the figures.
plt.show()


