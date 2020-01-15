function drawArrow2D(pos,dir,sz)
% pos for position [x y] of the arrow head!!!
% dir for direction [u v]
% size for the scale of the arrow
% body determine whether draw the body of not
% by Guoqiang Yuan
% Sep 2015
%

% len = norm(dir);
% k = size/len;
% tx = pos(1) - k*dir(1);
% ty = pos(2) - k*dir(2);
% plot([pos(1) tx],[pos(2) ty],'k');

headleny = sz/2;
ratio = get(gca,'DataAspectRatio');
kxy = ratio(2)/ratio(1);% x axis elongation
headlenx = headleny / kxy;

theta = atan(dir(2)/dir(1)/kxy);
if dir(1)<0
    theta = theta+pi;
end
theta = theta+pi;

tt = theta-pi/9;
hx = pos(1)+headlenx*cos(tt);
hy = pos(2)+headleny*sin(tt);
plot([pos(1) hx],[pos(2) hy],'k');

tt = theta+pi/9;
hx = pos(1)+headlenx*cos(tt);
hy = pos(2)+headleny*sin(tt);
plot([pos(1) hx],[pos(2) hy],'k');