classdef neuron_utilities_class
    
    % This class contains properties and methods related to neuron utilities.
    
    
    %% NEURON UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % Define default neuron parameters.
        Cm_DEFAULT = 5e-9;                          % [C] Membrane Capacitance
        Gm_DEFAULT = 1e-6;                          % [S] Membrane Conductance
        Er_DEFAULT = -60e-3;                        % [V] Equilibrium Voltage
        R_DEFAULT = 20e-3;                          % [V] Activation Domain
        Am_DEFAULT = 1;                             % [-] Sodium Channel Activation Parameter Amplitude
        Sm_DEFAULT = -50;                           % [-] Sodium Channel Activation Parameter Slope
        dEm_DEFAULT = 40e-3;                        % [V] Sodium Channel Activation Reversal Potential
        Ah_DEFAULT = 0.5;                           % [-] Sodium Channel Deactivation Parameter Amplitude
        Sh_DEFAULT = 50;                            % [-] Sodium Channel Deactivation Parameter Slope
        dEh_DEFAULT = 0;                            % [V] Sodium Channel Deactivation Reversal Potential
        dEna_DEFAULT = 110e-3;                      % [V] Sodium Channel Reversal Potential
        tauh_max_DEFAULT = 0.25;                    % [s] Maximum Sodium Channel Steady State Time Constant
        Gna_DEFAULT = 0;                            % [S] Sodium Channel Conductance
        Ileak_DEFAULT = 0;                          % [A] Leak Current
        Isyn_DEFAULT = 0;                           % [A] Synaptic Current
        Ina_DEFAULT = 0;                            % [A] Sodium Channel Current
        Itonic_DEFAULT = 0;                         % [A] Tonic Current
        Iapp_DEFAULT = 0;                           % [A] Applied Current
        Itotal_DEFAULT = 0;                         % [A] Total Current
        
        % Define generic subnetwork default parameters.
        c_DEFAULT = 1;                              % [-] General Subnetwork Gain
        epsilon_DEFAULT = 1e-6;                     % [-] Subnetwork Input Offset
        delta_DEFAULT = 1e-6;                       % [-] Subnetwork Output Offset
        alpha_DEFAULT = 1e-6;                     	% [-] Subnetwork Denominator Adjustment

        % Define free subnetwork default parameters.
        R_free_DEFAULT = 20e-3;                     % [V] Free Activation Domain
        Cm_free_DEFAULT = 5e-9;                     % [C] Free Membrane Capacitance
        Gm_free_DEFAULT = 1e-6;                     % [S] Free Membrance Conductance
        Gm_minimum_DEFAULT = 0.1e-6;                % [S] Minimum Membrance Conductance.
        
        % Define activate sodium channel default parameters.
        Gna_active_DEFAULT = 1e-6;             % [S] Sodium Channel Conductance (Ion Channels)
                
        % Define derivative subnetwork parameters.
        c_derivation_DEFAULT = 1e6;                 % [-] Derivative Subnetwork Gain
        w_derivation_DEFAULT = 1;                   % [Hz?] Derivative Subnetwork Cuttoff Frequency?
        sf_derivation_DEFAULT = 0.05;               % [-] Derivative Subnetwork Safety Factor
        
        % Define integration subnetwork parameters.
        c_integration_mean_DEFAULT = 0.01e9;        % [-] Mean Integration Subnetwork Gain

        % Define default cpg subnetwork parameters.
        T_oscillation_DEFAULT = 2;                  % [s] Oscillation Period.
        r_oscillation_DEFAULT = 0.90;               % [-] Oscillation Decay.
        num_cpg_neurons_DEFAULT = 2;                % [#] Number of CPG neurons.
        
    end
    
    
    %% NEURON UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neuron_utilities_class(  )
            
            
            
        end
        
        
        %% Sodium Channel Functions.
        
        % Implement a function to compute the steady state sodium channel activation and deactivation parameters.
        function mhinf = compute_mhinf( self, U, Amh, Smh, dEmh )
            
            % Define the default input arguments.
            if nargin < 5, dEmh = self.dEh_DEFAULT; end                 % [V] Sodium Channel Deactivation Reversal Potential.
            if nargin < 4, Smh = self.Sh_DEFAULT; end                   % [-] Sodium Channel Deactivation Slope.
            if nargin < 3, Amh = self.Ah_DEFAULT; end                   % [-] Sodium Channel Deactivation Amplitude.
            if nargin < 2, U = 0; end                                   % [V] Membrane Voltage
            
            % Compute the steady state sodium channel activation / deactivation parameter.
            mhinf = 1./( 1 + Amh.*exp( -Smh.*( dEmh - U ) ) );          % [-] Steady State Sodium Channel Activation/Deactivation Parameter (Defaults to Deactivation Parameter)
            
        end
        
        
        % Compute the sodium channel deactivation time constant.
        function tauhs = compute_tauh( self, Us, tauh_maxs, hinfs, Ahs, Shs, dEhs )
            
            % This function computes the sodium channel deactivation time constant associated with each neuron in a network.
            
            % Inputs:
            % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potential.
            % tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
            % hinfs = num_neurons x 1 vector of steady state sodium channel deactivation parameter values.
            % Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
            % Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
            % dEhs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
            
            % Outputs:
            % tauhs = num_neurons x 1 vector of sodium channel deactivation parameter time constants.
            
            % Define the default input arguments.
            if nargin < 7, dEhs = self.dEh_DEFAULT; end                                     % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 6, Shs = self.Sh_DEFAULT; end                                       % [-] Sodium Channel Deactivation Slope
            if nargin < 5, Ahs = self.Ah_DEFAULT; end                                       % [-] Sodium Channel Deactivation Amplitude
            if nargin < 4, hinfs = self.compute_mhinf( Us, Ahs, Shs, dEhs ); end            % [-] Steady State Sodium Channel Deactivation Parameter
            if nargin < 3, tauh_maxs = self.tauh_max_DEFAULT; end                           % [s] Maximum Sodium Channel Deactivation Time Constant
            
            % Compute the sodium channel deactivation time constant.
            tauhs = tauh_maxs.*hinfs.*sqrt( Ahs.*exp( -Shs.*( dEhs - Us ) ) );              % [s] Sodium Channel Deactivation Time Constant
            
        end
        
        
        % Implement a function to perform a sodium channel time constant step.
        function [ tauhs, hinfs ] = tauh_step( self, Us, tauh_maxs, Ahs, Shs, dEhs )
            
            % This function computes the sodium channel current for each neuron in a network.
            
            % Inputs:
            % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potential.
            % hs = num_neurons x 1 vector of neuron sodium channel deactivation parameters.
            % Ams = num_neurons x 1 vector of sodium channel activation A parameter values.
            % Sms = num_neurons x 1 vector of sodium channel activation S parameter values.
            % dEms = num_neurons x 1 vector of sodium channel activation parameter reversal potentials.
            % Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
            % Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
            % dEhs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
            % tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
            % Gnas = num_neurons x 1 vector of sodium channel conductances for each neuron.
            % dEnas = num_neurons x 1 vector of sodium channel reversal potentials for each neuron.
            
            % Outputs:
            % Inas = num_neurons x 1 vector of sodium channel currents for each neuron.
            % minfs = num_neurons x 1 vector of neuron steady state sodium channel activation values.
            % hinfs = num_neurons x 1 vector of neuron steady state sodium channel deactivation values.
            % tauhs = num_neurons x 1 vector of sodium channel deactivation parameter time constants.
            
            % Define the default input arguments.
            if nargin < 6, dEhs = self.dEh_DEFAULT; end                                     % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 5, Shs = self.Sh_DEFAULT; end                                       % [-] Sodium Channel Deactivation Slope
            if nargin < 4, Ahs = self.Ah_DEFAULT; end                                       % [-] Sodium Channel Deactivation Amplitude
            if nargin < 3, tauh_maxs = self.tauh_max_DEFAULT; end                           % [s] Maximum Sodium Channel Deactivation Time Constant
            
            % Compute the steady state sodium channel deactivation parameters.
            hinfs = self.compute_mhinf( Us, Ahs, Shs, dEhs );                               % [-] Steady State Sodium Channel Deactivation Parameter
            
            % Compute the sodium channel deactivation time constants.
            tauhs = self.compute_tauh( Us, tauh_maxs, hinfs, Ahs, Shs, dEhs );              % [s] Sodium Channel Deactivation Time Constant
            
        end
        
        
        %% Current Functions.
        
        % Implement a function to compute leak currents.
        function I_leak = compute_Ileak( self, U, Gm )
            
            % Define the default input arguments.
            if nargin < 3, Gm = self.Gm_DEFAULT; end                % [S] Membrane Conductance
            if nargin < 2, U = 0; end                               % [V] Membrane Voltage
            
            % Compute the leak current.
            I_leak = -Gm.*U;                                        % [A] Leak Current
            
        end
        
        
        % Implement a function to compute a sodium current.
        function I_na = compute_Ina( self, U, h, m_inf, Gna, dEna, Am, Sm, dEm )
            
            % Define the default input arguments.
            if nargin < 9, dEm = self.dEm_DEFAULT; end                              % [V] Sodium Channel Activation Reversal Potential
            if nargin < 8, Sm = self.Sm_DEFAULT; end                                % [-] Sodium Channel Activation Slope
            if nargin < 7, Am = self.Am_DEFAULT; end                                % [-] Sodium Channel Activation Amplitude
            if nargin < 6, dEna = self.dEna_DEFAULT; end                            % [V] Sodium Channel Reversal Potential
            if nargin < 5, Gna = self.Gna_DEFAULT; end                              % [S] Sodium Channel Conductance
            if nargin < 4, m_inf = self.compute_mhinf( U, Am, Sm, dEm ); end        % [-] Steady State Sodium Channel Activation Parameter
            
            % Compute the sodium current.
            I_na = Gna.*m_inf.*h.*( dEna - U );                                     % [A] Sodium Channel Current
            
        end
        
        
        % Implement a function to compute sodium channel currents.
        function [ I_na, m_inf ] = Ina_step( self, U, h, Gna, Am, Sm, dEm, dEna )
            
            % Define the default input arguments.
            if nargin < 8, dEna = self.dEna_DEFAULT; end                            % [V] Sodium Channel Reversal Potential
            if nargin < 7, dEm = self.dEm_DEFAULT; end                              % [-] Sodium Channel Activation Reversal Potential
            if nargin < 6, Sm = self.Sm_DEFAULT; end                                % [-] Sodium Channel Activation Slope
            if nargin < 5, Am = self.Am_DEFAULT; end                                % [-] Sodium Channel Activation Amplitude
            if nargin < 4, Gna = self.Gna_DEFAULT; end                              % [S] Sodium Channel Conductance
            if nargin < 3, h = 0; end                                               % [-] Sodium Channel Deactivation Parameter
            if nargin < 2, U = 0; end                                               % [V] Membrane Voltage
            
            % Compute the steady state sodium channel activation parameter.
            m_inf = self.compute_mhinf( U, Am, Sm, dEm );                           % [-] Steady State Sodium Channel Activation Parameter
            
            % Compute the sodium channel current.
            I_na = self.compute_Ina( U, h, m_inf, Gna, dEna );                      % [A] Sodium Channel Current
            
        end
        
        
        % Implement a function to compute the total current.
        function I_total = compute_Itotal( self, I_leak, I_syn, I_na, I_tonic, I_app )
            
            % Define the default input arguments.
            if nargin < 6, I_app = self.Iapp_DEFAULT; end                           % [A] Applied Current
            if nargin < 5, I_tonic = self.Itonic_DEFAULT; end                       % [A] Tonic Current
            if nargin < 4, I_na = self.Ina_DEFAULT; end                             % [A] Sodium Channel Current
            if nargin < 3, I_syn = self.Isyn_DEFAULT; end                           % [A] Synaptic Current
            if nargin < 2, I_leak = self.Ileak_DEFAULT; end                         % [A] Leak Current
            
            % Compute the the total current.
            I_total = I_leak + I_syn + I_na + I_tonic + I_app;                      % [A] Total Current
            
        end
        
        
        %% Neuron State Flow Functions.
        
        % Implement a function to compute the derivative of the membrane voltage with respect to time.
        function dUs = compute_dU( self, Itotals, Cms )
            
            % Define the default input arguments.
            if nargin < 3, Cms = self.Cm_DEFAULT; end               % [C] Membrane Capacitance
            if nargin < 2, Itotals = self.Itotal_DEFAULT; end       % [A] Total Current
            
            % Compute the membrane voltage derivative with respect to time.
            dUs = Itotals./Cms;                                     % [V/s] Voltage Derivative With Respect To Time
            
        end
        
        
        % Implement a function to compute the derivative of the sodium channel deactivation parameter with respect to time.
        function dhs = compute_dh( self, hs, hinfs, tauhs )
            
            % Define the default input arguments.
            if nargin < 4, tauhs = self.tauh_max_DEFAULT; end       % [s] Sodium Channel Deactivation Time Constant
            if nargin < 3, hinfs = 0; end                           % [-] Steady State Sodium Channel Deactivation Parameter
            if nargin < 2, hs = 0; end                              % [-] Sodium Channel Deactivation Parameter
            
            % Compute the sodium channel deactivation parameter derivative with respect to time.
            dhs = ( hinfs - hs )./tauhs;                            % [-/s] Sodium Channel Deactivation Parameter Derivative With Respect To Time.
            
        end
        
        
        %% Sodium Channel Conductance Functions.
        
        % Implement a function to compute the sodium channel conductance of an absolute transmission subnetwork neuron.
        function Gna = compute_absolute_transmission_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end

        
        % Implement a function to compute the sodium channel conductance of a relative transmission subnetwork neuron.
        function Gna = compute_relative_transmission_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a modulation subnetwork neuron.
        function Gna = compute_modulation_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of an absolute addition subnetwork neuron.
        function Gna = compute_absolute_addition_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a relative addition subnetwork neuron.
        function Gna = compute_relative_addition_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of an absolute subtraction subnetwork neuron.
        function Gna = compute_absolute_subtraction_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        % Implement a function to comptue the sodium channel conductance of a relative subtraction subnetwork neuron.
        function Gna = compute_relative_subtraction_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        

        % Implement a function to compute the sodium channel conductance of an absolute double subtraction subnetwork neuron.
        function Gna = compute_absolute_double_subtraction_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a relative double subtraction subnetwork neuron.
        function Gna = compute_relative_double_subtraction_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        

        % Implement a function to compute the sodium channel conductance of an absolute multiplication subnetwork neuron.
        function Gna = compute_absolute_multiplication_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a relative multiplication subnetwork neuron.
        function Gna = compute_relative_multiplication_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of an absolute inversion subnetwork neuron.
        function Gna = compute_absolute_inversion_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a relative inversino subnetwork neuron.
        function Gna = compute_relative_inversion_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        

        % Implement a function to compute the sodium channel conductance of an absolute division subnetwork neuron.
        function Gna = compute_absolute_division_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a relative division subnetwork neuron.
        function Gna = compute_relative_division_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a derivation subnetwork neuron.
        function Gna = compute_derivation_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a integration subnetwork neuron.
        function Gna = compute_integration_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        

        % Implement a function to compute the sodium channel conductance of a voltage based integration subnetwork neuron.
        function Gna = compute_vbi_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end


        % Implement a function to compute the sodium channel conductance of a split voltage based integration subnetwork neuron.
        function Gna = compute_svbi_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
       
        % Implement a function to compute the sodium channel conductances for a CPG subnetwork.
        function Gna = compute_cpg_Gna( self, R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna )
            
            % Define the default input arguments.
            if nargin < 10, dEna = self.dEna_DEFAULT; end                   % [V] Sodium Channel Reversal Potential
            if nargin < 9, dEh = self.dEh_DEFAULT; end                      % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 8, Sh = self.Sh_DEFAULT; end                        % [-] Sodium Channel Deactivation Slope
            if nargin < 7, Ah = self.Ah_DEFAULT; end                        % [-] Sodium Channel Deactivation Amplitude
            if nargin < 6, dEm = self.dEm_DEFAULT; end                      % [-] Sodium Channel Activation Reversal Potential
            if nargin < 5, Sm = self.Sm_DEFAULT; end                        % [-] Sodium Channel Activation Slope
            if nargin < 4, Am = self.Am_DEFAULT; end                        % [-] Sodium Channel Activation Amplitude
            if nargin < 3, Gm = self.Gm_DEFAULT; end                        % [S] Membrane Conductance
            if nargin < 2, R = self.R_DEFAULT; end                          % [V] Activation Domain
            
            % Compute the steady state sodium channel activation & devactivation parameters at the upper equilibrium.
            minf_upper = self.compute_mhinf( R, Am, Sm, dEm );              % [-] Steady State Sodium Channel Activation Parameter
            hinf_upper = self.compute_mhinf( R, Ah, Sh, dEh );              % [-] Steady State Sodium Channel Deactivation Parameter.
            
            % Compute the sodium channel conductance for each half-center neuron.
            Gna = ( Gm.*R )./( minf_upper.*hinf_upper.*( dEna - R ) );      % [S] Sodium Channel Conductance.  Equation straight from Szczecinski's CPG example.
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a driven multistate cpg subnetwork neuron.
        function Gna = compute_dmcpg_Gna( ~ )
            
            % Compute the sodium channel conductance.
            Gna = 0;              % [S] Sodium Channel Conductance.
            
        end
        
        
        
        %% Membrane Conductance Functions.
        
        % Implement a function to compute the membrane conductance for absolute addition subnetwork input neurons.
        function Gm = compute_absolute_addition_Gm_input( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_free_DEFAULT;                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the memebrane conductance for absolute addition subnetwork output neurons.
        function Gm = compute_absolute_addition_Gm_output( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_minimum_DEFAULT;                   % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative addition subnetwork input neurons.
        function Gm = compute_relative_addition_Gm_input( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_free_DEFAULT;                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the memebrane conductance for relative addition subnetwork output neurons.
        function Gm = compute_relative_addition_Gm_output( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_minimum_DEFAULT;                   % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute subtraction subnetwork input neurons.
        function Gm = compute_absolute_subtraction_Gm_input( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_free_DEFAULT;                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the memebrane conductance for absolute subtraction subnetwork output neurons.
        function Gm = compute_absolute_subtraction_Gm_output( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_minimum_DEFAULT;                   % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative subtraction subnetwork input neurons.
        function Gm = compute_relative_subtraction_Gm_input( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_free_DEFAULT;                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the memebrane conductance for relative subtraction subnetwork output neurons.
        function Gm = compute_relative_subtraction_Gm_output( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_minimum_DEFAULT;                   % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute inversion subnetwork input neurons.
        function Gm = compute_absolute_inversion_Gm_input( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_free_DEFAULT;                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the memebrane conductance for absolute inversion subnetwork output neurons.
        function Gm = compute_absolute_inversion_Gm_output( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_minimum_DEFAULT;                   % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative inversion subnetwork input neurons.
        function Gm = compute_relative_inversion_Gm_input( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_free_DEFAULT;                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the memebrane conductance for relative inversion subnetwork output neurons.
        function Gm = compute_relative_inversion_Gm_output( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_minimum_DEFAULT;                   % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for absolute division subnetwork input neurons.
        function Gm = compute_absolute_division_Gm_input( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_free_DEFAULT;                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the memebrane conductance for absolute division subnetwork output neurons.
        function Gm = compute_absolute_division_Gm_output( ~ )
            
            % Set the membrane conductance.
%             Gm = 8.70e-9;                   % [S] Membrane Conductance
            Gm = 8.70e-10;                   % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the membrane conductance for relative division subnetwork input neurons.
        function Gm = compute_relative_division_Gm_input( self )
            
            % Set the membrane conductance.
            Gm = self.Gm_free_DEFAULT;                      % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute the memebrane conductance for relative division subnetwork output neurons.
        function Gm = compute_relative_division_Gm_output( ~ )
            
            % Set the membrane conductance.
%             Gm = self.Gm_minimum_DEFAULT;                   % [S] Membrane Conductance
            Gm = 8.70e-10;                                  % [S] Membrane Conductance
            
        end
        
        
        % Implement a function to compute membrane conductance for a derivative subnetwork.
        function Gm = compute_derivation_Gm( ~, k, w, safety_factor )
            
            % Set the default input arugments.
            if nargin < 4, safety_factor = self.sf_derivation_DEFAULT; end          % [-] Derivative Safety Factor.
            if nargin < 3, w = self.w_derivation_DEFAULT; end                       % [Hz?] Derivative Cutoff Frequency?
            if nargin < 2, k = self.c_derivation_DEFAULT; end                       % [-] Derivative Gain
            
            % Compute the required membrance conductance.
            Gm = ( 1 - safety_factor )./( k.*w );                           % [S] Membrane Conductance
            
        end
        
        
        %% Membrane Capacitance Functions.
        
        % Implement a function to compute the membrane capacitance of absolute transmission subnetwork neurons.
        function Cm = compute_absolute_transmission_Cm( self )
            
            % Compute the membrane capacitance.
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of relative transmission subnetwork neurons.
        function Cm = compute_relative_transmission_Cm( self )
            
            % Compute the membrane capacitance.
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of slow absolute transmission subnetwork neurons.
        function Cm = compute_slow_absolute_transmission_Cm( self, Gm, n, T, r )
            
            % Define the default input arguments.
            if nargin < 5, r = self.r_oscillation_DEFAULT; end              % [-] Oscillation Decay
            if nargin < 4, T = self.T_oscillation_DEFAULT; end              % [-] Oscillation Period
            if nargin < 3, n = self.num_cpg_neurons_DEFAULT; end            % [#] Number of Neurons
            if nargin < 2, Gm = self.Gm_DEFAULT; end                % [S] Membrane Conductance
            
            % Compute the membrane capacitance.
            Cm = -( Gm.*T )./( n.*log( r ) );                       % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of slow relative transmission subnetwork neurons.
        function Cm = compute_slow_relative_transmission_Cm( self, Gm, n, T, r )
            
            % Define the default input arguments.
            if nargin < 5, r = self.r_oscillation_DEFAULT; end              % [-] Oscillation Decay
            if nargin < 4, T = self.T_oscillation_DEFAULT; end              % [-] Oscillation Period
            if nargin < 3, n = self.num_cpg_neurons_DEFAULT; end            % [#] Number of Neurons
            if nargin < 2, Gm = self.Gm_DEFAULT; end                % [S] Membrane Conductance
            
            % Compute the membrane capacitance.
            Cm = -( Gm.*T )./( n.*log( r ) );                       % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the memebrane capacitance of modulation subnetwork neurons.
        function Cm = compute_modulation_Cm( self )
            
            % Compute the membrane capacitance.
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of absolute addition subnetwork neurons.
        function Cm = compute_absolute_addition_Cm( self )
            
            % Compute the membrane capacitance.
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of relative addition subnetwork neurons.
        function Cm = compute_relative_addition_Cm( self )
            
            % Compute the membrane capacitance.
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of absolute subtraction subnetwork neurons.
        function Cm = compute_absolute_subtraction_Cm( self )
            
            % Compute the membrane capacitance.
            %             Cm = 0.5e-9;
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the mebrane capacitance of relative subtraction subnetwork neurons.
        function Cm = compute_relative_subtraction_Cm( self )
            
            % Compute the membrane capacitance.
            %            Cm = 0.5e-9;
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of absolute double subtraction subnetwork neurons.
        function Cm = compute_absolute_double_subtraction_Cm( self )
            
            % Compute the membrane capacitance.
            %             Cm = 1e-9;
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of relative double subtraction subnetwork neurons.
        function Cm = compute_relative_double_subtraction_Cm( self )
            
            % Compute the membrane capacitance.
            %             Cm = 1e-9;
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of absolute inversion subnetwork neurons.
        function Cm = compute_absolute_inversion_Cm( self )
            
            % Compute the membrane capacitance.
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of relative inversion subnetwork neurons.
        function Cm = compute_relative_inversion_Cm( self )
            
            % Compute the membrane capacitance.
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of asbolute division subnetwork neurons.
        function Cm = compute_absolute_division_Cm( ~ )
            
            % Compute the membrane capacitance.
%             Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            Cm = 5e-10;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of relative division subnetwork neurons.
        function Cm = compute_relative_division_Cm( ~ )
            
            % Compute the membrane capacitance.
%             Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            Cm = 5e-10;                                      % [C] Membrane Capacitance

        end
        
        
        % Implement a function to compute the membrane capacitance of absolute multiplication subnetwork neurons.
        function Cm = compute_absolute_multiplication_Cm( self )
            
            % Compute the membrane capacitance.
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitance of relative multiplication subnetwork neurons.
        function Cm = compute_relative_multipliction_Cm( self )
            
            % Compute the membrane capacitance.
            Cm = self.Cm_free_DEFAULT;                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the first membrane capacitance of the derivation subnetwork neurons.
        function Cm1 = compute_derivation_Cm1( self, Gm, Cm2, k )
            
            % Set the default input arguments.
            if nargin < 4, k = self.c_derivation_DEFAULT; end               % [-] Derivation Gain.
            if nargin < 3, Cm2 = 1e-9; end                          % [C] Membrane Capacitance of the Second Neuron.
            if nargin < 2, Gm = self.Gm_free_DEFAULT; end                   % [S] Membrance Conductance.
            
            % Compute the required membrane capacitance of the first neuron.
            Cm1 = Cm2 - ( Gm.^2 ).*k;                               % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the second membrane capacitance of the derivation subnetwork neurons.
        function Cm2 = compute_derivation_Cm2( self, Gm, w )
            
            % Set the default input arugments.
            if nargin < 3, w = self.w_derivation_DEFAULT; end               % [Hz?] Derivative Cutoff Frequency.
            if nargin < 2, Gm = self.Gm_free_DEFAULT; end                   % [S] Membrane Conductance.
            
            % Compute the required time constant.
            tau = 1./w;                                             % [s] Time Constant.
            
            % Compute the required membrane capacitance of the second neuron.
            Cm2 = Gm.*tau;                                          % [C] Membrane Capacitance of Second Neuron.
            
        end
        
        
        % Implement a function to compute the membrane capacitances for an integration subnetwork.
        function Cm = compute_integration_Cm( self, ki_mean )
            
            % Set the default input arguments.
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end       % [-] Average Integration Gain.
            
            % Compute the integration subnetwork membrane capacitance.
            Cm = 1./( 2*ki_mean );                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the membrane capacitances for a voltage based integration subnetwork.
        function Cm = compute_vbi_Cm( self, ki_mean )
            
            % Set the default input arguments.
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end       % [-] Average Integration Gain.
            
            % Compute the voltage based integration subnetwork membrane capacitance.
            Cm = 1./( 2*ki_mean );                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the first membrane capacitance for a split voltage based integration subnetwork.
        function Cm = compute_svbi_Cm1( self, ki_mean )
            
            % Set the default input arguments.
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end       % [-] Average Integration Gain.
            
            % Compute the first split voltage based integration subnetwork membrane capacitance.
            Cm = 1./( 2*ki_mean );                                      % [C] Membrane Capacitance
            
        end
        
        
        % Implement a function to compute the second membrane capacitance for a split voltage based integration subnetwork.
        function Cm = compute_svbi_Cm2( ~ )
            
            % Compute the second split voltage based integration subnetwork membrane capacitance.
            Cm = 1e-9;                                                  % [C] Membrance Capacitance.
            
        end
        
        
        %% Activation Domain Functions.
        
        % Implement a function to compute the operational domain of the absolute addition subnetwork input neurons.
        function R = compute_absolute_addition_R_input( self )
            
            % Compute the operational domain.
            R = self.R_free_DEFAULT;                                             % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute addition subnetwork output neurons.
        function R = compute_absolute_addition_R_output( self, Rs )
            
            % Define the default input arguments.
            if nargin < 2, Rs = self.R_free_DEFAULT; end                        % [V] Activation Domain
            
            % Compute the operational domain.
            R = sum( Rs );                                              % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative addition subnetwork input neurons.
        function R = compute_relative_addition_R_input( self )
            
            % Compute the operational domain.
            R = self.R_free_DEFAULT;                                             % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative addition subnetwork output neurons.
        function R = compute_relative_addition_R_output( self )
            
            % Compute the operational domain.
            R = self.R_free_DEFAULT;                                             % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute subtraction subnetwork input neurons.
        function R = compute_absolute_subtraction_R_input( self )
            
            % Compute the operational domain.
            R = self.R_free_DEFAULT;                                             % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute subtraction subnetwork output neurons.
        function R = compute_absolute_subtraction_R_output( self, Rs, s_ks )
            
            % Define the default input arguments.
            if nargin < 3, s_ks = 1; end                                  % [-1, +1] Excitatory / Inhibitory Sign
            if nargin < 2, Rs = self.R_free_DEFAULT; end                        % [V] Activation Domain
            
            % Compute the operational domain.
%             R = sum( s_ks.*Rs );                                           % [V] Activation Domain
%             R = max( Rs );                                           % [V] Activation Domain
            R = sum( Rs( s_ks == 1 ) );
            
        end
        
        
        % Implement a function to compute the operational domain of the relative subtraction subnetwork input neurons.
        function R = compute_relative_subtraction_R_input( self )
            
            % Compute the operational domain.
            R = self.R_free_DEFAULT;                                             % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative subtraction subnetwork output neurons.
        function R = compute_relative_subtraction_R_output( self )
            
            % Compute the operational domain.
            R = self.R_free_DEFAULT;                                             % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute inversion subnetwork input neurons.
        function R = compute_absolute_inversion_R_input( self, epsilon, delta )
            
            % Define the default input argument.
            if nargin < 3, delta = self.delta_DEFAULT; end                      % [V] Output Offset
            if nargin < 2, epsilon = self.epsilon_DEFAULT; end                  % [V] Input Offset
                
            % Compute the operational domain.
%             R = self.R_free_DEFAULT;                                      	% [V] Activation Domain
           R = 1./delta - epsilon;                                             	% [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute inversion subnetwork output neurons.
%         function R = compute_absolute_inversion_R_output( self, c, epsilon )
        function R = compute_absolute_inversion_R_output( self, c, epsilon, delta )

            % Define the default input arguments.
            if nargin < 4, delta = self.delta_DEFAULT; end                      % [-] Output Offset
            if nargin < 3, epsilon = self.epsilon_DEFAULT; end                  % [-] Input Offset
            if nargin < 2, c = self.c_DEFAULT; end                              % [-] Subnetwork Gain
            
            % Compute the operational domain.
%             R = c./epsilon;                                                   % [V] Activation Domain
            R = c.*( 1./epsilon - delta );                                   	% [V] Activation Domain

        end
        
        
        % Implement a function to compute the operational domain of the relative inversion subnetwork input neurons.
        function R = compute_relative_inversion_R_input( self )
            
            % Compute the operational domain.
            R = self.R_free_DEFAULT;                                             % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative inversion subnetwork output neurons.
        function R = compute_relative_inversion_R_output( self )
            
            % Compute the operational domain.
            R = self.R_free_DEFAULT;                                             % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute division subnetwork input neurons.
        function R = compute_absolute_division_R_input( self )
            
            % Compute the operational domain.
            R = self.R_free_DEFAULT;                                             % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the absolute division subnetwork output neurons.
        function R = compute_absolute_division_R_output( self, c, alpha, epsilon, R_numerator )
            
            % Define the default input arguments.
            if nargin < 5, R_numerator = self.R_free_DEFAULT; end           % [V] Activation Domain
            if nargin < 4, epsilon = self.epsilon_DEFAULT; end              % [-] Subnetwork Offset
            if nargin < 3, alpha = self.alpha_DEFAULT; end                  % [-] Subnetwork Denominator Adjustment
            if nargin < 2, c = self.c_DEFAULT; end                          % [-] Subnetwork Gain
            
            % Compute the operational domain.
            R = ( c*R_numerator )./( alpha*R_numerator + epsilon );     % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative division subnetwork input neurons.
        function R = compute_relative_division_R_input( self )
            
            % Compute the operational domain.
            R = self.R_free_DEFAULT;                                             % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative division subnetwork output neurons.
        function R = compute_relative_division_R_output( self )
            
            % Compute the operational domain.
            R = self.R_free_DEFAULT;                                             % [V] Activation Domain
            
        end
        
        
        % Implement a function to compute the operational domain of the relative multiplication subnetwork output neurons.
        function R3 = compute_relative_multiplication_R3( self, c, c1, c2, epsilon1, epsilon2 )
            
            % Define the default input arguments.
            if nargin < 6, epsilon2 = self.epsilon_DEFAULT; end                                 % [-] Division Subnetwork Offset
            if nargin < 5, epsilon1 = self.epsilon_DEFAULT; end                                 % [-] Inversion Subnetwork Offset
            if nargin < 4, c2 = self.c_DEFAULT; end                                                % [-] Division Subnetwork Gain
            if nargim < 3, c1 = self.c_DEFAULT; end                                                % [-] Inversion Subnetwork Gain
            if nargin < 2, c = self.c_DEFAULT; end                                                 % [-] Multiplication Subnetwork Gain
            
            % Compute the operational domain.
            R3 = ( c.*epsilon2 )./( c2 + c2.*epsilon1 - c.*c1.*epsilon1.*epsilon2 );             % [V] Activation Domain
            
        end
        
        
    end
    
    
end