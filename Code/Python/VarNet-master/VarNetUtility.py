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
This file provides the utility classes for the VarNet class.

"""

# ------------------------------------------------------------ IMPORT NECESSARY LIBRARIES ------------------------------------------------------------

import os
import math
import warnings
import pickle
from datetime import datetime
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt
from FiniteElement import FE
from UtilityFunc import UF

shape = np.shape
reshape = np.reshape
size = np.size

uf = UF()

# ------------------------------------------------------------ DEFINE RNN DATA CLASS ------------------------------------------------------------
        
class RNNData():

    """Class to store data for the RNN."""
    
    def __init__(self, dim, inpDim, integPnum, integNum, dof, bdof, tDiscNum, ns, seqLen, nt, nT, t_coord, tDiscInd, tIntegInd, deltaRNN):

        """
        Class initializer for the RNN class.
        
        Attributes:
            inpDim: input dimension for the RNN
            integPnum: number of integration points per dimension
            integNum: total number of integration points for each training point
            dof
            bdof: number of boundary nodes (used to decompose the RNN output)
            tDiscNum: number of time discretizations
            ns: number of spatial points used for training in domain interior
            seqLen: length of the RNN sequence (time series)
            nt: total number of training points
            nT: total number of discrete points for numerical integration
            t_coord: physical time corresponding to the discrete time
            tDiscInd: indices of time corresponding to user-requested time points
                these time values are used to predict the field at output
            tIntegInd: indices of time corresponding to integration points
            deltaRNN: spatial translation vector for use in RNN training
            tDiscIND: indices of entries to RNN corresponding to requested time 
                discretization ignoring the numerical integration
            integInd: index sequence to map RNN shaped data to numerical 
                integration format
        """

        # Retrieve input data.
        self.dim = dim
        self.inpDim = inpDim
        self.integPnum = integPnum
        self.integNum = integNum
        self.dof = dof
        self.bdof = bdof
        self.tDiscNum = tDiscNum
        self.ns = ns
        self.seqLen = seqLen
        self.nt = nt
        self.nT = nT
        self.t_coord = t_coord
        self.tDiscInd = tDiscInd
        self.tIntegInd = tIntegInd
        self.deltaRNN = deltaRNN
        self.tDiscIND = self.timeIndex(dof)
        self.integInd = self.RNN2IntegMap()
        
        
    def timeIndex(self, dof, t=None):

        """
        Function to construct the indexing to extract the spatial data corresponding
        to a given time instance.
        
        Input:
            dof: number of spatial discretization points
            t: vector of time instances
                (if None, construct indices for all discrete time instances)
        """

        # Retrieve the necessary data.
        seqLen = self.seqLen
        t_coord = self.t_coord

        # Determine whether we need to specify the time discretization index.
        if uf.isnone(t):                        # If t is None...

            # Set the time discretization index.
            tDiscInd = self.tDiscInd

        else:                                   # Otherwise...

            # Set the time discretization index.
            tDiscInd = uf.nodeNum(t_coord, t)
        
        tDiscIND = np.zeros(seqLen, dtype=bool)
        tDiscIND[tDiscInd] = True

        return np.tile(tDiscIND, reps=dof)
        
        
    def buildInput(self, coord):
        """Construct appropriate for the RNN given spatial discretization 'coord'."""
        
        # Data:
        dof = len(coord)
        inpDim = self.inpDim
        t_coord = self.t_coord
        seqLen = self.seqLen
        
        Input = uf.pairMats(coord, t_coord)
        return reshape(Input, [dof, seqLen, inpDim])
        
        
    def fold(self, val):
        """Function to fold the tensor to be used in the RNN."""
        
        # Data:
        seqLen = self.seqLen
        dofs = shape(val)
        return reshape(val, newshape=[dofs[0]//seqLen, seqLen, dofs[-1]])
    
    
    def flatten(self, val):
        """Function to flatten the tensor used in the RNN."""
        
        # Data:
        seqLen = self.seqLen
        dofs = shape(val)
        return reshape(val, newshape=[dofs[0]*seqLen, dofs[-1]])
        
        
    def RNN2IntegMap(self):
        """
        Function to create the index mapping from RNN input format to numerical 
        integration format. Note that the Input variable in the VarNet class 
        already is in integration format so we just need to change the ordering
        of the RNN network."""
        
        # Data:
        dim = self.dim
        integPnum = self.integPnum
        integNum = self.integNum
        tDiscNum = self.tDiscNum
        dof = self.dof
        bdof = self.bdof
        tInd = self.tIntegInd
        ns = self.ns
        nT = self.nT
        
        # Numerical integration dimensions:
        tdim = 2*integPnum
        sdim = (2*integPnum)**dim
        
        # Global spatial indices:
        sInd = np.arange(bdof,bdof+ns)
        sInd = np.repeat(sInd, tdim)                        # repeat for each time discretization in numerical integratoin
        sInd = reshape(sInd, [dof, integNum])               # dof x integNum
        sInd = np.tile(sInd, reps=[1, tDiscNum])            # dof x tDiscNum*integNum
        sInd = reshape(sInd, [nT, 1])
        
        # Global temporal indices:
        tInd = reshape(tInd, [tDiscNum, tdim])              # tDiscNum x tdim
        tInd = np.tile(tInd, reps=[1, sdim])                # tDiscNum x integNum
        tInd = reshape(tInd, [tDiscNum*integNum, 1])        # time indices for one set of spatial discretization points
        tInd = np.tile(tInd, reps=[dof,1])                  # copy for all spatial integration points
        
        return np.hstack([sInd, tInd])                      # put the indices together
        
        
        
# ------------------------------------------------------------ DEFINE FIX DATA CLASS ------------------------------------------------------------
        
class FIXData():

    """Class to generate and store fixed data for a the VarNet class."""
    
    def __init__(self, VarNet, integPnum = 2):

        """
        Class to store the fixed data that is used throughout the training process.
        This results in faster evaluation since data is always ready-to-use.
        
        Note: time coordinate is the last one in the numerical integrations, i.e.,
        first spatial and then the temporal coordinates (if time-dependent), are
        stored.
        
        Inputs:
            VarNet: current instance of VarNet class to access its functions for
                training point generation
            integPnum: number of integration points per dimension
        
        Attributes:
            dim: spatial dimension
            feDim: dimension of the numerical integration
            timeDependent: time-dependent PDE
            integPnum: number of integration points per dimension
            integNum: total number of computation points to perform the integration
            dof: number of training points in the inner domain
            bdof [bIndNum x 1]: list of the dofs of all boundaries
            biDof [bIndNum+1 x 1]: number of discretizations on (Dirichlet) 
                boundary-initial conditions
            bDofsum: total number of (Dirichlet) boundary discretizsation points 
                (sum of 'biDof' excluding initial condition)
            nt: number of training points
            nT: grand total of computational points across inner-domain
            delta: translation vector around training point to get the 
                computation points for numerical integration
            lossVecflag: compute loss field in ManageTrainData class only if 
                         corresponding uniform inputs are stored
            uniform_input [dof*tDiscNum x dim]: small uniform mesh over space-time
                used for residual computations
            uniform_biInput: uniform mesh for boundary-initial conditions
            cEx [dof*tDiscNum x 1]: exact concentration field for uniform_input
            uniform_inpData: PDE input data for fixed uniform input
            d_diff: gradient of the diffusivity field for fixed uniform input
            N [nT x 1]: grand vector of FE basis values at integration points
            dNx [nT x dim]: grand vector of spatial FE basis derivatives
            dNt [nT x 1]: grand vector of temporal FE basis derivatives
            integW [1 x integNum]: weights of the numerical integration points
            hVec [1 x feDim]: element size in each dimension
            detJ: determinant of the Jacobian for mapping from mathematical to physical domain
            detJvec [bool]: if True 'detJ' is given as a vector
            biDimVal: dimension correction for boundary-initial condition terms in the loss function
            MORbatchNum: number of MOR batches to loop through
            MORargInd: matrix of indices for MOR variables
            MORdiscArg: uniform discretized arguments for MOR
        """
        
        # Retrieve network data.
        dim = VarNet.dim
        discNum = VarNet.discNum
        bDiscNum = VarNet.bDiscNum

        # Retrieve the PDE data.
        PDE = VarNet.PDE
        timeDependent = PDE.timeDependent
        domain = PDE.domain
        MORvar = PDE.MORvar
        
        # Get the mesh info for the time coordinate.
        if timeDependent:                                       # If this problem is time dependent...

            # Compute the FE dimension.
            feDim = dim + 1

            # Retrieve the time domain number of discretization points.
            tDiscNum = VarNet.tDiscNum

            # Retrieve the time step and time vector.
            ht, t_coord = VarNet.timeDisc()                     # temporal coordinate discretization

        else:

            # Compute the FE dimension.
            feDim = dim

            # Define the number of time domain number discretization points.
            tDiscNum = 1                                        # temporary value to create the integration points

            # Set the time vector to be empty.
            t_coord = []
        
        # Get the spatial mesh info for the domain.
        # (for nonconvex domains the true dof only can be known after mesh generation)
        mesh = domain.getMesh(discNum, bDiscNum)

        # Retrieve information from the mesh.
        dof = mesh.dof                                          # number of training points inside domain
        bdof = mesh.bdof

        # Retrieve the spatial step size.
        he = reshape(mesh.he, [dim, 1])                          # element sizes in space

        # Create a vector of the spatial and temporal step size.
        if timeDependent:                           # If this problem is time dependent...

            # Stack the spatial and temporal step size.
            hVec = np.vstack([he, ht])              # element sizes in space-time

        else:                                       # Otherwise...

            # Set the spatial and temporal step size vector to just be the spatial step size.
            hVec = he

        # Get uniformly distributed boundary and initial condition training points.
        uniform_biInput, biDof = VarNet.biTrainPoints(mesh, t_coord)
        
        # Total number of training points in space-time.
        nt = dof*tDiscNum
        
        # Dimension correction for boundary-initial condition terms in the loss function.
        biDimVal = domain.measure                               # domain size
#        biDimVal = np.prod(hVec[:-1])                          # only spatial dimensions (from dimensional analysis)

        # Input to the NN for residual computations (smaller than training Input and uniform for easier iteration).
        lossVecflag = True                                      # only store lossVec if the corresponding uniform_input exists

        # Determine whether to create a less refined grid for residual information.
        if nt > 1e6:                                              # If the number of initial and boundary condition points exceeds 1 million...

            # Set the flag to store the lossVec to false.
            lossVecflag = False

            # Generate a more sparse domain.
            mesh = domain.getMesh(discNum = 100, bDiscNum = 50)

            # Determine whether to generate a less refined time vector.
            if timeDependent:                                   # If this problem is time dependent...

                # Generate a more sparse time vector.
                _, t_coord = VarNet.timeDisc(tdof = 100)

        # Retrieve the coarse spatial coordinates.
        coord = mesh.coordinates                                # mesh coordinates for inner domain

        # Generate network inputs for the residual points.
        if timeDependent:                                       # If this problem is time dependent...

            # Generate network inputs for the residual points (using spatial and temporal points).
            uniform_input = uf.pairMats(coord, t_coord)

        else:                                                   # Otherwise...

            # Generate network inputs for the residual points (using only spatial points).
            uniform_input = coord
        
        # Generate uniform input boundary and initial condition points for the residual.
        if nt > 1e6:                                            # If the number of points is greater than 1 million...

            # Generate uniform input boundary and initial condition points for the residual.
            uniform_biInput, _ = VarNet.biTrainPoints(mesh, t_coord)
        
        
        # Construct the constant indices to loop over MOR variables:
        if not uf.isnone(MORvar):
            discScheme = VarNet.MORdiscScheme
            discArg = MORvar.discretizeArg(discScheme)
            argInd = MORvar.argIndex(discArg)
            batchNum = len(argInd)
            if batchNum > 16: lossVecflag = False                 # do not store loss field for large MOR batches
        else:
            discArg = None
            argInd = None
            batchNum = 1
        
        # Store data.
        self.dim = dim
        self.feDim = feDim
        self.timeDependent = timeDependent
        self.integPnum = integPnum
        self.dof = dof
        self.bdof = bdof
        self.biDof0 = biDof
        self.nt0 = nt
        self.hVec = hVec
        self.biDimVal = biDimVal
        self.detJvec = False
        self.lossVecflag = lossVecflag
        self.uniform_input = uniform_input
        self.uniform_biInput = uniform_biInput
        self.MORbatchNum = batchNum
        self.MORargInd = argInd
        self.MORdiscArg = discArg
        
        # Placeholders.
        self.cEx = None
        self.uniform_inpData = None
        self.d_diff = None
        
        self.integNum = None
        self.biDof = None
        self.bDofsum = None
        self.nt = None
        self.nT = None
        self.delta = None
        self.integW = None
        self.detJ = None
        self.N = None
        self.dNx = None
        self.dNt = None
        
        
        
    def setInputData(self, VarNet):

        """
        Function to compute and store PDE input data for faster iterations.
        
        Inputs:
            VarNet: current instance of VarNet class to access its functions for
                training point generation
        """
        
        # Retrieve discretization information.
        dim = self.dim
        timeDependent = self.timeDependent
        uniform_input = self.uniform_input

        # Retrieve PDE information.
        PDE = VarNet.PDE
        d_diffFun = PDE.d_diffFun
        MORvar = PDE.MORvar
                
        # Retrieve the spatial inputs.
        Coord = uniform_input[:, :dim]

        # Determine whether to retrieve the temporal inputs.
        if timeDependent:                                           # If this problem is time dependent...

            # Retrieve the temporal inputs.
            tCoord = uniform_input[:, dim:(dim + 1)]
            
        # Determine how to compute the exact solution (only used to evaluate network after training).
        if not uf.isnone(PDE.cEx) and timeDependent:                # If the exact solution to the PDE has not been specified and the problem is time dependent...

            # Construct the time vector.
            tCoord = uniform_input[:, dim:(dim + 1)]

            # Compute the exact solution.
            cEx = PDE.cEx(Coord, tCoord)

        elif not uf.isnone(PDE.cEx):                                # If the exact solution to the PDE has not been specified and the problem is not time dependent...

            # Compute the exact solution.
            cEx = PDE.cEx(Coord)

        else:                                                       # Otherwise...

            # Set the exact solution to be empty.
            cEx = None
        
        # Construct the PDE input data for residual computation over uniform input.
        if uf.isnone(MORvar):                   # If the MOR variable is empty...
            uniform_inpData = VarNet.PDEinpData(uniform_input)
        else:
            uniform_inpData = [None]*3
        
        # Gradient of the diffusivity field over fixed uniform grid:
        if timeDependent:
            d_diff = d_diffFun(Coord, tCoord)
        else:
            d_diff = d_diffFun(Coord)
        
        # Store data.
        self.cEx = cEx
        self.uniform_inpData = uniform_inpData
        self.d_diff = d_diff
        


    def setFEdata(self):

        """
        Function to set the FE data to initial uniform sampling.
        
        Inputs:
            VarNet: current instance of VarNet class to access its functions for training point generation
            integPnum: number of integration points per dimension
        """
        
        # Retrieve problem information.
        dim = self.dim
        feDim = self.feDim
        timeDependent = self.timeDependent
        integPnum = self.integPnum
        biDof = self.biDof0
        nt = self.nt0
        hVec = self.hVec
        
        # Retrieve the total number of boundary condition points.
        if timeDependent:                       # If this problem is time dependent...

            # Compute the total number of boundary condition points by first excluding the initial condition points.
            bDofsum = np.sum(biDof[:-1])        # exclude the initial condition dof

        else:                                   # Otherwise...

            # Compute the total number of boundary condition points.
            bDofsum = np.sum(biDof)
        
        # FE basis data:
        feData = FE(feDim, integPnum)           # construct the Finite Element basis functions
        integNum, nT, detJ, delta, integW, N, dN = feData.basisTot(nt, hVec)
        
        # Split spatial and temporal derivative values:
        dNx = dN[:, 0:dim]
        if timeDependent:
            dNt = dN[:, dim:(dim + 1)]
        else:
            dNt = np.array([[None]])
        
        # Store data.
        self.integNum = integNum
        self.biDof = biDof
        self.bDofsum = bDofsum
        self.nt = nt
        self.nT = nT
        self.delta = delta
        self.integW = integW
        self.detJ = detJ
        self.N = N
        self.dNx = dNx
        self.dNt = dNt
        

        
    def updateOptimData(self, frac, suppFactor):
        """
        Function to update the fixed data after adding optimal training points.
        Note that when the optimal points replace original training points so 
        that the total number of training points stays fixed, this function is 
        not needed.
        
        Inputs:
            frac: fraction of the training points optimally selected
            suppFactor: scaling for the support of the optimally selected test functions
        """
        # Avoid recomputation if FE data for new optimal samples is already generated:
        if self.nt > self.nt0: return
        
        # Load data:
        dim = self.dim
        feDim = self.feDim
        timeDependent = self.timeDependent
        integPnum = self.integPnum
        biDof0 = self.biDof0
        nt0 = self.nt0
        nT0 = self.nT
        hVec0 = self.hVec
        detJ0 = self.detJ
        N0 = self.N
        dNx0 = self.dNx
        dNt0 = self.dNt
        
        # Number of optimal added training points
        nt1 = math.ceil(frac*nt0)
        
        # Support scaling.
        if np.abs(suppFactor-1.0) > 1.e-15:

            hVec1 = suppFactor*hVec0

        else:

            hVec1 = hVec0
        
        # FE basis data:
        feData = FE(feDim, integPnum)                                       # construct the Finite Element bsais functions
        _, nT1, detJ1, _, _, N1, dN1 = feData.basisTot(nt1, hVec1)
        
        # Update the data:
        # (note that in optTrainPoints() first optimal and then original training
        #  points are stored so that is the order used here as well)
        nt = nt0 + nt1              # total number of training points
        nT = nT0 + nT1              # total number of integration points
        if np.abs(suppFactor-1.0)>1.e-15:
            detJ = uf.vstack([ detJ1*np.ones([nt1,1]), detJ0*np.ones([nt0,1]) ])
            detJvec = True
        else:
            detJ = detJ0
            detJvec = False
        N = uf.vstack([N1, N0])
        
        # Split spatial and temporal derivative values:
        dNx1 = dN1[:,0:dim]
        dNx = uf.vstack([dNx1, dNx0])
        if timeDependent:
            dNt1 = dN1[:,dim:dim+1]
            dNt = uf.vstack([dNt1, dNt0])
        else:
            dNt = np.array([[None]])
        
        # Newly added optimal boundary-initial points:
        biDof = [bidof1 + math.ceil(frac*bidof1) for bidof1 in biDof0]      # add optimal samples
        
        # Total (Dirichlet) boundary nodes:
        if timeDependent:
            bDofsum = np.sum(biDof[:-1])                                    # exclude the initial condition dof
        else:
            bDofsum = np.sum(biDof)
        
        # Store data:
        self.biDof=biDof
        self.bDofsum=bDofsum
        self.nt = nt
        self.nT = nT
        self.detJ = detJ
        self.detJvec = detJvec                                              # update the status of 'detJ' variable (scalar or vector)
        self.N = N
        self.dNx = dNx
        self.dNt = dNt
        
        
    def removeInputData(self):

        """Function to remove uniform input data to spare memory."""
        
        self.uniform_input = None
        self.uniform_biInput = None
        self.cEx = None
        self.uniform_inpData = None
        self.d_diff = None
        self.MORargInd = None
        self.MORdiscArg = None
        
        
        
# ------------------------------------------------------------ DEFINE MANAGE TRAIN DATA CLASS ------------------------------------------------------------
        
class ManageTrainData():

    """Class to store and manage the training data for the NN."""
    
    def __init__(self, Input, biInput, batchNum=None, batchLen=None, saveMORdata=False, MORbatchNum=None):

        """
        Class to store training data in an organized way and feed proper data to TF
        model and functions.
        
        Inputs:
            Input: input to the NN corresponding to spatial and possibly temporal coordinates
            biInput: spatiotemporal discretization for training of boundary-initial conditions
            batchNum: number of batches used for training
            batchLen: length of training batches (recommended: 32-512 for ADAM optimizer)
            saveMORdata: save data corresponding to MOR argument combinations for faster training
            MORbatchNum: total number of MOR batches
        """

        # Error handling:
        if not (uf.isnone(batchNum) or uf.isnone(batchLen)):
            raise ValueError('Only one of batch number or length properties must be provided!')        
        elif not uf.isnone(batchNum) and not (type(batchNum) == int or batchNum < 1):
            batchNum = max(1, np.ceil(batchNum))
            print('\'batchNum\' must be a positive integer, using %i' % batchNum)
        elif not uf.isnone(batchLen) and not (type(batchLen) == int or batchLen < 1):
            batchLen = max(1, np.ceil(batchLen))
            print('\'batchLen\' must be a positive integer, using %i' % batchLen)
            if batchLen < 32 or batchLen > 512:
                warnings.warn('\'batchLen\' should preferably be between 32 and 512!')
        if MORbatchNum == 1: saveMORdata = False
        
        # Store the data.
        self.Input = Input
        self.biInput = biInput
        self.inputUpdated = True        # switch the input update on for batch computations
        self.batchNum = batchNum
        self.batchLen = batchLen
        
        # Module to save MOR fields:
        self.saveMORdata = saveMORdata
        self.MORdataSaved = False       # indicator to determine if all MOR data combinations are stored
        if saveMORdata:
            self.MORbatchNum = MORbatchNum
            self.MORinp = []
            self.MORdata = []
            self.fieldNames = []
        
        # Initialize the rest of the variables:
        self.InpuTot = None
        self.biInpuTot = None
        self.biLabel = None
        self.gcoef = None
        self.sourceVal = None
        self.diff = None
        self.vel = None


    def updateData(self, InpuTot=None, biInpuTot=None, biLabel=None, gcoef=None, sourceVal=None, diff=None, vel=None, inpMOR=None):

        """
        Function to update the data input to the NN for each batch.
        The fields that are 'None' are not stored or updated to save computation time.
        
        Inputs:
            inpMOR: only needed to construct the NN inputs if MOR data are stored
        """

        # Retrieve the input data to the network.
        self.inputUpdated = False       # switch the input update off for batch computations
        self.InpuTot = InpuTot
        self.biInpuTot = biInpuTot

        # Define the field names.
        fieldnames = ['InpuTot', 'biInpuTot']

        # Determine whether we need to define the boundary and initial condition labels.
        if not uf.isnone(biLabel):                  # If the boundary and initial condition labels are none...

            # Define the boundary and initial condition labels.
            self.biLabel = biLabel

            # Add another field name.
            fieldnames.append('biLabel')

        # Determine whether we need to define the g coefficient.
        if not uf.isnone(gcoef):                    # If the g coefficient is none...

            # Define the g coefficient.
            self.gcoef = gcoef

            # Add another field name.
            fieldnames.append('gcoef')

        # Determine whether we need to define the source values.
        if not uf.isnone(sourceVal):                # If the source values are none...

            # Define the source values.
            self.sourceVal = sourceVal

            # Add another field name.
            fieldnames.append('source')

        # Determine whether we need to define the diffusivity values.
        if not uf.isnone(diff):                     # If the diffusivity values are none...

            # Define the diffusivity value.
            self.diff = diff

            # Add another field name.
            fieldnames.append('diff')

        # Determine whether we need to define the velocity field.
        if not uf.isnone(vel):                      # If the velocity values are none...

            # Define the velocity value.
            self.vel = vel

            # Add another field name.
            fieldnames.append('vel')
        
        # Update the training dictionaries (if this data set is used for training and not residual calculations):
        if hasattr(self, 'optimFeedicts'):

            # Update the dictionary fields.
            self.updateDictFields(fieldnames)
        
        # If saveMORdata is true and not all MOR data are stored yet:
        if self.saveMORdata and not self.MORdataSaved:          # Determine whether to save the MOR data.

            # Save the MOR data.
            self.saveMORData(fieldnames, inpMOR, biLabel, gcoef, sourceVal, diff, vel)
        
        
        
    def saveMORData(self, fieldnames, inpMOR, biLabel, gcoef, sourceVal, diff, vel):

        """
        Function to store MOR data for faster performance.
        
        Inputs:
            inpMOR: MOR input values to NN to be stacked with the space-time samples
            
        Note: the order of fields in 'data' matters since it is loaded according
              to this order in loadMORData().
        """
        
        # Determine whether we need to save the data.
        if self.MORdataSaved:               # If the MOR data has already been saved...

            # Throw an error.
            raise ValueError('all MOR data are stored!')

        # Determine whether the input data is valid.
        if uf.isnone(inpMOR):               # Determine if the MOR data exists...

            # Throw an error.
            raise ValueError('MOR input values for NN must be provided!')
        
        # Load the MOR data.
        MORbatchNum = self.MORbatchNum
        MORinp = self.MORinp
        fieldNames = self.fieldNames
        MORdata = self.MORdata

        # Add the current MOR batch data:
        MORinp.append(inpMOR)           # MOR inputs to the NN
        fieldNames.append(fieldnames)   # corresponding field names that are updated

        # Initialize the data variable to be empty.
        data = []                       # field data that have been updated for this batch

        # Determine which data to append to the data variable.
        if 'biLabel' in fieldnames: data.append(biLabel)                # Append boundary and initial condition label data.
        if 'gcoef' in fieldnames:   data.append(gcoef)                  # Append g coefficient data.
        if 'source' in fieldnames:  data.append(sourceVal)              # Append source values.
        if 'diff' in fieldnames:    data.append(diff)                   # Append diffusivity values.
        if 'vel' in fieldnames:     data.append(vel)                    # Append velocity values...

        # Append this data to the MOR data.
        MORdata.append(data)
        
        # Save the MOR data.
        if len(MORinp) == MORbatchNum:      # If the data has been saved...

            # Set the MOR data saved flag.
            self.MORdataSaved = True   # indicator to determine if all MOR data combinations are stored

        # Store the MOR data.
        self.MORinp = MORinp
        self.fieldNames = fieldNames
        self.MORdata = MORdata
        
        
        
    def loadMORData(self, batch):

        """
        Function to store MOR data for faster performance.
        
        Input: number of MOR batch
        """
        
        # Determine whether there is data to load.
        if not (self.saveMORdata and self.MORdataSaved):            # If we have not been requested to save the data or if no data has been saved...

            # Throw an error.
            raise ValueError('loadMORData() can only be called when all MOR data are saved!')

        # Determine whether the batch number is valid.
        if batch < 0 or batch > self.MORbatchNum:               # If the batch size is less than zero or larger than the MOR acceptable batch number...

            # Throw an error.
            raise ValueError('batch number out of range!')

        # Retrieve input data.
        Input = self.Input
        nT = len(Input)
        biInput = self.biInput
        bidof = len(biInput)
        inpMOR = self.MORinp[batch]
        fieldnames = self.fieldNames[batch]
        data = self.MORdata[batch]
        
        # Construct inputs to NN:
        InpMOR = np.tile(inpMOR, reps=[nT, 1])
        InpuTot = np.hstack([Input, InpMOR])
        
        InpMOR = np.tile(inpMOR, reps=[bidof, 1])
        biInpuTot = np.hstack([biInput, InpMOR])
            
        # Store the data.
        self.InpuTot = InpuTot
        self.biInpuTot = biInpuTot

        # Set the index to be zero.
        ind = 0

        # Determine whether to retrieve the boundary and initial condition data.
        if 'biLabel' in fieldnames:                 # If the boundary and initial condition data is available...

            # Retrieve the boundary and initial condition data.
            self.biLabel = data[ind]

            # Advance the index.
            ind += 1

        # Determine whether to retrieve the g coefficient data.
        if 'gcoef' in fieldnames:                   # If the g coefficient data is available...

            # Retrieve g coefficient data.
            self.gcoef = data[ind]

            # Advance the index.
            ind += 1

        # Determine whether to retrieve the source data.
        if 'source' in fieldnames:                  # If the source data is available...

            # Retrieve source data.
            self.sourceVal = data[ind]

            # Advance the index.
            ind += 1

        # Determine whether to retrieve the diffusivity data.
        if 'diff' in fieldnames:                    # If the diffusivity data is available...

            # Retrieve the diffusivity data.
            self.diff = data[ind]

            # Advance the index.
            ind += 1

        # Determine whether to retrieve the velocity data.
        if 'vel' in fieldnames:                     # If the velocity data is available...

            # Retrieve the velocity data.
            self.vel = data[ind]
            
        # Update the training dictionaries (if this data set is used for training and not residual calculations):
        self.updateDictFields(fieldnames)


        
    def getTrainData(self):

        """Return training data in packed format for easy unpacking and clean code."""

        # Store some relevant training data.
        data = (self.InpuTot, self.biInpuTot, self.biLabel, self.gcoef, self.sourceVal)

        # Return the training data.
        return data


    def getAllData(self):

        """Return all data in packed format for easy unpacking and clean code."""

        # Retrieve the necessary data.
        data = (self.Input, self.biInput, self.InpuTot, self.biInpuTot, self.biLabel, self.gcoef, self.sourceVal, self.diff, self.vel)

        # Return the data.
        return data


    def trainDicts(self, fixData, tfData):

        """
        Function to CREATE the dictionaries that will be fed to tensorflow for training.
        
        In order to handle batch optimization, the function creates two key 
        attributes for the class, 'batchInd' and 'integInd'. Specifically, since
        the Gauss-Legendre points inside elements corresponding to each training
        points must not change, we first rearrange the 'nT' points into 'nt x integNum'
        points and only shuffle along the first axis which corresponds to training
        points. The variable 'batchInd' holds the order of training points whereas
        'integInd' holds the numbering of all points. We shuffle 'integInd' along
        first axis according to ordering in 'batchInd'.
        
        Inputs: 
            fixData: fixed data of the VarNet class including FE data
            tfData: TensorFlow computational graph data
        """

        # Error handling:
        if hasattr(self, 'optimFeedicts'):
            raise ValueError('training dictionaries are already built!')
        
        # Load data:
        batchNum = self.batchNum
        batchLen = self.batchLen
        if uf.isnone(batchNum) and uf.isnone(batchLen):
            batchNum = 1                                        # default
            
        # Retrieve some training data.
        InpuTot, biInpuTot, biLabel, gcoef, sourceVal = self.getTrainData()
        
        # Retrieve some fixed data.
        timeDependent = fixData.timeDependent
        bDofsum = fixData.bDofsum
        nt = fixData.nt
        nT = fixData.nT
        integNum = fixData.integNum
        detJ = fixData.detJ
        detJvec = fixData.detJvec
        integW = fixData.integW
        biDimVal = fixData.biDimVal
        N = fixData.N
        dNt = fixData.dNt
        
        # Retrieve tensorflow data.
        puNum = tfData.processorNum                                 # number of processors (devices) used for training+
        compTowers = tfData.compTowers                              # variables corresponding to all towers
        
        # Indexing for batch optimization.
        batchInd = np.arange(nt)                                    # indices of training points
        integInd = np.arange(nT).reshape([nt, integNum])

        # Determine whether  to set the number of batches to use.
        if uf.isnone(batchNum):                                     # If no batches were specified...

            # Determine how to set the batch length.
            if batchLen > nt:                                       # If the request batch length is greater than the amount of data.

                # Set the batch length to be all of the data.
                batchLen = nt                             # use all data at once

            # Compute the total number of batches.
            batchNum = int(np.ceil(nt/batchLen/puNum))              # batch number

        else:

            # Compute the total number of batches.
            batchLen = int(np.ceil(nt/batchNum/puNum))              # batch lengthes corresponding to the requested batch numbers
        

        # Initialize the optimization feed dictionary to be zero.
        optFeedicts = []

        # Initialize an index to zero.
        n1 = 0

        # Construct a list of 'feed_dict' values for batches.
        for bi in range(batchNum):                                  # Iterate through each batch...

            # Initialize the optimization feed dictionary for this batch to be empty.
            optFeedict = []                                         # 'feed_dict' for one batch
            for tower in compTowers:                                # Iterate through each tower...

                # Set the first index equal to the second.
                n0 = n1

                # Compute the second index.
                n1 = min(n1 + batchLen, nt)

                # Retrieve the indexes associated with these training points.
                bInd = batchInd[n0:n1]                              # training point indices in current batch
                intgInd = integInd[bInd, :]
                intShap = [n1 - n0, integNum]
                intgInd = reshape(intgInd, np.prod(intShap))        # integration point indices corresponding to current training points (btach)

                # Define the feed dictionary for this batch.
                fdict = {tower.Input: InpuTot[intgInd, :], tower.biInput: biInpuTot, tower.biLabel: biLabel, tower.gcoef: gcoef[intgInd, :], tower.source: sourceVal[intgInd, :], tower.N: N[intgInd, :] , tower.bDof: bDofsum, tower.intShape: intShap, tower.integW: integW, tower.biDimVal: biDimVal, tower.detJvec: detJvec}

                # Determine whether to add the temporal integration information to the optimization feed dictionary.
                if timeDependent:                                   # If this problem is time dependent...

                    # Add the temporal integration information to the optimization feed dictionary.
                    fdict[tower.dNt] = dNt[intgInd, :]

                else:                                               # Otherwise...

                    # Store the single temporal integration piece of information into the optimization feed dictionary.
                    fdict[tower.dNt] = dNt

                # Determine whether to add the jacobian determinant information to the optimization feed dictionary.
                if detJvec:                                         # If the jacobian determinant exists...

                    # Store the jacobina determinant into the optimization feed dictionary.
                    fdict[tower.detJ] = detJ[bInd, :]

                else:                                               # Otherwise...

                    # Store the Jacobian determinent into the optiization feed dictionary.
                    fdict[tower.detJ] = detJ

                # Add the optimization feed dictionary for this batch in this tower to the optimization feed dictionary for this batch in every tower
                optFeedict.append(fdict)                            # store current dictionary for current tower

            # Merge together the optimization feed dictionaries for every batch across all towers.
            optFeedicts.append(uf.mergeDict(optFeedict))            # store all dictionaries for current tower
                
        # Store the data.
        self.nt = nt
        self.integNum = integNum
        self.puNum = puNum
        self.batchNum = batchNum
        self.batchLen = batchLen
        self.batchInd = batchInd                                    # save current sequence of training points for batch optimization
        self.integInd = integInd
        self.compTowers = compTowers                                # Stroe tensorflow pointers to update the contents of the dictionaries
        self.optimFeedicts = optFeedicts
            
                
        
    def updateDictFields(self, fieldnames, trainW=None, normalizeW=True):

        """
        Function to UPDATE the entries of the training dictionaries.
        
        Inputs:
            fieldnames: list of the fields that will be updated:
                trainW, biLabel, gcoef, source
            trainW: weight of penalty terms in loss function
            normalizeW: if True normalizes for batchNum if 'trainW' is updated
        """

        # Ensure that the training dictionaries have been created.
        if not hasattr(self, 'optimFeedicts'):                                  # If the training dictionary hasn't been created...

            # Throw an error.
            raise ValueError('first call trainDicts() to create the training dictionaries!')

        # Ensure that the training weights are not None.
        if 'trainW' in fieldnames and uf.isnone(trainW):                    # If the training weights exist but are None...

            # Throw an error.
            raise ValueError('\'trainW\' cannot be updated by None!')
        
        # Retrieve relevant data.
        nt = self.nt
        integNum = self.integNum
        puNum = self.puNum
        batchInd = self.batchInd
        integInd = self.integInd
        batchNum = self.batchNum
        batchLen = self.batchLen
        compTowers = self.compTowers
        optFeedicts = self.optimFeedicts

        # Determine whether to adjust the loss weights for batch-optimization.
        if 'trainW' in fieldnames and normalizeW:

            # Adjust the boundary and initial condition loss weights for batch optimization.
            trainW[:-1] = trainW[:-1]/batchNum/puNum                # adjust the weights of the BICs for batch-optimization

        # Determine whether to retrieve the boundary and initial condition data.
        if 'biInpuTot' in fieldnames:                               # If the boundary and initial condition field exists...

            # Retrieve the boundary and initial condition data.
            biInpuTot = self.biInpuTot

        # Determine whether to retrieve the boundary and initial condition labels.
        if 'biLabel' in fieldnames:                                 # If the boundary and initial condition label exists...

            # Retrieve the boundary and initial condition labels.
            biLabel = self.biLabel            

        # Set the indexing flag to false.
        indexing = False

        # Determine whether to retrieve the input data.
        if 'InpuTot' in fieldnames:                                 # If the input field exists....

            # Set the indexing flag to true.
            indexing = True

            # Retrieve the input field.
            InpuTot = self.InpuTot

        if 'gcoef' in fieldnames:                                   # If the g coefficient exists...

            # Set the indexing flag to true.
            indexing = True

            # Retrieve the g coefficient.
            gcoef = self.gcoef

        if 'source' in fieldnames:                                  # If the source exists...

            # Set the indexing flag to true.
            indexing = True

            # Retrieve the source values.
            sourceVal = self.sourceVal

        # Initialize an index value to zero.
        n1 = 0

        # Update the training dictionary fields.
        for bi in range(batchNum):                                  # Iterate through each batch...
            for tower in compTowers:                                # Iterate through each tower...
                if 'trainW' in fieldnames:
                    optFeedicts[bi][tower.w] = trainW               # update the training weights
                    
                # Update the training inputs and labels for BICs:
                if 'biInpuTot' in fieldnames:
                    optFeedicts[bi][tower.biInput] = biInpuTot
                if 'biLabel' in fieldnames:
                    optFeedicts[bi][tower.biLabel] = biLabel

                # If the indexing variable is false, proceed to the next iteration.
                if not indexing: continue
                
                # Set the first index to be equal to the second index.
                n0 = n1

                # Advance the first index.
                n1 = min(n1 + batchLen, nt)

                # Slice the desired indexes for this batch on this tower.
                bInd = batchInd[n0:n1]                              # training point indices in current batch
                intgInd = integInd[bInd, :]
                intShap = [n1-n0, integNum]
                intgInd = reshape(intgInd, np.prod(intShap))        # integration point indices corresponding to current training points (btach)
                
                # Update the input values.
                if 'InpuTot' in fieldnames:                                     # If the input field exists...

                    # Store the input values associated with this batch and this tower.
                    optFeedicts[bi][tower.Input] = InpuTot[intgInd, :]
                
                # Update the coefficient of the solution gradient in variational form.
                if 'gcoef' in fieldnames:                                       # If the g coefficient exists...

                    # Store the g coefficient associated with this batch and this tower.
                    optFeedicts[bi][tower.gcoef] = gcoef[intgInd, :]
                    
                # Update the source term.
                if 'source' in fieldnames:                                      # If the source field exists...

                    # Store the source term.
                    optFeedicts[bi][tower.source] = sourceVal[intgInd, :]
        
        # Store the feed dictionaries.
        self.optimFeedicts = optFeedicts
        
        

    def shuffleTrainData(self, fixData):

        """
        Function to UPDATE the training dictionaries if shuffling is required.
        
        Inputs:
            fixData: fixed data of the VarNet class including FE data
        """

        # Ensure that the training dictionaries have been defined.
        if not hasattr(self, 'optimFeedicts'):              # If the training dictionaries have not been defined...

            # Throw an error.
            raise ValueError('first call trainDicts() to create the training dictionaries!')

        # Get batch information.
        nt = self.nt
        integNum = self.integNum
        batchInd = self.batchInd
        integInd = self.integInd
        batchNum = self.batchNum
        batchLen = self.batchLen
        compTowers = self.compTowers
        optFeedicts = self.optimFeedicts

        # Get training data.
        InpuTot, biInpuTot, biLabel, gcoef, sourceVal = self.getTrainData()
        
        # Load fixed-data.
        timeDependent = fixData.timeDependent
        integNum = fixData.integNum
        detJ = fixData.detJ
        detJvec = fixData.detJvec
        N = fixData.N
        dNt = fixData.dNt
        
        # Shuffle the batch indices.
        np.random.shuffle(batchInd)
        biInd = np.arange(len(biLabel))                             # index shuffling for BICs

        # Initialize an index variable to be zero.
        n1 = 0

        # Construct a list of 'feed_dict' values for batches:
        for bi in range(batchNum):                                  # Iterate through each batch...
            for tower in compTowers:                                # Iterate through each tower...

                # Shuffle BICs for each tower and batch:
                np.random.shuffle(biInd)

                # Store the shuffled boundary and initial condition inputs and outputs.
                optFeedicts[bi][tower.biInput] = biInpuTot[biInd, :]
                optFeedicts[bi][tower.biLabel] = biLabel[biInd, :]

                # Set the first index equal to the second.
                n0 = n1

                # Compute the second index.
                n1 = min(n1 + batchLen, nt)

                # Retrieve the batch indexes.
                bInd = batchInd[n0:n1]                              # training point indices in current batch

                # Retrieve the integration indexes.
                intgInd = integInd[bInd, :]

                # Retrieve the integration shape.
                intShap = [n1-n0, integNum]

                # Reshape the integration indexes.
                intgInd = reshape(intgInd, np.prod(intShap))        # integration point indices corresponding to current training points (btach)

                # Update other otimization feed dictionary properties.
                optFeedicts[bi][tower.Input] = InpuTot[intgInd, :]
                optFeedicts[bi][tower.gcoef] = gcoef[intgInd, :]
                optFeedicts[bi][tower.source] = sourceVal[intgInd, :]

                # Determine whether to add Jacobian determinant information.
                if detJvec:                                         # If the Jacobian determinant exists...

                    # Update the optimization feed dictionary properties.
                    optFeedicts[bi][tower.N] = N[intgInd, :]

                    # Determine whether to update the optimization feed dictionary properties with time dependent properties.
                    if timeDependent:                           # If the problem is time dependent...

                        # Update the optimization feed dictionary properties with time dependent information.
                        optFeedicts[bi][tower.dNt] = dNt[intgInd, :]

                    # Update the optimization feed dictionary with jacobian information.
                    optFeedicts[bi][tower.detJ] = detJ[bInd, :]
                
        # Store the updated optimization feed dictionaries.
        self.batchInd = batchInd                                    # save current sequence of training points for batch optimization
        self.optimFeedicts = optFeedicts



    def optimIter(self, tfData):

        """
        Function to perform the optimization iteration.
        The function handles multiple processors and batch-optimization.
        The BICs are trained over together with all batches thus the 
        corresponding training weight must be divided by the number of batches.
        
        Inputs:
            tfData: TensorFlow computational graph data
        """

        # Ensure that the training dictionaries are defined.
        if not hasattr(self, 'optimFeedicts'):

            # Throw an error.
            raise Exception('\'trainDicts\' must be called first to construct training dictionaries!')
                
        # Retrieve the batch number.
        batchNum = self.batchNum

        # Retrieve the feed dictionaries.
        optFeedicts = self.optimFeedicts

        # Retrieve the total loss over all towers.
        loss = tfData.loss                  # total loss summed over all towers

        # Retrieve the current applied gradient.
        optMinimize = tfData.optMinimize

        # Retrieve the tensorflow session.
        sess = tfData.sess

        # Initialize the loss value to be zero.
        lossVal = 0

        # Compute the total loss over all batches.
        for ib in range(batchNum):          # Iterate through each batch...

            # Compute the loss associated with this batch.
            _, lossTmp = sess.run([optMinimize, loss], feed_dict=optFeedicts[ib])

            # Add the loss associated with this batch to the total loss.
            lossVal += lossTmp

        # Return the total loss.
        return lossVal
        
        

    def splitLoss(self, tfData, lossVecflag):
        """
        Function to compute the loss components including the boundary and initial
        conditions and the variational loss as well as the individual values of 
        variational loss at training points.
        Note: BICs are copied across batches and computational nodes
            
        Inputs:
            tfData: TensorFlow computational graph data
            lossVecflag: if true return the loss field
        """
        # Error handling:
        if not hasattr(self, 'optimFeedicts'):
            raise Exception('\'trainDicts\' must be called first to construct training dictionaries!')
        
        # Load data:
        batchNum = self.batchNum
        optFeedicts = self.optimFeedicts
        
        # Load tensorflow computational nodes:
        compTowers = tfData.compTowers                  # variables corresponding to all towers
        BCloss_tf = compTowers[0].BCloss                # BCs loss component
        ICloss_tf = compTowers[0].ICloss                # ICs loss component
        varLoss_tf = tfData.varLoss                     # variational loss component
        if lossVecflag: lossVec_tf = tfData.lossVec     # variational loss field
        else:           lossVec_tf = []
        sess = tfData.sess
        
        # BIC loss values:
        BCloss, ICloss = sess.run([BCloss_tf, ICloss_tf], feed_dict=optFeedicts[0])
        # (BICs are copied across batches and computational nodes)
        
        varLoss = 0
        lossVec = []
        for ib in range(batchNum):                      # loop over batches
            varLossTmp, lossVecTmp = sess.run([varLoss_tf, lossVec_tf], feed_dict=optFeedicts[ib])
            varLoss += varLossTmp
            lossVec.append(lossVecTmp)
            
        if lossVecflag: lossVec = uf.vstack(lossVec)    # stack loss vector across bathces
        else:           lossVec = None
        
        return BCloss, ICloss, varLoss, lossVec




    def runSession(self, nodList, tfData, diff_dx=None):
        """
        Function to evaluate various parts of the computational graph for the 
        currently stored dataset of the class.
        Note: for computational efficiency use 'optimIter()' for loss node.
        
        Inputs: 
            nodList: list containing the nodes to be computed:
                model: NN output would be computed
                residual: PDE residual will be computed
            tfData: TensorFlow computational graph data
            trainW: weight of penalty terms in loss function
            diff_dx: derivative of the diffusivity field for PDE residual computation
        """
        if uf.isempty(nodList):
            warnings.warn('no nodes are specified for computation!')
            return []
        
        # Load data:
        _, _, InpuTot, biInpuTot, biLabel, gcoef, sourceVal, diff, vel = self.getAllData()
        
        sess = tfData.sess
        tower = tfData.compTowers[0]            # use first computational tower for computations
        
        nodList_tf = []
        if 'model' in nodList:
            model = tfData.model
            Input_tf = tower.Input
            
            nodList_tf.append(model(Input_tf))
            feedict = {Input_tf: InpuTot}
            
        if 'residual' in nodList:
            residual_tf = tower.residual
            diff_tf = tower.diff
            vel_tf = tower.vel
            source_tf = tower.source
            diff_dx_tf = tower.diff_dx
            
            nodList_tf.append(residual_tf)
            feedict = {Input_tf: InpuTot, diff_tf: diff, vel_tf: vel,
                       source_tf: sourceVal, diff_dx_tf: diff_dx}            
            
        # Perform the computations for the requested nodes of the graph:
        return sess.run(nodList_tf, feed_dict=feedict)
        
    
        
        
# ------------------------------------------------------------ DEFINE TRAIN RESULT CLASS ------------------------------------------------------------
        
class TrainResult():

    """Class to store current training data to hard drive."""
    
    def __init__(self, folderpath, cExFlg=False, verbose=True, saveFreq=100, pltReplace=True):

        """
        Class to store current training data.
        
        Inputs:
            folderpath: path to a folder to store the training data
            cExFlg: True if exact solution is available
            verbose: if True print training updates to console
            saveFreq: frequency of saving and reporting the training results
            pltReplace: replace the training result plots
            
        Attributes:
            folderpath: path to a folder to store the training data
            casepath: OS path to the text file storing training case data
            plotpath: folder to store the training plots
            saveFreq: frequency of saving and reporting the training results
            verbose: if True print training updates to console
            pltReplace: replace the training result plots
            trainWeight: penalty parameter in loss function to enforce the above weight 
            loss: history of the training loss
            lossComp: list containing the components of the loss function
            avgtime0: reference time, obtained from initital iterations, for performance check
            avgtime: average training iteraion time
            residual: history of PDE-residual values sampled from iterations
            iterSmp: iteration numbers for which training data are stored
            inpIter: iterations at which the input is updated
            error: error values compared to a reference (exact) solution
            lossVec: vector of individual variational loss values at training points
            
            train() arguemnts:
                option_stopping: options for stoppoing iterations
                option_trainPoint: options for selection of training points
                option_weighting: options for training weights
                option_batchOptim: options for batch-optimization
        """
        
        # Store input information.
        self.folderpath = folderpath
        self.verbose = verbose
        self.saveFreq = saveFreq
        self.pltReplace = pltReplace
        self.trainWeight = None
        
        # Create a path to store the plots.
        plotpath = os.path.join(folderpath, 'plots')

        # Determine whether we need to create a plots subfolder.
        if not os.path.exists(plotpath):                    # If the plots subfolder does not exist...

            # Create the plot path directory.
            os.makedirs(plotpath)

        # Store the plot path.
        self.plotpath = plotpath
        
        # Training history data initialization:
        self.loss = []          # full total loss history
        self.lossComp = []      # components of sampled loss function
        self.avgtime0 = None    # reference time for performance check
        self.avgtime = 0
        self.residual = []
        self.iterSmp = []
        self.inpIter = []
        if not uf.isnone(cExFlg):
            self.error = []
        else:
            self.error = None
        self.lossVec = None     # vector of individual variational loss values at training points
        
        
        
    def initializeCase(self, varNet, trainArg):

        """
        Function to write the settings of the current problem into a text file.
        
        Input:
            varNet: the instance of varNet class that is being trained
            trainArg: train() function argument values
        """

        # Load train() arguments and group them into dictionaries:
        epochNum = trainArg['epochNum']
        tol = trainArg['tol']
        option_stopping = {'epochNum': epochNum, 'tol': tol}
        
        smpScheme = trainArg['smpScheme']
        frac = trainArg['frac']
        addTrainPts = trainArg['addTrainPts']
        suppFactor = trainArg['suppFactor']
        multiTrainUpd = trainArg['multiTrainUpd']
        trainUpdelay = trainArg['trainUpdelay']
        tolUpd = trainArg['tolUpd']
        reinitrain = trainArg['reinitrain']
        option_trainPoint = {'smpScheme': smpScheme, 'frac': frac, 'addTrainPts': addTrainPts, 'suppFactor': suppFactor, 'multiTrainUpd': multiTrainUpd, 'trainUpdelay': trainUpdelay, 'tolUpd': tolUpd, 'reinitrain': reinitrain}
        
        weight = trainArg['weight']
        updateWeights = trainArg['updateWeights']
        normalizeW = trainArg['normalizeW']
        adjustWeight = trainArg['adjustWeight']
        useOriginalW = trainArg['useOriginalW']
        option_weighting = {'weight': weight, 'updateWeights': updateWeights, 'normalizeW': normalizeW, 'adjustWeight': adjustWeight, 'useOriginalW': useOriginalW}
        
        saveMORdata = trainArg['saveMORdata']
        batchNum = trainArg['batchNum']
        batchLen = trainArg['batchLen']
        shuffleData = trainArg['shuffleData']
        shuffleFreq = trainArg['shuffleFreq']
        option_batchOptim = {'saveMORdata':saveMORdata, 'batchNum': batchNum, 'batchLen': batchLen, 'shuffleData': shuffleData, 'shuffleFreq': shuffleFreq}
        
        # Retrieve the VarNet data.
        dim = varNet.dim
        modelId = varNet.modelId
        discNum = varNet.discNum
        bDiscNum = varNet.bDiscNum
        tDiscNum = varNet.tDiscNum

        # Retrieve PDE information.
        PDE = varNet.PDE
        timeDependent = PDE.timeDependent
        BCtype = PDE.BCtype
        MORoff = uf.isnone(PDE.MORvar)

        # Retrieve the fixed data.
        fixData = varNet.fixData
        nt = fixData.nt
        biDof = fixData.biDof
        bDofsum = fixData.bDofsum

        # Retrieve the tensorflow data.
        tfData = varNet.tfData
        inpDim = tfData.inpDim
        layerWidth = tfData.layerWidth
        activationFun = tfData.activationFun
        trainableNum = tfData.model.count_params()          # total number of trainable parameters
        puNum = tfData.processorNum                         # number of processing units
        processors = tfData.processors
        controller = tfData.controller
        optimizer_name = tfData.optimizer_name
        learning_rate = tfData.learning_rate
        
        # Create the case text file:
        folderpath = self.folderpath
        casepath = os.path.join(folderpath, 'caseData.txt')
        myfile = open(casepath, 'w+')
        
        # Write the VarNet library specifications and copyright notice:
        string = '-------------------------------------------------------------------------------\n'
        string += '=============================== VarNet Library ================================\n'
        string += '-------------------------------------------------------------------------------\n'
        string += 'Copyright (c) 2019 Reza Khodayi-mehr - licensed under the MIT License\n'
        string += 'https://arxiv.org/pdf/1912.07443.pdf\n\n'
        string += '-------------------------------------------------------------------------------\n'
        myfile.write(string)
        
        # Add date and time of the simulation:
        dt_str = datetime.now().strftime("%d/%m/%Y %H:%M:%S").split()
        string = 'Simulation date: ' + dt_str[0] + ' - time: ' + dt_str[1] + '\n\n'
        myfile.write(string)
        
        # Header:
        if timeDependent:
            myfile.write(str(dim) + 'D time-dependent Advection-Diffusion problem')
        else:
            myfile.write(str(dim) + 'D steady-state Advection-Diffusion problem')
            
        if not MORoff:
            myfile.write(' with model-order-reduction.\n\n')
        else:
            myfile.write(' without model-order-reduction.\n\n')
        
        # Boundary condition information:
        myfile.write('Boundary condition information:\n')
        if dim==1:
            myfile.write('\ttype:' + BCtype[0] + ', ' + BCtype[1] + '\n')
        elif dim==2:
            domain = PDE.domain
            bIndNum = domain.bIndNum
            boundryGeom = domain.boundryGeom.tolist()
            for bi in range(bIndNum):
                string = '\tBC' + str(bi+1) + ': ' + BCtype[bi]
                string += ' - vertices: ' + str(boundryGeom[bi]) + '\n'
                myfile.write(string)
        myfile.write('\n')
            
        # Neural Network information:
        myfile.write('Neural Network architecture:\n')
        myfile.write('\ttype: ' + modelId + '\n')
        myfile.write('\tnumber of inputs: ' + str(inpDim) + '\n')
        myfile.write('\tnumber of layers: ' + str(len(layerWidth)) + '\n')
        myfile.write('\tnumber of nodes in each layer: ' + str(layerWidth) + '\n')
        myfile.write('\tactivation function for each layer: ' + str(activationFun) + '\n')
        myfile.write('\ttotal number of trainable parameters: ' + str(trainableNum) + '\n\n')
        
        # Processor information:
        myfile.write('Processor information:\n')
        if puNum>1:
            myfile.write('\tparallel replicated training on ' + str(puNum) + ' processors\n')
            string = '\tutilized processors: '
            for pu in range(puNum):
                string += processors[pu][8:]
                if pu<puNum-1:  string += ' and '
                else:           string += '\n'
            myfile.write(string)
            myfile.write('master controller:' + controller[8:] + '\n\n')
        else:
            myfile.write('\tutilized processor: ' + processors[0][8:] + '\n')
            if not processors[0] == controller:
                myfile.write('controller:' + controller[8:] + '\n')
            myfile.write('\n')
        
        # Optimizer data:
        myfile.write('Optimizer information:\n')
        if optimizer_name.lower()=='adam':
            myfile.write('\ttype: Adam stochastic gradient descent algorithm\n')
        elif optimizer_name.lower() == 'rmsprop':
            myfile.write('\ttype: RMS stochastic gradient descent algorithm\n')
        myfile.write('\tlearning rate: ' + str(learning_rate) + '\n\n')
        
        # Discretization information:
        myfile.write('Space-time discretization information:\n')
        myfile.write('\tspatial domain interior discretization number: ' + str(discNum) + '\n')
        myfile.write('\tspatial domain boundary discretization density: ' + str(bDiscNum) + '\n')
        if timeDependent:
            myfile.write('\ttemporal discretization number: ' + str(tDiscNum) + '\n')
        myfile.write('\tnumber of training points: ' + str(nt) + '\n')
        myfile.write('\tnumber of training points for BCs: ' + str(biDof[:-1]) + '\n')
        myfile.write('\ttotal number of BC training points: ' + str(bDofsum) + '\n')
        if timeDependent:
            myfile.write('\tnumber of training points for IC: ' + str(biDof[-1]) + '\n')
        myfile.write('\n')
        
        # Sampling scheme information:
        myfile.write('Sampling scheme for training points: ' + smpScheme + '\n')
        if not smpScheme=='uniform':
            myfile.write('\tfraction of non-uniform points: ' + str(frac) + '\n')
            if addTrainPts:
                myfile.write('\tnon-uniform points are added without replacement\n')
            if multiTrainUpd:
                myfile.write('\tnon-uniform points updated every ' + str(trainUpdelay) + ' epochs ...\n')
                myfile.write('\t... if decrease in 5 consecutive loss values is less than ' + str(tolUpd) + '\n')
            else:
                myfile.write('\tnon-uniform points updated once after ' + str(trainUpdelay) + ' epochs\n')
                myfile.write('\tif decrease in 5 consecutive loss values is less than ' + str(tolUpd) + '\n')
            if smpScheme=='optimal' and np.abs(suppFactor-1.0)>1.e-15:
                myfile.write('\tsupport of optimal training points is scaled by a factor of ' + str(suppFactor) + '\n')
            if reinitrain:
                myfile.write('\ttrainable variables are re-initialized after update of training points\n')
                
            string = 'Note: since for non-uniform grid the training points and possibly weights are updated\n'
            string += '      the loss component plots will not necessarily match total loss plot!\n'
            myfile.write(string)
        myfile.write('\n')
        
        # Batch-optimization information:
        if not (MORoff and uf.isnone(batchNum) and uf.isnone(batchLen)):
            myfile.write('Batch-optimization information:\n')
            if not MORoff:
                myfile.write('\tnumber of MOR batches: ' + str(fixData.MORbatchNum) + '\n')
                if saveMORdata: myfile.write('\tMOR fields are stored for faster training.\n')
                
            if not uf.isnone(batchNum):
                myfile.write('\tnumber of training batches: ' + str(batchNum) + '\n')
            elif not uf.isnone(batchLen):
                myfile.write('\tlength of training batches: ' + str(batchLen) + '\n')
            if shuffleData:
                myfile.write('\tshuffle training data every ' + str(shuffleFreq) + ' epochs\n')
            if not (uf.isnone(batchNum) and uf.isnone(batchLen)):
                string = 'Note: for batch-optimization loss component values will not match total loss\n'
                string += '      since intermediate iterations change total loss unlike loss components!\n'
                myfile.write(string)
            myfile.write('\n')
        
        # Weighting information:
        myfile.write('Weighting information:\n')
        myfile.write('\trequested weights: ' + str(weight) + '\n')
        if updateWeights:
            myfile.write('\tweights updated to maintain the requested balance between terms\n')
        if normalizeW:
            myfile.write('\tweights normalized by values so that weight times values have requested weights\n')
        if not smpScheme=='uniform' and adjustWeight:
            myfile.write('\tweights on boundary-initial conditions updated after addition of non-uniform points\n')
        if useOriginalW:
            myfile.write('\trequested weights applied without any modification\n')
        myfile.write('\n')
        
        # Stopping criteria information:
        myfile.write('Stopping criteria:\n')
        myfile.write('\tmaximum number of epochs: ' + str(epochNum) + '\n')
        myfile.write('\tstopping tolerance: ' + str(tol) + '\n\n')
        
        # Header for training:
        myfile.write('==========================================================\n')
        myfile.write('Training iterations:\n\n')
        
        myfile.close()
        
        # Store the line after which the simulation data will be written:
        # (used to add comments later)
        with open(casepath, 'r') as file:
            data = file.readlines()
            caseSimline = len(data) - 4
        
        # Store the data.
        self.casepath = casepath
        self.option_stopping = option_stopping
        self.option_trainPoint = option_trainPoint
        self.option_weighting = option_weighting
        self.option_batchOptim = option_batchOptim
        self.caseSimline = caseSimline

            
        
    def writeCase(self, text):
        """Function to write 'text' to the case file."""
        # Error handling:
        if not type(text)==str:
            raise ValueError('the input must be a string!')
        
        casepath = self.casepath
        myfile = open(casepath, 'a+')
        myfile.write(text)
        myfile.close()
        
        
        
    def writeComment(self, text):
        """
        Function to write 'text' to the case file before the simulation results.
        This function is useful to add important post-simulation comments at the
        top of the case file.
        """
        # Error handling:
        if not type(text)==str:
            raise ValueError('the input must be a string!')
        
        # Pre-process 'text' and split lines:
        text = text.split('\n')
        text = [txt+'\n' for txt in text]       # add new line
        
        # Load data:
        casepath = self.casepath
        linum = self.caseSimline
        
        with open(casepath, 'r') as file:       # read case file
            data = file.readlines()
        
        # Add the line at the correct position:
        data2 = data[:linum]
        data2.extend(text)
        data2.extend(data[linum:])
        
        with open(casepath, 'w') as file:       # write back case file
            file.writelines(data2)



    def saveData(self):

        """Function to store the training data (an instance of this class)."""

        # Retrieve the folder path.
        folderpath = self.folderpath

        # Retrieve the file path.
        filepath = os.path.join(folderpath, 'trainData.vn')

        # Save the training data.
        with open(filepath, "wb") as file:

            # Save the training data.
            pickle.dump(self.__dict__, file, pickle.HIGHEST_PROTOCOL)
            
            
            
    def loadData(self):

        """Function to store the training data (an instance of this class)."""
        
        folderpath = self.folderpath
        filepath = os.path.join(folderpath, 'trainData.vn')

        with open(filepath, "rb") as file:

            dump = pickle.load(file)
            
            # Reset the attributes:
            self.folderpath = folderpath
            self.casepath = dump['casepath']
            self.plotpath = dump['plotpath']
            self.caseSimline = dump['caseSimline']
            self.saveFreq = dump['saveFreq']
            self.verbose = dump['verbose']
            self.pltReplace = dump['pltReplace']
            self.trainWeight = dump['trainWeight']
            self.loss = dump['loss']
            self.lossComp = dump['lossComp']
            self.avgtime0 = dump['avgtime0']
            self.avgtime = dump['avgtime']
            self.residual = dump['residual']
            self.iterSmp = dump['iterSmp']
            self.inpIter = dump['inpIter']
            self.error = dump['error']
            self.lossVec = dump['lossVec']
            
            # train() arguments:
            try:                                    # backward compatibility

                self.option_stopping = dump['option_stopping']
                self.option_trainPoint = dump['option_trainPoint']
                self.option_weighting = dump['option_weighting']
                self.option_batchOptim = dump['option_batchOptim']

            except:

                warnings.warn('train() arguments not loaded!')
                
        
        
    def iterOutput(self, epoch, current_loss, min_loss, epoch_time, resVal, err, lossSplit, lossVec):

        """
        Function to output results during training.
        
        Inputs:
            resVal: current residual value
            err: error compared to a reference value
            lossSplit: decomposed loss for each term
            lossVec: vector of loss values over training points
        """
        
        # Retrieve relevant information.
        verbose = self.verbose
        saveFreq = self.saveFreq

        # Determine whether to exit without taking any action.
        if not (epoch < saveFreq or (epoch % saveFreq) == 0):

            # Return nothing.
            return    # no action

        # Report loss values:
        string = 'Epoch %2d: loss = %2.5f\n' % (epoch, current_loss)

        # Determine whether to write data to a file.
        if epoch < saveFreq:                                    # If the current epoch number is less than the save frequency...

            # Write to this case.
            self.writeCase(string)

            # Determine whether to print out loss information.
            if verbose:                                         # If we have been requested to print information...

                # Print out the loss information.
                print(string, end='')

            # Determine whether to compute the average epoch time.
            if epoch == saveFreq - 1:               # If this epoch is at the save frequency...

                # Compute the average epoch time.
                self.avgtime0 = epoch_time/epoch                # reference time

            # Exit this function.
            return

        # If 'epoch' is a multiple of 'saveFreq':

        # Write this information to the case file.
        self.writeCase(string)

        # Determine whether to print the loss information.
        if verbose:                         # If we have been requested to print loss information...

            # Print the loss information.
            print(string, end='')
        
        # Retrieve loss and related data.
        iterSmp = self.iterSmp
        loss = self.loss
        lossComp = self.lossComp
        residual = self.residual
        error = self.error
        plotFreq = 10*saveFreq                                  # start plotting when at least 10 data points are available
        
        # Update the loss data.
        iterSmp.append(epoch)                                   # keep history of epochs stored
        loss.append(current_loss)                               # update convergence history
        lossComp.append(reshape(lossSplit, 3))                  # Split loss term values
        residual.append(resVal)                                 # residual values
        if not uf.isnone(error): error.append(err)              # error values

        # Compute the average training time per epoch.
        train_time = epoch_time/epoch                           # average training time

        # Determine whether the training time is getting significantly slower.
        if train_time>1.2*self.avgtime0:                        # If the training time is getting significantly slower...

            # Throw a warning.
            Warning('iterations are getting slower!')

        # Store the average training time.
        self.avgtime = train_time                               # update average training time
        
        # Update the loss information.
        self.iterSmp = iterSmp
        self.loss = loss
        self.lossComp = lossComp
        self.residual = residual
        if not uf.isnone(error): self.error = error
        self.lossVec = lossVec
        
        # Save this class instance with the most up-to-date data:
        self.saveData()
        
        # Return if plotting frequency does not match:
        if not (epoch % plotFreq) == 0: return
        
        string  = '\nbest model loss: %2.5f\n' % min_loss
        string += 'average iteration time: %2.5fs\n\n' % (epoch_time/epoch)
        print(string, end='')

        # Write to the case file.
        self.writeCase(string)
            
        # Plot the iteration data:
        self.iterPlot()
        
                
        
    def iterPlot(self, plotpath=None, pltFrmt='png'):

        """
        Function to plot current iteration data.
        
        Inputs:
            plotpath: path to store the plots
            pltFrmt: plot format
        """
        
        # Ensure that the plot format is recognized.
        if not (pltFrmt == 'png' or pltFrmt == 'jpg' or pltFrmt == 'pdf' or pltFrmt == 'eps'):              # If the plot format is not a recognized format...

            # Throw an error.
            raise ValueError('invalid plot format!')

        else:                                                                                       # Otherwise...

            # Add a period to the plot format.
            pltFrmt = '.' + pltFrmt


        # -------------------- SETUP FOR PLOTTING --------------------

        # Retrieve relevant data.
        iterSmp = self.iterSmp
        inpIter = self.inpIter                                  # epochs corresponding to input data update
        trainW = self.trainWeight                               # training weight to compute the total loss
        if uf.isnone(plotpath): plotpath = self.plotpath
        pltReplace = self.pltReplace                            # replace the plots
        loss = self.loss
        lossComp = self.lossComp
        residual = self.residual
        error = self.error
        
        # Determine how to update the file name.
        if pltReplace:              # If we want to replace the current file...

            # Do not modify the file name.
            filename0 = ''

        else:                       # Otherwise...

            # Retrieve the epoch number.
            epoch = iterSmp[-1]

            # Update the file name to avoid over writing existing value.
            filename0 = '{}'.format(epoch) + '_'

        # Set the plot title to be empty.
        title = ''                                              # default plot title


        # -------------------- PLOT LOSS FUNCTION --------------------

        # Set the plot title for png plots.
        if pltFrmt == '.png': title = 'convergence plot (variable grid)'

        # Create and format a figure to store the loss function.
        plt.figure(1); plt.clf(); plt.xlabel('epochs'); plt.ylabel('loss function'); plt.grid(True); plt.title(title)

        # Plot the loss function.
        plt.semilogy(iterSmp, loss)
        if not uf.isempty(inpIter):
            for i in inpIter:

                # Plot a vertical line.
                plt.axvline(i, color='r', linestyle='--')

        # Generate the file name.
        filename = filename0 + 'loss' + pltFrmt

        # Generate the file path.
        filepath = os.path.join(plotpath, filename)

        # Save the current figure.
        plt.savefig(filepath, dpi=300)

        # # Display the figure.
        # plt.show()


        # -------------------- PLOT LOSS COMPONENTS --------------------

        # Plot raw loss terms:
        lossComp = np.array(lossComp)
        iterSmp2 = np.concatenate([[0], iterSmp])

        if pltFrmt == '.png': title = 'loss components plot'

        # Create a figure to store the loss components.
        plt.figure(2); plt.clf(); plt.xlabel('epochs'); plt.ylabel('loss components'); plt.title(title); plt.grid(True)

        # Plot the loss components.
        plt.semilogy(iterSmp2, lossComp[:, 0], 'b')
        plt.semilogy(iterSmp2, lossComp[:, 1], 'r')
        plt.semilogy(iterSmp2, lossComp[:, 2], 'g')

        # Add a legend to the plot.
        plt.legend(['BC', 'IC', 'integral term'])

        # Define the figure name.
        filename = filename0 + 'lossComp' + pltFrmt

        # Define the figure path.
        filepath = os.path.join(plotpath, filename)

        # Save the figure.
        plt.savefig(filepath, dpi=300)

        # # Show the figure.
        # plt.show()


        # -------------------- PLOT SCALED LOSS COMPONENTS --------------------

        # Set the plot title.
        if pltFrmt == '.png': title = 'scaled loss components plot'

        # Plot loss terms:
        plt.figure(3); plt.clf(); plt.xlabel('epochs'); plt.ylabel('loss components'); plt.title(title); plt.grid(True)

        # Compute the weighted loss.
        lossTot = trainW*lossComp

        # Plot the weighted loss components.
        plt.semilogy(iterSmp2, lossTot[:, 0], 'b')
        plt.semilogy(iterSmp2, lossTot[:, 1], 'r')
        plt.semilogy(iterSmp2, lossTot[:, 2], 'g')

        # Compute the total loss.
        lossTot = np.sum(lossTot, axis=1)

        # Plot the total loss.
        plt.semilogy(iterSmp2, lossTot, 'k')

        # Create a legend.
        plt.legend(['BC', 'IC', 'integral term', 'total loss'])

        # Define the file name.
        filename = filename0 + 'scaled_lossComp' + pltFrmt

        # Define the file path.
        filepath = os.path.join(plotpath, filename)

        # Save the figure.
        plt.savefig(filepath, dpi=300)

        # # Show the figure.
        # plt.show()


        # -------------------- PLOT RESIDUAL --------------------

        # Update the plot title.
        if pltFrmt ==' .png': title = 'residual convergence plot'

        # Plot residual and solution error:
        plt.figure(4); plt.clf(); plt.xlabel('epochs'); plt.ylabel('residual'); plt.title(title); plt.grid(True)

        # Plot the residual.
        plt.semilogy(iterSmp, residual)

        # Define the file name.
        filename = filename0 + 'res_history' + pltFrmt

        # Define the file path.
        filepath = os.path.join(plotpath, filename)

        # Save the figure.
        plt.savefig(filepath, dpi=300)

        # # Show the figure.
        # plt.show()


        # -------------------- PLOT THE ERROR --------------------

        # Determine whether to plot the error.
        if not uf.isnone(error):

            # Update the plot title.
            if pltFrmt == '.png': title = 'normalized solution error'

            # Create a figure for the error.
            plt.figure(5); plt.clf(); plt.xlabel('epochs'); plt.ylabel('error'); plt.title(title); plt.grid(True)

            # Plot the error.
            plt.semilogy(iterSmp, error)

            # Define the file name.
            filename = filename0 + 'error' + pltFrmt

            # Define the file path.
            filepath = os.path.join(plotpath, filename)

            # Save the figure.
            plt.savefig(filepath, dpi=300)

            # # Show the plot.
            # plt.show()

    

        
        
        
        
        
        