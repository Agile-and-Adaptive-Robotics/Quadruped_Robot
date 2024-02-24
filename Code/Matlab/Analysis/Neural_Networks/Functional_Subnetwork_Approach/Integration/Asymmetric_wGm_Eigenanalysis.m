%% Functional Subnetwork Analysis - Integration - Eigen Analysis - Asymmetric, With Gm

% Clear Everything.
clear, close('all'), clc


%% Compute the Eigenvalues & Eigenvectors of the Jacobian.

% Define the symbolic variables.
syms Gm1 Gm2 Cm1 Cm2 Cm gs12 gs21 R1 R2 R dEs12 dEs21 U1 U2 lambda u B C1 C2 t Iapp1 Iapp2 Iapp ki_range ki_mean

% Assume that the values are real and positive.
assume( [ Gm1 Gm2 Cm1 Cm2 gs12 gs21 R1 R2 dEs12 dEs21 U1 U2 lambda u B C1 C2 t ], 'real' )
assume( [ Gm1 Gm2 Cm1 Cm2 gs12 gs21 R1 R2 U1 U2 t ], 'positive' )

% Define the constraint equations.
R1 = R;
R2 = R;
Iapp1 = Iapp;
Iapp2 = Iapp;
dEs12 = -( Gm1*R2 )/gs21;
% dEs21 = -( Gm2*R2 )/gs21;
% gs12 = ( R1*gs21 )/R2;
dEs21 = -( Gm2*Iapp1*R2 )/( Iapp2*gs21 );
gs12 = ( Iapp2*R1*gs21 )/( Iapp1*R2 );

% Define the system flow.
f1 = ( Gm1/Cm1 )*U1 + ( ( -gs21/( Cm1*R2 ) )*( dEs21 - U1 ) )*U2;
f2 = ( Gm2/Cm2 )*U2 + ( ( -gs12/( Cm2*R1 ) )*( dEs12 - U2 ) )*U1;

% Define the system forcing.
F = [ R1/Cm1 + u/Cm1; R2/Cm2 ];

% Define the jacobian.
J = [ diff( f1, U1 ) diff( f1, U2 ); diff( f2, U1 ) diff( f2, U2 ) ];

% Compute the eigenvalues.
[ V, D ] = eig( J );

% Normalize the eigenvectors.
X = [ V(:, 1)/norm( V(:, 1), 2 ), V(:, 2)/norm( V(:, 2), 2 ) ];


%% Compute the Particular Solution.

% Compute the transformed system.
Xinv = inv(X); Xinv = simplify( Xinv );
Jq = Xinv*J*X; Jq = simplify( Jq );
Fq = Xinv*F; Fq = simplify( Fq );

% Define a particular solution guess.
dqp_guess = [ B*u; 0 ];
qp_guess = int( dqp_guess, t ) + [ C1; C2 ];

% Setup the particular solution guess equation.
eq1 = dqp_guess + Jq*qp_guess == Fq;

% Isolate the particular solution parameter.
eq1 = isolate( eq1(1), B );

% Define the particular solution in the eigenspace.
dqp = subs( dqp_guess, lhs( eq1 ), rhs( eq1 ) );

% Convert the particular solution from the eigenspace to the state space.
dxp = X*dqp;


%% Compute the Integral Gain Parameters

% Compute the integral gain.
ki = dxp(1)/u; ki = simplify( ki );

% Compute the minimum and maximum integral gains.
ki_min = subs( ki, [ U1, U2 ], [ 0, R ] );
ki_max = subs( ki, [ U1, U2 ], [ R, 0 ] );

% Compute the range and mean integral gain.
eq1 = ki_range == ki_max - ki_min;
eq2 = ki_mean == ( ki_max + ki_min )/2;


%%  Determine Design Equations.

% Substitute a symmetric membrane capacitance.


% Solve the design equations.
sol = solve( [ eq1, eq2 ], [ Cm2 gs21 ] );

Cm2 = simplify( sol.Cm2 );
gs21 = simplify( sol.gs21 );

