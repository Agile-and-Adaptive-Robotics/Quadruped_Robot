# --------------------------- UNIQUE NEURON MODELS ---------------------------

# This script experiments with the creation of SNNs using custom neuron models.


# --------------------------- IMPORT LIBRARIES ---------------------------

# Import standard python libraries.
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt

# Import nengo libraries.
import nengo
from nengo.utils.matplotlib import rasterplot
from nengo.processes import Piecewise
import nengo_extras.graphviz as gvz
from graphviz import Source
from nengo.builder import Builder
from nengo.builder.operator import Operator
from nengo.utils.ensemble import tuning_curves

# --------------------------- CREATE CUSTOM NEURON TYPE ---------------------------

# Create the front end class for our custom neuron model.
class RectifiedLinear(nengo.neurons.NeuronType):
    """A rectified linear neuron model."""

    # We don't need any additional parameters here;
    # gain and bias are sufficient. But, if we wanted
    # more parameters, we could accept them by creating
    # an __init__ method.

    def gain_bias(self, max_rates, intercepts):
        """Return gain and bias given maximum firing rate and x-intercept."""
        gain = max_rates / (1 - intercepts)
        bias = -intercepts * gain
        return gain, bias

    def step_math(self, dt, J, output):
        """Compute rates in Hz for input current (incl. bias)"""
        output[...] = np.maximum(0., J)


# Create the backend class for our custom neuron class.
class SimRectifiedLinear(Operator):
    """Set output to the firing rate of a rectified linear neuron model."""

    def __init__(self, output, J, neurons, tag=None):
        super().__init__(tag=tag)
        self.neurons = neurons  # The RectifiedLinear instance

        # Operators must explicitly tell the simulator what signals
        # they read, set, update, and increment
        self.reads = [J]
        self.updates = [output]
        self.sets = []
        self.incs = []

    @property
    def output(self):
        """Output signal of the ensemble."""
        return self.updates[0]

    @property
    def J(self):
        return self.reads[0]

    # If we needed additional signals that aren't in one of the
    # reads, updates, sets, or incs lists, we can initialize them
    # by making an `init_signals(self, signals, dt)` method.

    def make_step(self, signals, dt, rng):
        """Return a function that the Simulator will execute on each step.

        `signals` contains a dictionary mapping each signal to
        an ndarray which can be used in the step function.
        `dt` is the simulator timestep (which we don't use).
        """
        J = signals[self.J]
        output = signals[self.output]

        def step_simrectifiedlinear():
            # Gain and bias are already taken into account here,
            # so we just need to rectify
            output[...] = np.maximum(0, J)

        return step_simrectifiedlinear

# Build the neuron model
@Builder.register(RectifiedLinear)
def build_rectified_linear(model, neuron_type, neurons):
    model.operators.append(SimRectifiedLinear(output=model.sig[neurons]['out'], J=model.sig[neurons]['in'], neurons=neuron_type))


# --------------------------- SETUP NETWORK PROPERTIES ---------------------------

# Define simulation properties.
dt_sim = 0.001                  # [s] Simulation Step Size.
t_sim_duration = 1             # [s] Total Simulation Duration.
x0 = [0, 0]                     # [-] Initial Condition.
t_start = 1                     # [s] Define the time to start the input.

# Define the network properties.
n_neurons = 1                   # [#] Number of neurons in the ensemble.
dim = 1                         # [#] Number of dimensions of the ensemble.
radius = 1                      # [V] Radius of the output of the ensemble.
seed = 0                        # [-] Seed used for random number generation.
tau = 0.01                      # [s] Post-synaptic time constant.


# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=1)  # [-] Sets the neuron model to LIF.

# Build the network.
with network:

    # Create the network components.
    u_node = nengo.Node(output=lambda x: x, label='u Node')
    u_ens = nengo.Ensemble(n_neurons=100, dimensions=dim, radius=radius, seed=seed, label='u Ensemble')
    x_ens = nengo.Ensemble(n_neurons=n_neurons, dimensions=dim, radius=radius, encoders=[[1]], intercepts=[0], max_rates=[100], neuron_type=RectifiedLinear(), seed=seed, label='x Ensemble')

    # Create the network connections.
    nengo.Connection(u_node, u_ens, synapse=None)
    nengo.Connection(u_ens, x_ens, synapse=None)

    # Create objects to store network data.
    u_probe = nengo.Probe(u_ens, synapse=None)
    x_probe = nengo.Probe(x_ens, synapse=None)


# --------------------------- SIMULATE THE NETWORK ---------------------------

# Simulate the network.
with nengo.Simulator(network=network, dt=dt_sim) as sim:

    # Run the simulation.
    sim.run(t_sim_duration)


# --------------------------- PLOT THE NETWORK RESULTS ---------------------------

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the Network Input over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel('Network Input [-]'); plt.title('Network Input vs Time')
plt.plot(sim.trange(), sim.data[u_probe], label='u')

# Plot the Network Output over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel('Network Output [-]'); plt.title('Network Output vs Time')
plt.plot(sim.trange(), sim.data[x_probe], label='x')

# Generate the raster plot for the output ensemble.
plt.figure(); plt.xlabel('x Ensemble Input'); plt.ylabel('x Ensemble Spike Train'); plt.title('x Ensemble Spike Train vs Ensemble Input')
rasterplot(sim.trange(), sim.data[x_probe])

# Show the figures.
plt.show()