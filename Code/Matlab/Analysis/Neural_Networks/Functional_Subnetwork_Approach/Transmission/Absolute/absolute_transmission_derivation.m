%% Absolute Transmission Derivation.

% Clear everything.
clear, close( 'all' ), clc


%% Setup Symbolic Variables.

% Create the symbolic variables.
syms x1 x2 U1 U2 real
syms c x1max x2max real positive
syms R1 R2 Gm1 Gm2 real positive
syms gs21 real positive
syms dEs21 real
syms Ia2 real

% Create additional symbolic assumptions.
assume( dEs21 >= 0 );


%% Derive Design Constraints.

% Define the encoded state variables.
U1 = x1;
U2 = x2;

% Define the maximum encoded states.
R1 = x1max;
R2 = x2max;

% Define the decoded desired mapping.
eq_desired = x2 == c*x1;

% Define the decoded achieved mapping.
eq_achieved = U2 == ( gs21*dEs21*U1 + R1*Ia2 )/( gs21*U1 + R1*Gm2 );

% Define the decoded target points.
P1 = [ x1max; x2max ];
P2 = [ 0; 0 ];

% Create the desired constraints.
eq_desired1 = subs( eq_desired, [ x1, x2 ], [ P1( 1 ), P1( 2 ) ] );
eq_desired2 = subs( eq_desired, [ x1, x2 ], [ P2( 1 ), P2( 2 ) ] );

% Solve the first desired constraint equation for x2max.
sol_x2max = solve( eq_desired1, x2max, 'ReturnConditions', true ); x2max = sol_x2max.x2max;

% Substitute the x2max constraint into the first decoded target point.
P1 = subs( P1, 'x2max', x2max );

% Create the achieved constraints.
eq_achieved1 = subs( eq_achieved, [ x1, x2 ], [ P1( 1 ), P1( 2 ) ] );
eq_achieved2 = subs( eq_achieved, [ x1, x2 ], [ P2( 1 ), P2( 2 ) ] );

% Compute Ia2.
sol_Ia2 = solve( eq_achieved2, Ia2, 'ReturnConditions', true );
Ia2 = sol_Ia2.Ia2;

% Compute gs21.
eq_achieved1 = subs( eq_achieved1, 'Ia2', Ia2 );
sol_gs21 = solve( eq_achieved1, gs21, 'ReturnConditions', true );
gs21 = sol_gs21.gs21;

% Update the encoded desired and achieved mappings.
eq_desired = subs( eq_desired, { 'x2max', 'Ia2', 'gs21' }, [ x2max, Ia2, gs21 ] );
eq_achieved = subs( eq_achieved, { 'x2max', 'Ia2', 'gs21' }, [ x2max, Ia2, gs21 ] );

% Define the similarity constraints.
[ num_desired, den_desired ] = numden( rhs( eq_desired ) );
[ num_achieved, den_achieved ] = numden( rhs( eq_achieved ) );
eq_similarity = num_desired*den_achieved - num_achieved*den_desired == 0;
eq_similarity = collect( eq_similarity, [ x1, x2 ] );
[ similarity_coeffs, similarity_terms ] = coeffs( lhs( eq_similarity ), [ x1, x2 ] );

