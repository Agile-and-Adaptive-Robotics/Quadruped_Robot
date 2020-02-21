function [ z ] = s2z( s, T )

%Compute the digital design points.
z = exp(T*s);

end

