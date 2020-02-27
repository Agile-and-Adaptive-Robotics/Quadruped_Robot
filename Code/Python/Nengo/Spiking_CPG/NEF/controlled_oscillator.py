# Harmonic oscillator example
# The frequency of the oscillation can be controlled with an additional input signal to the network
# TODO: I don't really understand this, but it is built!

import matplotlib.pyplot as plt
import numpy as np

from IPython.display import HTML

import nengo
from nengo.processes import Piecewise

# TODO: this can be acquired for $99; maybe we already have something that would serve the same purpose?
# we'd need to make an fpga_config file for it to reference
import nengo_fpga
from nengo_fpga.networks import FpgaPesEnsembleNetwork

from anim_utils import make_anim_controlled_osc

# Choose an FPGA Device
# The device on which the remote FpgaPesEnsembleNetwork will run
board = 'de1' # change to my device name

# Create the remote FPGA neural ensemble using the board, 50 neurons, 2 dimensions, and no learning rate
model = nengo.Network(label="Communication Channel")

with model:
    fpga_ens = FpgaPesEnsembleNetwork(
        board,
        n_neurons=50,
        dimensions=2,
        learning_rate=0
    )
    fpga_ens.ensemble.neuron_type = nengo.SpikingRectifiedLinear() # enables spiking

# Provide input to the ensemble
# Input node that generates a 2-D signal - 1st dim is sine wave, 2nd dim is cosine wave
def input_func(t):
    return [np.sin(t * 2*np.pi), np.cow(t * 2*np.pi)]

with model:
    input_node = nengo.Node(input_func)

with model:
    # Connect the input to the FPGA ensemble
    nengo.Connection(input_node, fpga_ens.input)

# Probe the data
with model:
    # The original input
    input_p = nengo.Probe(input_node, synapse=0.01)

    # Output from FPGA ensemble
    # (filtered with a 10ms post-synaptic filter)
    output_p = nengo.Probe(fpga_ens.output, synapse=0.01)

# Run the model!
with nengo_fpga.Simulator(model) as sim:
    sim.run(2)

# Plot the results!
plt.figure(figsize=(16, 5))
plt.subplot(1, 2, 1)
plt.title("Probed Results (Dimension 1)")
plt.plot(sim.trange(), sim.data[input_p][:, 0])
plt.plot(sim.trange(), sim.data[output_p][:, 0])
plt.ylim(-1.1, 1.1)
plt.legend(("Input", "Output"), loc='upper right')
plt.xlabel("Sim time (s)")

plt.subplot(1, 2, 2)
plt.title("Probed Results (Dimension 2)")
plt.plot(sim.trange(), sim.data[input_p][:, 1])
plt.plot(sim.trange(), sim.data[output_p][:, 1])
plt.ylim(-1.1, 1.1)
plt.legend(("Input", "Output"), loc='upper right')
plt.xlabel("Sim time (s)")
plt.show()
