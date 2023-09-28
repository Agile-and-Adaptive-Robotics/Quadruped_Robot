classdef network_utilities_class
    
    % This class contains properties and methods related to network utilities.
    
    
    %% NETWORK UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        array_utilities
        neuron_utilities
        numerical_method_utilities
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
    
        c_transmission_DEFAULT = 1;
        c_modulation_DEFAULT = 0.05;
        
        c_addition_DEFAULT = 1;
        c_subtraction_DEFAULT = 1;
        
        c_multiplication_DEFAULT = 1;
        c_inversion_DEFAULT = 1;
        c_division_DEFAULT = 1;
        
        c_derivation_DEFAULT = 1e6;
        w_derivation_DEFAULT = 1;
        sf_derivation_DEFAULT = 0.05;
        
        c_integration_mean_DEFAULT = 0.01e9;
        c_integration_range_DEFAULT = 0.01e9;

        Iapp_DEFAULT = 0;
        
    end
    
    
    %% NETWORK UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_utilities_class(  )
            
            % Create an instance of the array utilities class.
            self.array_utilities = array_utilities_class(  );
            
            % Create an instance of the neuron utilities class.
            self.neuron_utilities = neuron_utilities_class(  );
            
            % Create an instance of the numerical methods utilities class.
            self.numerical_method_utilities = numerical_method_utilities_class(  );
            
        end
        
        
        %% Synapse Functions
        
        % Implement a function to compute the synpatic conductance of a synapse leaving this neuron.
        function G_syn = compute_Gsyn( ~, U, R, g_syn_max )
            
            % Compute the synaptic conductance associated with this neuron.
            G_syn = g_syn_max.*( min( max( U'./R, 0 ), 1 ) );                   % CPG SUBNETWORK SEEMS TO REQUIR SATURATION...
%             G_syn = g_syn_max.*( U'./R );                                     % MULTIPLICATION SUBNETWORK SEEMS TO REQUIRE NO SATURATION...
            
        end
        
        
        % Implement a function to compute synaptic current.
        function I_syn = compute_Isyn( ~, U, G_syn, dE_syn )
            
            % Compute the synaptic current.
            I_syn = sum( G_syn.*( dE_syn - U ), 2 );
            
        end
        
        
        % Implement a function to perform a synaptic current step.
        function [ I_syn, G_syn ] = Isyn_step( self, U, R, g_syn_max, dE_syn )
            
            % Compute the synaptic conductance of this synapse leaving this neuron.
            G_syn = self.compute_Gsyn( U, R, g_syn_max );
            
            % Compute the synaptic current for this neuron.
            I_syn = self.compute_Isyn( U, G_syn, dE_syn );
            
        end
        
        
        %% Multistate CPG Subnetwork Design Functions
        
        % Implement a function to compute the maximum synaptic conductance.
        function g_syn_max_vector = compute_cpg_gsynmax_vector( self, deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, Iapps_tonic )
            
            % This function computes the maximum synaptic conductances for a chain of CPGs necessary to achieve the specified deltas with the given network properties.
            
            % Retrieve the number of neurons.
            num_neurons = length( Gms );
            
            % Define an anonymous function that is the opposite of the kronecker delta function.
            neq = @( a, b ) 1 - eq( a, b );
            
            % Compute the number of equations we need to solve.
            num_eqs = num_neurons.*( num_neurons - 1 );
            
            % Preallocate an array to store the system matrix and right-hand side.
            A = zeros( num_eqs, num_eqs );
            b = zeros( num_eqs, 1 );
            
            % Compute the system matrix and right-hand side entries.
            for k = 1:num_neurons               % Iterate through each of the neurons...
                
                % Compute the critical index p.
                p = mod( k, num_neurons ) + 1;
                
                % Compute the system matrix and right-hand side entries.
                for i = 1:num_neurons           % Iterate through each of the neurons...
                    
                    % Determine whether to compute system matrix and right-hand side entries for this synapse.
                    if i ~= k                   % If this synapse is not a self-connection...
                        
                        % Compute the leak current.
                        I_leak = self.neuron_utilities.compute_Ileak( deltas(i, k), Gms(i) );
                        
                        % Compute the sodium channel steady state activation and deactivation parameters.
                        m_inf = self.neuron_utilities.compute_mhinf( deltas(i, k), Ams(i), Sms(i), dEms(i) );
                        h_inf = self.neuron_utilities.compute_mhinf( deltas(i, k), Ahs(i), Shs(i), dEhs(i) );
                        
                        % Compute the sodium channel current.
                        I_na = self.neuron_utilities.compute_Ina( deltas(i, k), h_inf, m_inf, Gnas(i), dEnas(i) );
                        
                        % Compute the system and right-hand side coefficients.
                        aik1 = deltas( i, k ) - dEsyns( i, k );
                        aik2 = neq( p, k ).*( deltas( p, k )./Rs( p, k ) ).*( deltas( i, k ) - dEsyns( p, k ) );
                        bik = I_leak + I_na + Iapps_tonic(i);
                        
                        % Determine the row index at which to store these coefficients.
                        r = ( num_neurons - 1 ).*( k - 1 ) + i;
                        
                        % Determine whether to correct the row entry.
                        if i > k                % If this is an entry whose row index needs to be corrected...
                            
                            % Correct the row entry.
                            r = r - 1;
                            
                        end
                        
                        % Determine the column index at which to store the first coefficient.
                        c1 = ( num_neurons - 1 ).*( i - 1 ) + k;
                        
                        % Determine whether the first column index needs to be corrected.
                        if k > i                % If this is an entry whose first column index needs to be corrected...
                            
                            % Correct the first column index.
                            c1 = c1 - 1;
                            
                        end
                        
                        % Determine the column index at which to store the second coefficient.
                        c2 = ( num_neurons - 1 ).*( p - 1 ) + k;
                        
                        % Determine whether the second column index needs to be corrected.
                        if k > p                % If this is an entry whose second column index needs to be corrected...
                            
                            % Correct the second column index.
                            c2 = c2 - 1;
                            
                        end
                        
                        % Store the first and second system matrix coefficients.
                        A( r, c1 ) = A( r, c1 ) + aik1;
                        A( r, c2 ) = A( r, c2 ) + aik2;
                        
                        % Store the right-hand side coefficient.
                        b(r) = bik;
                        
                    end
                    
                end
            end
            
            % Solve the system of equations.
            g_syn_max_vector = A\b;
            
        end
        
        
        % Implement a function to convert a maximum synaptic conductance vector to a maximum synaptic conductance matrix.
        function g_syn_max_matrix = gsynmax_vector2gsynmax_matrix( ~, g_syn_max_vector, num_neurons )
            
            %             % Compute the number of neurons.
            %             num_neurons = sqrt( length( g_syn_max_vector ) );
            
            %             % Ensure that the number of neurons is an integer.
            %             assert( num_neurons == round( num_neurons ), 'Number of maximum synaptic conductances length( g_syn_max ) must be a perfect square.' )
            %
            % Preallocate the synaptic conductance matrix.
            g_syn_max_matrix = zeros( num_neurons );
            
            % Initialize the previous row variable.
            row_prev = 0;
            
            % Store each of the synaptic conductance vector entries into the synaptic conductance matrix.
            for k = 1:length( g_syn_max_vector )            % Iterate through each synaptic conductance...
                
                % Compute the relevant remainder and quotient.
                r = mod( k - 1, num_neurons - 1 );
                q = ( k - r - 1 )/( num_neurons - 1 );
                
                % Compute the row associated with this entry.
                row = q + 1;
                
                % Determine whether to reset the column associated with this entry.
                if row ~= row_prev              % If the current row is different than the previous row...
                    
                    % Reset the column index.
                    col = 0;
                    
                end
                
                % Advance the column index.
                col = col + 1;
                
                % Determine whether the column index needs to be advanced a second time.
                if row == col           % If this column would yield an entry on the diagonal...
                    
                    % Advance the column index a second time.
                    col = col + 1;
                    
                end
                
                % Store the current synaptic conductance vector entry into the correct synaptic conductance matrix location.
                g_syn_max_matrix( row, col ) = g_syn_max_vector(k);
                
                % Store the current row as the previous row for the next iteration.
                row_prev = row;
                
            end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance matrix.
        function g_syn_max_matrix = compute_cpg_gsynmax_matrix( self, deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, I_tonics )
            
            % Compute the maximum synaptic conductance vector.
            g_syn_max_vector = self.compute_cpg_gsynmax_vector( deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, I_tonics );
            
            % Retrieve the number of neurons.
            num_neurons = length( Gms );
            
            % Compute the maximum synaptic conductance matrix.
            g_syn_max_matrix = self.gsynmax_vector2gsynmax_matrix( g_syn_max_vector, num_neurons );
            
        end
        
                
        % Implement a function to compute the activation and deactivation periods.
        function [ Ta, Td ] = compute_activation_period( ~, T, n )
        
            % Compute the activation period.
            Ta = T/n;
            
            % Compute the deactivation period.
            Td = T - Ta;
            
        end
            
        
        %% Basic Transmission / Modulation Subnetwork Design Functions
        
        % Implement a function to compute the maximum synaptic conductance for a signal transmission pathway.
        function g_syn_max12 = compute_transmission_gsynmax( ~, Gm2, R1, dE_syn12, I_app2, k )
            
            % Set the default input arguments.
            if nargin < 6, k = self.c_transmission_DEFAULT; end
            if nargin < 5, I_app2 = self.Iapp_DEFAULT; end
                      
            % Determine how to compute the transmission maximum synaptic conductance.
            if k > 0                % If the specified gain is positive...
            
                % Compute the maximum synaptic conductances for a signal transmission pathway.
                g_syn_max12 = ( I_app2 - k.*Gm2.*R1 )./( k.*R1 - dE_syn12 );
            
                % Ensure that the synaptic reversal potential is large enough.
                assert( all( g_syn_max12 > 0 ), 'It is not possible to design a transmission pathway with the specified gain k = %0.2f [-] given the current synaptic reversal potential dEsyn = %0.2f [V] and neuron operating domain R = %0.2f [V].  To fix this problem, increase dE_syn.', k, dE_syn12, R1 )
                
            elseif k == 0           % If the specified gain is zero...
                
                % Set the maximum synaptic conductance to zero.
                g_syn_max12 = 0;
                
            else                    % If the specified gain is negative.                
                
                % Throw an error.
                error( 'Transmission synapse gain must be greater than or equal to zero.' )
                
            end
            
        end

        
        % Implement a function to compute the maximum synaptic conductance for a signal modulation pathway.
        function g_syn_max12 = compute_modulation_gsynmax( ~, Gm2, R1, R2, dE_syn12, I_app2, c )
            
            % Set the default input arguments.
            if nargin < 7, c = self.c_modulation_DEFAULT*( R2/R1 ); end
            if nargin < 6, I_app2 = self.Iapp_DEFAULT; end

            % Compute the maximum synaptic condcutance for a signal modulation pathway.
            g_syn_max12 = ( I_app2 + ( R2 - c.*R1 ).*Gm2 )./( c.*R1 - dE_syn12 );

            % Ensure that the synaptic reversal potential is large enough.
            assert( all( g_syn_max12 > 0 ), 'It is not possible to design a modulation pathway with the specified gain c = %0.2f [-] given the current synaptic reversal potential dEsyn = %0.2f [V] and neuron operating domain R = %0.2f [V].  To fix this problem, increase dE_syn.', c, dE_syn12, R1 )
            
        end

        
        %% Arithmetic Subnetwork Design Functions
        
        % Implement a function to compute the maximum synaptic conductances for an addition subnetwork.
        function [ g_syn_max13, g_syn_max23 ] = compute_addition_gsynmax( self, Gm3, R1, R2, dE_syn13, dE_syn23, I_app3, k )
            
            % Set the default input arguments.
            if nargin < 6, k = self.c_addition_DEFAULT; end
            if nargin < 5, I_app3 = self.Iapp_DEFAULT; end
            
            % Compute the maximum synaptic conductances in the same way as for a transmission subnetwork.
            g_syn_max13 = self.compute_transmission_gsynmax( Gm3, R1, dE_syn13, I_app3, k );
            g_syn_max23 = self.compute_transmission_gsynmax( Gm3, R2, dE_syn23, I_app3, k );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for a relative addition subnetwork.
        function [ g_syn_max13, g_syn_max23 ] = compute_relative_addition_gsynmax( self, Gm3, R1, R2, dE_syn13, dE_syn23, I_app3, k )
            
            % Set the default input arguments.
            if nargin < 6, k = self.c_addition_DEFAULT; end
            if nargin < 5, I_app3 = self.Iapp_DEFAULT; end
            
            % Compute the maximum synaptic conductances in the same way as for a transmission subnetwork.
            g_syn_max13 = self.compute_transmission_gsynmax( Gm3, R1, dE_syn13, I_app3, k );
            g_syn_max23 = self.compute_transmission_gsynmax( Gm3, R2, dE_syn23, I_app3, k );
            
        end
        

        % Implement a function to compute the maximum synaptic conductances for a subtraction subnetwork.
        function [ g_syn_max13, g_syn_max23 ] = compute_subtraction_gsynmax( self, Gm3, R1, dE_syn13, dE_syn23, I_app3, k )
            
            % Set the default input arguments.
            if nargin < 7, k = self.c_subtraction_DEFAULT; end
            if nargin < 6, I_app3 = self.Iapp_DEFAULT; end
            
            % Compute the maximum synaptic conductances for the first neuron of the substraction subnetwork.            
            g_syn_max13 = self.compute_transmission_gsynmax( Gm3, R1, dE_syn13, I_app3, k );

            % Compute the maximum synaptic conductances for the second neuron of the subtraction subnetwork.
            g_syn_max23 = -( dE_syn13*g_syn_max13 + I_app3 )./dE_syn23;
            
            % Ensure that the maximum synaptic condcutance for the second synapse is valid.
            assert( g_syn_max23 > 0, 'It is not possible to design the secon  synpase of this subtraction network given the current parameters.  g_syn_max23 must be positive.' )
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance for an inversion subnetwork.
        function g_syn_max = compute_inversion_gsynmax( self, Gm2, R1, I_app2, k, epsilon )
            
            % Set the default input arguments.
            if nargin < 6, epsilon = self.EPSILON_INVERSION; end
            if nargin < 5, k = self.K_INVERSION; end
            if nargin < 4, I_app2 = self.Iapp_DEFAULT; end
            
            % Compute the maximum synaptic conductance for the inversion subnetwork.
            g_syn_max = ( ( ( R1 + epsilon )*R1*I_app2 - k*R1*Gm2 )./( k*R1 ) );
                
        end
        
        
        % Implement a function to compute the input offset for a relative inversion subnetwork.
        function epsilon = compute_relative_inversion_epsilon( self, c )
            
           % Define the default input arguments.
           if nargin < 2, c = self.c_inversion_DEFAULT; end                 % [-] Inversion Subnetwork Gain
            
           % Compute the input offset.
           epsilon = ( -1 + sqrt( 1 + 4*c ) )/2;
           
        end
        
        
        % Implement a function compute the output offset for a relative inversion subnetwork.
        function delta = compute_relative_inversion_delta( self, c )
           
            % Define the default input arguments.
            if nargin < 2, c = self.c_inversion_DEFAULT; end                % [-] Inversion Subnetwork Gain
            
            % Compute the output offset.
            delta = 2./( -1 + sqrt( 1 + 4*c ) ) - ( 1./c );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for a division subnetwork.
        function [ g_syn_max13, g_syn_max23 ] = compute_division_gsynmax( self, Gm3, R1, R2, R3, dE_syn13, dE_syn23, I_app3, k, c )
        
            % Set the default input arguments.
            if ( nargin < 10 ) || ( isempty( c ) ), c = self.c_modulation_DEFAULT*( R3/R2 ); end
            if nargin < 9, k = self.c_division_DEFAULT; end
            if nargin < 8, I_app3 = self.Iapp_DEFAULT; end
            
            % Compute the maximum synaptic conductance for the first synapse.
            g_syn_max13 = self.compute_transmission_gsynmax( Gm3, R1, dE_syn13, I_app3, k );
            
            % Compute the maximum synaptic conductance for the second synapse.
            g_syn_max23 = self.compute_modulation_gsynmax( Gm3, R2, R3, dE_syn23, I_app3, c );
            
        end
            
        
        % Implement a function to compute the maximum synaptic conductances for a multiplication subnetwork.
        function [ g_syn_max14, g_syn_max23, g_syn_max34 ] = compute_multiplication_gsynmax( self, Gm3, Gm4, R1, R2, R3, R4, dE_syn14, dE_syn23, dE_syn34, I_app3, I_app4, k )
        
            % Set the default input arguments.
            if nargin < 13, k = self.c_multiplication_DEFAULT; end
            if nargin < 12, I_app4 = self.Iapp_DEFAULT; end
            if nargin < 11, I_app3 = self.Iapp_DEFAULT; end
            
            % Compute the maximum synaptic conductance for the first synapse.
            g_syn_max14 = self.compute_transmission_gsynmax( Gm4, R1, dE_syn14, I_app4, k );
            
            % Set the synaptic modulation parameter to zero.
            c = 0;
            
            % Compute the maximum synaptic conductance for the second synapse.
            g_syn_max23 = self.compute_modulation_gsynmax( Gm3, R2, R3, dE_syn23, I_app3, c );
            
            % Compute the maximum synaptic conductance for the third synapse.
            g_syn_max34 = self.compute_modulation_gsynmax( Gm4, R3, R4, dE_syn34, I_app4, c );
            
        end
        
        
        %% Derivation Subnetwork Design Functions
        
        % Implement a function to compute the maximum synaptic conductances for a derivative subnetwork.
        function [ g_syn_max13, g_syn_max23 ] = compute_derivation_gsynmax( self, Gm3, R1, dE_syn13, dE_syn23, I_app3, k )
            
            % Compute the maximum synaptic conductances for a derivative subnetwork in the same way as for a subtraction subnetwork.
            [ g_syn_max13, g_syn_max23 ] = self.compute_subtraction_gsynmax( Gm3, R1, dE_syn13, dE_syn23, I_app3, k );
            
        end
        
        
        % Implement a function to compute membrane conductance for a derivative subnetwork.
        function Gm = compute_derivation_Gm( ~, k, w, safety_factor )
            
            % Set the default input arugments.
            if nargin < 4, safety_factor = self.sf_derivation_DEFAULT; end
            if nargin < 3, w = self.w_derivation_DEFAULT; end
            if nargin < 2, k = self.c_derivation_DEFAULT; end
            
            % Compute the required membrance conductance.
            Gm = ( 1 - safety_factor )./( k.*w );    
            
        end
        
        
        % Implement a function to compute membrane capacitances for a derivative subnetwork.
        function [ Cm1, Cm2 ] = compute_derivation_Cms( ~, Gm, k, w )
            
            % Set the default input arugments.
            if nargin < 4, w = self.w_derivation_DEFAULT; end
            if nargin < 3, k = self.c_derivation_DEFAULT; end
            if nargin < 2, Gm = 1e-6; end
            
           % Compute the required time constant.
            tau = 1./w;
            
            % Compute the required membrane capacitance of the second neuron.
            Cm2 = Gm.*tau;
            
            % Compute the required membrane capacitance of the first neuron.
            Cm1 = Cm2 - ( Gm.^2 ).*k; 
            
        end
        
        
        %% Integration Subnetwork Design Functions
        
        % Implement a function to compute the membrane capacitances for an integration subnetwork.
        function Cm = compute_integration_Cm( ~, ki_mean )
        
            % Set the default input arguments.
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Compute the integration subnetwork membrane capacitance.
            Cm = 1./( 2*ki_mean );
            
        end
            
        
        % Implement a function to compute the maximum synaptic conductances for an integration subnetwork.
        function gs = compute_integration_gsynmax( ~, Gm, Cm, ki_range )
        
            % Set the default input arguments.
            if nargin < 4, ki_range = self.c_integration_range_DEFAULT; end
            
            % Compute the integration subnetwork maximum synaptic conductances.
            gs = ( -2*Gm.*Cm.*ki_range )./( Cm.*ki_range - 1 );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potentials for an integration subnetwork.
        function dEsyn = compute_integration_dEsyn( ~, Gm, R, gs )
        
           % Compute the synaptic reversal potentials for an integration subnetwork.
           dEsyn = - ( Gm*R )./gs;
            
        end
            
        
        % Implement a function to compute the applied current for an integration subnetwork.
        function Iapp = compute_integration_Iapp( ~, Gm, R )
            
            % Compute the applied current for an integration subnetwork.
            Iapp = Gm.*R;
            
        end
        
            
        %% Voltage Based Integration Design Functions
        
        % Implement a function to compute the desired intermediate synaptic current for a voltage based integration subnetwork.
        function I_syn12 = compute_vb_integration_Isyn( ~, R2, Ta, ki_mean, b_inhibition )

            % Set the default input arguments.
            if nargin < 5, b_inhibition = false; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Compute the intermediate synaptic current.
            I_syn12 = R2./( 2*Ta.*ki_mean );    
            
            % Determine whether to switch the sign on the intermediate synaptic current.
            if b_inhibition, I_syn12 = - I_syn12; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for a voltage based integration subnetwork.
        function g_syn_max12 = compute_vb_integration_gsynmax( ~, R2, dE_syn12, I_syn12 )
                    
            % Compute the maximum synaptic conductance for a voltage based integration subnetwork.
            g_syn_max12 = I_syn12./( dE_syn12 - ( R2/2 ) );
            
        end
            
        
        %% Network Functions
        
        
        
        %% Simulation Functions
        
        % Implement a function to perform a single simulation step.
        function [ dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = simulation_step( self, Us, hs, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps )
            
            % This function computes a single step of a neural network without sodium channels.
            
            % Inputs:
            % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.
            % hs = num_neurons x 1 vector of neuron sodium channel deactivation parameters.
            % Gms = num_neurons x 1 vector of neuron membrane conductances.
            % Cms = num_neurons x 1 vector of neuron membrane capacitances.
            % Rs = num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
            % g_syn_maxs = num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
            % dE_syns = num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
            % Ams = num_neurons x 1 vector of sodium channel activation A parameter values.
            % Sms = num_neurons x 1 vector of sodium channel activation S parameter values.
            % dEms = num_neurons x 1 vector of sodium channel activation parameter reversal potentials.
            % Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
            % Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
            % dEhs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
            % tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
            % Gnas = num_neurons x 1 vector of sodium channel conductances for each neuron.
            % dEnas = num_neurons x 1 vector of sodium channel reversal potentials for each neuron.
            % I_tonics = num_neurons x 1 vector of applied currents for each neuron.
            % I_apps = num_neurons x 1 vector of applied currents for each neuron.
            
            % Outputs:
            % dUs = num_neurons x 1 vector of neuron membrane voltage derivatives w.r.t their resting potentials.
            % dhs = num_neurons x 1 vector of neuron sodium channel deactivation parameter derivatives.
            % Gsyns = num_neurons x num_neurons matrix of synaptic conductances.  Entry ij represents the synaptic conductance from neuron j to neuron i.
            % Ileaks = num_neurons x 1 vector of leak currents for each neuron.
            % Isyns = num_neurons x 1 vector of synaptic currents for each neuron.
            % Inas = num_neurons x 1 vector of sodium channel currents for each neuron.
            % Itotals = num_neurons x 1 vector of total currents for each neuron.
            % minfs = num_neurons x 1 vector of neuron steady state sodium channel activation values.
            % hinfs = num_neurons x 1 vector of neuron steady state sodium channel deactivation values.
            % tauhs = num_neurons x 1 vector of sodium channel deactivation parameter time constants.
            
            % Compute the leak currents.
            I_leaks = self.neuron_utilities.compute_Ileak( Us, Gms );
            
            % Compute synaptic currents.
            [ I_syns, G_syns ] = self.Isyn_step( Us, Rs, g_syn_maxs, dE_syns );
            
            % Compute the sodium channel currents.
            [ I_nas, m_infs ] = self.neuron_utilities.Ina_step( Us, hs, Gnas, Ams, Sms, dEms, dEnas );
            
            % Compute the sodium channel deactivation time constant.
            [ tauhs, h_infs ] = self.neuron_utilities.tauh_step( Us, tauh_maxs, Ahs, Shs, dEhs );
            
            % Compute the total currents.
            I_totals = self.neuron_utilities.compute_Itotal( I_leaks, I_syns, I_nas, I_tonics, I_apps );
            
            % Compute the membrane voltage derivatives.
            dUs = self.neuron_utilities.compute_dU( I_totals, Cms );
            
            % Compute the sodium channel deactivation parameter derivatives.
            dhs = self.neuron_utilities.compute_dh( hs, h_infs, tauhs );
            
        end
        
        
        % Implement a function that defines the network flow.
        function dx = network_flow( self, t, x, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps )
           
            % Retrieve the number of states.
            num_states = length( x );
            
            % Ensure that the number of states is even.
            assert( ~mod( num_states, 2 ), 'The number of network flow states must be even.' )
            
            % Separate the input state into its voltage and sodium channel deactivation parameter components.
            Us = x( 1:num_states/2 );
            hs = x( ( num_states/2 + 1 ):end );
            
            % Perform a simulation step.
            [ dUs, dhs ] = self.simulation_step( Us, hs, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps );
            
            % Store the simulation step state derivatives into a single state variable.
            dx = [ dUs; dhs ];
            
        end
        
        
        % Implement a function to perform an integration step.
        function [ Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = integration_step( self, Us, hs, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps, V_apps_cell, dt, method )
        
            % Set the default input arguments.
            if nargin < 22, method = 'RK4'; end
            
            % Perform a single simulation step.
            [ ~, ~, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = self.simulation_step( Us, hs, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps );
            
            % Define the network flow.
            f = @( t, x ) self.network_flow( t, x, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps );
            
            % Determine how to perform a single numerical integration step.
            if strcmpi( method, 'FE' )                                                  % If the numerical integration method is set to FE...
                
                % Perform a single forward euler step.
                [ x, dx ] = self.numerical_method_utilities.FE( f, 0, [ Us; hs ], dt );
                
            elseif strcmpi( method, 'RK4' )                                             % If the numerical integration method is set to RK4...
                
                % Perform a single RK4 step.
                [ x, dx ] = self.numerical_method_utilities.RK4( f, 0, [ Us; hs ], dt );
                
            else                                                                        % Otherwise...
               
                % Throw an error.
                error( 'Numerical integration method %s not recognized.' )
                
            end

            % Retrieve the number of states.
            num_states = length(x)/2;
            
            % Extract the voltage and sodium deactivation parameter.
            Us = x( 1:num_states );
            hs = x( ( num_states + 1 ):end );
            
            % Extract the voltage and sodium deactivation parameter derivatives.
            dUs = dx( 1:num_states );
            dhs = dx( ( num_states + 1 ):end );
            
            % Determine whether there are applied voltages to consider.
            for k = 1:num_states                % Iterate through each of the states...
               
                if ~isempty(  V_apps_cell{ k } )
                    
                    Us( k ) = V_apps_cell{ k };
                    hs( k ) = self.neuron_utilities.compute_mhinf( Us( k ), Ahs( k ), Shs( k ), dEhs( k ) );
                    
                    dUs( k ) = 0;
                    dhs( k ) = 0;
                    
                end
                
            end
            
        end
            
        
        % Implement a function to simulate the network.
        function [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs ] = simulate( self, Us0, hs0, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps, V_apps_cell, tf, dt, method )
            
            % This function simulates a neural network described by Gms, Cms, Rs, gsyn_maxs, dEsyns with an initial condition of U0, h0 for tf seconds with a step size of dt and an applied current of Iapp.
            
            % Inputs:
            % Us0 = num_neurons x 1 vector of initial membrane voltages of each neuron w.r.t their resting potentials.
            % hs0 = num_neurons x 1 vector of initial sodium channel deactivation parameters for each neuron.
            % Gms = num_neurons x 1 vector of neuron membrane conductances.
            % Cms = num_neurons x 1 vector of neuron membrane capacitances.
            % Rs = num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
            % gsyn_maxs = num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
            % dEsyns = num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
            % Ams = num_neurons x 1 vector of sodium channel activation A parameter values.
            % Sms = num_neurons x 1 vector of sodium channel activation S parameter values.
            % dEms = num_neurons x 1 vector of sodium channel activation parameter reversal potentials.
            % Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
            % Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
            % dEhs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
            % tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
            % Gnas = num_neurons x 1 vector of sodium channel conductances for each neuron.
            % dEnas = num_neurons x 1 vector of sodium channel reversal potentials for each neuron.
            % Iapp = num_neurons x num_timesteps vector of applied currents for each neuron.
            % tf = Scalar that represents the simulation duration.
            % dt = Scalar that represents the simulation time step.
            
            % Outputs:
            % ts = 1 x num_timesteps vector of the time associated with each simulation step.
            % Us = num_neurons x num_timesteps matrix of the neuron membrane voltages over time w.r.t. their resting potentials.
            % hs = num_neurons x num_timesteps matrix of neuron sodium channel deactivation parameters.
            % dUs = num_neurons x num_timesteps matrix of neuron membrane voltage derivatives over time w.r.t their resting potentials.
            % dhs = num_neurons x num_timesteps matrix of neuron sodium channel deactivation parameter derivatives.
            % Gsyns = num_neurons x num_neurons x num_timesteps tensor of synapse conductances over time.  The ijk entry represens the synaptic condutance from neuron j to neuron i at time step k.
            % Ileaks = num_neurons x num_timsteps matrix of neuron leak currents over time.
            % Isyns = num_neurons x num_timesteps matrix of synaptic currents over time.
            % Inas = num_neurons x num_timesteps matrix of sodium channel currents for each neuron.
            % Itotals = num_neurons x num_timesteps matrix of total currents for each neuron.
            % minfs = num_neurons x num_timesteps matrix of neuron steady state sodium channel activation values.
            % hinfs = num_neurons x num_timesteps matrix of neuron steady state sodium channel deactivation values.
            % tauhs = num_neurons x num_timesteps matrix of sodium channel deactivation parameter time constants.
            
            % Set the default input arguments.
            if nargin < 23, method = 'RK4'; end
            
            % Compute the simulation time vector.
            ts = 0:dt:tf;
            
            % Compute the number of time steps.
            num_timesteps = length( ts );
            
            % Ensure that there are the correct number of applied currents.
            if size( I_apps, 2 ) ~= num_timesteps, error( 'size(Iapps, 2) must equal the number of simulation time steps.' ), end
            
            % Retrieve the number of neurons from the input dimensions.
            num_neurons = size( Us0, 1 );
            
            % Preallocate arrays to store the simulation data.
            [ Us, hs, dUs, dhs, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = deal( zeros( num_neurons, num_timesteps ) );
            
            % Preallocate a multidimensional array to store the synaptic conductances.
            G_syns = zeros( num_neurons, num_neurons, num_timesteps );
            
            % Set the initial network condition.
            Us( :, 1 ) = Us0; hs( :, 1 ) = hs0;
            
            % Simulate the network.
            for k = 1:( num_timesteps - 1 )               % Iterate through each timestep...
                
                % Perform a single integration step.
                [ Us( :, k + 1 ), hs( :, k + 1 ), dUs( :, k ), dhs( :, k ), G_syns( :, :, k ), I_leaks( :, k ), I_syns( :, k ), I_nas( :, k ), I_totals( :, k ), m_infs( :, k ), h_infs( :, k ), tauhs( :, k ) ] = self.integration_step( Us( :, k ), hs( :, k ), Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps( :, k ), V_apps_cell( :, k), dt, method );
                
            end
            
            % Advance the loop counter variable to perform one more network step.
            k = k + 1;
            
            % Compute the network state derivatives (as well as other intermediate network values).
            [ dUs( :, k ), dhs( :, k ), G_syns( :, :, k ), I_leaks( :, k ), I_syns( :, k ), I_nas( :, k ), I_totals( :, k ), m_infs( :, k ), h_infs( :, k ), tauhs( :, k ) ] = self.simulation_step( Us( :, k ), hs( :, k ), Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps( :, k ) );
            
        end
        
        
        %% Plotting Functions
        
        % Implement a function to plot the network currents over time.
        function fig = plot_network_currents( ~, ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 8, neuron_IDs = 1:size( I_totals, 1 ); end
            
            % Create a figure to store the network applied currents.
            fig = figure( 'Color', 'w', 'Name', 'Network Applied Currents vs Time' );
            subplot( 5, 1, 1 ), hold on, grid on, xlabel( 'Time [s]' ), ylabel( 'Leak Current, $I_{leak}$ [A]', 'Interpreter', 'Latex' ), title( 'Leak Current vs Time' )
            subplot( 5, 1, 2 ), hold on, grid on, xlabel( 'Time [s]' ), ylabel( 'Synaptic Current, $I_{syn}$ [A]', 'Interpreter', 'Latex' ), title( 'Synaptic Current vs Time' )
            subplot( 5, 1, 3 ), hold on, grid on, xlabel( 'Time [s]' ), ylabel( 'Sodium Current, $I_{na}$ [A]', 'Interpreter', 'Latex' ), title( 'Sodium Current vs Time' )
            subplot( 5, 1, 4 ), hold on, grid on, xlabel( 'Time [s]' ), ylabel( 'Applied Current, $I_{app}$ [A]', 'Interpreter', 'Latex' ), title( 'Applied Current vs Time' )
            subplot( 5, 1, 5 ), hold on, grid on, xlabel( 'Time [s]' ), ylabel( 'Total Current, $I_{total}$ [A]', 'Interpreter', 'Latex' ), title( 'Total Current vs Time' )

            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Prellocate an array to store the legend entries.
            legstr = cell( 1, num_neurons );
            
            % Plot the currents associated with each neuron.
            for k = 1:num_neurons                       % Iterate through each neuron...
               
                % Plot the currents associated with this neuron.
                subplot( 5, 1, 1 ), plot( ts, I_leaks( k, : ), '-', 'Linewidth', 3 )
                subplot( 5, 1, 2 ), plot( ts, I_syns( k, : ), '-', 'Linewidth', 3 )
                subplot( 5, 1, 3 ), plot( ts, I_nas( k, : ), '-', 'Linewidth', 3 )
                subplot( 5, 1, 4 ), plot( ts, I_apps( k, : ), '-', 'Linewidth', 3 )
                subplot( 5, 1, 5 ), plot( ts, I_totals( k, : ), '-', 'Linewidth', 3 )

                % Add an entry to our legend string.
                legstr{k} = sprintf( 'Neuron %0.0f', neuron_IDs( k ) );
                
            end
            
            % Add a legend to the plot.
            subplot( 5, 1, 5 ), legend( legstr, 'Location', 'Southoutside', 'Orientation', 'Horizontal' )
            
        end
        
        
        % Implement a function to plot the network states over time.
        function fig = plot_network_states( ~, ts, Us, hs, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 5, neuron_IDs = 1:size( Us, 1 ); end
            
            % Create a figure to store the network states.
            fig = figure( 'Color', 'w', 'Name', 'Network States vs Time' );
            subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Time, $t$ [s]', 'Interpreter', 'Latex' ), ylabel( 'Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex' ), title( 'CPG Membrane Voltage vs Time' )
            subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Time, $t$ [s]', 'Interpreter', 'Latex' ), ylabel( 'Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex' ), title( 'CPG Sodium Channel Deactivation Parameter vs Time' )
            
            % Retrieve the number of neurons.
            num_neurons = size( Us, 1 );
            
            % Prellocate an array to store the legend entries.
            legstr = cell( 1, num_neurons );
            
            % Plot the states of each neuron over time.
            for k = 1:num_neurons           % Iterate through each of the neurons.
                
                % Plot the states associated with this neuron.
                subplot( 2, 1, 1 ), plot( ts, Us( k, : ), '-', 'Linewidth', 3 )
                subplot( 2, 1, 2 ), plot( ts, hs( k, : ), '-', 'Linewidth', 3 )
                
                % Add an entry to our legend string.
                legstr{k} = sprintf( 'Neuron %0.0f', neuron_IDs( k ) );
                
            end
            
            % Add a legend to the plots.
            subplot( 2, 1, 1 ), legend( legstr, 'Location', 'Southoutside', 'Orientation', 'Horizontal' )
            subplot( 2, 1, 2 ), legend( legstr, 'Location', 'Southoutside', 'Orientation', 'Horizontal' )
            
        end
        
        
        % Implement a function to animate the network states over time.
        function fig = animate_network_states( self, Us, hs, neuron_IDs, num_playbacks, playback_speed )
            
            % Set the default input arguments.
            if nargin < 6, playback_speed = 1; end
            if nargin < 5, num_playbacks = 1; end
            if nargin < 4, neuron_IDs = 1:size( Us, 1 ); end
            
            % Compute the state space domain of interest.
            U_min = min( Us, [  ], 'all' ); U_max = max( Us, [  ], 'all' );
            h_min = min( hs, [  ], 'all' ); h_max = max( hs, [  ], 'all' );
            
            % Retrieve the number of neurons.
            num_neurons = size( Us, 1 );
            
            % Retrieve the number of time steps.
            num_timesteps = size( Us, 2 );
            
            % Ensure that the voltage domain is not degenerate.
            if U_min == U_max                           % If the minimum voltage is equal to the maximum voltage...
                
                % Scale the given domain.
                domain = self.array_utilities.scale_domain( [ U_min U_max ], 0.25, 'absolute' );
                
                % Set the minimum and maximum voltage domain.
                U_min = domain(1); U_max = domain(2);
                
            end
            
            % Ensure that the sodium deactivation domain is not degenerate.
            if h_min == h_max                           % If the minimum sodium deactivation parameter is equal to the maximum sodium deactivation parameter...
                
                % Scale the given domain.
                domain = self.array_utilities.scale_domain( [ h_min h_max ], 0.25, 'absolute' );
                
                % Set the minimum and maximum voltage domain.
                h_min = domain(1); h_max = domain(2);
                
            end
            
            % Create a plot to store the CPG's State Space Trajectory animation.
            fig = figure( 'Color', 'w', 'Name', 'Network State Trajectory Animation' ); hold on, grid on, xlabel( 'Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex' ), ylabel( 'Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex' ), title( 'Network State Space Trajectory' ), axis( [ U_min U_max h_min h_max ] )
            
            % Preallocate arrays to store the figure elements.
            line_paths = gobjects( num_neurons, 1 );
            line_ends = gobjects( num_neurons, 1 );
            
            % Prellocate an array to store the legend entries.
            legstr = cell( 1, num_neurons );
            
            % Compute the number of frames.
            num_frames = floor( ( num_timesteps - 1 )/playback_speed ) + 1;
            
            % Define the percentage of the total number of frames that should persist during the animation.
            frame_persist_percentage = 0.125;       % Works for two neurons CPGs.
%             frame_persist_percentage = 0.10;         % Works for multistate CPGs.

            
            % Compute the number of frames that should persist during the animation.
            num_frames_persist = floor( frame_persist_percentage*num_frames );
            
            % Create the figure elements associated with each of the neurons.
            for k = 1:num_neurons               % Iterate through each of the neurons...
                
                % Create data source strings for the path figure element.
%                 xdatastr_path = sprintf( 'Us(%0.0f, 1:k)', k );
%                 ydatastr_path = sprintf( 'hs(%0.0f, 1:k)', k );
                xdatastr_path = sprintf( 'Us(%0.0f, max( k - num_frames_persist, 1 ):k)', k );
                ydatastr_path = sprintf( 'hs(%0.0f, max( k - num_frames_persist, 1 ):k)', k );
                
                % Add this path figure element to the array of path figure elements.
                line_paths(k) = plot( 0, 0, '-', 'Linewidth', 2, 'XDataSource', xdatastr_path, 'YDataSource', ydatastr_path );
                
                % Create data source strings for each end point figure element.
                xdatastr_end = sprintf( 'Us(%0.0f, k)', k );
                ydatastr_end = sprintf( 'hs(%0.0f, k)', k );
                
                % Add this path figure element to the array of end figure elements.
                line_ends(k) = plot( 0, 0, 'o', 'Linewidth', 2, 'Markersize', 15, 'Color', line_paths(k).Color, 'XDataSource', xdatastr_end, 'YDataSource', ydatastr_end );
                
                % Add an entry to our legend string.
                legstr{k} = sprintf( 'Neuron %0.0f', neuron_IDs( k ) );
                
            end
            
            % Add a legend to the plot.
            legend( line_ends, legstr, 'Location', 'Southoutside', 'Orientation', 'Horizontal' )
            
            % Animate the figure.
            for j = 1:num_playbacks                     % Iterate through each play back...
                for k = 1:playback_speed:num_timesteps              % Iterate through each of the angles...
                    
                    % Refresh the plot data.
                    refreshdata( [ line_paths, line_ends ], 'caller' )
                    
                    % Update the plot.
                    drawnow
                    
                end
            end
            
        end
        
        
    end
end

