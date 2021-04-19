function dy = Dynamic_code_ode(t,y)

y1 = y(1);
y2 = y(2);
y3 = y(3);
y4 = y(4);
y5 = y(5);
y6 = y(6);

L1=1;
L2=1;
L3=1;
M1=1;
M2=1;
M3=1;
g=9.8;


u=[0 0 0]';
dy = Dynamic_code(y,u);