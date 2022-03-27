classdef neuron_utilities_class

    % This class contains properties and methods related to neuron utilities.
    
    
    %% NEURON UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )

        K_DERIVATION = 1e6;
        W_DERIVATION = 1;
        SF_DERIVATION = 0.05;
        
        K_INTEGRATION_MEAN = 0.01e9;

    end
    
    
    %% NEURON UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neuron_utilities_class(  )

            
            
        end
        
        
        %% Sodium Channel Functions
        
        % Implement a function to compute the steady state sodium channel activation and deactivation parameters.
        function mhinf = compute_mhinf( ~, U, Amh, Smh, dEmh )

            % Compute the steady state sodium channel activation / deactivation parameter.
            mhinf = 1./( 1 + Amh.*exp( -Smh.*( dEmh - U ) ) );
            
        end
        
        
        % Implement a function to compute the sodium channel conductances for a CPG subnetwork.
        function Gna = compute_cpg_Gna( self, R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna )
            
            % Compute the steady state sodium channel activation & devactivation parameters at the upper equilibrium.
            minf_upper = self.compute_mhinf( R, Am, Sm, dEm );
            hinf_upper = self.compute_mhinf( R, Ah, Sh, dEh );

            % Compute the sodium channel conductance for each half-center neuron.
            Gna = ( Gm.*R )./( minf_upper.*hinf_upper.*( dEna - R ) );       % [S] Sodium Channel Conductance.  Equation straight from Szczecinski's CPG example.

        end
        
        
        % Compute the sodium channel deactivation time constant.
        function tauhs = compute_tauh( ~, Us, tauh_maxs, hinfs, Ahs, Shs, dEhs )

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

            % Compute the sodium channel deactivation time constant.
            tauhs = tauh_maxs.*hinfs.*sqrt( Ahs.*exp( -Shs.*(dEhs - Us) ) );

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
            
            % Compute the steady state sodium channel deactivation parameters.            
            hinfs = self.compute_mhinf( Us, Ahs, Shs, dEhs );
            
            % Compute the sodium channel deactivation time constants.            
            tauhs = self.compute_tauh( Us, tauh_maxs, hinfs, Ahs, Shs, dEhs );
            
        end
        
        
        %% Current Functions
        
        % Implement a function to compute leak currents.
        function I_leak = compute_Ileak( ~, U, Gm )
        
            % Compute the leak current.
            I_leak = -Gm.*U;
        
        end
        

        % Implement a function to compute a sodium current.
        function I_na = compute_Ina( ~, U, h, m_inf, Gna, dEna )
           
            % Compute teh sodium current.
            I_na = Gna.*m_inf.*h.*( dEna - U );            
            
        end

        
        % Implement a function to compute sodium channel currents.
        function [ I_na, m_inf ] = Ina_step( self, U, h, Gna, Am, Sm, dEm, dEna )
         
            % Compute the steady state sodium channel activation parameter.
            m_inf = self.compute_mhinf( U, Am, Sm, dEm );

            % Compute the sodium channel current.
            I_na = self.compute_Ina( U, h, m_inf, Gna, dEna );
            
        end
        
        
        % Implement a function to compute the total current.
        function I_total = compute_Itotal( ~, I_leak, I_syn, I_na, I_tonic, I_app )
            
           % Compute the the total current.
           I_total = I_leak + I_syn + I_na + I_tonic + I_app;
            
        end
        
        
        %% Neuron State Flow Functions
        
        % Implement a function to compute the derivative of the membrane voltage with respect to time.
        function dUs = compute_dU( ~, Itotals, Cms )
            
            % Compute the membrane voltage derivative with respect to time.
            dUs = Itotals./Cms;
            
        end
        
        
        % Implement a function to compute the derivative of the sodium channel deactivation parameter with respect to time.
        function dhs = compute_dh( ~, hs, hinfs, tauhs )
            
            % Compute the sodium channel deactivation parameter derivative with respect to time.
            dhs = ( hinfs - hs )./tauhs;
            
        end
        
        
        %% Neuron Design Functions
        
        % ---------------------------------------------------------------- Sodium Channel Conductance Functions ----------------------------------------------------------------        

        % Implement a function to compute the sodium channel conductance of a transmission subnetwork neuron.
        function Gna = compute_transmission_Gna( ~ )
        
            % Compute the sodium channel conductance.
           Gna = 0;
            
        end
            
        
        % Implement a function to compute the sodium channel conductance of a modulation subnetwork neuron.
        function Gna = compute_modulation_Gna( ~ )
        
            % Compute the sodium channel conductance.
           Gna = 0;
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of an addition subnetwork neuron.
        function Gna = compute_addition_Gna( ~ )
        
            % Compute the sodium channel conductance.
           Gna = 0;
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a subtraction subnetwork neuron.
        function Gna = compute_subtraction_Gna( ~ )
        
            % Compute the sodium channel conductance.
           Gna = 0;
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a double subtraction subnetwork neuron.
        function Gna = compute_double_subtraction_Gna( ~ )
        
            % Compute the sodium channel conductance.
           Gna = 0;
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a multiplication subnetwork neuron.
        function Gna = compute_multiplication_Gna( ~ )
        
            % Compute the sodium channel conductance.
           Gna = 0;
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a division subnetwork neuron.
        function Gna = compute_division_Gna( ~ )
        
            % Compute the sodium channel conductance.
           Gna = 0;
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a derivation subnetwork neuron.
        function Gna = compute_derivation_Gna( ~ )
        
            % Compute the sodium channel conductance.
           Gna = 0;
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of an integration subnetwork neuron.
        function Gna = compute_integration_Gna( ~ )
        
            % Compute the sodium channel conductance.
           Gna = 0;
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of a voltage based integration subnetwork neuron.
        function Gna = compute_vb_integration_Gna( ~ )
        
            % Compute the sodium channel conductance.
           Gna = 0;
            
        end
        
        
        % ---------------------------------------------------------------- Membrane Conductance Functions ----------------------------------------------------------------        

        % Implement a function to compute membrane conductance for a derivative subnetwork.
        function Gm = compute_derivation_Gm( ~, k, w, safety_factor )
            
            % Set the default input arugments.
            if nargin < 4, safety_factor = self.SF_DERIVATION; end
            if nargin < 3, w = self.W_DERIVATION; end
            if nargin < 2, k = self.K_DERIVATION; end
            
            % Compute the required membrance conductance.
            Gm = ( 1 - safety_factor )./( k.*w );    
            
        end
        
        
        % ---------------------------------------------------------------- Membrane Capacitance Functions ----------------------------------------------------------------        

        % Implement a function to compute the membrane capacitance of subtraction subnetwork neurons.
        function Cm = compute_subtraction_Cm( ~ )
           
            % Compute the membrane capacitance.
            Cm = 1e-9;
            
        end
        
        
        % Implement a function to compute the membrane capacitance of double subtraction subnetwork neurons.
        function Cm = compute_double_subtraction_Cm( ~ )
           
            % Compute the membrane capacitance.
            Cm = 1e-9;
            
        end
        
        
        % Implement a function to compute the first membrane capacitance of the derivation subnetwork neurons.
        function Cm1 = compute_derivation_Cm1( ~, Gm, Cm2, k )
            
            % Set the default input arguments.
            if nargin < 4, k = self.K_DERIVATION; end
            if nargin < 3, Cm2 = 1e-9; end
            if nargin < 2, Gm = 1e-6; end

            % Compute the required membrane capacitance of the first neuron.
            Cm1 = Cm2 - ( Gm.^2 ).*k; 
            
        end
        
        
        % Implement a function to compute the second membrane capacitance of the derivation subnetwork neurons.
        function Cm2 = compute_derivation_Cm2( ~, Gm, w )
        
            % Set the default input arugments.
            if nargin < 3, w = self.W_DERIVATION; end
            if nargin < 2, Gm = 1e-6; end
            
           % Compute the required time constant.
            tau = 1./w;
            
            % Compute the required membrane capacitance of the second neuron.
            Cm2 = Gm.*tau;
            
        end
              
        
        % Implement a function to compute the membrane capacitances for an integration subnetwork.
        function Cm = compute_integration_Cm( ~, ki_mean )
        
            % Set the default input arguments.
            if nargin < 2, ki_mean = self.K_INTEGRATION_MEAN; end
            
            % Compute the integration subnetwork membrane capacitance.
            Cm = 1./( 2*ki_mean );
            
        end
        
        
        % Implement a function to compute the membrane capacitances for a voltage based integration subnetwork.
        function Cm = compute_vb_integration_Cm( ~, ki_mean )
        
            % Set the default input arguments.
            if nargin < 2, ki_mean = self.K_INTEGRATION_MEAN; end
            
            % Compute the voltage based integration subnetwork membrane capacitance.
            Cm = 1./( 2*ki_mean );
            
        end
        
        
    end
    
    
end