function [A, B, C, D, singular_values] = ERA(impulse_data, mode, parameter)
%This function performs the eigensystem realization algorithm on impulse data to generate a reduced order approximation of the system to which the impulse data belongs.

%INPUTS:
    %impulse_data = impulse data in the format that is output by Matlab's impulse function.  A SISO input would be a column vector.  A MIMO input would be a num_data_points X num_inputs X num_outputs multidimensional matrix.
    
    %mode = A string indicating the desired ERA mode.  There are three valid modes: rank, fullrank, and tol.
        %rank = The ERA yields a reduced order approximation of the system using the specified rank.  If no rank is specified, the ERA yields  full rank approximation instead.
        %fullrank = The ERA yields a full rank approximation of the system using the highest rank available based on the quantity of input data.  No parameter specification is required.
        %tol = The ERA yields a redced order approximation of the system that captures 100*tol percent of the variation in the full order system.  If no tolerance is specified, then the parameter defaults to 0.99.
        %If no input is provided, then the mode defaults to tol and the associated parameter defaults to 0.99.
        
    %parameter = A parameter value whose meaning depends on the specified mode.
        %rank = The parameter is the desired rank of the reduced order approximation.  If no parameter is specified, the ERA defaults to using full rank.
        %fullrank = No parameter is required and any parameter input is ignored.
        %tol = The parameter specifies the portion of the variability of the full rank system that should be captured by the reduced order system.  If no parameter is specified, the ERA defaults to using 0.99.

%OUPUTS:
    %A, B, C, D = The state space system matrices for the reduced order approximation of the system to which the impulse data belongs based on the ERA.
    %singular_values = A column vector the singular values of the hankle matrix formed by the impulse data.
        
%% Handle Variable Inputs.

%Handle the case where there are two input arguments.
if nargin == 2                                      %If the number of input arguments is two...
    
    %Handle each mode case separately.
    if strcmp(mode, 'FullRank') || strcmp(mode, 'fullrank') || strcmp(mode, 'Fullrank') || strcmp(mode, 'fullRank')
        
    elseif strcmp(mode, 'Rank') || strcmp(mode, 'rank')                                                                      %If rank mode is selected...
        
        %Set the mode to full rank.
        mode = 'FullRank';
        
    elseif strcmp(mode, 'Tolerance') || strcmp(mode, 'tolerance') || strcmp(mode, 'Tol') || strcmp(mode, 'tol')          %If tolerance mode is selected...
        
        %Set the tolerance to 99%.
        parameter = 0.99;
        
    else
        
        %Throw an error.
        error('Input mode not recognized. Valid options are: rank, fullrank, tolerance')
        
    end
    
end

%Handle the case where there is only one input argument.
if nargin == 1                          %If there is exactly one input arugment....
    
    %Default the mode type to tolerance with a value of 99%.
    mode = 'tol'; parameter = 0.99;
    
end


%% Compute the SVD of the Hankle Matrices Associated with the Impulse Data.

%Permute the input data such that it has the expected form.
impulse_data = permute(impulse_data, [2 3 1]);

%Generate the necessary Hankle matrices from the input data.
[ H1, H2 ] = Impulse2Hankle( impulse_data );

%Compute the number of inputs and outputs associated with the impulse data.
num_inputs = size(impulse_data, 2); num_outputs = size(impulse_data, 1);

%Compute the SVD of the data.
[U, S, V] = svd(H1, 'econ');

%Retrieve the singular values from the SVD.
singular_values = diag(S);

%% Detemine the Desired Rank of the Reduced Order Approximation.

%Determine how to compute the desired rank.
if strcmp(mode, 'FullRank') || strcmp(mode, 'fullrank') || strcmp(mode, 'Fullrank') || strcmp(mode, 'fullRank')         %If the user has requested to use full rank...
    
    %Set the desired rank to be the number of available singular value.
    desired_rank = length(singular_values);
    
elseif strcmp(mode, 'Rank') || strcmp(mode, 'rank')                                                                     %If the user has specified an explicit rank...
    
    %Set the desired rank to that specified by the user.
    desired_rank = parameter;
    
elseif strcmp(mode, 'Tolerance') || strcmp(mode, 'tolerance') || strcmp(mode, 'Tol') || strcmp(mode, 'tol')         %If the user has specified a tolerance...
    
    %Retrieve the singular value threshold.
    singular_value_threshold = parameter;
    
    %Normalize the singular values.
    normalized_singular_values = singular_values/sum(singular_values);
    
    %Compute the desired system rank.
    desired_rank = find(cumsum(normalized_singular_values) > singular_value_threshold, 1);
    
    %Ensure that the desired rank is at least as great as the number of inputs/ouputs (whichever is larger).
    if desired_rank < max([num_inputs num_outputs])                         %If the desired rank is less than the number of inputs/outputs (whichever is larger)...
        desired_rank = max([num_inputs num_outputs]);                       %Set the desired rank to be the number of inputs/outputs (whichever is larger).
    end
    
end

%% Compute the ERA Reduced Order System Approximation Matrices.

%Retrieve only the reduced order SVD.
Ur = U(:,1:desired_rank); Sigma = S(1:desired_rank,1:desired_rank); Vr = V(:,1:desired_rank);

%Compute the reduced order ERA system approximation based on the impulse data hankle matrices.
A = (Sigma^(-1/2))*Ur'*H2*Vr*(Sigma^(-1/2));
B = (Sigma^(-1/2))*Ur'*H1(:,1:num_inputs);
C = H1(1:num_outputs,:)*Vr*(Sigma^(-1/2));
D = impulse_data(:, :, 1);

end

% function [Ar, Br, Cr, Dr, HSVs] = ERA(YY, r)
%
% YY = permute(YY, [2 3 1]);
%
%  Dr = YY(:, :, 1);
%  Y = YY(:, :, 2:end);
%
% [ H1, H2 ] = Impulse2Hankle( YY );
%
% num_inputs = size(Y, 2); num_outputs = size(Y, 1);
%
% [U, S, V] = svd(H1,'econ');
%
% Ur = U(:,1:r); Sigma = S(1:r,1:r); Vr = V(:,1:r);
%
% Ar = (Sigma^(-1/2))*Ur'*H2*Vr*(Sigma^(-1/2));
% Br = (Sigma^(-1/2))*Ur'*H1(:,1:num_inputs);
% Cr = H1(1:num_outputs,:)*Vr*(Sigma^(-1/2));
%
% HSVs = diag(S);
%
% end