# --------------------------- CPG DYNAMICS ---------------------------

# This script creates a SNN that approximates the dynamics of a two neuron CPG.


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

# --------------------------- DEFINE FUNCTIONS TO APPROXIMATE WHEN CREATING THE NETWORK ---------------------------

# Define a function to compute the leak current.
def leak_current_func(U):

    # Return the leak current.
    return -Gm*U

# Define a function to compute the synaptic conductance.
def synaptic_conductance_func(Upre):

    # Compute the synaptic conductance.
    return gsynmax*np.minimum(np.maximum(Upre/R, 0), 1)

# Define a function to compute the synaptic current.
def synapse_current_func(x):

    # Retrieve the components of the input vector.
    U, Gsi = x

    # Compute the synaptic current.
    return Gsi*(Es_tilde - U)

# Define a function to compute the steady state sodium channel activation parameter intermediate calculation (mterm)
def sodium_channel_activation_intermediate_calc_func(U):

    # Compute the steady state sodium channel activation parameter intermediate calculation (mterm).
    return Am*np.exp(-Sm*(Em_tilde - U))

# Define a function to compute the steady state sodium channel activation parameter (minf).
def sodium_channel_activation_func(mterm):

    # Compute the steady state sodium channel activation parameter (minf).
    return 1/(1 + mterm)

# Define a function to compute the steady state sodium channel deactivation parameter intermediate calculation (hterm)
def sodium_channel_deactivation_intermediate_calc_func(U):

    # Compute the steady state sodium channel deactivation parameter intermediate calculation (hterm).
    return Ah*np.exp(-Sh*(Eh_tilde - U))

# Define a function to compute the steady state sodium channel deactivation parameter (hinf).
def sodium_channel_deactivation_func(hterm):

    # Compute the steady state sodium channel deactivation parameter (hinf).
    return 1/(1 + hterm)

# Define a function to compute the sodium channel deactivation parameter time constant intermediate calculation (tauterm)
def sodium_channel_time_constant_intermediate_calc_func(hterm):

    # Compute the sodium channel deactivation parameter intermediate calculation.
    return np.sqrt(np.maximum(0, hterm))

# Define a function to compute the sodium channel deactivation parameter time constant (tauh)
def sodium_channel_time_constant_func(x):

    # Retrieve the components of the input vector.
    hinf, tauterm = x

    # Compute the sodium channel deactivation parameter time constant.
    return np.maximum(tauhmax*hinf*tauterm, tauhmax/100)

# Define a function to compute the sodium channel deactivation parameter derivative (dh)
def sodium_channel_derivative_func(x):

    # Retrieve the components of the input vector.
    hinf, h, tauh = x

    # Ensure that we do not divide by zero.
    tauh = np.maximum(tauh, tauhmin)

    # Compute the sodium channel deactivation parameter derivative.
    return (hinf - h)/tauh

# Define a function to compute the sodium channel current.
def sodium_channel_current(x):

    # Retrieve the components of the input vector.
    minf, h, U = x

    # Compute the sodium channel current.
    return Gna*minf*h*(Ena_tilde - U)


# --------------------------- SETUP NETWORK PROPERTIES ---------------------------

# Define simulation properties.
dt_sim = 0.0001                                                      # [s] Simulation Step Size.
t_sim_duration = 6                                                 # [s] Total Simulation Duration.
# t_start = 1                                                         # [s] Simulation Start Time.
# t_offset = 0.01                                                     # [s] Offset Time for Inhibition Functions.
t_start = 0                                                         # [s] Simulation Start Time.
t_offset = 0                                                     # [s] Offset Time for Inhibition Functions.

# Define the network neuron quantities.
U_neurons = 5000                                                    # [#] Membrane Voltage w.r.t. Resting Potential Number of Neurons.
Ugate_neurons = 3000                                                # [#] Membrane Voltage w.r.t. Resting Potential Gate Number of Neurons.
gsyn_neurons = 1000                                                 # [#] Synaptic Conductance Number of Neurons.
MUX1_neurons = 2000                                                 # [#] Multiplexer 1 Number of Neurons.
mterm_neurons = 1000                                                # [#] Steady State Sodium Channel Activation Parameter Intermediate Calculation Number of Neurons.
hterm_neurons = 1000                                                # [#] Steady State Sodium Channel Deactivation Parameter Intermediate Calculation Number of Neurons.
minf_neurons = 1000                                                 # [#] Steady State Sodium Channel Activation Parameter Number of Neurons.
hinf_neurons = 1000                                                 # [#] Steady State Sodium Channel Deactivation Parameter Number of Neurons.
tauterm_neurons = 1000                                              # [#] Sodium Channel Deactivation Time Constant Intermediate Calculation Number of Neurons.
h_neurons = 3000                                                    # [#] Sodium Channel Deactivation Parameter Number of Neurons.
hgate_neurons = 3000                                                # [#] Sodium Channel Deactivation Parameter Gate Number of Neurons.
MUX2_neurons = 2000                                                 # [#] Multiplexer 2 Number of Neurons.
tauh_neurons = 1000                                                 # [#] Sodium Channel Deactivation Time Constant Number of Neurons.
MUX3_neurons = 3000                                                 # [#] Multiplexer 3 Number of Neurons.
dh_neurons = 3000                                                   # [#] Sodium Channel Deactivation Parameter Derivative Number of Neurons.
Ileak_neurons = 1000                                                # [#] Leak Current Number of Neurons.
Isyn_neurons = 2000                                                 # [#] Synaptic Current Number of Neurons.
MUX4_neurons = 3000                                                 # [#] Multiplexer 4 Number of Neurons.
Ina_neurons = 2000                                                  # [#] Sodium Channel Current Number of Neurons.
Iapp_neurons = 1000                                                 # [#] Applied Current Number of Neurons.
Itotal_neurons = 1000                                               # [#] Total Current Number of Neurons.
dU_neurons = 3000                                                   # [#] Membrane Voltage w.r.t. Resting Potential Derivative Number of Neurons.

# Define the network dimensions.
U_dims = 1                                                          # [#] Membrane Voltage Number w.r.t. Resting Potentialof Dimensions.
Ugate_dims = U_dims                                                 # [#] Membrane Voltage w.r.t. Resting Potential Gate Number of Dimensions.
gsyn_dims = U_dims                                                  # [S] Synaptic Conductance Number of Dimensions.
MUX1_dims = 2*U_dims                                                # [#] Multiplexer 1 Number of Dimensions.
mterm_dims = U_dims                                                 # [#] Steady State Sodium Channel Activation Parameter Intermediate Calculation Number of Dimensions
hterm_dims = U_dims                                                 # [#] Steady State Sodium Channel Deactivation Parameter Intermediate Calculation Number of Dimensions
minf_dims = mterm_dims                                              # [#] Steady State Sodium Channel Activation Parameter Number of Dimensions.
hinf_dims = hterm_dims                                              # [#] Steady State Sodium Channel Deactivation Parameter Number of Dimensions.
tauterm_dims = hterm_dims                                           # [#] Sodium Channel Deactivation Time Constant Intermediate Calculation Number of Dimensions.
h_dims = hinf_dims                                                  # [#] Sodium Channel Deactivation Parameter Number of Dimensions.
hgate_dims = h_dims                                                 # [#] Sodium Channel Deactivation Parameter Gate Number of Dimensions.
MUX2_dims = hinf_dims + tauterm_dims                                # [#] Multiplexer 2 Number of Dimensions.
tauh_dims = h_dims                                                  # [#] Sodium Channel Deactivation Time Constant Number of Dimensions.
MUX3_dims = hinf_dims + h_dims + tauh_dims                          # [#] Multiplexer 3 Number of Dimensions.
dh_dims = h_dims                                                    # [#] Sodium Channel Deactivation Parameter Derivative Number of Dimensions.
Ileak_dims = U_dims                                                 # [#] Leak Current Number of Dimensions.
Isyn_dims = U_dims                                                  # [#] Synaptic Current Number of Dimensions.
MUX4_dims = minf_dims + h_dims + U_dims                             # [#] Multiplexer 4 Number of Dimensions.
Ina_dims = U_dims                                                   # [#] Sodium Channel Current Number of Dimensions.
Iapp_dims = U_dims                                                  # [#] Applied Current Number of Dimensions.
Itotal_dims = U_dims                                                # [#] Total Current Number of Dimensions.
dU_dims = U_dims                                                    # [#] Membrane Voltage  w.r.t. Resting Potential Number of Dimensions.

# Define the network radii.
U_radius = 2*R                                                                          # [V] Membrane Voltage w.r.t. Resting Potential Radius.
Ugate_radius = U_radius                                                                 # [V] Membrane Voltage w.r.t. Resting Potential Gate Radius.
gsyn_radius = 1.25*gsynmax                                                               # [S] Synaptic Conductance Radius.
MUX1_radius = np.amax([U_radius, gsyn_radius])                                           # [-] Multiplexer 1 Radius.
mterm_radius = sodium_channel_activation_intermediate_calc_func(0)                      # [-] Steady State Sodium Channel Activation Parameter Intermediate Calculation Radius
hterm_radius = sodium_channel_deactivation_intermediate_calc_func(U_radius)             # [-] Steady State Sodium Channel Deactivation Parameter Intermediate Calculation Radius
minf_radius = minf_func(U_radius)                                                       # [-] Steady State Sodium Channel Activation Parameter Radius.
hinf_radius = hinf_func(0)                                                              # [-] Steady State Sodium Channel Deactivation Parameter Radius.
tauterm_radius = np.sqrt(hterm_radius)                                                  # [s] Sodium Channel Deactivation Time Constant Intermediate Calculation Radius.
h_radius = 0.75                                                                         # [-] Sodium Channel Deactivation Parameter Radius.  NOT SURE IF THIS CAN BE SET PROGRAMMICALLY. 0.70 is as low as possible.
hgate_radius = h_radius                                                                 # [-] Sodium Channel Deactivation Parameter Gate Radius.
MUX2_radius = np.amax([hinf_radius, tauterm_radius])                                    # [-] Multiplexer 2 Radius.
tauh_radius = 0.30                                                                      # [s] Sodium Channel Deactivation Time Constant Radius. THIS COULD BE SET PROGRAMMICALLY, BUT THE MAXIMUM DOES NOT OCCUR AT THE END POINTS. 0.15 is as low as possible.
MUX3_radius = np.amax([hinf_radius, h_radius, tauh_radius])                             # [-] Multiplexer 3 Radius.
dh_radius = 3                                                                           # [-] Sodium Channel Deactivation Parameter Derivative Radius. NOT SURE IF THIS CAN BE SET PROGRAMMICALLY.  2.5 is as low as possible.
Ileak_radius = -leak_current_func(U_radius)                                             # [A] Leak Current Radius.
Isyn_radius = np.abs(synapse_current_func([0, gsynmax]))                                # [A] Synaptic Current Radius.
MUX4_radius = np.amax([minf_radius, h_radius, U_radius])                                # [-] Multiplexer 4 Radius.
Ina_radius = sodium_channel_current([minf_radius, h_radius, 0])                         # [A] Sodium Channel Current Radius.
Iapp_radius = 2e-9                                                                         # [A] Applied Current Radius.
Itotal_radius = Ileak_radius + Isyn_radius + Ina_radius                                 # [A] Total Current Radius.
dU_radius = 3                                                                           # [V/s] Membrane Voltage Derivative Radius. NOT SURE IF THIS CAN BE SET PROGRAMMICALLY.  2 is as low as possible.

# Define universal network parameters.
seed = 0                                                            # [-] Seed for Random Number Generation.
# tau_synapse = 0.1                                                   # [s] Post-Synaptic Time Constant.
tau_synapse = 0.001                                                   # [s] Post-Synaptic Time Constant.
tau_probe = 0.1                                                     # [s] Probe Time Constant.


# Define the applied current functions.
Iapp1_func = Piecewise({0: 0, t_start: 1e-9, t_start+tau_synapse: 0})  # [V] System Input Function.
# Iapp1_func = Piecewise({0: 0, t_start: 1e-9, t_start+1: 0})  # [V] System Input Function.
# Iapp1_func = Piecewise({0: 0, t_start: 1e-9})  # [V] System Input Function.
# Iapp1_func = Piecewise({0: 1e-9, t_start: 0})  # [V] System Input Function.
Iapp2_func = lambda x: 0  # [V] System Input Function.

# Define the initial condition function.
U0_func = Piecewise({0: U0, t_start: 0})  # [V] Initial Condition Function for Membrane Voltage w.r.t. Resting Voltage.
h0_func = Piecewise({0: h0, t_start: 0})  # [-] Initial Condition Function for Sodium Channel Deactivation.

# Define an inhibition function for the membrane voltage gate ensemble.
Ugate_inhib_func = Piecewise({0: 1, t_start-t_offset: 0})  # [-] Membrane Voltage Inhibitory Function.

# Define an inhibition function for the sodium channel deactivation parameter.
hgate_inhib_func = Piecewise({0: 1, t_start-t_offset: 0})   # [-] Sodium Channel Deactivation Inhibitory Function.



# --------------------------- BUILD THE NETWORK ---------------------------

# Create the nengo network object.
network = nengo.Network()

# Define the network properties.
LIF_amplitude = 0.001
# network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=LIF_amplitude)  # [-] Sets the neuron model to LIF.
# network.config[nengo.Ensemble].neuron_type = nengo.Direct()  # [-] Sets the neuron model to Direct.

# Build the network.
with network:

    # # -------------------- Create the Network Components --------------------
    #
    # # Create the membrane voltage ensemble and associated network components.
    # U01_node = nengo.Node(output=U0_func, label='U01 Node')
    # U1_ens = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dims, radius=U_radius, seed=seed, label='U1 Ensemble')
    # U1gate_inhib_node = nengo.Node(output=Ugate_inhib_func, label='U1gate Node')
    # U1gate_ens = nengo.Ensemble(n_neurons=Ugate_neurons, dimensions=Ugate_dims, radius=Ugate_radius, seed=seed, label='U1gate Ensemble')
    #
    # U02_node = nengo.Node(output=U0_func, label='U02 Node')
    # U2_ens = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dims, radius=U_radius, seed=seed, label='U2 Ensemble')
    # U2gate_inhib_node = nengo.Node(output=Ugate_inhib_func, label='U2gate Node')
    # U2gate_ens = nengo.Ensemble(n_neurons=Ugate_neurons, dimensions=Ugate_dims, radius=Ugate_radius, seed=seed, label='U2gate Ensemble')
    #
    # # Create the leak current pathway.
    # Ileak1_ens = nengo.Ensemble(n_neurons=Ileak_neurons, dimensions=Ileak_dims, radius=Ileak_radius, seed=seed, label='Ileak1 Ensemble')
    # Ileak2_ens = nengo.Ensemble(n_neurons=Ileak_neurons, dimensions=Ileak_dims, radius=Ileak_radius, seed=seed, label='Ileak2 Ensemble')
    #
    # # Create the synaptic current pathway.
    # gsyn1_ens = nengo.Ensemble(n_neurons=gsyn_neurons, dimensions=gsyn_dims, radius=gsyn_radius, seed=seed, label='gsyn1 Ensemble')
    # MUX11_ens = nengo.Ensemble(n_neurons=MUX1_neurons, dimensions=MUX1_dims, radius=MUX1_radius, seed=seed, label='MUX11 Ensemble')
    # Isyn1_ens = nengo.Ensemble(n_neurons=Isyn_neurons, dimensions=Isyn_dims, radius=Isyn_radius, seed=seed, label='Isyn1 Ensemble')
    #
    # gsyn2_ens = nengo.Ensemble(n_neurons=gsyn_neurons, dimensions=gsyn_dims, radius=gsyn_radius, seed=seed, label='gsyn2 Ensemble')
    # MUX12_ens = nengo.Ensemble(n_neurons=MUX1_neurons, dimensions=MUX1_dims, radius=MUX1_radius, seed=seed, label='MUX12 Ensemble')
    # Isyn2_ens = nengo.Ensemble(n_neurons=Isyn_neurons, dimensions=Isyn_dims, radius=Isyn_radius, seed=seed, label='Isyn2 Ensemble')
    #
    # # # Create the sodium channel deactivation parameter ensemble and associated network components.
    # # mterm1_ens = nengo.Ensemble(n_neurons=mterm_neurons, dimensions=mterm_dims, radius=mterm_radius, seed=seed, label='mterm1 Ensemble')
    # # hterm1_ens = nengo.Ensemble(n_neurons=hterm_neurons, dimensions=hterm_dims, radius=hterm_radius, seed=seed, label='hterm1 Ensemble')
    # # minf1_ens = nengo.Ensemble(n_neurons=minf_neurons, dimensions=minf_dims, radius=minf_radius, seed=seed, label='minf1 Ensemble')
    # # hinf1_ens = nengo.Ensemble(n_neurons=hinf_neurons, dimensions=hinf_dims, radius=hinf_radius, seed=seed, label='hinf1 Ensemble')
    # # tauterm1_ens = nengo.Ensemble(n_neurons=tauterm_neurons, dimensions=tauterm_dims, radius=tauterm_radius, seed=seed, label='tauterm1 Ensemble')
    # # MUX21_ens = nengo.Ensemble(n_neurons=MUX2_neurons, dimensions=MUX2_dims, radius=MUX2_radius, seed=seed, label='MUX21 Ensemble')
    # # tauh1_ens = nengo.Ensemble(n_neurons=tauh_neurons, dimensions=tauh_dims, radius=tauh_radius, seed=seed, label='tauh1 Ensemble')
    # # h1_node = nengo.Node(output=h0_func, label='h1 Node')
    # # h1_ens = nengo.Ensemble(n_neurons=h_neurons, dimensions=h_dims, radius=h_radius, seed=seed, label='h1 Ensemble')
    # # h1gate_inhib_node = nengo.Node(output=hgate_inhib_func, label='h1gate Node')
    # # h1gate_ens = nengo.Ensemble(n_neurons=hgate_neurons, dimensions=hgate_dims, radius=hgate_radius, seed=seed, label='h1gate Ensemble')
    # # MUX31_ens = nengo.Ensemble(n_neurons=MUX3_neurons, dimensions=MUX3_dims, radius=MUX3_radius, seed=seed, label='MUX31 Ensemble')
    # # dh1_ens = nengo.Ensemble(n_neurons=dh_neurons, dimensions=dh_dims, radius=dh_radius, seed=seed, label='dh1 Ensemble')
    # #
    # # mterm2_ens = nengo.Ensemble(n_neurons=mterm_neurons, dimensions=mterm_dims, radius=mterm_radius, seed=seed, label='mterm2 Ensemble')
    # # hterm2_ens = nengo.Ensemble(n_neurons=hterm_neurons, dimensions=hterm_dims, radius=hterm_radius, seed=seed, label='hterm2 Ensemble')
    # # minf2_ens = nengo.Ensemble(n_neurons=minf_neurons, dimensions=minf_dims, radius=minf_radius, seed=seed, label='minf2 Ensemble')
    # # hinf2_ens = nengo.Ensemble(n_neurons=hinf_neurons, dimensions=hinf_dims, radius=hinf_radius, seed=seed, label='hinf2 Ensemble')
    # # tauterm2_ens = nengo.Ensemble(n_neurons=tauterm_neurons, dimensions=tauterm_dims, radius=tauterm_radius, seed=seed, label='tauterm2 Ensemble')
    # # MUX22_ens = nengo.Ensemble(n_neurons=MUX2_neurons, dimensions=MUX2_dims, radius=MUX2_radius, seed=seed, label='MUX22 Ensemble')
    # # tauh2_ens = nengo.Ensemble(n_neurons=tauh_neurons, dimensions=tauh_dims, radius=tauh_radius, seed=seed, label='tauh2 Ensemble')
    # # h2_node = nengo.Node(output=h0_func, label='h2 Node')
    # # h2_ens = nengo.Ensemble(n_neurons=h_neurons, dimensions=h_dims, radius=h_radius, seed=seed, label='h2 Ensemble')
    # # h2gate_inhib_node = nengo.Node(output=hgate_inhib_func, label='h2gate Node')
    # # h2gate_ens = nengo.Ensemble(n_neurons=hgate_neurons, dimensions=hgate_dims, radius=hgate_radius, seed=seed, label='h2gate Ensemble')
    # # MUX32_ens = nengo.Ensemble(n_neurons=MUX3_neurons, dimensions=MUX3_dims, radius=MUX3_radius, seed=seed, label='MUX32 Ensemble')
    # # dh2_ens = nengo.Ensemble(n_neurons=dh_neurons, dimensions=dh_dims, radius=dh_radius, seed=seed, label='dh2 Ensemble')
    # #
    # # # Create the sodium channel current pathway.
    # # MUX41_ens = nengo.Ensemble(n_neurons=MUX4_neurons, dimensions=MUX4_dims, radius=MUX4_radius, seed=seed, label='MUX41 Ensemble')
    # # Ina1_ens = nengo.Ensemble(n_neurons=Ina_neurons, dimensions=Ina_dims, radius=Ina_radius, seed=seed, label='Ina1 Ensemble')
    # #
    # # MUX42_ens = nengo.Ensemble(n_neurons=MUX4_neurons, dimensions=MUX4_dims, radius=MUX4_radius, seed=seed, label='MUX42 Ensemble')
    # # Ina2_ens = nengo.Ensemble(n_neurons=Ina_neurons, dimensions=Ina_dims, radius=Ina_radius, seed=seed, label='Ina2 Ensemble')
    #
    # # Create the applied current pathway.
    # Iapp1_node = nengo.Node(output=Iapp1_func, label='Iapp1 Node')
    # Iapp1_ens = nengo.Ensemble(n_neurons=Iapp_neurons, dimensions=Iapp_dims, radius=Iapp_radius, seed=seed, label='Iapp1 Ensemble')
    #
    # Iapp2_node = nengo.Node(output=Iapp2_func, label='Iapp2 Node')
    # Iapp2_ens = nengo.Ensemble(n_neurons=Iapp_neurons, dimensions=Iapp_dims, radius=Iapp_radius, seed=seed, label='Iapp2 Ensemble')
    #
    # # Create the total current pathway.
    # Itotal1_ens = nengo.Ensemble(n_neurons=Itotal_neurons, dimensions=Itotal_dims, radius=Itotal_radius, seed=seed, label='Itotal1 Ensemble')
    # Itotal2_ens = nengo.Ensemble(n_neurons=Itotal_neurons, dimensions=Itotal_dims, radius=Itotal_radius, seed=seed, label='Itotal2 Ensemble')
    #
    # # Create the membrane voltage derivative pathway.
    # dU1_ens = nengo.Ensemble(n_neurons=dU_neurons, dimensions=dU_dims, radius=dU_radius, seed=seed, label='dU1 Ensemble')
    # dU2_ens = nengo.Ensemble(n_neurons=dU_neurons, dimensions=dU_dims, radius=dU_radius, seed=seed, label='dU2 Ensemble')


    # Create the membrane voltage ensemble and associated network components.
    U01_node = nengo.Node(output=U0_func, label='U01 Node')
    U1_ens = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dims, radius=U_radius, seed=seed, label='U1 Ensemble', neuron_type=nengo.Direct())
    # U1_ens = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dims, radius=U_radius, seed=seed, label='U1 Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))
    U1gate_inhib_node = nengo.Node(output=Ugate_inhib_func, label='U1gate Node')
    U1gate_ens = nengo.Ensemble(n_neurons=Ugate_neurons, dimensions=Ugate_dims, radius=Ugate_radius, seed=seed, label='U1gate Ensemble', neuron_type=nengo.Direct())
    # U1gate_ens = nengo.Ensemble(n_neurons=Ugate_neurons, dimensions=Ugate_dims, radius=Ugate_radius, seed=seed, label='U1gate Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))

    U02_node = nengo.Node(output=U0_func, label='U02 Node')
    U2_ens = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dims, radius=U_radius, seed=seed, label='U2 Ensemble', neuron_type=nengo.Direct())
    # U2_ens = nengo.Ensemble(n_neurons=U_neurons, dimensions=U_dims, radius=U_radius, seed=seed, label='U2 Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))
    U2gate_inhib_node = nengo.Node(output=Ugate_inhib_func, label='U2gate Node')
    U2gate_ens = nengo.Ensemble(n_neurons=Ugate_neurons, dimensions=Ugate_dims, radius=Ugate_radius, seed=seed, label='U2gate Ensemble', neuron_type=nengo.Direct())
    # U2gate_ens = nengo.Ensemble(n_neurons=Ugate_neurons, dimensions=Ugate_dims, radius=Ugate_radius, seed=seed, label='U2gate Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))

    # Create the leak current pathway.
    # Ileak1_ens = nengo.Ensemble(n_neurons=Ileak_neurons, dimensions=Ileak_dims, radius=Ileak_radius, seed=seed, label='Ileak1 Ensemble', neuron_type=nengo.Direct())
    # Ileak2_ens = nengo.Ensemble(n_neurons=Ileak_neurons, dimensions=Ileak_dims, radius=Ileak_radius, seed=seed, label='Ileak2 Ensemble', neuron_type=nengo.Direct())
    Ileak1_ens = nengo.Ensemble(n_neurons=Ileak_neurons, dimensions=Ileak_dims, radius=Ileak_radius, seed=seed, label='Ileak1 Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))
    Ileak2_ens = nengo.Ensemble(n_neurons=Ileak_neurons, dimensions=Ileak_dims, radius=Ileak_radius, seed=seed, label='Ileak2 Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))

    # Create the synaptic current pathway.
    # gsyn1_ens = nengo.Ensemble(n_neurons=gsyn_neurons, dimensions=gsyn_dims, radius=gsyn_radius, seed=seed, label='gsyn1 Ensemble', neuron_type=nengo.Direct())
    gsyn1_ens = nengo.Ensemble(n_neurons=gsyn_neurons, dimensions=gsyn_dims, radius=gsyn_radius, seed=seed, label='gsyn1 Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))
    MUX11_ens = nengo.Ensemble(n_neurons=MUX1_neurons, dimensions=MUX1_dims, radius=MUX1_radius, seed=seed, label='MUX11 Ensemble', neuron_type=nengo.Direct())
    # Isyn1_ens = nengo.Ensemble(n_neurons=Isyn_neurons, dimensions=Isyn_dims, radius=Isyn_radius, seed=seed, label='Isyn1 Ensemble', neuron_type=nengo.Direct())
    Isyn1_ens = nengo.Ensemble(n_neurons=Isyn_neurons, dimensions=Isyn_dims, radius=Isyn_radius, seed=seed, label='Isyn1 Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))

    # gsyn2_ens = nengo.Ensemble(n_neurons=gsyn_neurons, dimensions=gsyn_dims, radius=gsyn_radius, seed=seed, label='gsyn2 Ensemble', neuron_type=nengo.Direct())
    gsyn2_ens = nengo.Ensemble(n_neurons=gsyn_neurons, dimensions=gsyn_dims, radius=gsyn_radius, seed=seed, label='gsyn2 Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))
    MUX12_ens = nengo.Ensemble(n_neurons=MUX1_neurons, dimensions=MUX1_dims, radius=MUX1_radius, seed=seed, label='MUX12 Ensemble', neuron_type=nengo.Direct())
    # Isyn2_ens = nengo.Ensemble(n_neurons=Isyn_neurons, dimensions=Isyn_dims, radius=Isyn_radius, seed=seed, label='Isyn2 Ensemble', neuron_type=nengo.Direct())
    Isyn2_ens = nengo.Ensemble(n_neurons=Isyn_neurons, dimensions=Isyn_dims, radius=Isyn_radius, seed=seed, label='Isyn2 Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))

    # Create the sodium channel deactivation parameter ensemble and associated network components.
    # mterm1_ens = nengo.Ensemble(n_neurons=mterm_neurons, dimensions=mterm_dims, radius=mterm_radius, seed=seed, label='mterm1 Ensemble', neuron_type=nengo.Direct())
    mterm1_ens = nengo.Ensemble(n_neurons=mterm_neurons, dimensions=mterm_dims, radius=mterm_radius, seed=seed, label='mterm1 Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))
    hterm1_ens = nengo.Ensemble(n_neurons=hterm_neurons, dimensions=hterm_dims, radius=hterm_radius, seed=seed, label='hterm1 Ensemble', neuron_type=nengo.Direct())
    # hterm1_ens = nengo.Ensemble(n_neurons=hterm_neurons, dimensions=hterm_dims, radius=hterm_radius, seed=seed, label='hterm1 Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))

    minf1_ens = nengo.Ensemble(n_neurons=minf_neurons, dimensions=minf_dims, radius=minf_radius, seed=seed, label='minf1 Ensemble', neuron_type=nengo.Direct())
    hinf1_ens = nengo.Ensemble(n_neurons=hinf_neurons, dimensions=hinf_dims, radius=hinf_radius, seed=seed, label='hinf1 Ensemble', neuron_type=nengo.Direct())
    tauterm1_ens = nengo.Ensemble(n_neurons=tauterm_neurons, dimensions=tauterm_dims, radius=tauterm_radius, seed=seed, label='tauterm1 Ensemble', neuron_type=nengo.Direct())
    MUX21_ens = nengo.Ensemble(n_neurons=MUX2_neurons, dimensions=MUX2_dims, radius=MUX2_radius, seed=seed, label='MUX21 Ensemble', neuron_type=nengo.Direct())
    tauh1_ens = nengo.Ensemble(n_neurons=tauh_neurons, dimensions=tauh_dims, radius=tauh_radius, seed=seed, label='tauh1 Ensemble', neuron_type=nengo.Direct())
    h1_node = nengo.Node(output=h0_func, label='h1 Node')
    h1_ens = nengo.Ensemble(n_neurons=h_neurons, dimensions=h_dims, radius=h_radius, seed=seed, label='h1 Ensemble', neuron_type=nengo.Direct())
    h1gate_inhib_node = nengo.Node(output=hgate_inhib_func, label='h1gate Node')
    h1gate_ens = nengo.Ensemble(n_neurons=hgate_neurons, dimensions=hgate_dims, radius=hgate_radius, seed=seed, label='h1gate Ensemble', neuron_type=nengo.Direct())
    MUX31_ens = nengo.Ensemble(n_neurons=MUX3_neurons, dimensions=MUX3_dims, radius=MUX3_radius, seed=seed, label='MUX31 Ensemble', neuron_type=nengo.Direct())
    dh1_ens = nengo.Ensemble(n_neurons=dh_neurons, dimensions=dh_dims, radius=dh_radius, seed=seed, label='dh1 Ensemble', neuron_type=nengo.Direct())

    # mterm2_ens = nengo.Ensemble(n_neurons=mterm_neurons, dimensions=mterm_dims, radius=mterm_radius, seed=seed, label='mterm2 Ensemble', neuron_type=nengo.Direct())
    mterm2_ens = nengo.Ensemble(n_neurons=mterm_neurons, dimensions=mterm_dims, radius=mterm_radius, seed=seed, label='mterm2 Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))
    hterm2_ens = nengo.Ensemble(n_neurons=hterm_neurons, dimensions=hterm_dims, radius=hterm_radius, seed=seed, label='hterm2 Ensemble', neuron_type=nengo.Direct())
    # hterm2_ens = nengo.Ensemble(n_neurons=hterm_neurons, dimensions=hterm_dims, radius=hterm_radius, seed=seed, label='hterm2 Ensemble', neuron_type=nengo.LIF(amplitude=LIF_amplitude))

    minf2_ens = nengo.Ensemble(n_neurons=minf_neurons, dimensions=minf_dims, radius=minf_radius, seed=seed, label='minf2 Ensemble', neuron_type=nengo.Direct())
    hinf2_ens = nengo.Ensemble(n_neurons=hinf_neurons, dimensions=hinf_dims, radius=hinf_radius, seed=seed, label='hinf2 Ensemble', neuron_type=nengo.Direct())
    tauterm2_ens = nengo.Ensemble(n_neurons=tauterm_neurons, dimensions=tauterm_dims, radius=tauterm_radius, seed=seed, label='tauterm2 Ensemble', neuron_type=nengo.Direct())
    MUX22_ens = nengo.Ensemble(n_neurons=MUX2_neurons, dimensions=MUX2_dims, radius=MUX2_radius, seed=seed, label='MUX22 Ensemble', neuron_type=nengo.Direct())
    tauh2_ens = nengo.Ensemble(n_neurons=tauh_neurons, dimensions=tauh_dims, radius=tauh_radius, seed=seed, label='tauh2 Ensemble', neuron_type=nengo.Direct())
    h2_node = nengo.Node(output=h0_func, label='h2 Node')
    h2_ens = nengo.Ensemble(n_neurons=h_neurons, dimensions=h_dims, radius=h_radius, seed=seed, label='h2 Ensemble', neuron_type=nengo.Direct())
    h2gate_inhib_node = nengo.Node(output=hgate_inhib_func, label='h2gate Node')
    h2gate_ens = nengo.Ensemble(n_neurons=hgate_neurons, dimensions=hgate_dims, radius=hgate_radius, seed=seed, label='h2gate Ensemble', neuron_type=nengo.Direct())
    MUX32_ens = nengo.Ensemble(n_neurons=MUX3_neurons, dimensions=MUX3_dims, radius=MUX3_radius, seed=seed, label='MUX32 Ensemble', neuron_type=nengo.Direct())
    dh2_ens = nengo.Ensemble(n_neurons=dh_neurons, dimensions=dh_dims, radius=dh_radius, seed=seed, label='dh2 Ensemble', neuron_type=nengo.Direct())

    # Create the sodium channel current pathway.
    MUX41_ens = nengo.Ensemble(n_neurons=MUX4_neurons, dimensions=MUX4_dims, radius=MUX4_radius, seed=seed, label='MUX41 Ensemble', neuron_type=nengo.Direct())
    Ina1_ens = nengo.Ensemble(n_neurons=Ina_neurons, dimensions=Ina_dims, radius=Ina_radius, seed=seed, label='Ina1 Ensemble', neuron_type=nengo.Direct())

    MUX42_ens = nengo.Ensemble(n_neurons=MUX4_neurons, dimensions=MUX4_dims, radius=MUX4_radius, seed=seed, label='MUX42 Ensemble', neuron_type=nengo.Direct())
    Ina2_ens = nengo.Ensemble(n_neurons=Ina_neurons, dimensions=Ina_dims, radius=Ina_radius, seed=seed, label='Ina2 Ensemble', neuron_type=nengo.Direct())

    # Create the applied current pathway.
    Iapp1_node = nengo.Node(output=Iapp1_func, label='Iapp1 Node')
    Iapp1_ens = nengo.Ensemble(n_neurons=Iapp_neurons, dimensions=Iapp_dims, radius=Iapp_radius, seed=seed, label='Iapp1 Ensemble', neuron_type=nengo.Direct())

    Iapp2_node = nengo.Node(output=Iapp2_func, label='Iapp2 Node')
    Iapp2_ens = nengo.Ensemble(n_neurons=Iapp_neurons, dimensions=Iapp_dims, radius=Iapp_radius, seed=seed, label='Iapp2 Ensemble', neuron_type=nengo.Direct())

    # Create the total current pathway.
    Itotal1_ens = nengo.Ensemble(n_neurons=Itotal_neurons, dimensions=Itotal_dims, radius=Itotal_radius, seed=seed, label='Itotal1 Ensemble', neuron_type=nengo.Direct())
    Itotal2_ens = nengo.Ensemble(n_neurons=Itotal_neurons, dimensions=Itotal_dims, radius=Itotal_radius, seed=seed, label='Itotal2 Ensemble', neuron_type=nengo.Direct())

    # Create the membrane voltage derivative pathway.
    dU1_ens = nengo.Ensemble(n_neurons=dU_neurons, dimensions=dU_dims, radius=dU_radius, seed=seed, label='dU1 Ensemble', neuron_type=nengo.Direct())
    dU2_ens = nengo.Ensemble(n_neurons=dU_neurons, dimensions=dU_dims, radius=dU_radius, seed=seed, label='dU2 Ensemble', neuron_type=nengo.Direct())

    # -------------------- Connect the Network Components --------------------

    # Connect the membrane voltage and associated network components.
    nengo.Connection(U01_node, U1_ens, synapse=tau_synapse)
    nengo.Connection(U1_ens, U1gate_ens, synapse=tau_synapse)
    # nengo.Connection(U1gate_inhib_node, U1gate_ens.neurons, transform=[[-2.5]]*Ugate_neurons)
    nengo.Connection(U1gate_ens, U1_ens, synapse=tau_synapse)

    nengo.Connection(U02_node, U2_ens, synapse=tau_synapse)
    nengo.Connection(U2_ens, U2gate_ens, synapse=tau_synapse)
    # nengo.Connection(U2gate_inhib_node, U2gate_ens.neurons, transform=[[-2.5]]*Ugate_neurons)
    nengo.Connection(U2gate_ens, U2_ens, synapse=tau_synapse)

    # Connect the components of the leak current pathway.
    nengo.Connection(U1_ens, Ileak1_ens, synapse=tau_synapse, function=leak_current_func)
    nengo.Connection(U2_ens, Ileak2_ens, synapse=tau_synapse, function=leak_current_func)

    # Create the presynaptic current pathway.
    nengo.Connection(U2_ens, gsyn1_ens, synapse=tau_synapse, function=synaptic_conductance_func)
    nengo.Connection(U1_ens, MUX11_ens[0], synapse=tau_synapse)
    nengo.Connection(gsyn1_ens, MUX11_ens[1], synapse=tau_synapse)
    nengo.Connection(MUX11_ens, Isyn1_ens, synapse=tau_synapse, function=synapse_current_func)

    nengo.Connection(U1_ens, gsyn2_ens, synapse=tau_synapse, function=synaptic_conductance_func)
    nengo.Connection(U2_ens, MUX12_ens[0], synapse=tau_synapse)
    nengo.Connection(gsyn2_ens, MUX12_ens[1], synapse=tau_synapse)
    nengo.Connection(MUX12_ens, Isyn2_ens, synapse=tau_synapse, function=synapse_current_func)

    # Connect the sodium channel deactivation parameter ensemble and associated network components.
    nengo.Connection(h1_ens, h1gate_ens, synapse=tau_synapse)
    # nengo.Connection(h1gate_inhib_node, h1gate_ens.neurons, transform=[[-2.5]]*hgate_neurons)
    nengo.Connection(h1gate_ens, h1_ens, synapse=tau_synapse)
    nengo.Connection(U1_ens, mterm1_ens, synapse=tau_synapse, function=sodium_channel_activation_intermediate_calc_func)
    nengo.Connection(U1_ens, hterm1_ens, synapse=tau_synapse, function=sodium_channel_deactivation_intermediate_calc_func)
    nengo.Connection(mterm1_ens, minf1_ens, synapse=tau_synapse, function=sodium_channel_activation_func)
    nengo.Connection(hterm1_ens, hinf1_ens, synapse=tau_synapse, function=sodium_channel_deactivation_func)
    nengo.Connection(hterm1_ens, tauterm1_ens, synapse=tau_synapse, function=sodium_channel_time_constant_intermediate_calc_func)
    nengo.Connection(hinf1_ens, MUX21_ens[0], synapse=tau_synapse)
    nengo.Connection(tauterm1_ens, MUX21_ens[1], synapse=tau_synapse)
    nengo.Connection(MUX21_ens, tauh1_ens, synapse=tau_synapse, function=sodium_channel_time_constant_func)
    nengo.Connection(hinf1_ens, MUX31_ens[0], synapse=tau_synapse)
    nengo.Connection(h1_node, h1_ens, synapse=tau_synapse)
    nengo.Connection(h1_ens, MUX31_ens[1], synapse=tau_synapse)
    nengo.Connection(tauh1_ens, MUX31_ens[2], synapse=tau_synapse)
    nengo.Connection(MUX31_ens, dh1_ens, synapse=tau_synapse, function=sodium_channel_derivative_func)
    nengo.Connection(dh1_ens, h1_ens, synapse=tau_synapse, transform=tau_synapse)

    nengo.Connection(h2_ens, h2gate_ens, synapse=tau_synapse)
    # nengo.Connection(h2gate_inhib_node, h2gate_ens.neurons, transform=[[-2.5]]*hgate_neurons)
    nengo.Connection(h2gate_ens, h2_ens, synapse=tau_synapse)
    nengo.Connection(U2_ens, mterm2_ens, synapse=tau_synapse, function=sodium_channel_activation_intermediate_calc_func)
    nengo.Connection(U2_ens, hterm2_ens, synapse=tau_synapse, function=sodium_channel_deactivation_intermediate_calc_func)
    nengo.Connection(mterm2_ens, minf2_ens, synapse=tau_synapse, function=sodium_channel_activation_func)
    nengo.Connection(hterm2_ens, hinf2_ens, synapse=tau_synapse, function=sodium_channel_deactivation_func)
    nengo.Connection(hterm2_ens, tauterm2_ens, synapse=tau_synapse, function=sodium_channel_time_constant_intermediate_calc_func)
    nengo.Connection(hinf2_ens, MUX22_ens[0], synapse=tau_synapse)
    nengo.Connection(tauterm2_ens, MUX22_ens[1], synapse=tau_synapse)
    nengo.Connection(MUX22_ens, tauh2_ens, synapse=tau_synapse, function=sodium_channel_time_constant_func)
    nengo.Connection(hinf2_ens, MUX32_ens[0], synapse=tau_synapse)
    nengo.Connection(h2_node, h2_ens, synapse=tau_synapse)
    nengo.Connection(h2_ens, MUX32_ens[1], synapse=tau_synapse)
    nengo.Connection(tauh2_ens, MUX32_ens[2], synapse=tau_synapse)
    nengo.Connection(MUX32_ens, dh2_ens, synapse=tau_synapse, function=sodium_channel_derivative_func)
    nengo.Connection(dh2_ens, h2_ens, synapse=tau_synapse, transform=tau_synapse)

    # Connect the sodium channel current pathway.
    nengo.Connection(minf1_ens, MUX41_ens[0], synapse=tau_synapse)
    nengo.Connection(h1_ens, MUX41_ens[1], synapse=tau_synapse)
    nengo.Connection(U1_ens, MUX41_ens[2], synapse=tau_synapse)
    nengo.Connection(MUX41_ens, Ina1_ens, synapse=tau_synapse, function=sodium_channel_current)

    nengo.Connection(minf2_ens, MUX42_ens[0], synapse=tau_synapse)
    nengo.Connection(h2_ens, MUX42_ens[1], synapse=tau_synapse)
    nengo.Connection(U2_ens, MUX42_ens[2], synapse=tau_synapse)
    nengo.Connection(MUX42_ens, Ina2_ens, synapse=tau_synapse, function=sodium_channel_current)

    # Connect the applied current pathway.
    nengo.Connection(Iapp1_node, Iapp1_ens, synapse=tau_synapse)
    nengo.Connection(Iapp2_node, Iapp2_ens, synapse=tau_synapse)

    # Connect the total current pathway.
    nengo.Connection(Ileak1_ens, Itotal1_ens, synapse=tau_synapse)
    nengo.Connection(Isyn1_ens, Itotal1_ens, synapse=tau_synapse)
    nengo.Connection(Ina1_ens, Itotal1_ens, synapse=tau_synapse)
    nengo.Connection(Iapp1_ens, Itotal1_ens, synapse=tau_synapse)

    nengo.Connection(Ileak2_ens, Itotal2_ens, synapse=tau_synapse)
    nengo.Connection(Isyn2_ens, Itotal2_ens, synapse=tau_synapse)
    nengo.Connection(Ina2_ens, Itotal2_ens, synapse=tau_synapse)
    nengo.Connection(Iapp2_ens, Itotal2_ens, synapse=tau_synapse)

    # Connect the membrane voltage derivative pathway.
    nengo.Connection(Itotal1_ens, dU1_ens, synapse=tau_synapse, transform=1/Cm)
    nengo.Connection(Itotal2_ens, dU2_ens, synapse=tau_synapse, transform=1/Cm)
    nengo.Connection(dU1_ens, U1_ens, synapse=tau_synapse, transform=tau_synapse)
    nengo.Connection(dU2_ens, U2_ens, synapse=tau_synapse, transform=tau_synapse)


    # -------------------- Collect Data From the Network --------------------

    # Collect data from the membrane voltage ensemble and associated components.
    U1_probe = nengo.Probe(U1_ens, synapse=tau_probe)
    U1gate_probe = nengo.Probe(U1gate_ens, synapse=tau_probe)

    U2_probe = nengo.Probe(U2_ens, synapse=tau_probe)
    U2gate_probe = nengo.Probe(U2gate_ens, synapse=tau_probe)

    # Collect data from the leak current pathway.
    Ileak1_probe = nengo.Probe(Ileak1_ens, synapse=tau_probe)
    Ileak2_probe = nengo.Probe(Ileak2_ens, synapse=tau_probe)

    # Collect data from the presynaptic current pathway.
    gsyn1_probe = nengo.Probe(gsyn1_ens, synapse=tau_probe)
    Isyn1_probe = nengo.Probe(Isyn1_ens, synapse=tau_probe)

    gsyn2_probe = nengo.Probe(gsyn2_ens, synapse=tau_probe)
    Isyn2_probe = nengo.Probe(Isyn2_ens, synapse=tau_probe)

    # Collect data from the sodium channel deactivation parameter ensemble and associated network components.
    mterm1_probe = nengo.Probe(mterm1_ens, synapse=tau_probe)
    hterm1_probe = nengo.Probe(hterm1_ens, synapse=tau_probe)
    minf1_probe = nengo.Probe(minf1_ens, synapse=tau_probe)
    hinf1_probe = nengo.Probe(hinf1_ens, synapse=tau_probe)
    tauterm1_probe = nengo.Probe(tauterm1_ens, synapse=tau_probe)
    tauh1_probe = nengo.Probe(tauh1_ens, synapse=tau_probe)
    h1_probe = nengo.Probe(h1_ens, synapse=tau_probe)
    h1gate_probe = nengo.Probe(h1gate_ens, synapse=tau_probe)
    dh1_probe = nengo.Probe(dh1_ens, synapse=tau_probe)

    mterm2_probe = nengo.Probe(mterm2_ens, synapse=tau_probe)
    hterm2_probe = nengo.Probe(hterm2_ens, synapse=tau_probe)
    minf2_probe = nengo.Probe(minf2_ens, synapse=tau_probe)
    hinf2_probe = nengo.Probe(hinf2_ens, synapse=tau_probe)
    tauterm2_probe = nengo.Probe(tauterm2_ens, synapse=tau_probe)
    tauh2_probe = nengo.Probe(tauh2_ens, synapse=tau_probe)
    h2_probe = nengo.Probe(h2_ens, synapse=tau_probe)
    hgate2_probe = nengo.Probe(h2gate_ens, synapse=tau_probe)
    dh2_probe = nengo.Probe(dh2_ens, synapse=tau_probe)

    # Collect data from the sodium channel current pathway.
    Ina1_probe = nengo.Probe(Ina1_ens, synapse=tau_probe)
    Ina2_probe = nengo.Probe(Ina2_ens, synapse=tau_probe)

    # Collect data from the applied current pathway.
    Iapp1_probe = nengo.Probe(Iapp1_ens, synapse=tau_probe)
    Iapp2_probe = nengo.Probe(Iapp2_ens, synapse=tau_probe)

    # Collect data from the total current pathway.
    Itotal1_probe = nengo.Probe(Itotal1_ens, synapse=tau_probe)
    Itotal2_probe = nengo.Probe(Itotal2_ens, synapse=tau_probe)

    # Collect data from the membrane voltage derivative pathway.
    dU1_probe = nengo.Probe(dU1_ens, synapse=tau_probe)
    dU2_probe = nengo.Probe(dU2_ens, synapse=tau_probe)

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

# Plot the network state space space trajectory.
plt.figure(); plt.xlabel(r'Membrane Voltage w.r.t. Resting Potential, $U$ [V]'); plt.ylabel(r'Na Ch. Deactivation, $h$ [-]'); plt.title(r'Na Ch. Deactivation, $h$ vs Membrane Voltage w.r.t. Resting Potential, $U$')
plt.plot(sim.data[U1_probe], sim.data[h1_probe], label=r'$Neuron 1$')
plt.plot(sim.data[U2_probe], sim.data[h2_probe], label=r'$Neuron 2$')

# Plot the network states over time.
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel('Time [s]'); axs[0].set_ylabel('Membrane Voltage w.r.t. Resting Voltage, $U$ [V]'); axs[0].set_title(r'Membrane Voltage w.r.t. Resting Voltage, $U$ vs Time')
axs[0].plot(sim.trange(), sim.data[U1_probe], label=r'$U_1$')
axs[0].plot(sim.trange(), sim.data[U2_probe], label=r'$U_2$')
axs[0].legend()
axs[1].set_xlabel('Time [s]'); axs[1].set_ylabel('Na Ch. Deactivation Parameter, $h$ [-]'); axs[1].set_title(r'Na Ch. Deactivation Parameter, $h$ vs Time')
axs[1].plot(sim.trange(), sim.data[h1_probe], label=r'$h_1$')
axs[1].plot(sim.trange(), sim.data[h2_probe], label=r'$h_2$')
axs[1].legend()

# Plot the network state derivatives over time.
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel('Time [s]'); axs[0].set_ylabel('Membrane Voltage Derivative w.r.t. Resting Voltage, $\dot{U}$ [V/s]'); axs[0].set_title(r'Membrane Voltage Derivative w.r.t. Resting Voltage, $\dot{U}$ vs Time')
axs[0].plot(sim.trange(), sim.data[dU1_probe], label=r'$\dot{U}_1$')
axs[0].plot(sim.trange(), sim.data[dU2_probe], label=r'$\dot{U}_2$')
axs[0].legend()
axs[1].set_xlabel('Time [s]'); axs[1].set_ylabel('Na Ch. Deactivation Parameter Derivative, $\dot{h}$ [-]'); axs[1].set_title(r'Na Ch. Deactivation Parameter Derivative, $\dot{h}$ vs Time')
axs[1].plot(sim.trange(), sim.data[dh1_probe], label=r'$\dot{h}_1$')
axs[1].plot(sim.trange(), sim.data[dh2_probe], label=r'$\dot{h}_2$')
axs[1].legend()

# Plot the network state gates over time.
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel('Time [s]'); axs[0].set_ylabel('Membrane Voltage Gate w.r.t. Resting Voltage, $U_{gate}$ [V]'); axs[0].set_title(r'Membrane Voltage Gate w.r.t. Resting Voltage, $U_{gate}$ vs Time')
axs[0].plot(sim.trange(), sim.data[U1_probe], label=r'$U_{gate,1}$')
axs[0].plot(sim.trange(), sim.data[U2_probe], label=r'$U_{gate,2}$')
axs[0].legend()
axs[1].set_xlabel('Time [s]'); axs[1].set_ylabel('Na Ch. Deactivation Parameter Gate, $h_{gate}$ [-]'); axs[1].set_title(r'Na Ch. Deactivation Parameter Gate, $h_{gate}$ vs Time')
axs[1].plot(sim.trange(), sim.data[h1_probe], label=r'$h_{gate,1}$')
axs[1].plot(sim.trange(), sim.data[h2_probe], label=r'$h_{gate,2}$')
axs[1].legend()

# Plot the network currents over time.
fig, axs = plt.subplots(5, 1)
axs[0].set_xlabel('Time [s]'); axs[0].set_ylabel('Leak Current, $I_{leak}$ [A]'); axs[0].set_title(r'Leak Current, $I_{leak}$ vs Time')
axs[0].plot(sim.trange(), sim.data[Ileak1_probe], label=r'$I_{leak,1}$')
axs[0].plot(sim.trange(), sim.data[Ileak2_probe], label=r'$I_{leak,2}$')
axs[0].legend()
axs[1].set_xlabel('Time [s]'); axs[1].set_ylabel('Synaptic Current, $I_{syn}$ [A]'); axs[1].set_title(r'Synaptic Current, $I_{syn}$ vs Time')
axs[1].plot(sim.trange(), sim.data[Isyn1_probe], label=r'$I_{syn,1}$')
axs[1].plot(sim.trange(), sim.data[Isyn2_probe], label=r'$I_{syn,2}$')
axs[1].legend()
axs[2].set_xlabel('Time [s]'); axs[2].set_ylabel('Na Ch. Current, $I_{Na}$ [A]'); axs[2].set_title(r'Na Ch. Current, $I_{Na}$ vs Time')
axs[2].plot(sim.trange(), sim.data[Ina1_probe], label=r'$I_{Na,1}$')
axs[2].plot(sim.trange(), sim.data[Ina2_probe], label=r'$I_{Na,2}$')
axs[2].legend()
axs[3].set_xlabel('Time [s]'); axs[3].set_ylabel('Applied Current, $I_{app}$ [A]'); axs[3].set_title(r'Applied Current, $I_{app}$ vs Time')
axs[3].plot(sim.trange(), sim.data[Iapp1_probe], label=r'$I_{app,1}$')
axs[3].plot(sim.trange(), sim.data[Iapp2_probe], label=r'$I_{app,2}$')
axs[3].legend()
axs[4].set_xlabel('Time [s]'); axs[4].set_ylabel('Total Current, $I_{total}$ [A]'); axs[4].set_title(r'Total Current, $I_{total}$ vs Time')
axs[4].plot(sim.trange(), sim.data[Itotal1_probe], label=r'$I_{total,1}$')
axs[4].plot(sim.trange(), sim.data[Itotal2_probe], label=r'$I_{total,2}$')
axs[4].legend()

# Plot the steady state sodium channel activation and deactivation parameter intermediate calculations.
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel('Time [s]'); axs[0].set_ylabel('Steady State Na Ch. Activation Intermediate, $m_{\infty,term}$ [-]'); axs[0].set_title(r'Steady State Na Ch. Activation Intermediate, $m_{term}$ vs Time')
axs[0].plot(sim.trange(), sim.data[mterm1_probe], label=r'$m_{\infty,term,1}$')
axs[0].plot(sim.trange(), sim.data[mterm2_probe], label=r'$m_{\infty,term,2}$')
axs[0].legend()
axs[1].set_xlabel('Time [s]'); axs[1].set_ylabel('Steady State Na Ch. Deactivation Intermediate, $h_{\infty,term}$ [-]'); axs[1].set_title(r'Steady State Na Ch. Deactivation Intermediate, $h_{term}$ vs Time')
axs[1].plot(sim.trange(), sim.data[hterm1_probe], label=r'$h_{\infty,term,1}$')
axs[1].plot(sim.trange(), sim.data[hterm2_probe], label=r'$h_{\infty,term,2}$')
axs[1].legend()

# Plot the steady state sodium channel activation and deactivation parameters.
fig, axs = plt.subplots(2, 1)
axs[0].set_xlabel('Time [s]'); axs[0].set_ylabel('Steady State Na Ch. Activation, $m_{\infty}$ [-]'); axs[0].set_title(r'Steady State Na Ch. Activation, $m_{\infty}$ vs Time')
axs[0].plot(sim.trange(), sim.data[minf1_probe], label=r'$m_{\infty,1}$')
axs[0].plot(sim.trange(), sim.data[minf2_probe], label=r'$m_{\infty,2}$')
axs[0].legend()
axs[1].set_xlabel('Time [s]'); axs[1].set_ylabel('Steady State Na Ch. Deactivation, $h_{\infty}$ [-]'); axs[1].set_title(r'Steady State Na Ch. Deactivation, $h_{\infty}$ vs Time')
axs[1].plot(sim.trange(), sim.data[hinf1_probe], label=r'$h_{\infty,1}$')
axs[1].plot(sim.trange(), sim.data[hinf2_probe], label=r'$h_{\infty,2}$')
axs[1].legend()

# Plot the sodium channel time constant.
plt.figure(); plt.xlabel(r'Time, $t$ [s]'); plt.ylabel(r'Na Ch. Time Constant Intermediate, $\tau_{h,term}$ [s]'); plt.title(r'Na Ch. Time Constant Intermediate, $\tau_{h,term}$ vs Time, $t$')
plt.plot(sim.trange(), sim.data[tauterm1_probe], label=r'$\tau_{h,term,1}$')
plt.plot(sim.trange(), sim.data[tauterm2_probe], label=r'$\tau_{h,term,2}$')

# Plot the sodium channel time constant.
plt.figure(); plt.xlabel(r'Time, $t$ [s]'); plt.ylabel(r'Na Ch. Time Constant, $\tau_{h}$ [s]'); plt.title(r'Na Ch. Time Constant, $\tau_{h}$ vs Time, $t$')
plt.plot(sim.trange(), sim.data[tauh1_probe], label=r'$\tau_{h,1}$')
plt.plot(sim.trange(), sim.data[tauh2_probe], label=r'$\tau_{h,2}$')

# Plot the synaptic conductances.
plt.figure(); plt.xlabel(r'Time, $t$ [s]'); plt.ylabel(r'Synaptic Conductance, $g_{syn}$ [S]'); plt.title(r'Synaptic Conductance, $g_{syn}$ vs Time, $t$')
plt.plot(sim.trange(), sim.data[gsyn1_probe], label=r'$g_{syn,1}$')
plt.plot(sim.trange(), sim.data[gsyn2_probe], label=r'$g_{syn,2}$')


# Show the network.
gvz_source.view()

# Display the figures.
plt.show()
