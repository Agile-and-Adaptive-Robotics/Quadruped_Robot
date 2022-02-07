classdef network_utilities_class
    
    % This class contains properties and methods related to network utilities.
    
    
    %% NETWORK UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        neuron_utilities
        
    end
    
    
    %% NETWORK UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_utilities_class(  )
            
            % Create an instance of the neuron utilities class.
            self.neuron_utilities = neuron_utilities_class(  );
            
        end
        
        
        
        %% Synapse Functions
        
        % Implement a function to comptue the maximum synaptic conductance.
        function g_syn_max_vector = compute_max_synaptic_conductance_vector( self, deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, Iapps_tonic )
            
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
                        I_leak = self.neuron_utilities.compute_leak_current( deltas(i, k), Gms(i) );
                        
                        % Compute the sodium channel current.
                        I_na = self.neuron_utilities.compute_sodium_current( deltas(i, k), Gnas(i), Ams(i), Sms(i), dEms(i), Ahs(i), Shs(i), dEhs(i), dEnas(i) );
                        
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
        function g_syn_max_matrix = max_synaptic_conductance_vector2max_synaptic_conductance_matrix( ~, g_syn_max_vector, n )
            
            % Preallocate the synaptic conductance matrix.
            g_syn_max_matrix = zeros( n );
            
            % Initialize the previous row variable.
            row_prev = 0;
            
            % Store each of the synaptic conductance vector entries into the synaptic conductance matrix.
            for k = 1:length( g_syn_max_vector )            % Iterate through each synaptic conductance...
                
                % Compute the relevant remainder and quotient.
                r = mod( k - 1, n - 1 );
                q = ( k - r - 1 )/( n - 1 );
                
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
        function g_syn_max_matrix = compute_max_synaptic_conductance_matrix( self, deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, I_tonics )

            % Compute the maximum synaptic conductance vector.
            g_syn_max_vector = self.compute_max_synaptic_conductance_vector( deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, I_tonics );
            
            % Retrieve the number of neurons.
            num_neurons = length( Gms );
            
            % Compute the maximum synaptic conductance matrix.
            g_syn_max_matrix = self.max_synaptic_conductance_vector2max_synaptic_conductance_matrix( g_syn_max_vector, num_neurons );
            
        end
        
        
    end
end

