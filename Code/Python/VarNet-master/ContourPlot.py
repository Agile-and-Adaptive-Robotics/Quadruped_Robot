# -*- coding: utf-8 -*-
"""
Created on Fri Aug 31 17:04:47 2018

-------------------------------------------------------------------------------
=============================== VarNet Library ================================
-------------------------------------------------------------------------------

Authors: Reza Khodayi-mehr and Michael M Zavlanos
reza.khodayi.mehr@duke.edu
http://people.duke.edu/~rk157/
Department of Mechanical Engineering and Materials Science,
Duke University, Durham, NC 27708, USA.

Copyright (c) 2019 Reza Khodayi-mehr - licensed under the MIT License
For a full copyright statement see the accompanying LICENSE.md file.
    
For theoretical derivations as well as numerical experiment results, see:
Reza Khodayi-mehr and Michael M Zavlanos. VarNet: Variational neural networks
for the solution of partial differential equations, 2019.
https://arxiv.org/pdf/1912.07443.pdf

To examine the functionalities of the VarNet library, see the acompanying 
Operater files.

The code is fully functional with the following module versions:
    - tensorflow: 1.10.0
    - numpy: 1.16.4
    - scipy: 1.2.1
    - matplotlib: 3.0.3

-------------------------------------------------------------------------------
This file provides the classes for 2D contour plotting.

"""

# ------------------------------------------------------------ IMPORT NECESSARY LIBRARIES ------------------------------------------------------------

# Import the necessary libraries.
import numpy as np
import matplotlib.pyplot as plt
from UtilityFunc import UF

# Create aliases for common functions.
shape = np.shape
reshape = np.reshape
size = np.size
uf = UF()


# ------------------------------------------------------------ CONTOUR PLOT CLASS ------------------------------------------------------------

class ContourPlot():

    """Class to plot the contours of a given function."""
    
    def __init__(self, domain, tInterval=None, discNum=51):

        """
        Initializer for the contour plot.
        
        Inputs:
            domain: an insatnce of Domain class containing domain information.
            tInterval [1x2]: time interval (default: time-independent)
            discNum: number of spatial discretization points
        
        Attributes:
            status: status of the problem whose plots are requested:
                '1D-time': 1D time-dependent problem
                '2D': 2D time-independent problem
                '2D-time': 2D time-dependent problem
            isOutside: True for points that do not lie inside domain
            x_coord: 1D discretization of the x-ccordinate
            y_coord: 1D discretization of the y-ccordinate
            X_coord: x-ccordinate of the meshgrid stacked in a column
            Y_coord: y-ccordinate of the meshgrid stacked in a column
                (y-coordinate may refer to time or 2nd coordinate in 2D problems)
            xx: x-coordinate in meshgrid format
            yy: y-coordinate in meshgrid format
        """

        # Retrieve domain information.
        dim = domain.dim
        lim = domain.lim

        # Compute the spatial step size.
        hx = (lim[1, 0] - lim[0, 0])/(discNum-1)                              # element size

        # Create the spatial discretization.
        x_coord = np.linspace(lim[0, 0], lim[1, 0], discNum)                  # x-discretization

        # Determine how to process any additional dimensions.
        if dim == 1 and uf.isnone(tInterval):                                   # If this problem is 1D and time-independent...

            # Throw an error.
            raise ValueError('contour plot unavailable for 1D, time-independent problems!')

        elif dim == 1:                                                          # If this problem is one dimensional and time dependent...

            # Set the status of this problem to be 1D time-dependent.
            status = '1D-time'

            # Compute the time step size.
            hy = (tInterval[1] - tInterval[0])/(discNum-1)                  # element size

            # Generate the y coordinate.
            y_coord = np.linspace(tInterval[0], tInterval[1], discNum)      # t-discretization

        # Determine how to handle additional dimensions if this is a 2D problem.
        if dim == 2:                                                        # If this problem is 2D...

            # Compute the y step size.
            hy = (lim[1, 1] - lim[0, 1])/(discNum-1)                          # element size

            # Generate the y discretization.
            y_coord = np.linspace(lim[0, 1], lim[1, 1], discNum)              # y-discretization

            # Determine how to set the status for this problem.
            if uf.isnone(tInterval):                                        # If no time interval was provided...

                # Set the status to be 2D time independent.
                status = '2D'

            else:                                                           # Otherwise...

                # Set the status to be 2D time dependent.
                status = '2D-time'
        
        # Mesh the input coordinates.
        xx, yy = np.meshgrid(x_coord, y_coord, sparse=False)
        
        # Generate the input coordinates.
        X_coord = np.tile(x_coord, discNum)                                 # copy for y
        X_coord = reshape(X_coord, [len(X_coord), 1])
        Y_coord = np.repeat(y_coord, discNum)                               # copy for x
        Y_coord = reshape(Y_coord, [len(Y_coord), 1])
             
        # Determine the points that lie outside the domain.
        if status == '1D-time':                                             # If the problem is 1D and time-dependent...

            # Set the outside locations to be all zeros.
            isOutside = np.zeros(discNum**2, dtype=bool)

        else:

            # Create the field inputs.
            Input = np.concatenate([X_coord, Y_coord], axis=1)

            # Determine whether the field inputs are inside the domain.
            isOutside = np.logical_not(domain.isInside(Input))
        
        # Store relevant data.
        self.status = status
        self.discNum = discNum
        self.tInterval = tInterval
        self.he = np.array([hx, hy])
        self.isOutside = isOutside
        self.x_coord = reshape(x_coord, [discNum, 1])
        self.y_coord = reshape(y_coord, [discNum, 1])
        self.X_coord = X_coord
        self.Y_coord = Y_coord
        self.xx = xx
        self.yy = yy
        self.domain = domain
        
        
    def conPlot(self, func, t=None, figNum=None, title=None, fill_val=0.):

        """
        Function to plot the contour field.
        
        Inputs:
            func: callable function of (x,t)
            t: time instance for 2D time-dependent problems
            title [string]: contour plot title
            figNum: figure number to draw on
            fill_val: value to be used for obstacles
            
        Note that the function 'func' must handle the obstcles by assigning 
        neutral values to the grid over the obstacles.
        """

        # Ensure that the provided function is callable.
        if not callable(func):                                  # If the field function is not callable...

            # Throw an error.
            raise ValueError('field function must be callable!')

        # Ensure that this is a 2D time dependent problem and that time has been provided.
        if self.status == '2D-time' and uf.isnone(t):           # If this is a 2D time-dependent problem and time has not been provided.

            # Throw an error.
            raise ValueError('time must be provided for 2D time-dependent problems!')

        # Retrieve relevant information.
        status = self.status
        discNum = self.discNum
        isOutside = self.isOutside
        X_coord = self.X_coord
        Y_coord = self.Y_coord
        domain = self.domain
        
        # Determine how to construct the field.
        if status == '1D-time':                                         # If this is a 1D time dependent problem...

            # Evaluate the field.
            field = func(X_coord, Y_coord)

        elif status == '2D':                                            # If this is a 2D time independent problem...

            # Construct the spatial inputs.
            Input = np.concatenate([X_coord, Y_coord], axis=1)

            # Evaluate the field.
            field = func(Input)

        elif status == '2D-time':                                       # If this is a 2D tie dependent problem...

            # Construct the spatial inputs.
            Input = np.concatenate([X_coord, Y_coord], axis=1)

            # Evaluate the field.
            field = func(Input, t)
            
        # Ensure that the field has the correct shape.
        if not shape(field)[0] == discNum**2:                           # If the field is not a column vector with the correct number of points...

            # Throw an error.
            raise ValueError('output of the function should be a column vector with size {}!'.format(discNum**2))

        elif size(shape(field)) == 1:                                   # If the field is only 1D...

            # Reshape the field to be 2D.
            field = reshape(field, [discNum**2, 1])

        # Fill in specified field values.
        field[isOutside, :] = fill_val

        # Reshape the field.
        field = np.reshape(field, [discNum, discNum])

        # Determine whether to reset the figure number.
        if uf.isnone(figNum):                                           # If no figure number was provided...

            # Set the figure number to zero.
            figNum = 0

        # Create or activate the desired figure.
        plt.figure(figNum)

        # Determine whether to plot the domain.
        if domain.dim > 1:                                              # If this problem is at least two dimensional...

            # Plot the domains.
            domain.domPlot(addDescription=False, figNum=figNum, frameColor='w')
        
        # Create a contour plot of the field.
        cP = plt.contourf(self.xx, self.yy, field)

        # Add a colorbar to the plot.
        plt.colorbar(cP)

        # Determine how to label the axes.
        if status == '1D-time':                                         # If this is a 1D time dependent problem...

            # Label the axes.
            plt.xlabel('$x$')
            plt.ylabel('time')

        else:

            # Label the axes.
            plt.xlabel('$x_1$')
            plt.ylabel('$x_2$')

        # Determine whether to add a title.
        if not uf.isnone(title):                                        # If a title was provided...

            # Add a title to the plot.
            plt.title(title)

        # Scale the axes.
        plt.axis('scaled')

        # Return the field.
        return field
        
        
    def animPlot(self, func, t=[], figNum=None, title=None, fill_val=0.):

        """
        Function to plot the animation of 2D time-dependent field.
        
        Inputs:
            func: callable function of (x,t)
            t: time instance vector for 2D time-dependent problems

        """

        # Determine whether the field function is valid.
        if not callable(func):                                          # If the field function is not provided...

            # Throw an error.
            raise ValueError('field function must be callable!')

        # Determine whether this problem is 2D and time-dependent.
        if self.status == '1D-time' or self.status == '2D':             # If the problem status is 1D time dependent or 2D non-time dependent...

            # Throw an error.
            raise ValueError('animation contour plot is only available for 2D time-dependent problems!')

        # Determine whether to set the figure number to zero.
        if uf.isnone(figNum):                                           # If the figure number if not provided...

            # Set the figure number to zero.
            figNum = 0

        # Retrieve the data.
        discNum = self.discNum
        X_coord = self.X_coord
        Y_coord = self.Y_coord
        isOutside = self.isOutside
        domain = self.domain

        # Concatenate the spatial coordinates.
        Input = np.concatenate([X_coord, Y_coord], axis=1)
        
        # Determine whether to construct our own time vector.
        if np.size(t) == 0:                         # If the provided time vector contains no elements...

            # Retrieve the time interval.
            tInterval = self.tInterval

            # Create the time vector.
            t = np.linspace(tInterval[0], tInterval[1], num=5)
                
        # Plot the data at each time step.
        for ti in t:                                    # Iterate through each time step...

            # Retrieve the figure.
            plt.figure(figNum)

            # Plot the domain limits.
            domain.domPlot(addDescription=False, figNum=figNum, frameColor='w')

            # Evaluate the field function over the spatial domain at this temporal snapshot.
            field = func(Input, ti)
            
            # Ensure that the field has the correct shape.
            if not shape(field)[0] == discNum**2:                       # If the number of rows is not equal to the number of discretization points squared...

                # Throw an error.
                raise ValueError('output of the function should be a column vector with size {}!'.format(discNum**2))

            elif size(shape(field)) == 1:                               # If the field is one dimensional...

                # Reshape the field to be two dimensional.
                field = reshape(field, [discNum**2, 1])

            # Fill in specified field values.
            field[isOutside, :] = fill_val

            # Reshape the field.
            field = np.reshape(field, [discNum, discNum])
            
            # Create a contour plot.
            cP = plt.contourf(self.xx, self.yy, field)

            # Add a colorbar to the plot.
            plt.colorbar(cP)

            # Create a title string.
            titleT = 't = {0:.2f}s'.format(ti)

            # Determine how to edit the title string.
            if not uf.isnone(title):                        # If a title was provided...

                # Add time information to the title.
                title2 = title + '-' + titleT

            else:                                           # Otherwise...

                # Just use time information.
                title2 = titleT

            # Format the plot.
            plt.title(title2); plt.xlabel('$x_1$'); plt.ylabel('$x_2$'); plt.axis('scaled')

            # Show the plot.
            plt.show()

            # Pause before plotting the next contour.
            plt.pause(1)        # pause 1sec before plotting the next contour

        
    def snap1Dt(self, func, t, lineOpt=None, figNum=None, title=None):

        """
        Function to plot snapshots for 1D time-dependent function.
        
        Inputs:
            func: callable function of (x,t)
            t: vector of time instances corresponding to the snapshot
            lineOpt: line options to allow comparison between different functions
            figNum: figure number to draw on
        """
        
        # Ensure that the provided field function is callable.
        if not callable(func):                                      # If the provided function is callable...

            # Throw an error.
            raise ValueError('field function must be callable!')

        # Ensure that this function is valid for 1D time dependent problems.
        if not self.status == '1D-time':                            # If the status has been set to 1D time dependent...

            # Throw an error.
            raise ValueError('Function is specific to 1D time-dependent problems!')

        # Retrieve the spatial coordinates.
        x_coord = self.x_coord

        # Evaluate the provided field function.
        field = func(x_coord, t)

        # Determine whether to create a new figure.
        if uf.isnone(figNum):                                       # If a figure number was not provided...

            # Create a new figure.
            plt.figure()

        else:                                                       # Otherwise...

            # Set the provided figure to be active.
            plt.figure(figNum)

        # Determine how to format the line plot.
        if uf.isnone(lineOpt):                                      # If no line format was provided...

            # Plot the provided field.
            plt.plot(x_coord, field)

        else:                                                       # Otherwise...

            # Plot the provided field with the specified line format.
            plt.plot(x_coord, field, lineOpt)

        # Set the x axis.
        plt.xlabel('$x$')

        # Determine whether to generate a title.
        if not uf.isnone(title):                                    # If a title was provided...

            # Add the title to the plot.
            plt.title(title)

        # Create a grid.
        plt.grid(True)
        
        
        
        

        