function [ y ] = RollOverValue( x_domain, x )
%This function takes a value x and rolls it back into the domain x_domain based on the degree to which it exceeds the boundaries.

%Determine how to roll over the value.
if x >= x_domain(2)                                 %If the value is at or above the upper limit...
    
    %Attempt to roll over the value back into the desired domain.
    y = x_domain(1) + x - x_domain(2);
    
    %Continue to attempt to roll over the value until no more rollovers are required.
    y = RollOverValue( x_domain, y );
    
elseif x < x_domain(1)                              %If the value is below the lower limit...
    
    %Attempt to roll over the value back into the desired domain.
    y = x_domain(2) + x - x_domain(1);
    
    %Continue to attempt to roll over the value until no more rollovers are required.
    y = RollOverValue( x_domain, y );
    
else                                                %Otherwise...  The value is within the specified domain.
    
    %Pass this value to the output.
    y = x;
    
end

end

