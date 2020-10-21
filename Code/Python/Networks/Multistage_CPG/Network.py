import numpy as np


class Network:
    def __init__(self, num_neurons, 
                       nprops,
                       synprops,
                       neuron_order = None
                       ):
        # Define the number of neurons.
        self.num_neurons = num_neurons

        # Define the neuron order.
        self.neuron_order = neuron_order
        if self.neuron_order is None:
            self.neuron_order = np.arange(num_neurons)

        ###################################################### 
        # Define neuron properties
        ###################################################### 
        self.nprops = nprops
        

        # Store the neuron properties into arrays.
        self.Cms =       self.nprops.Cm * np.ones((num_neurons, 1))
        self.Gms =       self.nprops.Gm * np.ones((num_neurons, 1))
        self.Ers =       self.nprops.Er * np.ones((num_neurons, 1))
        self.Rs =        self.nprops.R  * np.ones((num_neurons, 1)) 
        self.Rs =        np.tile(self.Rs.T, (num_neurons, 1))
        self.Ams =       self.nprops.Am * np.ones((num_neurons, 1))
        self.Sms =       self.nprops.Sm * np.ones((num_neurons, 1))
        self.dEms =      self.nprops.dEm * np.ones((num_neurons, 1))
        self.Ahs =       self.nprops.Ah * np.ones((num_neurons, 1))
        self.Shs =       self.nprops.Sh * np.ones((num_neurons, 1))
        self.dEhs =      self.nprops.dEh * np.ones((num_neurons, 1))
        self.dEnas =     self.nprops.dEna * np.ones((num_neurons, 1))
        self.tauh_maxs = self.nprops.tauh_max * np.ones((num_neurons, 1))
        self.Gnas =      self.nprops.Gna * np.ones((num_neurons, 1))


        ###################################################### 
        # Define Applied Current Magnitudes.
        ###################################################### 

        # Note that these are not necessarily constant applied currents.  Here we are only computing the maximum applied current for each neuron, if an applied current will be applied at all.

        # Compute the necessary applied current magnitudes.
        self.Iapps_mag = self.Gms * self.Rs                # [A] Applied Current.
        # Define tonic current magnitudes.
        self.Iapps_tonic = np.zeros((num_neurons, 1))


        ###################################################### 
        # Define Synapse Properties.
        ###################################################### 

        self.synprops = synprops

        # Create a matrix of synaptic reversal potentials.
        self.dEsyns = self.synprops.dEsyn * np.ones((num_neurons, num_neurons)) 
        self.dEsyns[np.eye(*self.dEsyns.shape).astype('bool')] = 0

        # Compute the delta matrix that describes the type of synaptic connections we want to form.
        self.deltas = self.GetDeltaMatrix()

        # Compute the synaptic conductances necessary to achieve these deltas.
        self.gsyn_maxs = self.GetCPGChainSynapticConductances()


    def GetDeltaMatrix(self):
        '''
        Called by constructor
        This function computes the delta matrix required to make a multistate CPG oscillate in a specified order.

        Outputs:
            deltas = num_neurons x num_neurons matrix whose ij entry is the delta value that describes the synapse from neuron j to neuron i.
        '''

        # Initialize the delta matrix to be completely bistable.
        deltas = self.synprops.delta_bistable * np.ones((self.num_neurons, self.num_neurons))

        # Switch thte desired synapses to be oscillatory.
        for k in range(self.num_neurons):
            # Compute the index of the next neuron in the chain.
            j = (k + 1) % self.num_neurons

            # Compute the from and to indexes.
            from_index = self.neuron_order[k]
            to_index = self.neuron_order[j]

            # Set the appropriate synapse to be oscillatory.
            deltas[to_index, from_index] = self.synprops.delta_oscillatory

        # Zero out the diagonal entries.
        np.ravel(deltas)[np.arange(0, np.size(deltas), 1 + deltas.shape[0])] = 0
        
        return deltas


    def GetCPGChainSynapticConductances(self):
        '''
        Called by constructor
        This function computes the maximum synaptic conductances for a chain of CPGs necessary to achieve the specified deltas with the given network properties.
        '''

        # define an anonymous function to compute the steady state sodium channel activation parameter.
        fminf = self.nprops.GetSteadyStateNaActDeactValue

        # Define an anonymous function to compute the steady state sodium channel deactivation parameter.
        fhinf = self.nprops.GetSteadyStateNaActDeactValue

        # Define an anonymous function to compute leak currents.
        fIleak = lambda U, Gm: -Gm*U 

        # Define an anonymous function to compute sodium channel currents.
        fInainf = lambda U, Gna, Am, Sm, dEm, Ah, Sh, dEh, dEna: Gna * fminf(U, Am, Sm, dEm) * fhinf(U, Ah, Sh, dEh) * (dEna - U)

        # Define an anonymous function that is the opposite of the kronecker delta function.
        neq = lambda a, b: 0 if a == b else 1

        # Compute the number of equations we need to solve.
        num_eqs = self.num_neurons * (self.num_neurons - 1)

        # Preallocate an array to store the system matrix and right-hand side.
        A = np.zeros((num_eqs, num_eqs))
        b = np.zeros((num_eqs, 1))

        # Compute the system matrix and right-hand side entries.
        for k in range(self.num_neurons):               # Iterate through each of the neurons...

            # Compute the critical index p.
            p = ((k + 1) % self.num_neurons) 

            # Compute the system matrix and right-hand side entries.
            for i in range(self.num_neurons):           # Iterate through each of the neurons...

                # Determine whether to compute system matrix and right-hand side entries for this synapse.
                if i != k:                   # If this synapse is not a self-connection...

                    # Compute the system and right-hand side coefficients.
                    aik1 = self.deltas[i, k] - self.dEsyns[i, k]
                    aik2 = neq(p, k) * ( self.deltas[p, k] / self.Rs[p, k] ) * ( self.deltas[i, k] - self.dEsyns[p, k] )
                    bik = fIleak(self.deltas[i, k], self.Gms[i]) + fInainf(self.deltas[i, k], self.Gnas[i], self.Ams[i], self.Sms[i], self.dEms[i], self.Ahs[i], self.Shs[i], self.dEhs[i], self.dEnas[i]) + self.Iapps_tonic[i]

                    # Determine the row index at which to store these coefficients.
                    r = (self.num_neurons - 1) * (k ) + i
                    # Determine whether to correct the row entry.
                    if i > k:               # If this is an entry whose row index needs to be corrected...
                        # Correct the row entry.
                        r = r - 1

                    # Determine the column index at which to store the first coefficient.
                    c1 = (self.num_neurons - 1) * (i ) + k
                    # Determine whether the first column index needs to be corrected.
                    if k > i:                # If this is an entry whose first column index needs to be corrected...
                        # Correct the first column index.
                        c1 = c1 - 1

                    # Determine the column index at which to store the second coefficient.
                    c2 = (self.num_neurons - 1) * (p ) + k
                    # Determine whether the second column index needs to be corrected.
                    if k > p:                # If this is an entry whose second column index needs to be corrected...
                        # Correct the second column index.
                        c2 = c2 - 1

                    # Store the first and second system matrix coefficients.
                    A[r, c1] += aik1
                    A[r, c2] += aik2

                    # Store the right-hand side coefficient.
                    b[r] = bik

        # Solve the system of equations.
        gsyns_vector = np.linalg.solve(A, b).reshape(num_eqs)

        # Convert the maximum synaptic conductance vector into a matrix.
        gsyn_maxs = self.SynapticConductanceVector2Matrix(gsyns_vector)

        return gsyn_maxs


    def SynapticConductanceVector2Matrix(self, gsyns_vector):
        '''
        Called by constructor
        '''
        n = self.num_neurons

        # Preallocate the synaptic conductance matrix.
        gsyns_matrix = np.zeros((n, n))

        # Store each of the synaptic conductance vector entries into the synaptic conductance matrix.
        for k in range(n - 1):            # Iterate through each synaptic conductance...
            np.ravel(gsyns_matrix)[1 + k*(n+1) : 1 + k*(n+1) + n] = gsyns_vector[k*(n) : (k+1)*(n)]

        return gsyns_matrix

    
    def SetSimulationProperties(self, tf, dt):
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
        self.Us0 = np.zeros((self.num_neurons, 1))
        self.hs0 = self.nprops.GetSteadyStateNaActDeactValue(self.Us0, self.nprops.Ah, self.nprops.Sh, self.nprops.dEh)


        # Define the Applied Currents.

        # Create the applied currents to use during simulation.
        self.Iapps = np.zeros((self.num_neurons, self.num_timesteps)) 
        self.Iapps[self.neuron_order[0], 0] = np.ravel(self.Iapps_mag)[self.neuron_order[0]]


    def Simulate(self):
        '''
        This function simulates a neural network described by Gms, Cms, Rs, gsyn_maxs, dEsyns with an initial condition of U0, h0 for tf seconds with a step size of dt and an applied current of Iapp.

        Inputs:
            Us0 = num_neurons x 1 vector of initial membrane voltages of each neuron w.r.t their resting potentials.
            hs0 = num_neurons x 1 vector of initial sodium channel deactivation parameters for each neuron.
            Gms = num_neurons x 1 vector of neuron membrane conductances.
            Cms = num_neurons x 1 vector of neuron membrane capacitances.
            Rs = num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
            gsyn_maxs = num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
            dEsyns = num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
            Ams = num_neurons x 1 vector of sodium channel activation A parameter values.
            Sms = num_neurons x 1 vector of sodium channel activation S parameter values.
            dEms = num_neurons x 1 vector of sodium channel activation parameter reversal potentials.
            Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
            Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
            dEhs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
            tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
            Gnas = num_neurons x 1 vector of sodium channel conductances for each neuron.
            dEnas = num_neurons x 1 vector of sodium channel reversal potentials for each neuron.
            Iapp = num_neurons x num_timesteps vector of applied currents for each neuron.
            tf = Scalar that represents the simulation duration.
            dt = Scalar that represents the simulation time step.

        Outputs:
            ts = 1 x num_timesteps vector of the time associated with each simulation step.
            Us = num_neurons x num_timesteps matrix of the neuron membrane voltages over time w.r.t. their resting potentials.
            hs = num_neurons x num_timesteps matrix of neuron sodium channel deactivation parameters.
            dUs = num_neurons x num_timesteps matrix of neuron membrane voltage derivatives over time w.r.t their resting potentials.
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
        if self.Iapps.shape[1] != self.num_timesteps:                  # If the number of Iapps columns is not equal to the number of timesteps...
            # Throw an error.
            raise ValueError('Iapps.shape[1] must equal the number of simulation time steps.\n')

        # Preallocate arrays to store the simulation data.
        self.Us, self.hs, self.dUs, self.dhs, self.Ileaks, self.Isyns, self.Inas, self.Itotals, self.minfs, self.hinfs, self.tauhs = (np.zeros((self.num_neurons, self.num_timesteps)) for i in range(11)) 

        # Preallocate a multidimensional array to store the synaptic conductances.
        self.Gsyns = np.zeros((self.num_neurons, self.num_neurons, self.num_timesteps))

        # Set the initial network condition.
        self.Us[:, 0:1] = self.Us0 
        self.hs[:, 0:1] = self.hs0

        # Simulate the network.
        for k in range(self.num_timesteps - 1):               # Iterate through each timestep...

            # Compute the network state derivatives (as well as other intermediate network values).
            self.dUs[:, k:k+1], self.dhs[:, k:k+1], self.Gsyns[:, :, k:k+1], self.Ileaks[:, k:k+1], self.Isyns[:, k:k+1], self.Inas[:, k:k+1], self.Itotals[:, k:k+1], self.minfs[:, k:k+1], self.hinfs[:, k:k+1], self.tauhs[:, k:k+1] = self.NetworkStep(self.Us[:, k:k+1], self.hs[:, k:k+1], self.Iapps[:, k:k+1])

            # Compute the membrane voltages at the next time step.
            self.Us[:, (k + 1) : (k + 2)] = self.ForwardEulerStep(self.Us[:, k:k+1], self.dUs[:, k:k+1], self.dt)

            # Compute the sodium channel deactivation parameters at the next time step.
            self.hs[:, (k + 1) : (k + 2)] = self.ForwardEulerStep(self.hs[:, k:k+1], self.dhs[:, k:k+1], self.dt)


        # Advance the loop counter variable to perform one more network step.
        k = k + 1

        # Compute the network state derivatives (as well as other intermediate network values).
        self.dUs[:, k:k+1], self.dhs[:, k:k+1], self.Gsyns[:, :, k:k+1], self.Ileaks[:, k:k+1], self.Isyns[:, k:k+1], self.Inas[:, k:k+1], self.Itotals[:, k:k+1], self.minfs[:, k:k+1], self.hinfs[:, k:k+1], self.tauhs[:, k:k+1] = self.NetworkStep(self.Us[:, k:k+1], self.hs[:, k:k+1], self.Iapps[:, k:k+1])

    def NetworkStep(self, Us, hs, Iapp):
        '''
        This function computes a single step of a neural network without sodium channels.

        Inputs, from the previous network step:
            Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.
            hs = num_neurons x 1 vector of neuron sodium channel deactivation parameters.
            Iapps = num_neurons x 1 vector of applied currents for each neuron

        Outputs:
            dUs = num_neurons x 1 vector of neuron membrane voltage derivatives w.r.t their resting potentials.
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
        Ileaks = self.GetLeakCurrent(Us)

        # Compute synaptic currents.
        Isyns, Gsyns = self.GetSynapticCurrents(Us)
        Gsyns = Gsyns.reshape(self.num_neurons, self.num_neurons, 1)

        # Compute the sodium channel currents.
        Inas, minfs, hinfs, tauhs = self.GetNaChCurrents(Us, hs)

        # Compute the total currents.
        Itotals = Ileaks + Isyns + Inas + Iapp

        # Compute the membrane voltage derivatives.
        dUs = Itotals / self.Cms

        # Compute the sodium channel deactivation parameter derivatives.
        dhs = (hinfs - hs) / tauhs

        return dUs, dhs, Gsyns, Ileaks, Isyns, Inas, Itotals, minfs, hinfs, tauhs

    
    def GetLeakCurrent(self, Us):
        '''
	This function computes the leak current associated with each neuron in a network.

	Inputs:
	    Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.

	% Outputs:
	    Ileaks = num_neurons x 1 vector of the leak current associated with each neuron in the network.
        '''
        return - self.Gms * Us


    def GetSynapticCurrents(self, Us):
        '''
        This function computes the synaptic current associated with each neuron in a network.

        Inputs:
            Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.

        Outputs:
            Isyns = num_neurons x 1 vector of synaptic currents for each neuron in the network.
            Gsyns = num_neurons x num_neurons matrix of synapse conductances over time.  The ijkentry represens the synaptic condutance from neuron j to neuron i.
        '''

        # Compute the synaptic conductances of each synapse in the network.
        Gsyns = self.GetSynapticCondutances(Us)

        # Compute the synaptic current for each neuron.
        Isyns = np.sum(Gsyns * ( self.dEsyns - Us ), 1).reshape(self.num_neurons,1)

        return Isyns, Gsyns


    def GetSynapticCondutances(self, Us):
        '''
        This function computes the synaptic condutance associated with each synapse in a network.

        Inputs:
            Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.

        Outputs:
            Gsyns = num_neurons x num_neurons matrix of synapse conductances over time.  The ijkentry represens the synaptic condutance from neuron j to neuron i.
        '''

        # Compute the synaptic conductance associated with each synapse in the network.
        Gsyns = self.gsyn_maxs * (np.minimum(np.maximum(Us.T / self.Rs, 0), 1 ))
        
        return Gsyns


    def GetNaChCurrents(self, Us, hs):
        '''
        This function computes the sodium channel current for each neuron in a network.

        Inputs:
            Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potential.
            hs = num_neurons x 1 vector of neuron sodium channel deactivation parameters.
        
        Outputs:
            Inas = num_neurons x 1 vector of sodium channel currents for each neuron.
            minfs = num_neurons x 1 vector of neuron steady state sodium channel activation values.
            hinfs = num_neurons x 1 vector of neuron steady state sodium channel deactivation values.
            tauhs = num_neurons x 1 vector of sodium channel deactivation parameter time constants.
        '''

        # Compute the steady state sodium channel activation parameters.
        minfs = self.nprops.GetSteadyStateNaActDeactValue(Us, self.Ams, self.Sms, self.dEms)

        # Compute the steady state sodium channel deactivation parameters.
        hinfs = self.nprops.GetSteadyStateNaActDeactValue(Us, self.Ahs, self.Shs, self.dEhs)

        # Compute the sodium channel deactivation time constants.
        tauhs = self.nprops.GetNaDeactTimeConst(Us, self.tauh_maxs, hinfs, self.Ahs, self.Shs, self.dEhs)

        # Compute the sodium channel currents.
        Inas = self.Gnas * minfs * hs * (self.dEnas - Us)

        return Inas, minfs, hinfs, tauhs


    def ForwardEulerStep(self, U, dU, dt):
        '''
        his function performs a single forward Euler step.
        '''
        # Compute the membrane voltage at the next time step.
        U = U + dt*dU

        return U
