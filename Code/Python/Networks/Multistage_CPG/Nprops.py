import numpy as np

class Nprops:
    def __init__(self, Cm, Gm, Er, Am, Sm, Em, Ah, Sh, Eh, Ena, tauh_max, Gna):
        '''
        Define universal neuron properties.
            Cm =        [F] Membrane Capacitance.
            Gm =        [S] Membrane Conductance.
            Er =        [V] Membrane Resting (Equilibrium) Potential.
            Am =        [-] Sodium Channel Activation Parameter A.
            Sm =        [-] Sodium Channel Activation Parametter S.
            Em =        [V] Sodium Channel Activation Reversal Potential (absolute)
            Ah =        [-] Sodiu  Channel Deactivation Parameter A.
            Sh =        [-] Sodium Channel Deactivation Parameter S.
            Eh =        [V] Sodium Channel Deactivation Reversal Potential (absolute)
            Ena =       [V] Sodium Channel Reversal Potential (absolute)
            tauh_max =  [s] Maximum Sodium Channel Deactivation Time Constant.
            Gna =       [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)
        '''

        self.Cm = Cm                # [F] Membrane Capacitance.
        self.Gm = Gm                # [S] Membrane Conductance.
        self.Er = Er                # [V] Membrane Resting (Equilibrium) Potential.
        self.Am = Am                # [-] Sodium Channel Activation Parameter A.
        self.Sm = Sm                # [-] Sodium Channel Activation Parametter S.
        self.Em = Em                # [V] Sodium Channel Activation Reversal Potential (absolute)
        self.Ah = Ah                # [-] Sodiu  Channel Deactivation Parameter A.
        self.Sh = Sh                # [-] Sodium Channel Deactivation Parameter S.
        self.Eh = Eh                # [V] Sodium Channel Deactivation Reversal Potential (absolute)
        self.Ena = Ena              # [V] Sodium Channel Reversal Potential (absolute)
        self.tauh_max = tauh_max    # [s] Maximum Sodium Channel Deactivation Time Constant.
        self.Gna = Gna              # [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)
        

    @staticmethod
    def GetSteadyStateNaActDeactValue(Vs, Amhs, Smhs, Emhs):
        '''
        This function computes the steady state sodium channel activation / deactivation parameter for every neuron in a network.

        Inputs:
            Vs   = 1 x num_neurons vector of neuron membrane voltages
            Amhs = 1 x num_neurons vector of neuron sodium channel activation / deactivation A parameters.
            Smhs = 1 x num_neurons vector of neuron sodium channel activation / deactivation S parameters.
            Emhs = 1 x num_neurons vector of neuron sodium channel activation / deactivation reversal potential

        Outputs:
            mhinfs = 1 x num_neurons vector of neuron steady state sodium channel activation /deactivation values.
        '''
        mhinfs = 1/(1 + Amhs*np.exp(-Smhs*(Emhs - Vs)))

        return mhinfs


    @staticmethod
    def GetNaDeactTimeConst(Vs, tauh_maxs, hinfs, Ahs, Shs, Ehs):
        '''
        This function computes the sodium channel deactivation time constant associated with each neuron in a network.

        Inputs:
            Vs  = 1 x num_neurons vector of neuron membrane voltages
            tauh_maxs
                = 1 x num_neurons vector of maximum sodium channel deactivation parameter time constants.
            hinfs
                = 1 x num_neurons vector of steady state sodium channel deactivation parameter values.
            Ahs = 1 x num_neurons vector of sodium channel deactivation A parameter values.
            Shs = 1 x num_neurons vector of sodium channel deactivation S parameter values.
            Ehs = 1 x num_neurons vector of sodium channel deactivation parameter reversal potentials.

        % Outputs:
            tauhs = 1 x num_neurons vector of sodium channel deactivation parameter time constants.
        '''
        # Compute the sodium channel deactivation time constant.
        tauhs = tauh_maxs * hinfs * np.sqrt( Ahs * np.exp( -Shs * (Ehs - Vs) ) );

        return tauhs
