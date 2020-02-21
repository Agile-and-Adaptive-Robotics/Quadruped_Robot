function [ values_crit ] = RetrieveSpecificMuscleValues( IDs, values, ID_crits )


%Retrieve the number of values of interest.
num_critical_values = length(ID_crits);

%Preallocate an array to store the indexes associated with each of the values of interest.
locs = zeros(1, num_critical_values);

%Preallocate a counter to keep track of the number of values of interest located.
count = 0;

%Determine the index associated with each critical value in the values array.
for k = 1:num_critical_values                       %Iterate through all of the critical values...
    
    %Retrieve the index associated with this critical value.
    loc = find(IDs == ID_crits(k), 1);
    
    %Determine whether a valid index was found.
    if ~isempty(loc)                                %If a valid index was found...
        %Advance the valid index counter.
        count = count + 1;
        
        %Add this index to the crtical index array.
        locs(count) = loc;
    end
    
end

%Remove the extra zero entries in the critical index array.
locs = locs(1:count);

%Retrieve the values associated with the critical indexes.
values_crit = values(locs);

end

