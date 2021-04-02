function [ A_okidera, B_okidera, C_okidera, D_okidera, singular_values_okidera ] = OKIDERA( ys_random, us_random, mode, parameter )


%% Handle Variable Input Arguments.

%Handle the case with all four inputs.
if nargin == 4                                                                                                               %If there are four inputs...
    
    %Determine how to set the desired rank.
    if strcmp(mode, 'Rank') || strcmp(mode, 'rank')                                                                          %If the user has specified a rank...
        
        %Set the rank to the user specified value.
        desired_rank = 5*parameter;
        
    elseif strcmp(mode, 'Tolerance') || strcmp(mode, 'tolerance') || strcmp(mode, 'Tol') || strcmp(mode, 'tol')               %If the user has specified to use a tolerance.
        
        %Compute the desired rank.
        desired_rank = floor(0.8*length(us_random));
        
    end
    
end

%Handle the case with only three inputs.
if nargin == 3                                                                                                                  %If there are three inputs...
    
    %Determine which default arguments to apply.
    if strcmp(mode, 'Rank') || strcmp(mode, 'rank')                                                                             %If the mode is set to 'rank'...
        
        %Throw an error.
        error('Must specify desired rank.')
        
    elseif strcmp(mode, 'Tolerance') || strcmp(mode, 'tolerance') || strcmp(mode, 'Tol') || strcmp(mode, 'tol')                 %If the mode is set to 'tol'...
        
        %Compute the desired rank.
        desired_rank = floor(0.8*length(us_random));
        
    else
        
        %Throw an error.
        error('Mode not recognized')
        
    end
    
end

%Handle the case with only two inputs.
if nargin == 2                                          %If there are only two inputs...
    %Compute the desired rank.
    %     desired_rank = floor(0.8*length(us_random));
    %     desired_rank = 50;
    desired_rank = 10;
end

%% Perform the OKID-ERA Method.

%Construct an impulse response from the pseudorandom input.
ys_impulse_okid = OKID(ys_random, us_random, desired_rank);
ys_impulse_okid = permute(ys_impulse_okid, [3 1 2]);

%Perform the ERA on the OKID impulse reconstruction data.
if nargin == 2
    [A_okidera, B_okidera, C_okidera, D_okidera, singular_values_okidera] = ERA(ys_impulse_okid);
elseif nargin == 3
    [A_okidera, B_okidera, C_okidera, D_okidera, singular_values_okidera] = ERA(ys_impulse_okid, mode);
else
    [A_okidera, B_okidera, C_okidera, D_okidera, singular_values_okidera] = ERA(ys_impulse_okid, mode, parameter);
end


end

