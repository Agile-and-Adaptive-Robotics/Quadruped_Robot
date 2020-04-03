# --------------------------- SODIUM CHANNEL TIME CONSTANT FUNCTION APPROXIMATION ---------------------------

# This script tests a methods of approximating the sodium channel time constant.


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

# Define full scale network properties.
seed = 0                                                            # [-] Seed for Random Number Generation.
# tau_synapse = 0.001                                                 # [s] Post-Synaptic Time Constant.
tau_synapse = None                                                 # [s] Post-Synaptic Time Constant.
tau_probe = 0.1                                                     # [s] Probe Time Constant.
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

# Define the steady state sodium channel deactivation time constant intermediate calculation properties 1.
tauhterm1_neurons = 100
tauhterm1_dimensions = 1
# tauhterm1_radius = Ah*np.exp(-Sh*(Eh_tilde - 6*R))
tauhterm1_radius = 100

# Define the steady state sodium channel deactivation time constant intermediate calculation properties 2.
tauhterm2_neurons = 100
tauhterm2_dimensions = 1
# tauhterm2_radius = np.sqrt(tauhterm1_radius)
tauhterm2_radius = 10

# Define the steady state sodium channel deactivation parameter multiplexer ensemble properties.
MUXtauh_neurons = 100
MUXtauh_dimensions = 2
MUXtauh_radius = 1

# Define the steady state sodium channel deactivation time constant ensemble properties.
tauh_neurons = 1000
tauh_dimensions = 1
tauh_radius = 2*tauhmax


# --------------------------- DEFINE THE CONSTITUENT FUNCTIONS TO APPROXIMATE ---------------------------

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

# Define the steady state sodium channel time constant intermediate calculation function.
def NaCh_TimeConstInterCalc1_func(x):

    # Return the steady state sodium channel time constant intermediate calculation.
    return Ah*np.exp(-Sh*(Eh_tilde - x))

# Define the steady state sodium channel time constant intermediate calculation function.
def NaCh_TimeConstInterCalc2_func(x):

    # Return the steady state sodium channel time constant intermediate calculation.
    # return np.sqrt(x)
    return np.sqrt(np.maximum(x, 0))

# Define the steady state sodium channel time constant function.
def NaCh_TimeConst_func(x):

    # Retrieve the input variables.
    hinf, tauhterm = x

    # Return the steady state sodium channel time constant.
    return tauhmax*(hinf*hinf_radius)*(tauhterm*tauhterm2_radius)

# Define the steady state sodium channel time constant function.
def NaCh_TimeConst_func_two_inputs(hinf, tauhterm2):

    # Return the steady state sodium channel time constant.
    return tauhmax*hinf*tauhterm2


# --------------------------- COMPUTE GROUND TRUTH SIMULATION RESULTS ---------------------------

# Define simulation properties.
num_inputs = 1000                                                   # [#] Number of inputs to pass to the network.
num_steps_per_input = 100                                           # [#] Number of time steps to take per network input.
dt_sim = 0.001                                                      # [s] Simulation Step Size.
t_sim_duration = num_steps_per_input*dt_sim                         # [s] Total Simulation Duration.

# Define the simulation time tensor.
ts_true = np.arange(0, t_sim_duration, dt_sim)
ts_sim = np.tile(np.reshape(ts_true, (1, num_steps_per_input, 1)), (num_inputs, 1, 1))

# Define the simulation input tensor.
input_lower = -4*R
input_upper = 6*R
input_true = np.linspace(input_lower, input_upper, num_inputs)
input_sim = np.tile(np.reshape(input_true, (num_inputs, 1, 1)), (1, num_steps_per_input, 1))

# Compute the true simulation outputs.
Us_true = input_true
minf_true = NaCh_Act_func(Us_true)
hinf_true = NaCh_Deact_func(Us_true)
tauhterm1_true = NaCh_TimeConstInterCalc1_func(Us_true)
tauhterm2_true = NaCh_TimeConstInterCalc2_func(tauhterm1_true)
tauh_true = NaCh_TimeConst_func_two_inputs(hinf_true, tauhterm2_true)


# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=LIF_amplitude)  # [-] Sets the neuron model to LIF.
# network.config[nengo.Ensemble].neuron_type = nengo.LIFRate(amplitude=LIF_amplitude)  # [-] Sets the neuron model to LIF.

# Build the network.
with network:

    # -------------------- Create the Network Components --------------------

    input_node = nengo.Node(output=input_func, label='Input Node')
    U_ens = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dimensions, radius=U_radius, seed=seed, label='U Ensemble')
    minf_ens = nengo.Ensemble(n_neurons=minf_neurons, dimensions=minf_dimensions, radius=minf_radius, seed=seed, label='minf Ensemble')
    hinf_ens = nengo.Ensemble(n_neurons=hinf_neurons, dimensions=hinf_dimensions, radius=hinf_radius, seed=seed, label='minf Ensemble')
    tauhterm1_ens = nengo.Ensemble(n_neurons=tauhterm1_neurons, dimensions=tauhterm1_dimensions, radius=tauhterm1_radius, seed=seed, label='tauh Inter. Calc. 1 Ensemble')
    tauhterm2_ens = nengo.Ensemble(n_neurons=tauhterm2_neurons, dimensions=tauhterm2_dimensions, radius=tauhterm2_radius, seed=seed, label='tauh Inter. Calc. 2 Ensemble')
    MUXtauh_ens = nengo.Ensemble(n_neurons=MUXtauh_neurons, dimensions=MUXtauh_dimensions, radius=MUXtauh_radius, seed=seed, label='tauh MUX Ensemble')
    tauh_ens = nengo.Ensemble(n_neurons=tauh_neurons, dimensions=tauh_dimensions, radius=tauh_dimensions, seed=seed, label='tauh Ensemble')

    # -------------------- Connect the Network Components --------------------

    U_conn = nengo.Connection(input_node, U_ens, synapse=tau_synapse)
    minf_conn = nengo.Connection(U_ens, minf_ens, synapse=tau_synapse, function=NaCh_Act_func)
    hinf_conn = nengo.Connection(U_ens, hinf_ens, synapse=tau_synapse, function=NaCh_Deact_func)
    tauhterm1_conn = nengo.Connection(U_ens, tauhterm1_ens, synapse=tau_synapse, function=NaCh_TimeConstInterCalc1_func)
    tauhterm2_conn = nengo.Connection(tauhterm1_ens, tauhterm2_ens, synapse=tau_synapse, function=NaCh_TimeConstInterCalc2_func)
    MUXtauh1_conn = nengo.Connection(hinf_ens, MUXtauh_ens[0], synapse=tau_synapse, transform=1/hinf_radius)
    MUXtauh2_conn = nengo.Connection(tauhterm2_ens, MUXtauh_ens[1], synapse=tau_synapse, transform=1/tauhterm2_radius)
    tauh_conn = nengo.Connection(MUXtauh_ens, tauh_ens, synapse=tau_synapse, function=NaCh_TimeConst_func)

    # -------------------- Collect Data From the Network --------------------

    input_probe = nengo.Probe(input_node, synapse=tau_probe)
    U_probe = nengo.Probe(U_ens, synapse=tau_probe)
    minf_probe = nengo.Probe(minf_ens, synapse=tau_probe)
    hinf_probe = nengo.Probe(hinf_ens, synapse=tau_probe)
    tauhterm1_probe = nengo.Probe(tauhterm1_ens, synapse=tau_probe)
    tauhterm1_probe_nofilt = nengo.Probe(tauhterm1_ens)
    tauhterm2_probe = nengo.Probe(tauhterm2_ens, synapse=tau_probe)
    tauhterm2_probe_nofilt = nengo.Probe(tauhterm2_ens)
    MUXtauh_probe = nengo.Probe(MUXtauh_ens, synapse=tau_probe)
    tauh_probe = nengo.Probe(tauh_ens, synapse=tau_probe)
    tauh_probe_nofilt = nengo.Probe(tauh_ens)

# Generate the contents of a .dot file that describes the network.
network_contents = gvz.net_diagram(network)

# Create a graphviz document using the network contents.
gvz_source = Source(network_contents, filename="network_diagram", format="jpg")


# --------------------------- SIMULATE THE NETWORK ---------------------------

# Simulate the network.
with nengo_dl.Simulator(network=network, dt=dt_sim, seed=seed) as sim:

    # Run the simulation.
    # sim.run(t_sim_duration)
    sim.run(t_sim_duration, data={input_node: input_sim})

# Retrieve the untrained network results.
input_untrained = sim.data[input_probe]
Us_untrained = sim.data[U_probe]
minf_untrained = sim.data[minf_probe]
hinf_untrained = sim.data[hinf_probe]
tauhterm1_untrained = sim.data[tauhterm1_probe]
tauhterm2_untrained = sim.data[tauhterm2_probe]
tauh_untrained = sim.data[tauh_probe]

# Retrieve the final untrained network results.
ts_untrained_final = ts_true
input_untrained_final = sim.data[input_probe][:, -1, 1]
Us_untrained_final = sim.data[U_probe][:, -1, 1]
minf_untrained_final = sim.data[minf_probe][:, -1, 1]
hinf_untrained_final = sim.data[hinf_probe][:, -1, 1]
tauhterm1_untrained_final = sim.data[tauhterm1_probe][:, -1, 1]
tauhterm2_untrained_final = sim.data[tauhterm2_probe][:, -1, 1]
tauh_untrained_final = sim.data[tauh_probe][:, -1, 1]


# --------------------------- DEFINE TRAINING & TESTING PROPERTIES ---------------------------

# Define training properties.
batch_size_train = 10000
minibatch_size_train = 50
n_train_epochs = 50
# learning_rate = 0.01
learning_rate = 0.1

# Define testing properties.
batch_size_test = 1000
num_test_steps = 100
num_steps_to_eval = 10

# Set the trainable aspects of the network.
with network:

    # Make all aspects of the network untrainable.
    nengo_dl.configure_settings(trainable=False)

    # Make the specific ensemble and connection of interest trainable.
    network.config[U_ens].trainable = True
    network.config[tauhterm1_ens].trainable = True
    network.config[tauhterm1_conn].trainable = True


# ------------------------------------------- GENERATE NETWORK TRAINING DATA -------------------------------------------

# Create the training data used to train the network.
ts_training = np.random.uniform(0, t_sim_duration, size=(batch_size_train, 1, 1))
Us_training = input_func(ts_training)
minf_training = NaCh_Act_func(Us_training)
hinf_training = NaCh_Deact_func(Us_training)
tauhterm1_training = NaCh_TimeConstInterCalc1_func(Us_training)
tauhterm2_training = NaCh_TimeConstInterCalc2_func(tauhterm1_training)
tauh_training = NaCh_TimeConst_func_two_inputs(hinf_training, tauhterm2_training)

# Create the necessary training data dictionaries.
input_training = {input_node: Us_training}
target_training = {tauhterm1_probe_nofilt: tauhterm1_training}

# Define the objective function we will use when training our SNN. (Note that the SNN will be converted to an ANN for training.)
def train_objective(outputs, targets):

    # Compute the loss of this output.
    return tf.reduce_mean(tf.square(outputs - targets))  # Standard MSE.


# ------------------------------------------- GENERATE NETWORK TESTING DATA -------------------------------------------

# Create the testing data used to evaluate the network.
ts_test = np.random.uniform(0, t_sim_duration, size=(batch_size_test, 1, 1))
ts_test = np.tile(ts_test, (1, num_test_steps, 1))
Us_test = input_func(ts_test)
minf_test = NaCh_Act_func(Us_test)
hinf_test = NaCh_Deact_func(Us_test)
tauhterm1_test = NaCh_TimeConstInterCalc1_func(Us_test)
tauhterm2_test = NaCh_TimeConstInterCalc2_func(tauhterm1_test)
tauh_test = NaCh_TimeConst_func_two_inputs(hinf_test, tauhterm2_test)

# Create the necessary testing data dictionaries.
input_testing = {input_node: Us_test}
target_testing = {tauhterm1_probe: tauhterm1_test}

# Define the test objective function we will use when evaluating our SNN.
def test_objective(outputs, targets):

    # Compute the loss associated with this output.
    return tf.reduce_mean(tf.square(outputs[:, -num_steps_to_eval:] - targets[:, -num_steps_to_eval:]))  # MSE using the last 10 time steps.


# ------------------------------------------------- TRAIN THE NETWORK --------------------------------------------------

# Evaluate and train the network.
with nengo_dl.Simulator(network=network, minibatch_size=minibatch_size_train, seed=seed) as sim:

    # Evaluate the network before training.
    print('Error before training:')
    sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={tauhterm1_probe: test_objective})
    sim.evaluate(input_testing, target_testing)

    # Train the network.
    sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={tauhterm1_probe_nofilt: train_objective})
    sim.fit(input_training, target_training, epochs=n_train_epochs)

    # Evaluate the network before training.
    print('Error after training:')
    sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={tauhterm1_probe: test_objective})
    sim.evaluate(input_testing, target_testing)

    # Freeze the parameters.
    sim.freeze_params(network)


# -------------------------------------------- SIMULATE THE TRAINED NETWORK --------------------------------------------

# Setup the simulation.
with nengo_dl.Simulator(network=network, dt=dt_sim, seed=seed) as sim:

    # Run the simulation.
    # sim.run(t_sim_duration)
    sim.run(t_sim_duration, data={input_node: input_sim})

# Retrieve the trained network results.
input_trained = sim.data[input_probe]
Us_trained = sim.data[U_probe]
minf_trained = sim.data[minf_probe]
hinf_trained = sim.data[hinf_probe]
tauhterm1_trained = sim.data[tauhterm1_probe]
tauhterm2_trained = sim.data[tauhterm2_probe]
tauh_trained = sim.data[tauh_probe]

# Retrieve the final trained network results.
ts_trained_final = ts_true
input_trained_final = sim.data[input_probe][:, -1, 1]
Us_trained_final = sim.data[U_probe][:, -1, 1]
minf_trained_final = sim.data[minf_probe][:, -1, 1]
hinf_trained_final = sim.data[hinf_probe][:, -1, 1]
tauhterm1_trained_final = sim.data[tauhterm1_probe][:, -1, 1]
tauhterm2_trained_final = sim.data[tauhterm2_probe][:, -1, 1]
tauh_trained_final = sim.data[tauh_probe][:, -1, 1]


# --------------------------- PLOT THE NETWORK RESULTS ---------------------------

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the network input over time.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Network Input [V]'); plt.title(r'Network Input vs Time')
plt.plot(ts_true, input_true, label=r'Input True')
plt.plot(ts_untrained, input_untrained, label=r'Input Untrained')
plt.plot(ts_trained, input_trained, label=r'Input Trained')
plt.legend()

# Plot the membrane voltage over time (U).
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Membrane Voltage, $U$ [V]'); plt.title(r'Membrane Voltage, $U$ [V] vs Time')
plt.plot(np.ravel(ts_training), np.ravel(Us_training), marker='.', linestyle='None', label=r'$U$ Training')
plt.plot(ts_true, Us_true, label=r'$U$ True')
plt.plot(ts_untrained, Us_untrained, label=r'$U$ Untrained')
plt.plot(ts_trained, Us_trained, label=r'$U$ Trained')
plt.legend()

# Plot the Na Ch Activation (minf).
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Steady State Na Ch. Activation, $m_{\infty}$ [-]'); axs[0].set_title(r'Steady State Na Ch. Activation, $m_{\infty}$ [-] vs Time')
axs[0].plot(np.ravel(ts_training), np.ravel(minf_training), marker='.', linestyle='None', label=r'$m_{\infty}$ Training')
axs[0].plot(ts_true, minf_true, label=r'$m_{\infty}$ True')
axs[0].plot(ts_untrained, minf_untrained, label=r'$m_{\infty}$ Untrained')
axs[0].plot(ts_trained, minf_trained, label=r'$m_{\infty}$ Trained')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Steady State Na Ch. Activation, $m_{\infty}$ [-]'); axs[1].set_title(r'Steady State Na Ch. Activation, $m_{\infty}$ [-] vs Membrane Voltage')
axs[1].plot(np.ravel(Us_training), np.ravel(minf_training), marker='.', linestyle='None', label=r'$m_{\infty}$ Training')
axs[1].plot(Us_true, minf_true, label=r'$m_{\infty}$ True')
axs[1].plot(Us_untrained, minf_untrained, label=r'$m_{\infty}$ Untrained')
axs[1].plot(Us_trained, minf_trained, label=r'$m_{\infty}$ Trained')
axs[1].legend()

# Plot the Na Ch Deactivation (hinf).
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Steady State Na Ch. Deactivation, $h_{\infty}$ [-]'); axs[0].set_title(r'Steady State Na Ch. Deactivation, $h_{\infty}$ [-] vs Time')
axs[0].plot(np.ravel(ts_training), np.ravel(hinf_training), marker='.', linestyle='None', label=r'$h_{\infty}$ Training')
axs[0].plot(ts_true, hinf_true, label=r'$h_{\infty}$ True')
axs[0].plot(ts_untrained, hinf_untrained, label=r'$h_{\infty}$ Untrained')
axs[0].plot(ts_trained, hinf_trained, label=r'$h_{\infty}$ Trained')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Steady State Na Ch. Deactivation, $h_{\infty}$ [-]'); axs[1].set_title(r'Steady State Na Ch. Deactivation, $h_{\infty}$ [-] vs Membrane Voltage')
axs[1].plot(np.ravel(Us_training), np.ravel(hinf_training), marker='.', linestyle='None', label=r'$h_{\infty}$ Training')
axs[1].plot(Us_true, hinf_true, label=r'$h_{\infty}$ True')
axs[1].plot(Us_untrained, hinf_untrained, label=r'$h_{\infty}$ Untrained')
axs[1].plot(Us_trained, hinf_trained, label=r'$h_{\infty}$ Trained')
axs[1].legend()

# Plot the first Na Ch Time Constant Calculation (tauhterm1)
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Na Ch. Time Constant Calc. 1, $\tau_{\infty, 1}$ [-]'); axs[0].set_title(r'Na Ch. Time Constant Calc. 1, $\tau_{\infty, 1}$ [-] vs Time')
axs[0].plot(np.ravel(ts_training), np.ravel(tauhterm1_training), marker='.', linestyle='None', label=r'$\tau_{\infty, 1}$ Training')
axs[0].plot(ts_true, tauhterm1_true, label=r'$\tau_{\infty, 1}$ True')
axs[0].plot(ts_untrained, tauhterm1_untrained, label=r'$\tau_{\infty, 1}$ Untrained')
axs[0].plot(ts_trained, tauhterm1_trained, label=r'$\tau_{\infty, 1}$ Trained')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Na Ch. Time Constant Calc. 1, $\tau_{\infty, 1}$ [-]'); axs[1].set_title(r'Na Ch. Time Constant Calc. 1, $\tau_{\infty, 1}$ [-] vs Membrane Voltage')
axs[1].plot(np.ravel(Us_training), np.ravel(tauhterm1_training), marker='.', linestyle='None', label=r'$\tau_{\infty, 1}$ Training')
axs[1].plot(Us_true, tauhterm1_true, label=r'$\tau_{\infty, 1}$ True')
axs[1].plot(Us_untrained, tauhterm1_untrained, label=r'$\tau_{\infty, 1}$ Untrained')
axs[1].plot(Us_trained, tauhterm1_trained, label=r'$\tau_{\infty, 1}$ Trained')
axs[1].legend()

# Plot the second Na Ch Time Constant Calculation (tauhterm2)
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Na Ch. Time Constant Calc. 2, $\tau_{\infty, 2}$ [-]'); axs[0].set_title(r'Na Ch. Time Constant Calc. 2, $\tau_{\infty, 2}$ [-] vs Time')
axs[0].plot(np.ravel(ts_training), np.ravel(tauhterm2_training), marker='.', linestyle='None', label=r'$\tau_{\infty, 2}$ Training')
axs[0].plot(ts_true, tauhterm2_true, label=r'$\tau_{\infty, 2}$ True')
axs[0].plot(ts_untrained, tauhterm2_untrained, label=r'$\tau_{\infty, 2}$ Untrained')
axs[0].plot(ts_trained, tauhterm2_trained, label=r'$\tau_{\infty, 2}$ Trained')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Na Ch. Time Constant Calc. 2, $\tau_{\infty, 2}$ [-]'); axs[1].set_title(r'Na Ch. Time Constant Calc. 2, $\tau_{\infty, 2}$ [-] vs Membrane Voltage')
axs[1].plot(np.ravel(Us_training), np.ravel(tauhterm2_training), marker='.', linestyle='None', label=r'$\tau_{\infty, 2}$ Training')
axs[1].plot(Us_true, tauhterm2_true, label=r'$\tau_{\infty, 2}$ True')
axs[1].plot(Us_untrained, tauhterm2_untrained, label=r'$\tau_{\infty, 2}$ Untrained')
axs[1].plot(Us_trained, tauhterm2_trained, label=r'$\tau_{\infty, 2}$ Trained')
axs[1].legend()

# Plot the Na Ch Time Constant Multiplexer (MUXtauh)
fig, axs = plt.subplots(2, 2)
axs[0, 0].set_xlabel(r'Time [s]'); axs[0, 0].set_ylabel(r'Na Ch. Time Constant Multiplexer, $h_{\infty}$ [-]'); axs[0, 0].set_title(r'Na Ch. Time Constant Multiplexer, $h_{\infty}$ [-] vs Time')
axs[0, 0].plot(ts_true, hinf_true, label=r'$h_{\infty}$ True')
axs[0, 0].plot(ts_untrained, sim.data[MUXtauh_probe][:, 0], label=r'$h_{\infty}$ Untrained')
axs[0, 0].legend()
axs[0, 1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[0, 1].set_ylabel(r'Na Ch. Time Constant Multiplexer, $h_{\infty}$ [-]'); axs[0, 1].set_title(r'Na Ch. Time Constant Multiplexer, $h_{\infty}$ [-] vs Membrane Voltage')
axs[0, 1].plot(Us_true, hinf_true, label=r'$h_{\infty}$ True')
axs[0, 1].plot(Us_untrained, sim.data[MUXtauh_probe][:, 0], label=r'$h_{\infty}$ Untrained')
axs[0, 1].legend()
axs[1, 0].set_xlabel(r'Time [s]'); axs[1, 0].set_ylabel(r'Na Ch. Time Constant Multiplexer, $\tau_{\infty, 2}$ [-]'); axs[1, 0].set_title(r'Na Ch. Time Constant Multiplexer, $\tau_{\infty, 2}$ [-] vs Time')
axs[1, 0].plot(ts_true, tauhterm2_true/tauhterm2_radius, label=r'$\tau_{\infty, 2}$ True')
axs[1, 0].plot(ts_untrained, sim.data[MUXtauh_probe][:, 1], label=r'$\tau_{\infty, 2}$ Untrained')
axs[1, 0].legend()
axs[1, 1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1, 1].set_ylabel(r'Na Ch. Time Constant Multiplexer, $\tau_{\infty}$ [-]'); axs[1, 1].set_title(r'Na Ch. Time Constant Multiplexer, $\tau_{\infty, 2}$ [-] vs Membrane Voltage')
axs[1, 1].plot(Us_true, tauhterm2_true/tauhterm2_radius, label=r'$\tau_{\infty, 2}$ True')
axs[1, 1].plot(Us_untrained, sim.data[MUXtauh_probe][:, 1], label=r'$\tau_{\infty, 2}$ Untrained')
axs[1, 1].legend()

# Plot the Na Ch Time Constant.
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Na Ch. Time Constant (Final Calc.), $\tau_{\infty}$ [-]'); axs[0].set_title(r'Na Ch. Time Constant (Final Calc.), $\tau_{\infty}$ [-] vs Time')
axs[0].plot(np.ravel(ts_training), np.ravel(tauh_training), marker='.', linestyle='None', label=r'$\tau_{\infty}$ Training')
axs[0].plot(ts_true, tauh_true, label=r'$\tau_{\infty}$ True')
axs[0].plot(ts_untrained, tauh_untrained, label=r'$\tau_{\infty}$ Untrained')
axs[0].plot(ts_trained, tauh_trained, label=r'$\tau_{\infty}$ Trained')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Na Ch. Time Constant (Final Calc.), $\tau_{\infty}$ [-]'); axs[1].set_title(r'Na Ch. Time Constant (Final Calc.), $\tau_{\infty}$ [-] vs Membrane Voltage')
axs[1].plot(np.ravel(Us_training), np.ravel(tauh_training), marker='.', linestyle='None', label=r'$\tau_{\infty}$ Training')
axs[1].plot(Us_true, tauh_true, label=r'$\tau_{\infty}$ True')
axs[1].plot(Us_untrained, tauh_untrained, label=r'$\tau_{\infty}$ Untrained')
axs[1].plot(Us_trained, tauh_trained, label=r'$\tau_{\infty}$ Trained')
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


