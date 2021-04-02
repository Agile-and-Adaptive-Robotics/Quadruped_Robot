function [ H1, H2 ] = Impulse2Hankle( ys )

ys = ys(:, :, 2:end);

num_inputs = size(ys, 2);
num_outputs = size(ys, 1);

hankle_size = floor( size(ys, 3)/2 );

[H1, H2] = deal( zeros(num_outputs*hankle_size, num_inputs*hankle_size) );

for i=1:hankle_size
    for j=1:hankle_size
        for Q=1:num_outputs
            for P=1:num_inputs
                H1(num_outputs*i-num_outputs+Q,num_inputs*j-num_inputs+P) = ys(Q,P,i+j-1);
                H2(num_outputs*i-num_outputs+Q,num_inputs*j-num_inputs+P) = ys(Q,P,i+j);
            end
        end
    end
end

end

