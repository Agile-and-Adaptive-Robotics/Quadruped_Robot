%% Functional Subnetwork Analysis - Integration - Eigen Analysis - Symmetric, With Gm

% Clear Everything.
clear, close('all'), clc


%% Compute the Eigenvalues & Eigenvectors of the Jacobian.

% Define the symbolic variables.
syms Gm Cm gs R dEs U1 U2 lambda u B C1 C2 t

% Assume that the values are real and positive.
assume( [ Gm Cm gs R dEs U1 U2 lambda u ], 'real' )
assume( [ Gm Cm gs R dEs U1 U2 u ], 'positive' )

% Define the constraint equation.
dEs = -Gm*R/gs;

% Define the system flow.
f1 = ( Gm/Cm )*U1 + ( -gs/( Cm*R ) )*( dEs - U1 )*U2;
f2 = ( Gm/Cm )*U2 + ( -gs/( Cm*R ) )*( dEs - U2 )*U1;

% Define the system forcing.
% F = [ R/Cm + u/Cm; R/Cm ];
% F = [ ( Gm*R )/Cm + ( Gm*u )/Cm; ( Gm*R )/Cm ];
F = [ ( Gm*R )/Cm + ( u )/Cm; ( Gm*R )/Cm ];

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
ki_range = ki_max - ki_min; ki_range = simplify( ki_range );
ki_mean = ( ki_max + ki_min )/2; ki_mean = simplify( ki_mean );


