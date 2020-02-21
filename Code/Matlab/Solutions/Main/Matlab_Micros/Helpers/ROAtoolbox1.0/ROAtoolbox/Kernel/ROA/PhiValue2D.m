function [meshxs, meshPhi] = PhiValue2D(projectoptions, fdata)
% Draw the level set function phi.
% Since toolboxLS-1.1.1 uses ndgrid, one should transfer the grid to 
%   mexhgrid-based array.
% Parameters:
%   projectoptions  Project Options for ROAtoolbox
%   fdata        array contains the function value on the grid.
%
% YUAN Guoqiang, Oct, 2016
%

g = projectoptions.Grid;
VF = projectoptions.VectorField;
[meshxs, meshPhi, U, V] = gridnd2mesh(g, fdata, VF{:});
figure
sty = {'EdgeColor', 'none'};

surface(meshxs{:}, meshPhi, sty{:});
% shading interp
% colormap jet
colormap summer
colorbar
hold on
% camlight

[~, ch] = contour3(meshxs{:}, meshPhi, [0, 0], 'r'); 
set(ch,'LineWidth', 2);

h = streamslice(meshxs{:}, U, V, 0.4); 
set(h,'color','b')
for i=1:length(h); 
 Xq = get(h(i), 'xdata');
 Yq = get(h(i), 'ydata');
 Vq = interp2(meshxs{:}, meshPhi, Xq, Yq);
 set(h(i),'zdata', Vq);
end

xlabel('x_1'); ylabel('x_2'); zlabel('\phi(x,t)');
% legend('\phi(x,t)', 'contour')

