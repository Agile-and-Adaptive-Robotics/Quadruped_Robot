function [ muscle_integers ] = ConvertMuscleSingles2Integers( muscle_singles )

%Define the input range and output range for the mapping.
% in_range = [0 450]; out_range = [0 65536];
in_range = [0 450]; out_range = [0 65535];

%Map the muscle singles from their input range to the output range and round to whole numbers.
muscle_integers = round(interp1(in_range, out_range, muscle_singles));


end

