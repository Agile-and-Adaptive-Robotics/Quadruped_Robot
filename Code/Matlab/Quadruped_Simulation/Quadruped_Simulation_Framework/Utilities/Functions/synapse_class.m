classdef synapse_class

    % This class contains properties and methods related to synapses.
    
    %% SYNAPSE PROPERTIES
    
    % Define the class properties.
    properties
     
        ID
        name
        
        dE_syn
        g_syn_max
        
        from_neuron_ID
        to_neuron_ID
    
        delta
        
    end
    
    
    %% SYNAPSE METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_class( ID, name, dE_syn, g_syn_max, from_neuron_ID, to_neuron_ID, delta )

            % Set the default synapse properties.
            if nargin < 7, self.delta = 0; else, self.delta = delta; end
            if nargin < 6, self.to_neuron_ID = 0; else, self.to_neuron_ID = to_neuron_ID; end
            if nargin < 5, self.from_neuron_ID = 0; else, self.from_neuron_ID = from_neuron_ID; end
            if nargin < 4, self.g_syn_max = 1e-6; else, self.g_syn_max = g_syn_max; end
            if nargin < 3, self.dE_syn = -40e-3; else, self.dE_syn = dE_syn; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end

        end
        
        
        %% CPG Functions
       

%         % Implement a function to convert a vector of synaptic conductances to a matrix of synaptic conductances.
%         function gsyns_matrix = g_syn_max_vector2gysn_max_matrix( ~, gsyns_vector, n )
% 
%             % Preallocate the synaptic conductance matrix.
%             gsyns_matrix = zeros(n, n);
% 
%             % Initialize the previous row variable. 
%             row_prev = 0;
% 
%             % Store each of the synaptic conductance vector entries into the synaptic conductance matrix.
%             for k = 1:length(gsyns_vector)            % Iterate through each synaptic conductance...
% 
%                 % Compute the relevant remainder and quotient.
%                 r = mod(k - 1, n - 1);
%                 q = (k - r - 1)/(n - 1);
% 
%                 % Compute the row associated with this entry.
%                 row = q + 1;
% 
%                 % Determine whether to reset the column associated with this entry.
%                 if row ~= row_prev              % If the current row is different than the previous row...
% 
%                     % Reset the column index.
%                     col = 0;
% 
%                 end
% 
%                 % Advance the column index.
%                 col = col + 1;
% 
%                 % Determine whether the column index needs to be advanced a second time.
%                 if row == col           % If this column would yield an entry on the diagonal...
% 
%                     % Advance the column index a second time.
%                     col = col + 1;
% 
%                 end
% 
%                 % Store the current synaptic conductance vector entry into the correct synaptic conductance matrix location.
%                 gsyns_matrix( row, col ) = gsyns_vector(k);
% 
%                 % Store the current row as the previous row for the next iteration.
%                 row_prev = row;
% 
%             end
% 
%         end


        
        
%         % Implement a function to compute the maximum synaptic conductances for a multistate CPG to achieve the specified delta matrix with the given network properties.
%         function g_syn_maxs = get_multistate_CPG_max_conductances( self, deltas, Gms, Rs, dE_syns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, Iapps_tonic )
%             
%             % This function computes the maximum synaptic conductances for a chain of CPGs necessary to achieve the specified deltas with the given network properties.
% 
%             % Retrieve the number of neurons.
%             num_neurons = length(Gms);
% 
%             % Define an anonymous function to compute the steady state sodium channel activation parameter.
%             fminf = @( U, Am, Sm, dEm ) self.get_mhinfs( U, Am, Sm, dEm );
% 
%             % Define an anonymous function to compute the steady state sodium channel deactivation parameter.
%             fhinf = @( U, Ah, Sh, dEh ) self.get_mhinfs( U, Ah, Sh, dEh );
% 
%             % Define an anonymous function to compute leak currents.
%             fIleak = @( U, Gm ) -Gm.*U;
% 
%             % Define an anonymous function to compute sodium channel currents.
%             fInainf = @( U, Gna, Am, Sm, dEm, Ah, Sh, dEh, dEna ) Gna.*fminf( U, Am, Sm, dEm ).*fhinf( U, Ah, Sh, dEh ).*( dEna - U );
% 
%             % Define an anonymous function that is the opposite of the kronecker delta function.
%             neq = @(a, b) 1 - eq(a, b);
% 
%             % Compute the number of equations we need to solve.
%             num_eqs = num_neurons.*(num_neurons - 1);
% 
%             % Preallocate an array to store the system matrix and right-hand side.
%             A = zeros( num_eqs, num_eqs );
%             b = zeros( num_eqs, 1 );
% 
%             % Compute the system matrix and right-hand side entries.
%             for k = 1:num_neurons               % Iterate through each of the neurons...
% 
%                 % Compute the critical index p.
%                 p = mod( k, num_neurons ) + 1;
% 
%                 % Compute the system matrix and right-hand side entries.
%                 for i = 1:num_neurons           % Iterate through each of the neurons...
% 
%                     % Determine whether to compute system matrix and right-hand side entries for this synapse.
%                     if i ~= k                   % If this synapse is not a self-connection...
% 
%                         % Compute the system and right-hand side coefficients.
%                         aik1 = deltas(i, k) - dE_syns(i, k);
%                         aik2 = neq(p, k).*( deltas(p, k)./Rs(p, k) ).*( deltas(i, k) - dE_syns(p, k) );
%                         bik = fIleak( deltas(i, k), Gms(i) ) + fInainf( deltas(i, k), Gnas(i), Ams(i), Sms(i), dEms(i), Ahs(i), Shs(i), dEhs(i), dEnas(i) ) + Iapps_tonic(i);
% 
%                         % Determine the row index at which to store these coefficients.
%                         r = (num_neurons - 1).*(k - 1) + i;
% 
%                         % Determine whether to correct the row entry.
%                         if i > k                % If this is an entry whose row index needs to be corrected...
% 
%                             % Correct the row entry.
%                             r = r - 1;
% 
%                         end
% 
%                         % Determine the column index at which to store the first coefficient.
%                         c1 = (num_neurons - 1).*(i - 1) + k;
% 
%                         % Determine whether the first column index needs to be corrected.
%                         if k > i                % If this is an entry whose first column index needs to be corrected...
% 
%                             % Correct the first column index.
%                             c1 = c1 - 1;
% 
%                         end
% 
%                         % Determine the column index at which to store the second coefficient.
%                         c2 = (num_neurons - 1).*(p - 1) + k;
% 
%                         % Determine whether the second column index needs to be corrected.
%                         if k > p                % If this is an entry whose second column index needs to be corrected...
% 
%                             % Correct the second column index.
%                             c2 = c2 - 1;
% 
%                         end
% 
%                         % Store the first and second system matrix coefficients.
%                         A(r, c1) = A(r, c1) + aik1;
%                         A(r, c2) = A(r, c2) + aik2;
% 
%                         % Store the right-hand side coefficient.
%                         b(r) = bik;
% 
%                     end
% 
%                 end
%             end
% 
%             % Solve the system of equations.
%             gsyns_vector = A\b;
% 
%             % Convert the maximum synaptic conductance vector into a matrix.
%             g_syn_maxs = self.g_syn_max_vector2gysn_max_matrix( gsyns_vector, num_neurons );
% 
%         end


        

    end
end

