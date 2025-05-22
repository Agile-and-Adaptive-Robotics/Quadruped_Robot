%% Reduced Relative Division After Inversion Subnetwork Derivation

% Clear Everything.
clear, close( 'all' ), clc


%% Setup the Reduced Relative Division After Inversion Subnetwork Constraints

% Define the symbolic variables.
syms x1 x2 x3 U1 U2 U3 real
syms c1 c2 x1max x2max x3max delta1 delta2 real positive
syms R1 R2 R3 Gm1 Gm2 Gm3 real positive
syms gs31 gs32 real positive
syms dEs31 dEs32 real
syms Ia3 real

% Create additional symbolic assumptions.
assume( [ dEs31, dEs32, Ia3 ] >= 0 );

% Define the encoded state variables.
U1 = ( R1/x1max )*x1;
U2 = ( R2/x2max )*x2;
U3 = ( R3/x3max )*x3;

% Define the decoded desired mapping.
eq_desired = x3 == ( c1*x1 )/( x2 + c2 );

% Define the decoded achieved mapping.
eq_achieved = U3 == ( R2*gs31*dEs31*U1 + R1*gs32*dEs32*U2 + R1*R2*Ia3 )/( R2*gs31*U1 + R1*gs32*U2 + R1*R2*Gm3 );

% Define the points of interest.
P1 = [ 0; x2max; 0 ];
P2 = [ x1max; delta1; x3max ];
P3 = [ 0; delta1; 0 ];
P4 = [ x1max; x2max; delta2 ];


%% Derive Desired Reduced Relative Division After Inversion Constraints.

% Create the desired constraints.
eq_desired1 = subs( eq_desired, [ x1, x2, x3 ], [ P1( 1 ), P1( 2 ), P1( 3 ) ] );
eq_desired2 = subs( eq_desired, [ x1, x2, x3 ], [ P2( 1 ), P2( 2 ), P2( 3 ) ] );
eq_desired3 = subs( eq_desired, [ x1, x2, x3 ], [ P3( 1 ), P3( 2 ), P3( 3 ) ] );
eq_desired4 = subs( eq_desired, [ x1, x2, x3 ], [ P4( 1 ), P4( 2 ), P4( 3 ) ] );

% Solve the fourth desired constraint for c2.
sol_c2 = solve( eq_desired4, c2, 'ReturnConditions', true );
c2 = simplify( sol_c2.c2 );

% Solve the second desired constraint for x3max.
eq_desired2 = subs( eq_desired2, 'c2', c2 );
sol_x3max = solve( eq_desired2, x3max, 'ReturnConditions', true );
x3max = simplify( sol_x3max.x3max );


%% Derive Achieved Reduced Relative Division After Inversion Constraints.

% Substitute the x3max constraint into the second decoded target point.
P2 = subs( P2, 'x3max', x3max );
R3 = subs( R3, 'x3max', x3max );
eq_achieved = subs( eq_achieved, 'x3max', x3max );

% Create the achieved constraints.
eq_achieved1 = subs( eq_achieved, [ x1, x2, x3 ], [ P1( 1 ), P1( 2 ), P1( 3 ) ] );
eq_achieved2 = subs( eq_achieved, [ x1, x2, x3 ], [ P2( 1 ), P2( 2 ), P2( 3 ) ] );
eq_achieved3 = subs( eq_achieved, [ x1, x2, x3 ], [ P3( 1 ), P3( 2 ), P3( 3 ) ] );
eq_achieved4 = subs( eq_achieved, [ x1, x2, x3 ], [ P4( 1 ), P4( 2 ), P4( 3 ) ] );

% Solve the first and third constraints for Ia3 and dEs32.
sol = solve( [ eq_achieved1, eq_achieved3 ], { 'Ia3', 'dEs32' }, 'ReturnConditions', true );
Ia3 = simplify( sol.Ia3 );
dEs32 = simplify( sol.dEs32 );

% Solve the second and fourth constraints for gs31 and gs32.
eq_achieved2 = subs( eq_achieved2, { 'Ia3', 'dEs32' }, [ Ia3, dEs32 ] );
eq_achieved4 = subs( eq_achieved4, { 'Ia3', 'dEs32', 'gs31' }, [ Ia3, dEs32, gs31 ] );
sol = solve( [ eq_achieved2, eq_achieved4 ], { 'gs31', 'gs32' }, 'ReturnConditions', true );
gs31 = simplify( sol.gs31( 2 ) );
gs32 = simplify( sol.gs32( 2 ) );

% dEs31 = ( delta1*delta2*R3 + c1*R3*x1max )/( c1*x1max );
% 
% gs31 = simplify( subs( gs31, 'dEs31', dEs31 ) );
% gs32 = simplify( subs( gs32, 'dEs31', dEs31 ) );


%% Derive Similarity Constraints.

% Update the encoded desired and achieved mappings.
eq_desired = simplify( subs( eq_desired, { 'x3max', 'c2', 'Ia3', 'dEs32', 'gs31', 'gs32' }, [ x3max, c2, Ia3, dEs32, gs31, gs32 ] ) );
eq_achieved = simplify( subs( eq_achieved, { 'x3max', 'c2', 'Ia3', 'dEs32', 'gs31', 'gs32' }, [ x3max, c2, Ia3, dEs32, gs31, gs32 ] ) );

% Reorganize the achieved mapping.
sol_x3 = solve( eq_desired, x3, 'ReturnConditions', true );
eq_desired = x3 == sol_x3.x3;

sol_x3 = solve( eq_achieved, x3, 'ReturnConditions', true );
eq_achieved = x3 == sol_x3.x3;

% Define the similarity constraints.
[ num_desired, den_desired ] = numden( rhs( eq_desired ) );
[ num_achieved, den_achieved ] = numden( rhs( eq_achieved ) );
eq_similarity = num_desired*den_achieved - num_achieved*den_desired == 0;
eq_similarity = collect( eq_similarity, [ x1, x2, x3 ] );
[ similarity_coeffs, similarity_terms ] = coeffs( lhs( eq_similarity ), [ x1, x2, x3 ] );
similarity_coeffs = simplify( similarity_coeffs );

