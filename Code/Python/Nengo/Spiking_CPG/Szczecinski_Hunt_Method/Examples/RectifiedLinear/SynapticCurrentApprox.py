# --------------------------- SYNAPTIC CURRENT FUNCTION APPROXIMATION ---------------------------

# This script tests a method of approximating the synaptic current function.


# --------------------------- IMPORT LIBRARIES ---------------------------

# Import standard python libraries.
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt

# Import nengo libraries.
import nengo
import nengo_dl
import tensorflow as tf
from nengo.processes import Piecewise
import nengo_extras.graphviz as gvz
from graphviz import Source
from nengo.utils.matplotlib import rasterplot
from nengo.dists import Choice
from nengo.utils.ensemble import response_curves, tuning_curves


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

# Define the membrane voltage ensemble properties.
U_neurons = 100
U_dimensions = 1
U_radius = 2*R

# Define the synaptic conductance ensemble properties.
gsyn_neurons = 100
gsyn_dimensions = 1
gsyn_radius = 2*gsynmax

# Define the synaptic current multiplexer ensemble properties.
MUXsyn_neurons = 1000
MUXsyn_dimensions = 2
MUXsyn_radius = 1

# Define the synaptic current ensemble properties.
Isyn_neurons = 1000
Isyn_dimensions = 1
Isyn_radius = 75e-9

# Define network properties.
seed = 0                                                            # [-] Seed for Random Number Generation.
# tau_synapse = 0.001                                                 # [s] Post-Synaptic Time Constant.
tau_synapse = None                                                 # [s] Post-Synaptic Time Constant.
tau_probe = 0.1                                                     # [s] Probe Time Constant.


# --------------------------- DEFINE THE FUNCTIONS TO APPROXIMATE ---------------------------

# Define the input function.
def input_func(x):

    # Return the desired function.
    return R*(x - 1)

# Define the synaptic conductance function.
def synaptic_conductance_func(x):

    # Return the first rectified linear function.
    return gsynmax*np.minimum(np.maximum(x/R, 0), 1)

# Define a function to compute the synaptic current.
def synapse_current_func(x):

    # Retrieve the components of the input vector.
    U, Gsi = x

    # Compute the synaptic current.
    return (Gsi*gsyn_radius)*(Es_tilde - (U*U_radius))

# Define a function to compute the synaptic current.
def synapse_current_func_two_inputs(U, Gsi):

    # Compute the synaptic current.
    return (Gsi*gsyn_radius)*(Es_tilde - (U*U_radius))


# --------------------------- COMPUTE GROUND TRUTH SIMULATION RESULTS ---------------------------

# Compute the ground truth simulation results that we want to achieve.
ts_true = np.arange(0, t_sim_duration, dt_sim)
input_true = input_func(ts_true)
Us_true = input_true
gsyn_true = synaptic_conductance_func(Us_true)
Isyn_true = synapse_current_func_two_inputs(Us_true/U_radius, gsyn_true/gsyn_radius)


# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=LIF_amplitude)  # [-] Sets the neuron model to LIF.

# Build the network.
with network:

    # -------------------- Create the Network Components --------------------

    input_node = nengo.Node(output=input_func, label='Input Node')
    U_ens = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dimensions, radius=U_radius, seed=seed, label='U_ens')
    gsyn_ens = nengo.Ensemble(n_neurons=gsyn_neurons, dimensions=gsyn_dimensions, radius=gsyn_radius, seed=seed, label='gsyn Ensemble')
    MUXsyn_ens = nengo.Ensemble(MUXsyn_neurons, dimensions=MUXsyn_dimensions, radius=MUXsyn_radius, seed=seed, label='MUXsyn Ensemble')
    # MUXsyn_ens = nengo.Ensemble(MUXsyn_neurons, dimensions=MUXsyn_dimensions, radius=MUXsyn_radius, seed=seed, label='MUXsyn Ensemble', neuron_type=nengo.Direct())
    Isyn_ens = nengo.Ensemble(n_neurons=Isyn_neurons, dimensions=Isyn_dimensions, radius=Isyn_radius, seed=seed, label='Isyn Ensemble')
    output_node = nengo.Node(output=None, size_in=1, label='Output Node')

    # -------------------- Connect the Network Components --------------------

    nengo.Connection(input_node, U_ens, synapse=tau_synapse)
    gsyn_conn = nengo.Connection(U_ens, gsyn_ens, synapse=tau_synapse, function=synaptic_conductance_func)
    nengo.Connection(U_ens, MUXsyn_ens[0], synapse=tau_synapse, transform=1/U_radius)
    nengo.Connection(gsyn_ens, MUXsyn_ens[1], synapse=tau_synapse, transform=1/gsyn_radius)
    Isyn_conn = nengo.Connection(MUXsyn_ens, Isyn_ens, synapse=tau_synapse, function=synapse_current_func)
    nengo.Connection(Isyn_ens, output_node, synapse=tau_synapse)

    # -------------------- Collect Data From the Network --------------------

    input_probe = nengo.Probe(input_node, synapse=tau_probe)
    U_probe = nengo.Probe(U_ens, synapse=tau_probe)
    gsyn_probe = nengo.Probe(gsyn_ens, synapse=tau_probe)
    gsyn_probe_nofilt = nengo.Probe(gsyn_ens)
    MUXsyn_probe = nengo.Probe(MUXsyn_ens, synapse=tau_probe)
    Isyn_probe = nengo.Probe(Isyn_ens, synapse=tau_probe)
    Isyn_probe_nofilt = nengo.Probe(output_node)

# Generate the contents of a .dot file that describes the network.
network_contents = gvz.net_diagram(network)

# Create a graphviz document using the network contents.
gvz_source = Source(network_contents, filename="network_diagram", format="jpg")

# --------------------------- SIMULATE THE NETWORK ---------------------------

# Simulate the network.
with nengo_dl.Simulator(network=network, dt=dt_sim) as sim:

    # Run the simulation.
    sim.run(t_sim_duration)

    # # Retrieve the tuning curve data.
    # gsyn_evals, gsyn_activites = tuning_curves(gsyn_ens, sim)

# Retrieve the untrained simulation results.
ts_untrained = sim.trange()
input_untrained = sim.data[input_probe]
Us_untrained = sim.data[U_probe]
gsyn_untrained = sim.data[gsyn_probe]
MUXsyn_untrained = sim.data[MUXsyn_probe]
Isyn_untrained = sim.data[Isyn_probe]


# --------------------------- RETRIEVE THE UNTRAINED NETWORK RESULTS ---------------------------

# # Set plot properties.
# plt.rc('text', usetex=True)
#
# # Plot the network input.
# plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Input [-]'); plt.title(r'Network Input vs Time (UNTRAINED)')
# plt.plot(ts_untrained, input_untrained, label=r'Input Node')
# plt.plot(ts_true, input_true, label=r'Input True')
# plt.legend()
#
# # Plot the membrane voltage.
# plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Membrane Voltage, $U$ [V]'); plt.title(r'Membrane Voltage $U$ vs Time (UNTRAINED)')
# plt.plot(ts_untrained, Us_untrained, label=r'$U$ Ensemble')
# plt.plot(ts_true, Us_true, label=r'$U$ True')
# plt.legend()
#
# # Plot the synaptic conductance.
# fig, axs = plt.subplots(2, 1)
# axs[0].set_xlabel('Time [s]'); axs[0].set_ylabel('Synaptic Conductance, $g_{syn}$ [S]'); axs[0].set_title(r'Synaptic Conductance, $g_{syn}$ vs Time (UNTRAINED)')
# axs[0].plot(ts_untrained, gsyn_untrained, label=r'$g_{syn}$ Ensemble')
# axs[0].plot(ts_true, gsyn_true, label=r'$g_{syn}$ True')
# axs[0].legend()
# axs[1].set_xlabel('Membrane Voltage, $U$ [V]'); axs[1].set_ylabel('Synaptic Conductance, $g_{syn}$ [S]'); axs[1].set_title(r'Synaptic Conductance, $g_{syn}$ vs Membrane Voltage $U$ (UNTRAINED)')
# axs[1].plot(Us_untrained, gsyn_untrained, label=r'$g_{syn}$ Ensemble')
# axs[1].plot(Us_true, gsyn_true, label=r'$g_{syn} True$')
# axs[1].legend()
#
# # Plot the synaptic current multiplexer.
# fig, axs = plt.subplots(2, 2)
#
# axs[0, 0].set_xlabel('Time [s]'); axs[0, 0].set_ylabel('MUX Membrane Voltage, $U$ [V]'); axs[0, 0].set_title(r'MUX Membrane Voltage, $U$ vs Time (UNTRAINED)')
# axs[0, 0].plot(ts_untrained, MUXsyn_untrained[:, 0], label=r'$U$ MUX Ensemble')
# axs[0, 0].plot(ts_true, Us_true/U_radius, label=r'$U$ True')
# axs[0, 0].legend()
#
# axs[0, 1].set_xlabel('Time [s]'); axs[0, 1].set_ylabel('MUX Synaptic Conductance, $g_{syn}$ [S]'); axs[0, 1].set_title(r'MUX Synaptic Conductance, $g_{syn}$ vs Time (UNTRAINED)')
# axs[0, 1].plot(ts_untrained, MUXsyn_untrained[:, 1], label=r'$g_{syn}$ MUX Ensemble')
# axs[0, 1].plot(ts_true, gsyn_true/gsyn_radius, label=r'$g_{syn}$ True')
# axs[0, 1].legend()
#
# axs[1, 0].set_xlabel('Membrane Voltage, $U$ [V]'); axs[1, 0].set_ylabel('MUX Membrane Voltage, $U$ [V]'); axs[1, 0].set_title(r'MUX Membrane Voltage, $U$ vs Membrane Voltage, $U$ (UNTRAINED)')
# axs[1, 0].plot(Us_untrained, MUXsyn_untrained[:, 0], label=r'$U$ MUX Ensemble')
# axs[1, 0].plot(Us_true, Us_true/U_radius, label=r'$U$ True')
# axs[1, 0].legend()
#
# axs[1, 1].set_xlabel('Membrane Voltage, $U$ [V]'); axs[1, 1].set_ylabel('MUX Synaptic Conductance, $g_{syn}$ [S]'); axs[1, 1].set_title(r'MUX Synaptic Conductance, $g_{syn}$ vs Membrane Voltage, $U$ (UNTRAINED)')
# axs[1, 1].plot(Us_untrained, MUXsyn_untrained[:, 1], label=r'$g_{syn}$ MUX Ensemble')
# axs[1, 1].plot(Us_true, gsyn_true/gsyn_radius, label=r'$g_{syn}$ True')
# axs[1, 1].legend()
#
# # Plot the synaptic current.
# fig, axs = plt.subplots(2, 1)
# axs[0].set_xlabel('Time [s]'); axs[0].set_ylabel('Synaptic Current, $I_{syn}$ [A]'); axs[0].set_title(r'Synaptic Current, $I_{syn}$ vs Time (UNTRAINED)')
# axs[0].plot(ts_untrained, Isyn_untrained, label=r'$I_{syn}$ Ensemble ')
# axs[0].plot(ts_true, Isyn_true, label=r'$I_{syn}$ True')
# axs[0].legend()
# axs[1].set_xlabel('Membrane Voltage, $U$ [V]'); axs[1].set_ylabel('Synaptic Current, $I_{syn}$ [A]'); axs[1].set_title(r'Synaptic Current, $I_{syn}$ vs Membrane Voltage, $U$ (UNTRAINED)')
# axs[1].plot(Us_untrained, Isyn_untrained, label=r'$I_{syn}$ Ensemble')
# axs[1].plot(Us_true, Isyn_true, label=r'$I_{syn}$ True')
# axs[1].legend()

# # Plot the tuning curves associated with the second rectified linear ensemble.
# plt.figure(); plt.xlabel('Input [-]'); plt.ylabel('Firing Frequency [Hz]'); plt.title('Firing Frequency vs Input')
# plt.plot(gsyn_evals, gsyn_activites)


# --------------------------- DEFINE TRAINING PROPERTIES ---------------------------

# Define training properties.
batch_size_train = 10000
minibatch_size_train = 50
n_train_epochs = 50
# learning_rate = 0.001
# learning_rate = 1e-6
learning_rate = 0.005*gsynmax


# ------------------------------------------- GENERATE NETWORK TRAINING DATA -------------------------------------------

# Create the training data inputs.
Us_training = input_func(np.random.uniform(0, t_sim_duration, size=(batch_size_train, 1, 1)))

# Compute the training data outputs.
gsyn_training = synaptic_conductance_func(Us_training)
Isyn_training = synapse_current_func_two_inputs(Us_training/U_radius, gsyn_training/gsyn_radius)

# Training data dictionary.
input_training = {input_node: Us_training}
target_training = {gsyn_probe_nofilt: gsyn_training}
# target_training = {Isyn_probe_nofilt: Isyn_training}
# target_training = {gsyn_probe_nofilt: gsyn_training, Isyn_probe_nofilt: Isyn_training}


# ------------------------------------------------- TRAIN THE NETWORK --------------------------------------------------

# Set the trainable aspects of the network.
with network:
    # Make all aspects of the network untrainable.
    nengo_dl.configure_settings(trainable=False)

    # Make the specific ensemble and connection of interest trainable.
    # network.config[U_ens].trainable = True
    network.config[gsyn_ens].trainable = True
    network.config[gsyn_conn].trainable = True

    # network.config[MUXsyn_ens].trainable = True
    # network.config[Isyn_ens].trainable = True
    # network.config[Isyn_conn].trainable = True

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

    # Setup the optimizer and loss function.
    sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={gsyn_probe_nofilt: train_objective})
    # sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={Isyn_probe_nofilt: train_objective})
    # sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={gsyn_probe_nofilt: train_objective, Isyn_probe_nofilt: train_objective})

    # Train the network.
    sim.fit(input_training, target_training, epochs=n_train_epochs)

    # Freeze the parameters.
    # sim.freeze_params(network)
    sim.freeze_params(gsyn_ens)
    sim.freeze_params(gsyn_conn)

    # # Save the network parameters.
    # sim.save_params("./SynapticCurrentApproxParams")


# -------------------------------------------- SIMULATE THE TRAINED NETWORK --------------------------------------------

# Setup the simulation.
with nengo_dl.Simulator(network=network, dt=dt_sim) as sim:

    # # Load the previous network parameters.
    # sim.load_params("./SynapticCurrentApproxParams")

    # Run the simulation.
    sim.run(t_sim_duration)

# Retrieve the trained simulation results.
ts_intermediate = sim.trange()
input_intermediate = sim.data[input_probe]
Us_intermediate = sim.data[U_probe]
gsyn_intermediate = sim.data[gsyn_probe]
MUXsyn_intermediate = sim.data[MUXsyn_probe]
Isyn_intermediate = sim.data[Isyn_probe]


# --------------------------- DEFINE TRAINING PROPERTIES ---------------------------

# Define training properties.
batch_size_train = 10000
minibatch_size_train = 50
n_train_epochs = 50
# learning_rate = 0.001
# learning_rate = 5e-7              # Causes divergent result.
# learning_rate = 2e-7              # Causes divergent result.
# learning_rate = 1.5e-7            # Causes divergent result.
# learning_rate = 1.1e-7            # Causes divergent result, but much less significantly.
# learning_rate = 1.05e-7           # Causes divergent result, but much less significantly.
# learning_rate = 1.04e-7           # Causes divergent result, but much less significantly.
# learning_rate = 1.03e-7           # Didn't really diverge, but not better than 1.02.
# learning_rate = 1.027e-7          # Starting to diverge.
# learning_rate = 1.025e-7          # Better on the bottom, worse on the top.
# learning_rate = 1.024e-7          # Diverged.
# learning_rate = 1.023e-7          # Slightly Worked.
# learning_rate = 1.021e-7
learning_rate = 1.02e-7             # Slightly Worked.
# learning_rate = 1.01e-7           # Causes no change from training.
# learning_rate = 1e-7              # Causes no change from training.
# learning_rate = 1e-8              # Causes no change from training.
# learning_rate = 0.005*gsynmax


# ------------------------------------------- GENERATE NETWORK TRAINING DATA -------------------------------------------

# # Create the training data inputs.
# Us_training = input_func(np.random.uniform(0, t_sim_duration, size=(batch_size_train, 1, 1)))
#
# # Compute the training data outputs.
# gsyn_training = synaptic_conductance_func(Us_training)
# Isyn_training = synapse_current_func_two_inputs(Us_training/U_radius, gsyn_training/gsyn_radius)

# Training data dictionary.
# input_training = {input_node: Us_training}
# target_training = {gsyn_probe_nofilt: gsyn_training}
target_training = {Isyn_probe_nofilt: Isyn_training}
# target_training = {gsyn_probe_nofilt: gsyn_training, Isyn_probe_nofilt: Isyn_training}


# ------------------------------------------------- TRAIN THE NETWORK --------------------------------------------------

# Set the trainable aspects of the network.
with network:

    # Make all aspects of the network untrainable.
    nengo_dl.configure_settings(trainable=False)

    # Make the specific ensemble and connection of interest trainable.
    # network.config[U_ens].trainable = True
    # network.config[gsyn_ens].trainable = True
    # network.config[gsyn_conn].trainable = True

    network.config[MUXsyn_ens].trainable = True
    network.config[Isyn_ens].trainable = True
    network.config[Isyn_conn].trainable = True

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

    # # Load the previous network parameters.
    # sim.load_params("./SynapticCurrentApproxParams")

    # Setup the optimizer and loss function.
    # sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={gsyn_probe_nofilt: train_objective})
    sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={Isyn_probe_nofilt: train_objective})
    # sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={gsyn_probe_nofilt: train_objective, Isyn_probe_nofilt: train_objective})

    # Train the network.
    sim.fit(input_training, target_training, epochs=n_train_epochs)

    # Freeze the parameters.
    sim.freeze_params(network)

    # # Save the network parameters.
    # sim.save_params("./SynapticCurrentApproxParams")


# -------------------------------------------- SIMULATE THE TRAINED NETWORK --------------------------------------------

# Setup the simulation.
with nengo_dl.Simulator(network=network, dt=dt_sim) as sim:

    # # Load the previous network parameters.
    # sim.load_params("./SynapticCurrentApproxParams")

    # Run the simulation.
    sim.run(t_sim_duration)

# Retrieve the trained simulation results.
ts_trained = sim.trange()
input_trained = sim.data[input_probe]
Us_trained = sim.data[U_probe]
gsyn_trained = sim.data[gsyn_probe]
MUXsyn_trained = sim.data[MUXsyn_probe]
Isyn_trained = sim.data[Isyn_probe]


# --------------------------- PLOT THE TRAINED NETWORK RESULTS ---------------------------

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the network input.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Input [-]'); plt.title(r'Network Input vs Time (UNTRAINED)')
plt.plot(ts_true, input_true, label=r'Input True')
plt.plot(ts_untrained, input_untrained, label=r'Input Node')
plt.legend()

# Plot the membrane voltage.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Membrane Voltage, $U$ [V]'); plt.title(r'Membrane Voltage $U$ vs Time (TRAINED)')
plt.plot(ts_untrained, Us_untrained, label=r'$U$ Ensemble (Untrained)')
plt.plot(ts_intermediate, Us_intermediate, label=r'$U$ Ensemble (Intermediate)')
plt.plot(ts_trained, Us_trained, label=r'$U$ Ensemble (Trained)')
plt.plot(ts_true, Us_true, label=r'$U$ True')
plt.legend()

# Plot the synaptic conductance.
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel('Time [s]'); axs[0].set_ylabel('Synaptic Conductance, $g_{syn}$ [S]'); axs[0].set_title(r'Synaptic Conductance, $g_{syn}$ vs Time (TRAINED)')
axs[0].plot(ts_untrained, gsyn_untrained, label=r'$g_{syn}$ Ensemble (Untrained)')
axs[0].plot(ts_intermediate, gsyn_intermediate, label=r'$g_{syn}$ Ensemble (Intermediate)')
axs[0].plot(ts_trained, gsyn_trained, label=r'$g_{syn}$ Ensemble (Trained)')
axs[0].plot(ts_true, gsyn_true, label=r'$g_{syn}$ True')
axs[0].legend()
axs[1].set_xlabel('Membrane Voltage, $U$ [V]'); axs[1].set_ylabel('Synaptic Conductance, $g_{syn}$ [S]'); axs[1].set_title(r'Synaptic Conductance, $g_{syn}$ vs Membrane Voltage $U$ (TRAINED)')
axs[1].plot(Us_untrained, gsyn_untrained, label=r'$g_{syn}$ Ensemble (Untrained)')
axs[1].plot(Us_intermediate, gsyn_intermediate, label=r'$g_{syn}$ Ensemble (Intermediate)')
axs[1].plot(Us_trained, gsyn_trained, label=r'$g_{syn}$ Ensemble (Trained)')
axs[1].plot(Us_true, gsyn_true, label=r'$g_{syn} True$')
axs[1].plot(np.ravel(Us_training), np.ravel(gsyn_training), marker='.', linestyle='None', label=r'$g_{syn}$ Training')
axs[1].legend()

# Plot the synaptic current multiplexer.
fig, axs = plt.subplots(2, 2)

axs[0, 0].set_xlabel('Time [s]'); axs[0, 0].set_ylabel('MUX Membrane Voltage, $U$ [V]'); axs[0, 0].set_title(r'MUX Membrane Voltage, $U$ vs Time (TRAINED)')
axs[0, 0].plot(ts_untrained, MUXsyn_untrained[:, 0], label=r'$U$ MUX Ensemble (Untrained)')
axs[0, 0].plot(ts_intermediate, MUXsyn_intermediate[:, 0], label=r'$U$ MUX Ensemble (Intermediate)')
axs[0, 0].plot(ts_trained, MUXsyn_trained[:, 0], label=r'$U$ MUX Ensemble (Trained)')
axs[0, 0].plot(ts_true, Us_true/U_radius, label=r'$U$ True')
axs[0, 0].legend()

axs[0, 1].set_xlabel('Time [s]'); axs[0, 1].set_ylabel('MUX Synaptic Conductance, $g_{syn}$ [S]'); axs[0, 1].set_title(r'MUX Synaptic Conductance, $g_{syn}$ vs Time (TRAINED)')
axs[0, 1].plot(ts_untrained, MUXsyn_untrained[:, 1], label=r'$g_{syn}$ MUX Ensemble (Untrained)')
axs[0, 1].plot(ts_intermediate, MUXsyn_intermediate[:, 1], label=r'$g_{syn}$ MUX Ensemble (Intermediate)')
axs[0, 1].plot(ts_trained, MUXsyn_trained[:, 1], label=r'$g_{syn}$ MUX Ensemble (Trained)')
axs[0, 1].plot(ts_true, gsyn_true/gsyn_radius, label=r'$g_{syn}$ True')
axs[0, 1].legend()

axs[1, 0].set_xlabel('Membrane Voltage, $U$ [V]'); axs[1, 0].set_ylabel('MUX Membrane Voltage, $U$ [V]'); axs[1, 0].set_title(r'MUX Membrane Voltage, $U$ vs Membrane Voltage, $U$ (TRAINED)')
axs[1, 0].plot(Us_untrained, MUXsyn_untrained[:, 0], label=r'$U$ MUX Ensemble (Untrained)')
axs[1, 0].plot(Us_intermediate, MUXsyn_intermediate[:, 0], label=r'$U$ MUX Ensemble (Intermediate)')
axs[1, 0].plot(Us_trained, MUXsyn_trained[:, 0], label=r'$U$ MUX Ensemble (Trained)')
axs[1, 0].plot(Us_true, Us_true/U_radius, label=r'$U$ True')
axs[1, 0].legend()

axs[1, 1].set_xlabel('Membrane Voltage, $U$ [V]'); axs[1, 1].set_ylabel('MUX Synaptic Conductance, $g_{syn}$ [S]'); axs[1, 1].set_title(r'MUX Synaptic Conductance, $g_{syn}$ vs Membrane Voltage, $U$ (TRAINED)')
axs[1, 1].plot(Us_untrained, MUXsyn_untrained[:, 1], label=r'$g_{syn}$ MUX Ensemble (Untrained)')
axs[1, 1].plot(Us_intermediate, MUXsyn_intermediate[:, 1], label=r'$g_{syn}$ MUX Ensemble (Intermediate)')
axs[1, 1].plot(Us_trained, MUXsyn_trained[:, 1], label=r'$g_{syn}$ MUX Ensemble (Trained)')
axs[1, 1].plot(Us_true, gsyn_true/gsyn_radius, label=r'$g_{syn}$ True')
axs[1, 1].legend()

# Plot the synaptic current.
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel('Time [s]'); axs[0].set_ylabel('Synaptic Current, $I_{syn}$ [A]'); axs[0].set_title(r'Synaptic Current, $I_{syn}$ vs Time (TRAINED)')
axs[0].plot(ts_untrained, Isyn_untrained, label=r'$I_{syn}$ Ensemble (Untrained)')
axs[0].plot(ts_intermediate, Isyn_intermediate, label=r'$I_{syn}$ Ensemble (Intermediate)')
axs[0].plot(ts_trained, Isyn_trained, label=r'$I_{syn}$ Ensemble (Trained)')
axs[0].plot(ts_true, Isyn_true, label=r'$I_{syn}$ True')
axs[0].legend()
axs[1].set_xlabel('Membrane Voltage, $U$ [V]'); axs[1].set_ylabel('Synaptic Current, $I_{syn}$ [A]'); axs[1].set_title(r'Synaptic Current, $I_{syn}$ vs Membrane Voltage, $U$ (TRAINED)')
axs[1].plot(Us_untrained, Isyn_untrained, label=r'$I_{syn}$ Ensemble (Untrained)')
axs[1].plot(Us_intermediate, Isyn_intermediate, label=r'$I_{syn}$ Ensemble (Intermediate)')
axs[1].plot(Us_trained, Isyn_trained, label=r'$I_{syn}$ Ensemble (Trained)')
axs[1].plot(Us_true, Isyn_true, label=r'$I_{syn}$ True')
axs[1].plot(np.ravel(Us_training), np.ravel(Isyn_training), marker='.', linestyle='None', label=r'$I_{syn}$ Training')
axs[1].legend()

# # Show the network.
# gvz_source.view()

# Display the figures.
plt.show()


