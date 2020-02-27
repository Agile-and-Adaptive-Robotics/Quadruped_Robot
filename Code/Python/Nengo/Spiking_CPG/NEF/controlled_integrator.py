# Controlled integrator is a circuit that acts on two signals
# 1. Input - the signal being integrated
# 2. Control - the control signal to the integrator

# The state of the controlled integrator can be directly manipulated by the control signal.

import matplotlib.pyplot as plt
import numpy as np

import nengo
from nengo.processes import Piecewise

# Create the network
model = nengo.Network(label='Controlled Integrator')
with model:
    #population 225 LIF neurons which represent a 2D signal with larger radius for large inputs
    A = nengo.Ensemble(225, dimensions=2, radius=1.5)

# Define the input signal to integrate
# It'll be a step function
with model:
    # Create a piecewise step function for input
    # This input_func function will be used later
    input_func = Piecewise({
        0: 0,
        0.2: 5,
        0.3: 0,
        0.44: -10,
        0.54: 0,
        0.8: 5,
        0.9: 0
    })

with model:
    #Define an input signal within our model
    inp = nengo.Node(input_func)

    # Connect the Input signal to ensemble A
    # using the transform argument
    tau = 0.1
    nengo.Connection(inp, A, transform=[[tau], [0]], synapse=tau)

# Define the control signal to control how the integrator behaves
# Initiated to 1 so it's an optimal integrator, then
# halfway through simulation, change it to 0.5 so it acts as leaky!

with model:
    #Another piecewise step that changes halway through the run
    control_func = Piecewise({0:1, 0.6: 0.5})

with model:
    control = nengo.Node(output=control_func)

    # Connect to the second dimension of the neural pop
    nengo.Connection(control, A[1], synapse=0.005)

# Define the integrator dynamics
# Set up the integrator by connecting population A to itself
# Tao affects rate and accuracy of integration

with model:
    # Creates recurrent connection that takes the product
    # of both dimensions in A (value times control)
    # adds this back into the first dimension of A using a transform
    nengo.Connection(
        A, A[0], # transform converts func output to new state input
        function=lambda x: x[0] * x[1], # function is first applied to A
        synapse=tau
    )
    # Record both dimensions of A
    A_probe = nengo.Probe(A, 'decoded_output', synapse=0.01)

with nengo.Simulator(model) as sim:
    sim.run(1.4)

t = sim.trange()
dt = t[1] - t[0]
input_sig = input_func.run(t[-1], dt=dt)
control_sig = control_func.run(t[-1], dt=dt)
ref = dt * np.cumsum(input_sig)

plt.figure(figsize=(6, 8))
plt.subplot(2, 1, 1)
plt.plot(t, input_sig, label='Input')
plt.xlim(right=t[-1])
plt.ylim(-11, 11)
plt.ylabel('Input')
plt.legend(loc="lower left", frameon=False)

plt.subplot(2, 1, 2)
plt.plot(t, ref, 'k--', label='Exact')
plt.plot(t, sim.data[A_probe][:, 0], label='A (value)')
plt.plot(t, sim.data[A_probe][:, 1], label='A (control)')
plt.xlim(right=t[-1])
plt.ylim(-1.1, 1.1)
plt.xlabel('Time (s)')
plt.ylabel('x(t)')
plt.legend(loc="lower left", frameon=False)
plt.show()