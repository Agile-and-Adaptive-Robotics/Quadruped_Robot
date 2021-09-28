function dy = Dynamic_code2(t,y,P,U)

y1 = y(1);
y2 = y(2);
y3 = y(3);
y4 = y(4);


M1=P(1);
R1=P(2);
I1=P(3);
L1=P(4);

M2=P(5);
R2=P(6);
I2=P(7);
L2=P(8);
g=P(9);

b1 = U(1); 
b2 = U(2);
K1 = U(3);
K2 = U(4);
theta1bias = U(5);
theta2bias = U(6);

u1 = 0.1;
N1 = 1000;
u2 = 0.1;
N2 = 1000;

b4 = 0;
b5 = 0;
K4 = 0;
K5 = 0;
theta4bias = 0;
theta5bias = 0;
%b4 = U(10); 
%b5 = U(11);
%b6 = U(12);
%K4 = U(13);
%K5 = U(14);
%K6 = U(15); 
%theta4bias = U(16);
%theta5bias = U(17);
%theta6bias = U(18);


dy1 = y2;
dy2 = (I2*K1*theta1bias + I2*K4*theta4bias + I2*K1*y1 + I2*K4*y1 + I2*b1*y2 + I2*b4*y2 + K1*M2*R2^2*theta1bias - K2*M2*R2^2*theta2bias + K4*M2*R2^2*theta4bias - K5*M2*R2^2*theta5bias + K1*M2*R2^2*y1 - K2*M2*R2^2*y3 + K4*M2*R2^2*y1 - K5*M2*R2^2*y1 + M2*R2^2*b1*y2 - M2*R2^2*b2*y4 + M2*R2^2*b4*y2 - M2*R2^2*b5*y2 + I2*N1*u1*sin(y2) + M2*N1*R2^2*u1*sin(y2) - M2*N2*R2^2*u2*sin(y4) - L1*M2^2*R2^2*g*cos(y1) - I2*M2*R2*g*cos(y1 + y3) - I2*L1*M2*g*cos(y1) - I2*M1*R1*g*cos(y1) + (L1^2*M2^2*R2^2*y2^2*sin(2*y3))/2 + L1*M2^2*R2^3*y2^2*sin(y3) + L1*M2^2*R2^3*y4^2*sin(y3) + L1*M2^2*R2^2*g*cos(y1 + y3)*cos(y3) - L1*M2*R2*b2*y4*cos(y3) - L1*M2*R2*b5*y2*cos(y3) - M1*M2*R1*R2^2*g*cos(y1) + I2*L1*M2*R2*y4^2*sin(y3) - K2*L1*M2*R2*theta2bias*cos(y3) - K5*L1*M2*R2*theta5bias*cos(y3) + 2*L1*M2^2*R2^3*y2*y4*sin(y3) - K2*L1*M2*R2*y3*cos(y3) - K5*L1*M2*R2*y1*cos(y3) + 2*I2*L1*M2*R2*y2*y4*sin(y3) - L1*M2*N2*R2*u2*cos(y3)*sin(y4))/(I1*I2 + L1^2*M2^2*R2^2 + I2*L1^2*M2 + I2*M1*R1^2 + I1*M2*R2^2 + I2*M2*R2^2 + M1*M2*R1^2*R2^2 - L1^2*M2^2*R2^2*cos(y3)^2 + 2*I2*L1*M2*R2*cos(y3));
dy3 = y4;
dy4 = (I1*K2*theta2bias + I1*K5*theta5bias + I1*K2*y3 + I1*K5*y1 + I1*b2*y4 + I1*b5*y2 + K2*L1^2*M2*theta2bias + K5*L1^2*M2*theta5bias + K2*L1^2*M2*y3 + K5*L1^2*M2*y1 - K1*M2*R2^2*theta1bias + K2*M1*R1^2*theta2bias + K2*M2*R2^2*theta2bias - K4*M2*R2^2*theta4bias + K5*M1*R1^2*theta5bias + K5*M2*R2^2*theta5bias - K1*M2*R2^2*y1 + K2*M1*R1^2*y3 + K5*M1*R1^2*y1 + K2*M2*R2^2*y3 - K4*M2*R2^2*y1 + K5*M2*R2^2*y1 + L1^2*M2*b2*y4 + L1^2*M2*b5*y2 - M2*R2^2*b1*y2 + M1*R1^2*b2*y4 + M1*R1^2*b5*y2 + M2*R2^2*b2*y4 - M2*R2^2*b4*y2 + M2*R2^2*b5*y2 + I1*N2*u2*sin(y4) + L1^2*M2*N2*u2*sin(y4) - M2*N1*R2^2*u1*sin(y2) + M1*N2*R1^2*u2*sin(y4) + M2*N2*R2^2*u2*sin(y4) - L1^2*M2^2*R2*g*cos(y1 + y3) + L1*M2^2*R2^2*g*cos(y1) - I1*M2*R2*g*cos(y1 + y3) - L1^2*M2^2*R2^2*y2^2*sin(2*y3) - (L1^2*M2^2*R2^2*y4^2*sin(2*y3))/2 - L1*M2^2*R2^3*y2^2*sin(y3) - L1^3*M2^2*R2*y2^2*sin(y3) - L1*M2^2*R2^3*y4^2*sin(y3) - L1*M2^2*R2^2*g*cos(y1 + y3)*cos(y3) - L1*M2*R2*b1*y2*cos(y3) + 2*L1*M2*R2*b2*y4*cos(y3) - L1*M2*R2*b4*y2*cos(y3) + 2*L1*M2*R2*b5*y2*cos(y3) - M1*M2*R1^2*R2*g*cos(y1 + y3) + L1^2*M2^2*R2*g*cos(y1)*cos(y3) + M1*M2*R1*R2^2*g*cos(y1) - I1*L1*M2*R2*y2^2*sin(y3) - L1^2*M2^2*R2^2*y2*y4*sin(2*y3) - K1*L1*M2*R2*theta1bias*cos(y3) + 2*K2*L1*M2*R2*theta2bias*cos(y3) - K4*L1*M2*R2*theta4bias*cos(y3) + 2*K5*L1*M2*R2*theta5bias*cos(y3) - 2*L1*M2^2*R2^3*y2*y4*sin(y3) - K1*L1*M2*R2*y1*cos(y3) + 2*K2*L1*M2*R2*y3*cos(y3) - K4*L1*M2*R2*y1*cos(y3) + 2*K5*L1*M2*R2*y1*cos(y3) - L1*M1*M2*R1^2*R2*y2^2*sin(y3) - L1*M2*N1*R2*u1*cos(y3)*sin(y2) + 2*L1*M2*N2*R2*u2*cos(y3)*sin(y4) + L1*M1*M2*R1*R2*g*cos(y1)*cos(y3))/(I1*I2 + L1^2*M2^2*R2^2 + I2*L1^2*M2 + I2*M1*R1^2 + I1*M2*R2^2 + I2*M2*R2^2 + M1*M2*R1^2*R2^2 - L1^2*M2^2*R2^2*cos(y3)^2 + 2*I2*L1*M2*R2*cos(y3));
dy = [dy1 dy2 dy3 dy4]'; 