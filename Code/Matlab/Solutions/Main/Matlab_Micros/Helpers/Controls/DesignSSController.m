function [ Gs, Ks, Ls ] = DesignSSController( G, ps, OIF, rt_spacing )
%% Function Description.

%INPUTS:
    %G = Process Transfer Function.
    %ps = Desired roots of closed loop system.
    %OIF = Observer Improvement Factor.
    %rt_spacing = Spacing of the Observer roots.
    
%OUTPUTS:
    %Gs = Cell array of CL SS models.
    %Ks = Cell array of SS gain matrices.
    %Ls = Cell array of Observer gain matrices.

%CELL ARRAY COMPONENTS:
    %1: State Space Controller.
    %2: State Space Controller with Observer.
    %3: State Space Controller with Outer Loop Integrator.
    %4: State Space Controller with Outer Loop Integrator and Observer.
    
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

%% Design the Controllers.

%Design a state space controller.
[ G1, K1 ] = GetSSController( G, ps(1:end-1) );

%Design a state space controller with an observer.
[ G2, K2, L2 ] = GetSSOController( G, ps(1:end-1), OIF, rt_spacing );

%Design a state space controller with an outer loop integrator.
[ G3, K3 ] = GetSSIController( G, ps );

%Design a state space controller with an outer loop integrator and an observer.
[ G4, K4, L4 ] = GetSSIOController( G, ps, OIF, rt_spacing );

%% Store the CL Models, SS Gain Matrices, and Observer Matrices.

%Define the CL SS controllers.
Gs = {G1, G2, G3, G4};

%Define the SS Gain Matrices.
Ks = {K1, K2, K3, K4};

%Define the Observer Gain Matrices.
Ls = {'', L2, '', L4};

end

