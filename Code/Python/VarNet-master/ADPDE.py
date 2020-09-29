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
This file provides the classes for definition of an Advection-Diffusion PDE.

"""

# ------------------------------------------------------------ IMPORT NECESSARY LIBRARIES ------------------------------------------------------------

# Import the necessary libraries.
import numpy as np
import numpy.linalg as la
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from Domain import Domain1D
from ContourPlot import ContourPlot
from UtilityFunc import UF

# Create function aliases.
shape = np.shape
reshape = np.reshape
size = np.size
uf = UF()


# ------------------------------------------------------------ DEFINE PDE CLASS ------------------------------------------------------------

class ADPDE():

    """
    Class for Advection-Diffusion PDE given as
    dc_dt = \nabla diff \nabla c - vel \cdot \nabla c + s,
    subject to
    a*\nabla c \cdot n + b*c = g on \Gamma_i.
    """

    # -------------------- CONSTRUCTOR --------------------

    def __init__(self, domain, diff, vel, source = 0.0, timeDependent = False, tInterval = None, BCs = None, IC = None, cEx = None, MORvar = None, d_diff = None):

        """
        Function to initialize the AD PDE class. The AD-PDE is given as
        dc_dt = \nabla diff \nabla c - vel \cdot \nabla c + s,
        subject to
        a*\nabla c \cdot n + b*c = g on \Gamma_i.
        
        Inputs:
            domain: Domain class instance containing domain information and 
                discretization data
            diff: diffusivity field given as a constant or function of (x,t)
            vel: velocity VECTOR field given as a constant or function of (x,t)
            source: source field given as a function of (x,t)
            tInterval [1x2]: time interval 
            BCs: list containing [a, b, g(x,t)] corresponding to each boundary
                indicator (default BC is zero-value Dirichlet)
            BCtype: list of corresponding boundary condition types:
                'Dirichlet', 'Neumann', 'Robin'
            IC: initial condition for time-dependent problem (default: zero)
            cEx: exact concentration field given as a function of (x,t)
            MORvar: an instance of MOR class containing the variable arguments 
                for the input data diff, vel, source, IC, and BCs (default: empty)
            d_diff: gradient of the diffusivity field wrt spatial coordinate
            
        Note that all function handles should recieve column vectors (x,t) in 
        that order and return a column vector of the same length.
        
        Attributes:
            dim: dimension of the problem
            timeDependent: boolean
            domain: instance of Domain class over which the PDE is solved
            diff, diffFun: diffusivity field
            vel, velFun: velocity vector field
        """


        # -------------------- Validate the Inputs --------------------

        # Determine whether the problem is time dependent.
        if uf.isnone(tInterval):            # If no time interval was provided...

            # Set the problem to not be time dependent.
            timeDependent = False

        else:

            # Set the problem to be time dependent.
            timeDependent = True

        # Determine whether the provided diffusion field is valid.
        if not uf.isnumber(diff) and not callable(diff):            # If diff is neither a number nor function...

            # Throw an error.
            raise ValueError('diffusivity field must be constant or callable!')

        # Determine whether the provided velocity field is valid.
        if not uf.isnumber(vel) and not callable(vel):              # IF vel is neither a number nor function...

            # Throw an error.
            raise ValueError('velocity field must be constant or callable!')

        # Determine whether the provided source is a number or callable.
        if not uf.isnumber(source) and not callable(source):                # If source is neither a number nor a function...

            # Throw an error.
            raise ValueError('source function must be constant or callable!')

        # Determine whether the provided boundary conditions exist and are a list.
        if not uf.isnone(BCs) and type(BCs) is not list:                    # If the boundary condition list is empty or not a list.

            # Throw an error.
            raise ValueError('BCs must be empty or a list of [a, b, g(x,t)]!')

        elif not uf.isnone(BCs) and len(BCs)!=domain.bIndNum:               # If the boundary condition exists but the length of the list does not agree with the index number...

            # Throw an error.
            raise ValueError('number of BCs does not match number of boundaries in domain!')

        # Determine whether a valid IC was specified.
        if timeDependent and uf.isnone(IC):                                 # If the problem is time dependent and no IC was specified...

            # Throw an error.
            raise ValueError('initial condition must be provided for time-dependent problems!')

        # Determine whether the provided exact solution is valid.
        if not uf.isnone(cEx) and not callable(cEx):                        # If the exact solution is valid...

            # Throw an error.
            raise ValueError('exact solution must be a callable function!')

        # Determine whether the diffusivity gradient is valid.
        if not uf.isnone(d_diff) and not uf.isnumber(d_diff) and not callable(d_diff):              # Determine whether the diffusivity gradient is not empty, is not a number, and not a callable function...

            # Throw an error.
            raise ValueError('diffusivity gradient must be constant or callable!')


        # -------------------- Generate Callable Functions --------------------

        # Retrieve the domain of the dimension.
        dim = domain.dim            # domain dimension
        
        # Define a callable function for the diffusivity field.
        if not callable(diff):              # If the diffusivity field is constant...

            # Define a constant callable function with the specified value.
            diffFun = lambda x, t=0: diff*np.ones([shape(x)[0], 1])

            # Store the diffusivity parameters.
            self.diff = diff
            self.diffFun = diffFun

        else:                               # Otherwise...

            # Store the diffusivity parameters.
            diffFun = diff
            self.diffFun = diffFun

        # Define a callable function for the velocity field.
        if not callable(vel):               # If the velocity field is not callable...

            # Create a callable velocity function of the specified constant velocity.
            velFun = lambda x, t=0: vel*np.ones([shape(x)[0], dim])

            # Store the velocity field parameters.
            self.vel = vel
            self.velFun = velFun

        else:                               # Otherwise...

            # Store the velocity field parameters.
            velFun = vel
            self.velFun = velFun

        # Define a callable function for the source function.
        if not callable(source):            # If the source is not a callable function...

            # Define a constant callable source function.
            sourceFun = lambda x, t=0: source*np.ones([shape(x)[0], 1])

            # Store the source parameters.
            self.source = source
            self.sourceFun = sourceFun

        else:                               # Otherwise...

            # Store the source parameters.
            sourceFun = source
            self.sourceFun = sourceFun

        # Define a callable function for the diffusivity gradient.
        if not callable(d_diff):            # If the diffusivity gradient is not callable...

            # Determine whether the diffusivity gradient should be sent to zero.
            if uf.isnone(d_diff):           # If the diffusivity gradient was not specified...

                # Set the diffusivity gradient to zero.
                d_diff = 0.0

            # Define a constant diffusivity gradient.
            d_diffFun = lambda x, t=0: d_diff*np.ones([shape(x)[0], dim])

            # Store the diffusivity gradient parameters.
            self.d_diff = d_diff
            self.d_diffFun = d_diffFun

        else:                               # Otherwise...

            # Store the diffusivity gradient parameters.
            self.d_diffFun = d_diff
        
        # Process the BCs and set them into standard format.
        bIndNum = domain.bIndNum                        # number of boundary indicators


        # Determine whether to create an empty BC list.
        if uf.isnone(BCs):                              # allocate a list if BCs==[]

            # Create a list of empty lists.
            BCs = [[] for i in range(bIndNum)]

        # Validate the specified boundary condition.
        for bInd in range(bIndNum):                     # Iterate through each boundary condition...

            # Determine how to specify the boundary condition.
            if uf.isempty(BCs[bInd]):                   # If this boundary condition is empty...

                # Create a Dirchelet boundary condition.
                BCs[bInd] = [0.0, 1.0, lambda x, t=0: np.zeros([len(x), 1])]

            elif len(BCs[bInd])!=3:                     # If this boundary condition list is not of length three...

                # Throw an error.
                raise ValueError('BCs must be specified as a list of [a, b, g(x,t)]!')

            elif not callable(BCs[bInd][2]):            # If the boundary condition function is not callable (e.g., if it is constant)...

                # Store the boundary condition with a constant callable function.
                BCval = BCs[bInd]                       # if not coppied as a whole, acts as pointer and generates errors
                BCs[bInd] = [ BCval[0], BCval[1], lambda x, t=0: BCval[2]*np.ones([len(x), 1]) ]

        # Initialize the boundary condition type to be empty.
        BCtype = []

        # Assign the boundary condition types.
        for bInd in range(bIndNum):                     # Iterate through each of the boundary conditions...

            # Determine which type of boundary condition this is.
            if BCs[bInd][0] == 0:                     # If this boundary condition has a 0 in the first slot...

                # Categorize this boundary condition as Dirichlet.
                BCtype.append('Dirichlet')

            elif BCs[bInd][1] == 0:

                # Categorize this boundary condition as Neumann.
                BCtype.append('Neumann')

            else:

                # Categorize this boundary condition as Robin.
                BCtype.append('Robin')

            
        # Process the initial condition:
        if timeDependent and uf.isempty(IC):                # If this problem is time dependent and no IC was provided...

            # Set the IC to be zero.
            IC = lambda x, t=0: np.zeros([len(x), 1])

        elif timeDependent and not callable(IC):            # If this problem is time dependent and a constant IC was provided...

            # Set the IC to be a constant function.
            ICval = IC
            IC = lambda x, t=0: ICval*np.ones([len(x), 1])
            
        # Check PDE input data for variable arguments and create a lookup table:
        if not uf.isnone(MORvar):               # IF MOR data was provided...

            funcHandles = MORvar.funcHandles            # list of function handles
            funNum = MORvar.funNum                      # number of function handles
            bDataFlg = False                            # flag to determine if boundary data appears in MOR
            BCind = [None for i in range(bIndNum)]
            MORfunInd = {'diff': None, 'vel': None, 'source': None, 'IC': None, 'd_diff': None}

            for i in range(funNum):

                if funcHandles[i] == diffFun:

                    MORfunInd['diff'] = i

                elif funcHandles[i] == velFun:

                    MORfunInd['vel'] = i

                elif funcHandles[i] == sourceFun:

                    MORfunInd['source'] = i

                elif funcHandles[i] == IC:

                    MORfunInd['IC'] = i

                elif funcHandles[i] == d_diffFun:

                    MORfunInd['d_diff'] = i

                else:

                    for bInd in range(bIndNum):

                        if funcHandles[i] == BCs[bInd][2]:

                            BCind[bInd] = i
                            bDataFlg = True
                            
            if not uf.isnone(MORfunInd['diff']) and callable(d_diff) and uf.isnone(MORfunInd['d_diff']):

                raise ValueError('\'diff\' has extra input arguments but \'d_diff\' does not!')
                
            MORfunInd['BCs'] = BCind

            if uf.isnone(MORfunInd['diff']) and uf.isnone(MORfunInd['vel']) and uf.isnone(MORfunInd['source']):

                MORfunInd['inpData'] = None

            else:

                MORfunInd['inpData'] = True

            if bDataFlg or not uf.isnone(MORfunInd['IC']):

                MORfunInd['biData'] = True

            else:

                MORfunInd['biData'] = None

            self.MORfunInd = MORfunInd

        # Store PDE parameters.
        self.dim = dim
        self.domain = domain
        self.timeDependent = timeDependent
        self.tInterval = tInterval
        self.BCs = BCs
        self.BCtype = BCtype
        self.IC = IC
        self.cEx = cEx
        self.MORvar = MORvar

        print('Done\n')


    # -------------------- IC PLOTTING FUNCTION --------------------

    def plotIC(self):

        """
        Function to plot the initial condition for time-dependent problems.
        """

        dim = self.dim
        domain = self.domain
        
        if not self.timeDependent:

            raise TypeError('the PDE is time-independent!')
        
        if dim == 1:

            mesh = domain.getMesh()
            coord = mesh.coordinates
            plt.figure()
            plt.plot(coord, self.IC(coord))
            plt.xlabel('$x$')
            plt.title('initial condition')
            plt.grid(True)
            plt.show()
            
        elif dim == 2:

            contPlot = ContourPlot(domain)
            contPlot.conPlot(self.IC)


    # -------------------- BC PLOTTING FUNCTION --------------------

    def plotBC(self, bInd):

        """
        Function to plot the right-hand-side of the BC specified by 'bInd'.
        
        Input:
            bInd: number of the boundary indicator to be plotted
        """

        dim = self.dim
        BCs = self.BCs
        domain = self.domain
        tInterval = self.tInterval
        
        if bInd >= domain.bIndNum:

            raise ValueError('entered boundary index is larger than number of indicators!')
            
        g = BCs[bInd][2]                                            # function handle to rhs of BC
        
        if dim == 1 and not self.timeDependent:

            raise TypeError('boundary conditions can only be plotted for time-dependent 1D problems!')

        elif dim == 1:                                                      # If this is a one dimensional problem...

            # Create a time vector for plotting the boundary condition.
            time = np.linspace(tInterval[0], tInterval[1])

            # Create a figure for the boundary condition.
            plt.figure(); plt.xlabel('time'); plt.ylabel('$g(x,t)$'); plt.title('boundary condition {}'.format(bInd + 1)); plt.grid(True)

            # Plot this boundary condition.
            plt.plot(time, g(time))

        elif dim == 2 and not self.timeDependent:                           # If this is a two dimensional problem that is not time dependent...

            # Retrieve the mesh.
            mesh = domain.getMesh()

            # Retrieve the spatial coordinates associated with this boundary condition.
            coord = mesh.bCoordinates[bInd]                         # discretized coordinates of the boundary

            # Create a figure to plot the boundary condition.
            fig = plt.figure(); ax = fig.gca(projection='3d'); plt.xlabel('$x_1$'); plt.ylabel('$x_2$'); ax.set_zlabel('$g(x)$'); plt.title('boundary condition {}'.format(bInd+1)); plt.grid(True)

            # Plot the this boundary condition.
            ax.plot3D(coord[:, 0], coord[:, 1], g(coord)[:, 0])

            
        elif dim == 2:                                                      # If this is a two dimensional problem that is time dependent...

            # Retrieve the limits for the current boundary edge.
            bg = domain.boundryGeom[bInd, :, :]                      # limits for current boundary edge

            # Generate a 1D domain.
            domain0 = Domain1D(interval=[0, 1])

            # Create a custom contour plot object.
            contPlot = ContourPlot(domain0, tInterval)

            # Create a function that converts the spatial variable to be a parameter between [0, 1].
            func = lambda s, t: g(bg[0, :] + s*(bg[1, :] - bg[0, :]), t)   # map to 2D domain

            # Create a contour plot of this boundary condition.
            contPlot.conPlot(func, title='boundary condition {}'.format(bInd + 1))

            # Format the plot.
            plt.xlabel('unit step along boundary {}'.format(bInd+1)); plt.ylabel('$t$')

            # Print out information about this plot.
            print('\nstep direction from ' + str(bg[0, :]) + ' to ' + str(bg[1, :]) + ':')

        # Show the plot.
        plt.show()
        

    # -------------------- FIELD PLOTTING FUNCTION --------------------

    def plotField(self, fieldName, t=[]):

        """
        Function to plot the fields corresponding to input data for the PDE.
        
        Input:
            fieldName: name of the field:
                'diff': diffusivity
                'vel': velocity
                'source': source
                'cEx': exact solution
        """

        dim = self.dim
        domain = self.domain
        timeDependent = self.timeDependent
        tInterval = self.tInterval
        
        if fieldName == 'diff':

            field = self.diffFun; fieldname = 'diffusivity field'
            
        elif fieldName == 'vel':

            velFun = self.velFun
            fieldname = 'velocity field'

            if dim == 1:

                field = velFun

            elif dim == 2 and not timeDependent:

                field = lambda x: la.norm(velFun(x), axis=1)

            elif dim == 2:

                field = lambda x, t: la.norm(velFun(x, t), axis=1)
                
        elif fieldName == 'source':

            field = self.sourceFun; fieldname = 'source field'
            
        elif fieldName == 'cEx':

            cEx = self.cEx

            if uf.isnone(cEx): raise ValueError('exact solution function not provided!')

            field = cEx;       fieldname = 'exact solution field'
            
        else:

            raise ValueError('incorrect field name!')
            
        if dim == 1:

            contPlot = ContourPlot(domain, tInterval)
            contPlot.conPlot(field, title=fieldname)
            
        elif dim == 2 and not timeDependent:

            contPlot = ContourPlot(domain)
            contPlot.conPlot(field, title=fieldname)
            
        elif dim == 2:

            contPlot = ContourPlot(domain, tInterval)
            contPlot.conPlot(field, t, title=fieldname)
                
        
        

