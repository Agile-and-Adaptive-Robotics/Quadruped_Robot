%% Reduced Absolute Inversion Subnetwork Derivation

% Clear Everything.
clear, close( 'all' ), clc


%% Setup the Reduced Absolute Inversion Subnetwork Constraints

% Define the symbolic variables.
syms x1 x2 U1 U2 real
syms c1 c2 x1max x2max delta real positive
syms R1 R2 Gm1 Gm2 real positive
syms gs21 real positive
syms dEs21 real
syms Ia2 real positive

% Create additional symbolic assumptions.
assume( dEs21 >= 0 );

% Define the encoded state variables.
U1 = x1;
U2 = x2;

% Define the maximum encoded states.
R1 = x1max;
R2 = x2max;

% Define the decoded desired mapping.
eq_desired = x2 == c1/( x1 + c2 );

% Define the decoded achieved mapping.
eq_achieved = U2 == ( gs21*dEs21*U1 + R1*Ia2 )/( gs21*U1 + R1*Gm2 );

% Define the points of interest.
P1 = [ 0; x2max ];
P2 = [ x1max; delta ];


%% Derive Desired Absolute Inversion Constraints.

% Create the desired constraints.
eq_desired1 = subs( eq_desired, [ x1, x2 ], [ P1( 1 ), P1( 2 ) ] );
eq_desired2 = subs( eq_desired, [ x1, x2 ], [ P2( 1 ), P2( 2 ) ] );

% Solve the first desired constraint for x2max.
sol_x2max = solve( eq_desired1, x2max, 'ReturnConditions', true );
x2max = simplify( sol_x2max.x2max );

% Solve the second desired constraint for c2.
sol_c2 = solve( eq_desired2, c2, 'ReturnConditions', true );
c2 = simplify( sol_c2.c2 );

% Substitute c2 into x2max.
x2max = subs( x2max, 'c2', c2 );
x2max = simplify( x2max );


%% Derive Achieved Absolute Inversion Constraints.

% Substitute the x2max constraint into the first decoded target point.
P1 = subs( P1, 'x2max', x2max );

% Create the achieved constraints.
eq_achieved1 = subs( eq_achieved, [ x1, x2 ], [ P1( 1 ), P1( 2 ) ] );
eq_achieved2 = subs( eq_achieved, [ x1, x2 ], [ P2( 1 ), P2( 2 ) ] );

% Solve the first achieved constraint for Ia2.
sol_Ia2 = solve( eq_achieved1, Ia2, 'ReturnConditions', true );
Ia2 = simplify( sol_Ia2.Ia2 );

% Solve the second achieved constraint for gs21.
eq_achieved2 = subs( eq_achieved2, 'Ia2', Ia2 );
sol_gs21 = solve( eq_achieved2, gs21, 'ReturnConditions', true );
gs21 = simplify( sol_gs21.gs21 );


%% Derive Similarity Constraints.

% Update the encoded desired and achieved mappings.
eq_desired = subs( eq_desired, { 'x2max', 'c2', 'Ia2', 'gs21' }, [ x2max, c2, Ia2, gs21 ] );
eq_achieved = subs( eq_achieved, { 'x2max', 'c2', 'Ia2', 'gs21' }, [ x2max, c2, Ia2, gs21 ] );

% Define the similarity constraints.
[ num_desired, den_desired ] = numden( rhs( eq_desired ) );
[ num_achieved, den_achieved ] = numden( rhs( eq_achieved ) );
eq_similarity = num_desired*den_achieved - num_achieved*den_desired == 0;
eq_similarity = collect( eq_similarity, [ x1, x2 ] );
[ similarity_coeffs, similarity_terms ] = coeffs( lhs( eq_similarity ), [ x1, x2 ] );
similarity_coeffs = simplify( similarity_coeffs );

