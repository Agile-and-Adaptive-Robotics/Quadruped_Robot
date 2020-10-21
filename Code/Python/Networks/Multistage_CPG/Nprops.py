import numpy as np

class Nprops:
    def __init__(self, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna = None):
        '''
        Define universal neuron properties.
            Cm =        [F] Membrane Capacitance.
            Gm =        [S] Membrane Conductance.
            Er =        [V] Membrane Resting (Equilibrium) Potential.
            R =         [V] Biphasic Equilibrium Voltage Range.
            Am =        [-] Sodium Channel Activation Parameter A.
            Sm =        [-] Sodium Channel Activation Parametter S.
            dEm =       [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
            Ah =        [-] Sodiu  Channel Deactivation Parameter A.
            Sh =        [-] Sodium Channel Deactivation Parameter S.
            dEh =       [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
            dEna =      [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
            tauh_max =  [s] Maximum Sodium Channel Deactivation Time Constant.
            Gna =       [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)
        '''

        self.Cm = Cm                # [F] Membrane Capacitance.
        self.Gm = Gm                # [S] Membrane Conductance.
        self.Er = Er                # [V] Membrane Resting (Equilibrium) Potential.
        self.R = R                  # [V] Biphasic Equilibrium Voltage Range.
        self.Am = Am                # [-] Sodium Channel Activation Parameter A.
        self.Sm = Sm                # [-] Sodium Channel Activation Parametter S.
        self.dEm = dEm              # [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
        self.Ah = Ah                # [-] Sodiu  Channel Deactivation Parameter A.
        self.Sh = Sh                # [-] Sodium Channel Deactivation Parameter S.
        self.dEh = dEh              # [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
        self.dEna = dEna            # [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
        self.tauh_max = tauh_max    # [s] Maximum Sodium Channel Deactivation Time Constant.
        self.Gna = Gna              # [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)
        if self.Gna is None:
            self.Gna = Nprops.TwoNeuronCPGSubnetworkNaConductance(R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna)

    @staticmethod
    def TwoNeuronCPGSubnetworkNaConductance(R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna):
        '''
        Computes the sodium channel conductance for each half-center neuron.
        '''

        # Compute the steady state sodium channel activation & devactivation parameters at the upper equilibrium.
        minf = Nprops.GetSteadyStateNaActDeactValue(R, Am, Sm, dEm)
        hinf = Nprops.GetSteadyStateNaActDeactValue(R, Ah, Sh, dEh)

        # Compute the sodium channel conductance for each half-center neuron.
        Gna = (Gm*R)/(minf*hinf*(dEna - R))       # [S] Sodium Channel Conductance.  Equation straight from Szczecinski's CPG example.

        return Gna


    @staticmethod
    def GetSteadyStateNaActDeactValue(Us, Amhs, Smhs, dEmhs):
        '''
        This function computes the steady state sodium channel activation / deactivation parameter for every neuron in a network.

        Inputs:
            Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials for each neuron in the network.
            Amhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation A parameters.
            Smhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation S parameters.
            dEmhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation reversal potential w.r.t thier resting potentials.

        Outputs:
            mhinfs = num_neurons x 1 vector of neuron steady state sodium channel activation /deactivation values.
        '''
        mhinfs = 1/(1 + Amhs*np.exp(-Smhs*(dEmhs - Us)))

        return mhinfs


    @staticmethod
    def GetNaDeactTimeConst(Us, tauh_maxs, hinfs, Ahs, Shs, dEhs):
        '''
        This function computes the sodium channel deactivation time constant associated with each neuron in a network.

        Inputs:
            Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potential.
            tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
            hinfs = num_neurons x 1 vector of steady state sodium channel deactivation parameter values.
            Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
            Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
            dEhs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.

        % Outputs:
            tauhs = num_neurons x 1 vector of sodium channel deactivation parameter time constants.
        '''
        # Compute the sodium channel deactivation time constant.
        tauhs = tauh_maxs * hinfs * np.sqrt( Ahs * np.exp( -Shs * (dEhs - Us) ) );

        return tauhs
