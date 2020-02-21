function [ Gcl, K, L ] = GetzSSIOController( G, pz, OIF, rt_spacing )
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

%Retrieve the sampling time from the digital state space model.
[~, ~, dt] = tfdata(G);

%Compute the state space controller gain matrix.
[ ~, K ] = GetzSSIController( G, pz );

%% Compute the Observer Gain Matrix.

%Determine whether the system is controllable.
if ~isempty(K)                                              %If the state space controller gain matrix is not empty...
    
    %Compute the s-Domain System Roots.
    ps = z2s(pz, dt);

    %Compute the s-Domain Observer Roots.
    ps_obs = OIF*ps;

    %Compute the maximum observer root.
    pz_obs_max = s2z(min(ps_obs), dt);

    %Define the observer roots.
    pz_obs = linspace2( pz_obs_max, -rt_spacing*pz_obs_max, length(pz) - 1 );

    %Determine whether the system is observable.
    if (size(G.a, 2) - rank(obsv(G.a, G.c))) == 0                  %If the system is observable...
        
        %Design the observer.
        L = place(G.a', G.c', pz_obs)';
        
        %% Compute the SSO CL System.
        
        %Compute the SSO CL System Matrices.
%         Acl = [G.A, G.B*K(end), -G.B*K(1:end-1);
%                   -G.C*G.A, 1 - G.C*G.B*K(end), G.C*G.B*K(1:end-1);
%                   L*G.C, G.B*K(end), G.A - L*G.C - G.B*K(1:end-1)];
%         Bcl = [zeros(size(G.A, 1), 1); 1; zeros(size(G.A, 1), 1)];
%         Ccl = [G.C, 0, zeros(1, size(G.A, 1))];
%         Dcl = 0;
        Acl = [G.A, G.B*K(end), -G.B*K(1:end-1);
                  -G.C*G.A, 1 - G.C*G.B*K(end), G.C*G.B*K(1:end-1);
                  L*G.C, G.B*K(end), G.A - L*G.C - G.B*K(1:end-1)];
        Bcl = [zeros(size(G.B)); ones(1, size(G.B, 2)); zeros(size(G.B))];
        Ccl = [G.C, zeros(size(G.C, 1), 1), zeros(size(G.C))];
        Dcl = G.D;

        
        %Define the SSO CL System.
        Gcl = ss( Acl, Bcl, Ccl, Dcl, dt );
        
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

