# --------------------------- LINEAR SYSTEM IDENTIFICATION ---------------------------

# This script tests a method of performing system identification on a linear motor system.

# --------------------------- IMPORT LIBRARIES ---------------------------

# Import standard python libraries.
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt

# Import nengo related libraries.
import nengo
import nengo_dl
import tensorflow as tf
from nengo.processes import WhiteSignal
import nengo_extras.graphviz as gvz
from graphviz import Source


# --------------------------- DEFINE NETWORK PROPERTIES ---------------------------

# Define the properties of the input ensemble.
input_neurons = 100                                     # [#] Number of neurons in the ensemble.
input_dimensions = 1                                    # [#] Dimension of the values represented by this ensemble.
input_radius = 1                                        # [-] Radius of the input space of this ensemble.

# Define the properties of the output ensemble.
output_neurons = 100                                    # [#] Number of neurons in the ensemble.
output_dimensions = 1                                   # [#] Dimension of the values represented by this ensemble.
output_radius = 1                                       # [-] Radius of the input space of this ensemble.

# Define the properties of the error ensemble.
error_neurons = 100                                     # [#] Number of neurons in the ensemble.
error_dimensions = 1                                    # [#] Dimension of the values represented by this ensemble.
error_radius = 1                                        # [-] Radius of the input space of this ensemble.

# Define network wide properties.
seed = 0                                                # [-] Seed for RNG.
tau_synapse = 0.001                                     # [s] Post-Synaptic Time Constant.
# tau_synapse = None                                    # [s] Post-Synaptic Time Constant.
tau_probe = 0.01                                         # [s] Probe Time Constant.
LIF_amplitude = 0.001                                   # [-] LIF Amplitude


# --------------------------- DEFINE SIMULATION PROPERTIES ---------------------------

# Define simulation properties.
dt_sim = 0.001              # [s] Simulation Step Size.
t_sim_duration = 10          # [s] Simulation Duration.

# Define the input white signal properties.
whitesignal_period = 6*t_sim_duration
# whitesignal_cutoff = 10*(1/t_sim_duration)
whitesignal_cutoff = 1
whitesignal_rms = 0.5

# Define the PES learning rate.
PES_learning_rate = 2e-4

# --------------------------- DEFINE THE FUNCTIONS TO APPROXIMATE ---------------------------

# Define the function to approximate when initializing the network.
def initial_func(x):

    # Return the initial function value.
    return 0*x

# Define the function to approximate when the network is online.
def online_func(x):

    # Return the online function value.
    return x


# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=LIF_amplitude)  # [-] Sets the neuron model to LIF.
# network.config[nengo.Ensemble].neuron_type = nengo.LIFRate(amplitude=LIF_amplitude)  # [-] Sets the neuron model to LIF.

# Build the network.
with network:

    # -------------------- Create the Network Components --------------------

    input_node = nengo.Node(output=WhiteSignal(period=whitesignal_period, high=whitesignal_cutoff, rms=whitesignal_rms), label='Input Node')
    input_ens = nengo.Ensemble(n_neurons=input_neurons, dimensions=input_dimensions, radius=input_radius, seed=seed, label='Input Ensemble')
    output_ens = nengo.Ensemble(n_neurons=output_neurons, dimensions=output_dimensions, radius=output_radius, seed=seed, label='Output Ensemble')
    output_desired_node = nengo.Node(output=lambda t, x: x, size_in=1, label='Output Desired Node')
    error_ens = nengo.Ensemble(n_neurons=error_neurons, dimensions=error_dimensions, radius=error_radius, seed=seed, label='Error Ensemble')

    # -------------------- Connect the Network Components --------------------

    input_conn = nengo.Connection(input_node, input_ens, synapse=tau_synapse)
    # output_conn = nengo.Connection(input_ens, output_ens, synapse=tau_synapse, function=initial_func, learning_rule_type=nengo.PES(learning_rate=PES_learning_rate))
    output_conn = nengo.Connection(input_ens, output_ens, synapse=tau_synapse, function=lambda x: [0], learning_rule_type=nengo.PES(learning_rate=PES_learning_rate))
    output_desired_conn = nengo.Connection(input_node, output_desired_node, synapse=tau_synapse, function=online_func)
    error_conn1 = nengo.Connection(output_ens, error_ens, synapse=tau_synapse)
    error_conn2 = nengo.Connection(output_desired_node, error_ens, synapse=tau_synapse, transform=-1)
    nengo.Connection(error_ens, output_conn.learning_rule)

    # -------------------- Collect Data From the Network --------------------

    input_node_probe = nengo.Probe(input_node, synapse=tau_probe)
    input_ens_probe = nengo.Probe(input_ens, synapse=tau_probe)
    output_ens_probe = nengo.Probe(output_ens, synapse=tau_probe)
    output_desired_node_probe = nengo.Probe(output_desired_node, synapse=tau_probe)
    error_probe = nengo.Probe(error_ens, synapse=tau_probe)

# Generate the contents of a .dot file that describes the network.
network_contents = gvz.net_diagram(network)

# Create a graphviz document using the network contents.
gvz_source = Source(network_contents, filename="network_diagram", format="jpg")


# --------------------------- SIMULATE THE NETWORK ---------------------------

# Simulate the network.
with nengo_dl.Simulator(network=network, dt=dt_sim, seed=seed) as sim:

    # Run the simulation.
    sim.run(t_sim_duration)
    # sim.run(t_sim_duration, data={input_node: input_sim})

# Retrieve the untrained simulation results.
ts_untrained = sim.trange()
input_node_untrained = sim.data[input_node_probe]
input_ens_untrained = sim.data[input_ens_probe]
output_ens_untrained = sim.data[output_ens_probe]
output_desired_node_true = sim.data[output_desired_node_probe]
error_untrained = sim.data[error_probe]

# --------------------------- PLOT THE NETWORK RESULTS ---------------------------

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the network input over time.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Network Input [-]'); plt.title(r'Network Input vs Time')
plt.plot(ts_untrained, input_node_untrained, label='Input True')
plt.plot(ts_untrained, input_ens_untrained, label='Input Untrained')
plt.legend()

# Plot the network output over time.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Network Output [-]'); plt.title(r'Network Output vs Time')
plt.plot(ts_untrained, initial_func(input_node_untrained), label='Output True (Initial)')
plt.plot(ts_untrained, output_desired_node_true, label='Output True (Online)')
plt.plot(ts_untrained, output_ens_untrained, label='Output Untrained')
plt.legend()

# Plot the network error over time.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Network Error [-]'); plt.title(r'Network Error vs Time')
plt.plot(ts_untrained, error_untrained, label='Error Untrained')
plt.legend()

# Display the figures.
plt.show()

