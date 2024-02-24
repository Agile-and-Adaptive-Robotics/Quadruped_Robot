function gsyn_maxs = GetCPGChainSynapticConductances(deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, Iapps_tonic)

% This function computes the maximum synaptic conductances for a chain of CPGs necessary to achieve the specified deltas with the given network properties.

% Retrieve the number of neurons.
num_neurons = length(Gms);

% Define an anonymous function to compute the steady state sodium channel activation parameter.
fminf = @(U, Am, Sm, dEm) GetSteadyStateNaActDeactValue(U, Am, Sm, dEm);

% Define an anonymous function to compute the steady state sodium channel deactivation parameter.
fhinf = @(U, Ah, Sh, dEh) GetSteadyStateNaActDeactValue(U, Ah, Sh, dEh);

% Define an anonymous function to compute leak currents.
fIleak = @(U, Gm) -Gm.*U;

% Define an anonymous function to compute sodium channel currents.
fInainf = @(U, Gna, Am, Sm, dEm, Ah, Sh, dEh, dEna) Gna.*fminf(U, Am, Sm, dEm).*fhinf(U, Ah, Sh, dEh).*(dEna - U);

% Define an anonymous function that is the opposite of the kronecker delta function.
neq = @(a, b) 1 - eq(a, b);

% Compute the number of equations we need to solve.
num_eqs = num_neurons.*(num_neurons - 1);

% Preallocate an array to store the system matrix and right-hand side.
A = zeros(num_eqs, num_eqs);
b = zeros(num_eqs, 1);

% Compute the system matrix and right-hand side entries.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Compute the critical index p.
    p = mod(k, num_neurons) + 1;

    % Compute the system matrix and right-hand side entries.
    for i = 1:num_neurons           % Iterate through each of the neurons...
   
        % Determine whether to compute system matrix and right-hand side entries for this synapse.
        if i ~= k                   % If this synapse is not a self-connection...
            
            % Compute the system and right-hand side coefficients.
            aik1 = deltas(i, k) - dEsyns(i, k);
            aik2 = neq(p, k).*( deltas(p, k)./Rs(p, k) ).*( deltas(i, k) - dEsyns(p, k) );
            bik = fIleak(deltas(i, k), Gms(i)) + fInainf(deltas(i, k), Gnas(i), Ams(i), Sms(i), dEms(i), Ahs(i), Shs(i), dEhs(i), dEnas(i)) + Iapps_tonic(i);
                   
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
gsyn_maxs = SynapticConductanceVector2Matrix(gsyns_vector, num_neurons);


end

