function [ ns ] = linspace2( nstart, nstep, nnum )
%This function creates a vector of points that starts at nstart with a step size of nstep and a nnum total entries.

%PReallocate a variable to store the array entries.
ns = zeros(1, nnum);

%Build the array.
for k = 1:nnum                          %Iterate through each array entry...
    ns(k) = nstart + nstep*(k - 1);     %Calculate the next array entry.
end

end

