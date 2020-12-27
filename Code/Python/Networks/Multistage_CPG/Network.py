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
        Used to add synaptic currents based on which neurons connect to which.
        The ij-th entry of the matrix is 1 if neuron j is the postsynaptic neuron for synapse i, 0 otherwise
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
        This function simulates a neural network described by Gms, Cms, Rs, gsyn_maxs, Esyns with an initial condition of V0, h0 for tf seconds with a step size of dt and an applied current of Iapp.

        Inputs:
            Vs0  = 1 x num_neurons vector of initial membrane voltages of each neuron
            hs0  = 1 x num_neurons vector of initial sodium channel deactivation parameters for each neuron.
            Gms  = 1 x num_neurons vector of neuron membrane conductances.
            Cms  = 1 x num_neurons vector of neuron membrane capacitances.
            Rs   = 1 x num_synapses vector of synapse voltage ranges.
            gsyn_maxs
                 = 1 x num_synapses vector of maximum synaptic conductances.
            Esyns
                 = 1 x num_synapses vector of synaptic reversal potentials.
            Ams  = 1 x num_neurons vector of sodium channel activation A parameter values.
            Sms  = 1 x num_neurons vector of sodium channel activation S parameter values.
            Ems  = 1 x num_neurons vector of sodium channel activation parameter reversal potentials.
            Ahs  = 1 x num_neurons vector of sodium channel deactivation A parameter values.
            Shs  = 1 x num_neurons vector of sodium channel deactivation S parameter values.
            Ehs  = 1 x num_neurons vector of sodium channel deactivation parameter reversal potentials.
            tauh_maxs
                 = 1 x num_neurons vector of maximum sodium channel deactivation parameter time constants.
            Gnas = 1 x num_neurons vector of sodium channel conductances for each neuron.
            Enas = 1 x num_neurons vector of sodium channel reversal potentials for each neuron.
            Iapp = num_timesteps x num_neurons matrix of applied currents for each neuron.
            tf   = Scalar that represents the simulation duration.
            dt   = Scalar that represents the simulation time step.

        Outputs:
            ts    = 1 x num_timesteps vector of the time associated with each simulation step.
            Vs    = num_timesteps x num_neurons matrix of the neuron membrane voltages over time
            hs    = num_timesteps x num_neurons matrix of neuron sodium channel deactivation parameters.
            dVs   = num_timesteps x num_neurons matrix of neuron membrane voltage derivatives over time
            dhs   = num_timesteps x num_neurons matrix of neuron sodium channel deactivation parameter derivatives.
            Gsyns = num_timesteps x num_synapses matrix of synapse conductances over time.
            Ileaks
                  = num_timsteps x num_neurons matrix of neuron leak currents over time.
            Isyns = num_timesteps x num_neurons matrix of synaptic currents over time.
            Inas  = num_timesteps x num_neurons matrix of sodium channel currents for each neuron.
            Itotals
                  = num_timesteps x num_neurons matrix of total currents for each neuron.
            minfs = num_timesteps x num_neurons matrix of neuron steady state sodium channel activation values.
            hinfs = num_timesteps x num_neurons matrix of neuron steady state sodium channel deactivation values.
            tauhs = num_timesteps x num_neurons matrix of sodium channel deactivation parameter time constants.
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
            Vs    = 1 x num_neurons vector of neuron membrane voltages
            hs    = 1 x num_neurons vector of neuron sodium channel deactivation parameters.
            Iapps = 1 x num_neurons vector of applied currents for each neuron

        Outputs:
            dVs   = 1 x num_neurons vector of neuron membrane voltage derivatives
            dhs   = 1 x num_neurons vector of neuron sodium channel deactivation parameter derivatives.
            Gsyns = 1 x num_neurons vector of synaptic conductances.
            Ileaks
                  = 1 x num_neurons vector of leak currents for each neuron.
            Isyns = 1 x num_neurons vector of synaptic currents for each neuron.
            Inas  = 1 x num_neurons vector of sodium channel currents for each neuron.
            Itotals
                  = 1 x num_neurons vector of total currents for each neuron.
            minfs = 1 x num_neurons vector of neuron steady state sodium channel activation values.
            hinfs = 1 x num_neurons vector of neuron steady state sodium channel deactivation values.
            tauhs = 1 x num_neurons vector of sodium channel deactivation parameter time constants.

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
	    Vs = 1 x num_neurons vector of neuron membrane voltages

	% Outputs:
	    Ileaks = 1 x num_neurons vector of the leak current associated with each neuron in the network.
        '''
        return self.Gms * (self.Ers - Vs)


    def GetSynapticCurrents(self, Vs):
        '''
        This function computes the synaptic current associated with each neuron in a network.

        Inputs:
            Vs = 1 x num_neurons vector of neuron membrane voltages

        Outputs:
            Isyns = 1 x num_neurons vector of synaptic currents for each neuron in the network.
            Gsyns = 1 x num_neurons vectir of synapse conductances.
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
            Vs = 1 x num_neurons vector of neuron membrane voltages

        Outputs:
            Gsyns = 1 x num_neurons matrix of synapse conductances.
        '''

        # Compute the synaptic conductance associated with each synapse in the network.
        Gsyns = self.gsyn_maxs * (np.minimum(np.maximum((Vs[self.pre_V_i] - self.Elos) / self.Rs, 0), 1 ))
        
        return Gsyns


    def GetNaChCurrents(self, Vs, hs):
        '''
        This function computes the sodium channel current for each neuron in a network.

        Inputs:
            Vs = 1 x num_neurons vector of neuron membrane voltages
            hs = 1 x num_neurons vector of neuron sodium channel deactivation parameters.
        
        Outputs:
            Inas = 1 x num_neurons vector of sodium channel currents for each neuron.
            minfs = 1 x num_neurons vector of neuron steady state sodium channel activation values.
            hinfs = 1 x num_neurons vector of neuron steady state sodium channel deactivation values.
            tauhs = 1 x num_neurons vector of sodium channel deactivation parameter time constants.
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
        This function performs a single forward Euler step.
        '''
        # Compute the membrane voltage at the next time step.
        U = U + dt*dU

        return U
