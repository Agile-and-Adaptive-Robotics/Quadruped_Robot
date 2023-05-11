function dy = Dynamic_code_Rat_complex(t,y,P,U)

y1 = y(1);
y2 = y(2);
y3 = y(3);
y4 = y(4);
y5 = y(5);
y6 = y(6);


M1=P(1);
R1=P(2);
I1=P(3);
L1=P(4);

M2=P(5);
R2=P(6);
I2=P(7);
L2=P(8);

M3=P(9);
R3=P(10);
I3=P(11);
L3=P(12);

g=P(13);

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

dy1 = y2;
dy2 = (-b1*y2 - u1*sign(y2) - K1*(theta1bias + y1) + M1*R1*g*cos(y1))/I1;
dy3 = 0;%y4;
dy4 = 0;%(K2*theta2bias + K2*y3 + b2*y4 - u2*sign(y4) - L2*M3*g*cos(y1 + y3) - M2*R2*g*cos(y1 + y3) + L1*L2*M3*sin(y3) + L1*M2*R2*sin(y3) - L1*M3*R3*sin(y3 - y5) + M3*R3*g*cos(y1 + y3 - y5))/I2;
dy5 = 0;%y6;
dy6 = 0;%(K3*theta3bias + K3*y5 + b3*y6 - u3*sign(y6) + L2*M3*R3*sin(y5) + L1*M3*R3*sin(y3 - y5) - M3*R3*g*cos(y1 + y3 - y5))/I3;
dy = [dy1 dy2 dy3 dy4 dy5 dy6]'; 
