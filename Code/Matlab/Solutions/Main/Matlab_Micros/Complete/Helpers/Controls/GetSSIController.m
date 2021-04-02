function [ Gcl, K ] = GetSSIController( G, ps )
%% Validate the User Inputs.

%Throw an error if G is not a transfer function or state space model.
if (~isa(G, 'tf')) && (~isa(G, 'ss'))
    error('G must be a transfer function or state space model.')
end

%Convert G to a state space model.
if isa(G, 'tf'), G = ss(G); end

%% Compute the SSI Gain Matrix.

%Define the integrator system matrices.
Ai = [G.a, zeros(size(G.a, 1), 1); -G.c, 0];
Bi = [G.b; 0];

%Determine whether the system is controllable.
if (size(Ai, 2) - rank(ctrb(Ai, Bi))) == 0                  %If the system is controllable...
    
    %Design a state space controller with an outer loop integrator.
    K = place(Ai, Bi, ps);
    
    %Correct the sign of the integrator gain.
    K(end) = -K(end);
    
    %% Compute the Closed Loop System SS Model.
    
    %Compute the SSI CL System matrices.
%     Acl = [G.a - G.b*K(1:end-1), G.b*K(end); -G.c, 0];
%     Bcl = [zeros(size(G.b, 1), 1); 1];
%     Ccl = [G.c 0];
%     Dcl = G.d;
    Acl = [G.a - G.b*K(1:end-1), G.b*K(end); -G.c, 0];
    Bcl = [zeros(size(G.b)); ones(1, size(G.b, 2)) ];
    Ccl = [G.c zeros(size(G.c, 1))];
    Dcl = G.d;    

    %Compute the SS CL System
    Gcl = ss(Acl, Bcl, Ccl, Dcl);
    
else
    
    %Throw a warning that some of the states are not controllable.
    warning('SSI Controller: At least one state is uncontrollable.')
    
    %Set the function outputs to be empty.
    Gcl = ''; K = [];
    
end

end

