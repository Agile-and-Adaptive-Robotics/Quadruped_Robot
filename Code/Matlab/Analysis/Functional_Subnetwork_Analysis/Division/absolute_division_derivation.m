%% Absolute Division Subnetwork Design Derivation

% Clear Everything.
clear, close( 'all' ), clc


%% Setup the Problem.

% Define the symbolic variables.
syms R1 R2 R3 R4 R5 Gm1 Gm2 Gm3 Gm4 Gm5 gs31 gs53 gs42 gs54 dEs31 dEs53 dEs42 dEs54 Iapp1 Iapp2 Iapp3 Iapp4 Iapp5 c1 c2 c3 c4 c5 c6 c7 c8

% Set the variable assumptions.
assume( [ R1 R2 R3 R4 R5 Gm1 Gm2 Gm3 Gm4 Gm5 gs31 gs53 gs42 gs54 ] > 0 )
assume( [ dEs31 dEs53 dEs42 dEs54 c1 c2 c3 c4 c5 c6 c7 c8 ], 'real' )
assume( [ Iapp1 Iapp2 Iapp3 Iapp4 Iapp5 ] >= 0 )


%% Define the Constraint Equations.

% % Define the constraint equations.
% constraint1 = R5 == ( c2*R1 + c4 )./( c6*R1 + c8 );
% constraint2 = 0 == ( c3*R2 + c4 )./( c7*R2 + c8 );
% constraint3 = 0 == ( c1*R1*R2 + c2*R1 + c3*R2 + c4 )./( c5*R1*R2 + c6*R1 + c7*R2 + c8 );
% constraint4 = 0 == c4;
% 
% subs( constraint1, constraint4 


% Define the symbolic coefficients.
c1 = gs31*gs42*( R4*gs53*dEs53*dEs31 + R3*gs54*dEs54*dEs42 + R3*R4*Iapp5 );
c2 = R2*gs31*( R4*Gm4*gs53*dEs53*dEs31 + R3*Iapp4*gs54*dEs54 + R3*R4*Gm4*Iapp5 );
c3 = R1*gs42*( R4*Iapp3*gs53*dEs53 + R3*Gm3*gs54*dEs54*dEs42 + R3*R4*Iapp5*Gm3 );
c4 = R1*R2*( R4*Gm4*Iapp3*gs53*dEs53 + R3*Gm3*Iapp4*gs54*dEs54 + R3*R4*Gm3*Gm4*Iapp5 );
c5 = gs31*gs42*( R4*gs53*dEs31 + R3*gs54*dEs42 + R3*R4*Gm5 );
c6 = R2*gs31*( R4*Gm4*gs53*dEs31 + R3*Iapp4*gs54 + R3*R4*Gm4*Gm5 );
c7 = R1*gs42*( R4*Iapp3*gs53 + R3*Gm3*gs54*dEs42 + R3*R4*Gm3*Gm5 );
c8 = R1*R2*( R4*Gm4*Iapp3*gs53 + R3*Gm3*Iapp4*gs54 + R3*R4*Gm3*Gm4*Gm5 );

% Define the constraint equations.
eq1 = R5 == ( c2*R1 + c4 )./( c6*R1 + c8 );
eq2 = 0 == c3*R2 + c4;
eq3 = 0 == ( c1*R1*R2 + c2*R1 + c3*R2 + c4 )./( c5*R1*R2 + c6*R1 + c7*R2 + c8 );
eq4 = c4 == 0;

% Solve for the synaptic conductances.
sol = solve( [ eq1 eq2 eq3 eq4 ], [ gs31 gs42 gs53 gs54 ] );  




