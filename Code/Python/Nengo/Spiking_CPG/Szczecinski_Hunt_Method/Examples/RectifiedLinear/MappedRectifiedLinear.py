# --------------------------- MAPPED RECTIFIED LINEAR MODEL ---------------------------

# This script tests a rectified linear neuron model that uses the same rectified linear model twice.  The first time, the rectified linear model is used directly.  The second time, the data is mapped before and after the application of the rectified linear model.


# --------------------------- IMPORT LIBRARIES ---------------------------

# Import standard python libraries.
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt

# Import nengo libraries.
import nengo
from nengo.processes import Piecewise
import nengo_extras.graphviz as gvz
from graphviz import Source
from nengo.utils.matplotlib import rasterplot
from nengo.dists import Choice
from nengo.utils.ensemble import response_curves, tuning_curves

# --------------------------- DEFINE NETWORK PROPERTIES ---------------------------

# Define simulation properties.
dt_sim = 0.001                                                      # [s] Simulation Step Size.
t_sim_duration = 3                                                  # [s] Total Simulation Duration.

# Define the rectified linear ensemble properties.
rectlin_neurons = 10
rectlin_dimensions = 1
rectlin_radius = 1
rectlin_intercepts = Choice([0])
rectlin_encoders = Choice([[1]])
rectlin_type = nengo.SpikingRectifiedLinear()

# Define the mapping ensemble properties.
map_neurons = 100
map_dimensions = 1
map_radius = 2

# Define network properties.
seed = 0                                                            # [-] Seed for Random Number Generation.
tau_synapse = 0.001                                                 # [s] Post-Synaptic Time Constant.
tau_probe = 0.1                                                     # [s] Probe Time Constant.

# Define the input function.
def input_func(x):

    # Return the desired function.
    return x - 1

# Define the first function to approximate.
def rectlin_func(x):

    # Return the rectified linear function.
    return np.maximum(x, 0)

# Define a function to map the [1, inf) range to (-inf, 0] and visa versa.
def map_func(x):

    # Return the mapped output.
    return -x


# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
LIF_amplitude = 0.001
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=LIF_amplitude)  # [-] Sets the neuron model to LIF.

# Build the network.
with network:

    # -------------------- Create the Network Components --------------------

    input_node = nengo.Node(output=input_func, label='Input Node')
    rectlin1_ens = nengo.Ensemble(n_neurons=rectlin_neurons, dimensions=rectlin_dimensions, radius=rectlin_radius, intercepts=rectlin_intercepts, encoders=rectlin_encoders, neuron_type=rectlin_type, seed=seed, label='Rect. Lin. 1 Ensemble')
    unity_node = nengo.Node(output=1, label='Unity Node')
    map1_ens = nengo.Ensemble(n_neurons=map_neurons, dimensions=map_dimensions, radius=map_radius, label='Map1 Ensemble')
    rectlin2_ens = nengo.Ensemble(n_neurons=rectlin_neurons, dimensions=rectlin_dimensions, radius=rectlin_radius, intercepts=rectlin_intercepts, encoders=rectlin_encoders, neuron_type=rectlin_type, seed=seed, label='Rect. Lin. 2 Ensemble')
    map2_ens = nengo.Ensemble(n_neurons=map_neurons, dimensions=map_dimensions, radius=map_radius, label='Map2 Ensemble')
    output_node = nengo.Node(output=None, size_in=1, label='Output Node')

    # -------------------- Connect the Network Components --------------------

    nengo.Connection(input_node, rectlin1_ens, synapse=tau_synapse)
    nengo.Connection(rectlin1_ens, map1_ens, synapse=tau_synapse, function=rectlin_func)
    nengo.Connection(map1_ens, rectlin2_ens, synapse=tau_synapse, function=map_func)
    nengo.Connection(unity_node, rectlin2_ens, synapse=tau_synapse)
    nengo.Connection(rectlin2_ens, map2_ens, synapse=tau_synapse, function=rectlin_func)
    nengo.Connection(map2_ens, output_node, synapse=tau_synapse, function=map_func)
    nengo.Connection(unity_node, output_node, synapse=tau_synapse)

    # -------------------- Collect Data From the Network --------------------

    input_probe = nengo.Probe(input_node, synapse=tau_probe)
    rectlin1_probe = nengo.Probe(rectlin1_ens, synapse=tau_probe)
    map1_probe = nengo.Probe(map1_ens, synapse=tau_probe)
    rectlin2_probe = nengo.Probe(rectlin2_ens, synapse=tau_probe)
    map2_probe = nengo.Probe(map2_ens, synapse=tau_probe)
    output_probe = nengo.Probe(output_node, synapse=tau_probe)

# Generate the contents of a .dot file that describes the network.
network_contents = gvz.net_diagram(network)

# Create a graphviz document using the network contents.
gvz_source = Source(network_contents, filename="network_diagram", format="jpg")

# --------------------------- SIMULATE THE NETWORK ---------------------------

# Simulate the network.
with nengo.Simulator(network=network, dt=dt_sim) as sim:

    # Run the simulation.
    sim.run(t_sim_duration)

    # Retrieve the tuning curve data.
    eval_points1, activites1 = tuning_curves(rectlin2_ens, sim)
    # eval_points2, activites2 = tuning_curves(rectlin2_ens, sim)


# --------------------------- PLOT THE NETWORK RESULTS ---------------------------

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the network input and output.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Input / Output [-]'); plt.title(r'Network Input / Output vs Time')
plt.plot(sim.trange(), sim.data[input_probe], label=r'Input')
plt.plot(sim.trange(), sim.data[output_probe], label=r'Output')

# Plot the first rectified linear ensemble output.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Rectified Linear Output 1 [-]'); plt.title(r'Rectified Linear Output 1 vs Time')
plt.plot(sim.trange(), sim.data[rectlin1_probe])

# Plot the map1 ensemble output.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Map 1 Output [-]'); plt.title(r'Map 1 Output vs Time')
plt.plot(sim.trange(), sim.data[map1_probe])

# Plot the second rectified linear ensemble output.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Rectified Linear Output 2 [-]'); plt.title(r'Rectified Linear Output 2 vs Time')
plt.plot(sim.trange(), sim.data[rectlin2_probe])

# Plot the map2 ensemble output.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Map 2 Output [-]'); plt.title(r'Map 2 Output vs Time')
plt.plot(sim.trange(), sim.data[map2_probe])

# # Show the network.
# gvz_source.view()

# Display the figures.
plt.show()


