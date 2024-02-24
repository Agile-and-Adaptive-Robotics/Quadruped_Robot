function [fx1, fx2, fx3] = Symb_3DOF_solver()
% JOE'S CODE - with some modifications

% Symbolically solves equations of motion. 
% Theta value were altered, and so coordinate designation was also changed.

clear;close all;%clc;

% Define symbolic variables used in EOM
syms M1 M2 M3;
syms theta1(t) dtheta1(t) ddtheta1(t) theta2(t) dtheta2(t) ddtheta2(t) theta3(t) dtheta3(t) ddtheta3(t);
syms L1 L2 L3;
syms R1 R2 R3;
syms b1 b2 b3 b4 b5 b6;
syms K1 K2 K3 K4 K5 K6;
syms theta1bias theta2bias theta3bias theta4bias theta5bias theta6bias;
syms I1 I2 I3;
syms u1 u2 u3;
syms g;
syms a1 a2 a3 w1 w2 w3;
syms u1 u2 u3 u4 u5 u6 du1 du2 du3 du4 du5 du6;

% Define inertia values, modeling links as rods
I1 = (1/3)*M1*( L1^2 - 3*L1*R1 + 3*R1^2 );
I2 = (1/3)*M2*( L2^2 - 3*L2*R2 + 3*R2^2 );
I3 = (1/3)*M3*( L3^2 - 3*L3*R3 + 3*R3^2 );

% Coordinates of center of masses of each point of 3-link pendulum. Theta
% values are measured between the negative horizontal (right direction) and
% the back of the thigh, the back of the thigh to the back of the calf, and
% the front of the shin to the top of the foot, respectively.
p1x = R1 * cos(pi - theta1(t));
p1y = R1 * sin(pi - theta1(t));
p2x = L1 * cos(pi - theta1(t)) + R2 * cos(-(theta1(t) + theta2(t)));
p2y = L1 * sin(pi - theta1(t)) + R2 * sin(-(theta1(t) + theta2(t)));
p3x = L1 * cos(pi - theta1(t)) + L2 * cos(-(theta1(t) + theta2(t))) + R3 * cos(theta3(t) - (theta1(t) + theta2(t)) + pi);
p3y = L1 * sin(pi - theta1(t)) + L2 * sin(-(theta1(t) + theta2(t))) + R3 * sin(theta3(t) - (theta1(t) + theta2(t)) + pi);

% First derivative of each point
v1 = sqrt(diff(p1x, t)^2 + diff(p1y, t)^2);
v2 = sqrt(diff(p2x, t)^2 + diff(p2y, t)^2);
v3 = sqrt(diff(p3x, t)^2 + diff(p3y, t)^2);

v1 = subs( v1, [ diff( theta1( t ), t ) diff( theta2( t ), t ) diff( theta3( t ), t ) ], [ dtheta1 dtheta2 dtheta3 ] ); 
v2 = subs( v2, [ diff( theta1( t ), t ) diff( theta2( t ), t ) diff( theta3( t ), t ) ], [ dtheta1 dtheta2 dtheta3 ] ); 
v3 = subs( v3, [ diff( theta1( t ), t ) diff( theta2( t ), t ) diff( theta3( t ), t ) ], [ dtheta1 dtheta2 dtheta3 ] ); 

% friction values
D1 = u1*M1*g*R1*dtheta1(t);
D2 = u2*M2*g*R2*dtheta2(t);
D3 = u3*M3*g*R3*dtheta3(t);

% Kinetic Energy equation
KE1 = 0.5*M1*(v1.^2) + 0.5*I1*(dtheta1(t)).^2; KE1 = simplify(KE1);
KE2 = 0.5*M2*(v2^2) + 0.5*I2*(dtheta2(t))^2; KE2 = simplify(KE2);
KE3 = 0.5*M3*(v3^2) + 0.5*I3*(dtheta3(t))^2; KE3 = simplify(KE3);
KE = KE1 + KE2 + KE3;


% Potential energy - modified. 
% define horizontal line at which the center of mass of the entire leg is
% at zero
m_tot = M1 + M2 + M3;
r_tot = (M1/m_tot)*R1 + (M2/m_tot)*(L1 + R2) + (M3/m_tot)*(L1 + L2 + R3);
PE = M1*g*(r_tot - p1y) + M2*g*(r_tot - p2y) + M3*g*(r_tot - p3y);
PE = simplify(PE);

% Joint torques. Note that Joe's version had the u (friction values
% replaced with the commented out portion. Friction appeared to be unused
% in his model.
P1 = -b1*dtheta1(t) - K1*(theta1(t)+theta1bias) - u1*sign(dtheta1(t));%(b4*dtheta1(t)+K4*(theta1(t)+theta4bias));
P2 = -b2*dtheta2(t) - K2*(theta2(t)+theta2bias) - u2*sign(dtheta2(t));%(b5*dtheta1(t)+K5*(theta1(t)+theta5bias));
P3 = -b3*dtheta3(t) - K3*(theta3(t)+theta3bias) - u3*sign(dtheta3(t));%(b6*dtheta1(t)+K6*(theta1(t)+theta6bias));

% Lagrangian formulation
L = simplify(KE - PE);

% Subsitute in non-time dependent variables for KE and PE
L_sub = subs( L, [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ], [ a1 a2 a3 w1 w2 w3 ] );

% Partial derivative of L with respect to theta (SUBBED)
pL_ptheta1_sub = simplify(diff(L_sub, a1));
pL_ptheta2_sub = simplify(diff(L_sub, a2));
pL_ptheta3_sub = simplify(diff(L_sub, a3));

% Partial derivative of L with respect to theta dot (SUBBED)
pL_pdtheta1_sub = simplify(diff(L_sub, w1));
pL_pdtheta2_sub = simplify(diff(L_sub, w2));
pL_pdtheta3_sub = simplify(diff(L_sub, w3));


% Subsitute BACK in time dependent variables for L
pL_ptheta1 = subs( pL_ptheta1_sub, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
pL_ptheta2 = subs( pL_ptheta2_sub, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
pL_ptheta3 = subs( pL_ptheta3_sub, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );

pL_pdtheta1 = subs( pL_pdtheta1_sub, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
pL_pdtheta2 = subs( pL_pdtheta2_sub, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
pL_pdtheta3 = subs( pL_pdtheta3_sub, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );

% Compute the derivative with respect to time of the partial derivative of
% L with respect to theta dot
d_dt_pL_pdtheta1 = simplify(diff(pL_pdtheta1, t));
d_dt_pL_pdtheta2 = simplify(diff(pL_pdtheta2, t));
d_dt_pL_pdtheta3 = simplify(diff(pL_pdtheta3, t));


% Substitute in convenient angle derivative variables.
d_dt_pL_pdtheta1 = subs(d_dt_pL_pdtheta1, [ diff(theta1(t), t ) diff(theta2(t), t ) diff(theta3(t), t ), diff(dtheta1(t), t ) diff(dtheta2(t), t ) diff(dtheta3(t), t ) ], [ dtheta1 dtheta2 dtheta3 ddtheta1 ddtheta2 ddtheta3 ] );
d_dt_pL_pdtheta2 = subs(d_dt_pL_pdtheta2, [ diff(theta1(t), t ) diff(theta2(t), t ) diff(theta3(t), t ), diff(dtheta1(t), t ) diff(dtheta2(t), t ) diff(dtheta3(t), t ) ], [ dtheta1 dtheta2 dtheta3 ddtheta1 ddtheta2 ddtheta3 ] );
d_dt_pL_pdtheta3 = subs(d_dt_pL_pdtheta3, [ diff(theta1(t), t ) diff(theta2(t), t ) diff(theta3(t), t ), diff(dtheta1(t), t ) diff(dtheta2(t), t ) diff(dtheta3(t), t ) ], [ dtheta1 dtheta2 dtheta3 ddtheta1 ddtheta2 ddtheta3 ] );


% Create system of equations from Lagrangian derivations
eqx1 = simplify( d_dt_pL_pdtheta1 - pL_ptheta1 - P1);
eqx2 = simplify( d_dt_pL_pdtheta2 - pL_ptheta2 - P2);
eqx3 = simplify( d_dt_pL_pdtheta3 - pL_ptheta3 - P3);

% Substitute in state variables.
eqx1 = subs( eqx1, [ theta1 dtheta1 ddtheta1 theta2 dtheta2 ddtheta2 theta3 dtheta3 ddtheta3 ], [ u1 u2 du2 u3 u4 du4 u5 u6 du6 ] );
eqx2 = subs( eqx2, [ theta1 dtheta1 ddtheta1 theta2 dtheta2 ddtheta2 theta3 dtheta3 ddtheta3 ], [ u1 u2 du2 u3 u4 du4 u5 u6 du6 ] );
eqx3 = subs( eqx3, [ theta1 dtheta1 ddtheta1 theta2 dtheta2 ddtheta2 theta3 dtheta3 ddtheta3 ], [ u1 u2 du2 u3 u4 du4 u5 u6 du6 ] );

% Solve the system of equations for the relevant state variables.
Sol = solve( [ eqx1 eqx2 eqx3 ], [ du2 du4 du6 ] );
Sol.du2 = simplify(Sol.du2);
Sol.du4 = simplify(Sol.du4);
Sol.du6 = simplify(Sol.du6);

% Create necessary outputs
fx1 = Sol.du2;
fx2 = Sol.du4;
fx3 = Sol.du6;

% pause(1)

end