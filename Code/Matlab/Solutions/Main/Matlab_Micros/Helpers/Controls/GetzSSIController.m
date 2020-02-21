function [ Gcl, K ] = GetzSSIController( G, ps )
%% Validate the User Inputs.

%Throw an error if G is not a transfer function or state space model.
if (~isa(G, 'tf')) && (~isa(G, 'ss'))
    error('G must be a transfer function or state space model.')
end

%Convert G to a state space model.
if isa(G, 'tf'), G = ss(G); end

%% Compute the SSI Gain Matrix.

%Retrieve the sampling time from the digital state space model.
[~, ~, dt] = tfdata(G);

%Define the integrator system matrices.
Ai = [G.A, zeros(size(G.A, 1), 1); -G.C*G.A, 1];
Bi = [G.B; -G.C*G.B];
% Ai = [G.A, zeros(size(G.A, 1), size(G.C, 1)); -G.C*G.A, eye(size(G.C, 1), size(G.A, 2))];
% Bi = [G.B; -G.C*G.B];

%Determine whether the system is controllable.
if (size(Ai, 2) - rank(ctrb(Ai, Bi))) == 0                  %If the system is controllable...
    
    %Design a state space controller with an outer loop integrator.
    K = place(Ai, Bi, ps);
    
    %Correct the sign of the integrator gain.
    K(end) = -K(end);
    
    %% Compute the Closed Loop System SS Model.
    
    %Compute the SSI CL System matrices.
    %     Acl = [G.A - G.B*K(1:end-1), G.B*K(end); G.C*(G.B*K(1:end-1) - G.A), 1 - G.C*G.B*K(end)];
    %     Bcl = [zeros(size(G.A, 1), 1); 1];
    %     Ccl = [G.C 0];
    %     Dcl = 0;
    Acl = [G.A - G.B*K(1:end-1), G.B*K(end); G.C*(G.B*K(1:end-1) - G.A), 1 - G.C*G.B*K(end)];
    Bcl = [zeros(size(G.A, 1), 1); ones(1, size(G.B, 2))];
    Ccl = [G.C zeros(size(G.C, 1))];
    Dcl = G.D; 
    
    %Compute the SS CL System
    Gcl = ss(Acl, Bcl, Ccl, Dcl, dt);
    
else
    
    %Throw a warning that some of the states are not controllable.
    warning('SSI Controller: At least one state is uncontrollable.')
    
    %Set the function outputs to be empty.
    Gcl = ''; K = [];
    
end

end

