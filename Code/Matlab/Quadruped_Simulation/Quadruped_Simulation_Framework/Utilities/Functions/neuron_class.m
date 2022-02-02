classdef neuron_class

    % This class contains properties and methods related to neurons.
    
    %% NEURON PROPERTIES
    
    % Define the class properties.
    properties
        
        ID
        name
        
        U
        
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
        
        minf
        hinf
        
    end
    
    
    %% NEURON METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neuron_class( ID, name, U, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna )

            % Set the default neuron properties.
            if nargin < 16, self.Gna = 1e-6; else, self.Gna = Gna; end
            if nargin < 15, self.tauh_max = 0.25; else, self.tauh_max = tauh_max; end
            if nargin < 14, self.dEna = 110e-3; else, self.dEna = dEna; end
            if nargin < 13, self.dEh = 0; else, self.dEh = dEh; end
            if nargin < 12, self.Sh = 50; else, self.Sh = Sh; end
            if nargin < 11, self.Ah = 0.5; else, self.Ah = Ah; end
            if nargin < 10, self.dEm = 40e-3; else, self.dEm = dEm; end
            if nargin < 9, self.Sm = -50; else, self.Sm = Sm; end
            if nargin < 8, self.Am = 1; else, self.Am = Am; end
            if nargin < 7, self.R = 20e-3; else, self.R = R; end
            if nargin < 6, self.Er = -60e-3; else, self.Er = Er; end
            if nargin < 5, self.Gm = 1e-6; else, self.Gm = Gm; end
            if nargin < 4, self.Cm = 5e-9; else, self.Cm = Cm; end
            if nargin < 3, self.U = 0; else, self.U = U; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end
            
            % Set the steady state sodium channel activation and deactivation parameters.
            self = self.set_minf(  );
            self = self.set_hinf(  );
            
        end
        

        %% Sodium Channel Activation & Deactivation Functions
        
        % Implement a function to compute the steady state sodium channel activation and deactivation parameters.
        function mhinf = compute_mhinf( ~, U, Amh, Smh, dEmh )
        
            % This function computes the steady state sodium channel activation / deactivation parameter for every neuron in a network.

            % Inputs:
                % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials for each neuron in the network.
                % Amhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation A parameters.
                % Smhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation S parameters.
                % dEmhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation reversal potential w.r.t thier resting potentials.

            % Outputs:
                % mhinfs = num_neurons x 1 vector of neuron steady state sodium channel activation /deactivation values.

            % Compute the steady state sodium channel activation / deactivation parameter.
            mhinf = 1./( 1 + Amh.*exp( -Smh.*( dEmh - U ) ) );
            
        end
        
        
        % Implement a function to compute the steady state sodium channel activation parameter.
        function minf = compute_minf( self )
            
            % Compute the steady state sodium channel activation parameter.
            minf = self.compute_mhinf( self.U, self.Am, self.Sm, self.dEm );
            
        end
        
        
        % Implement a function to compute the steady state sodium channel deactivation parameter.
        function hinf = compute_hinf( self )
           
            % Compute the steady state sodium channel deactivaiton parameter.
            hinf = self.compute_mhinf( self.U, self.Am, self.Sm, self.dEm );
            
        end
        
        
        % Implement a function to set the steady state sodium channel activation parameter.
        function self = set_minf( self )

            % Compute the steady state sodium channel activation parameter.
            self.minf = self.compute_minf(  );
            
        end
        
        
        % Implement a function to set the steady state sodium channel deactivation parameter.
        function self = set_hinf( self )
           
            % Compute the steady state sodium channel deactivaiton parameter.
            self.hinf = self.compute_hinf(  );
            
        end
        
        
        %% Sodium Channel Conductance Functions
        
        % Implement a function to compute the sodium channel conductances for a two neuron CPG subnetwork.
        function Gna = compute_two_neuron_CPG_Gna( self, R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna )
            
            % Compute the steady state sodium channel activation & devactivation parameters at the upper equilibrium.
            minf_upper = self.compute_mhinf( R, Am, Sm, dEm );
            hinf_upper = self.compute_mhinf( R, Ah, Sh, dEh );

            % Compute the sodium channel conductance for each half-center neuron.
            Gna = ( Gm.*R )./( minf_upper.*hinf_upper.*( dEna - R ) );       % [S] Sodium Channel Conductance.  Equation straight from Szczecinski's CPG example.

        end
        
        % Implement a function to set the sodium channel conductance for a two neuron CPG subnetwork.
        function self = set_two_neuron_CPG_Gna( self )
            
            % Compute the sodium channel conductance for a two neuron CPG subnetwork.
            self.Gna = self.compute_two_neuron_CPG_Gna( self.R, self.Gm, self.Am, self.Sm, self.dEm, self.Ah, self.Sh, self.dEh, self.dEna );
            
        end
        
        
    end
end

