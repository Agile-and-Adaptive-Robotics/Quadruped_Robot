
# -------------------------------------------------- IMPORT LIBRARIES --------------------------------------------------

# Import built-in necessary libraries.
import nengo
import nengo_dl
import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf

# ----------------------------------------- SET NETWORK & TRAINING PROPERTIES ------------------------------------------

# Define simulation properties.
dt_sim = 0.001
t_sim_duration = 2*np.pi

# Define training properties.
batch_size_train = 10000
minibatch_size_train = 50
n_train_epochs = 50
learning_rate = 0.001

# Simple function that we will approximate.
def f_approx(x):

    return np.sin(x)


# ------------------------------------------------- BUILD THE NETWORK --------------------------------------------------

tau_synapse = None

# Create the network.
network = nengo.Network()

# Set default network properties.
network.config[nengo.Ensemble].neuron_type = nengo.LIF(amplitude=0.001)
network.config[nengo.Connection].synapse = None

# Create the components of the network.
with network:

    # Create the network nodes & ensembles.
    x_node = nengo.Node(output=lambda x: x, label='x Node')
    x_ens = nengo.Ensemble(n_neurons=20, dimensions=1, radius=1.25*t_sim_duration, seed=0, label='x Ensemble')
    y_node = nengo.Node(output=None, size_in=1)

    # Connect up the network components.
    nengo.Connection(x_node, x_ens, synapse=tau_synapse)
    nengo.Connection(x_ens, y_node, synapse=tau_synapse, function=f_approx)

    # Collect data from the network.
    x_probe = nengo.Probe(x_node)
    y_probe_nofilt = nengo.Probe(y_node)
    # y_probe_filt = nengo.Probe(y_node, synapse=0.01)
    y_probe_filt = nengo.Probe(y_node, synapse=0.05)


# ------------------------------------------- SIMULATE THE UNTRAINED NETWORK -------------------------------------------

# Setup the simulation.
with nengo_dl.Simulator(network=network, dt=dt_sim) as sim:

    # Run the simulation.
    sim.run(t_sim_duration)


# ----------------------------------------- PLOT THE UNTRAINED NETWORK RESULTS -----------------------------------------

# Plot the network input.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel('Network Input [-]'); plt.title('Network Input vs Time')
plt.plot(sim.trange(), sim.data[x_probe], label='x')

# Plot the network output.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel('Network Output [-]'); plt.title('Network Output vs Time (Untrained)')
plt.plot(sim.trange(), sim.data[y_probe_filt], label='y SNN')
plt.plot(sim.trange(), f_approx(sim.trange()), label='y True')
plt.legend()


# ------------------------------------------- GENERATE NETWORK TRAINING DATA -------------------------------------------

# Create the training data inputs.
xs_training_input = np.random.uniform(0, t_sim_duration, size=(batch_size_train, 1, 1))

# Compute the training data outputs.
ys_training_output = f_approx(xs_training_input)

# Training data dictionary.
input_training = {x_node: xs_training_input}
target_training = {y_probe_nofilt: ys_training_output}

# ------------------------------------------------- TRAIN THE NETWORK --------------------------------------------------

with nengo_dl.Simulator(network=network, minibatch_size=minibatch_size_train) as sim:

    # Define the objective function we will use when training our SNN. (Note that the SNN will be converted to an ANN for training.)
    def train_objective(outputs, targets):

        # # Retrieve the symbolic input tensor.
        # inputs = sim.tensor_graph.input_ph[x_node]
        #
        # # Compute the gradient of the network output with respect to the input.
        # dydx = tf.transpose(tf.gradients(outputs, inputs)[0], (2, 0, 1))  # This is no longer None!
        #
        # # Print dydx (for debugging).
        # print('dydx =', dydx)

        # Compute the loss of this output.
        return tf.reduce_mean(tf.square(outputs - targets))     # Standard MSE.  This works fine.
        # return tf.reduce_mean(tf.square(dydx))                    # Example error that uses gradient term.  This yields "TypeError: Second-order gradient for while loops not supported."

    # Train the network.
    # sim.train(data=data_training, optimizer=tf.train.AdamOptimizer(learning_rate=learning_rate), objective={y_probe_nofilt: train_objective}, n_epochs=n_train_epochs)
    # sim.train(data=data_training, optimizer=tf.optimizers.Adam(learning_rate=learning_rate), objective={y_probe_nofilt: train_objective}, n_epochs=n_train_epochs)
    sim.compile(optimizer=tf.optimizers.Adam(learning_rate=learning_rate), loss={y_probe_nofilt: train_objective})
    sim.fit(input_training, target_training, epochs=n_train_epochs)

    # Freeze the parameters.
    sim.freeze_params(network)



# -------------------------------------------- SIMULATE THE TRAINED NETWORK --------------------------------------------

# Setup the simulation.
with nengo_dl.Simulator(network=network, dt=dt_sim) as sim:

    # Run the simulation.
    sim.run(t_sim_duration)


# ------------------------------------------ PLOT THE TRAINED NETWORK RESULTS ------------------------------------------

# Plot the network output.
plt.figure(); plt.xlabel('Time [s]'); plt.ylabel('Network Output [-]'); plt.title('Network Output vs Time (Trained)')
plt.plot(sim.trange(), sim.data[y_probe_filt], label='y SNN')
plt.plot(sim.trange(), f_approx(sim.trange()), label='y True')
plt.legend()

# Display the results.
plt.show()



