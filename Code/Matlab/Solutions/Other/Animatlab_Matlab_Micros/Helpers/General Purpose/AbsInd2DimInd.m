function [ inds ] = AbsInd2DimInd( dims, loc )

%Compute the number of dimensions.
ndims = length(dims);

%Preallocate a variable to store the location values and indexes.
[locs, inds] = deal( zeros(1, ndims) );

%Define the first location value.
locs(1) = loc;

%Compute the first ndims - 1 indexes.
for k = 1:(ndims - 1)                               %Iterate through all but the last dimension...
    
    %Compute the divisor.
    div = prod(dims(1:(ndims - k)));
    
    %Compute the location within the set of lower dimensions.
    locs(k + 1) = mod(locs(k), div);
    
    %Compute the current index.
    inds(k) = (locs(k) - locs(k + 1))/div + 1;
    
    %Adjust the location and index values if the value is in the final row, col, layer, etc.
    if locs(k + 1) == 0                 %If the value is in the final row, col, layter, etc...
        %Adjust the location value.
        locs(k + 1) = div;
        
        %Adjust the index value.
        inds(k) = inds(k) - 1;
    end
    
end

%Commpute the final index.
inds(end) = locs(end);

%Flip the indexes to be in the appropriate order.
inds = fliplr(inds);

end

