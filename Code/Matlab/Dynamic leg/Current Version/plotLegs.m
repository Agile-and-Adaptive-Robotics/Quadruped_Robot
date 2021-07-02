function plotLegs(x,e,Lengths)
L1 = Lengths(1);
L2 = Lengths(2);
L3 = Lengths(3);
N = Lengths(4);

px=[0 0 0 0];
py=[0 0 0 0];

ex = [0 0 0 0];
ey = [0 0 0 0];

figure; hold on;
h = plot(px,py,'ro-');      
z = plot(ex,ey,'bo-');
legend('Optimized Model', 'Muscle Mutt Data');

axis([-(L1+L2+L3+4) (L1+L2+L3+4) -(L1+L2+L3+4) (L1+L2+L3+4)]);

    for i=1:N-1
        if(mod(i,50)==1)
            x1=x(i,1);
            x2=x(i,3);
            x3=x(i,5);
            p0x=0;
            p0y=0;
            p1x = L1*cos(x1);
            p1y = L1*sin(x1);
            p2x = L1*cos(x1)+L2*cos(x1+x2);
            p2y = L1*sin(x1)+L2*sin(x1+x2);
            p3x = L1*cos(x1)+L2*cos(x1+x2)+L3*cos(x1+x2+x3);
            p3y = L1*sin(x1)+L2*sin(x1+x2)+L3*sin(x1+x2+x3);
            px=[p0x p1x p2x p3x];
            py=[p0y p1y p2y p3y];

            %Optimized Joint positions
            e1=e(i,1);
            e2=e(i,2);
            e3=e(i,3);
            e0x=0;
            e0y=0;
            e1x = L1*cos(e1);
            e1y = L1*sin(e1);
            e2x = L1*cos(e1)+L2*cos(e1+e2);
            e2y = L1*sin(e1)+L2*sin(e1+e2);
            e3x = L1*cos(e1)+L2*cos(e1+e2)+L3*cos(e1+e2+e3);
            e3y = L1*sin(e1)+L2*sin(e1+e2)+L3*sin(e1+e2+e3);
            ex=[e0x e1x e2x e3x];
            ey=[e0y e1y e2y e3y];

            h.XData = px;
            h.YData = py;
            z.XData = ex;
            z.YData = ey;

            drawnow
            pause(0.001);

        end
    end
end