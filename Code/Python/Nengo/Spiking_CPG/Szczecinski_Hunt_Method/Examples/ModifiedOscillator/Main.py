# --------------------------- BASIC HARMONIC OSCILLATOR WITH RATE MODULATION ---------------------------

# This script creates a SNN that approximates the dynamics of a basic mass-spring-damper harmonic oscillator with natural frequency modulation.


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
dt_sim = 0.001                      # [s] Simulation Step Size.
t_sim_duration = 10                 # [s] Total Simulation Duration.
# x0 = [0, 0]                       # [-] Initial Condition.
x0 = [1, 0]                         # [-] Initial Condition.
t_start = 1                         # [s] Define the time to start the input.

# Define the network neuron quantities.
fn_neurons = 100                    # [#] Natural Frequency Number of Neurons.
wn_neurons = 1000                   # [#] Angular Natural Frequency Number of Neurons.
wn_squared_neurons = 1000           # [#] Squared Angular Natural Frequency Number of Neurons.
zeta_neurons = 100                  # [#] Damping Ratio Number of Neurons.
u_neurons = 100                     # [#] Input Number of Neurons.
x0_neurons = 100                    # [#] Initial Condition Number of Neurons.
x_neurons = 3000                    # [#] State Number of Neurons.

# MUX1_neurons = 3000                 # [#] Multiplexer 1 Number of Neurons.
# MUX2_neurons = 3000                 # [#] Multiplexer 2 Number of Neurons.
# MUX3_neurons = 3000                 # [#] Multiplexer 3 Number of Neurons.
# term1_neurons = 3000                # [#] Intermediate Calculation 1 Number of Neurons.
# term2_neurons = 3000                # [#] Intermediate Calculation 2 Number of Neurons.
# term3_neurons = 3000                # [#] Intermediate Calculation 3 Number of Neurons.

xhat_neurons = 1000                 # [#] Composite State Number of Neurons.
dx_neurons = 3000                   # [#] State Derivative Number of Neurons.


# Define the network dimensions.
fn_dim = 1                                                              # [#] Natural Frequency Number of Dimensions.
wn_dim = 1                                                              # [#] Angular Natural Frequency Number of Dimensions.
wn_squared_dim = wn_dim                                                 # [#] Squared Angular Natural Frequency Number of Dimensions.
zeta_dim = 1                                                            # [#] Damping Ratio Number of Dimensions.
u_dim = 1                                                               # [#] Input Space Number of Dimensions.
x0_dim = 2                                                              # [#] Initial Condition Number of Dimensions.
x_dim = 2                                                               # [#] State Space Number of Dimensions.

# MUX1_dim = 2                                                            # [#] Multiplexer 1 Number of Dimensions.
# MUX2_dim = 3                                                            # [#] Multiplexer 2 Number of Dimensions.
# MUX3_dim = 2                                                            # [#] Multiplexer 3 Number of Dimensions.
# term1_dim = 1                                                           # [#] Intermediate Calculation 1 Number of Dimensions.
# term2_dim = 1                                                           # [#] Intermediate Calculation 2 Number of Dimensions.
# term3_dim = 1                                                           # [#] Intermediate Calculation 3 Number of Dimensions.

xhat_dim = wn_dim + zeta_dim + u_dim + x_dim                            # [#] Composite State Number of Dimensions.
dx_dim = 2                                                              # [#] State Space Derivative Number of Dimensions.

# Define the network radii.
fn_radius = 1                                                           # [Hz] Natural Frequency Radius.
wn_radius = 2*np.pi*fn_radius                                           # [rad/s] Angular Natural Frequency Radius.
wn_squared_radius = wn_radius**2                                        # [rad^2/s^2] Squared Angular Natural Frequency Radius.
zeta_radius = 1                                                         # [-] Damping Ratio Radius.
u_radius = 1                                                            # [-] Input Space Radius.
x0_radius = 1                                                           # [-] Initial Condition Radius.
x_radius = 1                                                            # [-] State Space Radius.

# MUX1_radius = np.amax([wn_squared_radius, x_radius])                    # [-] Multiplexer 1 Radius.
# MUX2_radius = np.amax([zeta_radius, wn_radius, x_radius])               # [-] Multiplexer 2 Radius.
# MUX3_radius = np.amax([wn_squared_radius, u_radius])                    # [-] Multiplexer 3 Radius.
# term1_radius = wn_squared_radius*x_radius                               # [-] Intermediate Calculation 1 Radius.
# term2_radius = 2*zeta_radius*wn_radius*x_radius                         # [-] Intermediate Calculation 2 Radius.
# term3_radius = wn_squared_radius*u_radius                               # [-] Intermediate Calculation 3 Radius.

xhat_radius = np.amax([wn_radius, zeta_radius, u_radius, x_radius])     # [-] Composite State Radius.
dx_radius = 1                                                           # [-] Derivative State Space Radius.

# Define universal network parameters.
seed = 0                            # [-] Seed for Random Number Generation.
tau_synapse = 0.1                   # [s] Post-Synaptic Time Constant.
tau_probe = 0.1                     # [s] Probe Time Constant.

# Define the input function.
# input_func = Piecewise({0: 0, t_start: 1})  # [V] System Input Function.
input_func = Piecewise({0: 0, t_start: 0})  # [V] System Input Function.

# Define the initial condition function.
initial_cond_func = Piecewise({0: x0, t_start: [0, 0]})  # [-] Initial Condition Function.
# initial_cond_func = Piecewise({0: x0, t_start: x0})  # [-] Initial Condition Function.
# initial_cond_func = Piecewise({0: [0, 0], t_start: [0, 0]})  # [-] Initial Condition Function.


# --------------------------- DEFINE THE DYNAMICAL SYSTEM TO APPROXIMATE ---------------------------

# Set the desired system parameters.
fn = 1/(2*np.pi)                    # [Hz] Natural Frequency
wn = 2*np.pi*fn                     # [rad/s] Angular Natural Frequency
zeta = 0.                           # [-] Damping Ratio

# Define a function that squares its input.
def square_func(x):

    # Square the input.
    return x[0]*x[0]

# Create a function that computes the first term.
def first_term_func(x):

    # Retrieve the components of the input.
    wn_squared, x1 = x

    # Return the first term.
    return -wn_squared*x1

# Create a function that computes the second term.
def second_term_func(x):

    # Retrieve the components of the input.
    zeta, wn, x2 = x

    # Return the second term.
    return -2*zeta*wn*x2

# Create a function that computes the third term.
def third_term_func(x):

    # Retrieve the components of the input.
    wn_squared, u = x

    # Return the third term.
    return wn_squared*u

# Define the oscillator function.
def oscillator_func(xhat):

    # Retrieve the components of the oscillator function input.
    wn, zeta, u, x1, x2 = xhat

    wn = 1
    zeta = 0
    u = 0

    # Compute the state derivatives.
    dx1 = x2
    dx2 = -(wn**2)*x1 - 2*zeta*wn*x2 + (wn**2)*u

    # Return the state derivatives.
    return [dx1, dx2]

# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=0.001)  # [-] Sets the neuron model to LIF.

# Build the network.
with network:

    # Create the network input nodes.
    fn_node = nengo.Node(output=fn, label='fn Node')
    zeta_node = nengo.Node(output=zeta, label='zeta Node')
    u_node = nengo.Node(output=input_func, label='u Node')
    x0_node = nengo.Node(output=initial_cond_func, label='x0 Node')

    # Create the network ensembles.
    fn_ens = nengo.Ensemble(n_neurons=fn_neurons, dimensions=fn_dim, radius=fn_radius, seed=seed, label='fn Ensemble')
    wn_ens = nengo.Ensemble(n_neurons=wn_neurons, dimensions=wn_dim, radius=wn_radius, label='wn Ensemble')
    # wn_squared_ens = nengo.Ensemble(n_neurons=wn_squared_neurons, dimensions=wn_squared_dim, radius=wn_squared_radius, label='wn^2 Ensemble')
    zeta_ens = nengo.Ensemble(n_neurons=zeta_neurons, dimensions=zeta_dim, radius=zeta_radius, seed=seed, label='zeta Ensemble')
    u_ens = nengo.Ensemble(n_neurons=u_neurons, dimensions=u_dim, radius=u_radius, seed=seed, label='u Ensemble')
    x0_ens = nengo.Ensemble(n_neurons=x0_neurons, dimensions=x0_dim, radius=x0_radius, seed=seed, label='x0 Ensemble')
    x_ens = nengo.Ensemble(n_neurons=x_neurons, dimensions=x_dim, radius=x_radius, seed=seed, label='x Ensemble')
    xhat_ens = nengo.Ensemble(n_neurons=xhat_neurons, dimensions=xhat_dim, radius=xhat_radius, seed=seed, label='xhat Ensemble')
    dx_ens = nengo.Ensemble(n_neurons=dx_neurons, dimensions=dx_dim, radius=dx_radius, seed=seed, label='dx Ensemble')

    # Create the network connections.
    nengo.Connection(fn_node, fn_ens, synapse=tau_synapse)
    nengo.Connection(fn_ens, wn_ens, transform=2*np.pi, synapse=tau_synapse)
    # nengo.Connection(wn_ens, wn_squared_ens, function=square_func, synapse=tau_synapse)
    nengo.Connection(zeta_node, zeta_ens, synapse=tau_synapse)
    nengo.Connection(u_node, u_ens, synapse=tau_synapse)
    nengo.Connection(x0_node, x0_ens, synapse=tau_synapse)
    nengo.Connection(x0_ens, x_ens, synapse=tau_synapse)

    nengo.Connection(wn_ens, xhat_ens[0], synapse=tau_synapse)
    nengo.Connection(zeta_ens, xhat_ens[1], synapse=tau_synapse)
    nengo.Connection(u_ens, xhat_ens[2], synapse=tau_synapse)
    # nengo.Connection(fn_node, xhat_ens[0], transform=2*np.pi, synapse=tau_synapse)
    # nengo.Connection(zeta_node, xhat_ens[1], synapse=tau_synapse)
    # nengo.Connection(u_node, xhat_ens[2], synapse=tau_synapse)

    nengo.Connection(x_ens[0], xhat_ens[3], synapse=tau_synapse)
    nengo.Connection(x_ens[1], xhat_ens[4], synapse=tau_synapse)

    nengo.Connection(xhat_ens, dx_ens, function=oscillator_func, synapse=tau_synapse)

    nengo.Connection(dx_ens, x_ens, transform=tau_synapse, synapse=tau_synapse)
    nengo.Connection(x_ens, x_ens, synapse=tau_synapse)

    # Create objects to store network data.
    fn_probe = nengo.Probe(fn_ens, synapse=tau_probe)
    wn_probe = nengo.Probe(wn_ens, synapse=tau_probe)
    # wn_squared_probe = nengo.Probe(wn_squared_ens, synapse=tau_probe)
    zeta_probe = nengo.Probe(zeta_ens, synapse=tau_probe)
    u_probe = nengo.Probe(u_ens, synapse=tau_probe)
    x0_probe = nengo.Probe(x0_ens, synapse=tau_probe)
    x_probe = nengo.Probe(x_ens, synapse=tau_probe)
    xhat_probe = nengo.Probe(xhat_ens, synapse=tau_probe)
    dx_probe = nengo.Probe(dx_ens, synapse=tau_probe)

    # # Create the network input nodes.
    # fn_node = nengo.Node(output=fn, label='fn Node')
    # zeta_node = nengo.Node(output=zeta, label='zeta Node')
    # u_node = nengo.Node(output=input_func, label='u Node')
    # x0_node = nengo.Node(output=initial_cond_func, label='x0 Node')
    #
    # # Create the network ensembles.
    # fn_ens = nengo.Ensemble(n_neurons=fn_neurons, dimensions=fn_dim, radius=fn_radius, seed=seed, label='fn Ensemble')
    # wn_ens = nengo.Ensemble(n_neurons=wn_neurons, dimensions=wn_dim, radius=wn_radius, label='wn Ensemble')
    # wn_squared_ens = nengo.Ensemble(n_neurons=wn_squared_neurons, dimensions=wn_squared_dim, radius=wn_squared_radius, label='wn^2 Ensemble')
    # zeta_ens = nengo.Ensemble(n_neurons=zeta_neurons, dimensions=zeta_dim, radius=zeta_radius, seed=seed, label='zeta Ensemble')
    # u_ens = nengo.Ensemble(n_neurons=u_neurons, dimensions=u_dim, radius=u_radius, seed=seed, label='u Ensemble')
    # x0_ens = nengo.Ensemble(n_neurons=x0_neurons, dimensions=x0_dim, radius=x0_radius, seed=seed, label='x0 Ensemble')
    # x_ens = nengo.Ensemble(n_neurons=x_neurons, dimensions=x_dim, radius=x_radius, seed=seed, label='x Ensemble')
    #
    # MUX1_ens = nengo.Ensemble(n_neurons=MUX1_neurons, dimensions=MUX1_dim, radius=MUX1_radius, seed=seed, label='MUX1 Ensemble')
    # MUX2_ens = nengo.Ensemble(n_neurons=MUX2_neurons, dimensions=MUX2_dim, radius=MUX2_radius, seed=seed, label='MUX2 Ensemble')
    # MUX3_ens = nengo.Ensemble(n_neurons=MUX3_neurons, dimensions=MUX3_dim, radius=MUX3_radius, seed=seed, label='MUX3 Ensemble')
    # term1_ens = nengo.Ensemble(n_neurons=term1_neurons, dimensions=term1_dim, radius=term1_radius, seed=seed, label='term1 Ensemble')
    # term2_ens = nengo.Ensemble(n_neurons=term2_neurons, dimensions=term2_dim, radius=term2_radius, seed=seed, label='term2 Ensemble')
    # term3_ens = nengo.Ensemble(n_neurons=term3_neurons, dimensions=term3_dim, radius=term3_radius, seed=seed, label='term3 Ensemble')
    #
    # dx_ens = nengo.Ensemble(n_neurons=dx_neurons, dimensions=dx_dim, radius=dx_radius, seed=seed, label='dx Ensemble')
    #
    # # Create the network connections.
    # nengo.Connection(fn_node, fn_ens, synapse=tau_synapse)
    # nengo.Connection(fn_ens, wn_ens, transform=2*np.pi, synapse=tau_synapse)
    # nengo.Connection(wn_ens, wn_squared_ens, function=square_func, synapse=tau_synapse)
    # nengo.Connection(zeta_node, zeta_ens, synapse=tau_synapse)
    # nengo.Connection(u_node, u_ens, synapse=tau_synapse)
    # nengo.Connection(x0_node, x0_ens, synapse=tau_synapse)
    # nengo.Connection(x0_ens, x_ens, synapse=tau_synapse)
    #
    # nengo.Connection(wn_squared_ens, MUX1_ens[0], synapse=tau_synapse)
    # nengo.Connection(x_ens[0], MUX1_ens[1], synapse=tau_synapse)
    # nengo.Connection(zeta_ens, MUX2_ens[0], synapse=tau_synapse)
    # nengo.Connection(wn_ens, MUX2_ens[1], synapse=tau_synapse)
    # nengo.Connection(x_ens[1], MUX2_ens[2], synapse=tau_synapse)
    # nengo.Connection(wn_squared_ens, MUX3_ens[0], synapse=tau_synapse)
    # nengo.Connection(u_ens, MUX3_ens[1], synapse=tau_synapse)
    #
    # nengo.Connection(MUX1_ens, term1_ens, function=first_term_func, synapse=tau_synapse)
    # nengo.Connection(MUX2_ens, term2_ens, function=second_term_func, synapse=tau_synapse)
    # nengo.Connection(MUX3_ens, term3_ens, function=third_term_func, synapse=tau_synapse)
    #
    # nengo.Connection(x_ens[1], dx_ens[0], synapse=tau_synapse)
    # nengo.Connection(term1_ens, dx_ens[1], synapse=tau_synapse)
    # nengo.Connection(term2_ens, dx_ens[1], synapse=tau_synapse)
    # nengo.Connection(term3_ens, dx_ens[1], synapse=tau_synapse)
    #
    # nengo.Connection(dx_ens, x_ens, transform=tau_synapse, synapse=tau_synapse)
    # nengo.Connection(x_ens, x_ens, synapse=tau_synapse)
    #
    # # Create objects to store network data.
    # fn_probe = nengo.Probe(fn_ens, synapse=tau_probe)
    # wn_probe = nengo.Probe(wn_ens, synapse=tau_probe)
    # wn_squared_probe = nengo.Probe(wn_squared_ens, synapse=tau_probe)
    # zeta_probe = nengo.Probe(zeta_ens, synapse=tau_probe)
    # u_probe = nengo.Probe(u_ens, synapse=tau_probe)
    # x0_probe = nengo.Probe(x0_ens, synapse=tau_probe)
    # x_probe = nengo.Probe(x_ens, synapse=tau_probe)
    #
    # MUX1_probe = nengo.Probe(MUX1_ens, synapse=tau_probe)
    # MUX2_probe = nengo.Probe(MUX2_ens, synapse=tau_probe)
    # MUX3_probe = nengo.Probe(MUX3_ens, synapse=tau_probe)
    #
    # term1_probe = nengo.Probe(term1_ens, synapse=tau_probe)
    # term2_probe = nengo.Probe(term2_ens, synapse=tau_probe)
    # term3_probe = nengo.Probe(term3_ens, synapse=tau_probe)
    #
    # dx_probe = nengo.Probe(dx_ens, synapse=tau_probe)


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

# Plot the Network Natural Frequency (i.e., fn) over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel(r'Natural Frequency, $f_n$ [Hz]'); plt.title(r'Natural Frequency, $f_n$ [Hz] vs Time')
plt.plot(sim.trange(), sim.data[fn_probe], label=r'$f_n$')

# Plot the Network Angular Natural Frequency (i.e., wn) over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel(r'Angular Natural Frequency, $w_n$ [rad/s]'); plt.title(r'Angular Natural Frequency, $w_n$ $\left[ \frac{\mathrm{rad}}{\mathrm{s}} \right]$ vs Time')
plt.plot(sim.trange(), sim.data[wn_probe], label=r'$w_n$')

# # Plot the Squared Network Angular Natural Frequency (i.e., wn) over Time.
# plt.figure(); plt.xlabel('Time [s]'); plt.ylabel(r'Squared Angular Natural Frequency, $w_n^2$ $\left[ \frac{\mathrm{rad}^2}{\mathrm{s}^2} \right]$'); plt.title(r'Squared Angular Natural Frequency, $w_n^2$ $\left[ \frac{\mathrm{rad}^2}{\mathrm{s}^2} \right]$ vs Time')
# plt.plot(sim.trange(), sim.data[wn_squared_probe], label=r'$w_n^2$')

# Plot the Network Damping Ratio (i.e., zeta) over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel(r'Damping Ratio, $\zeta$ [-]'); plt.title(r'Damping Ratio, $\zeta$ [-] vs Time')
plt.plot(sim.trange(), sim.data[zeta_probe], label=r'$\zeta$')

# Plot the Network Input (i.e., u) over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel('Network Input, u [-]'); plt.title('Network Input, u [-] vs Time')
plt.plot(sim.trange(), sim.data[u_probe], label='u')

# Plot the Network State Initial Condition (i.e., x0) over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel(r'Initial Condition, $x_0$ [-]'); plt.title(r'Initial Condition, $x_0$ [-] vs Time')
plt.plot(sim.trange(), sim.data[x0_probe], label=r'$x_0$')

# Plot the Network State (i.e., x) over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel('Network State, x [-]'); plt.title('Network State, x [-] vs Time')
plt.plot(sim.trange(), sim.data[x_probe], label='x')



# # Plot the MUX1 State over Time
# plt.figure(); plt.xlabel('Time [s]'), plt.ylabel('MUX 1 [-]'), plt.title('MUX 1 vs Time')
# plt.plot(sim.trange(), sim.data[MUX1_probe], label='MUX1')
#
# # Plot the MUX2 State over Time
# plt.figure(); plt.xlabel('Time [s]'), plt.ylabel('MUX 2 [-]'), plt.title('MUX 2 vs Time')
# plt.plot(sim.trange(), sim.data[MUX2_probe], label='MUX2')
#
# # Plot the MUX3 State over Time
# plt.figure(); plt.xlabel('Time [s]'), plt.ylabel('MUX 3 [-]'), plt.title('MUX 3 vs Time')
# plt.plot(sim.trange(), sim.data[MUX3_probe], label='MUX3')
#
# # Plot the Term 1 State over Time
# plt.figure(); plt.xlabel('Time [s]'), plt.ylabel('Term 1 [-]'), plt.title('Term 1 vs Time')
# plt.plot(sim.trange(), sim.data[term1_probe], label='term1')
#
# # Plot the Term 2 State over Time
# plt.figure(); plt.xlabel('Time [s]'), plt.ylabel('Term 2 [-]'), plt.title('Term 2 vs Time')
# plt.plot(sim.trange(), sim.data[term2_probe], label='term2')
#
# # Plot the Term 3 State over Time
# plt.figure(); plt.xlabel('Time [s]'), plt.ylabel('Term 3 [-]'), plt.title('Term 3 vs Time')
# plt.plot(sim.trange(), sim.data[term3_probe], label='term3')




# Plot the Composite Network State (i.e., xhat) over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel(r'Network State, $\hat{x}$ [-]'); plt.title(r'Network State, $\hat{x}$ [-] vs Time')
plt.plot(sim.trange(), sim.data[xhat_probe], label='xhat')

# Plot the Network State Derivative (i.e., dx) over Time.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel(r'Network Output Derivative, $\dot{x}$ [-]'); plt.title(r'Network Output Derivative, $\dot{x}$ [-] vs Time')
plt.plot(sim.trange(), sim.data[dx_probe], label='dx')

# Plot the trajectory of this dynamical system in the state space.
plt.figure(); plt.xlabel('Position, x [m]'); plt.ylabel(r'Velocity, $\dot{x}$ $\left[ \frac{\mathrm{m}}{\mathrm{s}} \right]$'); plt.title('Network State Space Trajectory')
plt.plot(sim.data[x_probe].T[0], sim.data[x_probe].T[1])

# Show the network.
gvz_source.view()

# Show the figures.
plt.show()
