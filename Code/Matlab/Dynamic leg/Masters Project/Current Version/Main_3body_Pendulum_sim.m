clear;close all;clc;

init_t=0;
final_t=10;
dt=0.001;
N= (final_t-init_t)/dt;
t_span=linspace(init_t,final_t,N);

x0=[0 0 0 0 0 0]';

x=zeros(6,N);
x(:,1)=x0;

[t,y] = ode45(@Dynamic_code_ode,t_span,x0);


L1=1;
L2=1;
L3=1;
M1=1;
M2=1;
M3=1;
g=9.8;

x=y;

mov_cnt = 1;
figure; hold on;
for i=1:N-1
    if(mod(i,50)==1)
        clf;
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
        plot(px,py,'ro-');
        axis([-4 4 -4 4]);
        pause(0.001);
        MM(mov_cnt)=getframe;
        mov_cnt=mov_cnt+1;
    end
end

movie(MM)
