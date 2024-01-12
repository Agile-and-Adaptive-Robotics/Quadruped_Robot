%% Absolute Multiplication (Version 5) Functional Subnetwork Design Rule Derivation

% Clear everything.
clear, close( 'all' ), clc


%% Setup the Problem.

% Print out a message that says we are setting up.
fprintf( 'ABSOLUTE MULTIPLICATION: VERSION 5\n' )
fprintf( 'Setting up problem...\n' )

% Define symbolic variables.
syms R1 R2 R3 R4 R5 R6 R7 U1 U2 U3 U4 U5 U6 U7 gs31 gs32 gs41 gs42 gs43 gs51 gs52 gs53 gs54 gs62 gs63 gs74 gs75 gs76 dEs31 dEs32 dEs41 dEs42 dEs43 dEs51 dEs52 dEs53 dEs54 dEs62 dEs63 dEs74 dEs75 dEs76 Gm1 Gm2 Gm3 Gm4 Gm5 Gm6 Gm7 Ia1 Ia2 Ia3 Ia4 Ia5 Ia6 Ia7 k1 k2 delta

% Set the variable assumptions.
assume( [ R1, R2, R3, R4, R5, R6, R7, U1, U2, U3, U4, U5, U6, U7, gs31, gs32, gs41, gs42, gs43 gs51 gs52 gs53 gs54 gs62 gs63 gs74 gs75 gs76 dEs31 dEs32 dEs41 dEs42 dEs43 dEs51 dEs52 dEs53 dEs54 dEs62 dEs63 dEs74 dEs75 dEs76 Gm1 Gm2 Gm3 Gm4 Gm5 Gm6 Gm7 Ia1 Ia2 Ia3 Ia4 Ia5 Ia6 Ia7 k1 k2 delta ], 'real' ) 
assume( [ R1, R2, R3, R4, R5, R6, R7 ], 'positive' ) 
assume( [ Gm1, Gm2, Gm3, Gm4, Gm5, Gm6, Gm7 ], 'positive' ) 
assume( [ gs31 gs32 gs41 gs42 gs43 gs51 gs52 gs53 gs54 gs62 gs63 gs74 gs75 gs76 ], 'positive' ) 
assume( [ k1, k2, delta ], 'positive' )
assume( [ Ia1 >= 0, Ia2 >= 0, Ia3 >= 0, Ia4 >= 0, Ia5 >= 0, Ia6 >= 0, Ia7 >= 0 ] )
assume( [ U1 >= 0, U2 >= 0, U3 >= 0, U4 >= 0, U5 >= 0, U6 >= 0, U7 >= 0 ] )

% Define the points of interest.
P1 = [ R1; 0; 0 ];
P2 = [ 0; R2; 0 ];
P3 = [ R1; R2; R4 ];
P4 = [ 0; 0; 0 ];

% Print out a message that says we are done setting up.
fprintf( 'Setting up problem... Done.\n' )
fprintf( '\n' )


%% Desired Formulation Constraints.

% Print out a message that says we are deriving desired formulation constraints.
fprintf( 'Deriving desired formulation constraints...\n' )
fprintf( '\n' )

% Define the desired formulation.
U5_desired = k1*U1*U2;

% Define the desired formulation constraints.
eq1_desired = P1( 3 ) == subs( U5_desired, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] );
eq2_desired = P2( 3 ) == subs( U5_desired, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] );
eq3_desired = P3( 3 ) == subs( U5_desired, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] );
eq4_desired = P4( 3 ) == subs( U5_desired, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] );

% Print out the desired constraints.
fprintf( 'D1: ' ), pretty( eq1_desired )
fprintf( 'D2: ' ), pretty( eq2_desired )
fprintf( 'D3: ' ), pretty( eq3_desired )
fprintf( 'D4: ' ), pretty( eq4_desired )

% Print out a message that says we are done deriving desired formulation constraints.
fprintf( 'Deriving desired formulation constraints... Done.\n' )
fprintf( '\n' )


%% Achieved Formulation Constraints.

% Print out a message that says we are deriving achieved formulation constraints.
fprintf( 'Deriving achieved formulation constraints...\n' )
fprintf( '\n' )

% Define the steady state behavior of neuron three.
U3 = ( gs31*dEs31*U1 + R1*Ia3 )/( gs31*U1 + R1*Gm3 );
U4 = ( gs42*dEs42*U2 + R2*Ia4 )/( gs42*U2 + R2*Gm4 );

% Define the steady state behavior of neuron fifth.
U5_achieved = ( R2*R3*R4*gs51*dEs51*U1 + R1*R3*R4*gs52*dEs52*U2 + R1*R2*R4*gs53*dEs53*U3 + R1*R2*R3*gs54*dEs54*U4 + R1*R2*R3*R4*Ia5 )/( R2*R3*R4*gs51*U1 + R1*R3*R4*gs52*U2 + R1*R2*R4*gs53*U3 + R1*R2*R3*gs54*U4 + R1*R2*R3*R4*Gm5 );

% Collect the relevant terms of the fifth neuron's steady state behavior.
U5_achieved = collect( U5_achieved, [ U1, U2 ] );

% Retrieve the numerator and denominator of the fifth neuron's steady state behavior.
[ U5_achieved_num, U5_achieved_den ] = numden( U5_achieved );

% Retrieve the coefficients associated with the numerator and denominator of the fifth neuron's steady state behavior.
[ U5_achieved_num_coeffs, U5_achieved_num_terms ] = coeffs( U5_achieved_num, [ U1, U2 ] ); U5_achieved_num_coeffs = simplify( U5_achieved_num_coeffs );
[ U5_achieved_den_coeffs, U5_achieved_den_terms ] = coeffs( U5_achieved_den, [ U1, U2 ] ); U5_achieved_den_coeffs = simplify( U5_achieved_den_coeffs );

% % Define the achieved formulation constraints.
% eq1_achieved = P1( 3 ) == subs( U4_achieved, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] );
% eq2_achieved = P2( 3 ) == subs( U4_achieved, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] );
% eq3_achieved = P3( 3 ) == subs( U4_achieved, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] );
% eq4_achieved = P4( 3 ) == subs( U4_achieved, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] );

% Define the achieved formulation constraints.
eq1_achieved = P1( 3 )*subs( U5_achieved_den, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] ) - subs( U5_achieved_num, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] ) == 0;
eq2_achieved = P2( 3 )*subs( U5_achieved_den, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] ) - subs( U5_achieved_num, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] ) == 0;
eq3_achieved = P3( 3 )*subs( U5_achieved_den, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] ) - subs( U5_achieved_num, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] ) == 0;
eq4_achieved = P4( 3 )*subs( U5_achieved_den, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] ) - subs( U5_achieved_num, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] ) == 0;

% % Simplify the achieved formulation constraints.
% eq1_achieved = collect( simplify( eq1_achieved ), [ gs32, gs41, gs43 ] );
% eq2_achieved = collect( simplify( eq2_achieved ), [ gs32, gs41, gs43 ] );
% eq3_achieved = collect( simplify( eq3_achieved ), [ gs32, gs41, gs43 ] );
% eq4_achieved = collect( simplify( eq4_achieved ), [ gs32, gs41, gs43 ] );

% % Simplify the achieved formulation constraints.
% eq1_achieved = collect( eq1_achieved, [ gs32, gs41, gs43 ] );
% eq2_achieved = collect( eq2_achieved, [ gs32, gs41, gs43 ] );
% eq3_achieved = collect( eq3_achieved, [ gs32, gs41, gs43 ] );
% eq4_achieved = collect( eq4_achieved, [ gs32, gs41, gs43 ] );

% Simplify the achieved formulation constraints.
eq1_achieved = collect( eq1_achieved, [ dEs31, dEs42, dEs53, dEs54, Ia3, Ia4, Ia5 ] );
eq2_achieved = collect( eq2_achieved, [ dEs31, dEs42, dEs53, dEs54, Ia3, Ia4, Ia5 ] );
eq3_achieved = collect( eq3_achieved, [ dEs31, dEs42, dEs53, dEs54, Ia3, Ia4, Ia5 ] );
eq4_achieved = collect( eq4_achieved, [ dEs31, dEs42, dEs53, dEs54, Ia3, Ia4, Ia5 ] );

% Print out the desired constraints.
fprintf( 'A1: ' ), pretty( eq1_achieved )
fprintf( 'A2: ' ), pretty( eq2_achieved )
fprintf( 'A3: ' ), pretty( eq3_achieved )
fprintf( 'A4: ' ), pretty( eq4_achieved )

% Print out a message that says we are done deriving achieved formulation constraints.
fprintf( 'Deriving achieved formulation constraints... Done.\n' )
fprintf( '\n' )


%% Similarity Constraints.

% Print out a message that says we are deriving similarity constraints.
fprintf( 'Deriving similarity constraints...\n' )
fprintf( '\n' )

% Set the desired and achieved formulations equal to one another.
eq_similarity = U5_desired*U5_achieved_den - U5_achieved_num;

% Collect the U1 and U2 terms.
eq_similarity = collect( eq_similarity, [ U1, U2 ] );

% Retrieve the coefficients.
[ eq_similarity_coeffs, eq_similarity_terms ] = coeffs( eq_similarity, [ U1, U2 ] ); eq_similarity_coeffs = simplify( eq_similarity_coeffs );

% Define the similarity constraints.
eq1_similarity = eq_similarity_coeffs( 1 ) == 0;
eq2_similarity = eq_similarity_coeffs( 2 ) == 0;
eq3_similarity = eq_similarity_coeffs( 3 ) == 0;
eq4_similarity = eq_similarity_coeffs( 4 ) == 0;
eq5_similarity = eq_similarity_coeffs( 5 ) == 0;
eq6_similarity = eq_similarity_coeffs( 6 ) == 0;
eq7_similarity = eq_similarity_coeffs( 7 ) == 0;
eq8_similarity = eq_similarity_coeffs( 8 ) == 0;

% Print out the similarity constraints.
fprintf( 'S1: ' ), pretty( eq1_similarity )
fprintf( 'S2: ' ), pretty( eq2_similarity )
fprintf( 'S3: ' ), pretty( eq3_similarity )
fprintf( 'S4: ' ), pretty( eq4_similarity )
fprintf( 'S5: ' ), pretty( eq5_similarity )
fprintf( 'S6: ' ), pretty( eq6_similarity )
fprintf( 'S7: ' ), pretty( eq7_similarity )
fprintf( 'S8: ' ), pretty( eq8_similarity )

% Print out a message that says we are done deriving similarity constraints.
fprintf( 'Deriving similarity constraints... Done.\n' )
fprintf( '\n' )

