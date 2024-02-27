%% Absolute Multiplication (Version 4a) Functional Subnetwork Design Rule Derivation

% Clear everything.
clear, close( 'all' ), clc


%% Setup the Problem.

% Print out a message that says we are setting up.
fprintf( 'ABSOLUTE MULTIPLICATION: VERSION 4A\n' )
fprintf( 'Setting up problem...\n' )

% Define symbolic variables.
syms R1 R2 R3 R4 R5 R6 R7 U1 U2 U3 U4 U5 U6 U7 gs31 gs32 gs41 gs42 gs43 gs51 gs52 gs53 gs54 gs62 gs63 gs74 gs75 gs76 dEs31 dEs32 dEs41 dEs42 dEs43 dEs51 dEs52 dEs53 dEs54 dEs62 dEs63 dEs74 dEs75 dEs76 Gm1 Gm2 Gm3 Gm4 Gm5 Gm6 Gm7 Ia1 Ia2 Ia3 Ia4 Ia5 Ia6 Ia7 k1 k2 k3 k4 delta

% Set the variable assumptions.
assume( [ R1, R2, R3, R4, R5, R6, R7, U1, U2, U3, U4, U5, U6, U7, gs31, gs32, gs41, gs42, gs43 gs51 gs52 gs53 gs54 gs62 gs63 gs74 gs75 gs76 dEs31 dEs32 dEs41 dEs42 dEs43 dEs51 dEs52 dEs53 dEs54 dEs62 dEs63 dEs74 dEs75 dEs76 Gm1 Gm2 Gm3 Gm4 Gm5 Gm6 Gm7 Ia1 Ia2 Ia3 Ia4 Ia5 Ia6 Ia7 k1 k2 delta ], 'real' ) 
assume( [ R1, R2, R3, R4, R5, R6, R7 ] > 0 ) 
assume( [ Gm1, Gm2, Gm3, Gm4, Gm5, Gm6, Gm7 ] > 0 ) 
assume( [ gs31 gs32 gs41 gs42 gs43 gs51 gs52 gs53 gs54 gs62 gs63 gs74 gs75 gs76 ] > 0 ) 
% assume( [ k1, k2, delta ] > 0 )
assume( [ Ia1, Ia2, Ia3, Ia4, Ia5, Ia6, Ia7 ] >= 0 )
assume( [ U1, U2, U3, U4, U5, U6, U7 ] >= 0 )

% Define the points of interest.
% P1 = [ R1; 0; 0 ];
P1 = [ R1; 0; delta ];
P2 = [ 0; R2; 0 ];
P3 = [ R1; R2; R4 ];
P4 = [ 0; 0; 0 ];
% P5 = [ R1/2; R2/2; ( R1/2 )*( R2/2 ) ];
% P5 = [ R1/3; R2/2; ( R1/3 )*( R2/2 ) ];
% P5 = [ R1/3; 0; 0 ];
% P5 = [ -R1/2; R2/2; -( R1/2 )*( R2/2 ) ];

% Print out a message that says we are done setting up.
fprintf( 'Setting up problem... Done.\n' )
fprintf( '\n' )


%% Desired Formulation Constraints.

% Print out a message that says we are deriving desired formulation constraints.
fprintf( 'Deriving desired formulation constraints...\n' )
fprintf( '\n' )

% Define the desired formulation.
% U4_desired = k1*U1*U2;
U4_desired = k1*U1*U2 + k2*U1;
% U4_desired = ( k1*U1*U2 + k2*U1 )/( k3*U2 + k4 );

% Retrieve the numerator and denominator of the fourth neuron's steady state behavior.
[ U4_desired_num, U4_desired_den ] = numden( U4_desired );

% Retrieve the coefficients associated with the numerator and denominator of the fourth neuron's steady state behavior.
[ U4_desired_num_coeffs, U4_desired_num_terms ] = coeffs( U4_desired_num, [ U1, U2 ] ); U4_desired_num_coeffs = simplify( U4_desired_num_coeffs );
[ U4_desired_den_coeffs, U4_desired_den_terms ] = coeffs( U4_desired_den, [ U1, U2 ] ); U4_desired_den_coeffs = simplify( U4_desired_den_coeffs );

% Define the desired formulation constraints.
eq1_desired = P1( 3 ) == subs( U4_desired, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] );
eq2_desired = P2( 3 ) == subs( U4_desired, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] );
eq3_desired = P3( 3 ) == subs( U4_desired, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] );
eq4_desired = P4( 3 ) == subs( U4_desired, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] );

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
U3 = ( gs32*dEs32*U2 + R2*Ia3 )/( gs32*U2 + R2*Gm3 );

% Define the steady state behavior of neuron four.
U4_achieved = ( R3*gs41*dEs41*U1 + R1*gs43*dEs43*U3 + R1*R3*Ia4 )/( R3*gs41*U1 + R1*gs43*U3 + R1*R3*Gm4 );

% Collect the relevant terms of the fourth neuron's steady state behavior.
U4_achieved = collect( U4_achieved, [ U1, U2 ] );

% Retrieve the numerator and denominator of the fourth neuron's steady state behavior.
[ U4_achieved_num, U4_achieved_den ] = numden( U4_achieved );

% Retrieve the coefficients associated with the numerator and denominator of the fourth neuron's steady state behavior.
[ U4_achieved_num_coeffs, U4_achieved_num_terms ] = coeffs( U4_achieved_num, [ U1, U2 ] ); U4_achieved_num_coeffs = simplify( U4_achieved_num_coeffs );
[ U4_achieved_den_coeffs, U4_achieved_den_terms ] = coeffs( U4_achieved_den, [ U1, U2 ] ); U4_achieved_den_coeffs = simplify( U4_achieved_den_coeffs );

% Define the achieved formulation constraints.
eq1_achieved = P1( 3 )*subs( U4_achieved_den, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] ) - subs( U4_achieved_num, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] ) == 0;
eq2_achieved = P2( 3 )*subs( U4_achieved_den, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] ) - subs( U4_achieved_num, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] ) == 0;
eq3_achieved = P3( 3 )*subs( U4_achieved_den, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] ) - subs( U4_achieved_num, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] ) == 0;
eq4_achieved = P4( 3 )*subs( U4_achieved_den, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] ) - subs( U4_achieved_num, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] ) == 0;

% Simplify the achieved formulation constraints.
eq1_achieved = collect( eq1_achieved, [ dEs32, dEs41, dEs43, Ia3, Ia4 ] );
eq2_achieved = collect( eq2_achieved, [ dEs32, dEs41, dEs43, Ia3, Ia4 ] );
eq3_achieved = collect( eq3_achieved, [ dEs32, dEs41, dEs43, Ia3, Ia4 ] );
eq4_achieved = collect( eq4_achieved, [ dEs32, dEs41, dEs43, Ia3, Ia4 ] );

% Print out the desired constraints.
fprintf( 'A1: ' ), pretty( eq1_achieved )
fprintf( 'A2: ' ), pretty( eq2_achieved )
fprintf( 'A3: ' ), pretty( eq3_achieved )
fprintf( 'A4: ' ), pretty( eq4_achieved )

% Print out a message that says we are done deriving achieved formulation constraints.
fprintf( 'Deriving achieved formulation constraints... Done.\n' )
fprintf( '\n' )


%% General Similarity Constraints.

% Print out a message that says we are deriving general similarity constraints.
fprintf( 'Deriving general similarity constraints...\n' )
fprintf( '\n' )

% Set the desired and achieved formulations equal to one another.
% eq_general_similarity = U4_desired*U4_achieved_den - U4_achieved_num;
eq_general_similarity = U4_desired_num*U4_achieved_den - U4_achieved_num*U4_desired_den;

% Collect the U1 and U2 terms.
eq_general_similarity = collect( eq_general_similarity, [ U1, U2 ] );

% Retrieve the coefficients.
[ eq_general_similarity_coeffs, eq_general_similarity_terms ] = coeffs( eq_general_similarity, [ U1, U2 ] ); eq_general_similarity_coeffs = simplify( eq_general_similarity_coeffs );

% Define the similarity constraints.
eq1_general_similarity = eq_general_similarity_coeffs( 1 ) == 0;
eq2_general_similarity = eq_general_similarity_coeffs( 2 ) == 0;
eq3_general_similarity = eq_general_similarity_coeffs( 3 ) == 0;
eq4_general_similarity = eq_general_similarity_coeffs( 4 ) == 0;
eq5_general_similarity = eq_general_similarity_coeffs( 5 ) == 0;
eq6_general_similarity = eq_general_similarity_coeffs( 6 ) == 0;
eq7_general_similarity = eq_general_similarity_coeffs( 7 ) == 0;
eq8_general_similarity = eq_general_similarity_coeffs( 8 ) == 0;
% eq9_general_similarity = eq_general_similarity_coeffs( 9 ) == 0;

% Print out the similarity constraints.
fprintf( 'S1: ' ), pretty( eq1_general_similarity )
fprintf( 'S2: ' ), pretty( eq2_general_similarity )
fprintf( 'S3: ' ), pretty( eq3_general_similarity )
fprintf( 'S4: ' ), pretty( eq4_general_similarity )
fprintf( 'S5: ' ), pretty( eq5_general_similarity )
fprintf( 'S6: ' ), pretty( eq6_general_similarity )
fprintf( 'S7: ' ), pretty( eq7_general_similarity )
fprintf( 'S8: ' ), pretty( eq8_general_similarity )
% fprintf( 'S9: ' ), pretty( eq9_general_similarity )

% Print out a message that says we are done deriving general similarity constraints.
fprintf( 'Deriving general similarity constraints... Done.\n' )
fprintf( '\n' )


%% Specific Similarity Constraints.

% Print out a message that says we are deriving specific similarity constraints.
fprintf( 'Deriving specific similarity constraints...\n' )
fprintf( '\n' )

% Compute the specific similarity constraints.
eq1_specific_similarity = simplify( subs( eq_general_similarity, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] ) == 0 );
eq2_specific_similarity = simplify( subs( eq_general_similarity, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] ) == 0 );
eq3_specific_similarity = simplify( subs( eq_general_similarity, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] ) == 0 );
eq4_specific_similarity = simplify( subs( eq_general_similarity, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] ) == 0 );
% eq5_specific_similarity = simplify( subs( eq_general_similarity, [ U1, U2 ], [ P5( 1 ), P5( 2 ) ] ) == 0 );

% Print out the specific similarity constraints.
fprintf( 'S1: ' ), pretty( eq1_specific_similarity )
fprintf( 'S2: ' ), pretty( eq2_specific_similarity )
fprintf( 'S3: ' ), pretty( eq3_specific_similarity )
fprintf( 'S4: ' ), pretty( eq4_specific_similarity )
% fprintf( 'S5: ' ), pretty( eq5_specific_similarity )

% Print out a message that says we are done deriving specific similarity constraints.
fprintf( 'Deriving specific similarity constraints... Done.\n' )
fprintf( '\n' )


% %% Post Processesing
% 
% % Are the general similarity constraints internally consistent?
% 
% % Solve the second general similarity constraint for gs32.
% gs32 = solve( eq2_general_similarity, gs32 );
% 
% % Solve the fourth general similarity constraint for gs43.
% gs43 = solve( eq4_general_similarity, gs43 );
% 
% % Solve the fifth general similarity constraint for gs41.
% eq5_general_similarity = subs( eq5_general_similarity, { 'gs32', 'gs43' }, { gs32, gs43 } );
% gs41a = solve( eq5_general_similarity, gs41 );
% gs41a = simplify( gs41a );
% 
% % Solve the sixth general similarity constraint for gs41.
% eq6_general_similarity = subs( eq6_general_similarity, { 'gs32', 'gs43' }, { gs32, gs43 } );
% gs41b = solve( eq6_general_similarity, gs41 );
% gs41b = simplify( gs41b );


% %% Simplifications
% 
% % Substitute in zeros for Ia4 and dEs43.
% eq1_specific_similarity = subs( eq1_specific_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% eq2_specific_similarity = subs( eq2_specific_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% eq3_specific_similarity = subs( eq3_specific_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% eq4_specific_similarity = subs( eq4_specific_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% 
% % Solve for gs41 and gs43.
% sol = solve( [ eq1_specific_similarity, eq3_specific_similarity ], [ gs41, gs43 ], 'ReturnConditions', true );
% 
% gs41 = simplify( sol.gs41 );
% gs43 = simplify( sol.gs43 );
% 
% 
% 
% % % Substitute in zeros for Ia4 and dEs43.
% % eq1_specific_similarity = subs( eq1_specific_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq2_specific_similarity = subs( eq2_specific_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq3_specific_similarity = subs( eq3_specific_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq4_specific_similarity = subs( eq4_specific_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq5_specific_similarity = subs( eq5_specific_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % 
% % % Solve for gs32, gs41, gs43.
% % sol = solve( [ eq1_specific_similarity, eq3_specific_similarity, eq5_specific_similarity ], [ gs32, gs41, gs43 ], 'ReturnConditions', true );
% % 
% % gs32 = simplify( sol.gs32 );
% % gs41 = simplify( sol.gs41 );
% % gs43 = simplify( sol.gs43 );
% 
% 
% 
% 
% 
% 
% % sol = solve( eq5_specific_similarity, gs32, 'ReturnConditions', true );
% % gs32 = simplify( sol.gs32 );
% % 
% % eq1_specific_similarity = subs( eq1_specific_similarity, 'gs32', gs32 );
% % eq3_specific_similarity = subs( eq3_specific_similarity, 'gs32', gs32 );
% % 
% % % Solve for gs41 and gs43.
% % sol = solve( [ eq1_specific_similarity, eq3_specific_similarity ], [ gs41, gs43 ], 'ReturnConditions', true );
% % 
% % gs41 = simplify( sol.gs41 );
% % gs43 = simplify( sol.gs43 );
% 
% 
% 
% % % Substitute zero in for Ia4 and dEs43.
% % eq1_achieved = subs( eq1_achieved, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq2_achieved = subs( eq2_achieved, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq3_achieved = subs( eq3_achieved, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq4_achieved = subs( eq4_achieved, [ Ia4, dEs43 ], [ 0, 0 ] );
% % 
% % eq1_general_similarity = subs( eq1_general_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq2_general_similarity = subs( eq2_general_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq3_general_similarity = subs( eq3_general_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq4_general_similarity = subs( eq4_general_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq5_general_similarity = subs( eq5_general_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq6_general_similarity = subs( eq6_general_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq7_general_similarity = subs( eq7_general_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % eq8_general_similarity = subs( eq8_general_similarity, [ Ia4, dEs43 ], [ 0, 0 ] );
% % 
% % % Solve the specified equations for gs32, gs41, and gs43.
% % % sol = solve( [ eq1_achieved, eq3_achieved ], [ gs41, gs43 ] );
% % % sol = solve( [ eq5_general_similarity, eq6_general_similarity ], [ gs41, gs43 ], 'ReturnConditions', true );
% % sol = solve( [ eq4_general_similarity, eq5_general_similarity, eq6_general_similarity ], [ gs32, gs41, gs43 ], 'ReturnConditions', true );
% % 
% % % sol = solve( eq1_achieved, gs41, 'ReturnConditions', true );
% % % gs41 = simplify( sol.gs41 );
% % % 
% % % sol = solve( subs( eq3_achieved, 'gs41', gs41 ), gs43, 'ReturnConditions', true );
% % % gs43 = simplify( sol.gs43 );
% % % 
% % % gs41 = subs( gs41, 'gs43', gs43 ); 

