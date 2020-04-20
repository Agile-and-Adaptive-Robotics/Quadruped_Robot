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
tauh_neurons = 100
tauh_dimensions = 1
tauh_radius = 2*tauhmax

# Define network properties.
seed = 0                                                            # [-] Seed for Random Number Generation.
tau_synapse = 0.001                                                 # [s] Post-Synaptic Time Constant.
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
    tauhterm1_ens = nengo.Ensemble(n_neurons=tauhterm1_neurons, dimensions=tauhterm1_dimensions, radius=tauhterm1_radius, seed=seed, label='tauh Inter. Calc. 1 Ensemble')
    # tauhterm1_ens = nengo.Ensemble(n_neurons=tauhterm1_neurons, dimensions=tauhterm1_dimensions, radius=tauhterm1_radius, seed=seed, label='tauh Inter. Calc. 1 Ensemble', intercepts=Choice([0]), encoders=Choice([[1]]))
    # tauhterm1_ens = nengo.Ensemble(n_neurons=tauhterm1_neurons, dimensions=tauhterm1_dimensions, radius=tauhterm1_radius, seed=seed, label='tauh Inter. Calc. 1 Ensemble', intercepts=Choice([0]), encoders=Choice([[1]]), neuron_type=nengo.SpikingRectifiedLinear())
    # tauhterm1_ens = nengo.Ensemble(n_neurons=tauhterm1_neurons, dimensions=tauhterm1_dimensions, radius=tauhterm1_radius, seed=seed, label='tauh Inter. Calc. 1 Ensemble', neuron_type=nengo.SpikingRectifiedLinear())
    tauhterm2_ens = nengo.Ensemble(n_neurons=tauhterm2_neurons, dimensions=tauhterm2_dimensions, radius=tauhterm2_radius, seed=seed, label='tauh Inter. Calc. 2 Ensemble')
    # tauhterm2_ens = nengo.Ensemble(n_neurons=tauhterm2_neurons, dimensions=tauhterm2_dimensions, radius=tauhterm2_radius, seed=seed, label='tauh Inter. Calc. 2 Ensemble', intercepts=Choice([0]), encoders=Choice([[1]]))
    # tauhterm2_ens = nengo.Ensemble(n_neurons=tauhterm2_neurons, dimensions=tauhterm2_dimensions, radius=tauhterm2_radius, seed=seed, label='tauh Inter. Calc. 2 Ensemble', intercepts=Choice([0]), encoders=Choice([[1]]), neuron_type=nengo.SpikingRectifiedLinear())
    # tauhterm2_ens = nengo.Ensemble(n_neurons=tauhterm2_neurons, dimensions=tauhterm2_dimensions, radius=tauhterm2_radius, seed=seed, label='tauh Inter. Calc. 2 Ensemble', neuron_type=nengo.SpikingRectifiedLinear())
    MUXtauh_ens = nengo.Ensemble(n_neurons=MUXtauh_neurons, dimensions=MUXtauh_dimensions, radius=MUXtauh_radius, seed=seed, label='tauh MUX Ensemble')
    tauh_ens = nengo.Ensemble(n_neurons=tauh_neurons, dimensions=tauh_dimensions, radius=tauh_dimensions, seed=seed, label='tauh Ensemble')

    U_node = nengo.Node(output=None, size_in=1, label='U Node')
    minf_node = nengo.Node(output=None, size_in=1, label='minf Node')
    hinf_node = nengo.Node(output=None, size_in=1, label='hinf Node')
    tauhterm1_node = nengo.Node(output=None, size_in=1, label='tauhterm1 Node')
    tauhterm2_node = nengo.Node(output=None, size_in=1, label='tauhterm2 Node')
    MUXtauh_node = nengo.Node(output=lambda t, x: x, size_in=2, label='MUXtauh Node')
    tauh_node = nengo.Node(output=None, size_in=1, label='tauh Node')

    U_direct = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dimensions, radius=U_radius, seed=seed, label='U Direct', neuron_type=nengo.Direct())
    minf_direct = nengo.Ensemble(n_neurons=minf_neurons, dimensions=minf_dimensions, radius=minf_radius, seed=seed, label='minf Direct', neuron_type=nengo.Direct())
    hinf_direct = nengo.Ensemble(n_neurons=hinf_neurons, dimensions=hinf_dimensions, radius=hinf_radius, seed=seed, label='minf Direct', neuron_type=nengo.Direct())
    tauhterm1_direct = nengo.Ensemble(n_neurons=tauhterm1_neurons, dimensions=tauhterm1_dimensions, radius=tauhterm1_radius, seed=seed, label='tauh Inter. Calc. 1 Direct', neuron_type=nengo.Direct())
    tauhterm2_direct = nengo.Ensemble(n_neurons=tauhterm2_neurons, dimensions=tauhterm2_dimensions, radius=tauhterm2_radius, seed=seed, label='tauh Inter. Calc. 2 Direct', neuron_type=nengo.Direct())
    MUXtauh_direct = nengo.Ensemble(n_neurons=MUXtauh_neurons, dimensions=MUXtauh_dimensions, radius=MUXtauh_radius, seed=seed, label='tauh MUX Direct', neuron_type=nengo.Direct())
    tauh_direct = nengo.Ensemble(n_neurons=tauh_neurons, dimensions=tauh_dimensions, radius=tauh_dimensions, seed=seed, label='tauh Direct', neuron_type=nengo.Direct())


    tauh_indirect = nengo.Node(output=None, size_in=1, label='tauh Indirect')

    # -------------------- Connect the Network Components --------------------

    nengo.Connection(input_node, U_ens, synapse=tau_synapse)
    nengo.Connection(U_ens, minf_ens, synapse=tau_synapse, function=NaCh_Act_func)
    nengo.Connection(U_ens, hinf_ens, synapse=tau_synapse, function=NaCh_Deact_func)
    nengo.Connection(U_ens, tauhterm1_ens, synapse=tau_synapse, function=NaCh_TimeConstInterCalc1_func)
    nengo.Connection(tauhterm1_ens, tauhterm2_ens, synapse=tau_synapse, function=NaCh_TimeConstInterCalc2_func)
    nengo.Connection(hinf_ens, MUXtauh_ens[0], synapse=tau_synapse, transform=1/hinf_radius)
    nengo.Connection(tauhterm2_ens, MUXtauh_ens[1], synapse=tau_synapse, transform=1/tauhterm2_radius)
    nengo.Connection(MUXtauh_ens, tauh_ens, synapse=tau_synapse, function=NaCh_TimeConst_func)

    nengo.Connection(input_node, U_node, synapse=tau_synapse)
    nengo.Connection(U_ens, minf_node, synapse=tau_synapse, function=NaCh_Act_func)
    nengo.Connection(U_ens, hinf_node, synapse=tau_synapse, function=NaCh_Deact_func)
    nengo.Connection(U_ens, tauhterm1_node, synapse=tau_synapse, function=NaCh_TimeConstInterCalc1_func)
    nengo.Connection(tauhterm1_ens, tauhterm2_node, synapse=tau_synapse, function=NaCh_TimeConstInterCalc2_func)
    nengo.Connection(hinf_ens, MUXtauh_node[0], synapse=tau_synapse, transform=1/hinf_radius)
    nengo.Connection(tauhterm2_ens, MUXtauh_node[1], synapse=tau_synapse, transform=1/tauhterm2_radius)
    nengo.Connection(MUXtauh_ens, tauh_node, synapse=tau_synapse, function=NaCh_TimeConst_func)

    nengo.Connection(input_node, U_direct, synapse=tau_synapse)
    nengo.Connection(U_direct, minf_direct, synapse=tau_synapse, function=NaCh_Act_func)
    nengo.Connection(U_direct, hinf_direct, synapse=tau_synapse, function=NaCh_Deact_func)
    nengo.Connection(U_direct, tauhterm1_direct, synapse=tau_synapse, function=NaCh_TimeConstInterCalc1_func)
    nengo.Connection(tauhterm1_direct, tauhterm2_direct, synapse=tau_synapse, function=NaCh_TimeConstInterCalc2_func)
    nengo.Connection(hinf_direct, MUXtauh_direct[0], synapse=tau_synapse, transform=1/hinf_radius)
    nengo.Connection(tauhterm2_direct, MUXtauh_direct[1], synapse=tau_synapse, transform=1/tauhterm2_radius)
    nengo.Connection(MUXtauh_direct, tauh_direct, synapse=tau_synapse, function=NaCh_TimeConst_func)

    nengo.Connection(MUXtauh_node, tauh_indirect, synapse=tau_synapse, function=NaCh_TimeConst_func)

    # -------------------- Collect Data From the Network --------------------

    input_node_probe = nengo.Probe(input_node, synapse=tau_probe)

    U_ens_probe = nengo.Probe(U_ens, synapse=tau_probe)
    minf_ens_probe = nengo.Probe(minf_ens, synapse=tau_probe)
    hinf_ens_probe = nengo.Probe(hinf_ens, synapse=tau_probe)
    tauhterm1_ens_probe = nengo.Probe(tauhterm1_ens, synapse=tau_probe)
    tauhterm2_ens_probe = nengo.Probe(tauhterm2_ens, synapse=tau_probe)
    MUXtauh_ens_probe = nengo.Probe(MUXtauh_ens, synapse=tau_probe)
    tauh_ens_probe = nengo.Probe(tauh_ens,synapse=tau_probe)

    U_node_probe = nengo.Probe(U_node, synapse=tau_probe)
    minf_node_probe = nengo.Probe(minf_node, synapse=tau_probe)
    hinf_node_probe = nengo.Probe(hinf_node, synapse=tau_probe)
    tauhterm1_node_probe = nengo.Probe(tauhterm1_node, synapse=tau_probe)
    tauhterm2_node_probe = nengo.Probe(tauhterm2_node, synapse=tau_probe)
    MUXtauh_node_probe = nengo.Probe(MUXtauh_node, synapse=tau_probe)
    tauh_node_probe = nengo.Probe(tauh_node,synapse=tau_probe)

    U_direct_probe = nengo.Probe(U_direct, synapse=tau_probe)
    minf_direct_probe = nengo.Probe(minf_direct, synapse=tau_probe)
    hinf_direct_probe = nengo.Probe(hinf_direct, synapse=tau_probe)
    tauhterm1_direct_probe = nengo.Probe(tauhterm1_direct, synapse=tau_probe)
    tauhterm2_direct_probe = nengo.Probe(tauhterm2_direct, synapse=tau_probe)
    MUXtauh_direct_probe = nengo.Probe(MUXtauh_direct, synapse=tau_probe)
    tauh_direct_probe = nengo.Probe(tauh_direct,synapse=tau_probe)

    tauh_indirect_probe = nengo.Probe(tauh_indirect,synapse=tau_probe)



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
    U_evals, U_activites = tuning_curves(U_ens, sim)
    minf_evals, minf_activites = tuning_curves(minf_ens, sim)
    hinf_evals, hinf_activites = tuning_curves(hinf_ens, sim)
    tauhterm1_evals, tauhterm1_activites = tuning_curves(tauhterm1_ens, sim)
    tauhterm2_evals, tauhterm2_activites = tuning_curves(tauhterm2_ens, sim)
    MUXtauh_evals, MUXtauh_activites = tuning_curves(MUXtauh_ens, sim)
    tauh_evals, tauh_activites = tuning_curves(tauh_ens, sim)


# --------------------------- COMPUTE THE FINAL TAUH CALCULATION MANUALLY ---------------------------

tauh_manual = []

for k in range(len(sim.data[MUXtauh_ens_probe])):
    tauh_manual.append(NaCh_TimeConst_func(sim.data[MUXtauh_ens_probe][k]))


# --------------------------- PLOT THE NETWORK RESULTS ---------------------------

# Set plot properties.
plt.rc('text', usetex=True)

# Plot the network input over time.
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Network Input [V]'); plt.title(r'Network Input vs Time')
plt.plot(sim.trange(), sim.data[input_node_probe], label=r'Input')

# Plot the membrane voltage over time (U).
plt.figure(); plt.xlabel(r'Time [s]'); plt.ylabel(r'Membrane Voltage, $U$ [V]'); plt.title(r'Membrane Voltage, $U$ [V] vs Time')
plt.plot(sim.trange(), sim.data[U_ens_probe], label=r'U_{ens}')
plt.plot(sim.trange(), sim.data[U_node_probe], label=r'U_{node}')
plt.plot(sim.trange(), sim.data[U_direct_probe], label=r'U_{direct}')
plt.legend()

# Plot the Na Ch Activation (minf).
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Steady State Na Ch. Activation, $m_{\infty}$ [-]'); axs[0].set_title(r'Steady State Na Ch. Activation, $m_{\infty}$ [-] vs Time')
axs[0].plot(sim.trange(), sim.data[minf_ens_probe], label=r'$m_{\infty, ens}$')
axs[0].plot(sim.trange(), sim.data[minf_node_probe], label=r'$m_{\infty, node}$')
axs[0].plot(sim.trange(), sim.data[minf_direct_probe], label=r'$m_{\infty, direct}$')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Steady State Na Ch. Activation, $m_{\infty}$ [-]'); axs[1].set_title(r'Steady State Na Ch. Activation, $m_{\infty}$ [-] vs Membrane Voltage')
axs[1].plot(sim.data[U_direct_probe], sim.data[minf_ens_probe], label=r'$m_{\infty, ens}$')
axs[1].plot(sim.data[U_direct_probe], sim.data[minf_node_probe], label=r'$m_{\infty, node}$')
axs[1].plot(sim.data[U_direct_probe], sim.data[minf_direct_probe], label=r'$m_{\infty, direct}$')
axs[1].legend()

# Plot the Na Ch Deactivation (hinf)
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Steady State Na Ch. Deactivation, $h_{\infty}$ [-]'); axs[0].set_title(r'Steady State Na Ch. Deactivation, $h_{\infty}$ [-] vs Time')
axs[0].plot(sim.trange(), sim.data[hinf_ens_probe], label=r'$h_{\infty, ens}$')
axs[0].plot(sim.trange(), sim.data[hinf_node_probe], label=r'$h_{\infty, node}$')
axs[0].plot(sim.trange(), sim.data[hinf_direct_probe], label=r'$h_{\infty, direct}$')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Steady State Na Ch. Deactivation, $h_{\infty}$ [-]'); axs[1].set_title(r'Steady State Na Ch. Deactivation, $h_{\infty}$ [-] vs Membrane Voltage')
axs[1].plot(sim.data[U_direct_probe], sim.data[hinf_ens_probe], label=r'$h_{\infty, ens}$')
axs[1].plot(sim.data[U_direct_probe], sim.data[hinf_node_probe], label=r'$h_{\infty, node}$')
axs[1].plot(sim.data[U_direct_probe], sim.data[hinf_direct_probe], label=r'$h_{\infty, direct}$')
axs[1].legend()

# Plot the first Na Ch Time Constant Calculation (tauhterm1)
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Na Ch. Time Constant Calc. 1, $\tau_{\infty, 1}$ [-]'); axs[0].set_title(r'Na Ch. Time Constant Calc. 1, $\tau_{\infty, 1}$ [-] vs Time')
axs[0].plot(sim.trange(), sim.data[tauhterm1_ens_probe], label=r'$\tau_{\infty, ens, 1}$')
axs[0].plot(sim.trange(), sim.data[tauhterm1_node_probe], label=r'$\tau_{\infty, node, 1}$')
axs[0].plot(sim.trange(), sim.data[tauhterm1_direct_probe], label=r'$\tau_{\infty, direct, 1}$')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Na Ch. Time Constant Calc. 1, $\tau_{\infty, 1}$ [-]'); axs[1].set_title(r'Na Ch. Time Constant Calc. 1, $\tau_{\infty, 1}$ [-] vs Membrane Voltage')
axs[1].plot(sim.data[U_direct_probe], sim.data[tauhterm1_ens_probe], label=r'$\tau_{\infty, ens, 1}$')
axs[1].plot(sim.data[U_direct_probe], sim.data[tauhterm1_node_probe], label=r'$\tau_{\infty, node, 1}$')
axs[1].plot(sim.data[U_direct_probe], sim.data[tauhterm1_direct_probe], label=r'$\tau_{\infty, direct, 1}$')
axs[1].legend()

# Plot the second Na Ch Time Constant Calculation (tauhterm2)
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Na Ch. Time Constant Calc. 2, $\tau_{\infty, 2}$ [-]'); axs[0].set_title(r'Na Ch. Time Constant Calc. 2, $\tau_{\infty, 2}$ [-] vs Time')
axs[0].plot(sim.trange(), sim.data[tauhterm2_ens_probe], label=r'$\tau_{\infty, ens, 2}$')
axs[0].plot(sim.trange(), sim.data[tauhterm2_node_probe], label=r'$\tau_{\infty, node, 2}$')
axs[0].plot(sim.trange(), sim.data[tauhterm2_direct_probe], label=r'$\tau_{\infty, direct, 2}$')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Na Ch. Time Constant Calc. 2, $\tau_{\infty, 2}$ [-]'); axs[1].set_title(r'Na Ch. Time Constant Calc. 2, $\tau_{\infty, 2}$ [-] vs Membrane Voltage')
axs[1].plot(sim.data[U_direct_probe], sim.data[tauhterm2_ens_probe], label=r'$\tau_{\infty, ens, 2}$')
axs[1].plot(sim.data[U_direct_probe], sim.data[tauhterm2_node_probe], label=r'$\tau_{\infty, node, 2}$')
axs[1].plot(sim.data[U_direct_probe], sim.data[tauhterm2_direct_probe], label=r'$\tau_{\infty, direct, 2}$')
axs[1].legend()

# Plot the Na Ch Time Constant Multiplexer (MUXtauh)
fig, axs = plt.subplots(2, 2)
axs[0, 0].set_xlabel(r'Time [s]'); axs[0, 0].set_ylabel(r'Na Ch. Time Constant Multiplexer, $h_{\infty}$ [-]'); axs[0, 0].set_title(r'Na Ch. Time Constant Multiplexer, $h_{\infty}$ [-] vs Time')
axs[0, 0].plot(sim.trange(), sim.data[MUXtauh_ens_probe][:, 0], label=r'$h_{\infty, ens}$')
axs[0, 0].plot(sim.trange(), sim.data[MUXtauh_node_probe][:, 0], label=r'$h_{\infty, node}$')
axs[0, 0].plot(sim.trange(), sim.data[MUXtauh_direct_probe][:, 0], label=r'$h_{\infty, direct}$')
axs[0, 0].legend()
axs[0, 1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[0, 1].set_ylabel(r'Na Ch. Time Constant Multiplexer, $h_{\infty}$ [-]'); axs[0, 1].set_title(r'Na Ch. Time Constant Multiplexer, $h_{\infty}$ [-] vs Membrane Voltage')
axs[0, 1].plot(sim.data[U_direct_probe], sim.data[MUXtauh_ens_probe][:, 0], label=r'$h_{\infty, ens}$')
axs[0, 1].plot(sim.data[U_direct_probe], sim.data[MUXtauh_node_probe][:, 0], label=r'$h_{\infty, node}$')
axs[0, 1].plot(sim.data[U_direct_probe], sim.data[MUXtauh_direct_probe][:, 0], label=r'$h_{\infty, direct}$')
axs[0, 1].legend()
axs[1, 0].set_xlabel(r'Time [s]'); axs[1, 0].set_ylabel(r'Na Ch. Time Constant Multiplexer, $\tau_{\infty, 2}$ [-]'); axs[1, 0].set_title(r'Na Ch. Time Constant Multiplexer, $\tau_{\infty, 2}$ [-] vs Time')
axs[1, 0].plot(sim.trange(), sim.data[MUXtauh_ens_probe][:, 1], label=r'$\tau_{\infty, ens, 2}$')
axs[1, 0].plot(sim.trange(), sim.data[MUXtauh_node_probe][:, 1], label=r'$\tau_{\infty, node, 2}$')
axs[1, 0].plot(sim.trange(), sim.data[MUXtauh_direct_probe][:, 1], label=r'$\tau_{\infty, direct, 2}$')
axs[1, 0].legend()
axs[1, 1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1, 1].set_ylabel(r'Na Ch. Time Constant Multiplexer, $\tau_{\infty}$ [-]'); axs[1, 1].set_title(r'Na Ch. Time Constant Multiplexer, $\tau_{\infty, 2}$ [-] vs Membrane Voltage')
axs[1, 1].plot(sim.data[U_direct_probe], sim.data[MUXtauh_ens_probe][:, 1], label=r'$\tau_{\infty, ens, 2}$')
axs[1, 1].plot(sim.data[U_direct_probe], sim.data[MUXtauh_node_probe][:, 1], label=r'$\tau_{\infty, node, 2}$')
axs[1, 1].plot(sim.data[U_direct_probe], sim.data[MUXtauh_direct_probe][:, 1], label=r'$\tau_{\infty, direct, 2}$')
axs[1, 1].legend()

# Plot the Na Ch Time Constant.
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel(r'Time [s]'); axs[0].set_ylabel(r'Na Ch. Time Constant (Final Calc.), $\tau_{\infty}$ [-]'); axs[0].set_title(r'Na Ch. Time Constant (Final Calc.), $\tau_{\infty}$ [-] vs Time')
axs[0].plot(sim.trange(), sim.data[tauh_ens_probe], label=r'$\tau_{\infty, ens}$')
axs[0].plot(sim.trange(), sim.data[tauh_node_probe], label=r'$\tau_{\infty, node}$')
axs[0].plot(sim.trange(), sim.data[tauh_direct_probe], label=r'$\tau_{\infty, direct}$')
axs[0].plot(sim.trange(), sim.data[tauh_indirect_probe], label=r'$\tau_{\infty, indirect}$')
axs[0].plot(sim.trange(), tauh_manual, label=r'$\tau_{\infty, manual}$')
axs[0].legend()
axs[1].set_xlabel(r'Membrane Voltage, $U$ [V]'); axs[1].set_ylabel(r'Na Ch. Time Constant (Final Calc.), $\tau_{\infty}$ [-]'); axs[1].set_title(r'Na Ch. Time Constant (Final Calc.), $\tau_{\infty}$ [-] vs Membrane Voltage')
axs[1].plot(sim.data[U_direct_probe], sim.data[tauh_ens_probe], label=r'$\tau_{\infty, ens}$')
axs[1].plot(sim.data[U_direct_probe], sim.data[tauh_node_probe], label=r'$\tau_{\infty, node}$')
axs[1].plot(sim.data[U_direct_probe], sim.data[tauh_direct_probe], label=r'$\tau_{\infty, direct}$')
axs[1].plot(sim.data[U_direct_probe], sim.data[tauh_indirect_probe], label=r'$\tau_{\infty, indirect}$')
axs[1].plot(sim.data[U_direct_probe], tauh_manual, label=r'$\tau_{\infty, manual}$')
axs[1].legend()


plt.figure(); plt.xlabel('Input [-]'); plt.ylabel(r'$m_{\infty}$ Firing Frequency [Hz]'); plt.title(r'$\tau_{\infty, ens, 2}$ Firing Frequency vs Input')
plt.plot(tauhterm2_evals, tauhterm2_activites)

# # Plot the tuning curves associated with the Na Ch Activation ensemble.
# plt.figure(); plt.xlabel('Input [-]'); plt.ylabel(r'$m_{\infty}$ Firing Frequency [Hz]'); plt.title(r'$m_{\infty}$ Firing Frequency vs Input')
# plt.plot(minf_evals, minf_activites)
#
# # Plot the tuning curves associated with the Na Ch Deactivation ensemble.
# plt.figure(); plt.xlabel('Input [-]'); plt.ylabel(r'$h_{\infty}$ Firing Frequency [Hz]'); plt.title(r'$h_{\infty}$ Firing Frequency vs Input')
# plt.plot(minf_evals, minf_activites)

# Show the network.
gvz_source.view()

# Display the figures.
plt.show()


