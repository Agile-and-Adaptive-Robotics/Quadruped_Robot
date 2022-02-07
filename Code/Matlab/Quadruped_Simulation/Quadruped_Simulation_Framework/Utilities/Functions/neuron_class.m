classdef neuron_class

    % This class contains properties and methods related to neurons.
    
    %% NEURON PROPERTIES
    
    % Define the class properties.
    properties
        
        ID
        name
        
        U
        h
        
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
        
        I_leak
        I_syn
        I_na
        I_tonic
        I_app
        I_total
        
        neuron_utilities
        
    end
    
    
    %% NEURON METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neuron_class( ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total )
            
            % Create an instance of the neuron utilities class.
            self.neuron_utilities = neuron_utilities_class(  );
            
            % Set the default neuron properties.
            if nargin < 23, self.I_total = 0; else, self.I_total = I_total; end
            if nargin < 22, self.I_app = 0; else, self.I_app = I_app; end
            if nargin < 21, self.I_tonic = 0; else, self.I_tonic = I_tonic; end
            if nargin < 20, self.I_na = 0; else, self.I_na = I_na; end
            if nargin < 19, self.I_syn = 0; else, self.I_syn = I_syn; end
            if nargin < 18, self.I_leak = 0; else, self.I_leak = I_leak; end
            if nargin < 17, self.Gna = 1e-6; else, self.Gna = Gna; end
            if nargin < 16, self.tauh_max = 0.25; else, self.tauh_max = tauh_max; end
            if nargin < 15, self.dEna = 110e-3; else, self.dEna = dEna; end
            if nargin < 14, self.dEh = 0; else, self.dEh = dEh; end
            if nargin < 13, self.Sh = 50; else, self.Sh = Sh; end
            if nargin < 12, self.Ah = 0.5; else, self.Ah = Ah; end
            if nargin < 11, self.dEm = 40e-3; else, self.dEm = dEm; end
            if nargin < 10, self.Sm = -50; else, self.Sm = Sm; end
            if nargin < 9, self.Am = 1; else, self.Am = Am; end
            if nargin < 8, self.R = 20e-3; else, self.R = R; end
            if nargin < 7, self.Er = -60e-3; else, self.Er = Er; end
            if nargin < 6, self.Gm = 1e-6; else, self.Gm = Gm; end
            if nargin < 5, self.Cm = 5e-9; else, self.Cm = Cm; end
            if nargin < 4, self.h = 0; else, self.h = h; end
            if nargin < 3, self.U = 0; else, self.U = U; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end
            
            
            % Set the steady state sodium channel activation and deactivation parameters.
            self = self.compute_set_minf(  );
            self = self.compute_set_hinf(  );
            
        end
        

        %% Sodium Channel Activation & Deactivation Functions
        
        % Implement a function to compute the steady state sodium channel activation parameter.
        function minf = compute_minf( self )
            
            % Compute the steady state sodium channel activation parameter.
            minf = self.neuron_utilities.compute_mhinf( self.U, self.Am, self.Sm, self.dEm );
            
        end
        
        
        % Implement a function to compute the steady state sodium channel deactivation parameter.
        function hinf = compute_hinf( self )
           
            % Compute the steady state sodium channel deactivaiton parameter.
            hinf = self.neuron_utilities.compute_mhinf( self.U, self.Am, self.Sm, self.dEm );
            
        end

        
        % Implement a function to set the steady state sodium channel activation parameter.
        function self = compute_set_minf( self )

            % Compute the steady state sodium channel activation parameter.
            self.minf = self.compute_minf(  );
            
        end
        
        
        % Implement a function to set the steady state sodium channel deactivation parameter.
        function self = compute_set_hinf( self )
           
            % Compute the steady state sodium channel deactivaiton parameter.
            self.hinf = self.compute_hinf(  );
            
        end
        
        
        %% Conductance Functions
        
        % Implement a function to compute the required sodium channel conductance to create oscillation in a CPG subnetwork.
        function Gna = compute_CPG_Gna( self )
            
            % Compute the required sodium channel conductance to create oscillation in a two neuron CPG subnetwork.
            Gna = self.neuron_utilities.compute_CPG_Gna( self.R, self.Gm, self.Am, self.Sm, self.dEm, self.Ah, self.Sh, self.dEh, self.dEna );
            
        end
        

        % Implement a function to set the sodium channel conductance for a two neuron CPG subnetwork.
        function self = compute_set_CPG_Gna( self )
            
            % Compute the sodium channel conductance for a two neuron CPG subnetwork.
            self.Gna = self.compute_CPG_Gna(  );
            
        end
        
        
        %% Current Functions.
        
        % Implement a function to compute the leak current associated with this neuron.
        function I_leak = compute_leak_current( self )
           
            % Compute the leak current associated with this neuron.
            I_leak = self.neuron_utilities.compute_leak_current( self.U, self.Gm );
            
        end
        
            
        % Implement a function to compute and set the leak current associated with this neuron.
        function self = compute_set_leak_current( self )
            
           % Compute the leak current associated with this neuron.
           self.I_leak = self.compute_leak_current(  );
            
        end
        
        
        % Implement a function to compute the sodium channel current associated with this neuron.
        function I_na = compute_sodium_current( self )
        
            % Compute the sodium channel current associated with this neuron.
            I_na = self.neuron_utilities.compute_sodium_current( self.U, self.Gna, self.Am, self.Sm, self.dEm, self.Ah, self.Sh, self.dEh, self.dEna );
                       
        end
        
        
        % Implement a function to compute and set the sodium channel current associated with this neuron.
        function self = compute_set_sodium_current( self )
        
            % Compute the sodium channel current associated with this neuron.
            self.I_na = self.neuron_utilities.compute_sodium_current( self.U, self.Gna, self.Am, self.Sm, self.dEm, self.Ah, self.Sh, self.dEh, self.dEna );
                       
        end
        
        
        % Implement a function to compute the total current associated with this neuron.
        function I_total = compute_total_current( self )
            
            % Compute the total current.
            I_total = self.neuron_utilities.compute_total_current( self.I_leak, self.I_syn, self.I_na, self.I_tonic, self.I_app );
            
        end
        
        
        % Implement a function to compute and set the total current associated with this neuron.
        function self = compute_set_total_current( self )
            
            % Compute and set the total current.
            self.I_total = self.neuron_utilities.compute_total_current( self.I_leak, self.I_syn, self.I_na, self.I_app );
            
        end
        
        
    end
end

