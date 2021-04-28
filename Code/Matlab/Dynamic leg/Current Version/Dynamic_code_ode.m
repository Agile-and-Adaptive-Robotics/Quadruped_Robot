function dy = Dynamic_code_ode(t,y,P)


y1 = y(1);
y2 = y(2);
y3 = y(3);
y4 = y(4);
y5 = y(5);
y6 = y(6);
%{ 
L1=P.L1;
L2=P.L2;
L3=P.L3;
M1=P.M1;
M2=P.M2;
M3=P.M3;
g=P.g;
%}
b1=0; b2 = 0;b3 =0;K1 = 0;K2=0;K3 = 0; theta1bias=0;theta2bias = 0;theta3bias = 0;
u1 = b1*y2+K1*(y1+theta1bias);
u2 = b2*y4+K2*(y3+theta2bias);
u3= b3*y6+K3*(y5+theta3bias);

%u=[u1 u2 u3]';
u = [0 0 0]';
dy = Dynamic_code(y,u,P);