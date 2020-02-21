function [ values_crit ] = GetSpecificMuscleValues( IDs, values_old, values, ID_crits )

%Retrieve the number of values of interest.
num_critical_values = length(ID_crits);

%Preallocate an array to store the critical values.
values_crit = zeros(1, num_critical_values);

%Determine the index associated with each critical value in the values array.
for k = 1:num_critical_values                       %Iterate through all of the critical values...
    
    %Retrieve the index associated with this critical value.
    loc = find(IDs == ID_crits(k), 1);
    
    %Determine whether a valid index was found.
    if ~isempty(loc)                                %If a valid index was found...
        values_crit(k) = values(loc);               %Retrieve the value associated with this index.
    else                                            %Otherwise...
        values_crit(k) = values_old(k);             %Carry over the previous value.
    end
    
end

end


