function [ Gcl, K, L ] = GetSSOController( G, ps, OIF, rt_spacing )
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
[ ~, K ] = GetSSController( G, ps );

%% Compute the Observer Gain Matrix.

%Compute the maximum observer root.
ps_obs_max = OIF*min(ps);

%Preallocate an array to store the observer roots.
ps_obs = zeros(1, length(ps));

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
    Ao = [G.a, -G.b*K; L*G.c, G.a - G.b*K - L*G.c];
    Bo = [G.b; G.b];
    Co = [zeros(size(G.c, 1), size(G.c, 2)), G.c];
    Do = G.d;
    
    %Define the SSO CL System.
    Gcl = ss( Ao, Bo, Co, Do );
    
else
    
    %Throw a warning that some of the states are not observable.
    warning('SSO Controller: At least one state is unobservable.')
    
    %Set the function outputs to be empty.
    Gcl = ''; K = []; L = [];
    
end

end

