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
        
        minf                                                                                                           % [-] Steady State Sodium Channel Activation Parameter
        hinf                                                                                                           % [-] Steady State Sodium Channel Deactivation Parameter
        
        Ileak                                                                                                          % [A] Leak Current
        Isyn                                                                                                           % [A] Synaptic Current
        Ina                                                                                                            % [A] Sodium Channel Current
        Itonic                                                                                                         % [A] Tonic Current
        Iapp                                                                                                           % [A] Applied Current
        Itotal                                                                                                         % [A] Total Current
        
        enabled_flag                                                                                                       % [-] [T/F] Enable Flag
        
        neuron_utilities                                                                                                % [-] Neuron Utilities Class
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % Define the neuron parameters.
        Cm_DEFAULT = 5e-9;                                                                                              % [C] Membrane Capacitance.
        Gm_DEFAULT = 1e-6;                                                                                              % [S] Membrane Conductance.
        Er_DEFAULT = -60e-3;                                                                                            % [V] Equilibrium Voltage.
        R_DEFAULT = 20e-3;                                                                                              % [V] Activation Domain.
        Am_DEFAULT = 1;                                                                                                 % [-] Sodium Channel Activation Parameter Amplitude.
        Sm_DEFAULT = -50;                                                                                               % [-] Sodium Channel Activation Parameter Slope.
        dEm_DEFAULT = 40e-3;                                                                                            % [V] Sodium Channel Activation Reversal Potential.
        Ah_DEFAULT = 0.5;                                                                                               % [-] Sodium Channel Deactivation Parameter Amplitude.
        Sh_DEFAULT = 50;                                                                                                % [-] Sodium Channel Deactivation Parameter Slope.
        dEh_DEFAULT = 0;                                                                                                % [V] Sodium Channel Deactivation Reversal Potential.
        dEna_DEFAULT = 110e-3;                                                                                          % [V] Sodium Channel Reversal Potential.
        tauh_max_DEFAULT = 0.25;                                                                                        % [s] Maximum Sodium Channel Steady State Time Constant.
        Gna_DEFAULT = 1e-6;                                                                                             % [S] Sodium Channel Conductance.
        Ileak_DEFAULT = 0;                                                                                              % [A] Leak Current.
        Isyn_DEFAULT = 0;                                                                                               % [A] Synaptic Current.
        Ina_DEFAULT = 0;                                                                                                % [A] Sodium Channel Current.
        Itonic_DEFAULT = 0;                                                                                             % [A] Tonic Current.
        Iapp_DEFAULT = 0;                                                                                               % [A] Applied Current.
        Itotal_DEFAULT = 0;                                                                                             % [A] Total Current.
        
        % Define subtraction subnetwork parameters.
        s_ks_DEFAULT = [ 1, -1 ];                                                                                       % [-] Subtraction Input Signature.
        
        % Define derivative subnetwork parameters.
        c_derivation_DEFAULT = 1e6;                                                                                 	% [-] Derivative Gain.
        w_derivation_DEFAULT = 1;                                                                                     	% [Hz?] Derivative Cutoff Frequency?
        sf_derivation_DEFAULT = 0.05;                                                                                 	% [-] Derivative safety Factor.
        
        % Define integration subnetwork parameters.
        c_integration_mean_DEFAULT = 0.01e9;                                                                          	% [-] Average Integration Gain.
        
        % Define centeral pattern generator subnetwork parameters.
        T_oscillation_DEFAULT = 2;                                                                                   	% [s] Oscillation Period.
        r_oscillation_DEFAULT = 0.90;                                                                                  	% [-] Oscillation Decay.
        num_cpg_neurons_DEFAULT = 2;                                                                                  	% [#} Number of CPG Neurons.
        
        % Define inversion & division subnetwork parameters.
        c_DEFAULT = 1;                                                                                                 	% [-] General Subnetwork Gain.
        epsilon_DEFAULT = 1e-6;                                                                                        	% [-] Subnetwork Input Offset.
        delta_DEFAULT = 1e-6;                                                                                          	% [-] Subnetwork Output Offset.
        alpha_DEFAULT = 1e-6;                                                                                           % [-] Subnetwork Denominator Adjustment.
        
        % Define the default encoding scheme.
        encoding_scheme_DEFAULT = 'Absolute';                                                                           % [str] Encoding Scheme.
        
        % Define the default flags.
        enabled_flag_DEFAULT = true;                                                                                    % [T/F] Enabled Flag.
        set_flag_DEFAULT = true;                                                                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
        
    end
    
    
    %% NEURON METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neuron_class( ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, Ileak, Isyn, Ina, Itonic, Iapp, Itotal, enabled_flag, neuron_utilities )
            
            % Set the default neuron properties.
            if nargin < 25, neuron_utilities = neuron_utilities_class(  ); end      % [class] Neuron Utilities Class.
            if nargin < 24, enabled_flag = self.enabled_flag_DEFAULT; end           % [T/F] Enable Flag.
            if nargin < 23, Itotal = self.Itotal_DEFAULT; end                      % [A] Total Current.
            if nargin < 22, Iapp = self.Iapp_DEFAULT; end                          % [A] Applied Current.
            if nargin < 21, Itonic = self.Itonic_DEFAULT; end                      % [A] Tonic Current.
            if nargin < 20, Ina = self.Ina_DEFAULT; end                            % [A] Sodium Channel Current.
            if nargin < 19, Isyn = self.Isyn_DEFAULT; end                         	% [A] Synaptic Current.
            if nargin < 18, Ileak = self.Ileak_DEFAULT; end                        % [A] Leak Current.
            if nargin < 17, Gna = self.Gna_DEFAULT; end                             % [S] Sodium Channel Conductance.
            if nargin < 16, tauh_max = self.tauh_max_DEFAULT; end                   % [s] Maximum Sodium Channel Deactivation Time Constant.
            if nargin < 15, dEna = self.dEna_DEFAULT; end                           % [V] Sodium Channel Reveral Potential.
            if nargin < 14, dEh = self.dEh_DEFAULT; end                             % [V] Sodium Channel Deactivation Reversal Potential.
            if nargin < 13, Sh = self.Sh_DEFAULT; end                               % [V] Sodium Channel Deacitvation Slope.
            if nargin < 12, Ah = self.Ah_DEFAULT; end                               % [V] Sodium Channel Deactivation Amplitude.
            if nargin < 11, dEm = self.dEm_DEFAULT; end                             % [V] Sodium Channel Activation Reversal Potential.
            if nargin < 10, Sm = self.Sm_DEFAULT; end                               % [V] Sodium Channel Activation Slope.
            if nargin < 9, Am = self.Am_DEFAULT; end                                % [V] Sodium Channel Activation Amplitude.
            if nargin < 8, R = self.R_DEFAULT; end                                  % [V] Activation Domain.
            if nargin < 7, Er = self.Er_DEFAULT; end                                % [V] Membrane Reversal Potential.
            if nargin < 6, Gm = self.Gm_DEFAULT; end                                % [S] Membrane Conductance.
            if nargin < 5, Cm = self.Cm_DEFAULT; end                                % [C] Membrane Capacitance.
            if nargin < 4, h = [  ]; end                                            % [-] Sodium Channel Deactivation.
            if nargin < 3, U = 0; end                                               % [V] Membrane Voltage.
            if nargin < 2, name = ''; end                                           % [-] Neuron Name.
            if nargin < 1, ID = 0; end                                              % [#] ID Number.
            
            % Store an instance of the neuron utilities class.
            self.neuron_utilities = neuron_utilities;
            
            % Store whether this neuron is active.
            self.enabled_flag = enabled_flag;
            
            % Store the current properties.
            self.Itotal = Itotal;
            self.Iapp = Iapp;
            self.Itonic = Itonic;
            self.Ina = Ina;
            self.Isyn = Isyn;
            self.Ileak = Ileak;
            
            % Store the ion channel properties.
            self.Gna = Gna;
            self.tauh_max = tauh_max;
            self.dEna = dEna;
            self.dEh = dEh;
            self.Sh = Sh;
            self.Ah = Ah;
            self.dEm = dEm;
            self.Sm = Sm;
            self.Am = Am;
            
            % Store the membrane properties.
            self.R = R;
            self.Er = Er;
            self.Gm = Gm;
            self.Cm = Cm;
            
            % Store the neuron states.
            self.h = h;
            self.U = U;
            
            % Store the neuron identification information.
            self.name = name;
            self.ID = ID;
            
            % Compute the steady state sodium channel activation and deactivation parameters.
            [ ~, self ] = self.compute_minf( U, Am, Sm, dEm, true, neuron_utilities );                      % [-] Steady State Sodium Channel Activation Parameter
            [ hinf, self ] = self.compute_hinf( U, Ah, Sh, dEh, true, neuron_utilities );                  % [-] Steady State Sodium Channel Deactivation Parameter
            
            % Determine whether to set the sodium channel activation parameter to its steady state value.
            if isempty( self.h ), self.h = hinf; end                                                     	% [-] Steady State Sodium Channel Deactivation Parameter
            
            % Compute and set the sodium channel deactivation time constant.
            [ ~, self ] = self.compute_tauh( U, tauh_max, hinf, Ah, Sh, dEh, true, neuron_utilities );     % [-] Sodium Channel Deactivation Time Constant                                                                         
            
        end
        
        
        %% Sodium Channel Activation & Deactivation Compute Functions.
        
        % Implement a function to compute the steady state sodium channel activation parameter.
        function [ minf, self ] = compute_minf( self, U, Am, Sm, dEm, set_flag, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 7, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 5, dEm = self.dEm; end                                                          % [V] Sodium Channel Activation Reversal Potential.
            if nargin < 4, Sm = self.Sm; end                                                         	% [-] Sodium Channel Activation Slope.
            if nargin < 3, Am = self.Am; end                                                         	% [-] Sodium Channel Activation Amplitude.
            if nargin < 2, U = self.U; end                                                           	% [V] Membrane Voltage.
            
            % Compute the steady state sodium channel activation parameter.
            minf = neuron_utilities.compute_mhinf( U, Am, Sm, dEm );                                	% [-] Sodium Channel Activation Parameter.
            
            % Determine whether to update the neuron object.
            if set_flag, self.minf = minf; end
            
        end
        
        
        % Implement a function to compute the steady state sodium channel deactivation parameter.
        function [ hinf, self ] = compute_hinf( self, U, Ah, Sh, dEh, set_flag, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 7, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)                 
            if nargin < 5, dEh = self.dEh; end                                                                          % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 4, Sh = self.Sh; end                                                                            % [-] Sodium Channel Deactivation Slope
            if nargin < 3, Ah = self.Ah; end                                                                            % [-] Sodium Channel Deactivation Amplitude
            if nargin < 2, U = self.U; end                                                                              % [V] Membrane Voltage
            
            % Compute the steady state sodium channel deactivaiton parameter.
            hinf = neuron_utilities.compute_mhinf( U, Ah, Sh, dEh );                                              % [-] Sodium Channel Deactivation Parameter
            
            % Determine whether to update the neuron object.
            if set_flag, self.hinf = hinf; end
            
        end
        
        
        % Implement a function to compute the sodium channel deactivation time constant.
        function [ tauh, self ] = compute_tauh( self, U, tauh_max, hinf, Ah, Sh, dEh, set_flag, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 9, neuron_utilities = self.neuron_utilities; end                     	% [class] Neuron Utilities.
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 7, dEh = self.dEh; end                                              	% [V] Sodium Channel Deactivation Reversal Potential.
            if nargin < 6, Sh = self.Sh; end                                                	% [-] Sodium Channel Deactivation Slope.
            if nargin < 5, Ah = self.Ah; end                                                    % [-] Sodium Channel Deactivation Amplitude.
            if nargin < 4, hinf = self.hinf; end                                              % [-] Steady State Sodium Channel Deactivation Parameter.
            if nargin < 3, tauh_max = self.tauh_max; end                                        % [s] Maximum Sodium Channel Deactivation Time Constant.
            if nargin < 2, U = self.U; end                                                      % [V] Membrane Voltage.
            
            % Compute the sodium channel deactivation time constant.
            tauh = neuron_utilities.compute_tauh( U, tauh_max, hinf, Ah, Sh, dEh );            % [s] Sodium Channel Deactivation Time Constant.
            
            % Determine whether to update the neuron object.
            if set_flag, self.tauh = tauh; end
            
        end
        
        
        %% Sodium Channel Conductance Compute Functions.
        
        % Implement a function to compute the required sodium channel conductance for a transmission subnetwork neuron.
        function [ Gna, self ] = compute_transmission_Gna( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end             	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                      	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the sodium channel conductance for this transmission subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is set to absolute...

                % Compute the sodium channel conductance for this neuron assuming that it belongs to an absolue transmission subnetwork.
                Gna = neuron_utilities.compute_absolute_transmission_Gna(  );           % [S] Sodium Channel Conductance.
            
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is set to relative...
            
                % Compute the sodium channel conductance for this neuron assuming that it belongs to a relative transmission subnetwork.
                Gna = neuron_utilities.compute_relative_transmission_Gna(  );           % [S] Sodium Channel Conductance.

            else                                                                        % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a modulation subnetwork neuron.
        function [ Gna, self ] = compute_modulation_Gna( self, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 3, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 2, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            
            % Compute the sodium channel conductance for a modulation subnetwork neuron.
            Gna = neuron_utilities.compute_modulation_Gna(  );                                          % [S] Sodium Channel Conductance
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for an addition subnetwork neuron.
        function [ Gna, self ] = compute_addition_Gna( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                 	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                          	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the sodium channel conductance for this addition subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the sodium channel conductance for this neuron assuming that it belongs to an absolue addition subnetwork.
                Gna = neuron_utilities.compute_absolute_addition_Gna(  );                   % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the sodium channel conductance for this neuron assuming that it belongs to a relative addition subnetwork.
                Gna = neuron_utilities.compute_relative_addition_Gna(  );                   % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a subtraction subnetwork neuron.
        function [ Gna, self ] = compute_subtraction_Gna( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                 	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                           	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the sodium channel conductance for this subtraction subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the sodium channel conductance for this neuron assuming that it belongs to an absolue subtraction subnetwork.
                Gna = neuron_utilities.compute_absolute_subtraction_Gna(  );                % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the sodium channel conductance for this neuron assuming that it belongs to a relative subtraction subnetwork.
                Gna = neuron_utilities.compute_relative_subtraction_Gna(  );                % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        

        % Implement a function to compute the required sodium channel conductance for a double subtraction subnetwork neuron.
        function [ Gna, self ] = compute_double_subtraction_Gna( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                 	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                          	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the sodium channel conductance for this double subtraction subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the sodium channel conductance for this neuron assuming that it belongs to an absolue double subtraction subnetwork.
                Gna = neuron_utilities.compute_absolute_double_subtraction_Gna(  );         % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the sodium channel conductance for this neuron assuming that it belongs to a relative double subtraction subnetwork.
                Gna = neuron_utilities.compute_relative_double_subtraction_Gna(  );         % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a multiplication subnetwork neuron.
        function [ Gna, self ] = compute_multiplication_Gna( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                   	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                         	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the sodium channel conductance for this multiplication subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the sodium channel conductance for this neuron assuming that it belongs to an absolue multiplication subnetwork.
                Gna = neuron_utilities.compute_absolute_multiplication_Gna(  );             % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the sodium channel conductance for this neuron assuming that it belongs to a relative multiplication subnetwork.
                Gna = neuron_utilities.compute_relative_multiplication_Gna(  );             % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        
      
        % Implement a function to compute the required sodium channel conductance for an inversion subnetwork neuron.
        function [ Gna, self ] = compute_inversion_Gna( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                           	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the sodium channel conductance for this inversion subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the sodium channel conductance for this neuron assuming that it belongs to an absolue inversion subnetwork.
                Gna = neuron_utilities.compute_absolute_inversion_Gna(  );                  % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the sodium channel conductance for this neuron assuming that it belongs to a relative inversion subnetwork.
                Gna = neuron_utilities.compute_relative_inversion_Gna(  );                  % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a division subnetwork neuron.
        function [ Gna, self ] = compute_division_Gna( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                  	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                          	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the sodium channel conductance for this inversion subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the sodium channel conductance for this neuron assuming that it belongs to an absolue division subnetwork.
                Gna = neuron_utilities.compute_absolute_division_Gna(  );                   % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the sodium channel conductance for this neuron assuming that it belongs to a relative division subnetwork.
                Gna = neuron_utilities.compute_relative_division_Gna(  );                   % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        
                
        % Implement a function to compute the required sodium channel conductance for a derivation subnetwork neuron.
        function [ Gna, self ] = compute_derivation_Gna( self, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 3, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 2, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            
            % Compute the sodium channel conductance for a derivation subnetwork neuron.
            Gna = neuron_utilities.compute_derivation_Gna(  );                                      	% [S] Sodium Channel Conductance
           
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for an integration subnetwork neuron.
        function [ Gna, self ] = compute_integration_Gna( self, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 3, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 2, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            
            % Compute the sodium channel conductance for an integration subnetwork neuron.
            Gna = neuron_utilities.compute_integration_Gna(  );                                      	% [S] Sodium Channel Conductance
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a voltage based integration subnetwork neuron.
        function [ Gna, self ] = compute_vbi_Gna( self, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 3, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 2, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            
            % Compute the sodium channel conductance for a voltage based integration subnetwork neuron.
            Gna = neuron_utilities.compute_vbi_Gna(  );                                                 % [S] Sodium Channel Conductance
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance for a split voltage based integration subnetwork neuron.
        function [ Gna, self ] = compute_svbi_Gna( self, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 3, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 2, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            
            % Compute the sodium channel conductance for a split voltage based integration subnetwork neuron.
            Gna = neuron_utilities.compute_svbi_Gna(  );                                                % [S] Sodium Channel Conductance
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        
        
        % Implement a function to compute the required sodium channel conductance to create oscillation in a CPG subnetwork.
        function [ Gna, self ] = compute_cpg_Gna( self, R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna, set_flag, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 12, neuron_utilities = self.neuron_utilities; end                                               % [class] Neuron Utilities.
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end                                                   	% [T/F] Set Flag (Determines whether to update the neuron object.)
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
            Gna = neuron_utilities.compute_cpg_Gna( R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna );                            % [S] Sodium Channel Conductance
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end

        end
        
        
        % Implement a function to compute the required sodium channel conductance for a driven multistate cpg subnetwork neuron.
        function [ Gna, self ] = compute_dmcpg_Gna( self, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 3, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 2, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)

            % Compute the sodium channel conductance for a driven multistate cpg subnetwork neuron.
            Gna = neuron_utilities.compute_dmcpg_Gna(  );                                               % [S] Sodium Channel Conductance
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gna = Gna; end
            
        end
        
        
        %% Membrane Conductance Compute Functions.
        
        % Implement a function to compute the membrance conductance for addition subnetwork input neurons.
        function [ Gm, self ] = compute_addition_Gm_input( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                  	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                        	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane conductance for this addition subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane conductance for this neuron assuming that it is an input to an absolue addition subnetwork.
                Gm = neuron_utilities.compute_absolute_addition_Gm_input(  );               % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the membrane conductance for this neuron assuming that it is an input to a relative addition subnetwork.
                Gm = neuron_utilities.compute_relative_addition_Gm_input(  );               % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gm = Gm; end
            
        end
        
        
        % Implement a function to compute the membrance conductance for addition subnetwork output neurons.
        function [ Gm, self ] = compute_addition_Gm_output( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                   	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                          	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane conductance for this addition subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane conductance for this neuron assuming that it is an output to an absolue addition subnetwork.
                Gm = neuron_utilities.compute_absolute_addition_Gm_output(  );              % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the membrane conductance for this neuron assuming that it is an output to a relative addition subnetwork.
                Gm = neuron_utilities.compute_relative_addition_Gm_output(  );              % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gm = Gm; end
            
        end
        
        
        % Implement a function to compute the membrance conductance for subtraction subnetwork input neurons.
        function [ Gm, self ] = compute_subtraction_Gm_input( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                   	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                           	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane conductance for this subtraction subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane conductance for this neuron assuming that it is an input to an absolue subtraction subnetwork.
                Gm = neuron_utilities.compute_absolute_subtraction_Gm_input(  );            % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the membrane conductance for this neuron assuming that it is an input to a relative subtraction subnetwork.
                Gm = neuron_utilities.compute_relative_subtraction_Gm_input(  );            % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gm = Gm; end
            
        end
        
        
        % Implement a function to compute the membrance conductance for subtraction subnetwork output neurons.
        function [ Gm, self ] = compute_subtraction_Gm_output( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                        	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane conductance for this subtraction subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane conductance for this neuron assuming that it is an input to an absolue subtraction subnetwork.
                Gm = neuron_utilities.compute_absolute_subtraction_Gm_output(  );           % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the membrane conductance for this neuron assuming that it is an input to a relative subtraction subnetwork.
                Gm = neuron_utilities.compute_relative_subtraction_Gm_output(  );           % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gm = Gm; end
            
        end
        

        % Implement a function to compute the membrance conductance for inversion subnetwork input neurons.
        function [ Gm, self ] = compute_inversion_Gm_input( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                  	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                          	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane conductance for this inversion subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane conductance for this neuron assuming that it is an input to an absolue inversion subnetwork.
                Gm = neuron_utilities.compute_absolute_inversion_Gm_input(  );              % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the membrane conductance for this neuron assuming that it is an input to a relative inversion subnetwork.
                Gm = neuron_utilities.compute_relative_inversion_Gm_input(  );              % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gm = Gm; end
            
        end
        
        
        % Implement a function to compute the membrance conductance for inversion subnetwork output neurons.
        function [ Gm, self ] = compute_inversion_Gm_output( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                          	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane conductance for this inversion subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane conductance for this neuron assuming that it is an output to an absolue inversion subnetwork.
                Gm = neuron_utilities.compute_absolute_inversion_Gm_output(  );             % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the membrane conductance for this neuron assuming that it is an output to a relative inversion subnetwork.
                Gm = neuron_utilities.compute_relative_inversion_Gm_output(  );             % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gm = Gm; end
            
        end
        
        
        % Implement a function to compute the membrance conductance for division subnetwork input neurons.
        function [ Gm, self ] = compute_division_Gm_input( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                  	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                           	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane conductance for this division subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane conductance for this neuron assuming that it is an input to an absolue division subnetwork.
                Gm = neuron_utilities.compute_absolute_division_Gm_input(  );               % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the membrane conductance for this neuron assuming that it is an input to a relative division subnetwork.
                Gm = neuron_utilities.compute_relative_division_Gm_input(  );               % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gm = Gm; end
            
        end
        
        
        % Implement a function to compute the membrance conductance for division subnetwork output neurons.
        function [ Gm, self ] = compute_division_Gm_output( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane conductance for this division subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane conductance for this neuron assuming that it is an output to an absolue division subnetwork.
                Gm = neuron_utilities.compute_absolute_division_Gm_output(  );              % [S] Sodium Channel Conductance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                 	% If the encoding scheme is set to relative...
            
                % Compute the membrane conductance for this neuron assuming that it is an output to a relative division subnetwork.
                Gm = neuron_utilities.compute_relative_division_Gm_output(  );              % [S] Sodium Channel Conductance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gm = Gm; end
            
        end
        

        % Implement a function to compute the required membrane conductance for a derivation neuron.
        function [ Gm, self ] = compute_derivation_Gm( self, k, w, safety_factor, set_flag, neuron_utilities )
            
            % Set the default input arugments.
            if nargin < 6, neuron_utilities = self.neuron_utilities; end                 	% [class] Neuron Utilities.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                          	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 4, safety_factor = self.sf_derivation_DEFAULT; end               	% [-] Derivation Subnetwork Safety Factor.
            if nargin < 3, w = self.w_derivation_DEFAULT; end                             	% [Hz?] Derivation Subnetwork Cutoff Frequency?
            if nargin < 2, k = self.c_derivation_DEFAULT; end                             	% [-] Derivation Subnetwork Gain.
            
            % Compute the membrane conductance for this derivation neuron.
            Gm = neuron_utilities.compute_derivation_Gm( k, w, safety_factor );             % [S] Membrane Conductance.
            
            % Determine whether to update the neuron object.
            if set_flag, self.Gm = Gm; end
            
        end
        
        
        %% Membrane Capacitance Compute Functions.
        
        % Implement a function to compute the required membrane capacitance for a transmission subnetwork neuron.
        function [ Cm, self ] = compute_transmission_Cm( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end         	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                 	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end     	% [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane capacitance for this transmission subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                               % If the encoding scheme is set to absolute...

                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue transmission subnetwork.
                Cm = neuron_utilities.compute_absolute_transmission_Cm(  );         % [C] Membrane Capacitance
            
            elseif strcmpi( encoding_scheme, 'relative' )                           % If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative transmission subnetwork.
                Cm = neuron_utilities.compute_relative_transmission_Cm(  );         % [C] Membrane Capacitance

            else                                                                    % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a transmission subnetwork neuron.
        function [ Cm, self ] = compute_slow_transmission_Cm( self, Gm, num_cpg_neurons, T, r, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 8, neuron_utilities = self.neuron_utilities; end                                                        % [class] Neuron Utilities.
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                                % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 6, encoding_scheme = self.encoding_scheme_DEFAULT; end                                                  % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            if nargin < 5, r = self.r_oscillation_DEFAULT; end                                                                  % [-] Oscillation Decay
            if nargin < 4, T = self.T_oscillation_DEFAULT; end                                                                  % [s] Oscillation Period
            if nargin < 3, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                                                  % [#] Number of CPG Neurons
            if nargin < 2, Gm = self.Gm; end                                                                                    % [S] Membrane Conductance
            
            % Determine how to compute the membrane capacitance for this transmission subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                                                           % If the encoding scheme is set to absolute...

                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue transmission subnetwork.
                Cm = neuron_utilities.compute_slow_absolute_transmission_Cm( Gm, num_cpg_neurons, T, r );                       % [C] Membrane Capacitance

            elseif strcmpi( encoding_scheme, 'relative' )                                                                   	% If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative transmission subnetwork.
                Cm = neuron_utilities.compute_slow_relative_transmission_Cm( Gm, num_cpg_neurons, T, r );                       % [C] Membrane Capacitance

            else                                                                                                                % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a modulation subnetwork neuron.
        function [ Cm, self ] = compute_modulation_Cm( self, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 3, neuron_utilities = self.neuron_utilities; end                                            % [class] Neuron Utilities.
            if nargin < 2, set_flag = self.set_flag_DEFAULT; end                                                    % [T/F] Set Flag (Determines whether to update the neuron object.)
            
            % Compute the membrane capacitance for a modulation subnetwork neuron.
            Cm = neuron_utilities.compute_modulation_Cm(  );                                                        % [C] Membrane Capacitance
           
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance for an addition subnetwork neuron.
        function [ Cm, self ] = compute_addition_Cm( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                          	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane capacitance for this addition subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue addition subnetwork.
                Cm = neuron_utilities.compute_absolute_addition_Cm(  );                     % [C] Membrane Capacitance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative addition subnetwork.
                Cm = neuron_utilities.compute_relative_addition_Cm(  );                     % [C] Membrane Capacitance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a subtraction subnetwork neuron.
        function [ Cm, self ] = compute_subtraction_Cm( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                   	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                         	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane capacitance for this subtraction subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue subtraction subnetwork.
                Cm = neuron_utilities.compute_absolute_subtraction_Cm(  );                  % [C] Membrane Capacitance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                 	% If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative subtraction subnetwork.
                Cm = neuron_utilities.compute_relative_subtraction_Cm(  );                  % [C] Membrane Capacitance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        

        % Implement a function to compute the membrane capacitance for a double subtraction subnetwork neuron.
        function [ Cm, self ] = compute_double_subtraction_Cm( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                   	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                           	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane capacitance for this double subtraction subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue double subtraction subnetwork.
                Cm = neuron_utilities.compute_absolute_double_subtraction_Cm(  );           % [C] Membrane Capacitance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative double subtraction subnetwork.
                Cm = neuron_utilities.compute_relative_double_subtraction_Cm(  );           % [C] Membrane Capacitance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance for an inversion subnetwork neuron.
        function [ Cm, self ] = compute_inversion_Cm( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                  	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                          	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane capacitance for this inversion subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue inversion subnetwork.
                Cm = neuron_utilities.compute_absolute_inversion_Cm(  );                    % [C] Membrane Capacitance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                  	% If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative inversion subnetwork.
                Cm = neuron_utilities.compute_relative_inversion_Cm(  );                    % [C] Membrane Capacitance

            else                                                                          	% Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        

        % Implement a function to compute the membrane capacitance for a division subnetwork neuron.
        function [ Cm, self ] = compute_division_Cm( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                  	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                         	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane capacitance for this division subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue division subnetwork.
                Cm = neuron_utilities.compute_absolute_division_Cm(  );                     % [C] Membrane Capacitance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative division subnetwork.
                Cm = neuron_utilities.compute_relative_division_Cm(  );                     % [C] Membrane Capacitance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a multiplication subnetwork neuron.
        function [ Cm, self ] = compute_multiplication_Cm( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                  	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                           	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane capacitance for this multiplication subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue multiplication subnetwork.
                Cm = neuron_utilities.compute_absolute_multiplication_Cm(  );               % [C] Membrane Capacitance
            
            elseif strcmpi( encoding_scheme, 'relative' )                                 	% If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative multiplication subnetwork.
                Cm = neuron_utilities.compute_relative_multiplication_Cm(  );               % [C] Membrane Capacitance

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        
        
        % Implement a function to compute the first membrane capacitance for a derivation subnetwork neuron.
        function [ Cm1, self ] = compute_derivation_Cm1( self, Gm, Cm2, k, set_flag, neuron_utilities  )
            
            % Set the default input arguments.
            if nargin < 6, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 4, k = self.c_derivation_DEFAULT; end                                          	% [-] Derivative Subnetwork Gain.
            if nargin < 3, Cm2 = 1e-9; end                                                            	% [C] Membrane Capacitance.
            if nargin < 2, Gm = self.Gm; end                                                         	% [S] Membrance Conductance.
            
            % Compute the first membrane capacitance for a derivation subnetwork neuron.
            Cm1 = neuron_utilities.compute_derivation_Cm1( Gm, Cm2, k );                              	% [C] Membrane Capacitance.
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm1; end
            
        end
        
        
        % Implement a function to compute the second membrane capacitance for a derivation subnetwork neuron.
        function [ Cm2, self ] = compute_derivation_Cm2( self, Gm, w, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 5, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 3, w = self.w_derivation_DEFAULT; end                                          	% [Hz?] Derivative Subnetwork Cutoff Frequency?
            if nargin < 2, Gm = self.Gm; end                                                          	% [S] Membrane Conductance.
            
            % Compute the second membrane capacitance for a derivation subnetwork neuron.
            Cm2 = neuron_utilities.compute_derivation_Cm2( Gm, w );                                  	% [C] Membrane Capacitance.
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm2; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance for an integration neuron.
        function [ Cm, self ] = compute_integration_Cm( self, ki_mean, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end                             	% [-] Average Integration Gain
            
            % Compute the membrane capacitance for this integration neuron.
            Cm = neuron_utilities.compute_integration_Cm( ki_mean );                                  	% [C] Membrane Capacitance
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance for a voltage based integration neuron.
        function [ Cm, self ] = compute_vbi_Cm( self, ki_mean, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end                             	% [-] Average Integration Gain
            
            % Compute the membrane capacitance for this voltage based integration neuron.
            Cm = neuron_utilities.compute_vbi_Cm( ki_mean );                                            % [C] Membrane Capacitance
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        
        
        % Implement a function to first compute the membrane capacitance for a split voltage based integration neuron.
        function [ Cm, self ] = compute_svbi_Cm1( self, ki_mean, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end                              	% [-] Average Integration Gain
            
            % Compute the first membrane capacitance for this split voltage based integration neuron.
            Cm = neuron_utilities.compute_svbi_Cm1( ki_mean );                                          % [C] Membrane Capacitance
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        
        
        % Implement a function to second compute the membrane capacitance for a split voltage based integration neuron.
        function [ Cm, self ] = compute_svbi_Cm2( self, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 3, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 2, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            
            % Compute the second membrane capacitance for this split voltage based integration neuron.
            Cm = neuron_utilities.compute_svbi_Cm2(  );                                                 % [C] Membrane Capacitance
            
            % Determine whether to update the neuron object.
            if set_flag, self.Cm = Cm; end
            
        end
        
        
        %% Parameter Unpacking Functions.
        
        % Implement a function to unpack the parameters required to compute the absolute addition output activation domain.
        function Rs = unpack_absolute_addition_R_output_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end                       % [-] Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                    % If the parameters are empty...
                
                % Set the parameters to default values.
                Rs = self.R_DEFAULT*ones( 1, 2 );                    	% [V] Activation Domain
                
            elseif length( parameters ) == 1                          	% If there are a specific number of parameters...
                
                % Unpack the parameters.
                Rs = parameters{ 1 };                                	% [V] Activation Domain
                
            else                                                     	% Otherwise...
                
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end
            
        end
        
    
        % Implement a function to unpack the parameters required to compute the absolute subtraction output activation domain.
        function [ Rs, s_ks ] = unpack_absolute_subtraction_R_output_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end                       % [-] Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                    % If the parameters are empty...
                
                % Set the parameters to default values.
                Rs = self.R_DEFAULT*ones( 1, 2 );                       % [V] Activation Domain.
                s_ks = self.s_ks_DEFAULT;                               % [-] Subtraction Signature.
                    
            elseif length( parameters ) == 2                            % If there are a specific number of parameters...
                
                % Unpack the parameters.
                Rs = parameters{ 1 };                                   % [V] Activation Domain.
                s_ks = parameters{ 2 };                                 % [-] Subtraction Signature.
                                    
            else                                                        % Otherwise...
                
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end
            
        end
        
        
        % Implement a function to unpack the parameters required to compute the absolute inversion input activation domain.
        function [ epsilon, delta ] = unpack_absolute_inversion_R_input_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end                	% [-] Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                % If the parameters are empty...

                % Set the default parameters.
                epsilon = self.epsilon_DEFAULT;                  	% [-] Subnetwork Input Offset
                delta = self.delta_DEFAULT;                       	% [-] Subnetwork Output Offset

            elseif length( parameters ) == 1                     	% If there are a specific number of parameters...

                % Retrieve the parameters.
                epsilon = parameters{ 1 };                       	% [-] Subnetwork Input Offset
                delta = parameters{ 2 };                         	% [-] Subnetwork Output Offset

            else                                                  	% Otherwise...
                
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end            
            
        end
        
        
        % Implement a function to unpack the parameters required to compute the absolute inversion output activation domain.
        function [ c, epsilon, delta ] = unpack_absolute_inversion_R_output_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end                   % [-] Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                % If the parameters are empty...

                % Set the default parameters.
                c = self.c_DEFAULT;                              	% [-] General Subnetwork Gain
                epsilon = self.epsilon_DEFAULT;                  	% [-] Subnetwork Input Offset
                delta = self.delta_DEFAULT;                       	% [-] Subnetwork Output Offset

            elseif length( parameters ) == 1                     	% If there are a specific number of parameters...

                % Retrieve the parameters.
                c = parameters{ 1 };                            	% [-] General Subnetwork Gain
                epsilon = parameters{ 2 };                        	% [-] Subnetwork Input Offset
                delta = parameters{ 3 };                           	% [-] Subnetwork Output Offset
                
            else                                                    % Otherwise...
                
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end            
            
        end
        
        
        % Implement a function to unpack the parameters required to compute the absolute division output activation domain.
        function [ c, alpha, epsilon, R_numerator ] = unpack_absolute_division_R_output_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end               	% [-] Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                % If the parameters are empty...

                % Set the default parameters.
                c = self.c_DEFAULT;                                 % [-] General Subnetwork Gain
                alpha = self.alpha_DEFAULT;                      	% [-] Subnetwork Denominator Adjustment
                epsilon = self.epsilon_DEFAULT;                    	% [-] Subnetwork Input Offset
                R_numerator = self.R;                             	% [V] Activation Domain.

            elseif length( parameters ) == 1                      	% If there are a specific number of parameters...

                % Retrieve the parameters.
                c = parameters{ 1 };                              	% [-] General Subnetwork Gain
                alpha = parameters{ 2 };                         	% [-] Subnetwork Input Offset
                epsilon = parameters{ 3 };                       	% [-] Subnetwork Output Offset
                R_numerator = parameters{ 4 };                     	% [V] Activation Domain.
                
            else                                                   	% Otherwise...
                
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end            
            
        end

        
        %% Activation Domain Compute Functions.
        
        % Implement a function to compute the operational domain of the addition subnetwork input neurons.
        function [ R, self ] = compute_addition_R_input( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end           	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                  	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end      % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane capacitance for this addition subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                               % If the encoding scheme is set to absolute...

                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue addition subnetwork.
                R = neuron_utilities.compute_absolute_addition_R_input(  );         % [V] Activation Domain.
            
            elseif strcmpi( encoding_scheme, 'relative' )                           % If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative addition subnetwork.
                R = neuron_utilities.compute_relative_addition_R_input(  );         % [V] Activation Domain.

            else                                                                    % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.R = R; end
            
        end
        
        
        % Implement a function to compute the operational domain of the addition subnetwork output neurons.
        function [ R, self ] = compute_addition_R_output( self, parameters, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 5, neuron_utilities = self.neuron_utilities; end              	% [class] Neuron Utilities.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                       	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            if nargin < 2, parameters = {  }; end                                       % [-] Parameters Cell.                                                                             

            % Determine how to compute the membrane capacitance for this addition subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is set to absolute...

                % Unpack the parameters required to compute the absolute addition subnetwork output activation domain.
                Rs = self.unpack_absolute_addition_R_output_parameters( parameters );
                    
                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue addition subnetwork.
                R = neuron_utilities.compute_absolute_addition_R_output( Rs );          % [V] Activation Domain.
            
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative addition subnetwork.
                R = neuron_utilities.compute_relative_addition_R_output(  );            % [V] Activation Domain.

            else                                                                        % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.R = R; end
            
        end
        
        
        % Implement a function to compute the operational domain of the subtraction subnetwork input neurons.
        function [ R, self ] = compute_subtraction_R_input( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end                  	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                          	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane capacitance for this subtraction subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is set to absolute...

                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue subtraction subnetwork.
                R = neuron_utilities.compute_absolute_subtraction_R_input(  );              % [V] Activation Domain.
            
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative subtraction subnetwork.
                R = neuron_utilities.compute_relative_subtraction_R_input(  );              % [V] Activation Domain.

            else                                                                            % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.R = R; end
            
        end
        
        
        % Implement a function to compute the operational domain of the subtraction subnetwork output neurons.
        function [ R, self ] = compute_subtraction_R_output( self, parameters, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 5, neuron_utilities = self.neuron_utilities; end                            % [class] Neuron Utilities.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                                    % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                      % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            if nargin < 2, parameters = {  }; end                                                   % [-] Parameters Cell.
            
            % Determine how to compute the membrane capacitance for this subtraction subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                               % If the encoding scheme is set to absolute...

                % Unpack the parameters required to compute the absolute subtraction subnetwork output activation domain.
                [ Rs, s_ks ] = self.unpack_absolute_subtraction_R_output_parameters( parameters );
                
                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue subtraction subnetwork.
                R = neuron_utilities.compute_absolute_subtraction_R_output( Rs, s_ks );             % [V] Activation Domain.
            
            elseif strcmpi( encoding_scheme, 'relative' )                                           % If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative subtraction subnetwork.
                R = neuron_utilities.compute_relative_subtraction_R_output(  );                     % [V] Activation Domain.

            else                                                                                    % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.R = R; end
            
        end


        % Implement a function to compute the operational domain of the inversion subnetwork input neurons.
        function [ R, self ] = compute_inversion_R_input( self, parameters, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 5, neuron_utilities = self.neuron_utilities; end                            % [class] Neuron Utilities.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                                    % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                      % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            if nargin < 2, parameters = {  }; end                                                   % [-] Parameters Cell.
            
            % Determine how to compute the membrane capacitance for this inversion subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                               % If the encoding scheme is set to absolute...

                % Unpack the parameters required to compute the absolute inversion subnetwork input activation domain.
                [ epsilon, delta ] = self.unpack_absolute_inversion_R_input_parameters( parameters );
                
                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue inversion subnetwork.
                R = neuron_utilities.compute_absolute_inversion_R_input( epsilon, delta );          % [V] Activation Domain.
            
            elseif strcmpi( encoding_scheme, 'relative' )                                           % If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative inversion subnetwork.
                R = neuron_utilities.compute_relative_inversion_R_input(  );                        % [V] Activation Domain.

            else                                                                                    % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.R = R; end
            
        end
        
        
        % Implement a function to compute the operational domain of the inversion subnetwork output neurons.
        function [ R, self ] = compute_inversion_R_output( self, parameters, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 5, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                         	% [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            if nargin < 2, parameters = {  }; end                                                       % [-] Parameters Cell.
            
            % Determine how to compute the membrane capacitance for this inversion subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                                   % If the encoding scheme is set to absolute...

                % Unpack the parameters required to compute the absolute inversion subnetwork output activation domain.
                [ c, epsilon, delta ] = self.unpack_absolute_inversion_R_output_parameters( parameters );
                
                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue inversion subnetwork.
                R = neuron_utilities.compute_absolute_inversion_R_output( c, epsilon, delta );          % [V] Activation Domain.
            
            elseif strcmpi( encoding_scheme, 'relative' )                                               % If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative inversion subnetwork.
                R = neuron_utilities.compute_relative_inversion_R_output(  );                           % [V] Activation Domain.

            else                                                                                        % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.R = R; end

        end


        % Implement a function to compute the operational domain of the division subnetwork input neurons.
        function [ R, self ] = compute_division_R_input( self, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 4, neuron_utilities = self.neuron_utilities; end               	% [class] Neuron Utilities.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                      	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end       	% [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            
            % Determine how to compute the membrane capacitance for this division subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is set to absolute...

                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue division subnetwork.
                R = neuron_utilities.compute_absolute_division_R_input(  );             % [V] Activation Domain.
            
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative inverdivisionsion subnetwork.
                R = neuron_utilities.compute_relative_division_R_input(  );             % [V] Activation Domain.

            else                                                                        % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.R = R; end
            
        end
        
        
        % Implement a function to compute the operational domain of the division subnetwork output neurons.
        function [ R, self ] = compute_division_R_output( self, parameters, encoding_scheme, set_flag, neuron_utilities )
            
            % Set the default input arguments.
            if nargin < 5, neuron_utilities = self.neuron_utilities; end                                            % [class] Neuron Utilities.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                                                   	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                      % [str] Encoding Scheme (Either 'Absolute' or 'Relative'.)
            if nargin < 2, parameters = {  }; end                                                                   % [-] Parameters Cell.
            
            % Determine how to compute the membrane capacitance for this division subnetwork neuron.
            if strcmpi( encoding_scheme, 'absolute' )                                                               % If the encoding scheme is set to absolute...
                
                % Unpack the parameters required to compute the absolute division subnetwork output activation domain.
                [ c, alpha, epsilon, R_numerator ] = self.unpack_absolute_division_R_output_parameters( parameters );
                
                % Compute the membrane capacitance for this neuron assuming that it belongs to an absolue division subnetwork.
                R = neuron_utilities.compute_absolute_division_R_output( c, alpha, epsilon, R_numerator );          % [V] Activation Domain.
            
            elseif strcmpi( encoding_scheme, 'relative' )                                                           % If the encoding scheme is set to relative...
            
                % Compute the membrane capacitance for this neuron assuming that it belongs to a relative inverdivisionsion subnetwork.
                R = neuron_utilities.compute_relative_division_R_output(  );                                        % [V] Activation Domain.

            else                                                                                                    % Otherwise...

                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
            
            % Determine whether to update the neuron object.
            if set_flag, self.R = R; end
                        
        end
        
        
        % Implement a function to compute the operational domain of the relative multiplication subnetwork output neurons.
        function [ R, self ] = compute_relative_multiplication_R_output( self, c, c1, c2, epsilon1, epsilon2, set_flag, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 8, neuron_utilities = self.neuron_utitlies; end
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 6, epsilon2 = self.epsilon_DEFAULT; end                                                         % [-] Division Subnetwork Offset.
            if nargin < 5, epsilon1 = self.epsilon_DEFAULT; end                                                         % [-] Inversion Subnetwork Offset.
            if nargin < 4, c2 = self.c_DEFAULT; end                                                                     % [-] Division Subnetwork Gain.
            if nargin < 3, c1 = self.c_DEFAULT; end                                                                     % [-] Inversion Subnetwork Gain.
            if nargin < 2, c = self.c_DEFAULT; end                                                                      % [-] Multiplication Subnetwork Gain.
            
            % Compute the operational domain.
            R = neuron_utilities.compute_relative_multiplication_R_output( c, c1, c2, epsilon1, epsilon2 );             % [V] Activation Domain.
            
            % Determine whether to update the neuron object.
            if set_flag, self.R = R; end
            
        end
        
        
        %% Current Compute Functions.
        
        % Implement a function to compute the leak current associated with this neuron.
        function [ Ileak, self ] = compute_Ileak( self, U, Gm, set_flag, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 5, neuron_utilities = self.neuron_utilities; end            % [class] Neuron Utilities.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                   	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 3, Gm = self.Gm; end                                     	% [S] Membrane Conductance.
            if nargin < 2, U = self.U; end                                         	% [V] Membrane Voltage.
            
            % Compute the leak current associated with this neuron.
            Ileak = neuron_utilities.compute_Ileak( U, Gm );                     	% [A] Leak Current.
            
            % Determine whether to update the neuron object.
            if set_flag, self.Ileak = Ileak; end
            
        end
        
        
        % Implement a function to compute the sodium channel current associated with this neuron.
        function [ Ina, self ] = compute_Ina( self, U, Gna, Am, Sm, dEm, Ah, Sh, dEh, dEna, set_flag, neuron_utilities )
            
            % Define the default input arguments.
            if nargin < 12, neuron_utilities = self.neuron_utilities; end                       	% [class] Neuron Utilities.
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 10, dEna = self.dEna; end                                                 	% [V] Sodium Channel Reversal Potential.
            if nargin < 9, dEh = self.dEh; end                                                      % [V] Sodium Channel Deactivation Reversal Potential.
            if nargin < 8, Sh = self.Sh; end                                                      	% [-] Sodium Channel Deactivation Slope.
            if nargin < 7, Ah = self.Ah; end                                                     	% [-] Sodium Channel Deactivation Amplitude.
            if nargin < 6, dEm = self.dEm; end                                                    	% [V] Sodium Channel Activation Reversal Potential.
            if nargin < 5, Sm = self.Sm; end                                                        % [-] Sodium Channel Activation Slope.
            if nargin < 4, Am = self.Am; end                                                     	% [-] Sodium Channel Activation Amplitude.
            if nargin < 3, Gna = self.Gna; end                                                  	% [S] Sodium Channel Conductance.
            if nargin < 2, U = self.U; end                                                       	% [V] Membrane Voltage.
            
            % Compute the sodium channel current associated with this neuron.
            Ina = neuron_utilities.compute_Ina( U, Gna, Am, Sm, dEm, Ah, Sh, dEh, dEna );          % [A] Sodium Channel Current.
            
            % Determine whether to update the neuron object.
            if set_flag, self.Ina = Ina; end
            
        end
        
        
        % Implement a function to compute the total current associated with this neuron.
        function [ Itotal, self ] = compute_Itotal( self, Ileak, Isyn, Ina, Itonic, Iapp, set_flag, neuron_utilities )
            
            % Define the default input arguments.
            if narign < 8, neuron_utilities = self.neuron_utilities; end                                % [class] Neuron Utilities.
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            if nargin < 6, Iapp = self.Iapp; end                                                    	% [A] Applied Currents
            if nargin < 5, Itonic = self.Itonic; end                                               	% [A] Tonic Current
            if nargin < 4, Ina = self.Ina; end                                                     	% [A] Sodium Channel Current
            if nargin < 3, Isyn = self.Isyn; end                                                     	% [A] Synaptic Current
            if nargin < 2, Ileak = self.Ileak; end                                                 	% [A] Leak Current
            
            % Compute the total current.
            Itotal = neuron_utilities.compute_Itotal( Ileak, Isyn, Ina, Itonic, Iapp );           % [A] Total Current
            
            % Determine whether to update the neuron object.
            if set_flag, self.Itotal = Itotal; end
            
        end
  
        
        %% Enable & Disable Functions.
        
        % Implement a function to toogle whether this neuron is enabled.
        function [ enabled_flag, self ] = toggle_enabled( self, enabled_flag, set_flag )
            
            % Set the default input arguments.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            if narign < 2, enabled_flag = self.enabled_flag; end                                        % [T/F] Enabled Flag.
            
            % Toggle whether the neuron is enabled.
            enabled_flag = ~enabled_flag;                                                            	% [T/F] Neuron Enabled Flag.
            
            % Determine whether to update the neuron object.
            if set_flag, self.enabled_flag = enabled_flag; end
            
        end
        
        
        % Implement a function to enable this neuron.
        function [ enabled_flag, self ] = enable( self, set_flag )
            
            % Set the default input arguments.
            if nargin < 2, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            
            % Enable this neuron.
            enabled_flag = true;                                                                        % [T/F] Neuron Enabled Flag
            
            % Determine whether to update the neuron object.
            if set_flag, self.enabled_flag = enabled_flag; end
            
        end
        
        
        % Implement a function to disable this neuron.
        function [ enabled_flag, self ] = disable( self, set_flag )
            
            % Set the default input arguments.
            if nargin < 2, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            
            % Disable this neuron.
            enabled_flag = false;                                                                   	% [T/F] Neuron Enabled Flag
            
            % Determine wehther to update the neuron object.
            if set_flag, self.enabled_flag = enabled_flag; end
            
        end

        
        %% Save & Load Functions.
        
        % Implement a function to save neuron data as a matlab object.
        function save( self, directory, file_name, neuron )
            
            % Set the default input arguments.
            if nargin < 4, neuron = self; end
            if nargin < 3, file_name = 'Neuron.mat'; end                                                                % [-] File Name
            if nargin < 2, directory = '.'; end                                                                         % [-] Directory Path
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];                                                                  % [-] Full Directory Path
            
            % Save the neuron data.
            save( full_path, neuron )
            
        end
        
        
        % Implement a function to load neuron data as a matlab object.
        function neuron = load( ~, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Neuron.mat'; end                                                                % [-] File Name
            if nargin < 2, directory = '.'; end                                                                         % [-] Directory Name
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];                                                                  % [-] Full Directory Path
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            neuron = data.neuron;
            
        end
        
        
    end
end

