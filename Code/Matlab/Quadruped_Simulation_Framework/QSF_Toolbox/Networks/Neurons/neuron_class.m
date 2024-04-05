classdef neuron_class
    
    % This class contains properties and methods related to neurons.
    
    %% NEURON PROPERTIES
    
    % Define the class properties.
    properties
        
        ID                                                                                                              % [#] Neuron ID
        name                                                                                                            % [-] Neuron Name
        
        U                                                                                                               % [V] Membrane Voltage
        h                                                                                                               % [-] Sodium Channel Deactivation Parameter
        
        Cm                                                                                                              % [C] Membrance Capacitance
        Gm                                                                                                              % [S] Membrane Conductance
        Er                                                                                                              % [V] Membrane Resting Potential
        R                                                                                                               % [V] Activation Domain
        
        Am                                                                                                              % [V] Sodium Channel Activation Amplitude
        Sm                                                                                                              % [V] Sodium Channel Activation Slope
        dEm                                                                                                             % [V] Sodium Channel Activation Reversal Potential
        
        Ah                                                                                                              % [-] Sodium Channel Deactivation Amplitude
        Sh                                                                                                              % [-] Sodium Channel Deactivation Slope
        dEh                                                                                                             % [V] Sodium Channel Deactivation Reversal Potential
        
        dEna                                                                                                            % [V] Sodium Channel Reversal Potential
        tauh_max                                                                                                        % [s] Maximum Sodium Channel Deactivation Time Constant
        tauh                                                                                                            % [s] Sodium Channel Deactivation Time Constant
        Gna                                                                                                             % [S] Sodium Channel Conductance
        
        m_inf                                                                                                           % [-] Steady State Sodium Channel Activation Parameter
        h_inf                                                                                                           % [-] Steady State Sodium Channel Deactivation Parameter
        
        I_leak                                                                                                          % [A] Leak Current
        I_syn                                                                                                           % [A] Synaptic Current
        I_na                                                                                                            % [A] Sodium Channel Current
        I_tonic                                                                                                         % [A] Tonic Current
        I_app                                                                                                           % [A] Applied Current
        I_total                                                                                                         % [A] Total Current
        
        b_enabled                                                                                                       % [-] [T/F] Enable Flag
        
        neuron_utilities                                                                                                % [-] Neuron Utilities Class
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % Define the neuron parameters.
        Cm_DEFAULT = 5e-9;                                                                                              % [C] Membrane Capacitance
        Gm_DEFAULT = 1e-6;                                                                                              % [S] Membrane Conductance
        Er_DEFAULT = -60e-3;                                                                                            % [V] Equilibrium Voltage
        R_DEFAULT = 20e-3;                                                                                              % [V] Activation Domain
        Am_DEFAULT = 1;                                                                                                 % [-] Sodium Channel Activation Parameter Amplitude
        Sm_DEFAULT = -50;                                                                                               % [-] Sodium Channel Activation Parameter Slope
        dEm_DEFAULT = 40e-3;                                                                                            % [V] Sodium Channel Activation Reversal Potential
        Ah_DEFAULT = 0.5;                                                                                               % [-] Sodium Channel Deactivation Parameter Amplitude
        Sh_DEFAULT = 50;                                                                                                % [-] Sodium Channel Deactivation Parameter Slope
        dEh_DEFAULT = 0;                                                                                                % [V] Sodium Channel Deactivation Reversal Potential
        dEna_DEFAULT = 110e-3;                                                                                          % [V] Sodium Channel Reversal Potential
        tauh_max_DEFAULT = 0.25;                                                                                        % [s] Maximum Sodium Channel Steady State Time Constant
        Gna_DEFAULT = 1e-6;                                                                                             % [S] Sodium Channel Conductance
        Ileak_DEFAULT = 0;                                                                                              % [A] Leak Current
        Isyn_DEFAULT = 0;                                                                                               % [A] Synaptic Current
        Ina_DEFAULT = 0;                                                                                                % [A] Sodium Channel Current
        Itonic_DEFAULT = 0;                                                                                             % [A] Tonic Current
        Iapp_DEFAULT = 0;                                                                                               % [A] Applied Current
        Itotal_DEFAULT = 0;                                                                                             % [A] Total Current
        
        % Define the derivative subnetwork parameters.
        c_derivation_DEFAULT = 1e6;                                                                                 	% [-] Derivative Gain
        w_derivation_DEFAULT = 1;                                                                                     	% [Hz?] Derivative Cutoff Frequency?
        sf_derivation_DEFAULT = 0.05;                                                                                 	% [-] Derivative safety Factor
        
        % Define the integration subnetwork parameters.
        c_integration_mean_DEFAULT = 0.01e9;                                                                          	% [-] Average Integration Gain
        
        % Define the center pattern generator parameters.
        T_oscillation_DEFAULT = 2;                                                                                   	% [s] Oscillation Period.
        r_oscillation_DEFAULT = 0.90;                                                                                  	% [-] Oscillation Decay.
        num_cpg_neurons_DEFAULT = 2;                                                                                  	% [#} Number of CPG Neurons.
        
        % Subnetwork parameters.
        c_DEFAULT = 1;                                                                                                 	% [-] General Subnetwork Gain
        epsilon_DEFAULT = 1e-6;                                                                                        	% [-] Subnetwork Input Offset
        delta_DEFAULT = 1e-6;                                                                                          	% [-] Subnetwork Output Offset
        alpha_DEFAULT = 1e-6;                                                                                           % [-] Subnetwork Denominator Adjustment
        
    end
    
    
    %% NEURON METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neuron_class( ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total, b_enabled )
            
            % Create an instance of the neuron utilities class.
            self.neuron_utilities = neuron_utilities_class(  );
            
            % Set the default neuron properties.
            if nargin < 24, self.b_enabled = true; else, self.b_enabled = b_enabled; end                                % [T/F] Enable Flag
            if nargin < 23, self.I_total = self.Itotal_DEFAULT; else, self.I_total = I_total; end                       % [A] Total Current
            if nargin < 22, self.I_app = self.Iapp_DEFAULT; else, self.I_app = I_app; end                               % [A] Applied Current
            if nargin < 21, self.I_tonic = self.Itonic_DEFAULT; else, self.I_tonic = I_tonic; end                       % [A] Tonic Current
            if nargin < 20, self.I_na = self.Ina_DEFAULT; else, self.I_na = I_na; end                                   % [A] Sodium Channel Current
            if nargin < 19, self.I_syn = self.Isyn_DEFAULT; else, self.I_syn = I_syn; end                               % [A] Synaptic Current
            if nargin < 18, self.I_leak = self.Ileak_DEFAULT; else, self.I_leak = I_leak; end                           % [A] Leak Current
            if nargin < 17, self.Gna = self.Gna_DEFAULT; else, self.Gna = Gna; end                                      % [S] Sodium Channel Conductance
            if nargin < 16, self.tauh_max = self.tauh_max_DEFAULT; else, self.tauh_max = tauh_max; end                  % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 15, self.dEna = self.dEna_DEFAULT; else, self.dEna = dEna; end                                  % [V] Sodium Channel Reveral Potential
            if nargin < 14, self.dEh = self.dEh_DEFAULT; else, self.dEh = dEh; end                                      % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 13, self.Sh = self.Sh_DEFAULT; else, self.Sh = Sh; end                                          % [V] Sodium Channel Deacitvation Slope
            if nargin < 12, self.Ah = self.Ah_DEFAULT; else, self.Ah = Ah; end                                          % [V] Sodium Channel Deactivation Amplitude
            if nargin < 11, self.dEm = self.dEm_DEFAULT; else, self.dEm = dEm; end                                      % [V] Sodium Channel Activation Reversal Potential
            if nargin < 10, self.Sm = self.Sm_DEFAULT; else, self.Sm = Sm; end                                          % [V] Sodium Channel Activation Slope
            if nargin < 9, self.Am = self.Am_DEFAULT; else, self.Am = Am; end                                           % [V] Sodium Channel Activation Amplitude
            if nargin < 8, self.R = self.R_DEFAULT; else, self.R = R; end                                               % [V] Activation Domain
            if nargin < 7, self.Er = self.Er_DEFAULT; else, self.Er = Er; end                                           % [V] Membrane Reversal Potential
            if nargin < 6, self.Gm = self.Gm_DEFAULT; else, self.Gm = Gm; end                                           % [S] Membrane Conductance
            if nargin < 5, self.Cm = self.Cm_DEFAULT; else, self.Cm = Cm; end                                           % [C] Membrane Capacitance
            if nargin < 4, self.h = [  ]; else, self.h = h; end                                                         % [-] Sodium Channel Deactivation
            if nargin < 3, self.U = 0; else, self.U = U; end                                                            % [V] Membrane Voltage
            if nargin < 2, self.name = ''; else, self.name = name; end                                                  % [-] Neuron Name
            if nargin < 1, self.ID = 0; else, self.ID = ID; end                                                         % [#] ID Number
            
            % Set the steady state sodium channel activation and deactivation parameters.
            self = self.compute_set_minf(  );                                                                           % [-] Steady State Sodium Channel Activation Parameter
            self = self.compute_set_hinf(  );                                                                           % [-] Steady State Sodium Channel Deactivation Parameter
            
            % Determine whether to set the sodium channel activation parameter to its steady state value.
            if isempty( self.h ), self.h = self.h_inf; end                                                              % [-] Steady State Sodium Channel Deactivation Parameter
            
            % Compute and set the sodium channel deactivation time constant.
            self = self.compute_set_tauh(  );                                                                           % [-] Sodium Channel Deactivation Time Constant
            
        end
        
        
        %% Sodium Channel Activation & Deactivation Compute Functions
        
        % Implement a function to compute the steady state sodium channel activation parameter.
        function m_inf = compute_minf( self, U, Am, Sm, dEm, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 6, neuron_utilities = self.neuron_utilities; end
            if nargin < 5, dEm = self.dEm; end                                                                          % [V] Sodium Channel Activation Reversal Potential
            if nargin < 4, Sm = self.Sm; end                                                                            % [-] Sodium Channel Activation Slope
            if nargin < 3, Am = self.Am; end                                                                            % [-] Sodium Channel Activation Amplitude
            if nargin < 2, U = self.U; end                                                                              % [V] Membrane Voltage
            
            % Compute the steady state sodium channel activation parameter.
            m_inf = neuron_utilities.compute_mhinf( U, Am, Sm, dEm );                                              % [-] Sodium Channel Activation Parameter
            
        end
        
        
        % Implement a function to compute the steady state sodium channel deactivation parameter.
        function h_inf = compute_hinf( self, U, Ah, Sh, dEh, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 6, neuron_utilities = self.neuron_utilities; end
            if nargin < 5, dEh = self.dEh; end                                                                          % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 4, Sh = self.Sh; end                                                                            % [-] Sodium Channel Deactivation Slope
            if nargin < 3, Ah = self.Ah; end                                                                            % [-] Sodium Channel Deactivation Amplitude
            if nargin < 2, U = self.U; end                                                                              % [V] Membrane Voltage
            
            % Compute the steady state sodium channel deactivaiton parameter.
            h_inf = neuron_utilities.compute_mhinf( U, Ah, Sh, dEh );                                              % [-] Sodium Channel Deactivation Parameter
            
        end
        
        
        % Implement a function to compute the sodium channel deactivation time constant.
        function tauh = compute_tauh( self, U, tauh_max, h_inf, Ah, Sh, dEh, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 8, neuron_utilities = self.neuron_utilities; end
            if nargin < 7, dEh = self.dEh; end                                                                          % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 6, Sh = self.Sh; end                                                                            % [-] Sodium Channel Deactivation Slope
            if nargin < 5, Ah = self.Ah; end                                                                            % [-] Sodium Channel Deactivation Amplitude
            if nargin < 4, h_inf = self.h_inf; end                                                                      % [-] Steady State Sodium Channel Deactivation Parameter
            if nargin < 3, tauh_max = self.tauh_max; end                                                                % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 2, U = self.U; end                                                                              % [V] Membrane Voltage
            
            % Compute the sodium channel deactivation time constant.
            tauh = neuron_utilities.compute_tauh( U, tauh_max, h_inf, Ah, Sh, dEh );                               % [s] Sodium Channel Deactivation Time Constant
            
        end
        
        
        %% Sodium Channel Conductance Compute Functions
        
        % Implement a function to compute the required sodium channel conductance to create oscillation in a CPG subnetwork.
        function Gna = compute_cpg_Gna( self, R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 11, neuron_utilities = self.neuron_utilities; end
            if nargin < 10, dEna = self.dEna; end                                                                       % [V] Sodium Channel Reversal Potential
            if nargin < 9, dEh = self.dEh; end                                                                          % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 8, Sh = self.Sh; end                                                                            % [-] Sodium Channel Deactivation Slope
            if nargin < 7, Ah = self.Ah; end                                                                            % [-] Sodium Channel Deactivation Amplitude
            if nargin < 6, dEm = self.dEm; end                                                                          % [V] Sodium Channel Activation Reversal Potential
            if nargin < 5, Sm = self.Sm; end                                                                            % [-] Sodium Channel Activation Slope
            if nargin < 4, Am = self.Am; end                                                                            % [-] Sodium Channel Activation Amplitude
            if nargin < 3, Gm = self.Gm; end                                                                            % [S] Membrane Conductance
            if nargin < 2, R = self.R; end                                                                              % [V] Activation Domain
            
            % Compute the required sodium channel conductance to create oscillation in a two neuron CPG subnetwork.
            Gna = neuron_utilities.compute_cpg_Gna( R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna );                       % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a driven multistate cpg subnetwork neuron.
        function Gna = compute_driven_multistate_cpg_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a driven multistate cpg subnetwork neuron.
            Gna = neuron_utilities.compute_driven_multistate_cpg_Gna(  );                                          % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a transmission subnetwork neuron.
        function Gna = compute_transmission_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a transmission subnetwork neuron.
            Gna = neuron_utilities.compute_transmission_Gna(  );                                                   % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a modulation subnetwork neuron.
        function Gna = compute_modulation_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a modulation subnetwork neuron.
            Gna = neuron_utilities.compute_modulation_Gna(  );                                                     % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for an addition subnetwork neuron.
        function Gna = compute_addition_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for an addition subnetwork neuron.
            Gna = neuron_utilities.compute_addition_Gna(  );                                                       % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for an absolute addition subnetwork neuron.
        function Gna = compute_absolute_addition_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for an absolute addition subnetwork neuron.
            Gna = neuron_utilities.compute_absolute_addition_Gna(  );                                              % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a relative addition subnetwork neuron.
        function Gna = compute_relative_addition_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a relative addition subnetwork neuron.
            Gna = neuron_utilities.compute_relative_addition_Gna(  );                                              % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a subtraction subnetwork neuron.
        function Gna = compute_subtraction_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a subtraction subnetwork neuron.
            Gna = neuron_utilities.compute_subtraction_Gna(  );                                                    % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for an absolute subtraction subnetwork neuron.
        function Gna = compute_absolute_subtraction_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for an absolute subtraction subnetwork neuron.
            Gna = neuron_utilities.compute_absolute_subtraction_Gna(  );                                           % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a relative subtraction subnetwork neuron.
        function Gna = compute_relative_subtraction_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a relative subtraction subnetwork neuron.
            Gna = neuron_utilities.compute_relative_subtraction_Gna(  );                                            % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a double subtraction subnetwork neuron.
        function Gna = compute_double_subtraction_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a double subtraction subnetwork neuron.
            Gna = neuron_utilities.compute_double_subtraction_Gna(  );                                             % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for an absolute double subtraction subnetwork neuron.
        function Gna = compute_absolute_double_subtraction_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for an absolute double subtraction subnetwork neuron.
            Gna = neuron_utilities.compute_absolute_double_subtraction_Gna(  );                                    % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a relative double subtraction subnetwork neuron.
        function Gna = compute_relative_double_subtraction_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a relative double subtraction subnetwork neuron.
            Gna = neuron_utilities.compute_relative_double_subtraction_Gna(  );                                    % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a multiplication subnetwork neuron.
        function Gna = compute_multiplication_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a multiplication subnetwork neuron.
            Gna = neuron_utilities.compute_multiplication_Gna(  );                                                 % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for an absolute multiplication subnetwork neuron.
        function Gna = compute_absolute_multiplication_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for an absolute multiplication subnetwork neuron.
            Gna = neuron_utilities.compute_absolute_multiplication_Gna(  );                                        % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a relative multiplication subnetwork neuron.
        function Gna = compute_relative_multiplication_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a relative multiplication subnetwork neurons.
            Gna = neuron_utilities.compute_relative_multiplication_Gna(  );                                         % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for an inversion subnetwork neuron.
        function Gna = compute_inversion_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for an inversion subnetwork neuron.
            Gna = neuron_utilities.compute_inversion_Gna(  );                                                      % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for an absolute inversion subnetwork neuron.
        function Gna = compute_absolute_inversion_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for an absolute inversion subnetwork neuron.
            Gna = neuron_utilities.compute_absolute_inversion_Gna(  );                                             % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a relative inversion subnetwork neuron.
        function Gna = compute_relative_inversion_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a relative inversion subnetwork neuron.
            Gna = neuron_utilities.compute_relative_inversion_Gna(  );                                              % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a division subnetwork neuron.
        function Gna = compute_division_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a division subnetwork neuron.
            Gna = neuron_utilities.compute_division_Gna(  );                                                       % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for an absolute division subnetwork neuron.
        function Gna = compute_absolute_division_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for an absolute division subnetwork neuron.
            Gna = neuron_utilities.compute_absolute_division_Gna(  );                                              % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a relative division subnetwork neuron.
        function Gna = compute_relative_division_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a relative division subnetwork neuron.
            Gna = neuron_utilities.compute_relative_division_Gna(  );                                               % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a derivation subnetwork neuron.
        function Gna = compute_derivation_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a derivation subnetwork neuron.
            Gna = neuron_utilities.compute_derivation_Gna(  );                                                     % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for an integration subnetwork neuron.
        function Gna = compute_integration_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for an integration subnetwork neuron.
            Gna = neuron_utilities.compute_integration_Gna(  );                                                    % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a voltage based integration subnetwork neuron.
        function Gna = compute_vb_integration_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a voltage based integration subnetwork neuron.
            Gna = neuron_utilities.compute_vb_integration_Gna(  );                                                 % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a split voltage based integration subnetwork neuron.
        function Gna = compute_split_vb_integration_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the sodium channel conductance for a split voltage based integration subnetwork neuron.
            Gna = neuron_utilities.compute_split_vb_integration_Gna(  );                                           % [S] Sodium Channel Conductance
            
        end
        
        
        %% Membrane Conductance Compute Functions
        
        % Implement a function to compute the membrance conductance for absolute addition subnetwork input neurons.
        function Gm = compute_absolute_addition_Gm_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_absolute_addition_Gm_input(  );                                          % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrance conductance for absolute addition subnetwork output neurons.
        function Gm = compute_absolute_addition_Gm_output( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_absolute_addition_Gm_output(  );                                         % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrance conductance for relative addition subnetwork input neurons.
        function Gm = compute_relative_addition_Gm_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_relative_addition_Gm_input(  );                                          % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrance conductance for relative addition subnetwork output neurons.
        function Gm = compute_relative_addition_Gm_output( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_relative_addition_Gm_output(  );                                         % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute subtraction subnetwork input neurons.
        function Gm = compute_absolute_subtraction_Gm_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_absolute_subtraction_Gm_input(  );                                       % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute subtraction subnetwork output neurons.
        function Gm = compute_absolute_subtraction_Gm_output( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_absolute_subtraction_Gm_output(  );                                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative subtraction subnetwork input neurons.
        function Gm = compute_relative_subtraction_Gm_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_relative_subtraction_Gm_input(  );                                       % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative subtraction subnetwork output neurons.
        function Gm = compute_relative_subtraction_Gm_output( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_relative_subtraction_Gm_output(  );                                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute inversion subnetwork input neurons.
        function Gm = compute_absolute_inversion_Gm_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_absolute_inversion_Gm_input(  );                                         % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute inversion subnetwork output neurons.
        function Gm = compute_absolute_inversion_Gm_output( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_absolute_inversion_Gm_output(  );                                        % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative inversion subnetwork input neurons.
        function Gm = compute_relative_inversion_Gm_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_relative_inversion_Gm_input(  );                                         % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative inversion subnetwork output neurons.
        function Gm = compute_relative_inversion_Gm_output( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_relative_inversion_Gm_output(  );                                        % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute division subnetwork input neurons.
        function Gm = compute_absolute_division_Gm_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_absolute_division_Gm_input(  );                                          % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute division subnetwork output neurons.
        function Gm = compute_absolute_division_Gm_output( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_absolute_division_Gm_output(  );                                         % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative division subnetwork input neurons.
        function Gm = compute_relative_division_Gm_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_relative_division_Gm_input(  );                                          % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative division subnetwork output neurons.
        function Gm = compute_relative_division_Gm_output( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane conductance.
            Gm = neuron_utilities.compute_relative_division_Gm_output(  );                                         % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the required membrane conductance for a derivation neuron.
        function Gm = compute_derivation_Gm( self, k, w, safety_factor, neuron_utilities )
            
            % Set the default input arugments.
            if nargin < 5, neuron_utilities = self.neuron_utilities; end
            if nargin < 4, safety_factor = self.sf_derivation_DEFAULT; end                                                      % [-] Derivation Subnetwork Safety Factor
            if nargin < 3, w = self.w_derivation_DEFAULT; end                                                                   % [Hz?] Derivation Subnetwork Cutoff Frequency?
            if nargin < 2, k = self.c_derivation_DEFAULT; end                                                                   % [-] Derivation Subnetwork Gain
            
            % Compute the membrane conductance for this derivation neuron.
            Gm = neuron_utilities.compute_derivation_Gm( k, w, safety_factor );                                    % [S] Membrane Conductance
            
        end
        
        
        %% Membrane Capacitance Compute Functions
        
        % Implement a function to compute the membrane capacitance for a transmission subnetwork neuron.
        function Cm = compute_transmission_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for a transmission subnetwork neuron.
            Cm = neuron_utilities.compute_transmission_Cm(  );                                                     % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a transmission subnetwork neuron.
        function Cm = compute_slow_transmission_Cm( self, Gm, num_cpg_neurons, T, r, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 6, neuron_utilities = self.neuron_utilites; end
            if nargin < 5, r = self.r_oscillation_DEFAULT; end                                                                  % [-] Oscillation Decay
            if nargin < 4, T = self.T_oscillation_DEFAULT; end                                                                  % [s] Oscillation Period
            if nargin < 3, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                                                  % [#] Number of CPG Neurons
            if nargin < 2, Gm = self.Gm; end                                                                            % [S] Membrane Conductance
            
            % Compute the membrane capacitance for a transmission subnetwork neuron.
            Cm = neuron_utilities.compute_slow_transmission_Cm( Gm, num_cpg_neurons, T, r );                       % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a modulation subnetwork neuron.
        function Cm = compute_modulation_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for a modulation subnetwork neuron.
            Cm = neuron_utilities.compute_modulation_Cm(  );                                                       % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for an addition subnetwork neuron.
        function Cm = compute_addition_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for an addition subnetwork neuron.
            Cm = neuron_utilities.compute_addition_Cm(  );                                                         % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for an absolute addition subnetwork neuron.
        function Cm = compute_absolute_addition_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for an absolute addition subnetwork neuron.
            Cm = neuron_utilities.compute_absolute_addition_Cm(  );                                                % [C] Membrane Capacitance
            
        end
        
        
        % Implemenet a function to compute the membrane capacitance for a relative addition subnetwork neuron.
        function Cm = compute_relative_addition_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for a relative addition subnetwork neuron.
            Cm = neuron_utilities.compute_relative_addition_Cm(  );                                                 % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a subtraction subnetwork neuron.
        function Cm = compute_subtraction_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for a subtraction subnetwork neuron.
            Cm = neuron_utilities.compute_subtraction_Cm(  );                                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for an absolute subtraction subnetwork neuron.
        function Cm = compute_absolute_subtraction_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for an absolute subtraction subnetwork neuron.
            Cm = neuron_utilities.compute_absolute_subtraction_Cm(  );                                             % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to comput the membrane capacitance for a relative subtraction subnetwork neuron.
        function Cm = compute_relative_subtraction_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for a relative subtraction subnetwork neuron.
            Cm = neuron_utilities.compute_relative_subtraction_Cm(  );                                             % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a double subtraction subnetwork neuron.
        function Cm = compute_double_subtraction_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for a double subtraction subnetwork neuron.
            Cm = neuron_utilities.compute_double_subtraction_Cm(  );                                               % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for an absolute double subtraction subnetwork neuron.
        function Cm = compute_absolute_double_subtraction_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for an absolute double subtraction subnetwork neuron.
            Cm = neuron_utilities.compute_absolute_double_subtraction_Cm(  );                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a relative double subtraction subnetwork neuron.
        function Cm = compute_relative_double_subtraction_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for a relative double subtraction subnetwork neuron.
            Cm = neuron_utilities.compute_relative_double_subtraction_Cm(  );                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for an inversion subnetwork neuron.
        function Cm = compute_inversion_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for an inversion subnetwork neuron.
            Cm = neuron_utilities.compute_inversion_Cm(  );                                                        % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for an absolute inversion subnetwork neuron.
        function Cm = compute_absolute_inversion_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for an absolute inversion subnetwork neuron.
            Cm = neuron_utilities.compute_absolute_inversion_Cm(  );                                               % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a relative inversion subnetwork neuron.
        function Cm = compute_relative_inversion_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for a relative inversion subnetwork neuron.
            Cm = neuron_utilities.compute_relative_inversion_Cm(  );                                               % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a division subnetwork neuron.
        function Cm = compute_division_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for a division subnetwork neuron.
            Cm = neuron_utilities.compute_division_Cm(  );                                                         % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for an absolute division subnetwork neuron.
        function Cm = compute_absolute_division_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for an absolute division subnetwork neuron.
            Cm = neuron_utilities.compute_absolute_division_Cm(  );                                                % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a relative division subnetwork neuron.
        function Cm = compute_relative_division_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for a relative division subnetwork.
            Cm = neuron_utilities.compute_relative_division_Cm(  );                                                % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a multiplication subnetwork neuron.
        function Cm = compute_multiplication_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for a multiplication subnetwork neuron.
            Cm = neuron_utilities.compute_multiplication_Cm(  );                                                   % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for an absolute multiplication subnetwork neuron.
        function Cm = compute_absolute_multiplication_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for an absolute multiplication subnetwork neuron.
            Cm = neuron_utilities.compute_absolute_multiplication_Cm(  );                                          % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a relative multiplication subnetwork neuron.
        function Cm = compute_relative_multiplication_Cm( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the membrane capacitance for a relative multiplication subnetwork neuron.
            Cm = neuron_utilities.compute_relative_multiplication_Cm(  );                                          % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the first membrane capacitance for a derivation subnetwork neuron.
        function Cm1 = compute_derivation_Cm1( self, Gm, Cm2, k, neuron_utilities  )
            
            % Set the default input arguments.
            if nargin < 5, neuron_utilities = self.neuron_utilities; end
            if nargin < 4, k = self.c_derivation_DEFAULT; end                                                                   % [-] Derivative Subnetwork Gain
            if nargin < 3, Cm2 = 1e-9; end                                                                              % [C] Membrane Capacitance
            if nargin < 2, Gm = self.Gm; end                                                                            % [S] Membrance Conductance
            
            % Compute the first membrane capacitance for a derivation subnetwork neuron.
            Cm1 = neuron_utilities.compute_derivation_Cm1( Gm, Cm2, k );                                           % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the second membrane capacitance for a derivation subnetwork neuron.
        function Cm2 = compute_derivation_Cm2( self, Gm, w, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end
            if nargin < 3, w = self.w_derivation_DEFAULT; end                                                                   % [Hz?] Derivative Subnetwork Cutoff Frequency?
            if nargin < 2, Gm = self.Gm; end                                                                            % [S] Membrane Conductance
            
            % Compute the second membrane capacitance for a derivation subnetwork neuron.
            Cm2 = neuron_utilities.compute_derivation_Cm2( Gm, w );                                                % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for an integration neuron.
        function Cm = compute_integration_Cm( self, ki_mean, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 3, neuron_utilities = self.neuron_utilities; end
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end                                                       % [-] Average Integration Gain
            
            % Compute the membrane capacitance for this integration neuron.
            Cm = neuron_utilities.compute_integration_Cm( ki_mean );                                               % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a voltage based integration neuron.
        function Cm = compute_vb_integration_Cm( self, ki_mean, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 3, neuron_utilities = self.neuron_utilities; end
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end                                                       % [-] Average Integration Gain
            
            % Compute the membrane capacitance for this voltage based integration neuron.
            Cm = neuron_utilities.compute_vb_integration_Cm( ki_mean );                                            % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to first compute the membrane capacitance for a split voltage based integration neuron.
        function Cm = compute_split_vb_integration_Cm1( self, ki_mean, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 3, neuron_utilities = self.neuron_utilities; end
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end                                                       % [-] Average Integration Gain
            
            % Compute the first membrane capacitance for this split voltage based integration neuron.
            Cm = neuron_utilities.compute_split_vb_integration_Cm1( ki_mean );                                     % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to second compute the membrane capacitance for a split voltage based integration neuron.
        function Cm = compute_split_vb_integration_Cm2( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the second membrane capacitance for this split voltage based integration neuron.
            Cm = neuron_utilities.compute_split_vb_integration_Cm2(  );                                            % [C] Membrane Capacitance
            
        end
        
        
        %% Activation Domain Compute Functions
        
        % Implement a function to compute the operational domain of the absolute addition subnetwork input neurons.
        function R = compute_absolute_addition_R_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the operational domain.
            R = neuron_utilities.compute_absolute_addition_R_input(  );                                            % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute addition subnetwork output neurons.
        function R = compute_absolute_addition_R_output( self, Rs, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 3, neuron_utilities = self.neuron_utilities; end
            if nargin < 2, Rs = self.R; end                                                                             % [V] Activation Domain
            
            % Compute the operational domain.
            R = neuron_utilities.compute_absolute_addition_R_output( Rs );                                         % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative addition subnetwork input neurons.
        function R = compute_relative_addition_R_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the operational domain.
            R = neuron_utilities.compute_relative_addition_R_input(  );                                            % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative addition subnetwork output neurons.
        function R = compute_relative_addition_R_output( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the operational domain.
            R = neuron_utilities.compute_relative_addition_R_output(  );                                           % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute subtraction subnetwork input neurons.
        function R = compute_absolute_subtraction_R_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the operational domain.
            R = neuron_utilities.compute_absolute_subtraction_R_input(  );                                         % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute subtraction subnetwork output neurons.
        function R = compute_absolute_subtraction_R_output( self, Rs, s_ks, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end
            if nargin < 3, s_ks = 1; end                                                                                  % [-] Subtraction Sign
            if nargin < 2, Rs = self.R; end                                                                             % [V] Activation Domain
            
            % Compute the operational domain.
            R = neuron_utilities.compute_absolute_subtraction_R_output( Rs, s_ks );                                  % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative subtraction subnetwork input neurons.
        function R = compute_relative_subtraction_R_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the operational domain.
            R = neuron_utilities.compute_relative_subtraction_R_input(  );                                         % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative subtraction subnetwork output neurons.
        function R = compute_relative_subtraction_R_output( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the operational domain.
            R = neuron_utilities.compute_relative_subtraction_R_output(  );                                        % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute inversion subnetwork input neurons.
        function R = compute_absolute_inversion_R_input( self, epsilon, delta, neuron_utilities )
            
            % Define the default input argument.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end
            if nargin < 3, delta = self.delta_DEFAULT; end                                                                              % [V] Output Offset
            if nargin < 2, epsilon = self.epsilon_DEFAULT; end                                                                          % [V] Input Offset
            
            % Compute the operational domain.
            R = neuron_utilities.compute_absolute_inversion_R_input( epsilon, delta );                                             % [V] Activation Domain
            
        end
        
        
        %         % Implement a function to compute the operational domain of the absolute inversion subnetwork output neurons.
        %         function R = compute_absolute_inversion_R_output( self, c, epsilon, neuron_utilities )
        %
        %             % Define the default input arguments.
        %             if nargin < 4, neuron_utilities = self.neuron_utilities; end
        %             if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                          % [-] Subnetwork Offset
        %             if nargin < 2, c = self.c_DEFAULT; end                                                                         % [-] Subnetwork Gain
        %
        %             % Compute the operational domain.
        %             R = neuron_utilities.compute_absolute_inversion_R_output( c, epsilon );                                % [V] Activation Domain
        %
        %         end
        
        
        % Implement a function to compute the operational domain of the absolute inversion subnetwork output neurons.
        function R = compute_absolute_inversion_R_output( self, c, epsilon, delta, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 5, neuron_utilities = self.neuron_utilities; end
            if nargin < 4, delta = self.delta_DEFAULT; end                                                              % [-] Output Offset
            if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                          % [-] Input Offset
            if nargin < 2, c = self.c_DEFAULT; end                                                                      % [-] Subnetwork Gain
            
            % Compute the operational domain.
            R = neuron_utilities.compute_absolute_inversion_R_output( c, epsilon, delta );                          	% [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative inversion subnetwork input neurons.
        function R = compute_relative_inversion_R_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the operational domain.
            R = neuron_utilities.compute_relative_inversion_R_input(  );                                           % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative inversion subnetwork output neurons.
        function R = compute_relative_inversion_R_output( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the operational domain.
            R = neuron_utilities.compute_relative_inversion_R_output(  );                                          % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute division subnetwork input neurons.
        function R = compute_absolute_division_R_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the operational domain.
            R = neuron_utilities.compute_absolute_division_R_input(  );                                            % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute division subnetwork output neurons.
        function R = compute_absolute_division_R_output( self, c, alpha, epsilon, R_numerator, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 6, neuron_utilities = self.neuron_utilities; end
            if nargin < 5, R_numerator = self.R; end                                                                    % [V] Activation Domain
            if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                                          % [-] Subnetwork Offset
            if nargin < 3, alpha = self.alpha_DEFAULT; end                                                              % [-] Subnetwork Denominator Adjustment
            if nargin < 2, c = self.c_DEFAULT; end                                                                    	% [-] Subnetwork Gain
            
            % Compute the operational domain.
            R = neuron_utilities.compute_absolute_division_R_output( c, alpha, epsilon, R_numerator );           	% [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative division subnetwork input neurons.
        function R = compute_relative_division_R_input( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the operational domain.
            R = neuron_utilities.compute_relative_division_R_input(  );                                            % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative division subnetwork output neurons.
        function R = compute_relative_division_R_output( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute the operational domain.
            R = neuron_utilities.compute_relative_division_R_output(  );                                           % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative multiplication subnetwork output neurons.
        function R = compute_relative_multiplication_R_output( self, c, c1, c2, epsilon1, epsilon2, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 7, neuron_utilities = self.neuron_utitlies; end
            if nargin < 6, epsilon2 = self.epsilon_DEFAULT; end                                                         % [-] Division Subnetwork Offset
            if nargin < 5, epsilon1 = self.epsilon_DEFAULT; end                                                         % [-] Inversion Subnetwork Offset
            if nargin < 4, c2 = self.c_DEFAULT; end                                                                        % [-] Division Subnetwork Gain
            if nargin < 3, c1 = self.c_DEFAULT; end                                                                        % [-] Inversion Subnetwork Gain
            if nargin < 2, c = self.c_DEFAULT; end                                                                         % [-] Multiplication Subnetwork Gain
            
            % Compute the operational domain.
            R = neuron_utilities.compute_relative_multiplication_R_output( c, c1, c2, epsilon1, epsilon2 );        % [V] Activation Domain
            
        end
        
        
        %% Current Compute Functions.
        
        % Implement a function to compute the leak current associated with this neuron.
        function I_leak = compute_Ileak( self, U, Gm, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end
            if nargin < 3, Gm = self.Gm; end                                                                            % [S] Membrane Conductance
            if nargin < 2, U = self.U; end                                                                              % [V] Membrane Voltage
            
            % Compute the leak current associated with this neuron.
            I_leak = neuron_utilities.compute_Ileak( U, Gm );                                                      % [A] Leak Current
            
        end
        
        
        % Implement a function to compute the sodium channel current associated with this neuron.
        function I_na = compute_Ina( self, U, Gna, Am, Sm, dEm, Ah, Sh, dEh, dEna, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 11, neuron_utilities = self.neuron_utilities; end
            if nargin < 10, dEna = self.dEna; end                                                                       % [V] Sodium Channel Reversal Potential
            if nargin < 9, dEh = self.dEh; end                                                                          % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 8, Sh = self.Sh; end                                                                            % [-] Sodium Channel Deactivation Slope
            if nargin < 7, Ah = self.Ah; end                                                                            % [-] Sodium Channel Deactivation Amplitude
            if nargin < 6, dEm = self.dEm; end                                                                          % [V] Sodium Channel Activation Reversal Potential
            if nargin < 5, Sm = self.Sm; end                                                                            % [-] Sodium Channel Activation Slope
            if nargin < 4, Am = self.Am; end                                                                            % [-] Sodium Channel Activation Amplitude
            if nargin < 3, Gna = self.Gna; end                                                                          % [S] Sodium Channel Conductance
            if nargin < 2, U = self.U; end                                                                              % [V] Membrane Voltage
            
            % Compute the sodium channel current associated with this neuron.
            I_na = neuron_utilities.compute_Ina( U, Gna, Am, Sm, dEm, Ah, Sh, dEh, dEna );                         % [A] Sodium Channel Current
            
        end
        
        
        % Implement a function to compute the total current associated with this neuron.
        function I_total = compute_Itotal( self, I_leak, I_syn, I_na, I_tonic, I_app, neuron_utilities )
            
            % Define the default input arguments.
            if narign < 7, neuron_utilities = self.neuron_utilities; end
            if nargin < 6, I_app = self.I_app; end                                                                      % [A] Applied Currents
            if nargin < 5, I_tonic = self.I_tonic; end                                                                  % [A] Tonic Current
            if nargin < 4, I_na = self.I_na; end                                                                        % [A] Sodium Channel Current
            if nargin < 3, I_syn = self.I_syn; end                                                                      % [A] Synaptic Current
            if nargin < 2, I_leak = self.I_leak; end                                                                    % [A] Leak Current
            
            % Compute the total current.
            I_total = neuron_utilities.compute_Itotal( I_leak, I_syn, I_na, I_tonic, I_app );                      % [A] Total Current
            
        end
        
        
        %% Sodium Channel Activation & Deactivation Compute & Set Functions
        
        % Implement a function to set the steady state sodium channel activation parameter.
        function self = compute_set_minf( self, U, Am, Sm, dEm, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 6, neuron_utilities = self.neuron_utilities; end
            if nargin < 5, dEm = self.dEm; end                                                                          % [V] Sodium Channel Activation Reversal Potential
            if nargin < 4, Sm = self.Sm; end                                                                            % [-] Sodium Channel Activation Slope
            if nargin < 3, Am = self.Am; end                                                                            % [-] Sodium Channel Activation Amplitude
            if nargin < 2, U = self.U; end                                                                              % [V] Membrane Voltage
            
            % Compute the steady state sodium channel activation parameter.
            self.m_inf = self.compute_minf( U, Am, Sm, dEm, neuron_utilities );                                                           % [-] Steady State Sodium Channel Activation Parameter
            
        end
        
        
        % Implement a function to set the steady state sodium channel deactivation parameter.
        function self = compute_set_hinf( self, U, Ah, Sh, dEh, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 6, neuron_utilities = self.neuron_utilities; end
            if nargin < 5, dEh = self.dEh; end                                                                          % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 4, Sh = self.Sh; end                                                                            % [-] Sodium Channel Deactivation Slope
            if nargin < 3, Ah = self.Ah; end                                                                            % [-] Sodium Channel Deactivation Amplitude
            if nargin < 2, U = self.U; end                                                                              % [V] Membrane Voltage
            
            % Compute the steady state sodium channel deactivaiton parameter.
            self.h_inf = self.compute_hinf( U, Ah, Sh, dEh, neuron_utilities );                                                           % [-] Steady State Sodium Channel Deactivation Parameter
            
        end
        
        
        % Implement a function to compute and set the sodium channel deactivation time constant.
        function self = compute_set_tauh( self, U, tauh_max, h_inf, Ah, Sh, dEh, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 8, neuron_utilities = self.neuron_utilities; end
            if nargin < 7, dEh = self.dEh; end                                                                          % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 6, Sh = self.Sh; end                                                                            % [-] Sodium Channel Deactivation Slope
            if nargin < 5, Ah = self.Ah; end                                                                            % [-] Sodium Channel Deactivation Amplitude
            if nargin < 4, h_inf = self.h_inf; end                                                                      % [-] Steady State Sodium Channel Deactivation Parameter
            if nargin < 3, tauh_max = self.tauh_max; end                                                                % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 2, U = self.U; end                                                                              % [V] Membrane Voltage
            
            % Compute and set the sodium channel deactivation time constant.
            self.tauh = self.compute_tauh( U, tauh_max, h_inf, Ah, Sh, dEh, neuron_utilities );                                           % [s] Sodium Channel Deactivation Time Constant
            
        end
        
        
        %% Sodium Channel Conductance Compute & Set Functions.
        
        % Implement a function to set the sodium channel conductance for a two neuron CPG subnetwork.
        function self = compute_set_cpg_Gna( self, R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 11, neuron_utilities = self.neuron_utilities; end
            if nargin < 10, dEna = self.dEna; end                                                                       % [V] Sodium Channel Reversal Potential
            if nargin < 9, dEh = self.dEh; end                                                                          % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 8, Sh = self.Sh; end                                                                            % [-] Sodium Channel Deactivation Slope
            if nargin < 7, Ah = self.Ah; end                                                                            % [-] Sodium Channel Deactivation Amplitude
            if nargin < 6, dEm = self.dEm; end                                                                          % [V] Sodium Channel Activation Reversal Potential
            if nargin < 5, Sm = self.Sm; end                                                                            % [-] Sodium Channel Activation Slope
            if nargin < 4, Am = self.Am; end                                                                            % [-] Sodium Channel Activation Amplitude
            if nargin < 3, Gm = self.Gm; end                                                                            % [S] Membrane Conductance
            if nargin < 2, R = self.R; end                                                                              % [V] Activation Domain
            
            % Compute and set the sodium channel conductance for a two neuron CPG subnetwork.
            self.Gna = self.compute_cpg_Gna( R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna, neuron_utilities );                                   % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for a driven multistate cpg subnetwork.
        function self = compute_set_driven_multistate_cpg_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute and set the sodium channel conductance for driven multistate cpg subnetwork neurons.
            self.Gna = self.compute_driven_multistate_cpg_Gna( neuron_utilities );                                                       % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for transmission subnetwork neurons.
        function self = compute_set_transmission_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute and set the sodium channel conductance for transmission subnetwork neurons.
            self.Gna = self.compute_transmission_Gna( neuron_utilities );                                                                % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for modulation subnetwork neurons.
        function self = compute_set_modulation_Gna( self, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 2, neuron_utilities = self.neuron_utilities; end
            
            % Compute and set the sodium channel conductance for modulation subnetwork neurons.
            self.Gna = self.compute_modulation_Gna( neuron_utilities );                                                                  % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for addition subnetwork neurons.
        function self = compute_set_addition_Gna( self )
            
            % Compute and set the sodium channel conductance for addition subnetwork neurons.
            self.Gna = self.compute_addition_Gna(  );                                                                    % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for absolute addition subnetwork neurons.
        function self = compute_set_absolute_addition_Gna( self )
            
            % Compute and set the sodium channel conductance for absolute addition subnetwork neurons.
            self.Gna = self.compute_absolute_addition_Gna(  );                                                           % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for relative addition subnetwork neurons.
        function self = compute_set_relative_addition_Gna( self )
            
            % Compute and set the sodium channel conductance for relative addition subnetwork neurons.
            self.Gna = self.compute_relative_addition_Gna(  );                                                           % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for subtraction subnetwork neurons.
        function self = compute_set_subtraction_Gna( self )
            
            % Compute and set the sodium channel conductance for subtraction subnetwork neurons.
            self.Gna = self.compute_subtraction_Gna(  );                                                                 % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for absolute subtraction subnetwork neurons.
        function self = compute_set_absolute_subtraction_Gna( self )
            
            % Compute and set the sodium channel conductance for absolute subtraction subnetwork neurons.
            self.Gna = self.compute_absolute_subtraction_Gna(  );                                                        % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for relative subtraction subnetwork neurons.
        function self = compute_set_relative_subtraction_Gna( self )
            
            % Compute and set the sodium channel conductance for relative subtraction subnetwork neurons.
            self.Gna = self.compute_relative_subtraction_Gna(  );                                                        % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for double subtraction subnetwork neurons.
        function self = compute_set_double_subtraction_Gna( self )
            
            % Compute and set the sodium channel conductance for double subtraction subnetwork neurons.
            self.Gna = self.compute_double_subtraction_Gna(  );                                                          % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for absolute double subtraction subnetwork neurons.
        function self = compute_set_absolute_double_subtraction_Gna( self )
            
            % Compute and set the sodium channel conductance for absolute double subtraction subnetwork neurons.
            self.Gna = self.compute_absolute_double_subtraction_Gna(  );                                                 % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for relative double subtraction subnetwork neurons.
        function self = compute_set_relative_double_subtraction_Gna( self )
            
            % Compute and set the sodium channel conductance for relative double subtraction subnetwork neurons.
            self.Gna = self.compute_relative_double_subtraction_Gna( self );                                             % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for multiplication subnetwork neurons.
        function self = compute_set_multiplication_Gna( self )
            
            % Compute and set the sodium channel conductance for multiplication subnetwork neurons.
            self.Gna = self.compute_multiplication_Gna(  );                                                              % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for absolute multiplication subnetwork neurons.
        function self = compute_set_absolute_multiplication_Gna( self )
            
            % Compute and set the sodium channel conductance for absolute multiplication subnetwork neurons.
            self.Gna = self.compute_absolute_multiplication_Gna(  );                                                     % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for relative multiplication subnetwork neurons.
        function self = compute_set_relative_multiplication_Gna( self )
            
            % Compute and set the sodium channel conductance for relative multiplication subnetwork neurons.
            self.Gna = self.compute_relative_multiplication_Gna(  );                                                    % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for inversion subnetwork neurons.
        function self = compute_set_inversion_Gna( self )
            
            % Compute and set the sodium channel conductance for inversion subnetwork neurons.
            self.Gna = self.compute_inversion_Gna(  );                                                                  % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for absolute inversion subnetwork neurons.
        function self = compute_set_absolute_inversion_Gna( self )
            
            % Compute and set the sodium channel conductance for inversion subnetwork neurons.
            self.Gna = self.compute_absolute_inversion_Gna(  );                                                         % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for relative inversion subnetwork neurons.
        function self = compute_set_relative_inversion_Gna( self )
            
            % Compute and set the sodium channel conductance for relative inversion subnetwork neurons.
            self.Gna = self.compute_relative_inversion_Gna(  );                                                          % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for division subnetwork neurons.
        function self = compute_set_division_Gna( self )
            
            % Compute and set the sodium channel conductance for division subnetwork neurons.
            self.Gna = self.compute_division_Gna(  );                                                                    % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for absolute division subnetwork neurons.
        function self = compute_set_absolute_division_Gna( self )
            
            % Compute and set the sodium channel conductance for absolute division subnetwork neurons.
            self.Gna = self.compute_absolute_division_Gna(  );                                                           % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for relative division subnetwork neurons.
        function self = compute_set_relative_division_Gna( self )
            
            % Compute and set the sodium channel conductance for relative division subnetwork neurons.
            self.Gna = self.compute_relative_division_Gna(  );                                                           % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for derivation subnetwork neurons.
        function self = compute_set_derivation_Gna( self )
            
            % Compute and set the sodium channel conductance for derivation subnetwork neurons.
            self.Gna = self.compute_derivation_Gna(  );                                                                  % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for integration subnetwork neurons.
        function self = compute_set_integration_Gna( self )
            
            % Compute and set the sodium channel conductance for integration subnetwork neurons.
            self.Gna = self.compute_integration_Gna(  );                                                                 % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for voltage based integration subnetwork neurons.
        function self = compute_set_vb_integration_Gna( self )
            
            % Compute and set the sodium channel conductance for voltage based integration subnetwork neurons.
            self.Gna = self.compute_vb_integration_Gna(  );                                                              % [S] Sodium Channel Conductance
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance for split voltage based integration subnetwork neurons.
        function self = compute_set_split_vb_integration_Gna( self )
            
            % Compute and set the sodium channel conductance for split voltage based integration subnetwork neurons.
            self.Gna = self.compute_split_vb_integration_Gna(  );                                                        % [S] Sodium Channel Conductance
            
        end
        
        
        %% Membrane Conductance Compute & Set Functions
        
        % Implement a function to compute the membrance conductance for absolute addition subnetwork input neurons.
        function self = compute_set_absolute_addition_Gm_input( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_absolute_addition_Gm_input(  );                                                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrance conductance for absolute addition subnetwork output neurons.
        function self = compute_set_absolute_addition_Gm_output( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_absolute_addition_Gm_output(  );                                                     % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrance conductance for relative addition subnetwork input neurons.
        function self = compute_set_relative_addition_Gm_input( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_relative_addition_Gm_input(  );                                                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrance conductance for relative addition subnetwork output neurons.
        function self = compute_set_relative_addition_Gm_output( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_relative_addition_Gm_output(  );                                                     % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute subtraction subnetwork input neurons.
        function self = compute_set_absolute_subtraction_Gm_input( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_absolute_subtraction_Gm_input(  );                                                   % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute subtraction subnetwork output neurons.
        function self = compute_set_absolute_subtraction_Gm_output( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_absolute_subtraction_Gm_output(  );                                                  % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative subtraction subnetwork input neurons.
        function self = compute_set_relative_subtraction_Gm_input( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_relative_subtraction_Gm_input(  );                                                   % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative subtraction subnetwork output neurons.
        function self = compute_set_relative_subtraction_Gm_output( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_relative_subtraction_Gm_output(  );                                                  % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute inversion subnetwork input neurons.
        function self = compute_set_absolute_inversion_Gm_input( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_absolute_inversion_Gm_input(  );                                                     % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute inversion subnetwork output neurons.
        function self = compute_set_absolute_inversion_Gm_output( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_absolute_inversion_Gm_output(  );                                                    % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative inversion subnetwork input neurons.
        function self = compute_set_relative_inversion_Gm_input( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_relative_inversion_Gm_input(  );                                                     % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative inversion subnetwork output neurons.
        function self = compute_set_relative_inversion_Gm_output( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_relative_inversion_Gm_output(  );                                                    % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute division subnetwork input neurons.
        function self = compute_set_absolute_division_Gm_input( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_absolute_division_Gm_input(  );                                                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute division subnetwork output neurons.
        function self = compute_set_absolute_division_Gm_output( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_absolute_division_Gm_output(  );                                                     % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative division subnetwork input neurons.
        function self = compute_set_relative_division_Gm_input( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_relative_division_Gm_input(  );                                                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative division subnetwork output neurons.
        function self = compute_set_relative_division_Gm_output( self )
            
            % Compute the membrane conductance.
            self.Gm = self.compute_relative_division_Gm_output(  );                                                     % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute and set the membrane conductance for a derivation neuron.
        function self = compute_set_derivation_Gm( self, k, w, safety_factor )
            
            % Set the default input arugments.
            if nargin < 4, safety_factor = self.sf_derivation_DEFAULT; end                                                      % [-] Derivative Subnetwork Safety Factor
            if nargin < 3, w = self.w_derivation_DEFAULT; end                                                                   % [Hz?] Derviative Subnetwork Cutoff Frequency?
            if nargin < 2, k = self.c_derivation_DEFAULT; end                                                                   % [-] Derivative Subnetwork Gain
            
            % Compute and set the membrane conductance for a derivation neuron.
            self.Gm = self.compute_derivation_Gm( k, w, safety_factor );                                                % [S] Membrane Conductance
            
        end
        
        
        %% Membrane Capacitance Compute & Set Functions
        
        % Implement a function to compute and set the membrane capacitance for a transmission subnetwork neuron.
        function self = compute_set_transmission_Cm( self )
            
            % Compute and set the membrane capacitance for a transmission subnetwork neuron.
            self.Cm = self.compute_transmission_Cm(  );                                                                 % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a slow transmission subnetwork neuron.
        function self = compute_set_slow_transmission_Cm( self, Gm, num_cpg_neurons, T, r )
            
            % Set the default input arguments.
            if nargin < 5, r = self.r_oscillation_DEFAULT; end                                                                  % [-] Oscillation Decay
            if nargin < 4, T = self.T_oscillation_DEFAULT; end                                                                  % [s] Oscillation Period
            if nargin < 3, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                                                  % [#] Number of CPG Neurons
            if nargin < 2, Gm = self.Gm; end                                                                            % [S] Membrane Conductance
            
            % Compute and set the membrane capacitance for a slow transmission subnetwork neuron.
            self.Cm = self.compute_slow_transmission_Cm( Gm, num_cpg_neurons, T, r );                                   % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a modulation subnetwork neuron.
        function self = compute_set_modulation_Cm( self )
            
            % Compute and set the membrane capacitance for a transmission subnetwork neuron.
            self.Cm = self.compute_transmission_Cm(  );                                                                 % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for an addition subnetwork neuron.
        function self = compute_set_addition_Cm( self )
            
            % Compute and set the membrane capacitance for an addition subnetwork neuron.
            self.Cm = self.compute_addition_Cm(  );                                                                      % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for an absolute addition subnetwork neuron.
        function self = compute_set_absolute_addition_Cm( self )
            
            % Compute and set the membrane capacitance for a absolute addition subnetwork neuron.
            self.Cm = self.compute_absolute_addition_Cm(  );                                                             % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a relative addition subnetwork neuron.
        function self = compute_set_relative_addition_Cm( self )
            
            % Compute and set the membrane capacitance for a relative addition subnetwork neuron.
            self.Cm = self.compute_relative_addition_Cm(  );                                                             % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a subtraction subnetwork neuron.
        function self = compute_set_subtraction_Cm( self )
            
            % Compute and set the membrane capacitance for a subtraction subnetwork neuron.
            self.Cm = self.compute_subtraction_Cm(  );                                                                  % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for an absolute subtraction subnetwork neuron.
        function self = compute_set_absolute_subtraction_Cm( self )
            
            % Compute and set the membrane capacitance for an absolute subtraction subnetwork neuron.
            self.Cm = self.compute_absolute_subtraction_Cm(  );                                                         % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a relative subtraction subnetwork neuron.
        function self = compute_set_relative_subtraction_Cm( self )
            
            % Compute and set the membrane capacitance for a relative subtraction subnetwork neuron.
            self.Cm = self.compute_relative_subtraction_Cm(  );                                                          % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a double subtraction subnetwork neuron.
        function self = compute_set_double_subtraction_Cm( self )
            
            % Compute and set the membrane capacitance for a double subtraction subnetwork neuron.
            self.Cm = self.compute_double_subtraction_Cm(  );                                                           % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for an absolute double subtraction subnetwork neuron.
        function self = compute_set_absolute_double_subtraction_Cm( self )
            
            % Compute and set the membrane capacitance for an absolute double subtraction subnetwork neuron.
            self.Cm = self.compute_absolute_double_subtraction_Cm(  );                                                  % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a relative double subtraction subnetwork neuron.
        function self = compute_set_relative_double_subtraction_Cm( self )
            
            % Compute and set the membrane capacitance for a relative double subtraction subnetwork neuron.
            self.Cm = self.compute_relative_double_subtraction_Cm(  );                                                   % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a multiplication subnetwork neuron.
        function self = compute_set_multiplication_Cm( self )
            
            % Compute and set the membrane capacitance for a multiplication subnetwork neuron.
            self.Cm = self.compute_multiplication_Cm(  );                                                                % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for an absolute multiplication subnetwork neuron.
        function self = compute_set_absolute_multiplication_Cm( self )
            
            % Compute and set the membrane capacitance for an absolute multiplication subnetwork neuron.
            self.Cm = self.compute_absolute_multiplication_Cm(  );                                                       % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a relative multiplication subnetwork neuron.
        function self = compute_set_relative_multiplication_Cm( self )
            
            % Compute and set the membrane capacitance for a relative multiplication subnetwork neuron.
            self.Cm = self.compute_relative_multiplication_Cm(  );                                                       % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for an inversion subnetwork neuron.
        function self = compute_set_inversion_Cm( self )
            
            % Compute and set the membrane capacitance for an inversion subnetwork neuron.
            self.Cm = self.compute_inversion_Cm(  );                                                                     % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for an absolute inversion subnetwork neuron.
        function self = compute_set_absolute_inversion_Cm( self )
            
            % Compute and set the membrane capacitance for an absolute inversion subnetwork neuron.
            self.Cm = self.compute_absolute_inversion_Cm(  );                                                            % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a relative inversion subnetwork neuron.
        function self = compute_set_relative_inversion_Cm( self )
            
            % Compute and set the membrane capacitance for a relative inversion subnetwork neuron.
            self.Cm = self.compute_relative_inversion_Cm(  );                                                           % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a division subnetwork neuron.
        function self = compute_set_division_Cm( self )
            
            % Compute and set the membrane capacitance for a division subnetwork neuron.
            self.Cm = self.compute_division_Cm(  );                                                                      % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for an absolute division subnetwork neuron.
        function self = compute_set_absolute_division_Cm( self )
            
            % Compute and set the membrane capacitance for an absolute division subnetwork neuron.
            self.Cm = self.compute_absolute_division_Cm(  );                                                                      % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a relative division subnetwork neuron.
        function self = compute_set_relative_division_Cm( self )
            
            % Compute and set the membrane capacitance for a relative
            self.Cm = self.compute_relative_division_Cm(  );                                                            % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the first membrane capacitance for a derivation subnetwork neuron.
        function self = compute_set_derivation_Cm1( self, Gm, Cm2, k )
            
            % Set the default input arguments.
            if nargin < 4, k = self.c_derivation_DEFAULT; end                                                                   % [-] Derivative Subnetwork Gain
            if nargin < 3, Cm2 = 1e-9; end                                                                              % [F] Membrane Capacitance
            if nargin < 2, Gm = self.Gm; end                                                                            % [S] Membrane Conductance
            
            % Compute and set the first membrane capacitance for a derivation subnetwork neuron.
            self.Cm = self.compute_derivation_Cm1( Gm, Cm2, k  );                                                        % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the second membrane capacitance for a derivation subnetwork neuron.
        function self = compute_set_derivation_Cm2( self, Gm, w )
            
            % Set the default input arguments.
            if nargin < 3, w = self.w_derivation_DEFAULT; end                                                                   % [Hz?] Derivation Subnetwork Cutoff Frequency?
            if nargin < 2, Gm = self.Gm; end                                                                            % [S] Membrane Conductance
            
            % Compute and set the second membrane capacitance for a derivation subnetwork neuron.
            self.Cm = self.compute_derivation_Cm2( Gm, w );                                                             % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for an integration neuron.
        function self = compute_set_integration_Cm( self, ki_mean )
            
            % Set the default input arguments.
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end                                                       % [-] Average Integration Gain
            
            % Compute and set the membrane capacitance for this integration neuron.
            self.Cm = self.compute_integration_Cm( ki_mean );                                                           % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance for a voltage based integration neuron.
        function self = compute_set_vb_integration_Cm( self, ki_mean )
            
            % Set the default input arguments.
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end                                                       % [-] Average Integration Gain
            
            % Compute and set the membrane capacitance for this voltage based integration neuron.
            self.Cm = self.compute_vb_integration_Cm( ki_mean );                                                        % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the first membrane capacitance for a split voltage based integration neuron.
        function self = compute_set_split_vb_integration_Cm1( self, ki_mean )
            
            % Set the default input arguments.
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end                                                       % [-] Average Integration Gain
            
            % Compute and set the first membrane capacitance for this split voltage based integration neuron.
            self.Cm = self.compute_split_vb_integration_Cm1( ki_mean );                                                 % [F] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute and set the second membrane capacitance for a split voltage based integration neuron.
        function self = compute_set_split_vb_integration_Cm2( self )
            
            % Compute and set the second membrane capacitance for this split voltage based integration neuron.
            self.Cm = self.compute_split_vb_integration_Cm2(  );                                                        % [F] Membrane Capacitance
            
        end
        
        
        %% Activation Domain Compute & Set Functions
        
        % Implement a function to compute the operational domain of the absolute addition subnetwork input neurons.
        function self = compute_set_absolute_addition_R_input( self )
            
            % Compute the operational domain.
            self.R = self.compute_absolute_addition_R_input(  );                                                        % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute addition subnetwork output neurons.
        function self = compute_set_absolute_addition_R_output( self, Rs )
            
            % Define the default input arguments.
            if nargin < 2, Rs = self.R; end                                                                             % [V] Activation Domain
            
            % Compute the operational domain.
            self.R = self.compute_absolute_addition_R_output( Rs );                                                     % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative addition subnetwork input neurons.
        function self = compute_set_relative_addition_R_input( self )
            
            % Compute the operational domain.
            self.R = self.compute_relative_addition_R_input(  );                                                        % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative addition subnetwork output neurons.
        function self = compute_set_relative_addition_R_output( self )
            
            % Compute the operational domain.
            self.R = self.compute_relative_addition_R_output(  );                                                       % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute subtraction subnetwork input neurons.
        function self = compute_set_absolute_subtraction_R_input( self )
            
            % Compute the operational domain.
            self.R = self.compute_absolute_subtraction_R_input(  );                                                     % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute subtraction subnetwork output neurons.
        function self = compute_set_absolute_subtraction_R_output( self, Rs, s_ks )
            
            % Define the default input arguments.
            if nargin < 3, s_ks = 1; end                                                                                  % [-] Subtraction Sign
            if nargin < 2, Rs = self.R; end                                                                             % [V] Activation Domain
            
            % Compute the operational domain.
            self.R = self.compute_absolute_subtraction_R_output( Rs, s_ks );                                              % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative subtraction subnetwork input neurons.
        function self = compute_set_relative_subtraction_R_input( self )
            
            % Compute the operational domain.
            self.R = self.compute_relative_subtraction_R_input(  );                                                     % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative subtraction subnetwork output neurons.
        function self = compute_set_relative_subtraction_R_output( self )
            
            % Compute the operational domain.
            self.R = self.compute_relative_subtraction_R_output(  );                                                    % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute inversion subnetwork input neurons.
        function self = compute_set_absolute_inversion_R_input( self, epsilon, delta )
            
            % Define the default input argument.
            if nargin < 3, delta = self.delta_DEFAULT; end                                                                   	% [V] Output Offset
            if nargin < 2, epsilon = self.epsilon_DEFAULT; end                                                                	% [V] Input Offset
            
            % Compute the operational domain.
            self.R = self.compute_absolute_inversion_R_input( epsilon, delta );                                              	% [V] Activation Domain
            
        end
        
        
        %         % Implement a function to compute the operational domain of the absolute inversion subnetwork output neurons.
        %         function self = compute_set_absolute_inversion_R_output( self, c, epsilon )
        %
        %             % Define the default input arguments.
        %             if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                          % [-] Subnetwork Offset
        %             if nargin < 2, c = self.c_DEFAULT; end                                                                         % [-] Subnetwork Gain
        %
        %             % Compute the operational domain.
        %             self.R = self.compute_absolute_inversion_R_output( c, epsilon );                                            % [V] Activation Domain
        %
        %         end
        
        
        % Implement a function to compute the operational domain of the absolute inversion subnetwork output neurons.
        function self = compute_set_absolute_inversion_R_output( self, c, epsilon, delta )
            
            % Define the default input argument.
            if nargin < 4, delta = self.delta_DEFAULT; end                                                                   	% [V] Output Offset
            if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                	% [V] Input Offset
            if nargin < 2, c = self.c_DEFAULT; end                                                                              % [-] Subnetwork Gain
            
            % Compute the operational domain.
            self.R = self.compute_absolute_inversion_R_output( c, epsilon, delta );                                             	% [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative inversion subnetwork input neurons.
        function self = compute_set_relative_inversion_R_input( self )
            
            % Compute the operational domain.
            self.R = self.compute_relative_inversion_R_input(  );                                                       % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative inversion subnetwork output neurons.
        function self = compute_set_relative_inversion_R_output( self )
            
            % Compute the operational domain.
            self.R = self.compute_relative_inversion_R_output(  );                                                      % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute division subnetwork input neurons.
        function self = compute_set_absolute_division_R_input( self )
            
            % Compute the operational domain.
            self.R = self.compute_absolute_division_R_input(  );                                                        % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute division subnetwork output neurons.
        function self = compute_set_absolute_division_R_output( self, c, alpha, epsilon, R_numerator )
            
            % Define the default input arguments.
            if nargin < 4, R_numerator = self.R; end                                                                    % [V] Activation Domain
            if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                          % [-] Subnetwork Offset
            if nargin < 3, alpha = self.alpha_DEFAULT; end                                                              % [-] Subnetwork Denominator Adjustment
            if nargin < 2, c = self.c_DEFAULT; end                                                                     	% [-] Subnetwork Gain
            
            % Compute the operational domain.
            self.R = compute_absolute_division_R_output( self, c, alpha, epsilon, R_numerator );                      	% [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative division subnetwork input neurons.
        function self = compute_set_relative_division_R_input( self )
            
            % Compute the operational domain.
            self.R = self.compute_relative_division_R_input(  );                                                        % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative division subnetwork output neurons.
        function self = compute_set_relative_division_R_output( self )
            
            % Compute the operational domain.
            self.R = self.compute_relative_division_R_output(  );                                                       % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative multiplication subnetwork output neurons.
        function self = compute_set_relative_multiplication_R3( self, c, c1, c2, epsilon1, epsilon2 )
            
            % Define the default input arguments.
            if nargin < 6, epsilon2 = self.epsilon_DEFAULT; end                                                         % [-] Division Subnetwork Offset
            if nargin < 5, epsilon1 = self.epsilon_DEFAULT; end                                                         % [-] Inversion Subnetwork Offset
            if nargin < 4, c2 = self.c_DEFAULT; end                                                                        % [-] Division Subnetwork Gain
            if nargin < 3, c1 = self.c_DEFAULT; end                                                                        % [-] Inversion Subnetwork Gain
            if nargin < 2, c = self.c_DEFAULT; end                                                                         % [-] Multiplication Subnetwork Gain
            
            % Compute the operational domain.
            self.R = self.compute_relative_multiplication_R3( c, c1, c2, epsilon1, epsilon2 );                          % [V] Activation Domain
            
        end
        
        
        %% Current Compute & Set Functions
        
        % Implement a function to compute and set the leak current associated with this neuron.
        function self = compute_set_Ileak( self, U, Gm )
            
            % Define the default input arguments.
            if nargin < 3, Gm = self.Gm; end                                                                            % [S] Membrane Conductance
            if nargin < 2, U = self.U; end                                                                              % [V] Membrane Voltage
            
            % Compute the leak current associated with this neuron.
            self.I_leak = self.compute_Ileak( U, Gm );                                                                   % [A] Leak Current
            
        end
        
        
        % Implement a function to compute and set the sodium channel current associated with this neuron.
        function self = compute_set_Ina( self, U, Gna, Am, Sm, dEm, Ah, Sh, dEh, dEna )
            
            % Define the default input arguments.
            if nargin < 10, dEna = self.dEna; end                                                                       % [V] Sodium Channel Reversal Potential
            if nargin < 9, dEh = self.dEh; end                                                                          % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 8, Sh = self.Sh; end                                                                            % [-] Sodium Channel Deactivation Slope
            if nargin < 7, Ah = self.Ah; end                                                                            % [-] Sodium Channel Deactivation Amplitude
            if nargin < 6, dEm = self.dEm; end                                                                          % [V] Sodium Channel Activation Reversal Potential
            if nargin < 5, Sm = self.Sm; end                                                                            % [-] Sodium Channel Activation Slope
            if nargin < 4, Am = self.Am; end                                                                            % [-] Sodium Channel Activation Amplitude
            if nargin < 3, Gna = self.Gna; end                                                                          % [S] Sodium Channel Conductance
            if nargin < 2, U = self.U; end                                                                              % [V] Membrane Voltage
            
            % Compute the sodium channel current associated with this neuron.
            self.I_na = self.compute_Ina( U, Gna, Am, Sm, dEm, Ah, Sh, dEh, dEna );                                     % [A] Sodium Channel Current
            
        end
        
        
        % Implement a function to compute and set the total current associated with this neuron.
        function self = compute_set_Itotal( self, I_leak, I_syn, I_na, I_tonic, I_app )
            
            % Define the default input arguments.
            if nargin < 6, I_app = self.I_app; end                                                                      % [A] Applied Currents
            if nargin < 5, I_tonic = self.I_tonic; end                                                                  % [A] Tonic Current
            if nargin < 4, I_na = self.I_na; end                                                                        % [A] Sodium Channel Current
            if nargin < 3, I_syn = self.I_syn; end                                                                      % [A] Synaptic Current
            if nargin < 2, I_leak = self.I_leak; end                                                                    % [A] Leak Current
            
            % Compute and set the total current.
            self.I_total = self.compute_Itotal( I_leak, I_syn, I_na, I_tonic, I_app );                                  % [A] Total Current
            
        end
        
        
        %% Enable & Disable Functions
        
        % Implement a function to toogle whether this neuron is enabled.
        function self = toggle_enabled( self )
            
            % Toggle whether the neuron is enabled.
            self.b_enabled = ~self.b_enabled;                                                                            % [T/F] Neuron Enabled Flag
            
        end
        
        
        % Implement a function to enable this neuron.
        function self = enable( self )
            
            % Enable this neuron.
            self.b_enabled = true;                                                                                       % [T/F] Neuron Enabled Flag
            
        end
        
        
        % Implement a function to disable this neuron.
        function self = disable( self )
            
            % Disable this neuron.
            self.b_enabled = false;                                                                                      % [T/F] Neuron Enabled Flag
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save neuron data as a matlab object.
        function save( self, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Neuron.mat'; end                                                                % [-] File Name
            if nargin < 2, directory = '.'; end                                                                         % [-] Directory Path
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];                                                                  % [-] Full Directory Path
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load neuron data as a matlab object.
        function self = load( ~, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Neuron.mat'; end                                                                % [-] File Name
            if nargin < 2, directory = '.'; end                                                                         % [-] Directory Name
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];                                                                  % [-] Full Directory Path
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            self = data.self;
            
        end
        
        
    end
end

