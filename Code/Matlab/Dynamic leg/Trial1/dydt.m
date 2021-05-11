function dydt = f(t,q)


dydt = [q(2)  
        (m1*g*R1*sin(q(1))+m2*g*L1*sin(q(1))+m2*g*R3*sin(q(1)+q(3))+m3*g*L1*sin(q(1))+m3*g*L2*sin(q(1)+q(3))+R3*m3*g*sin(q(1)+q(3)+q(5))) 
        q(4) 
        (m2*L1*L2*sin(q(1) +q(2))+m3*L1*L2*sin(q(1)) -m3*L1*R3*sin(q(3)+q(5)) -m2*g*R2*sin(q(1) +q(3))-m3*g*L2*sin(q(1)+q(3)) -m3*g*R3*sin(q(1)+q(3)+q(5)) )
        q(6) 
        (+m3*L2*R3*sin(q(5))+m3*g*R3*sin(q(1) + q(3) +q(5)))];
end