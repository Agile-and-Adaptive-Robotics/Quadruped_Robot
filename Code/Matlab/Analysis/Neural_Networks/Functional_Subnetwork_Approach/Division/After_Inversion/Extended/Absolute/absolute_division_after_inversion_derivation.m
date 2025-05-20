%% Absolute Division After Inversion Subnetwork Derivation.

% Clear Everything.
clear, close( 'all' ), clc


%% Setup the Absolute Division After Inversion Subnetwork Constraints.

% Define symbolic variables.
syms R1 R2 R3 R3_target Cm1 Cm2 Cm3 Gm1 Gm2 Gm3 gs31 gs32 dEs31 dEs32 Ia3 c1 c2 c3 delta1 delta2 U1 U2

% Define the target points.
P1 = [ R1; delta1; R3 ];
P2 = [ 0; R2; 0 ];
P3 = [ R1; R2; delta2 ];
P4 = [ 0; delta1; 0 ];

% Define the desired reduced absolute division after inversion subnetwork steady state output.
U3d = ( c1*U1 )/( c2*U2 + c3 );

% Define the achieved reduced absolute division after inversion subnetwork steady state output.
U3a = ( R2*gs31*dEs31*U1 + R1*gs32*dEs32*U2 + R1*R2*Ia3 )/( R2*gs31*U1 + R1*gs32*U2 + R1*R2*Gm3 );


%% Compute the Desired Constraints.

% Define the desired constraint equations.
eq1d = P1( 3 ) == subs( U3d, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] );
eq2d = P2( 3 ) == subs( U3d, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] );
eq3d = P3( 3 ) == subs( U3d, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] );
eq4d = P4( 3 ) == subs( U3d, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] );

% Compute the maximum membrane voltage of the output neuron.
R3 = simplify( solve( eq1d, R3 ) );

% Compute the second design constant.
c2 = simplify( solve( eq3d, c2 ) );


%% Compute the Achieved Constraints.

% Define the achieved constraint equations.
eq1a = P1( 3 ) == subs( U3a, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] );
eq2a = P2( 3 ) == subs( U3a, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] );
eq3a = P3( 3 ) == subs( U3a, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] );
eq4a = P4( 3 ) == subs( U3a, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] );

% Compute the applied current (neuron 3) and the synaptic reversal potential (synapse 32).
sol = solve( [ eq2a, eq4a ], [ dEs32, Ia3 ] );

% Retrieve the applied current (neuron 3) and the synaptic reversal potential (synapse 32).
Ia3 = simplify( sol.Ia3 );
dEs32 = simplify( sol.dEs32 );

% Compute the synaptic conductances.
sol = solve( [ eq1a, eq3a ], [ gs31, gs32 ] );

% Retrieve the synaptic conductances.
gs31 = simplify( subs(  sol.gs31, { 'Ia3', 'dEs32' }, [ Ia3, dEs32 ] ) );
gs32 = simplify( subs( sol.gs32, { 'Ia3', 'dEs32' }, [ Ia3, dEs32 ] ) );


%% Determine how to Compute c1 to Achieve a Target R3.

% Define the target R3 equation.
eq = R3_target == subs( R3, 'c2', c2 );

% Solve for the first design constant.
c1 = simplify( solve( eq, c1 ) );

