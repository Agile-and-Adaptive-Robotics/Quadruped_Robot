%% Single Hill Muscle With Rotating Joint

% Clear Everything.
clear, close('all'), clc


%% Setup the Problem.

% Define the symbolic variables.
syms t kse kpe b k kt ct L m T dT u theta(t) Pa1x Pa1y Pa1z Pa2x Pa2y Pa2z Pa30x Pa30y Pa30z Pb1x Pb1y Pb1z Pb2x Pb2y Pb2z Pb30x Pb30y Pb30z ddeltaLa

% Define variable conditions.
assume( [ t kse kpe b k kt ct L m T dT u theta(t) Pa1x Pa1y Pa1z Pa2x Pa2y Pa2z Pa30x Pa30y Pa30z Pb1x Pb1y Pb1z Pb2x Pb2y Pb2z Pb30x Pb30y Pb30z ddeltaLa ], 'real' )
assume( [ kse kpe b k kt ct L m ], 'positive' )

% Define the state variable derivatives.
dtheta = diff( theta, t );
ddtheta = diff( dtheta, t );

% Define the geometry points.
Pa1 = [ Pa1x; Pa1y; Pa1z  ]; Pb1 = [ Pb1x; Pb1y; Pb1z  ];
Pa2 = [ Pa2x; Pa2y; Pa2z  ]; Pb2 = [ Pb2x; Pb2y; Pb2z  ];
Pa30 = [ Pa30x; Pa30y; Pa30z  ]; Pb30 = [ Pb30x; Pb30y; Pb30z  ];

% Pa1 = [ Pa1x; Pa1y; 0  ]; Pb1 = [ Pb1x; Pb1y; 0  ];
% Pa2 = [ Pa2x; Pa2y; 0  ]; Pb2 = [ Pb2x; Pb2y; 0  ];
% Pa30 = [ Pa30x; Pa30y; 0  ]; Pb30 = [ Pb30x; Pb30y; 0  ];

% Define the rotation matrix.
Rz = [ cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1 ];

% Define the location of the third geometric points.
Pa3 = Rz*Pa30; Pb3 = Rz'*Pb30;

% Define the initial tendon lengths.
La0 = norm( Pa2 - Pa30, 2 );
Lb0 = norm( Pb2 - Pb30, 2 );

% Define the current tendon lengths.
La = norm( Pa2 - Pa3, 2 );
Lb = norm( Pb2 - Pb3, 2 );

% Compute the change in length of the muscles.
deltaLa = La - La0;
deltaLb = Lb - Lb0;

% Compute the rate of length change of the muscles.
ddeltaLa = diff( deltaLa, t );
ddeltaLb = diff( deltaLb, t );

% Compute the direction of the forces.
Fahat = ( Pa2 - Pa3 )/norm( Pa2 - Pa3 );
Fbhat = ( Pb2 - Pb3 )/norm( Pb2 - Pb3 );

% Compute the magnitude of the forces.
Famag = T;
Fbmag = k*deltaLb;

% Define the force vectors.
Fa = Famag*Fahat;
Fb = Fbmag*Fbhat;

% Define the moment arms.
ra = Pa3;
rb = Pb3;

% Compute the applied moments.
Ma = cross( ra, Fa );
Mb = cross( rb, Fb );

% Define the Hill Muscle model.
eq1 = dT == ((kse*kpe)/b)*deltaLa + kse*ddeltaLa - (kse/b)*(1 + kpe/kse)*T + (kse/b)*u;

% Define the link moment of intertia.
I = (1/3)*m*L^2;

% Define the equation of motion.
eq2 = I*ddtheta + ct*dtheta + kt*theta == Ma + Mb;




