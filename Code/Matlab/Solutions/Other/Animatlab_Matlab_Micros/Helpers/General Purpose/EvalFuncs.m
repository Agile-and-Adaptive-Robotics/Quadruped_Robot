function [ ys ] = EvalFuncs( fs, x )

%Preallocate a variable to store the function outputs.
ys = zeros(size(fs, 1), size(fs, 2));

%Evaluate each function at the given point.
for k1 = 1:size(fs, 1)          %Iterate through each row of the functions...
    for k2 = 1:size(fs, 2)      %Iterate through each column of the functions...
        
        %Retrieve the current function to evaluate.
        f = fs{k1, k2};
        
        %Evaluate the current function and store it in a matrix.
        ys(k1, k2) = f(x);
        
    end
end

end

