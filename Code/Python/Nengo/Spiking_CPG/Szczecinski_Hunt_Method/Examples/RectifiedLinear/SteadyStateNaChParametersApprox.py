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
minf_func = lambda U: 1/(1 + Am*np.exp(-Sm*(Em_tilde - U)))             # [-] Lambda Function for the Steady State Sodium Channel Activation Parameter.
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
t_sim_duration = 1                                                  # [s] Total Simulation Duration.

# Define the LIF amplitude.
LIF_amplitude = 0.001

# Define the membrane voltage ensemble properties.
U_neurons = 100
U_dimensions = 1
U_radius = 6*R

# Define the steady state sodium channel activation parameter ensemble properties.
minf_neurons = 100
minf_dimensions = 1
minf_radius = 1

# Define the steady state sodium channel deactivation parameter ensemble properties.
hinf_neurons = 100
hinf_dimensions = 1
hinf_radius = 1

# Define network properties.
seed = 0                                                            # [-] Seed for Random Number Generation.
# tau_synapse = 0.001                                                 # [s] Post-Synaptic Time Constant.
tau_synapse = None                                                 # [s] Post-Synaptic Time Constant.
tau_probe = 0.1                                                     # [s] Probe Time Constant.

# Define the input function.
def input_func(x):

    # Return the desired function.
    return 10*R*x - 4*R

# Define the steady state sodium channel activation function.
def NaCh_Act_func(x):

    # Return the steady state sodium channel activation.
    return 1/(1 + Am*np.exp(-Sm*(Em_tilde - x)))

# Define the steady state sodium channel deactivation function.
def NaCh_Deact_func(x):

    # Return the steady state sodium channel deactivation.
    return 1/(1 + Ah*np.exp(-Sh*(Eh_tilde - x)))


# --------------------------- COMPUTE THE GROUND TRUTH SIMULATION RESULTS ---------------------------

# Compute the desired simulation results.
ts_true = np.arange(0, t_sim_duration, dt_sim)
input_true = input_func(ts_true)
Us_true = input_true
minf_true = NaCh_Act_func(Us_true)
hinf_true = NaCh_Deact_func(Us_true)


# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=LIF_amplitude)  # [-] Sets the neuron model to LIF.

# Build the network.
with network:

    # -------------------- Create the Network Components --------------------

    input_node = nengo.Node(output=input_func, label='Input Node')
    U_ens = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dimensions, radius=U_radius, seed=seed, label='U Ensemble')
    minf_ens = nengo.Ensemble(n_neurons=minf_neurons, dimensions=minf_dimensions, radius=minf_radius, seed=seed, label='minf Ensemble')
    hinf_ens = nengo.Ensemble(n_neurons=hinf_neurons, dimensions=hinf_dimensions, radius=hinf_radius, seed=seed, label='minf Ensemble')

    # input_node = nengo.Node(output=input_func, label='Input Node')
    # U_ens = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dimensions, radius=U_radius, seed=seed, label='U Ensemble', neuron_type=nengo.Direct())
    # minf_ens = nengo.Ensemble(n_neurons=minf_neurons, dimensions=minf_dimensions, radius=minf_radius, seed=seed, label='minf Ensemble', neuron_type=nengo.Direct())
    # hinf_ens = nengo.Ensemble(n_neurons=hinf_neurons, dimensions=hinf_dimensions, radius=hinf_radius, seed=seed, label='minf Ensemble', neuron_type=nengo.Direct())

    # -------------------- Connect the Network Components --------------------

    U_conn = nengo.Connection(input_node, U_ens, synapse=tau_synapse)
    minf_conn = nengo.Connection(U_ens, minf_ens, synapse=tau_synapse, function=NaCh_Act_func)
    hinf_conn = nengo.Connection(U_ens, hinf_ens, synapse=tau_synapse, function=NaCh_Deact_func)


    # -------------------- Collect Data From the Network --------------------

    input_probe = nengo.Probe(input_node, synapse=tau_probe)
    U_probe = nengo.Probe(U_ens, synapse=tau_probe)
    minf_probe = nengo.Probe(minf_ens, synapse=tau_probe)
    minf_probe_nofilt = nengo.Probe(minf_ens)
    hinf_probe = nengo.Probe(hinf_ens, synapse=tau_probe)
    hinf_probe_nofilt = nengo.Probe(hinf_ens)


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
    # minf_evals, minf_activites = tuning_curves(minf_ens, sim)
    # hinf_evals, hinf_activites = tuning_curves(hinf_ens, sim)

# Retrieve the simulation results.
ts_untrained = sim.trange()
input_untrained = sim.data[input_probe]
Us_untrained = sim.data[U_probe]
minf_untrained = sim.data[minf_probe]
hinf_untrained = sim.data[hinf_probe]


# --------------------------- DEFINE TRAINING PROPERTIES ---------------------------

# Define training properties.
batch_size_train = 10000
minibatch_size_train = 50
n_train_epochs = 50
learning_rate = 0.0075


# ------------------------------------------- GENERATE NETWORK TRAINING DATA -------------------------------------------

# Create the training data inputs.
Us_training = input_func(np.random.uniform(0, t_sim_duration, size=(batch_size_train, 1, 1)))

# Compute the training data outputs.
minf_training = NaCh_Act_func(Us_training)
hinf_training = NaCh_Deact_func(Us_training)

# Training data dictionary.
input_training = {input_node: Us_training}
target_training = {minf_probe_nofilt: minf_training}
# target_training = {hinf_probe_nofilt: hinf_training}
# target_training = {minf_probe_nofilt: minf_training, hinf_probe_nofilt: hinf_training}


# ------------------------------------------------- TRAIN THE NETWORK --------------------------------------------------

# Set the trainable aspects of the network.
with network:

    # Make all aspects of the network untrainable.
    nengo_dl.configure_settings(trainable=False)

    # Make the specific ensemble and connection of interest trainable.
    network.config[U_ens].trainable = True
    network.config[minf_ens].trainable = True
    network.config[minf_conn].trainable = True


with nengo_dl.Simulator(network=network, minibatch_size=minibatch_size_train) as sim:

    # Define the objective function we will use when training our SNN. (Note that the SNN will be converted to an ANN for training.)
    def train_objective(outputs, targets):

        # Compute the loss of this output.
        return tf.reduce_mean(tf.square(outputs - targets))     # Standard MSE.

    # Setup the optimizer and loss function.
    sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={minf_probe_nofilt: train_objective})
    # sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={hinf_probe_nofilt: train_objective})
    # sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={minf_probe_nofilt: train_objective, hinf_probe_nofilt: train_objective})

    # Train the network.
    sim.fit(input_training, target_training, epochs=n_train_epochs)

    # Freeze the parameters.
    sim.freeze_params(network)
    # sim.freeze_params(U_ens)
    # sim.freeze_params(minf_ens)
    # sim.freeze_params(minf_conn)


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
minf_trained = sim.data[minf_probe]
hinf_trained = sim.data[hinf_probe]


# --------------------------- PLOT THE NETWORK RESULTS ---------------------------

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the network input.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Input [-]'); plt.title(r'Network Input vs Time')
plt.plot(ts_true, input_true, label=r'Input True')
plt.plot(ts_untrained, input_untrained, label=r'Input Untrained')
plt.plot(ts_trained, input_trained, label=r'Input Trained')
plt.legend()

# Plot the membrane voltage.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Membrane Voltage, $U$ [V]'); plt.title(r'Membrane Voltage $U$ vs Time')
plt.plot(ts_true, Us_true, label=r'$U$ True')
plt.plot(ts_untrained, Us_untrained, label=r'$U$ Untrained')
plt.plot(ts_trained, Us_trained, label=r'$U$ Trained')
plt.legend()

# Plot the sodium channel activation parameter.
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Na Ch Activation, $m_{\infty}$ [-]'); axs[0].set_title(r'$m_{\infty}$ Na Ch Activation vs Time')
axs[0].plot(ts_true, minf_true, label=r'$m_{\infty}$ True')
axs[0].plot(ts_untrained, minf_untrained, label=r'$m_{\infty}$ Untrained')
axs[0].plot(ts_trained, minf_trained, label=r'$m_{\infty}$ Trained')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Na Ch Activation, $m_{\infty}$ [-]'); axs[1].set_title(r'$m_{\infty}$ Na Ch Activation vs Membrane Voltage')
axs[1].plot(Us_true, minf_true, label=r'$m_{\infty}$ True')
axs[1].plot(Us_untrained, minf_untrained, label=r'$m_{\infty}$ Untrained')
axs[1].plot(Us_trained, minf_trained, label=r'$m_{\infty}$ Trained')
axs[1].legend()

# Plot the sodium channel deactivation parameter.
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Na Ch Deactivation, $h_{\infty}$ [-]'); axs[0].set_title(r'$h_{\infty}$ Na Ch Deactivation vs Time')
axs[0].plot(ts_true, hinf_true, label=r'$h_{\infty}$ True')
axs[0].plot(ts_untrained, hinf_untrained, label=r'$h_{\infty}$ Untrained')
axs[0].plot(ts_trained, hinf_trained, label=r'$h_{\infty}$ Trained')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Na Ch Deactivation, $h_{\infty}$ [-]'); axs[1].set_title(r'$h_{\infty}$ Na Ch Activation vs Membrane Voltage')
axs[1].plot(Us_true, hinf_true, label=r'$h_{\infty}$ True')
axs[1].plot(Us_untrained, hinf_untrained, label=r'$h_{\infty}$ Untrained')
axs[1].plot(Us_trained, hinf_trained, label=r'$h_{\infty}$ Trained')
axs[1].legend()

# # Plot the tuning curves associated with the Na Ch Activation ensemble.
# plt.figure(); plt.xlabel('Input [-]'); plt.ylabel(r'$m_{\infty}$ Firing Frequency [Hz]'); plt.title(r'$m_{\infty}$ Firing Frequency vs Input')
# plt.plot(minf_evals, minf_activites)
#
# # Plot the tuning curves associated with the Na Ch Deactivation ensemble.
# plt.figure(); plt.xlabel('Input [-]'); plt.ylabel(r'$h_{\infty}$ Firing Frequency [Hz]'); plt.title(r'$h_{\infty}$ Firing Frequency vs Input')
# plt.plot(minf_evals, minf_activites)

# # Show the network.
# gvz_source.view()

# Display the figures.
plt.show()


