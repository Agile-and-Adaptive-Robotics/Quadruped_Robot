%% Relative Inversion Subnetwork Derivation

% Clear Everything.
clear, close( 'all' ), clc


%% Setup the Relative Inversion Subnetwork Constraints

% Define the symbolic variables.
syms U1 U2 c1 c2 c3 R1 R2 delta gs21 dEs21 Ia2 Gm2

% assume( [ U1 U2 c1 c2 c3 R1 R2 delta gs21 dEs21 Ia2 Gm2 ], 'real' )
% assume( [ R1, R2, delta, gs21, Gm2 ], 'positive' )

% Define the points of interest.
P1 = [ 0; R2 ];
P2 = [ R1; delta ];

% Define the desired formulation.
eq1 = U2 == ( c1*R1*R2 )/( c2*U1 + c3*R1 );

% Define the achieved formulation.
eq2 = U2 == ( gs21*dEs21*U1 + R1*Ia2 )/( gs21*U1 + R1*Gm2 );


%% Derive Desired Relative Inversion Constraints.

% Define the point 1 desired constraint.
dc1 = subs( eq1, [ U1 U2 ], [ P1( 1 ), P1( 2 ) ] );

% Solve the point 1 desired constraint for c1.
dc1_sol = solve( dc1, c1, 'ReturnConditions', true );

% Define the point 2 desired constraint.
dc2 = subs( eq1, [ U1 U2 ], [ P2( 1 ), P2( 2 ) ] );

% Solve the point 2 desired constraint.
dc2_sol = solve( dc2, c2, 'ReturnConditions', true );


%% Derive Achieved Relative Inversion Constraints.

% Define the point 1 achieved constraint.
ac1 = subs( eq2, [ U1 U2 ], [ P1( 1 ), P1( 2 ) ] );

% Solve the point 1 achieved constraint.
ac1_sol = solve( ac1, Ia2, 'ReturnConditions', true );

% Define the point 2 achieved constraint.
ac2 = subs( eq2, [ U1 U2 ], [ P2( 1 ), P2( 2 ) ] );

% Solve the point 2 achieved constraint.
ac2_sol = solve( ac2, gs21, 'ReturnConditions', true );


%% Derive Similarity Constraints.

% Substitute known quantities into equations.
c1 = dc1_sol.c1;
c2 = dc2_sol.c2;
Ia2 = ac1_sol.Ia2;
gs21 = simplify( subs( ac2_sol.gs21, 'Ia2', Ia2 ) );

% Retrieve the components of the constraints.
[ eq1_num, eq1_den ] = numden( rhs( eq1 ) );
[ eq2_num, eq2_den ] = numden( rhs( eq2 ) );

% Define the general similarity equation.
sc = eq2_num*eq1_den - eq1_num*eq2_den;

% Define the similarity equation coefficients.
sc_coeffs  = coeffs( collect( sc, U1 ), U1 );

% Define the three similarity constraint equations.
sc1 = sc_coeffs( 1 ) == 0;
sc2 = sc_coeffs( 2 ) == 0;
sc3 = sc_coeffs( 3 ) == 0;

% Substitute known values into the similarity constain equations.
sc1_sub = subs( sc1, { 'c1', 'c2', 'Ia2', 'gs21' }, [ c1, c2, Ia2, gs21 ] );
sc2_sub = simplify( subs( sc2, { 'c1', 'c2', 'Ia2', 'gs21' }, [ c1, c2, Ia2, gs21 ] ) );
sc3_sub = simplify( subs( sc3, { 'c1', 'c2', 'Ia2', 'gs21' }, [ c1, c2, Ia2, gs21 ] ) );




