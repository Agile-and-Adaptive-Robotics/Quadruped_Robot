function [ xs ] = RemoveOutliers( xs, threshold )
%This function corrects values in the matrix / vector xs that are beyond threshold different from at least one of their neighboring values.

%Compute thevalue changes.
dxs = diff(xs, 1, 2);

%Determine the absolute indexes associated with outliers.
abs_index = find(abs(dxs) > threshold);

%Compute the number of outliers.
num_outliers = length(abs_index);

%Preallocate a matrix to store the dimension based indexes..
dim_index = zeros(num_outliers, 2);

%Compute the row and column indexes associated with each of the absolute indexes.
for k = 1:num_outliers

    %Compute the dimension based index associated with this absolute index.
    dim_index(k, :) = AbsInd2DimInd( size(dxs), abs_index(k) );

    %Retrieve the column indexes associated with this outlier.
    col_indexes = dim_index(k, 2):(dim_index(k, 2) + 2);
    
    %Retrieve the adjacent values.
    ps = xs(dim_index(k , 1), col_indexes);
    
    %Iterpolate the outlying value.
    xs_interp = interp1(col_indexes([1 3]), ps([1 3]), col_indexes(2));

    %Correct the outlying value.
    xs(dim_index(k, 1), col_indexes(2)) = xs_interp;
    
end

%% Determine Whether to Initiate Another Recursive Call.

%Compute thevalue changes.
dxs = diff(xs, 1, 2);

%Determine the absolute indexes associated with outliers.
abs_index = find(abs(dxs) > threshold);

%Compute the number of outliers.
num_outliers = length(abs_index);

%Determine whether to initiate another recursive call.
if num_outliers > 0
    
    %Perform another iteration of removing the outliers.
    xs = RemoveOutliers( xs, threshold );
    
end

end

