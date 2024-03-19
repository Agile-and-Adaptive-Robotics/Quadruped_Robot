classdef network_utilities_class
    
    % This class contains properties and methods related to network utilities.
    
    
    %% NETWORK UTILITIES PROPERTIES.
    
    % Define the class properties.
    properties
        
        array_utilities                                     % [class] Performs common array operations.
        neuron_utilities                                    % [class] Performs neuron specific operations.
        numerical_method_utilities                          % [class] Performs common numerical method operations.
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
    
        c_transmission_DEFAULT = 1;                         % [-] Transmission Subnetwork Default Gain.
        c_modulation_DEFAULT = 0.05;                        % [-] Modulation Subnetwork Default Gain.
        
        c_addition_DEFAULT = 1;                             % [-] Addition Subnetwork Default Gain.
        c_subtraction_DEFAULT = 1;                          % [-] Subtraction Subnetwork Default Gain.
        
        c_multiplication_DEFAULT = 1;                       % [-] Multiplication Subnetwork Default Gain.
        c_inversion_DEFAULT = 1;                            % [-] Inversion Subnetwork Default Gain.
        c_division_DEFAULT = 1;                             % [-] Division Subnetwork Default Gain.
        
        c_derivation_DEFAULT = 1e6;                         % [-] Derivation Subnetwork Default Gain.
        w_derivation_DEFAULT = 1;                           % [-] Derivation Subnetwork Default Cut Off.
        sf_derivation_DEFAULT = 0.05;                       % [-] Derivation Subnetwork Default Safety Factor.
        
        c_integration_mean_DEFAULT = 0.01e9;                % [-] Integration Subnetwork Default Average Gain.
        c_integration_range_DEFAULT = 0.01e9;               % [-] Integration Subnetwork Default Gain Range.

        Iapp_DEFAULT = 0;                                   % [-] Default Applied Current.
        
    end
    
    
    %% NETWORK UTILITIES METHODS SETUP.
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_utilities_class(  )
            
            % Create an instance of the array utilities class.
            self.array_utilities = array_utilities_class(  );                               % [class] Collection of Array Operations.
            
            % Create an instance of the neuron utilities class.
            self.neuron_utilities = neuron_utilities_class(  );                             % [class] Collection of Neuron Operations.
            
            % Create an instance of the numerical methods utilities class.
            self.numerical_method_utilities = numerical_method_utilities_class(  );         % [class] Collection of Numerical Method Operations.
            
        end
        
        
        %% Synapse Functions.
        
        % Implement a function to compute the synpatic conductance of a synapse leaving this neuron.
        function G_syn = compute_Gsyn( ~, U, R, g_syn_max )
                    
            %{
            Input(s):
                U           =   [V] Membrane Voltage.
                R           =   [V] Maximum Membrane Voltage.
                g_syn_max   =   [S] Maximum Synaptic Conductance.
            
            Output(s):
                G_syn       =   [S] Synaptic Conductance.
            %}
                
            % Compute the synaptic conductance associated with this neuron. % CPG SUBNETWORK SEEMS TO REQUIRE SATURATION... % MULTIPLICATION SUBNETWORK SEEMS TO REQUIRE NO SATURATION...
            G_syn = g_syn_max.*( min( max( U'./R, 0 ), 1 ) );                           % [S] Synaptic Conductance.
%             G_syn = g_syn_max.*( U'./R );                                     
            
        end
        
        
        % Implement a function to compute synaptic current.
        function I_syn = compute_Isyn( ~, U, G_syn, dE_syn )
            
            %{
            Input(s):
                U       =   [V] Membrane Voltage.
                G_syn   =   [S] Synaptic Conductance.
                dE_syn  =   [V] Synaptic Reversal Potential.
            
            Output(s):
                I_syn   =   [A] Synaptic Current.
            %}
            
            % Compute the synaptic current.
            I_syn = sum( G_syn.*( dE_syn - U ), 2 );                % [A] Synaptic Current.
            
        end
        
        
        % Implement a function to perform a synaptic current step.
        function [ I_syn, G_syn ] = Isyn_step( self, U, R, g_syn_max, dE_syn )
            
            %{
            Input(s):
                U           =   [V] Membrane Voltage.
                R           =   [V] Maximum Membrane Voltage.
                g_syn_max	=   [S] Maximum Synaptic Conductance.
                dE_syn      =   [V] Synaptic Reversal Potential.
            
            Output(s):
                I_syn       =   [A] Synaptic Current.
                G_syn       =   [S] Synaptic Conductance.
            %}
            
            % Compute the synaptic conductance of this synapse leaving this neuron.
            G_syn = self.compute_Gsyn( U, R, g_syn_max );
            
            % Compute the synaptic current for this neuron.
            I_syn = self.compute_Isyn( U, G_syn, dE_syn );
            
        end
        
        
        %% Multistate CPG Subnetwork Design Functions.
        
        % Implement a function to compute the maximum synaptic conductance.
        function g_syn_max_vector = compute_cpg_gsynmax_vector( self, deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, Iapps_tonic )
            
            %{
            Input(s):
                deltas              =   [V] Bifurcation Parameter
                Gms                 =   [S] Membrane Conductance
                Rs                  =   [V] Maximum Membrane Voltage
                dEsyns              =   [V] Synaptic Reversal Potential
                Gnas                =   [S] Ion channel Conductance
                Ams                 =   [-] Ion Channel Activation Amplitude
                Sms                 =   [-] Ion Channel Activation Slope
                dEms                =   [-] Ion Channel Activation Offset
                Ahs                 =   [-] Ion Channel Deactivation Amplitude
                Shs                 =   [-] Ion Channel Deactivation Slope
                dEhs                =   [-] Ion Channel Deactivation Offset
                dEnas               =   [V] Ion Channel Reversal Potential
                Iapps_tonic         =   [A] Applied Currents
            
            Output(s):
                g_syn_max_vector    =   [S] Maxmimum Synaptic Conductances (Column Vector) 
            %}
            
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
                        I_leak = self.neuron_utilities.compute_Ileak( deltas( i, k ), Gms( i ) );
                        
                        % Compute the sodium channel steady state activation and deactivation parameters.
                        m_inf = self.neuron_utilities.compute_mhinf( deltas( i, k ), Ams( i ), Sms( i ), dEms( i ) );
                        h_inf = self.neuron_utilities.compute_mhinf( deltas( i, k ), Ahs( i ), Shs( i ), dEhs( i ) );
                        
                        % Compute the sodium channel current.
                        I_na = self.neuron_utilities.compute_Ina( deltas( i, k ), h_inf, m_inf, Gnas( i ), dEnas( i ) );
                        
                        % Compute the system and right-hand side coefficients.
                        aik1 = deltas( i, k ) - dEsyns( i, k );
                        aik2 = neq( p, k ).*( deltas( p, k )./Rs( p, k ) ).*( deltas( i, k ) - dEsyns( p, k ) );
                        bik = I_leak + I_na + Iapps_tonic( i );
                        
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
            
            %{
            Input(s):
                g_syn_max_vector    =   [S] Maximum Synaptic Conductance Vector
                num_neurons         =   [#] Number of Neurons
            
            Output(s):
                g_syn_max_matrix    =   Maximum Synaptic Conductance Matrix
            %}

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
                g_syn_max_matrix( row, col ) = g_syn_max_vector( k );
                
                % Store the current row as the previous row for the next iteration.
                row_prev = row;
                
            end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance matrix.
        function g_syn_max_matrix = compute_cpg_gsynmax_matrix( self, deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, I_tonics )
            
            %{
            Input(s):
                deltas              =   [V] Bifurcation Parameter
                Gms                 =   [S] Membrane Conductance
                Rs                  =   [V] Maximum Membrane Voltage
                dEsyns              =   [V] Synaptic Reversal Potential
                Gnas                =   [S] Ion channel Conductance
                Ams                 =   [-] Ion Channel Activation Amplitude
                Sms                 =   [-] Ion Channel Activation Slope
                dEms                =   [-] Ion Channel Activation Offset
                Ahs                 =   [-] Ion Channel Deactivation Amplitude
                Shs                 =   [-] Ion Channel Deactivation Slope
                dEhs                =   [-] Ion Channel Deactivation Offset
                dEnas               =   [V] Ion Channel Reversal Potential
                I_tonics            =   [A] Applied Currents
            
            Output(s):
                g_syn_max_matrix    =   [S] Maxmimum Synaptic Conductances (Matrix) 
            %}
            
            % Compute the maximum synaptic conductance vector.
            g_syn_max_vector = self.compute_cpg_gsynmax_vector( deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, I_tonics );
            
            % Retrieve the number of neurons.
            num_neurons = length( Gms );
            
            % Compute the maximum synaptic conductance matrix.
            g_syn_max_matrix = self.gsynmax_vector2gsynmax_matrix( g_syn_max_vector, num_neurons );
            
        end
        
                
        % Implement a function to compute the activation and deactivation periods.
        function [ Ta, Td ] = compute_activation_period( ~, T, n )
        
            %{
            Input(s):
                T   =   [s] Total Period.
                n   =   [#] Number of Cycles.
            
            Output(s):
                Ta  =   [s] Activation Period.
                Td  =   [s] Deactivation Period.
            %}
            
            % Compute the activation period.
            Ta = T/n;
            
            % Compute the deactivation period.
            Td = T - Ta;
            
        end
            
        
        %% Basic Transmission / Modulation Subnetwork Design Functions.
        
        % Implement a function to compute the maximum synaptic conductance for a signal transmission pathway.
        function g_syn_max12 = compute_transmission_gsynmax( ~, Gm2, R1, dE_syn12, I_app2, k )
            
            %{
            Input(s):
                Gm2             =   [S] Membrane Conductance (Neuron 2).
                R1              =   [V] Maximum Membrane Voltage (Neuron 1).
                dE_syn12        =   [V] Synaptic Reversal Potential (Synapse 12).
                I_app2          =   [A] Applied Current (Neuron 2).
                k               =   [-] Transmission Gain.
            
            Output(s):
                g_syn_max12     =   [S] Maximum Synaptic Conductance (Synapce 12).
            %}
            
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
            
            %{
            Input(s):
                Gm2             =   [S] Membrane Conductance (Neuron 2).
                R1              =   [V] Maximum Membrane Voltage (Neuron 1).
                R2              =   [V] Maximum Membrane Voltage (Neuron 2).
                dE_syn12        =   [V] Synaptic Reversal Potential (Synapse 12).
                I_app2          =   [A] Applied Current (Neuron 2).
                c               =   [-] Modulation Gain.
            
            Output(s):
                g_syn_max12     =   [S] Maximum Synaptic Conductance (Synapce 12).
            %}
            
            % Set the default input arguments.
            if nargin < 7, c = self.c_modulation_DEFAULT*( R2/R1 ); end
            if nargin < 6, I_app2 = self.Iapp_DEFAULT; end

            % Compute the maximum synaptic condcutance for a signal modulation pathway.
            g_syn_max12 = ( I_app2 + ( R2 - c.*R1 ).*Gm2 )./( c.*R1 - dE_syn12 );

            % Ensure that the synaptic reversal potential is large enough.
            assert( all( g_syn_max12 > 0 ), 'It is not possible to design a modulation pathway with the specified gain c = %0.2f [-] given the current synaptic reversal potential dEsyn = %0.2f [V] and neuron operating domain R = %0.2f [V].  To fix this problem, increase dE_syn.', c, dE_syn12, R1 )
            
        end

        
        %% Arithmetic Subnetwork Design Functions.
        
        % Implement a function to compute the maximum synaptic conductances for an addition subnetwork.
        function [ g_syn_max13, g_syn_max23 ] = compute_addition_gsynmax( self, Gm3, R1, R2, dE_syn13, dE_syn23, I_app3, k )
            
            %{
            Input(s):
                Gm3             =   [S] Membrane Conductance (Neuron 3).
                R1              =   [V] Maximum Membrane Voltage (Neuron 1).
                R2              =   [V] Maximum Membrane Voltage (Neuron 2).
                dE_syn13        =   [V] Synaptic Reversal Potential (Synapse 13).
                dE_syn23        =   [V] Synaptic Reversal Potential (Synapse 23).
                I_app3          =   [A] Applied Current (Neuron 3).
            
            Output(s):
                g_syn_max13     =   [S] Maximum Synaptic Conductance (Syanpse 13).
                g_syn_max23     =   [S] Maximum Synaptic Conductnace (Synapse 23).
            %}
            
            % Set the default input arguments.
            if nargin < 6, k = self.c_addition_DEFAULT; end
            if nargin < 5, I_app3 = self.Iapp_DEFAULT; end
            
            % Compute the maximum synaptic conductances in the same way as for a transmission subnetwork.
            g_syn_max13 = self.compute_transmission_gsynmax( Gm3, R1, dE_syn13, I_app3, k );
            g_syn_max23 = self.compute_transmission_gsynmax( Gm3, R2, dE_syn23, I_app3, k );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for a relative addition subnetwork.
        function [ g_syn_max13, g_syn_max23 ] = compute_relative_addition_gsynmax( self, Gm3, R1, R2, dE_syn13, dE_syn23, I_app3, k )
            
            %{
            Input(s):
                Gm3             =   [S] Membrane Conductance (Neuron 3).
                R1              =   [V] Maximum Membrane Voltage (Neuron 1).
                R2              =   [V] Maximum Membrane Voltage (Neuron 2).
                dE_syn13        =   [V] Synaptic Reversal Potential (Synapse 13).
                dE_syn23        =   [V] Synaptic Reversal Potential (Synapse 23).
                I_app3          =   [A] Applied Current (Neuron 3).
                k               =   [-] Relative Transmission Gain.

            Output(s):
                g_syn_max13     =   [S] Maximum Synaptic Conductance (Syanpse 13).
                g_syn_max23     =   [S] Maximum Synaptic Conductnace (Synapse 23).
            %}
            
            % Set the default input arguments.
            if nargin < 6, k = self.c_addition_DEFAULT; end
            if nargin < 5, I_app3 = self.Iapp_DEFAULT; end
            
            % Compute the maximum synaptic conductances in the same way as for a transmission subnetwork.
            g_syn_max13 = self.compute_transmission_gsynmax( Gm3, R1, dE_syn13, I_app3, k );
            g_syn_max23 = self.compute_transmission_gsynmax( Gm3, R2, dE_syn23, I_app3, k );
            
        end
        

        % Implement a function to compute the maximum synaptic conductances for a subtraction subnetwork.
        function [ g_syn_max13, g_syn_max23 ] = compute_subtraction_gsynmax( self, Gm3, R1, dE_syn13, dE_syn23, I_app3, k )
            
            %{
            Input(s):
                Gm3             =   [S] Membrane Conductance (Neuron 3).
                R1              =   [V] Maximum Membrane Voltage (Neuron 1).
                dE_syn13        =   [V] Synaptic Reversal Potential (Synapse 13).
                dE_syn23        =   [V] Synaptic Reversal Potential (Synapse 23).
                I_app3          =   [A] Applied Current.
                k               =   [-] Subtraction Gain.
            
            Output(s):
                g_syn_max13     =   [S] Maximum Synaptic Conductance (Syanpse 13).
                g_syn_max23     =   [S] Maximum Synaptic Conductnace (Synapse 23).
            %}
            
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
            
            %{
            Input(s):
                Gm2         =   [S] Membrane Conductance (Neuron 2).
                R1          =   [V] Maximum Membrane Voltage (Neuron 1).
                I_app2      =   [A] Applied Current (Neuron 2).
                k           =   [-] Inversion Gain.
                epsilon     =   [V] Inversion Offset.
            
            Output(s):
                g_syn_max   =   [S] Maximum Synaptic Conductance.
            %}
            
            % Set the default input arguments.
            if nargin < 6, epsilon = self.EPSILON_INVERSION; end
            if nargin < 5, k = self.K_INVERSION; end
            if nargin < 4, I_app2 = self.Iapp_DEFAULT; end
            
            % Compute the maximum synaptic conductance for the inversion subnetwork.
            g_syn_max = ( ( ( R1 + epsilon )*R1*I_app2 - k*R1*Gm2 )./( k*R1 ) );
                
        end
        
        
        % Implement a function to compute the input offset for a relative inversion subnetwork.
        function epsilon = compute_relative_inversion_epsilon( self, c )
            
            %{
            Input(s):
                c           =   [-] Relative Inversion Subnetwork Gain
            
            Output(s):
                epsilon     =   [-] Relative Inversion Subnetwork Input Offset
            %}
            
           % Define the default input arguments.
           if nargin < 2, c = self.c_inversion_DEFAULT; end                 % [-] Inversion Subnetwork Gain
            
           % Compute the input offset.
           epsilon = ( -1 + sqrt( 1 + 4*c ) )/2;
           
        end
        
        
        % Implement a function compute the output offset for a relative inversion subnetwork.
        function delta = compute_relative_inversion_delta( self, c )
           
            %{
            Input(s):
                c           =   [-] Relative Inversion Subnetwork Gain
            
            Output(s):
                epsilon     =   [-] Relative Inversion Subnetwork Output Offset
            %}
            
            % Define the default input arguments.
            if nargin < 2, c = self.c_inversion_DEFAULT; end                % [-] Inversion Subnetwork Gain
            
            % Compute the output offset.
            delta = 2./( -1 + sqrt( 1 + 4*c ) ) - ( 1./c );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for a division subnetwork.
        function [ g_syn_max13, g_syn_max23 ] = compute_division_gsynmax( self, Gm3, R1, R2, R3, dE_syn13, dE_syn23, I_app3, k, c )
        
            %{
            Input(s):
                Gm3             =   [S] Membrane Conductance (Neuron 3).
                R1              =   [V] Maximum Membrane Voltage (Neuron 1).
                R2              =   [V] Maximum Membrane Voltage (Neuron 2).
                R3              =   [V] Maximum Membrane Voltage (Neuron 3).
                dE_syn13        =   [V] Synaptic Reversal Potential (Synapse 13).
                dE_syn23        =   [V] Synapticv Reversal Potential (Synapse 23).
                I_app3          =   [A] Applied Current (Neuron 3).
                k               =   [-] Division Subnetwork Gain.
                c               =   [-] Modulation Subnetwork Gain.
            
            Output(s):
                g_syn_max13     =   [S] Maximum Synaptic Conductance (Synapse 13).
                g_syn_max23     =   [S] Maximum Synaptic Conductance (Synapse 23).
            %}
            
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
        
            %{
            Input(s):
                Gm3             =   [S] Membrane Conductance (Neuron 3).
                Gm4             =   [S] Membrane Conductance (Neuron 4).
                R1              =   [V] Maximum Membrane Voltage (Neuron 1).
                R2              =   [V] Maximum Membrane Voltage (Neuron 2).
                R3              =   [V] Maximum Membrane Voltage (Neuron 3).
                R4              =   [V] Maximum Membrane Voltage (Neuron 4).
                dE_syn14        =   [V] Synaptic Reversal Potential (Synapse 14).
                dE_syn23        =   [V] Synapatic Reversal Potential (Synapse 23).
                dE_syn34        =   [V] Synaptic Reversal Potential (Synapse 34).
                I_app3          =   [A] Applied Current (Neuron 3).
                I_app4          =   [A] Applied Current (Neuron 4).
                k               =   [-] Multiplication Subnetwork Gain.
            
            Output(s):
                g_syn_max14     =   [S] Maximum Synaptic Conductance (Synapse 14).
                g_syn_max23     =   [S] Maximum Synaptic Conductance (Synapse 23).
                g_syn_max34     =   [S] Maximum Synaptic Conductance (Synapse 34).
            %}
            
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
        
        
        %% Derivation Subnetwork Design Functions.
        
        % Implement a function to compute the maximum synaptic conductances for a derivative subnetwork.
        function [ g_syn_max13, g_syn_max23 ] = compute_derivation_gsynmax( self, Gm3, R1, dE_syn13, dE_syn23, I_app3, k )
            
            %{
            Input(s):
                Gm3             =   [S] Membrane Conductance (Neuron 3).
                R1              =   [V] Maximum Membrane Voltage (Neuron 1).
                dE_syn13        =   [V] Synaptic Reversal Potential (Synapse 13).
                dE_syn23        =   [V] Synaptic Reversal Potential (Synapse 23).
                I_app3          =   [A] Applied Current (Neuron 3).
                k               =   [-] Derivation Subnetwork Gain.
            
            Output(s):
                g_syn_max13     =   [S] Maximum Synaptic Conductance (Synapse 13).
                g_syn_max23     =   [S] Maximum Synaptic Conductnace (Synapse 23).
            %}
            
            % Compute the maximum synaptic conductances for a derivative subnetwork in the same way as for a subtraction subnetwork.
            [ g_syn_max13, g_syn_max23 ] = self.compute_subtraction_gsynmax( Gm3, R1, dE_syn13, dE_syn23, I_app3, k );
            
        end
        
        
        % Implement a function to compute membrane conductance for a derivative subnetwork.
        function Gm = compute_derivation_Gm( ~, k, w, safety_factor )
            
            %{
            Input(s):
                k               =   [-] Derivation Subnetwork Gain.
                w               =   [-] Derivation Subnetwork Cutoff.
                safety_factor   =   [-] Derivation Subnetwork Safety Factor.
            
            Output(s):
                Gm              =   [S] Membrane Conductance.
            %}
            
            % Set the default input arugments.
            if nargin < 4, safety_factor = self.sf_derivation_DEFAULT; end
            if nargin < 3, w = self.w_derivation_DEFAULT; end
            if nargin < 2, k = self.c_derivation_DEFAULT; end
            
            % Compute the required membrance conductance.
            Gm = ( 1 - safety_factor )./( k.*w );    
            
        end
        
        
        % Implement a function to compute membrane capacitances for a derivative subnetwork.
        function [ Cm1, Cm2 ] = compute_derivation_Cms( ~, Gm, k, w )
            
            %{
            Input(s):
                Gm = [S] Membrane Conductance.
                k = [-] Derivation Subnetwork Gain.
            `   w = [-] Derivation Subnetwork Cutoff.
            
            Output(s):
                Cm1 = [F] Membrane Conductance (Neuron 1).
                Cm2 = [F] Membrane Conductnace (Neuron 2).
            %}
            
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
        
        
        %% Integration Subnetwork Design Functions.
        
        % Implement a function to compute the membrane capacitances for an integration subnetwork.
        function Cm = compute_integration_Cm( ~, ki_mean )
        
            %{
            Input(s):
                ki_mean     =   [-] Intergration Subnetwork Gain.
            
            Output(s):
                Cm          =   [F] Membrane Conductance.
            %}
            
            % Set the default input arguments.
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Compute the integration subnetwork membrane capacitance.
            Cm = 1./( 2*ki_mean );
            
        end
            
        
        % Implement a function to compute the maximum synaptic conductances for an integration subnetwork.
        function gs = compute_integration_gsynmax( ~, Gm, Cm, ki_range )
        
            %{
            Input(s):
                Gm          =   [S] Membrane Conductance.
                Cm          =   [F] Membrane Capacitance.
                ki_range    =   [-] Integration Subnetwork Gain.
            
            Output(s):
                gs          =   [S] Maximum Synaptic Conductance.
            %}
            
            % Set the default input arguments.
            if nargin < 4, ki_range = self.c_integration_range_DEFAULT; end
            
            % Compute the integration subnetwork maximum synaptic conductances.
            gs = ( -2*Gm.*Cm.*ki_range )./( Cm.*ki_range - 1 );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potentials for an integration subnetwork.
        function dEsyn = compute_integration_dEsyn( ~, Gm, R, gs )
        
            %{
            Input(s):
                Gm      =   [S] Membrane Conductance.
                R       =   [V] Maximum Membrane Voltage.
                gs      =   [S] Maximum Synaptic Conductance.
            
            Output(s):
                dEsyn   =   [S] Synaptic Reversal Potential.
            %}
            
           % Compute the synaptic reversal potentials for an integration subnetwork.
           dEsyn = - ( Gm*R )./gs;
            
        end
            
        
        % Implement a function to compute the applied current for an integration subnetwork.
        function Iapp = compute_integration_Iapp( ~, Gm, R )
            
            %{
            Input(s):
                Gm      =   [S] Membrane Conductance.
                R       =   [V] Maximum Membrane Conductance.
            
            Output(s):
                Iapp    =   [A] Applied Current.
            %}
            
            % Compute the applied current for an integration subnetwork.
            Iapp = Gm.*R;
            
        end
        
            
        %% Voltage Based Integration Design Functions.
        
        % Implement a function to compute the desired intermediate synaptic current for a voltage based integration subnetwork.
        function I_syn12 = compute_vb_integration_Isyn( ~, R2, Ta, ki_mean, b_inhibition )

            %{
            Input(s):
                R2              =   [V] Maximum Membrane Voltage.
                Ta              =   [s] Activation Period.
                ki_mean         =   [-] Integration Subnetwork Gain.
                b_inhibition    =   [T/F] Inhibition Flag.
            
            Output(s):
                I_syn12         =   [A] Synaptic Current (Synapse 12).
            %}
            
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
                    
            %{
            Input(s):
                R2              =   [V] Maximum Membrane Voltage.
                dE_syn12        =   [V] Synaptic Reversal Potential (Synapse 12).
                I_syn12         =   [A] Synaptic Current (Synapse 12).
            
            Output(s):
                g_syn_max12     =   [S] Maximum Synaptic Conductance (Synapse 12).
            %}
            
            % Compute the maximum synaptic conductance for a voltage based integration subnetwork.
            g_syn_max12 = I_syn12./( dE_syn12 - ( R2/2 ) );
            
        end
            
        
        %% Steady State Formulations.
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute transmission subnetwork.
        function U2s = compute_desired_absolute_transmission_steady_state_output( ~, U1s, c )
            
            %{
            Input(s):
                U1s     =   [V] Membrane Voltages (Neuron 1).
                c       =   [-] Absolute Transmission Gain.
            
            Output(s):
                U2s     =   [V] Membrane Voltages (Neuron 2).
            %}
            
            % Set the default input arguments.
            if nargin < 3, c = 1; end
            if nargin < 2, U1s = 0; end
            
            % Compute the steady state network output.
            U2s = c*U1s;
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative transmission subnetwork.
        function U2s = compute_desired_relative_transmission_steady_state_output( ~, U1s, c, R1, R2 )
            
            %{
            Input(s):
                U1s     =   [V] Membrane Voltages (Neuron 1).
                c       =   [-] Relative Transmission Gain.
                R1      =   [V] Maximum Membrane Voltage (Neuron 1).
                R2      =   [V] Maximum Membrane Voltage (Neuron 2).
            
            Output(s):
                U2s     =   [V] Membrane Voltages (Neuron 2).
            %}
            
            % Set the default input arguments.
            if nargin < 5, R2 = 20e-3; end
            if nargin < 4, R1 = 20e-3; end
            if nargin < 3, c = 1; end
            if nargin < 2, U1s = 0; end
            
            % Compute the steady state network output.
            U2s = c*( R2/R1 )*U1s;
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a transmission subnetwork.
        function U2s = compute_achieved_transmission_steady_state_output( ~, U1s, R1, Gm2, Ia2, gs21, dEs21 )
        
            % Set the default input arguments.
            if nargin < 7, dEs21 = 194e-3; end                                  % [V] Synaptic Reversal Potential (Synapse 21).
            if nargin < 6, gs21 = 19e-6; end                                    % [S] Synaptic Conductance (Synapse 21).
            if nargin < 5, Ia2 = 20e-9; end                                     % [A] Applied Current (Neuron 2).
            if nargin < 4, Gm2 = 1e-6; end                                      % [S] Membrane Conductance (Neuron 2).
            if nargin < 3, R1 = 20e-3; end                                      % [V] Maximum Membrane Voltage (Neuron 1).
            
            % Compute the steady state network outputs.
            U2s = ( gs21*dEs21*U1s + R1*Ia2 )./( gs21*U1s + R1*Gm2 );           % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute addition subnetwork.
        function U_outputs = compute_desired_absolute_addition_steady_state_output( ~, U_inputs, c )
            
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                c           =   [-] Absolute Addition Gain.
            
            Output(s):
                U_outputs   =   [V] Membrane Voltage Outputs.
            %}
            
            % Set the default input arguments.
            if nargin < 3, c = 1; end
            if nargin < 2, U_inputs = zeros( 1, 2 ); end
            
            % Compute the steady state network outputs.
            U_outputs = c*sum( U_inputs, 2 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative addition subnetwork.
        function U_outputs = compute_desired_relative_addition_steady_state_output( ~, U_inputs, Rs, c )
            
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                Rs          =   [V] Maximum Membrane Voltage.
                c           =   [-] Relative Addition Gain.
            
            Output(s):
                U_Outputs   =   [V] Membrane Voltage Outputs.
            %}
            
            % Set the default input arguments.
            if nargin < 4, c = 1; end
            if nargin < 3, Rs = ( 20e-3 )*ones( 1, 2 ); end
            if nargin < 2, U_inputs = zeros( 1, 2 ); end
            
            % Compute the number of inputs.
            num_inputs = size( U_inputs, 2 );
            
            % Compute the steady state network outputs.
            U_outputs = ( ( c*Rs( end ) )/num_inputs )*sum( U_inputs./Rs( 1:( end - 1 ) ), 2 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of an addition subnetwork.
        function U_outputs = compute_achieved_addition_steady_state_output( ~, U_inputs, Rs, Gms, Ias, gs, dEs )
            
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                Rs          =   [V] Maximum Membrane Voltage.
                Gms         =   [s] Membrane Conductance.
                Ias         =   [A] Applied Current.
                gs          =   [S] Maximum Synaptic Conductance.
                dEs         =   [V] Synaptic Reversal Potential.
            
            Output(s):
                U_outputs   =   [V] Membrane Voltage Outputs.
            %}
            
            % Compute the steady state network outputs.
%             U_outputs = ( sum( ( gs( end, : ).*dEs( end, : ).*U_inputs )./Rs( 1:( end - 1 ) ), 2 ) + Ias( end ) )./( sum( ( gs( end, : ).*U_inputs )./Rs( 1:( end - 1 ) ), 2 ) + Gms( end ) );
            U_outputs = ( sum( ( gs( end, 1:( end - 1 ) ).*dEs( end, 1:( end - 1 ) ).*U_inputs )./Rs( 1:( end - 1 ) ), 2 ) + Ias( end ) )./( sum( ( gs( end, 1:( end - 1 ) ).*U_inputs )./Rs( 1:( end - 1 ) ), 2 ) + Gms( end ) );

        end
            
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute subtraction subnetwork.
        function U_outputs = compute_desired_absolute_subtraction_steady_state_output( ~, U_inputs, c, ss )
            
            %{
            Input(s):
                U_inputs = [V] Membrane Voltage Inputs.
                c = [-] Absolute Subtraction Gain.
                ss = [-1/1] Subtraction Signs.
            
            Output(s):
                U_outputs = [V] Membrane Voltage Outputs.
            %}
            
            % Set the default input arguments.
            if nargin < 4, ss = [ 1, -1 ]; end
            if nargin < 3, c = 1; end
            if nargin < 2, U_inputs = zeros( 1, 2 ); end
            
            % Compute the steady state network outputs.
            U_outputs = c*sum( ss.*U_inputs, 2 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative subtraction subnetwork.
        function U_outputs = compute_desired_relative_subtraction_steady_state_output( ~, U_inputs, Rs, c, ss )
            
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                Rs          =   [V] Maximum Membrane Voltages.
                c           =   [-] Relative Subtraction Subnetwork Gain.
                ss          =   [-1/1] Subtraction Signs.
            
            Output(s):
                U_outputs   =   [V] Membrane Voltage Outputs.
            %}
            
            % Set the default input arguments.
            if nargin < 5, ss = [ 1, -1 ]; end
            if nargin < 4, c = 1; end
            if nargin < 3, Rs = ( 20e-3 )*ones( 1, 2 ); end
            if nargin < 2, U_inputs = zeros( 1, 2 ); end
            
            % Retrieve the indexes associated with the excitatory and inhibitory synapses.
            i_plus = ss == 1;
            i_negative = ss == -1;
            
            % Compute the number of excitatory and inhibitory synapses.
            n_plus = length( i_plus );
            n_negative = length( i_negative );
            
            % Compute the steady state network outputs.
            U_outputs = ( c*Rs( end ) )*( ( 1/n_plus )*sum( U_inputs( :, i_plus )./Rs( i_plus ), 2 ) - ( 1/n_negative )*sum( U_inputs( :, i_negative )./Rs( i_negative ), 2 ) );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a subtraction subnetwork.
        function U_outputs = compute_achieved_subtraction_steady_state_output( ~, U_inputs, Rs, Gms, Ias, gs, dEs )
            
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                Rs          =   [V] Maximum Membrane Voltages.
                Gms         =   [S] Membrane Conductances.
                Ias         =   [A] Applied Currents.
                gs          =   [S] Maximum Synaptic Conductance.
                dEs         =   [V] Synaptic Reversal Potential.
            
            Output(s):
                U_outputs   =   [V] Membrane Voltage Outputs.
            %}
            
            % Compute the steady state network outputs.
            U_outputs = ( sum( ( gs( end, 1:( end - 1 ) ).*dEs( end, 1:( end - 1 ) ).*U_inputs )./Rs( 1:( end - 1 ) ), 2 ) + Ias( end ) )./( sum( ( gs( end, 1:( end - 1 ) ).*U_inputs )./Rs( 1:( end - 1 ) ), 2 ) + Gms( end ) );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute inversion subnetwork.
        function U2s = compute_desired_absolute_inversion_steady_state_output( ~, U1s, c1, c2, c3 )
            
            %{
            Input(s):
                U1s     =   [V] Membrane Voltages (Neuron 1).
                c1      =   [?] Absolute Inversion Design Constant 1.
                c2      =   [?] Absolute Inversion Design Constant 2.
                c3      =   [?] Absolute Inversion Design Constant 3.
            
            Output(s):
                U2s     =   [V] Membrane Voltages (Neuron 2).
            %}
            
            % Set the default input arguments.
            if nargin < 5, c3 = 20e-9; end                          % [A] Design Constant 3.
            if nargin < 4, c2 = 19e-6; end                          % [S] Design Constant 2.
            if nargin < 3, c1 = 0.40e-9; end                        % [W] Design Constant 1.
            
            % Compute the steady state network outputs.
            U2s = c1./( c2*U1s + c3 );                              % [V] Membrane Voltage.
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced absolute inversion subnetwork.
        function U2s = compute_desired_reduced_absolute_inversion_steady_state_output( ~, U1s, c1, c2 )
           
            %{
            Input(s):
                U1s     =   [V] Membrane Voltages (Neuron 1).
                c1      =   [-] Reduced Absolute Inversion Design Constant 1.
                c2      =   [-] Reduced Absolute Inversion Design Constant 2.
            
            Output(s):
                U2s     =   [V] Membrane Voltages (Neuron 2).
            %}
            
            % Set the default input arguments.
            if nargin < 4, c2 = 21.05e-6; end                       % [mV] Design Constant 2.
            if nargin < 3, c1 = 1.05e-3; end                        % [mV^2] Design Constant 1.
           
            % Compute the steady state network outputs.
            U2s = c1./( U1s + c2 );                                 % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative inversion subnetwork.
        function U2s = compute_desired_relative_inversion_steady_state_output( ~, Us1, c1, c2, c3, R1, R2 )
        
            %{
            Input(s):
                Us1 = [V] Membrane Voltages (Neuron 1).
                c1 = [?] Desired Relative Inversion Design Constant 1.
                c2 = [?] Desired Relative Inversion Design Constant 2.
                c3 = [?] Desired Relative Inversion Design Constant 3.
                R1 = [V] Maximum Membrane Voltage (Neuron 1).
                R2 = [V] Maximum Membrane Voltage (Neuron 2).
            
            Output(s):
                U2s = [V] Membrane Voltages (Neuron 2).
            %}
            
            % Set the default input arguments.
            if nargin < 7, R2 = 20e-3; end                          % [V] Maxmimum Membrane Voltage (Neuron 2).
            if nargin < 6, R1 = 20e-3; end                          % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 5, c3 = 1e-6; end                           % [-] Design Constant 3.
            if nargin < 4, c2 = 19e-6; end                          % [-] Design Constant 2.
            if nargin < 3, c1 = 1e-6; end                           % [-] Design Constant 1.

            % Compute the steady state network outputs.
            U2s = ( c1*R1*R2 )./( c2*Us1 + c3*R1 );                 % [V] Membrane Voltage (Neuron 2).
            
        end
           
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced relative inversion subnetwork.
        function U2s = compute_desired_reduced_relative_inversion_steady_state_output( ~, Us1, c1, c2, R1, R2 )
        
            %{
            Input(s):
                Us1     =   [V] Membrane Voltages (Neuron 1).
                c1      =   [?] Reduced Relative Inversion Design Constant 1.
                c2      =   [?] Reduced Relative Inversion Design Constant 2.
                R1      =   [V] Maximum Membrane Voltage (Neuron 1).
                R2      =   [V] Maximum Membrane Voltage (Neuron 2).
            
            Output(s):
                U2s     =   [V] Membrane Voltages (Neuron 2).
            %}
            
            % Set the default input arguments.
            if nargin < 6, R2 = 20e-3; end                          % [V] Maximum Membrane Voltage (Neuron 2).
            if nargin < 5, R1 = 20e-3; end                          % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 4, c2 = 52.6e-3; end                       	% [-] Design Constant 2.
            if nargin < 3, c1 = 52.6e-3; end                       	% [-] Design Constant 1.

            % Compute the steady state network outputs.
            U2s = ( c1*R1*R2 )./( Us1 + c2*R1 );                    % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of an inversion subnetwork.
        function U2s = compute_achieved_inversion_steady_state_output( ~, U1s, R1, Gm2, Ia2, gs21, dEs21 )
        
            %{
            Input(s):
                U1s     =   [V] Membrane Voltages (Neuron 1).
                R1      =   [V] Maximum Membrane Voltage (Neuron 1).
                Gm2     =   [S] Membrane Conductance (Neuron 2).
                Ia2     =   [A] Applied Current (Neuron 2).
                gs21    =   [S] Maximum Synaptic Conductance (Synapse 21).
                dEs21   =   [V] Synaptic Reversal Potential (Synapse 21).
            
            Output(s):
                U2s     =   [V] Membrane Voltages (Neuron 2).
            %}
            
            % Set the default input arguments.
            if nargin < 7, dEs21 = 0; end                                       % [V] Synaptic Reversal Potential (Synapse 21).
            if nargin < 6, gs21 = 19e-6; end                                    % [S] Synaptic Conductance (Synapse 21).
            if nargin < 5, Ia2 = 20e-9; end                                     % [A] Applied Current (Neuron 2).
            if nargin < 4, Gm2 = 1e-6; end                                      % [S] Membrane Conductance (Neuron 2).
            if nargin < 3, R1 = 20e-3; end                                      % [V] Maximum Membrane Voltage (Neuron 1).
            
            % Compute the steady state network outputs.
            U2s = ( gs21*dEs21*U1s + R1*Ia2 )./( gs21*U1s + R1*Gm2 );           % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute division subnetwork.
        function U3s = compute_desired_absolute_division_steady_state_output( ~, U_inputs, c1, c2, c3 )
        
            %{
            Input(s):
                U_inputs = [V] Membrane Voltage Inputs.
                c1 = [?] Absolute Division Design Constant 1.
                c2 = [?] Absolute Division Design Constant 2.
                c3 = [?] Absolute Division Design Constant 3.
            
            Output(s):
                U3s = [V] Membrane Voltage (Neuron 3). 
            %}
            
            % Set the default input arguments.
            if nargin < 5, c3 = 0.40e-9; end                                    % [W] Design Constant 3.
            if nargin < 4, c2 = 380e-9; end                                     % [A] Design Constant 2.
            if nargin < 3, c1 = 0.40e-9; end                                    % [W] Design Constant 1.
            
            % Retrieve the steady state inputs.
            U1s = U_inputs( :, 1 );                                             % [V] Membrane Voltage (Neuron 1).
            U2s = U_inputs( :, 2 );                                             % [V] Membrane Voltage (Neuron 2).
            
            % Compute the steady state network outputs.
            U3s = ( c1*U1s )./( c2*U2s + c3 );                                  % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced absolute division subnetwork.
        function U3s = compute_desired_reduced_absolute_division_steady_state_output( ~, U_inputs, c1, c2 )
        
            %{
            Input(s):
                U_inputs = [V] Membrane Voltage Inputs.
                c1 = [?] Reduced Absolute Division Design Constant 1.
                c2 = [?] Reduced Absolute Division Design Constant 2.
            
            Output(s):
                U3s = [V] Membrane Voltages (Neuron 3).
            %}
            
            % Set the default input arguments.
            if nargin < 4, c2 = 1.05e-3; end                                	% [V] Design Constant 2.
            if nargin < 3, c1 = 1.05e-3; end                                    % [V] Design Constant 1.
            
            % Retrieve the steady state inputs.
            U1s = U_inputs( :, 1 );                                             % [V] Membrane Voltage (Neuron 1).
            U2s = U_inputs( :, 2 );                                             % [V] Membrane Voltage (Neuron 2).
            
            % Compute the steady state network outputs.
            U3s = ( c1*U1s )./( U2s + c2 );                                     % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative division subnetwork.
        function U3s = compute_desired_relative_division_steady_state_output( ~, U_inputs, c1, c2, c3, R1, R2, R3 )
        
            %{
            Input(s):
                U_inputs = [V] Membrane Voltage Inputs.
                c1 = [?] Desired Relative Division Design Constant 1.
                c2 = [?] Desired Relative Division Design Constant 2.
                c3 = [?] Desired Relative Division Design Constant 3.
                R1 = [V] Maximum Membrane Voltage (Neuron 1).
                R2 = [V] Maximum Membrane Voltage (Neuron 2).
                R3 = [V] Maximum Membrane Voltage (Neuron 3).
            
            Output(s):
                U3s = [V] Membrane Voltages (Neuron 3).
            %}
            
            % Set the default input arguments.
            if nargin < 8, R3 = 20e-3; end                                      % [V] Maximum Membrane Voltage (Neuron 3).
            if nargin < 7, R2 = 20e-3; end                                      % [V] Maximum Membrane Voltage (Neuron 2).
            if nargin < 6, R1 = 20e-3; end                                      % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 5, c3 = 1e-6; end                                       % [S] Design Constant 3.
            if nargin < 4, c2 = 19e-6; end                                      % [S] Design Constant 2.
            if nargin < 3, c1 = 1e-6; end                                       % [S] Design Constant 1.
            
            % Retrieve the steady state inputs.
            U1s = U_inputs( :, 1 );                                             % [V] Membrane Voltage (Neuron 1).
            U2s = U_inputs( :, 2 );                                             % [V] Membrane Voltage (Neuron 2).
            
            % Compute the steady state network outputs.
            U3s = ( c1*R2*R3*U1s )./( c2*R1*U2s + R1*R2*c3 );                   % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced relative division subnetwork.
        function U3s = compute_desired_reduced_relative_division_steady_state_output( ~, U_inputs, c1, c2, R1, R2, R3 )
        
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                c1          =   [?] Reduced Relative Division Design Constant 1.
                c2          =   [?] Reduced Relative Division Design Constant 2.
                c3          =   [?] Reduced Relative Division Design Constant 3.
                R1          =   [V] Maximum Membrane Voltage (Neuron 1).
                R2          =   [V] Maximum Membrane Voltage (Neuron 2).
                R3          =   [V] Maximum Membrane Voltage (Neuron 3).
            
            Output(s):
                U3s         =   [V] Membrane Voltages (Neuron 3).
            %}
            
            % Set the default input arguments.
            if nargin < 7, R3 = 20e-3; end                                      % [V] Maximum Membrane Voltage (Neuron 3).
            if nargin < 6, R2 = 20e-3; end                                      % [V] Maximum Membrane Voltage (Neuron 2).
            if nargin < 5, R1 = 20e-3; end                                      % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 4, c2 = 0.0526; end                                   	% [-] Design Constant 2.
            if nargin < 3, c1 = 0.0526; end                                   	% [-] Design Constant 1.
            
            % Retrieve the steady state inputs.
            U1s = U_inputs( :, 1 );                                             % [V] Membrane Voltage (Neuron 1).
            U2s = U_inputs( :, 2 );                                             % [V] Membrane Voltage (Neuron 2).
            
            % Compute the steady state network outputs.
            U3s = ( c1*R2*R3*U1s )./( R1*U2s + R1*R2*c2 );                      % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a division subnetwork.
        function U3s = compute_achieved_division_steady_state_output( ~, U_inputs, R1, R2, Gm3, Ia3, gs31, gs32, dEs31, dEs32 )
        
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                R1          =   [V] Maximum Membrane Voltage (Neuron 1).
                R2          =   [V] Maximum Membrane Voltage (Neuron 2).
                Gm3         =   [S] Membrane Conductance (Neuron 3).
                Ia3         =   [A] Applied Current (Neuron 3).
                gs31        =   [S] Maximum Synaptic Conductance (Synapse 31).
                gs32        =   [S] Maximum Synaptic Conductance (Synapse 32).
                dEs31       =   [V] Synaptic Reversal Potential (Synapse 31).
                dEs32       =   [V] Synaptic Reversal Potential (Synapse 32).
            
            Output(s):
            `   U3s         =   [V] Membrane Voltages (Neuron 3).
            %}
            
            % Retrieve the steady state inputs.
            U1s = U_inputs( :, 1 );
            U2s = U_inputs( :, 2 );
            
           % Compute the steady state network outputs.
           U3s = ( R2*gs31*dEs31*U1s + R1*gs32*dEs32*U2s + R1*R2*Ia3 )./( R2*gs31*U1s + R1*gs32*U2s + R1*R2*Gm3 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute multiplication subnetwork.
        function [ U4s, U3s ] = compute_desired_absolute_multiplication_steady_state_output( self, U_inputs, c1, c2, c3, c4, c5, c6 )
        
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                c1          =   [?] Absolute Multiplication Design Constant 1.
                c2          =   [?] Absolute Multiplication Design Constant 2.
                c3          =   [?] Absolute Multiplication Design Constant 3.
                c4          =   [?] Absolute Multiplication Design Constant 4.
                c5          =   [?] Absolute Multiplication Design Constant 5.
                c6          =   [?] Absolute Multiplication Design Constant 6.
            
            Output(s):
                U3s         =   [V] Membrane Voltage (Neuron 3).
                U4s         =   [V] Membrane Voltage (Neuron 4).
            %}
            
            % Retrieve the steady state inputs.
            U1s = U_inputs( :, 1 );
            U2s = U_inputs( :, 2 );
            
            % Compute the desired absolute inversion steady state output.
            U3s = self.compute_desired_absolute_inversion_steady_state_output( U2s, c1, c2, c3 );
            
            % Compute the desired absolute division steady state output.
            U4s = self.compute_desired_absolute_division_steady_state_output( [ U1s, U3s ], c4, c5, c6 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced absolute multiplication subnetwork.
        function [ U4s, U3s ] = compute_desired_red_abs_mult_ss_output( self, U_inputs, c1, c2, c3, c4 )
        
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                c1          =   [?] Reduced Absolute Multiplication Design Constant 1.
                c2          =   [?] Reduced Absolute Multiplication Design Constant 2.
                c3          =   [?] Reduced Absolute Multiplication Design Constant 3.
                c4          =   [?] Reduced Absolute Multiplication Design Constant 4.

            Output(s):
                U3s         =   [V] Membrane Voltage (Neuron 3).
                U4s         =   [V] Membrane Voltage (Neuron 4).
            %}
            
            % Retrieve the steady state inputs.
            U1s = U_inputs( :, 1 );
            U2s = U_inputs( :, 2 );
            
            % Compute the desired absolute inversion steady state output.            
            U3s = self.compute_desired_reduced_absolute_inversion_steady_state_output( U2s, c1, c2 );
            
            % Compute the desired absolute division steady state output.
            U4s = self.compute_desired_reduced_absolute_division_steady_state_output( [ U1s, U3s ], c3, c4 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative multiplication subnetwork.
        function [ U4s, U3s ] = compute_desired_relative_multiplication_steady_state_output( self, U_inputs, c1, c2, c3, c4, c5, c6, R1, R2, R3, R4 )
   
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                c1          =   [?] Relative Multiplication Design Constant 1.
                c2          =   [?] Relative Multiplication Design Constant 2.
                c3          =   [?] Relative Multiplication Design Constant 3.
                c4          =   [?] Relative Multiplication Design Constant 4.
                c5          =   [?] Relative Multiplication Design Constant 5.
                c6          =   [?] Relative Multiplication Design Constant 6.
                R1          =   [V] Maximum Membrane Voltage (Neuron 1).
                R2          =   [V] Maximum Membrane Voltage (Neuron 2).
                R3          =   [V] Maximum Membrane Voltage (Neuron 3).
                R4          =   [V] Maximum Membrane Voltage (Neuron 4).

            Output(s):
                U3s         =   [V] Membrane Voltage (Neuron 3).
                U4s         =   [V] Membrane Voltage (Neuron 4).
            %}
            
            % Retrieve the steady state inputs.
            U1s = U_inputs( :, 1 );
            U2s = U_inputs( :, 2 );
            
            % Compute the desired relative inversion steady state output.
            U3s = self.compute_desired_relative_inversion_steady_state_output( U2s, c1, c2, c3, R2, R3 );

            % Compute the desired relative division steady state output.
            U4s = self.compute_desired_relative_division_steady_state_output( [ U1s, U3s ], c4, c5, c6, R1, R3, R4 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative multiplication subnetwork.
        function [ U4s, U3s ] = compute_desired_red_rel_mult_ss_output( self, U_inputs, c1, c2, c3, c4, R1, R2, R3, R4 )
           
           %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                c1          =   [?] Reduced Relative Multiplication Design Constant 1.
                c2          =   [?] Reduced Relative Multiplication Design Constant 2.
                c3          =   [?] Reduced Relative Multiplication Design Constant 3.
                c4          =   [?] Reduced Relative Multiplication Design Constant 4.
                R1          =   [V] Maximum Membrane Voltage (Neuron 1).
                R2          =   [V] Maximum Membrane Voltage (Neuron 2).
                R3          =   [V] Maximum Membrane Voltage (Neuron 3).
                R4          =   [V] Maximum Membrane Voltage (Neuron 4).

            Output(s):
                U3s         =   [V] Membrane Voltage (Neuron 3).
                U4s         =   [V] Membrane Voltage (Neuron 4).
            %}
           
            % Retrieve the steady state inputs.
            U1s = U_inputs( :, 1 );
            U2s = U_inputs( :, 2 );
            
            % Compute the desired relative inversion steady state output.
            U3s = self.compute_desired_reduced_relative_inversion_steady_state_output( U2s, c1, c2, R2, R3 );

            % Compute the desired relative division steady state output.
            U4s = self.compute_desired_reduced_relative_division_steady_state_output( [ U1s, U3s ], c3, c4, R1, R3, R4 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a multiplication subnetwork.
        function [ U4s, U3s ] = compute_achieved_multiplication_steady_state_output( self, U_inputs, R1, R2, R3, Gm3, Gm4, Ia3, Ia4, gs32, gs41, gs43, dEs32, dEs41, dEs43 )
        
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                R1          =   [V] Maximum Membrane Voltage (Neuron 1).
                R2          =   [V] Maximum Membrane Voltage (Neuron 2).
                R3          =   [V] Maximum Membrane Voltage (Neuron 3).
                Gm3         =   [S] Membrane Conductance (Neuron 3).
                Gm4         =   [S] Membrane Conductance (Neuron 4).
                Ia3         =   [A] Applied Current (Neuron 3).
                Ia4         =   [A] Applied Current (Neuron 4).
                gs32        =   [S] Synaptic Conductance (Synapse 32).
                gs41        =   [S] Synaptic Conductance (Synapse 41).
                gs43        =   [S] Synaptic Conductance (Synapse 43).
                dEs32       =   [S] Synaptic Reversal Potential (Synapse 32).
                dEs41       =   [S] Synaptic Reversal Potential (Synapse 41).
                dEs43       =   [S] Synaptic Reversal Potential (Synapse 43).
            
            Output(s):
                U3s         =   [V] Membrane Voltage (Neuron 3).
                U4s         =   [V] Membrane Voltage (Neuron 4).
            %}
            
            % Retrieve the steady state inputs.
            U1s = U_inputs( :, 1 );
            U2s = U_inputs( :, 2 );
            
            % Compute the achieved inversion steady state output.
            U3s = self.compute_achieved_inversion_steady_state_output( U2s, R2, Gm3, Ia3, gs32, dEs32 );            
                        
            % Compute the achieved division steady state output.
            U4s = self.compute_achieved_division_steady_state_output( [ U1s, U3s ], R1, R3, Gm4, Ia4, gs41, gs43, dEs41, dEs43 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute linear combination subnetwork.
        function Us_output = compute_desired_absolute_linear_combination_steady_state_output( ~, Us_inputs, cs, ss )
        
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                cs          =   [-] Input Gains.
                ss          =   [-1/1] Input Signatures.
            
            Output(s):
                Us_output  	=   [V] Membrane Voltage Outputs.
            %}
            
            % Set the default input arguments.
            if nargin < 4, ss = [ 1; -1 ]; end
            if nargin < 3, cs = [ 1; 1 ]; end
            if nargin < 2, Us_inputs = zeros( 1, 2 ); end
            
            % Compute the steady state network outputs.
            Us_output = ( ( ss.*cs )'*Us_inputs' )';
            
        end
        
            
        % Implement a function to compute the steady state output associated with the desired formulation of a relative linear combination subnetwork.
        function Us_output = compute_desired_relative_linear_combination_steady_state_output( ~, Us_inputs, Rs, cs, ss )
        
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                Rs          =   [V] Maximum Membrane Voltages.
                cs          =   [-] Input Gains.
                ss          =   [-1/1] Input Signatures.
            
            Output(s):
                Us_output 	=   [V] Membrane Voltage Outputs.
            %}
            
            % Set the default input arguments.
            if nargin < 5, ss = [ 1; -1 ]; end
            if nargin < 4, cs = [ 1; 1 ]; end
            if nargin < 3, Rs = [ 20e-3; 20e-3; 20e-3 ]; end
            if nargin < 2, Us_inputs = zeros( 1, 2 ); end
            
            % Compute the steady state network outputs.
            Us_output = Rs( end )*( ( ss.*cs./Rs( 1:( end - 1 ) ) )'*Us_inputs' )';
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a linear combination subnetwork.
        function Us_output = compute_achieved_linear_combination_ss_output( ~, Us_inputs, Rs, Gms, Ias, gs, dEs )
        
            %{
            Input(s):
                Us_inputs = [V] Membrane Voltage Inputs (# of timesteps x # of inputs).
                Rs = [V] Maximum Membrane Voltage (# of inputs).
                Gms = [S] Membrane Conductances (# of inputs).
                Ias = [S] Applied Currents (# of neurons).
                gs = [S] Synaptic Conductances (# of synapses).
                dEs = [V] Synaptic Reversal Potentials (# of synapses).
            
            Output(s):
                Us_output = [V] Membrane Voltage Outputs (# of timesteps).
            %}
 
            % Set the default input arguments.
            if nargin < 7, dEs = [ 194e-3; -194e-3 ]; end
            if nargin < 6, gs = [ 0.10e-6; 0.10e-6 ]; end
            if nargin < 5, Ias = [ 0; 0; 0 ]; end
            if nargin < 4, Gms = [ 1e-6; 1e-6; 1e-6 ]; end
            if nargin < 3, Rs = [ 20e-3; 20e-3; 20e-3 ]; end
            if nargin < 2, Us_inputs = zeros( 2, 1 ); end
            
            % Retrieve the number of neurons & synapses.
            num_neurons = size( Us_inputs, 1 ) + 1;
            num_timesteps = size( Us_inputs, 2 );
            
            % Preallocate an array to store the maximum membrane voltage products.
            Ps = zeros( num_neurons, 1 );
            
            % Preallocate an array to store the maximum membrane voltage products.
            for k = 1:( num_neurons - 1 )            % Iterate through each of the input neurons...
                
                % Compute the indexes for this maximum membrane voltage product.
                indexes = ( 1:( num_neurons - 1 ) ) ~= k;
                
                % Compute this maximum membrane voltage product...
                Ps( k ) = prod( Rs( indexes ) );
                
            end
            
            % Compute the final maximum membrane voltage product.
            Ps( end ) = prod( Rs( 1:( num_neurons - 1 ) ) );
            
            % Compute the membrane voltage outputs.
            Us_output = ( Ps'*[ gs.*dEs.*Us_inputs; Ias( end )*ones( 1, num_timesteps ) ] )./( Ps'*[ gs.*Us_inputs; Gms( end )*ones( 1, num_timesteps ) ] );
            
        end
        
        
        %% Network Functions.
        
        % Implement a function to compute the linearized system matrix for a neural network about a given operating point.  (This method is only valid for neural networks WITHOUT sodium channels.)
        function A = compute_linearized_system_matrix( ~, Cms, Gms, Rs, gs, dEs, Us0 )
        
            %{
            Input(s):
                Cms     =   [F] Membrane Capacitances.
                Gms    	=   [S] Membrane Conductances.
                Rs      =   [V] Maximum Membrane Votlages.
                gs      =   [S] Synaptic Conductances.
                dEs     =   [V] Synaptic Reversal Potentials.
                Us0     =   [V] Membrane Voltage Equilibrium Point.  The point at which the system linearization is performed.
            
            Output(s):
                A       =	[variable] Linearized System Matrix.
            %}
            
            % Set the default input arguments.
            if nargin < 7, Us0 = zeros( length( Cm2 ), 1 ); end
            
            % Compute the number of neurons.
            num_neurons = length( Us0 );
            
            % Preallocate the system matrix.
            A = zeros( num_neurons, num_neurons );
            
            % Compute the linearized system matrix.
            for k1 = 1:num_neurons              % Iterate through each of the neurons...
                for k2 = 1:num_neurons          % Iterate through each of the neurons...
                    
                   % Determine how to compute this system matrix entry.
                   if k1 == k2                  % If the row and column indexes are equal...
                      
                       % Compute the first term of the system matrix entry.
                       A( k1, k2 ) = ( ( gs( k1, k2 )*dEs( k1, k2 ) - Gms( k1 )*Rs( k2 ) )/( Cms( k1 )*Rs( k2 ) ) );
                       
                       % Compute the additional system matrix terms. 
                       for k3 = 1:num_neurons               % Iterate through each of the neurons...
                          
                           % Compute this additional system matrix term.
                           A( k1, k2 ) = A( k1, k2 ) - ( gs( k1, k3 )/( Cms( k1 )*Rs( k3 ) ) )*Us0( k3 );
                           
                       end
                       
                       % Compute the final system matrix term.
                       A( k1, k2 ) = A( k1, k2 ) - ( gs( k1, k2 )/( Cms( k1 )*Rs( k2 ) ) )*Us0( k2 );
                       
                   else                         % Otherwise...
                       
                       % Compute this system matrix entry.
                       A( k1, k2 ) = ( gs( k1, k2 )/( Cms( k1 )*Rs( k2 ) ) )*( dEs( k1, k2 ) - Us0( k1 ) );
                       
                   end
                    
                end 
            end
            
        end
        
        
        % Implement a function to compute the linearized input matrix for a neural network.  (This method is only valid for neural networks WITHOUT sodium channels.) 
        function B = compute_linearized_input_matrix( ~, Cms, Ias )
            
            %{
            Input(s):
                Cms     =   [F] Membrane Capacitances.
                Ias     =   [A] Applied Currents.
            
            Output(s):
                B       =   [variable] Linearized Input Matrix.
            %}
            
            % Compute the number of neurons.
            num_neurons = length( Cms );
            
            % Preallocate the input matrix.
            B = zeros( num_neurons, 1 );
            
            % Compute the linearized input matrix.
            for k1 = 1:num_neurons              % Iterate through each of the neurons...
                for k2 = 1:num_neurons          % Iterate through each of the neurons...
                    
                    % Determine how to compute this input matrix entry.
                    if k1 == k2                 % If the row and column indexes as equal...
                        
                       % Compute this input matrix entry.
                       B( k1, k2 ) = Ias( k1 )/Cms( k1 );
                        
                    else                        % Otherwise...
                       
                        % Compute this input matrix entry.
                        B( k1, k2 ) = 0;
                        
                    end
                    
                end
            end
            
        end
            
        
        % Implement a function to compute the linearized system for a neural network about a given operating point.  (This method is only valid for neural networks WITHOUT sodium channels.)
        function [ A, B ] = get_linearized_system( self, Cms, Gms, Rs, gs, dEs, Ias, Us0 )
        
            %{
            Input(s):
                Cms     =   [F] Membrane Capacitances.
                Gms     =   [S] Membrane Conductances.
                Rs      =   [V] Maximum Membrane Voltages.
                gs      =   [S] Synaptic Conductances.
                dEs     =   [V] Synaptic Reversal Potentials.
                Ias     =   [A] Applied Currents.
                Us0     =   [V] Membrane Voltage Equilibrium Point.  The point at which the system is linearized.
            
            Output(s):
                A       =   [variable] Linearized System Matrix.
                B       =   [variable] Linearized Input Matrix.
            %}
            
            % Set the default input arguments.
            if nargin < 8, Us0 = zeros( length( Cm2 ), 1 ); end
            
            % Compute the linearized system matrix.
            A = self.compute_linearized_system_matrix( Cms, Gms, Rs, gs, dEs, Us0 );
            
            % Compute the linearized input matrix.
            B = self.compute_linearized_input_matrix( Cms, Ias );
            
        end
        
        
        %% Stability Functions.
        
        % Implement a function to compute the maximum RK4 step size.
        function [ A, dt, condition_number ] = RK4_stability_analysis_at_point( self, Cms, Gms, Rs, gs, dEs, Us0, dt0 )
        
            %{
            Input(s):
                Cms                 =   [F] Membrane Capacitances.
                Gms                 =   [S] Membrane Conductances.
                Rs                  =   [V] Maximum Membrane Voltages.
                gs                  =   [S] Synaptic Conductances.
                dEs                 =   [V] Synaptic Reversal Potentials.
                Us0                 =   [V] Membrane Voltage Equilibrium Point.  The point at which the system is to be linearized.
                dt0                 =   [s] Maximum RK4 Timestep Guess.
            
            Output(s);
                A                   =   [variable] Linearized System Matrix.
                dt                  =   [s] Maximum RK4 Timestep.  Simulation timesteps greater than this value are unstable.
                condition_number    =   [-] Linearized System Condition Number.
            %}
            
            % Set the default input arguments.
            if nargin < 8, dt0 = 1e-6; end
            if nargin < 7, Us0 = zeros( length( Cm2 ), 1 ); end
            
            % Compute the linearized system matrix.
            A = self.compute_linearized_system_matrix( Cms, Gms, Rs, gs, dEs, Us0 );
            
            % Compute the maximum RK4 step size.
            dt = self.numerical_method_utilities.compute_max_RK4_step_size( A, dt0 );
            
            % Compute the condition number of the system matrix.
            condition_number = cond( A );
            
        end      
        
        
        %% Simulation Functions.
        
        % Implement a function to perform a single simulation step.
        function [ dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = simulation_step( self, Us, hs, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps )
            
            % This function computes a single step of a neural network without sodium channels.
            
            %{
            Input(s):
                Us          =   [V] num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.
                hs          =   [-] num_neurons x 1 vector of neuron sodium channel deactivation parameters.
                Gms         =   [S] num_neurons x 1 vector of neuron membrane conductances.
                Cms         =   [F] num_neurons x 1 vector of neuron membrane capacitances.
                Rs          =   [V] num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
                g_syn_maxs  =   [S] num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
                dE_syns     =   [V] num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
                Ams         =   [-] num_neurons x 1 vector of sodium channel activation A parameter values.
                Sms         =   [-] num_neurons x 1 vector of sodium channel activation S parameter values.
                dEms        =   [-] num_neurons x 1 vector of sodium channel activation parameter reversal potentials.
                Ahs         =   [-] num_neurons x 1 vector of sodium channel deactivation A parameter values.
                Shs         =   [-] num_neurons x 1 vector of sodium channel deactivation S parameter values.
                dEhs        =   [-] num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
                tauh_maxs   =   [s] num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
                Gnas        =   [S] num_neurons x 1 vector of sodium channel conductances for each neuron.
                dEnas       =   [V] num_neurons x 1 vector of sodium channel reversal potentials for each neuron.
                I_tonics    =   [A] num_neurons x 1 vector of applied currents for each neuron.
                I_apps      =   [A] num_neurons x 1 vector of applied currents for each neuron.
            
            Output(s):
                dUs         =   [V] num_neurons x 1 vector of neuron membrane voltage derivatives w.r.t their resting potentials.
                dhs         =   [-] num_neurons x 1 vector of neuron sodium channel deactivation parameter derivatives.
                Gsyns       =   [S] num_neurons x num_neurons matrix of synaptic conductances.  Entry ij represents the synaptic conductance from neuron j to neuron i.
                Ileaks      =   [A] num_neurons x 1 vector of leak currents for each neuron.
                Isyns       =   [A] num_neurons x 1 vector of synaptic currents for each neuron.
                Inas        =   [A] num_neurons x 1 vector of sodium channel currents for each neuron.
                Itotals   	=   [A] num_neurons x 1 vector of total currents for each neuron.
                minfs       =   [-] num_neurons x 1 vector of neuron steady state sodium channel activation values.
                hinfs       =   [-] num_neurons x 1 vector of neuron steady state sodium channel deactivation values.
                tauhs       =   [s] num_neurons x 1 vector of sodium channel deactivation parameter time constants.
            %}
            
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
           
            %{
            Input(s):
                t           =   [s] Network Simulation Time.
                x           =   [variable] Network State.
                Gms         =   [S] Membrane Conductances.
                Cms         =   [F] Membrane Capacitances.
                Rs          =   [V] Maximum Membrane Voltages.
                g_syn_maxs  =   [S] Maximum Synaptic Conductances.
                dE_syns     =   [V] Synaptic Reversal Potentials.
                Ams         =   [?] Ion Channel Activation Parameter 1.
                Sms         =   [?] Ion Channel Activation Parameter 2.
                dEms        =   [?] Ion Channel Activation Parameter 3. 
                Ahs         =   [?] Ion Channel Deactivation Parameter 1.
                Shs         =   [?] Ion Channel Deactivation Parameter 2.
                dEhs        =   [?] Ion Channel Deactivation Parameter 3. 
                tauh_maxs   =   [s] Ion Channel Deactivation Time Constant.
                Gnas        =   [S] Ion Channel Conductances.
                dEnas       =   [V] Ion Channel Reversal Potential.
                I_tonics    =   [V] Tonic Currents.
                I_apps      =   [V] Applied Currents.
            
            Output(s):
                dx          =   [variable] Network State Flows.
            %}
            
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
        
            %{
            Input(s):
                Us              =   [V] Membrane Voltages.
                hs              =   [-] Ion Channel Deactivation Parameter.
                Gms             =   [S] Membrane Conductances.
                Cms             =   [F] Membrane Capacitances.
                Rs              =   [V] Maximum Membrane Voltages.
                g_syn_maxs      =   [S] Maximum Synaptic Conductances.
                dE_syns         =   [V] Synaptic Reversal Potentials.
                Ams             =   [?] Ion Channel Activation Parameter 1.
                Sms             =   [?] Ion Channel Activation Parameter 2.
                dEms            =   [?] Ion Channel Activation Parameter 3.
                Ahs             =   [?] Ion Channel Deactivation Parameter 1.
                Shs             =   [?] Ion Channel Deactivation Parameter 2.
                dEhs            =   [?] Ion Channel Deactivation Parameter 3.
                tauh_maxs       =   [s] Ion Channel Deactivation Time Constant.
                Gnas            =   [S] Ion Channel Conductances.
                dEnas           =   [V] Ion Channel Reversal Potential.
                I_tonics        =   [V] Tonic Currents.
                I_apps          =   [V] Applied Currents.
                V_apps_cell     =   [V] Applied Voltages (When used, the associated neurons have the voltages clamped to these values.)
                dt              =   [s] Simulation Timestep.
                method          =   [str] Integration Method.
            
            Output(s):
                Us              =   [V] Membrane Voltages.
                hs              =   [-] Ion Channel Deactivation Parameters.
                dUs             =   [V/s] Membrane Voltage Time Derivatives.
                dhs             =   [-/s] Ion Channel Deactivation Parameter Time Derivatives.
                G_syns          =   [S] Synaptic Conductances.
                I_leaks         =   [A] Leak Currents.
                I_syns          =   [A] Synaptic Currents.
                I_nas           =   [A] Ion Channel Currents.
                I_totals        =   [A] Total Currents.
                m_infs          =   [-] Steady State Ion Channel Activation Parameters.
                h_infs          =   [-] Steady State Ion Channel Deactivation Parameters.
                tauhs           =   [s] Ion Channel Deactivation Parameter Time Constant.
            %}
            
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
            
            %{
            Input(s):
                Us0         =   [V] num_neurons x 1 vector of initial membrane voltages of each neuron w.r.t their resting potentials.
                hs0         =   [-] num_neurons x 1 vector of initial sodium channel deactivation parameters for each neuron.
                Gms         =   [S] num_neurons x 1 vector of neuron membrane conductances.
                Cms         =   [F] num_neurons x 1 vector of neuron membrane capacitances.
                Rs        	=   [V] num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
                gsyn_maxs	=   [S] num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
                dEsyns      =   [V] num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
                Ams         =   [?] num_neurons x 1 vector of sodium channel activation A parameter values.
                Sms         =   [?] num_neurons x 1 vector of sodium channel activation S parameter values.
                dEms        =   [?] num_neurons x 1 vector of sodium channel activation parameter reversal potentials.
                Ahs         =   [?] num_neurons x 1 vector of sodium channel deactivation A parameter values.
                Shs         =   [?] num_neurons x 1 vector of sodium channel deactivation S parameter values.
                dEhs        =   [?] num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
                tauh_maxs   =   [s] num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
                Gnas        =   [S] num_neurons x 1 vector of sodium channel conductances for each neuron.
                dEnas       =   [V] num_neurons x 1 vector of sodium channel reversal potentials for each neuron.
                Iapp        =   [A] num_neurons x num_timesteps vector of applied currents for each neuron.
                tf          =   [s] Scalar that represents the simulation duration.
                dt          =   [s] Scalar that represents the simulation time step.
            
            Output(s):
                ts          =   [s] 1 x num_timesteps vector of the time associated with each simulation step.
                Us          =   [V] num_neurons x num_timesteps matrix of the neuron membrane voltages over time w.r.t. their resting potentials.
                hs          =   [-] num_neurons x num_timesteps matrix of neuron sodium channel deactivation parameters.
                dUs         =   [V/s] num_neurons x num_timesteps matrix of neuron membrane voltage derivatives over time w.r.t their resting potentials.
                dhs         =   [-/s] num_neurons x num_timesteps matrix of neuron sodium channel deactivation parameter derivatives.
                Gsyns       =   [S] num_neurons x num_neurons x num_timesteps tensor of synapse conductances over time.  The ijk entry represens the synaptic condutance from neuron j to neuron i at time step k.
                Ileaks      =   [A] num_neurons x num_timsteps matrix of neuron leak currents over time.
                Isyns       =   [A] num_neurons x num_timesteps matrix of synaptic currents over time.
                Inas        =   [A] num_neurons x num_timesteps matrix of sodium channel currents for each neuron.
                Itotals     =   [A] num_neurons x num_timesteps matrix of total currents for each neuron.
                minfs       =   [-] num_neurons x num_timesteps matrix of neuron steady state sodium channel activation values.
                hinfs       =   [-] num_neurons x num_timesteps matrix of neuron steady state sodium channel deactivation values.
                tauhs       =   [s] num_neurons x num_timesteps matrix of sodium channel deactivation parameter time constants.
            %}
            
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
        
        
        %% Plotting Functions.
        
        % Implement a function to plot the network currents over time.
        function fig = plot_network_currents( ~, ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs )
            
            %{
            Input(s):
                ts          =   [s] Times.
                I_leaks     =   [A] Leak Currents.
                I_syns      =   [A] Synaptic Currents.
                I_nas       =   [A] Ion Channel Currents.
                I_apps      =   [A] Applied Currents.
                I_totals    =   [A] Total Currents.
                neuron_IDs  =   [#] Neuron IDs.
            
            Output(s):
                fig         =   [-] Network Currents Figure.
            %}
            
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
            
            %{
            Input(s):
                ts          =   [s] Times.
                Us          =   [V] Membrane Voltages.
                hs          =   [-] Ion Channel Deactivation Parameters.
                neuron_IDs  =   [#] Neuron IDs.
            
            Output(s):
                fig         =   [-] Network States Figure.
            %}
            
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
            
            %{
            Input(s):
                Us              =   [V] Membrane Voltages.
                hs              =   [-] Ion Channel Deactivation.
                neuron_IDs      =   [#] Neuron IDs.
                num_playbacks   =   [#] Number of Animation Playbacks.
                playback_speed  =   [#] Playback Speed. 1 = Use Every Frame, 2 = Use Every Other Frame , 3 = Use Every Third Frame, etc.
            
            Output(s):
                fig             =   [-] Network State Animation Figure.
            %}
            
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
            for j = 1:num_playbacks                                 % Iterate through each play back...
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

