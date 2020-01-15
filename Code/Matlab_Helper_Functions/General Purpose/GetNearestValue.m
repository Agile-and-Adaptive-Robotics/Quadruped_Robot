function [ y, ind ] = GetNearestValue( xs, x )

%Compute the index associated with the nearest value.
[~, ind] = min(abs(xs - x));

%Retrieve the nearest value.
y = xs(ind);

end

