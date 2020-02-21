function hs = Boundaries(ProjectOptions, phis)
% Draw the boundaries for each period.
% Since toolboxLS-1.1.1 uses ndgrid, one should transfer the grid to 
%   mexhgrid-based array.
% Parameters:
%   ProjectOptions  Project Options for ROAtoolbox
%   phis        boundary you want to show
%   hs    the handles of boundaries
%
% YUAN Guoqiang, Oct, 2016
%

level = 0;
g = ProjectOptions.Grid;
cnt = length(phis);
hs = cell(cnt, 1);
fig = figure;
hold on

for ii = 1:cnt
    hs{ii} = Boundary(g, phis{ii}, fig, level);
end

function  h = Boundary(g, data, fig, level)

switch(g.dim)    
   case 1
      figure(fig);
      if(g.N < 20)
        % For very coarse grids, we can identify the individual nodes.
        h = plot(g.xs{1}, data, 'r-+');
      else
        h = plot(g.xs{1}, data, 'r-');
      end

   case 2
       figure(fig);
       [ mesh_xs, mesh_data ] = gridnd2mesh(g, data); 
       sty = {'r'; 'LineWidth'; 2};
       [ ~, h ] = contour(mesh_xs{:}, mesh_data, [level, level], sty{:});
       xlabel('x_1'); ylabel('x_2'); 
       axis square;  axis manual;

   case 3
      figure(fig);
      [ mesh_xs, mesh_data ] = gridnd2mesh(g, data); 
      h = patch(isosurface(mesh_xs{:}, mesh_data, level));
      isonormals(mesh_xs{:}, mesh_data, h);
      set(h, 'FaceColor', 'red', 'EdgeColor', 'none');
      lighting phong;
      xlabel('x_1'); ylabel('x_2'); zlabel('x_3');
      view(3)    

   otherwise
    warning('Unable to display data in dimension %d', g.dim); 
end