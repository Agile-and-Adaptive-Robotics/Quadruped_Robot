function MassM = mass(t,q,P)
%extracting Parameters
m1 = P.m1;
R1 = P.R1;
I1 = P.I1;
L1 = P.L1;

m2 = P.m2;
R2 = P.R2;
I2 = P.I2;
L2 = P.L1;

m3 = P.m3;
R3 = P.R3;
I3 = P.I3;
g = P.g;

%
MassM = zeros(6,6);
MassM(1,1) = 1;
MassM(2,2) = m1*R1^2 + m2*L1^2 + m3*L1^2 + I1 +m2*R2^2+m3*L2^2 +2*m2*L1*L2*sin(q(3)) + 2*m3*L1*L2*sin(q(3)) + 2*m3*L1*R3*sin(q(3)+q(5)) + 2*m3*L2*R3*sin(q(5)) + m3*R3^2;
MassM(2,4) = m3*L2^2 + m2*R2^2 + m2*L1*L2*sin(q(3)) + m3*L1*L2*sin(q(3)) + m3*L1*R3*sin(q(3) + q(5)) + 2*m3*L2*R3*sin(q(5)) + m3*R3^2;
MassM(2,6) = m3*L1*R3*sin(q(3) + q(5))+m3*R3^2 + 2*m3*L2*R3*sin(q(5));
MassM(3,3) = 1;
MassM(4,2) = m2*L1*L2*sin(q(3)) + m2*R2^2 + m3*L1*L2*sin(q(3)) + m3*L1*R3*sin(q(3) + q(5)) + m3*L2^2 + 2*L2*R3*sin(q(5)) + m3*R3^2;
MassM(4,4) = m2*R2^2 +m3*L2^2+2*R3*L2^2*sin(q(5))+m3*R3^2 + I2;
MassM(4,6) = L2*R3*sin(q(5)) + m3*R3^2;
MassM(5,5) = 1;
MassM(6,2) = m3*R3^2 + m3*L1*R3*sin( q(3)+q(5));
MassM(6,4) = m3*L2*R3*sin(q(5)) + m3*R3^2;
MassM(6,6) = m3*R3^2 + I3;

end