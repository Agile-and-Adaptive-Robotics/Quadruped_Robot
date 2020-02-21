function [ zs ] = MixArrays( xs, ys )

%Compute the length of the mixed array.
n = length(xs) + length(ys);

%Preallocate the mixed array.
zs = zeros(1, n);

%Define counter variables.
[k, kx, ky] = deal( 0 );

%Create the mixed array.
while k < n                %Iterate through each element in the mixed array...
    
    %Advance the counter.
    k = k + 1;
    
    %If the current element is still
    if (kx < length(xs)) && (ky < length(ys))
        if kx <= ky
            %Advance the x counter.
            kx = kx + 1;
            
            %Store an element from the x array.
            zs(k) = xs(kx);
        elseif ky < kx
            %Advance the y counter.
            ky = ky + 1;
            
            %Store an element from the y array.
            zs(k) = ys(ky);
        end
    elseif kx < length(xs)
        %Advance the x counter.
        kx = kx + 1;
        
        %Store an element from the x array.
        zs(k) = xs(kx);
    elseif ky < length(ys)
        %Advance the y counter.
        ky = ky + 1;
        
        %Store an element from the y array.
        zs(k) = ys(ky);
    end
end

end

