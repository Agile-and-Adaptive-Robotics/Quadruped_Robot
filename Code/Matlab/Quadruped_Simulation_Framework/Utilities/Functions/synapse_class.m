classdef synapse_class

    % This class contains properties and methods related to synapses.
    
    %% SYNAPSE PROPERTIES
    
    % Define the class properties.
    properties
        dEsyn
        gsyn_max
        to_neuron_ID
        from_neuron_ID
    end
    
    
    %% SYNAPSE METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_class( dEsyn, gsyn_max, from_neuron_ID, to_neuron_ID )

            % Set the default synapse properties.
            if nargin < 4, self.to_neuron_ID = 0; else, self.to_neuron_ID = to_neuron_ID; end
            if nargin < 3, self.from_neuron_ID = 0; else, self.from_neuron_ID = from_neuron_ID; end
            if nargin < 2, self.gsyn_max = 1e-6; else, self.gsyn_max = gsyn_max; end
            if nargin < 1, self.dEsyn = -40e-3; else, self.dEsyn = dEsyn; end

        end
        
        
        %% CPG Functions
        
        % Implement a function to compute the steady state sodium channel activation and deactivation parameters.
        function mhinfs = get_mhinfs( ~, Us, Amhs, Smhs, dEmhs )
        
            % This function computes the steady state sodium channel activation / deactivation parameter for every neuron in a network.

            % Inputs:
                % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials for each neuron in the network.
                % Amhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation A parameters.
                % Smhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation S parameters.
                % dEmhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation reversal potential w.r.t thier resting potentials.

            % Outputs:
                % mhinfs = num_neurons x 1 vector of neuron steady state sodium channel activation /deactivation values.

            % Compute the steady state sodium channel activation / deactivation parameter.
            mhinfs = 1./(1 + Amhs.*exp(-Smhs.*(dEmhs - Us)));
            
        end
        
        
        % Implement a function to compute the delta matrix required to make a multistate CPG oscilate in a specific order.
        function deltas = get_delta_matrix( ~, neuron_order, delta_bistable, delta_oscillatory )

            % This function computes the delta matrix required to make a multistate CPG oscillate in a specified order.

            % Inputs:
                % neuron_order = 1 x num_neurons array that specifies the order in which the multistate CPG should oscillate.
                % delta_bistable = Scalar delta value that describes the steady state voltage to which low neurons should be sent in bistable configurations.
                % delta_oscillatory = Scalar delta value that describes the steady state voltage to which low neurons should be sent in oscillatory configurations.

            % Outputs:
                % deltas = num_neurons x num_neurons matrix whose ij entry is the delta value that describes the synapse from neuron j to neuron i.

            % Compute the number of neurons.
            num_neurons = length( neuron_order );

            % Initialize the delta matrix to be completely bistable.
            deltas = delta_bistable*ones( num_neurons, num_neurons );

            % Switch the desired synapses to be oscillatory.
            for k = 1:num_neurons

                % Compute the index of the next neuron in the chain.
                j = mod( k, num_neurons ) + 1;

                % Compute the from and to indexes.
                from_index = neuron_order(k);
                to_index = neuron_order(j);

                % Set the appropriate synapse to be oscillatory.
                deltas( to_index, from_index ) = delta_oscillatory;

            end

            % Zero out the diagonal entries.
            deltas(1:(1 + size(deltas, 1)):end) = 0;

        end


        % Implement a function to convert a vector of synaptic conductances to a matrix of synaptic conductances.
        function gsyns_matrix = gsyn_max_vector2gysn_max_matrix( ~, gsyns_vector, n )

            % Preallocate the synaptic conductance matrix.
            gsyns_matrix = zeros(n, n);

            % Initialize the previous row variable. 
            row_prev = 0;

            % Store each of the synaptic conductance vector entries into the synaptic conductance matrix.
            for k = 1:length(gsyns_vector)            % Iterate through each synaptic conductance...

                % Compute the relevant remainder and quotient.
                r = mod(k - 1, n - 1);
                q = (k - r - 1)/(n - 1);

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
                gsyns_matrix( row, col ) = gsyns_vector(k);

                % Store the current row as the previous row for the next iteration.
                row_prev = row;

            end

        end


        % Implement a function to compute the maximum synaptic conductances for a multistate CPG to achieve the specified delta matrix with the given network properties.
        function gsyn_maxs = get_multistate_CPG_max_conductances( self, deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, Iapps_tonic )
            
            % This function computes the maximum synaptic conductances for a chain of CPGs necessary to achieve the specified deltas with the given network properties.

            % Retrieve the number of neurons.
            num_neurons = length(Gms);

            % Define an anonymous function to compute the steady state sodium channel activation parameter.
            fminf = @( U, Am, Sm, dEm ) self.get_mhinfs( U, Am, Sm, dEm );

            % Define an anonymous function to compute the steady state sodium channel deactivation parameter.
            fhinf = @( U, Ah, Sh, dEh ) self.get_mhinfs( U, Ah, Sh, dEh );

            % Define an anonymous function to compute leak currents.
            fIleak = @( U, Gm ) -Gm.*U;

            % Define an anonymous function to compute sodium channel currents.
            fInainf = @( U, Gna, Am, Sm, dEm, Ah, Sh, dEh, dEna ) Gna.*fminf( U, Am, Sm, dEm ).*fhinf( U, Ah, Sh, dEh ).*( dEna - U );

            % Define an anonymous function that is the opposite of the kronecker delta function.
            neq = @(a, b) 1 - eq(a, b);

            % Compute the number of equations we need to solve.
            num_eqs = num_neurons.*(num_neurons - 1);

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

                        % Compute the system and right-hand side coefficients.
                        aik1 = deltas(i, k) - dEsyns(i, k);
                        aik2 = neq(p, k).*( deltas(p, k)./Rs(p, k) ).*( deltas(i, k) - dEsyns(p, k) );
                        bik = fIleak( deltas(i, k), Gms(i) ) + fInainf( deltas(i, k), Gnas(i), Ams(i), Sms(i), dEms(i), Ahs(i), Shs(i), dEhs(i), dEnas(i) ) + Iapps_tonic(i);

                        % Determine the row index at which to store these coefficients.
                        r = (num_neurons - 1).*(k - 1) + i;

                        % Determine whether to correct the row entry.
                        if i > k                % If this is an entry whose row index needs to be corrected...

                            % Correct the row entry.
                            r = r - 1;

                        end

                        % Determine the column index at which to store the first coefficient.
                        c1 = (num_neurons - 1).*(i - 1) + k;

                        % Determine whether the first column index needs to be corrected.
                        if k > i                % If this is an entry whose first column index needs to be corrected...

                            % Correct the first column index.
                            c1 = c1 - 1;

                        end

                        % Determine the column index at which to store the second coefficient.
                        c2 = (num_neurons - 1).*(p - 1) + k;

                        % Determine whether the second column index needs to be corrected.
                        if k > p                % If this is an entry whose second column index needs to be corrected...

                            % Correct the second column index.
                            c2 = c2 - 1;

                        end

                        % Store the first and second system matrix coefficients.
                        A(r, c1) = A(r, c1) + aik1;
                        A(r, c2) = A(r, c2) + aik2;

                        % Store the right-hand side coefficient.
                        b(r) = bik;

                    end

                end
            end

            % Solve the system of equations.
            gsyns_vector = A\b;

            % Convert the maximum synaptic conductance vector into a matrix.
            gsyn_maxs = self.gsyn_max_vector2gysn_max_matrix( gsyns_vector, num_neurons );

        end


        

    end
end

