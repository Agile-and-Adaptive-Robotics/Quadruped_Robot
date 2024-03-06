%% Multiplication Functional Subnetwork Design Rule Derivation

% Clear everything.
clear, close( 'all' ), clc


%% Setup the Problem.

% Define symbolic variables.
syms c1 c2 c3 c4 c5 c6 R1 R2 R3 R4 R5 R6 R7 U1 U2 U3 U4 U5 U6 U7 gs31 gs32 gs41 gs42 gs43 gs51 gs52 gs53 gs54 gs62 gs63 gs74 gs75 gs76 dEs31 dEs32 dEs41 dEs42 dEs43 dEs51 dEs52 dEs53 dEs54 dEs62 dEs63 dEs74 dEs75 dEs76 Gm1 Gm2 Gm3 Gm4 Gm5 Gm6 Gm7 Iapp1 Iapp2 Iapp3 Iapp4 Iapp5 Iapp6 Iapp7 c delta1 delta2

% Set the variable assumptions.
assume( [ R1, R2, R3, R4, R5, R6, R7 ], 'positive' ) 
assume( [ Gm1, Gm2, Gm3, Gm4, Gm5, Gm6, Gm7 ], 'positive' ) 
assume( [ gs31 gs32 gs41 gs42 gs43 gs51 gs52 gs53 gs54 gs62 gs63 gs74 gs75 gs76 ], 'positive' ) 
assume( [ c, delta1, delta2 ], 'positive' )


%% Absolute Multiplication Desired Formulation

% Define the points of interest.
% P1 = [ R1; 0; 0 ];
P1 = [ R1; 0; delta2 ];
P2 = [ 0; R2; 0 ];
P3 = [ R1; R2; R4 ];
P4 = [ 0; 0; 0 ];

% Define the absolute inverse constraints.
R3 = c1/c3;
c2 = ( c1 - delta1*c3 )/( delta1*R2 );
Gm3 = c3/R2;
dEs32 = 0;
Iapp3 = R3*Gm3;
gs32 = ( delta1*Gm3 - Iapp3 )/( dEs32 - delta1 );

% Define the absolute division constraints.
% R4 = c4*R1/c6;
% c5 = ( R1*c4 - delta2*c6 )/( delta2*R3 );
% dEs43 = 0;
% Iapp4 = 0;
% Gm4 = c6/( R1*R3 );
% gs41 = ( R4*Gm4 - Iapp4 )/( dEs41 - R4 );
% gs43 = ( ( dEs41 - delta2 )*gs41 + Iapp4 - delta2*Gm4 )/( delta2 - dEs43 );

R4 = ( c1*R1*R3*delta2 )/( c1*R1*delta1 - c3*delta1*delta2 + c3*R3*delta2 );
c5 = ( c4*R1 - c6*delta2 )/( delta2*R3 );
dEs43 = 0;
Iapp4 = 0;
Gm4 = c6/( R1*R3 );
% gs41 = ( R4*c6*delta1*delta2 - R3*R4*c6*delta2 )/( -R1*R3*R4*delta1*delta2 + R1*R3*R4*dEs41*delta1 + ( R4 - dEs41 )*R1*( R3^2 )*delta2 );
% gs43 = ( ( delta2 - R4 )*c6*dEs41 )/( -R1*R4*delta1*delta2 + R1*R4*dEs41*delta1 + ( R4 - dEs41 )*R1*R3*delta2 );
gs41 = ( c4*c6 )/( ( c6*dEs41 - R1*c4 )*R3 );
gs43 = ( ( delta2*c6 - R1*c4 )*dEs41*c6 )/( ( R1*c4 - dEs41*c6 )*R1*R3*delta2 );

% Define the steady state behavior of the third neuron.
U3 = c1/( c2*U2 + c3 );

% Define the steady state behavior of the fourth neuron.
U4 = c4*U1/( c5*U3 + c6 );

% Collect terms in the steady state behavior of the output neuron.
U4 = collect( U4, [ U1, U2 ] );

% Evaluate the absolute multiplication desired formulation at the target points.
eq1 = P1( 3 ) == subs( U4, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] );
eq2 = P2( 3 ) == subs( U4, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] );
eq3 = P3( 3 ) == subs( U4, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] );
eq4 = P4( 3 ) == subs( U4, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] );

% Solve for c4.
c4 = simplify( solve( subs( eq3, 'R4', R4 ), c4 ) );


% Substitute this solution into the previous definitions.
c5 = simplify( subs( c5, 'c4', c4 ) );
gs41 = simplify( subs( gs41, 'c4', c4 ) );
gs43 = simplify( subs( gs43, 'c4', c4 ) );

