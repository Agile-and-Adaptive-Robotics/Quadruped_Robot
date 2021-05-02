classdef neuron_class

    % This class contains properties and methods related to neurons.
    
    %% NEURON PROPERTIES
    
    % Define the class properties.
    properties
        Cm
        Gm
        Er
        R
        Am
        Sm
        dEm
        Ah
        Sh
        dEh
        dEna
        tauh_max
        Gna
    end
    
    
    %% NEURON METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neuron_class( Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna )

            % Set the default neuron properties.
            if nargin < 13, self.Gna = 1e-6; else, self.Gna = Gna; end
            if nargin < 12, self.tauh_max = 0.25; else, self.tauh_max = tauh_max; end
            if nargin < 11, self.dEna = 110e-3; else, self.dEna = dEna; end
            if nargin < 10, self.dEh = 0; else, self.dEh = dEh; end
            if nargin < 9, self.Sh = 50; else, self.Sh = Sh; end
            if nargin < 8, self.Ah = 0.5; else, self.Ah = Ah; end
            if nargin < 7, self.dEm = 40e-3; else, self.dEm = dEm; end
            if nargin < 6, self.Sm = -50; else, self.Sm = Sm; end
            if nargin < 5, self.Am = 1; else, self.Am = Am; end
            if nargin < 4, self.R = 20e-3; else, self.R = R; end
            if nargin < 3, self.Er = -60e-3; else, self.Er = Er; end
            if nargin < 2, self.Gm = 1e-6; else, self.Gm = Gm; end
            if nargin < 1, self.Cm = 5e-9; else, self.Cm = Cm; end
            
        end
        

        % Implement a function to compute the steady state sodium channel activation and deactivation parameters.
        function mhinfs = get_mhinfs( ~, Us, Amhs, Smhs, dEmhs )
        
            % This function computes the steady state sodium channel activation / deactivation parameter for every neuron in a network.

            % Inputs:
                % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials for each neuron in the network.
                % Amhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation A parameters.
                % Smhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation S parameters.
                % dEmhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation reversal potential w.r.t thier resting potentials.

            % Outputs:
                % mhinfs = num_neurons x 1 vector of neuron steady state sodium channel activation /deactivation values.

            % Compute the steady state sodium channel activation / deactivation parameter.
            mhinfs = 1./(1 + Amhs.*exp(-Smhs.*(dEmhs - Us)));
            
        end
        
        
        % Implement a function to compute the sodium channel conductances for a two neuron CPG subnetwork.
        function Gna = two_neuron_CPG_Gna( self, R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna )
            
            % Compute the steady state sodium channel activation & devactivation parameters at the upper equilibrium.
            minf = self.get_mhinfs( R, Am, Sm, dEm );
            hinf = self.get_mhinfs( R, Ah, Sh, dEh );

            % Compute the sodium channel conductance for each half-center neuron.
            Gna = (Gm.*R)./(minf.*hinf.*(dEna - R));       % [S] Sodium Channel Conductance.  Equation straight from Szczecinski's CPG example.

        end
        
    end
end

