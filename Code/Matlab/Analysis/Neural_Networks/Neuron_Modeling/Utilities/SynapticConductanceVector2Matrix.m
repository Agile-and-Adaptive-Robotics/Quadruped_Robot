function gsyns_matrix = SynapticConductanceVector2Matrix( gsyns_vector, n )

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

