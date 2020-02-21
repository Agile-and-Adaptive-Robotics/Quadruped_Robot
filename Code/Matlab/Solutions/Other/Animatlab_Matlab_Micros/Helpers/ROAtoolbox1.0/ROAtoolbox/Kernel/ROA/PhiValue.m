function [meshxs, meshPhi] = PhiValue(ProjectOptions, data)

switch(ProjectOptions.Grid.dim)
 case 2
    % 2D.    
    [meshxs, meshPhi] = PhiValue2D(ProjectOptions, data);
 case 3
    % 3D.
    [meshxs, meshPhi] = PhiValue3D(ProjectOptions, data);
  otherwise
    error('Can not draw phi for system with dimention: %s!', g.dim);
end
