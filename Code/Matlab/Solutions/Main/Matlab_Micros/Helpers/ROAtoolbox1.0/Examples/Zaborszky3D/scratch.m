
set(0,'defaultfigurecolor', 'w');
load('phi_t.mat')
ProjectOptions = SetProjectOptions();
g = ProjectOptions.Grid;
VF = ProjectOptions.VectorField;
figure
sty = {'k'; 'LineWidth'; 2};
plot3([0, 0], [0, 0],[0.5 ,3], sty{:})
hold on
xa = [0; 0;  -3];
[t, x] = Trajectory(ProjectOptions, [0.001; 0; -2.999], [0 -100]);
plot3(x(:, 1), x(:, 2),x(:, 3), sty{:});
hold on
[t, x] = Trajectory(ProjectOptions, [-0.001; 0; -2.999], [0 -100]);
plot3(x(:, 1), x(:, 2),x(:, 3), sty{:});

[meshxs, meshPhi] = gridnd2mesh(g, phi_t{end,1});
ch = contourslice(meshxs{:}, meshPhi, [], 0, [], [0, 0]);
set(ch,'edgecolor','r', 'LineWidth', 2);

[meshxs, meshPhi] = gridnd2mesh(g, phi_t{1,1});
ch = contourslice(meshxs{:}, meshPhi, [], 0, [], [0, 0]);
set(ch,'edgecolor','r', 'LineWidth', 2);

[meshxs, meshPhi] = gridnd2mesh(g, phi_t{3,1});
ch = contourslice(meshxs{:}, meshPhi, [], 0, [], [0, 0]);
set(ch,'edgecolor','r', 'LineWidth', 2);

[meshxs, meshPhi] = gridnd2mesh(g, phi_t{5,1});
ch = contourslice(meshxs{:}, meshPhi, [], 0, [], [0, 0]);
set(ch,'edgecolor','r', 'LineWidth', 2);

axis equal
axis([-3, 3, -3, 3, -3, 3])
grid on
box on
xlabel('x_1');
ylabel('x_2');
zlabel('x_3');