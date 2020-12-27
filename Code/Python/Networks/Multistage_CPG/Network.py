import numpy as np
from Nprops import Nprops

class Network:
    def __init__(self, neurons, synapses):
        self.num_neurons = len(neurons)
        self.num_synapses = len(synapses)

        ###################################################### 
        # Define neuron properties
        ###################################################### 

        self.Cms =       np.array([x.Cm for x in neurons])
        self.Gms =       np.array([x.Gm for x in neurons])
        self.Ers =       np.array([x.Er for x in neurons])
        self.Ams =       np.array([x.Am for x in neurons])
        self.Sms =       np.array([x.Sm for x in neurons])
        self.Ems =       np.array([x.Em for x in neurons])
        self.Ahs =       np.array([x.Ah for x in neurons])
        self.Shs =       np.array([x.Sh for x in neurons])
        self.Ehs =       np.array([x.Eh for x in neurons])
        self.Enas =      np.array([x.Ena for x in neurons])
        self.tauh_maxs = np.array([x.tauh_max for x in neurons])
        self.Gnas =      np.array([x.Gna for x in neurons])

        ###################################################### 
        # Define Synapse Properties.
        ###################################################### 

        self.Elos =      np.array([x[2].Elo  for x in synapses])
        self.Rs =        np.array([x[2].R  for x in synapses])
        self.Esyns =     np.array([x[2].Esyn for x in synapses])
        self.gsyn_maxs = np.array([x[2].gmax for x in synapses])

        ###################################################### 
        # Define Connection Properties.
        ###################################################### 
        self.pre_V_i = np.array([x[0] for x in synapses])  # indices of presynaptic neurons
        self.post_V_i = np.array([x[1] for x in synapses]) # indices of postsynaptic neurons
        self.post_map = self.PostsynapticMap(synapses)
        
        ###################################################### 
        # Define Applied Current Magnitudes.
        ###################################################### 

        # Note that these are not necessarily constant applied currents.  Here we are only computing the maximum applied current for each neuron, if an applied current will be applied at all.

        # Compute the necessary applied current magnitudes.
        # Define tonic current magnitudes.
        self.Iapps_tonic = np.zeros(self.num_neurons)


    def PostsynapticMap(self, synapses):
        '''
        ij-th entry of the matrix is 1 if neuron j is the postsynaptic neuron for synapse i, 0 otherwise
        '''
        post_map = np.zeros((self.num_synapses, self.num_neurons))
        for i in range(self.num_synapses):
            post_map[i][synapses[i][1]] = 1
        return post_map

    
    def SetSimulationProperties(self, tf, dt, Iapps = None):
        '''
        Can be called multiple times after the object has been constructed
        '''
        # Set the simulation time.
        self.tf = tf         # [s] Simulation Duration.
        self.dt = dt      # [s] Simulation Time Step.

        # Compute the simulation time vector.
        self.ts = np.arange(0, tf+dt, dt)

        # Compute the number of time steps.
        self.num_timesteps = len(self.ts)

        # Set the network initial conditions.
        self.Vs0 = self.Ers
        self.hs0 = Nprops.GetSteadyStateNaActDeactValue(self.Vs0, self.Ahs, self.Shs, self.Ehs)


        # Define the Applied Currents.

        # Create the applied currents to use during simulation.
        self.Iapps = Iapps
        if self.Iapps is None:
            self.Iapps = np.zeros((self.num_timesteps, self.num_neurons))


    def Simulate(self):
        '''
        This function simulates a neural network described by Gms, Cms, Rs, gsyn_maxs, Esyns with an initial condition of U0, h0 for tf seconds with a step size of dt and an applied current of Iapp.

        Inputs:
            Vs0 = num_neurons x 1 vector of initial membrane voltages of each neuron w.r.t their resting potentials.
            hs0 = num_neurons x 1 vector of initial sodium channel deactivation parameters for each neuron.
            Gms = num_neurons x 1 vector of neuron membrane conductances.
            Cms = num_neurons x 1 vector of neuron membrane capacitances.
            Rs = num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
            gsyn_maxs = num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
            Esyns = num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
            Ams = num_neurons x 1 vector of sodium channel activation A parameter values.
            Sms = num_neurons x 1 vector of sodium channel activation S parameter values.
            Ems = num_neurons x 1 vector of sodium channel activation parameter reversal potentials.
            Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
            Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
            Ehs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
            tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
            Gnas = num_neurons x 1 vector of sodium channel conductances for each neuron.
            Enas = num_neurons x 1 vector of sodium channel reversal potentials for each neuron.
            Iapp = num_neurons x num_timesteps vector of applied currents for each neuron.
            tf = Scalar that represents the simulation duration.
            dt = Scalar that represents the simulation time step.

        Outputs:
            ts = 1 x num_timesteps vector of the time associated with each simulation step.
            Vs = num_neurons x num_timesteps matrix of the neuron membrane voltages over time w.r.t. their resting potentials.
            hs = num_neurons x num_timesteps matrix of neuron sodium channel deactivation parameters.
            dVs = num_neurons x num_timesteps matrix of neuron membrane voltage derivatives over time w.r.t their resting potentials.
            dhs = num_neurons x num_timesteps matrix of neuron sodium channel deactivation parameter derivatives.
            Gsyns = num_neurons x num_neurons x num_neurons tensor of synapse conductances over time.  The ijk entry represens the synaptic condutance from neuron j to neuron i at time step k.
            Ileaks = num_neurons x num_timsteps matrix of neuron leak currents over time.
            Isyns = num_neurons x num_timesteps matrix of synaptic currents over time.
            Inas = num_neurons x num_timesteps matrix of sodium channel currents for each neuron.
            Itotals = num_neurons x num_timesteps matrix of total currents for each neuron.
            minfs = num_neurons x num_timesteps matrix of neuron steady state sodium channel activation values.
            hinfs = num_neurons x num_timesteps matrix of neuron steady state sodium channel deactivation values.
            tauhs = num_neurons x num_timesteps matrix of sodium channel deactivation parameter time constants.
        '''
        #import pdb; pdb.set_trace()
        # Ensure that there are the correct number of applied currents.
        if self.Iapps.shape[0] != self.num_timesteps:                  # If the number of Iapps columns is not equal to the number of timesteps...
            # Throw an error.
            raise ValueError('Iapps.shape[0] must equal the number of simulation time steps.\n')

        # Preallocate arrays to store the simulation data.
        self.Vs, self.hs, self.dVs, self.dhs, self.Ileaks, self.Isyns, self.Inas, self.Itotals, self.minfs, self.hinfs, self.tauhs = (np.zeros((self.num_timesteps, self.num_neurons)) for i in range(11)) 

        # Preallocate a multidimensional array to store the synaptic conductances.
        self.Gsyns = np.zeros((self.num_timesteps, self.num_synapses))

        # Set the initial network condition.
        self.Vs[0] = self.Vs0 
        self.hs[0] = self.hs0

        # Simulate the network.
        for k in range(self.num_timesteps - 1):               # Iterate through each timestep...

            # Compute the network state derivatives (as well as other intermediate network values).
            self.dVs[k], self.dhs[k], self.Gsyns[k], self.Ileaks[k], self.Isyns[k], self.Inas[k], self.Itotals[k], self.minfs[k], self.hinfs[k], self.tauhs[k] = self.NetworkStep(self.Vs[k], self.hs[k], self.Iapps[k])

            # Compute the membrane voltages at the next time step.
            self.Vs[k+1] = self.ForwardEulerStep(self.Vs[k], self.dVs[k], self.dt)

            # Compute the sodium channel deactivation parameters at the next time step.
            self.hs[k+1] = self.ForwardEulerStep(self.hs[k], self.dhs[k], self.dt)


        # Advance the loop counter variable to perform one more network step.
        k = k + 1

        # Compute the network state derivatives (as well as other intermediate network values).
        self.dVs[k], self.dhs[k], self.Gsyns[k], self.Ileaks[k], self.Isyns[k], self.Inas[k], self.Itotals[k], self.minfs[k], self.hinfs[k], self.tauhs[k] = self.NetworkStep(self.Vs[k], self.hs[k], self.Iapps[k])

    def NetworkStep(self, Vs, hs, Iapp):
        '''
        This function computes a single step of a neural network without sodium channels.

        Inputs, from the previous network step:
            Vs = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.
            hs = num_neurons x 1 vector of neuron sodium channel deactivation parameters.
            Iapps = num_neurons x 1 vector of applied currents for each neuron

        Outputs:
            dVs = num_neurons x 1 vector of neuron membrane voltage derivatives w.r.t their resting potentials.
            dhs = num_neurons x 1 vector of neuron sodium channel deactivation parameter derivatives.
            Gsyns = num_neurons x num_neurons x 1 matrix of synaptic conductances.  Entry ij represents the synaptic conductance from neuron j to neuron i.
            Ileaks = num_neurons x 1 vector of leak currents for each neuron.
            Isyns = num_neurons x 1 vector of synaptic currents for each neuron.
            Inas = num_neurons x 1 vector of sodium channel currents for each neuron.
            Itotals = num_neurons x 1 vector of total currents for each neuron.
            minfs = num_neurons x 1 vector of neuron steady state sodium channel activation values.
            hinfs = num_neurons x 1 vector of neuron steady state sodium channel deactivation values.
            tauhs = num_neurons x 1 vector of sodium channel deactivation parameter time constants.

        ''' 
        # Compute the leak currents.
        Ileaks = self.GetLeakCurrent(Vs)

        # Compute synaptic currents.
        Isyns, Gsyns = self.GetSynapticCurrents(Vs)

        # Compute the sodium channel currents.
        Inas, minfs, hinfs, tauhs = self.GetNaChCurrents(Vs, hs)

        # Compute the total currents.
        Itotals = Ileaks + Isyns + Inas + Iapp

        # Compute the membrane voltage derivatives.
        dVs = Itotals / self.Cms

        # Compute the sodium channel deactivation parameter derivatives.
        dhs = (hinfs - hs) / tauhs

        return dVs, dhs, Gsyns, Ileaks, Isyns, Inas, Itotals, minfs, hinfs, tauhs

    
    def GetLeakCurrent(self, Vs):
        '''
	This function computes the leak current associated with each neuron in a network.

	Inputs:
	    Vs = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.

	% Outputs:
	    Ileaks = num_neurons x 1 vector of the leak current associated with each neuron in the network.
        '''
        return self.Gms * (self.Ers - Vs)


    def GetSynapticCurrents(self, Vs):
        '''
        This function computes the synaptic current associated with each neuron in a network.

        Inputs:
            Vs = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.

        Outputs:
            Isyns = num_neurons x 1 vector of synaptic currents for each neuron in the network.
            Gsyns = num_neurons x num_neurons matrix of synapse conductances over time.  The ijkentry represens the synaptic condutance from neuron j to neuron i.
        '''

        # Compute the synaptic conductances of each synapse in the network.
        Gsyns = self.GetSynapticConductances(Vs)

        # Compute the synaptic current for each neuron.
        Isyns = np.dot(self.post_map.T, Gsyns * ( self.Esyns - Vs[self.post_V_i] ))

        return Isyns, Gsyns


    def GetSynapticConductances(self, Vs):
        '''
        This function computes the synaptic condutance associated with each synapse in a network.

        Inputs:
            Vs = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.

        Outputs:
            Gsyns = num_neurons x num_neurons matrix of synapse conductances over time.  The ijkentry represens the synaptic condutance from neuron j to neuron i.
        '''

        # Compute the synaptic conductance associated with each synapse in the network.
        Gsyns = self.gsyn_maxs * (np.minimum(np.maximum((Vs[self.pre_V_i] - self.Elos) / self.Rs, 0), 1 ))
        
        return Gsyns


    def GetNaChCurrents(self, Vs, hs):
        '''
        This function computes the sodium channel current for each neuron in a network.

        Inputs:
            Vs = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potential.
            hs = num_neurons x 1 vector of neuron sodium channel deactivation parameters.
        
        Outputs:
            Inas = num_neurons x 1 vector of sodium channel currents for each neuron.
            minfs = num_neurons x 1 vector of neuron steady state sodium channel activation values.
            hinfs = num_neurons x 1 vector of neuron steady state sodium channel deactivation values.
            tauhs = num_neurons x 1 vector of sodium channel deactivation parameter time constants.
        '''

        # Compute the steady state sodium channel activation parameters.
        minfs = Nprops.GetSteadyStateNaActDeactValue(Vs, self.Ams, self.Sms, self.Ems)

        # Compute the steady state sodium channel deactivation parameters.
        hinfs = Nprops.GetSteadyStateNaActDeactValue(Vs, self.Ahs, self.Shs, self.Ehs)

        # Compute the sodium channel deactivation time constants.
        tauhs = Nprops.GetNaDeactTimeConst(Vs, self.tauh_maxs, hinfs, self.Ahs, self.Shs, self.Ehs)

        # Compute the sodium channel currents.
        Inas = self.Gnas * minfs * hs * (self.Enas - Vs)

        return Inas, minfs, hinfs, tauhs


    def ForwardEulerStep(self, U, dU, dt):
        '''
        his function performs a single forward Euler step.
        '''
        # Compute the membrane voltage at the next time step.
        U = U + dt*dU

        return U
