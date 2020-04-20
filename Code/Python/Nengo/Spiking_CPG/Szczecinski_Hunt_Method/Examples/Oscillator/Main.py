# --------------------------- BASIC HARMONIC OSCILLATOR ---------------------------

# This script creates a SNN that approximates the dynamics of a basic mass-spring-damper harmonic oscillator.


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

# --------------------------- SETUP NETWORK PROPERTIES ---------------------------

# Define simulation properties.
dt_sim = 0.001                  # [s] Simulation Step Size.
t_sim_duration = 10             # [s] Total Simulation Duration.
x0 = [0, 0]                     # [-] Initial Condition.
t_start = 1                     # [s] Define the time to start the input.

# Define the network properties.
n_neurons = 100                 # [#] Number of neurons in the ensemble.
dim = 2                         # [#] Number of dimensions of the ensemble.
radius = 1.5                    # [V] Radius of the output of the ensemble.
seed = 0                        # [-] Seed used for random number generation.
tau = 0.2                       # [s] Post-synaptic time constant.

# Define the input function.
input_func = Piecewise({0: 0, t_start: 1})  # [V] System Input Function.

# Define the initial condition function.
initial_cond_func = Piecewise({0: x0, t_start: [0, 0]})  # [-] Initial Condition Function.


# --------------------------- DEFINE THE DYNAMICAL SYSTEM TO APPROXIMATE ---------------------------

# Define the dynamical system properties.
m = 1           # [kg] System Mass.
c = 1           # [Ns/m] System Viscous Damping Coefficient.
k = 1           # [N/m] System Stiffness.

# Define the system matrices.
A = [[0, 1], [-k/m, -c/m]]
B = [[0], [1/m]]


# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=0.001)  # [-] Sets the neuron model to LIF.

# Build the network.
with network:

    # Create the network components.
    u_node = nengo.Node(output=input_func, label='u Node')
    x0_node = nengo.Node(output=initial_cond_func, label='x0 Node')
    u_ens = nengo.Ensemble(n_neurons=n_neurons, dimensions=1, radius=radius, seed=seed, label='u Ensemble')
    x_ens = nengo.Ensemble(n_neurons=n_neurons, dimensions=dim, radius=radius, seed=seed, label='x Ensemble')
    dx_ens = nengo.Ensemble(n_neurons=n_neurons, dimensions=dim, radius=radius, seed=seed, label='dx Ensemble')

    # Connect the network connections.
    nengo.Connection(u_node, u_ens, synapse=tau)
    nengo.Connection(x0_node, x_ens, synapse=tau)
    nengo.Connection(u_ens, dx_ens, transform=B, synapse=tau)
    nengo.Connection(x_ens, dx_ens, transform=A, synapse=tau)
    nengo.Connection(dx_ens, x_ens, transform=tau, synapse=tau)
    nengo.Connection(x_ens, x_ens, synapse=tau)

    # Create objects to store network data.
    u_probe = nengo.Probe(u_ens, synapse=tau)
    x_probe = nengo.Probe(x_ens, synapse=tau)
    dx_probe = nengo.Probe(dx_ens, synapse=tau)

# Generate the contents of a .dot file that describes the network.
network_contents = gvz.net_diagram(network)

# Create a graphviz document using the network contents.
gvz_source = Source(network_contents, filename="network_diagram", format="jpg")


# --------------------------- SIMULATE THE NETWORK ---------------------------

# Simulate the network.
with nengo.Simulator(network=network, dt=dt_sim) as sim:

    # Run the simulation.
    sim.run(t_sim_duration)


# --------------------------- PLOT THE NETWORK RESULTS ---------------------------

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the Network Input (i.e., u) over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel('Network Input, u [-]'); plt.title('Network Input vs Time')
plt.plot(sim.trange(), sim.data[u_probe], label='u')

# Plot the Network State (i.e., x) over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel('Network Output, x [-]'); plt.title('Network Output vs Time')
plt.plot(sim.trange(), sim.data[x_probe], label='x')

# Plot the Network State Derivative (i.e., dx) over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel(r'Network Output Derivative, $\dot{x}$ [-]'); plt.title('Network Output Derivative vs Time')
plt.plot(sim.trange(), sim.data[dx_probe], label='dx')

# Plot the trajectory of this dynamical system in the state space.
plt.figure(); plt.xlabel('Position, x [m]'); plt.ylabel(r'Velocity, $\dot{x}$ [m/s]'); plt.title('Network State Space Trajectory')
plt.plot(sim.data[x_probe].T[0], sim.data[x_probe].T[1])

# Show the network.
gvz_source.view()

# Show the figures.
plt.show()
