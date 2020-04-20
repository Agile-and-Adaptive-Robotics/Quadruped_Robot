%% Muscle Attachment Point Definition

%Clear Everything
clear, close('all'), clc

%% Test Matlab Functionality.

xs_joint_animatlab = 254.01e-3;
ys_joint_animatlab = -22e-3;
zs_joint_animatlab = -66.5e-3;
Ps_joint_animatlab = [xs_joint_animatlab; ys_joint_animatlab; zs_joint_animatlab];

xs_hipext_animatlab = -[169.1e-3, -169.1e-3, -244.51e-3];
ys_hipext_animatlab = [-33.1e-3, -33.1e-3, -9.298e-3];
zs_hipext_animatlab = [-66.5e-3, -66.5e-3, -66.5e-3];
Ps_hipext_animatlab = [xs_hipext_animatlab; ys_hipext_animatlab; zs_hipext_animatlab];

xs_hipflx_animatlab = -[169.1e-3, -169.1e-3, -244.51e-3];
ys_hipflx_animatlab = [-10.9e-3, -10.9e-3, -34.698e-3];
zs_hipflx_animatlab = [-66.5e-3, -66.5e-3, -66.5e-3];
Ps_hipflx_animatlab = [xs_hipflx_animatlab; ys_hipflx_animatlab; zs_hipflx_animatlab];

xs_kneeext_animatlab = -[-235.02e-3, -234.98e-3, -239.69e-3];
ys_kneeext_animatlab = [47.104e-3, -178.2e-3, -194.2e-3];
zs_kneeext_animatlab = [-66.5e-3, -66.5e-3, -66.5e-3];
Ps_kneeext_animatlab = [xs_kneeext_animatlab; ys_kneeext_animatlab; zs_kneeext_animatlab];

xs_kneeflx_animatlab = -[-273.02e-3, -272.98e-3, -253.97e-3];
ys_kneeflx_animatlab = [47.096e-3, -178.2e-3, -206.1e-3];
zs_kneeflx_animatlab = [-66.5e-3, -66.5e-3, -66.5e-3];
Ps_kneeflx_animatlab = [xs_kneeflx_animatlab; ys_kneeflx_animatlab; zs_kneeflx_animatlab];

xs_ankleext_animatlab = -[-272.97e-3, -272.93e-3, -268.22e-3];
ys_ankleext_animatlab = [-224.2e-3, -388.2e-3, -405e-3];
zs_ankleext_animatlab = [-66.5e-3, -66.5e-3, -66.5e-3];
Ps_ankleext_animatlab = [xs_ankleext_animatlab; ys_ankleext_animatlab; zs_ankleext_animatlab];

xs_ankleflx_animatlab = -[-234.97e-3, -234.93e-3, -253.93e-3];
ys_ankleflx_animatlab = [-201.3e-3, -388.2e-3, -416.1e-3];
zs_ankleflx_animatlab = [-66.5e-3, -66.5e-3, -66.5e-3];
Ps_ankleflx_animatlab = [xs_ankleflx_animatlab; ys_ankleflx_animatlab; zs_ankleflx_animatlab];

Ps_joint = Ps_joint_animatlab - Ps_joint_animatlab;
Ps_hipext = Ps_hipext_animatlab - Ps_joint_animatlab;
Ps_hipflx = Ps_hipflx_animatlab - Ps_joint_animatlab;
Ps_kneeext = Ps_kneeext_animatlab - Ps_joint_animatlab;
Ps_kneeflx = Ps_kneeflx_animatlab - Ps_joint_animatlab;
Ps_ankleext = Ps_ankleext_animatlab - Ps_joint_animatlab;
Ps_ankleflx = Ps_ankleflx_animatlab - Ps_joint_animatlab;

theta = 90*(pi/180);
R = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];

Ps_hipext(:, end) = R*Ps_hipext(:, end);
Ps_hipflx(:, end) = R*Ps_hipflx(:, end);
Ps_kneeext = R*Ps_kneeext;
Ps_kneeflx = R*Ps_kneeflx;
Ps_ankleext = R*Ps_ankleext;
Ps_ankleflx = R*Ps_ankleflx;

dlmwrite('C:\Users\USER\Documents\Graduate_School\Coursework\Year3\Spring2020\ME610_NeuromechanicalModeling\Project\Joint_Position_Control\Ps_hipext.txt', Ps_hipext)
dlmwrite('C:\Users\USER\Documents\Graduate_School\Coursework\Year3\Spring2020\ME610_NeuromechanicalModeling\Project\Joint_Position_Control\Ps_hipflx.txt', Ps_hipflx)

dlmwrite('C:\Users\USER\Documents\Graduate_School\Coursework\Year3\Spring2020\ME610_NeuromechanicalModeling\Project\Joint_Position_Control\Ps_kneeext.txt', Ps_kneeext)
dlmwrite('C:\Users\USER\Documents\Graduate_School\Coursework\Year3\Spring2020\ME610_NeuromechanicalModeling\Project\Joint_Position_Control\Ps_kneeflx.txt', Ps_kneeflx)

dlmwrite('C:\Users\USER\Documents\Graduate_School\Coursework\Year3\Spring2020\ME610_NeuromechanicalModeling\Project\Joint_Position_Control\Ps_ankleext.txt', Ps_ankleext)
dlmwrite('C:\Users\USER\Documents\Graduate_School\Coursework\Year3\Spring2020\ME610_NeuromechanicalModeling\Project\Joint_Position_Control\Ps_ankleflx.txt', Ps_ankleflx)


figure('Color', 'w', 'Name', 'Muscle Arrangement'), hold on, grid on, rotate3d on, xlabel('x'), ylabel('y'), zlabel('z'), axis equal
plot3(Ps_joint(1, :), Ps_joint(2, :), Ps_joint(3, :), '.', 'Markersize', 20)
plot3(Ps_hipext(1, :), Ps_hipext(2, :), Ps_hipext(3, :), '.-', 'Markersize', 20)
plot3(Ps_hipflx(1, :), Ps_hipflx(2, :), Ps_hipflx(3, :), '.-', 'Markersize', 20)
plot3(Ps_kneeext(1, :), Ps_kneeext(2, :), Ps_kneeext(3, :), '.-', 'Markersize', 20)
plot3(Ps_kneeflx(1, :), Ps_kneeflx(2, :), Ps_kneeflx(3, :), '.-', 'Markersize', 20)
plot3(Ps_ankleext(1, :), Ps_ankleext(2, :), Ps_ankleext(3, :), '.-', 'Markersize', 20)
plot3(Ps_ankleflx(1, :), Ps_ankleflx(2, :), Ps_ankleflx(3, :), '.-', 'Markersize', 20)

