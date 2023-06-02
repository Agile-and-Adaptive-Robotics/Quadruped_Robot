%% Multiplication Functional Subnetwork Design Rule Derivation

% Clear everything.
clear, close( 'all' ), clc


%% Setup the Problem.

% Define symbolic variables.
syms R1 R2 R3 R4 R5 R6 R7 U1 U2 U3 U4 U5 U6 U7 gs31 gs32 gs41 gs42 gs43 gs51 gs52 gs53 gs54 gs62 gs63 gs74 gs75 gs76 dEs31 dEs32 dEs41 dEs42 dEs43 dEs51 dEs52 dEs53 dEs54 dEs62 dEs63 dEs74 dEs75 dEs76 Gm1 Gm2 Gm3 Gm4 Gm5 Gm6 Gm7 Iapp1 Iapp2 Iapp3 Iapp4 Iapp5 Iapp6 Iapp7 c delta

% Set the variable assumptions.
assume( [ R1, R2, R3, R4, R5, R6, R7 ], 'positive' ) 
assume( [ Gm1, Gm2, Gm3, Gm4, Gm5, Gm6, Gm7 ], 'positive' ) 
assume( [ gs31 gs32 gs41 gs42 gs43 gs51 gs52 gs53 gs54 gs62 gs63 gs74 gs75 gs76 ], 'positive' ) 
assume( [ c, delta ], 'positive' )


%% Multiplication Architecture 4a

% Define the points of interest.
% P1 = [ R1; 0; 0 ];
P1 = [ R1; 0; delta ];
P2 = [ 0; R2; 0 ];
P3 = [ R1; R2; R4 ];
P4 = [ 0; 0; 0 ];

% Define the steady state behavior of neuron three.
U3 = ( gs32*dEs32*U2 + R2*Iapp3 )/( gs32*U2 + R2*Gm3 );

% Define the steady state behavior of neuron four.
U4 = ( R3*gs41*dEs41*U1 + R1*gs43*dEs43*U3 + R1*R3*Iapp4 )/( R3*gs41*U1 + R1*gs43*U3 + R1*R3*Gm4 );

% Collect the relevant terms of the fourth neuron's steady state behavior.
U4 = collect( U4, [ U1, U2 ] );

% Substitute in some values.
U4 = subs( U4, [ dEs32, dEs43, Iapp4 ], [ 0, 0, 0 ] );

% Retrieve the numerator and denominator of the fourth neuron's steady state behavior.
[ U4_num, U4_den ] = numden( U4 );

% Retrieve the coefficients associated with the numerator and denominator of the fourth neuron's steady state behavior.
[ U4_num_coeffs, U4_num_terms ] = coeffs( U4_num, [ U1, U2 ] ); U4_num_coeffs = simplify( U4_num_coeffs );
[ U4_den_coeffs, U4_den_terms ] = coeffs( U4_den, [ U1, U2 ] ); U4_den_coeffs = simplify( U4_den_coeffs );

% Print out the symbolic result.
fprintf( 'Architecture 4A:\n' )
fprintf( 'U4a = \n' )
pretty( U4 )

eq1 = c == U4_num_coeffs( 1 )/U4_den_coeffs( end );
eq2 = P1( 3 ) == subs( U4, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] );
eq3 = P3( 3 ) == subs( U4, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] );

sol = solve( [ eq1, eq2, eq3 ], [ gs32, gs41, gs43 ] );
% [ sol1, sol2, sol3, parameters, conditions ] = solve( [ eq1, eq2, eq3 ], [ gs32, gs41, gs43 ], 'ReturnConditions', true );

gs32 = simplify( sol.gs32 );
gs41 = simplify( sol.gs41 );
gs43 = simplify( sol.gs43 );

% %% Multiplication Architecture 4b
% 
% % Define the points of interest.
% P1 = [ R1; 0; 0 ];
% P2 = [ 0; R2; 0 ];
% P3 = [ R1; R2; R4 ];
% P4 = [ 0; 0; 0 ];
% 
% % Define the steady state behavior of neuron three.
% U3 = ( gs31*dEs31*U1 + R1*Iapp3 )/( gs31*U1 + R1*Gm3 );
% 
% % Define the steady state behavior of neuron four.
% U4 = ( R3*gs42*dEs42*U2 + R2*gs43*dEs43*U3 + R2*R3*Iapp4 )/( R3*gs42*U2 + R2*gs43*U3 + R2*R3*Gm4 );
% 
% % Collect the relevant terms of the fourth neuron's steady state behavior.
% U4 = collect( U4, [ U1, U2 ] );
% 
% % Retrieve the numerator and denominator of the fourth neuron's steady state behavior.
% [ U4_num, U4_den ] = numden( U4 );
% 
% % Retrieve the coefficients associated with the numerator and denominator of the fourth neuron's steady state behavior.
% U4_num_coeffs = simplify( coeffs( U4_num, [ U1, U2 ] ) );
% U4_den_coeffs = simplify( coeffs( U4_den, [ U1, U2 ] ) );
% 
% % Print out the symbolic result.
% fprintf( 'Architecture 4b:\n' )
% fprintf( 'U4b = \n' )
% pretty( U4 )
% 
% 
% %% Multiplication Architecture 5
% 
% % Define the points of interest.
% P1 = [ R1; 0; 0 ];
% P2 = [ 0; R2; 0 ];
% P3 = [ R1; R2; R5 ];
% P4 = [ 0; 0; 0 ];
% 
% % Define the steady state behavior of neuron three.
% U3 = ( gs31*dEs31*U1 + R1*Iapp3 )/( gs31*U1 + R1*Gm3 );
% 
% % Define the steady state behavior of neuron four.
% U4 = ( gs42*dEs42*U2 + R2*Iapp4 )/( gs42*U2 + R2*Gm4 );
% 
% % Define the steady state behavior of neuron five.
% U5 = ( R4*gs53*dEs53*U3 + R3*gs54*dEs54*U4 + R3*R4*Iapp5 )/( R4*gs53*U3 + R3*gs54*U4 + R3*R4*Gm5 );
% 
% % Collect the relevant terms of the fifth neuron's steady state behavior.
% U5 = collect( U5, [ U1, U2 ] );
% 
% % Retrieve the numerator and denominator of the fifth neuron's steady state behavior.
% [ U5_num, U5_den ] = numden( U5 );
% 
% % Retrieve the coefficients associated with the numerator and denominator of the fifth neuron's steady state behavior.
% U5_num_coeffs = simplify( coeffs( U5_num, [ U1, U2 ] ) );
% U5_den_coeffs = simplify( coeffs( U5_den, [ U1, U2 ] ) );
% 
% % Print out the symbolic result.
% fprintf( 'Architecture 5:\n' )
% fprintf( 'U5 = \n' )
% pretty( U5 )
% 
% eq1 = P1( 3 ) == subs( U5, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] );
% eq2 = P2( 3 ) == subs( U5, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] );
% eq3 = P3( 3 ) == subs( U5, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] );
% eq4 = P4( 3 ) == subs( U5, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] );
% 
% 
% 
% % %% Multiplication Architecture 7
% % 
% % % Reset the necessary symbolic variables.
% % syms U3
% % 
% % % Define the steady state behavior of the intermediate neurons.
% % U4 = ( gs41*dEs41*U1 + R1*Iapp4 )/( gs41*U1 + R1*Gm4 );
% % U5 = ( gs52*dEs52*U2 + R2*Iapp5 )/( gs52*U2 + R2*Gm5 );
% % U6 = ( gs63*dEs63*U3 + R3*Iapp6 )/( gs63*U3 + R3*Gm6 );
% % 
% % % Define the steady state behavior of the output neuron.
% % U7 = ( R5*R6*gs74*dEs74*U4 + R4*R6*gs75*dEs75*U5 + R4*R5*gs76*dEs76*U6 + R4*R5*R6*Iapp7 )/( R5*R6*gs74*U4 + R4*R6*gs75*U5 + R4*R5*gs76*U6 + R4*R5*R6*Gm7 );
% % 
% % % Collect the relevant terms of the output neuron's steady state behavior.
% % U7 = collect( U7, [ U1, U2, U3 ] );
% % 
% % % Retrieve the numerator and denominator of the output neuron's steady state behavior.
% % [ U7_num, U7_den ] = numden( U7 );
% % 
% % % Retrieve the coefficients associated with the numerator and denominator of the fifth neuron's steady state behavior.
% % U7_num_coeffs = simplify( coeffs( U7_num, [ U1, U2, U3 ] ) );
% % U7_den_coeffs = simplify( coeffs( U7_den, [ U1, U2, U3 ] ) );
% % 
% % % Print out the symbolic result.
% % fprintf( 'Architecture 7:\n' )
% % fprintf( 'U7 = \n' )
% % pretty( U7 )
% 
% 
% %% Multiplication Architecture 5 (Two Stage, Variation 1)
% 
% % Define the points of interest.
% P1 = [ R1; 0; 0 ];
% P2 = [ 0; R2; 0 ];
% P3 = [ R1; R2; R5 ];
% P4 = [ 0; 0; 0 ];
% 
% % Define the steady state behavior of neuron three.
% U3 = ( gs31*dEs31*U1 + R1*Iapp3 )/( gs31*U1 + R1*Gm3 );
% 
% % Define the steady state behavior of neuron four.
% U4 = ( gs42*dEs42*U2 + R2*Iapp4 )/( gs42*U2 + R2*Gm4 );
% 
% % Define the steady state behavior of neuron five.
% U5 = ( R2*R3*R4*gs51*dEs51*U1 + R1*R3*R4*gs52*dEs52*U2 + R1*R2*R4*gs53*dEs53*U3 + R1*R2*R3*gs54*dEs54*U4 + R1*R2*R3*R4*Iapp5 )/( R2*R3*R4*gs51*U1 + R1*R3*R4*gs52*U2 + R1*R2*R4*gs53*U3 + R1*R2*R3*gs54*U4 + R1*R2*R3*R4*Gm5 );
% 
% % Collect the relevant terms of the fifth neuron's steady state behavior.
% U5 = collect( U5, [ U1, U2 ] );
% 
% % Print out the symbolic result.
% fprintf( 'Architecture 5:\n' )
% fprintf( 'U5 = \n' )
% pretty( U5 )
% 
% 
% %% Multiplication Architecture 5 (Two Stage, Variation 2)
% 
% % Define the points of interest.
% P1 = [ R1; 0; 0 ];
% P2 = [ 0; R2; 0 ];
% P3 = [ R1; R2; R4 ];
% P4 = [ 0; 0; 0 ];
% 
% U3 = ( R2*gs31*dEs31*U1 + R1*gs32*dEs32*U2 + R1*R2*Iapp3 )/( R2*gs31*U1 + R1*gs32*U2 + R1*R2*Gm3 );
% 
% U4 = ( R2*R3*gs41*dEs41*U1 + R1*R3*gs42*dEs42*U2 + R1*R2*gs43*dEs43*U3 + R1*R2*R3*Iapp4 )/( R2*R3*gs41*U1 + R1*R3*gs42*U2 + R1*R2*gs43*U3 + R1*R2*R3*Gm4 );
% 
% % Collect the relevant terms of the output neuron's steady state behavior.
% U4 = collect( U4, [ U1, U2 ] );
% 
% % Print out the symbolic result.
% fprintf( 'Architecture 5:\n' )
% fprintf( 'U4 = \n' )
% pretty( U4 )
% 
% 
% %% Multiplication Architecture (Three Stage)
% 
% P1 = [ R1; 0; 0 ];
% P2 = [ 0; R2; 0 ];
% P3 = [ R1; R2; R7 ];
% P4 = [ 0; 0; 0 ];
% 
% U3 = ( gs31*dEs31*U1 + R1*Iapp3 )/( gs31*U1 + R1*Gm3 );
% U4 = ( gs42*dEs42*U2 + R2*Iapp4 )/( gs42*U2 + R2*Gm4 );
% 
% U5 = ( R4*gs51*dEs51*U1 + R1*gs54*dEs54*U4 + R1*R4*Iapp5 )/( R4*gs51*U1 + R1*gs54*U4 + R1*R4*Gm5 );
% U6 = ( R3*gs62*dEs62*U2 + R2*gs63*dEs63*U3 + R2*R3*Iapp6 )/( R3*gs62*U2 + R2*gs63*U3 + R2*R3*Gm6 );
% U7 = ( R6*gs75*dEs75*U5 + R5*gs76*dEs76*U6 + R5*R6*Iapp7 )/( R6*gs75*U5 + R5*gs76*U6 + R5*R6*Gm7 );
% 
% % Collect the relevant terms of the output neuron's steady state behavior.
% U7 = collect( U7, [ U1, U2 ] );
% 
% [ U7_num, U7_den ] = numden( U7 );
% 
% [ U7_num_coeffs, U7_num_terms ] = coeffs( U7_num, [ U1, U2 ] ); U7_num_coeffs = simplify( U7_num_coeffs );
% [ U7_den_coeffs, U7_den_terms ] = coeffs( U7_den, [ U1, U2 ] ); U7_den_coeffs = simplify( U7_den_coeffs );
% 
% % U7_num_coeffs = subs( U7_num_coeffs, [ Iapp7 ], [ 0 ] );
% % U7_den_coeffs = subs( U7_den_coeffs, [ Iapp7 ], [ 0 ] );
% 
% U7_num_coeffs = subs( U7_num_coeffs, [ Iapp5, Iapp6, Iapp7 ], [ 0, 0, 0 ] );
% U7_den_coeffs = subs( U7_den_coeffs, [ Iapp5, Iapp6, Iapp7 ], [ 0, 0, 0 ] );
% 
% eq1 = U7_num_coeffs( 1 ) == 0;
% eq2 = U7_num_coeffs( 2 ) == 0;
% eq3 = U7_num_coeffs( 3 ) == 0;
% eq4 = U7_num_coeffs( 4 ) == 0;
% eq6 = U7_num_coeffs( 6 ) == 0;
% eq7 = U7_num_coeffs( 7 ) == 0;
% eq8 = U7_num_coeffs( 8 ) == 0;
% eq9 = U7_num_coeffs( 9 ) == 0;
% 
% sol = solve( [ eq1, eq2, eq3, eq4, eq6, eq7, eq8, eq9 ], [ dEs31, dEs51, dEs42, dEs62, dEs54, dEs63, dEs75, dEs76 ] );
% 
% mult = U7_num_coeffs( 5 );
% mult1 = subs( mult, [ dEs31, dEs51, dEs42, dEs62, dEs54, dEs63, dEs75, dEs76 ], [ sol.dEs31( 1 ), sol.dEs51( 1 ), sol.dEs42( 1 ), sol.dEs62( 1 ), sol.dEs54( 1 ), sol.dEs63( 1 ), sol.dEs75( 1 ), sol.dEs76( 1 ) ] );
% mult2 = subs( mult, [ dEs31, dEs51, dEs42, dEs62, dEs54, dEs63, dEs75, dEs76 ], [ sol.dEs31( 2 ), sol.dEs51( 2 ), sol.dEs42( 2 ), sol.dEs62( 2 ), sol.dEs54( 2 ), sol.dEs63( 2 ), sol.dEs75( 2 ), sol.dEs76( 2 ) ] );
% mult3 = subs( mult, [ dEs31, dEs51, dEs42, dEs62, dEs54, dEs63, dEs75, dEs76 ], [ sol.dEs31( 3 ), sol.dEs51( 3 ), sol.dEs42( 3 ), sol.dEs62( 3 ), sol.dEs54( 3 ), sol.dEs63( 3 ), sol.dEs75( 3 ), sol.dEs76( 3 ) ] );
% 
% % Print out the symbolic result.
% fprintf( 'Architecture 5:\n' )
% fprintf( 'U7 = \n' )
% pretty( U7 )
% 
% % eq1 = P1( 3 ) == subs( U7, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] );
% % eq2 = P2( 3 ) == subs( U7, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] );
% % eq3 = P3( 3 ) == subs( U7, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] );
% % eq4 = P4( 3 ) == subs( U7, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] );


