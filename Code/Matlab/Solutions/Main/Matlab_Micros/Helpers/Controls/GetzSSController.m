function [ Gcl, K ] = GetzSSController( G, ps )
%% Validate the User Inputs.

%Throw an error if G is not a transfer function or state space model.
if (~isa(G, 'tf')) && (~isa(G, 'ss'))
    error('G must be a transfer function or state space model.')
end

%Convert G to a state space model.
if isa(G, 'tf'), G = ss(G); end

%% Compute the SS Gain Matrix.

%Retrieve the sampling time from the digital state space model.
[~, ~, dt] = tfdata(G);

%Determine whether the system is controllable.
if (size(G.a, 2) - rank(ctrb(G.a, G.b))) == 0                  %If the system is controllable...
    
    %Design the original state space controller.
    K = place(G.a, G.b, ps);
    
    %% Compute the Closed Loop System SS Model.
    
    %Compute the Digital, State Space, CL System Matrix.
    Acl = G.a - G.b*K;
    
    %Compute the Digital, State Space, CLTF.
    Gcl = ss(Acl, G.b, G.c, G.d, dt);
    
else
    
    %Throw a warning that some of the states are not controllable.
    warning('SS Controller: At least one state is uncontrollable.')
    
    %Set the function outputs to be empty.
     Gcl = ''; K = [];
    
end

end

