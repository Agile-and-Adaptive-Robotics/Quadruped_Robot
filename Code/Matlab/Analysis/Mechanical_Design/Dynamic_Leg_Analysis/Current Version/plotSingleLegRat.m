function plotSingleLegRat(Leg,Lengths)
L1 = Lengths(1);
L2 = Lengths(2);
L3 = Lengths(3);
N = Lengths(4);

px=[0 0 0 0];
py=[0 0 0 0];

figure; hold on;
h = plot(px,py,'ro-'); 

axis([-(L1+L2+L3+4) (L1+L2+L3+4) -(L1+L2+L3+4) (L1+L2+L3+4)]);

for i=1:N-1
 
            x1=Leg(i,1);
            x2=Leg(i,3);
            x3=Leg(i,5);
            p0x=0;
            p0y=0;
            p1x = L1*cos(x1);
            p1y = -L1*sin(x1);
            p2x = L1*cos(x1)+L2*cos(x1+x2);
            p2y = -(L1*sin(x1)+L2*sin(x1+x2));
            p3x = L1*cos(x1)+L2*cos(x1+x2)+L3*cos(x1+x2+x3);
            p3y = -(L1*sin(x1)+L2*sin(x1+x2)+L3*sin(x1+x2+x3));
            px=[p0x p1x p2x p3x];
            py=[p0y p1y p2y p3y];
            
            h.XData = px;
            h.YData = py;
            
            drawnow
            pause(0.001);

       
end

end