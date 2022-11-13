function dy = Dynamic_code_Rat_complex_3dof(t,y,P,U, fx1, fx2, fx3)

u1 = y(1);
u2 = y(2);
u3 = y(3);
u4 = y(4);
u5 = y(5);
u6 = y(6);


M1=P(1);
R1=P(2);
L1=P(3);

M2=P(4);
R2=P(5);
L2=P(6);

M3=P(7);
R3=P(8);
L3=P(9);

g=P(10);

b1 = U(1); 
b2 = U(2);
b3 = U(3);
K1 = U(4);
K2 = U(5);
K3 = U(6); 
% theta1bias = -1.939;
% theta2bias = 1.1258;
% theta3bias = -0.7945;
theta1bias = 0;
theta2bias = 0;
theta3bias = 0;

u1 = U(7);
u2 = U(8);
u3 = U(9);

b4 = 0;
b5 = 0;
b6 = 0;
K4 = 0;
K5 = 0;
K6 = 0; 
theta4bias = 0;
theta5bias = 0;
theta6bias = 0;

dy1 = double(subs(u2));
dy2 = double(subs(fx1));
dy3 = double(subs(u4));
dy4 = double(subs(fx2));
dy5 = double(subs(u6));
dy6 = double(subs(fx3));
dy = [dy1 dy2 dy3 dy4 dy5 dy6]'; 

