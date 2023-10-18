%% Relative Division Subnetwork Derivation

% Clear Everything.
clear, close( 'all' ), clc


%% Setup the Relative Inversion Subnetwork Constraints

% Define the symbolic variables.
syms U1 U2 U3 c1 c2 c3 R1 R2 R3 delta gs31 gs32 dEs31 dEs32 Ia3 Gm3

% assume( [ U1 U2 U3 c1 c2 c3 R1 R2 R3 delta gs31 gs32 dEs31 dEs32 Ia3 Gm3 ], 'real' )
% assume( [ U1 U2 U3 c1 c2 c3 R1 R2 R3 delta gs31 gs32 Gm3 ], 'positive' )

% Define the points of interest.
P1 = [ R1; 0; R3 ];
P2 = [ 0; R2; 0 ];
P3 = [ R1; R2; delta ];
P4 = [ 0; 0; 0 ];

% Define the desired formulation.
deq = U3 == ( c1*R2*R3*U1 )/( c2*R1*U2 + R1*R2*c3 );

% Define the achieved formulation.
aeq = U3 == ( R2*gs31*dEs31*U1 + R1*gs32*dEs32*U2 + R1*R2*Ia3 )/( R2*gs31*U1 + R1*gs32*U2 + R1*R2*Gm3 );


%% Derive Desired Relative Inversion Constraints.

% Define the desired formulation constraints.
dc1 = subs( deq, [ U1, U2, U3 ], [ P1( 1 ), P1( 2 ), P1( 3 ) ] );
dc2 = subs( deq, [ U1, U2, U3 ], [ P2( 1 ), P2( 2 ), P2( 3 ) ] );
dc3 = subs( deq, [ U1, U2, U3 ], [ P3( 1 ), P3( 2 ), P3( 3 ) ] );
dc4 = subs( deq, [ U1, U2, U3 ], [ P4( 1 ), P4( 2 ), P4( 3 ) ] );

% Solve the desired formulation constraints.
% dc1_sol = solve( dc1, R2, 'ReturnConditions', true );
% dc3_sol = solve( dc3, c2, 'ReturnConditions', true );
% dc1_sol = solve( dc1, R3 );
% dc3_sol = solve( dc3, c2 );

dc_sol = solve( [ dc1, dc2, dc3, dc4 ], [ c1, c2 ] );

% Retrieve the desired formulation solution results.
c1 = dc_sol.c1;
c2 = dc_sol.c2;


%% Derive Achieved Relative Inversion Constraints.

% Define the achieved formulation constraints.
ac1 = subs( aeq, [ U1, U2, U3 ], [ P1( 1 ), P1( 2 ), P1( 3 ) ] );
ac2 = subs( aeq, [ U1, U2, U3 ], [ P2( 1 ), P2( 2 ), P2( 3 ) ] );
ac3 = subs( aeq, [ U1, U2, U3 ], [ P3( 1 ), P3( 2 ), P3( 3 ) ] );
ac4 = subs( aeq, [ U1, U2, U3 ], [ P4( 1 ), P4( 2 ), P4( 3 ) ] );

% Solve the achieved formulation constraints.
% sol = solve( [ ac1, ac2, ac3, ac4 ], [ dEs32, Ia3, gs31, gs32 ], 'ReturnConditions', true );
ac_sol = solve( [ ac1, ac2, ac3, ac4 ], [ dEs32, Ia3, gs31, gs32 ] );

% Retrieve the achieved formulation solution results.
dEs32 = ac_sol.dEs32;
Ia3 = ac_sol.Ia3;
gs31 = ac_sol.gs31;
gs32 = ac_sol.gs32;


%% Derive Similarity Constraints

% Retrieve the components of the constraints.
[ deq_num, deq_den ] = numden( rhs( deq ) );
[ aeq_num, aeq_den ] = numden( rhs( aeq ) );

% Define the general similarity equation.
sc = aeq_num*deq_den - deq_num*aeq_den;

% Define the similarity equation coefficients.
sc_coeffs  = coeffs( collect( sc, [ U1, U2 ] ), [ U1, U2 ] );

% Define the similarity constraint equations.
sc1 = sc_coeffs( 1 ) == 0;
sc2 = sc_coeffs( 2 ) == 0;
sc3 = sc_coeffs( 3 ) == 0;
sc4 = sc_coeffs( 4 ) == 0;
sc5 = sc_coeffs( 5 ) == 0;
sc6 = sc_coeffs( 6 ) == 0;

% Substitute known values into the similarity constraint equations.
sc1 = subs( sc1, { 'R3', 'c2', 'dEs32', 'Ia3', 'gs31', 'gs32' }, [ R3, c2, dEs32, Ia3, gs31, gs32 ] );
sc2 = subs( sc2, { 'R3', 'c2', 'dEs32', 'Ia3', 'gs31', 'gs32' }, [ R3, c2, dEs32, Ia3, gs31, gs32 ] );
sc3 = subs( sc3, { 'R3', 'c2', 'dEs32', 'Ia3', 'gs31', 'gs32' }, [ R3, c2, dEs32, Ia3, gs31, gs32 ] );
sc4 = subs( sc4, { 'R3', 'c2', 'dEs32', 'Ia3', 'gs31', 'gs32' }, [ R3, c2, dEs32, Ia3, gs31, gs32 ] );
sc5 = subs( sc5, { 'R3', 'c2', 'dEs32', 'Ia3', 'gs31', 'gs32' }, [ R3, c2, dEs32, Ia3, gs31, gs32 ] );
sc6 = subs( sc6, { 'R3', 'c2', 'dEs32', 'Ia3', 'gs31', 'gs32' }, [ R3, c2, dEs32, Ia3, gs31, gs32 ] );

% Simplify the constraint equations.
sc4 = simplify( sc4 );
sc5 = simplify( sc5 );
sc6 = simplify( sc6 );


