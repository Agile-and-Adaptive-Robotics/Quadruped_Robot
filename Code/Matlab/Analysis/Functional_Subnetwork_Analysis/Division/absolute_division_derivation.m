%% Absolute Division Subnetwork Design Derivation

% Clear Everything.
clear, close( 'all' ), clc


%% Setup the Problem

% Define the symbolic variables.
syms R1 R2 R3 R4 R5 Gm1 Gm2 Gm3 Gm4 Gm5 gs31 gs53 gs42 gs54 dEs31 dEs53 dEs42 dEs54 Iapp1 Iapp2 Iapp3 Iapp4 Iapp5 c1 c2 c3 c4 c5 c6 c7 c8 U1 U2 U3 U4 U5 V1 V2 V3 V4 V5 k1 k2 k3 k4 k5 k6 k7 k8

assume( [ R1 R2 R3 R4 R5 Gm1 Gm2 Gm3 Gm4 Gm5 ], 'positive' )

% Define the points of interest.
P1 = [ R1; 0; R5 ];
P2 = [ 0; R2; 0 ];
P3 = [ R1; R2; 0 ];
P4 = [ 0; 0; 0 ];


%% Determine the Steady State Neuron Output

% Define the steady state output of the third neuron.
U3 = ( gs31*dEs31*U1 + R1*Iapp3 )./( gs31*U1 + R1*Gm3 );
U4 = ( gs42*dEs42*U2 + R2*Iapp4 )./( gs42*U2 + R2*Gm4 );

% Define the steady state ouput of the fifth neuron.
U_eq = U5 == collect( ( R4*gs53*dEs53*U3 + R3*gs54*dEs54*U4 + R3*R4*Iapp5 )./( R4*gs53*U3 + R3*gs54*U4 + R3*R4*Gm5 ), [ U1, U2 ] );

% Define the U constraints.
U_constraint1 = simplify( subs( U_eq, [ U1; U2; U5 ], P1 ) );
U_constraint2 = simplify( subs( U_eq, [ U1; U2; U5 ], P2 ) );
U_constraint3 = simplify( subs( U_eq, [ U1; U2; U5 ], P3 ) );
U_constraint4 = simplify( subs( U_eq, [ U1; U2; U5 ], P4 ) );

% Solve for the maximum synaptic conductances.
U_sol = solve( [ U_constraint2 U_constraint4 ], [ gs53 gs42 ], 'ReturnConditions', true ); 
% U_sol = solve( [ U_constraint1 U_constraint2 U_constraint3 U_constraint4 ], [ gs31 gs42 gs53 gs54 ], 'ReturnConditions', true ); 


%% Define the Desired Steady State Neuron Output

% Define the desired steady state neuron output.
V_eq = V5 == ( k1*V1*V2 + k2*V1 + k3*V2 + k4 )./( k5*V1*V2 + k6*V1 + k7*V2 + k8 );

% Define the desired steady state neuron output constraints.
V_constraint1 = subs( V_eq, [ V1; V2; V5 ], P1 );
V_constraint2 = subs( V_eq, [ V1; V2; V5 ], P2);
V_constraint3 = subs( V_eq, [ V1; V2; V5 ], P3);
V_constraint4 = subs( V_eq, [ V1; V2; V5 ], P4);

% Solve for k4.
k4_sol = solve( V_constraint4, k4, 'ReturnConditions', true ); 

% Substitute the k4 solution into the other constraints.
V_constraint1 = subs( V_constraint1, k4, k4_sol.k4 );
V_constraint2 = subs( V_constraint2, k4, k4_sol.k4 );
V_constraint3 = subs( V_constraint3, k4, k4_sol.k4 );

% Solve for k3.
k3_sol = solve( V_constraint2, k3, 'ReturnConditions', true );

% Substitute the k3 solution into the other constraints.
V_constraint1 = subs( V_constraint1, k3, k3_sol.k3 );
V_constraint3 = subs( V_constraint3, k3, k3_sol.k3 );

% Solve for R2.
R2_sol = solve( V_constraint3, R2, 'ReturnConditions', true );

% Solve for R5.
R5_sol = solve( V_constraint1, R5, 'ReturnConditions', true );


%


% 


% %% Setup the Problem.
% 
% % Define the symbolic variables.
% syms R1 R2 R3 R4 R5 Gm1 Gm2 Gm3 Gm4 Gm5 gs31 gs53 gs42 gs54 dEs31 dEs53 dEs42 dEs54 Iapp1 Iapp2 Iapp3 Iapp4 Iapp5 c1 c2 c3 c4 c5 c6 c7 c8
% 
% % % Set the variable assumptions.
% % assume( [ R1 R2 R3 R4 R5 Gm1 Gm2 Gm3 Gm4 Gm5 gs31 gs53 gs42 gs54 ] > 0 )
% % assume( [ dEs31 dEs53 dEs42 dEs54 c1 c2 c3 c4 c5 c6 c7 c8 ], 'real' )
% % assume( [ Iapp1 Iapp2 Iapp3 Iapp4 Iapp5 ] >= 0 )
% 
% 
% %% Define the Constraint Equations.
% 
% % % Define the constraint equations.
% % constraint1 = R5 == ( c2*R1 + c4 )./( c6*R1 + c8 );
% % constraint2 = 0 == ( c3*R2 + c4 )./( c7*R2 + c8 );
% % constraint3 = 0 == ( c1*R1*R2 + c2*R1 + c3*R2 + c4 )./( c5*R1*R2 + c6*R1 + c7*R2 + c8 );
% % constraint4 = 0 == c4;
% % 
% % subs( constraint1, constraint4 
% 
% 
% % Define the symbolic coefficients.
% c1 = gs31*gs42*( R4*gs53*dEs53*dEs31 + R3*gs54*dEs54*dEs42 + R3*R4*Iapp5 );
% c2 = R2*gs31*( R4*Gm4*gs53*dEs53*dEs31 + R3*Iapp4*gs54*dEs54 + R3*R4*Gm4*Iapp5 );
% c3 = R1*gs42*( R4*Iapp3*gs53*dEs53 + R3*Gm3*gs54*dEs54*dEs42 + R3*R4*Iapp5*Gm3 );
% c4 = R1*R2*( R4*Gm4*Iapp3*gs53*dEs53 + R3*Gm3*Iapp4*gs54*dEs54 + R3*R4*Gm3*Gm4*Iapp5 );
% c5 = gs31*gs42*( R4*gs53*dEs31 + R3*gs54*dEs42 + R3*R4*Gm5 );
% c6 = R2*gs31*( R4*Gm4*gs53*dEs31 + R3*Iapp4*gs54 + R3*R4*Gm4*Gm5 );
% c7 = R1*gs42*( R4*Iapp3*gs53 + R3*Gm3*gs54*dEs42 + R3*R4*Gm3*Gm5 );
% c8 = R1*R2*( R4*Gm4*Iapp3*gs53 + R3*Gm3*Iapp4*gs54 + R3*R4*Gm3*Gm4*Gm5 );
% 
% % Define the constraint equations.
% eq1 = R5 == ( c2*R1 + c4 )./( c6*R1 + c8 );
% eq2 = 0 == c3*R2 + c4;
% % eq3 = 0 == ( c1*R1*R2 + c2*R1 + c3*R2 + c4 )./( c5*R1*R2 + c6*R1 + c7*R2 + c8 );
% eq3 = 0 == c1*R1*R2 + c2*R1 + c3*R2 + c4;
% eq4 = c4 == 0;
% 
% % Solve for the synaptic conductances.
% sol = solve( [ eq2 eq4 ], [ gs53 gs54 ] );  
% % sol = solve( [ eq1 eq2 eq3 eq4 ], [ gs31 gs42 gs53 gs54 ] );  




