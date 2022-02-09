classdef neuron_utilities_class

    % This class contains properties and methods related to neuron utilities.
    
    
    %% NEURON UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        
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
        function Gna = compute_CPG_Gna( self, R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna )
            
            % Compute the steady state sodium channel activation & devactivation parameters at the upper equilibrium.
            minf_upper = self.compute_mhinf( R, Am, Sm, dEm );
            hinf_upper = self.compute_mhinf( R, Ah, Sh, dEh );

            % Compute the sodium channel conductance for each half-center neuron.
            Gna = ( Gm.*R )./( minf_upper.*hinf_upper.*( dEna - R ) );       % [S] Sodium Channel Conductance.  Equation straight from Szczecinski's CPG example.

        end
        
        
        % Compute the sodium channel deactivation time constant.
        function tauhs = compute_sodium_time_constant( ~, Us, tauh_maxs, hinfs, Ahs, Shs, dEhs )

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
        function [ tauhs, hinfs ] = sodium_time_constant_step( self, Us, tauh_maxs, Ahs, Shs, dEhs )
            
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
            tauhs = self.compute_sodium_time_constant( Us, tauh_maxs, hinfs, Ahs, Shs, dEhs );
            
        end
        
        
        %% Current Functions
        
        % Implement a function to compute leak currents.
        function I_leak = compute_leak_current( ~, U, Gm )
        
            I_leak = -Gm.*U;
        
        end
        

        % Implement a function to compute a sodium current.
        function I_na = compute_sodium_current( ~, U, h, m_inf, Gna, dEna )
           
            I_na = Gna.*m_inf.*h.*( dEna - U );            
            
        end

        
        % Implement a function to compute sodium channel currents.
        function [ I_na, m_inf ] = sodium_current_step( self, U, h, Gna, Am, Sm, dEm, dEna )
         
            % Compute the steady state sodium channel activation parameter.
            m_inf = self.compute_mhinf( U, Am, Sm, dEm );

            % Compute the sodium channel current.
            I_na = self.compute_sodium_current( U, h, m_inf, Gna, dEna );
            
        end
        
        
        % Implement a function to compute the total current.
        function I_total = compute_total_current( ~, I_leak, I_syn, I_na, I_tonic, I_app )
            
           % Compute the the total current.
           I_total = I_leak + I_syn + I_na + I_tonic + I_app;
            
        end
        
        
        %% Neuron State Flow Functions
        
        % Implement a function to compute the derivative of the membrane voltage with respect to time.
        function dUs = compute_membrane_voltage_derivative( ~, Itotals, Cms )
            
            % Compute the membrane voltage derivative with respect to time.
            dUs = Itotals./Cms;
            
        end
        
        
        % Implement a function to compute the derivative of the sodium channel deactivation parameter with respect to time.
        function dhs = compute_sodium_deactivation_derivative( ~, hs, hinfs, tauhs )
            
            % Compute the sodium channel deactivation parameter derivative with respect to time.
            dhs = ( hinfs - hs )./tauhs;
            
        end
        
        
    end
    
    
end