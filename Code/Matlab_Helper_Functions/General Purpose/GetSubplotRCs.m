function [ nrows, ncols ] = GetSubplotRCs( n, bPreferColumns )

%If the value is not supplied by the user, default to preferring to add
%rows.
if nargin < 2, bPreferColumns = false; end

%Determine whether n is an integer.
if n ~= round(n)                                                            %If n is not an integer...
    n = round(n);                                                           %Round n to the nearest integer.
    warning('n must be an integer.  Rounding n to the nearest integer.')    %Throw a warning about rounding n.
end

%Compute the square root of the integer of interest.
nsr = sqrt(n);

%Determine how many rows and columns to use in the subplot.
if nsr == round(nsr)                    %If n is a perfect square...
    [nrows, ncols] = deal(nsr);         %Set the number of rows and columns to be the square root.
else
    %Compute all divisors of n.
    dn = divisors(n);                   
    
    %Set the number of rows and columns to be the central divisors.
    nrows = dn(length(dn)/2 + 1);
    ncols = dn(length(dn)/2);
end

%Determine whether to give prefernce to columns or rows.
if bPreferColumns                           %If we want to prefer columns...
    
    %Flip the row and column assignments, since we prefer rows by default.
    [nrows, ncols] = deal(ncols, nrows);
    
end

end

