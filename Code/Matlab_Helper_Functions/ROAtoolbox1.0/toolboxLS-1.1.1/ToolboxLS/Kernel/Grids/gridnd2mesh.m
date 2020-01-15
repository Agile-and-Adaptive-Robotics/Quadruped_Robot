function [ mesh_xs, varargout ] = gridnd2mesh(grid, varargin)
% gridnd2mesh: converts an ndgrid to a meshgrid, as well as associated data
%
%  [ mesh_xs, mesh_data1, mesh_data2 ... ] = ...
%                                 gridnd2mesh(grid, nd_data1, nd_data2, ...)
%
% The grid.xs member (which specifies the location of each node in the grid)
% is generated in ToolboxLS by processGrid using a call to ndgrid.  Such
% grids are incompatible with those generated by calls to meshgrid.  This
% routine converts from an ndgrid to a meshgrid.  The output of this routine
% is useful for 3D visualization calls such as slice, contourslice and
% isonormals, as well as interp2 and interp3.  Note however that all of the
% 2D visualization routines (eg contour, surf, mesh, ...), the 3D
% visualization routine isosurface, and the general dimensional interpn work
% just fine with grids generated by ndgrid, so they should be perferred to
% the conversion performed by this routine where possible.
%
% Input Parameters:
%
%   grid: A standard Toolbox grid structure.  It is the grid.xs member of
%   this structure which is converted into the mesh_xs output.
%
%   nd_data: Zero or more arrays of size grid.shape.  The same permutation
%   is performed on this arrays as is performed on the arrays defining the
%   node locations in the grid.xs cell vector.  Optional.
%
% Output Parameters:
%
%   mesh_xs: A cell vector whose elements would be the output of a call
%   to meshgrid for the set of nodes in the grid structure.
%
%   mesh_data: One array for each input array nd_data, each containing the
%   corresponding permuted data.

% Further comments: Matlab has two methods for generating the node locations
% in Cartesian grids: meshgrid and ndgrid.  Because Matlab's indexing is
% based on indexing into an array (rows/vertical, columns/horizontal) it
% does not agree with the traditional method of indexing into plots
% (x/horizontal, y/vertical).  Many Matlab visualization routines therefore
% assume that they need to swap the first two dimensions, and meshgrid
% builds a grid based on this assumption.  In constrast, ndgrid builds a
% grid without this implicit swap.
%
% This swapping procedure easily leads to inconsistencies when you are
% working with data external to Matlab, especially with higher dimensional
% data.  Therefore ToolboxLS chooses to use ndgrid exclusively.  So far, the
% only problem caused by this choice appears to be the fact that several 3D
% visualization routines require an input grid generated by meshgrid.  Users
% of the Toolbox may also have created their own routines which make this
% implicit dimension swap.
%
% Consequently, this routine is provided to perform the correct permutations
% to transform a grid from ndgrid (and its associated data) into a grid
% equivalent to that produced by meshgrid (and the same transform on the
% data).  Note that this permutation is a relatively expensive process, so
% it should not be invoked inside inner loops.

% Copyright 2007 Ian M. Mitchell (mitchell@cs.ubc.ca).
% This software is used, copied and distributed under the licensing 
%   agreement contained in the file LICENSE in the top directory of 
%   the distribution.
%
% Ian Mitchell, 5/17/07

  % No need to do anything to a 1D grid.
  if(grid.dim == 1)
    mesh_xs = grid.xs{1};
    varargout = varargin;
    return;
  end
  
  % Permutation to convert ndgrid to meshgrid.
  perm = [ 2, 1, 3 : grid.dim ];

  % Permute the node location cell vector.
  mesh_xs = cell(grid.dim, 1);
  for d = 1 : grid.dim
    mesh_xs{d} = permute(grid.xs{d}, perm);
  end
  
  % No point in permuting more input arguments than there are output
  % arguments.
  n_data_out = min(nargin - 1, nargout - 1);
  varargout = cell(n_data_out, 1);

  % Permute the data arrays.
  for i = 1 : n_data_out
    varargout{i} = permute(varargin{i}, perm);
  end
