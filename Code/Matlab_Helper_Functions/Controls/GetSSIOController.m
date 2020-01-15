function [ Gcl, K, L ] = GetSSIOController( G, ps, OIF, rt_spacing )
%% Validate the User Inputs.

%Throw an error if G is not a transfer function or state space model.
if (~isa(G, 'tf')) && (~isa(G, 'ss'))
    error('G must be a transfer function or state space model.')
end

%Convert G to a state space model.
if isa(G, 'tf'), G = ss(G); end

%Set the default observer improvement factor.
if nargin < 4, rt_spacing = 1; end
if nargin < 3, OIF = 10; end

%% Generate a State Space Controller.

%Compute the state space controller gain matrix.
[ ~, K ] = GetSSIController( G, ps );

%% Compute the Observer Gain Matrix.

%Determine whether the system is controllable.
if ~isempty(K)                                              %If the state space controller gain matrix is not empty...
    
    %Compute the maximum observer root.
    ps_obs_max = OIF*min(ps);
    
    %Preallocate an array to store the observer roots.
    ps_obs = zeros(1, length(ps) - 1);
    
    %Define the observer roots.
    for k = 1:length(ps_obs)
        ps_obs(k) = ps_obs_max - (k - 1)*rt_spacing;
    end
    
    %Determine whether the system is observable.
    if (size(G.a, 2) - rank(obsv(G.a, G.c))) == 0                  %If the system is observable...
        
        %Design the observer.
        L = place(G.a', G.c', ps_obs)';
        
        %% Compute the SSO CL System.
        
        %Compute the SSO CL System Matrices.
%         Acl = [G.a, G.b*K(end), -G.b*K(1:end-1);
%             -G.c, 0, zeros(size(G.c, 1), size(G.c, 2));
%             L*G.c, G.b*K(end), G.a - G.b*K(1:end-1) - L*G.c];
%         Bcl = [zeros(size(G.b, 1), 1); 1; zeros(size(G.b, 1), 1)];
%         Ccl = [G.c, zeros(size(G.c, 1), 1), zeros(size(G.c, 1), size(G.c, 2))];
%         Dcl = G.d;
        Acl = [G.a, G.b*K(end), -G.b*K(1:end-1);
            -G.c, 0, zeros(size(G.c, 1), size(G.c, 2));
            L*G.c, G.b*K(end), G.a - G.b*K(1:end-1) - L*G.c];
        Bcl = [zeros(size(G.b)); ones(1, size(G.b, 2)); zeros(size(G.b))];
        Ccl = [G.c, zeros(size(G.c, 1), 1), zeros(size(G.c))];
        Dcl = G.d;        

        %Define the SSO CL System.
        Gcl = ss( Acl, Bcl, Ccl, Dcl );
        
    else
        
        %Throw a warning that some of the states are not observable.
        warning('SSIO Controller: At least one state is unobservable.')
        
        %Set the function outputs to be empty.
        Gcl = ''; K = []; L = [];
        
    end
    
else
    
    %Throw a warning that some of the states are not controllable.
    warning('SSIO Controller: At least one state is uncontrollable.')
    
    %Set the function outputs to be empty.
    Gcl = ''; K = []; L = [];
    
end

end

