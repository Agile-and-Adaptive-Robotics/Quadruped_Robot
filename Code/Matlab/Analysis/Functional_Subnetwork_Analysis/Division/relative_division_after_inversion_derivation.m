%% Relative Division After Inversion Derivation

% Clear everything.
clear, close( 'all' ), clc

%% Setup the Problem.

% Define the symbolic variables.
syms R1 R2 R3 c1 c2 c3 delta1 delta2 Gm3 Iapp3 gs31 gs32 dEs31 dEs32 U1 U2 U3

% Set the variable assumptions.
assume( [ R1, R2, R3 ], 'positive' ) 
assume( Gm3, 'positive' ) 
assume( Iapp3, 'real' ) 
assume( [ gs31 gs32 ], 'positive' ) 
assume( [ c1, c2, c3, delta1, delta2 ], 'positive' )
assume( dEs31, 'positive' ) 
assume( dEs32, 'real' ) 


%% Relative Division Derivation Desired Formulation

% Define the points of interest.
P1 = [ R1, delta1, R3 ];
P2 = [ 0, R2, 0 ];
P3 = [ R1, R2, delta2 ];
P4 = [ 0, delta1, 0 ];

% Define the desired formulation.
U3 = c1*R2*R3*U1./( c2*R1*U2 + R1*R2*c3 );

% Evaluate the desired formulation at the target points.
eq1 = P1( 3 ) == subs( U3, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] );
eq2 = P2( 3 ) == subs( U3, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] );
eq3 = P3( 3 ) == subs( U3, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] );
eq4 = P4( 3 ) == subs( U3, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] );

% % Solve equations 1 and 3 for c2 and R3.
% sol = solve( [ eq1, eq3 ], [ c2, R3 ], 'ReturnConditions', true );
% 
% % Retrieve c2 and R3 from the solution.
% c2 = sol.c2;
% R3 = sol.R3;

% Solve equations 1 and 3 for c1 and c2.
sol = solve( [ eq1, eq3 ], [ c1, c2 ], 'ReturnConditions', true );

% Retrieve c1 and c2 from the solution.
c1 = sol.c1;
c2 = sol.c2;

% % Solve equation 1 for c1.
% c1 = solve( eq1, c1 );


%% Relative Division Derivation Similarity Constraints

% Define the similarity constraints.
dEs32 = 0;
Iapp3 = 0;
Gm3 = c3;


%% Relative Division Derivation Acheived Formulation

% Define the achieved formulation.
U3 = ( R2*gs31*dEs31*U1 + R1*gs32*dEs32*U2 + R1*R2*Iapp3 )/( R2*gs31*U1 + R1*gs32*U2 + R1*R2*Gm3 );

% Evaluate the achieved formulation at the target points.
eq1 = P1( 3 ) == subs( U3, [ U1, U2 ], [ P1( 1 ), P1( 2 ) ] );
eq2 = P2( 3 ) == subs( U3, [ U1, U2 ], [ P2( 1 ), P2( 2 ) ] );
eq3 = P3( 3 ) == subs( U3, [ U1, U2 ], [ P3( 1 ), P3( 2 ) ] );
eq4 = P4( 3 ) == subs( U3, [ U1, U2 ], [ P4( 1 ), P4( 2 ) ] );

% Solve equations 1 and 2 for gs31 and gs32.
sol = solve( [ eq1, eq3 ], [ gs31, gs32 ], 'ReturnConditions', true );

% Retrieve gs31 and gs32.
gs31 = collect( subs( sol.gs31, 'R3', R3 ), [ delta1, delta2 ] );
gs32 = collect( subs( sol.gs32, 'R3', R3 ), [ delta1, delta2 ] );





