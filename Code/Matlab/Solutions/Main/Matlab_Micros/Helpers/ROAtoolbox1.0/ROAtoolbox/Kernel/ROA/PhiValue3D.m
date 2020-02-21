function [meshxs, meshPhi] = PhiValue3D(projectoptions, fdata)
% Draw the implicit function phi.
% Since toolboxLS-1.1.1 uses ndgrid, one should transfer the grid to 
%   mexhgrid-based array.
% Parameters:
%   projectoptions  Project Options for ROAtoolbox
%   fdata        array contains the function value on the grid.
%
% YUAN Guoqiang, Oct, 2016
%

g = projectoptions.Grid;
sep = projectoptions.InitCircleCen;

[meshxs, meshPhi] = gridnd2mesh(g, fdata);
% [meshX2, meshY2, meshZ2, meshPhi2] = subvolume( meshxs{:}, meshPhi, ...
%                                                                         [sep(1),nan, sep(2),nan, nan,sep(3)]);
[meshX2, meshY2, meshZ2, meshPhi2] = subvolume( meshxs{:}, meshPhi, ...
                                                                        [sep(1),nan, sep(2),nan, sep(3), nan]);

meshxs2 = {meshX2; meshY2; meshZ2};                                                                    
figure
v = min(meshPhi2(:));
patch(isocaps(meshxs2{:}, meshPhi2, v),...
   'FaceColor','interp','EdgeColor','none');
hold on
p1 = patch(isosurface(meshxs2{:}, meshPhi2, v),...
        'FaceColor','blue','EdgeColor','none');
isonormals(meshxs2{:}, meshPhi2, p1); 
colormap summer
colorbar
view(-30,22); 
axis vis3d tight
% lighting phong

ch = contourslice(meshxs2{:}, meshPhi2, sep(1), [], [], [0, 0]);
set(ch,'edgecolor','r', 'LineWidth', 2);
ch = contourslice(meshxs2{:}, meshPhi2, [], sep(2), [], [0, 0]);
set(ch,'edgecolor','r', 'LineWidth', 2);
ch = contourslice(meshxs2{:}, meshPhi2, [], [], sep(3), [0, 0]);
set(ch,'edgecolor','r', 'LineWidth', 2);

fx = projectoptions.VectorFieldOperator;
VF = fx( meshxs2 );

% Set the density of streamlines
density = 0.2;
h = streamslice(meshxs2{:}, VF{:}, sep(1), [], [], density);
%set(h,'color','r');
h = streamslice(meshxs2{:}, VF{:}, [], sep(2), [], density);
%set(h,'color','r');
h = streamslice(meshxs2{:}, VF{:}, [], [], sep(3), density);
%set(h,'color','r');

xlabel('x_1'); ylabel('x_2'); zlabel('x_3');
% legend('\phi(x,t)', 'contour')
camlight(-30, 22);
