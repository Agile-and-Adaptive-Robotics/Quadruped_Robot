function [ B ] = StackRowBlocks( A, n )

%Define the number of columns in each block.
m = size(A, 1)/n;

%Preallocate an empty matrix.
B = [];

%Determine whether to stack the column blocks.
if m == round(m)                                        %If we can evenly divide up the columns...
    
    %Stack the column blocks.
    for k = 1:m                                         %Iterate through each block...
        B = cat(3, B, A(n*(k - 1) + 1:n*k, :));
    end
    
end

end