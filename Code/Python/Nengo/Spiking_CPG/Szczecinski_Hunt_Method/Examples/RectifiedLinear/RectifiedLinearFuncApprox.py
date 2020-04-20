# --------------------------- RECTIFIED LINEAR MODEL FUNCTION APPROXIMATION ---------------------------

# This script tests a rectified linear neuron model that uses direct function approximation.


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

# Define the LIF amplitude.
LIF_amplitude = 0.001

# Define the rectified linear ensemble properties.
rectlin_neurons = 1000
rectlin_dimensions = 1
rectlin_radius = 2


# Define network properties.
seed = 0                                                            # [-] Seed for Random Number Generation.
tau_synapse = 0.001                                                 # [s] Post-Synaptic Time Constant.
tau_probe = 0.1                                                     # [s] Probe Time Constant.

# Define the input function.
def input_func(x):

    # Return the desired function.
    return x - 1

# Define the first rectified linear function.
def rectlin_func(x):

    # Return the first rectified linear function.
    return np.minimum(np.maximum(x, 0), 1)




# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=LIF_amplitude)  # [-] Sets the neuron model to LIF.

# Build the network.
with network:

    # -------------------- Create the Network Components --------------------

    input_node = nengo.Node(output=input_func, label='Input Node')
    rectlin_ens = nengo.Ensemble(n_neurons=rectlin_neurons, dimensions=rectlin_dimensions, radius=rectlin_radius, seed=seed, label='Rect. Lin. Ensemble')
    output_node = nengo.Node(output=None, size_in=1, label='Output Node')

    # -------------------- Connect the Network Components --------------------

    nengo.Connection(input_node, rectlin_ens, synapse=tau_synapse)
    nengo.Connection(rectlin_ens, output_node, synapse=tau_synapse, function=rectlin_func)


    # -------------------- Collect Data From the Network --------------------

    input_probe = nengo.Probe(input_node, synapse=tau_probe)
    rectlin_probe = nengo.Probe(rectlin_ens, synapse=tau_probe)
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
    eval_points1, activites1 = tuning_curves(rectlin_ens, sim)
    # eval_points2, activites2 = tuning_curves(rectlin2_ens, sim)


# # Show the network.
# gvz_source.view()


# --------------------------- PLOT THE NETWORK RESULTS ---------------------------

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the network input and output.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Input / Output [-]'); plt.title(r'Network Input / Output vs Time')
plt.plot(sim.trange(), sim.data[input_probe], label=r'Input')
plt.plot(sim.trange(), sim.data[output_probe], label=r'Output')

# Plot the tuning curves associated with the second rectified linear ensemble.
plt.figure(); plt.xlabel('Input [-]'); plt.ylabel('Firing Frequency [Hz]'); plt.title('Firing Frequency vs Input')
plt.plot(eval_points1, activites1)

# # Show the network.
# gvz_source.view()

# Display the figures.
plt.show()


