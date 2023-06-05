%% Multiplication Derivation (Absolute)

% Clear everything.
clear, close( 'all' ), clc


%% Setup the Problem.

% Define symbolic variables.
syms R1 R2 R3 R4 c1 c2 c3 c4 c5 c6 delta1 delta2 dEs41 dEs32 dEs43 gs41 gs32 gs43 U1 U2 U3 U4 Iapp1 Iapp2 Iapp3 Iapp4 P1 P2 P3 P4

% Define symbolic assumptions.
assume( [ R1 R2 R3 R4 ], 'positive' )
assume( [ c1 c2 c3 c4 c5 c6 ], 'positive' )
assume( [ delta1 delta2 ], 'positive' )
assume( [ dEs41 dEs32 dEs43 ], 'real' )
assume( [ gs41 gs32 gs43 ], 'positive' )
assume( [ U1 U2 U3 U4 ], 'real' )
assume( [ Iapp1 Iapp2 Iapp3 Iapp4 ], 'real' )

% Define the target points of interest.
P1 = [ R1, 0, delta2 ];
P2 = [ 0, R2, 0 ];
P3 = [ R1, R2, R4 ];
P4 = [ 0, 0, 0 ];

% Define the absolute inversion subnetwork constraints.
R3 = c1/c3;
c2 = ( c1 - delta1*c3 )/( delta1*R2 );
Iapp3 = c1/R2;
gs32 = ( c1 - delta1*c3 )/( delta1*R2 );
dEs32 = 0;
Gm3 = c3/R2;

% Define the absolute division subnetwork constaints.
R4 = ( c4*R1*R3*delta2 )/( c4*R1*delta1 + c6*R3*delta2 - c6*delta1*delta2 );
c5 = ( c3*R1 - c6*delta2 )/( delta2*R3 );
gs41 = ( c4*c6 )/( ( c6*dEs41 - R1*c4 )*R3 );
gs43 = ( ( delta2*c6 - R1*c4 )*dEs41*c6 )/( ( R1*c4 - dEs41*c6 )*R1*R3*delta2 );
dEs43 = 0;
Iapp4 = 0;
Gm4 = c6/( R1*R3 );

% Define the resulting desired formulation.
U3 = c1/( c2*U2 + c3 );
U4 = ( c4*U1 )/( c5*U3 + c6 );

% Substitue target points into the desired formulation.
eq1 = P1( 3 ) == subs( U4, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] );
eq2 = P2( 3 ) == subs( U4, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] );
eq3 = P3( 3 ) == subs( U4, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] );
eq4 = P4( 3 ) == subs( U4, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] );

eq3 = subs( eq3, c4, c3 );
eq3 = subs( eq3, 'R4', R4 );

