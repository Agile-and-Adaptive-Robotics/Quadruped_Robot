function bichromatic_map = GetBichromaticColormap(num_colors, gradient_magnitude)

%Set the default input arguments.
if nargin < 2, gradient_magnitude = 0.75; end
if nargin < 1, num_colors = 1e6; end

%Get the current color axis.
caxis_current = caxis;

%Determine the percentage of the color axis that is positive.
if all(caxis_current > 0)                                       %If the color axis is entirely positive...
    
    %Set the caxis positive percentage to 100%.
   percent_positive = 1;
   
elseif all(caxis_current < 0)                                   %If the color axis is entirely negative...
    
    %Set the caxis positive percentage to 0%.
    percent_positive = 0;
    
else                                                            %Otherwise...
    
    %Compute the current caxis range.
    caxis_range = range(caxis_current);
    
    %Compute the percentage of the current caxis range that is positive.
    percent_positive = caxis_current(2)/caxis_range;
    
end

%Compute the number of colors to use for the positive part of the surface.
num_colors2 = round(percent_positive*num_colors);

%Compute the number of colors to use for the negative part of the surface.
num_colors1 = num_colors - num_colors2;

%Preallocate the custom color map.
bichromatic_map = zeros(num_colors, 3);

%Set the magnitude of the gradient for the two colors.
mags1 = linspace(0, gradient_magnitude, num_colors1); mags2 = linspace(gradient_magnitude, 0, num_colors2);

%Set the colors for the negative part of the surface.
for k = 1:num_colors1                                               %Iterate through all of the negative colors...
    
    %Set each negative color to be a shade of blue.
    bichromatic_map(k, :) = [mags1(k) mags1(k) 1];
    
end

%Set the colors for the positive part of the surface.
for k = 1:num_colors2                                               %Iterate through all of the positive colors...
    
    %Set each positive color to be a shade of red.
    bichromatic_map(num_colors1 + k, :) = [1 mags2(k) mags2(k)];
    
end


end

