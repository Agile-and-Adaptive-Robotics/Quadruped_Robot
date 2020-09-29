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
This file provides the classes for Finite Element machinary needed for VarNet class.

"""

# ------------------------------------------------------------ IMPORT NECESSARY LIBRARIES ------------------------------------------------------------

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from UtilityFunc import UF

shape = np.shape
reshape = np.reshape
size = np.size

uf = UF()
        
# ------------------------------------------------------------ DEFINE FINITE ELEMENT CLASS ------------------------------------------------------------
        
class FE():

    """Finite Element class to construct compactly supported basis functions."""
    
    def __init__(self, dim = 2, integPnum = 2):

        """
        Initializer for FE class to construct the compactly supported basis
        functions relevant to the problem at hand.
        
        In order to understand the code note that for simple elements used here,
        the number of nodes on the element is equal to the number of basis functions.
        Moreover, we use one nonzero basis in variational formulation which means
        that the number of elements is equal to the number of nodes and bases as
        well.
        
        Inputs:
            dim: dimension of the problem
            integPnum: number of (Gauss-Legendre) integration points per dimension
            
        Attributes:
            dim
            basisNum: number of FE basis functions per element
            nodeNum: number of nodes around a training point
            basMultiInd: multi-index used to define the ordering of basis functions
            integPnum: number of integration points per dimension
            integP: integration points per dimension
            integW: corresponding integration weights per dimension
            IntegPnum: total number of integration points per element
            IntegP: integration point grid
            IntegW: corresponding integration weight grid
            basVal [basisNum x IntegPnum]: value of basis functions at integration points
            basDeriVal [dim x basisNum x IntegPnum]: derivatives of basis 
                functions at integration point
            elemCoord [dim x basisNum x basisNum]: coordinates of the corners of
                the elements around each training point (nonzero basis function)
            delta [dim, elemnum, IntegPnum]: coordinates of the integration points
                at elements
            IntegW [basisNum, IntegPnum]: integration weights corresponding to
                integration points
            massVec [nodeNum]: mass vector corresponding to nodes around the training point
            massDelta [dim x nodeNum]: translation from the coordinates of the 
                training point to obtain the node coordinates in accordance with
                the mass vector values stored in 'massVec'
        """

        # Validate the user input.
        if integPnum > 3:                   # If the integration order is greater than 3...

            # Throw an error.
            raise ValueError('higher order integration needs code modification!')

        elif integPnum == 2:                  # If the integration order is 2...

            # Compute integration points.
            integP = 1/np.sqrt(3)*np.array([-1, 1])         # numerical integration points
            integW = np.ones(2)                             # corresponding weights

        elif integPnum == 3:                  # If the integration order is 3...

            # Compute integration points.
            integP = np.sqrt(3/5)*np.array([-1, 0, 1])      # numerical integration points
            integW = (1/9)*np.array([5, 8, 5])                # corresponding weights

        # Store parameters.
        self.dim = dim
        self.basisNum = 2**dim                  # two bases functions per dimension - 2**dim for one element
        self.nodeNum = (2 + 1)**dim             # three nodes per dimension for two elements around a training point - 3**dim for all nodes around a training point
        self.basMultiInd = self.basisOrder()
        self.integPnum = integPnum
        self.integP = integP
        self.integW = integW
        self.IntegPnum = integPnum**dim
        self.IntegP = self.integPoint()
        self.basVal = self.basisVal()
        self.basDeriVal = self.basisDeriVal()
        self.elemCoord = self.elemTranslation()
        self.delta = self.integPtranslation()
        self.IntegW = self.integWeight()
        massVec, massDelta = self.massVec()
        self.massVec = massVec
        self.massDelta = massDelta
        
    
    def basisOrder(self):

        """
        Function to standardize the node numbering across the class.
        
        Output:
            order [2**dim, dim]: matrix of multi-indices defining each FE basis function.
        """

        # Retrieve information.
        dim = self.dim
        basisNum = self.basisNum

        # Initialize the order variable.
        order = np.zeros([basisNum, dim], dtype=int)

        # Initialize a temporary order variable.
        order1 = [-1, 1]

        # Determine how to set the order variable.
        if dim == 1:                # If this problem is only a single dimension...

            # Set the order to be the temporary order variable.
            order[:, 0] = order1
            
        elif dim == 2:              # If this problem is a two dimensional problem...

            # Set the order by querying the temporary order variable.
            for i in range(2):
                for j in range(2):

                    order[i*2 + j, :] = [order1[i], order1[j]]
                    
        elif dim == 3:                # If this problem is a three dimensional problem...

            # Set the order by querying the temporary order variable.
            for i in range(2):
                for j in range(2):
                    for k in range(2):

                        order[i*4 + j*2 + k, :] = [order1[i], order1[j], order1[k]]

        # Return the order.
        return order
        
    
    def integPoint(self):

        """
        Function to construct integration points for square elements in a 
        standard way. The importance of this function is to ensure similar 
        ordering of integration points across the class.
        
        Output:
            IntegP [integPnum**dim x dim]: combination of integration points for appropriate problem dimension
        """

        # Retrieve the integration points for a single dimension.
        integP = self.integP

        # Ensure that the integration points are valid.
        if len(shape(integP)) > 1:              # If the integration points for a single dimension are not stored in a vector...

            # Throw an error.
            raise ValueError('integration points for a SINGLE dimension should be stored in a vector!')

        # Retrieve problem information.
        dim = self.dim
        integPnum = self.integPnum                     # number of integration points per dimension
        IntegPnum = self.IntegPnum                     # total number of integration points

        # Initialize the integration points to be zeros of the correct shape.
        IntegP = np.zeros([IntegPnum, dim])

        # Determine the integration points.
        if dim == 1:                                    # If this is a 1D problem...

            # Reshape the integration points.
            IntegP = reshape(integP, [integPnum, 1])
            
        elif dim == 2:                                  # If this is a 2D problem...

            # Compute the integration points.
            for i in range(integPnum):
                for j in range(integPnum):

                    IntegP[i*integPnum + j, :] = [integP[i], integP[j]]
                    
        elif dim == 3:                                  # If this is a 3D problem...

            # Compute the integration points.
            for i in range(integPnum):
                for j in range(integPnum):
                    for k in range(integPnum):

                        ind = i*integPnum**2 + j*integPnum + k
                        IntegP[ind, :] = [integP[i], integP[j], integP[k]]

        # Return the integration points.
        return IntegP
    
    
    
    def basisFE(self, xi, ind):

        """
        Linear FE basis functions. The function recursively computes the FE basis
        function values at given points. The multi-index 'ind' determines the 
        dimension of the problem and corresponding basis functions:
            1D: N_i(xi) = Nb_i(xi)
            2D: N_ij(xi1, xi2) = Nb_i(xi1)*Nb_j(xi2)
            3D: N_ijk(xi1, xi2, xi3) = Nb_i(xi1)*Nb_j(xi2)*Nb_k(xi3)
            where i, j, k are (-1 or +1) and 
            Nb_{-1}(xi) = 0.5*(1 - xi) and Nb_{+1}(xi) = 0.5*(1 + xi)
        
        Inputs:
            xi [n x dim]: coordinates in the mathematical domain
            ind: multi-index of the basis function
            
        Output [nx1]: value of the basis function specified by multi-index 'ind' 
            at evaluation points 'xi'
            
        """

        if np.sum(xi < -1) or np.sum(xi > 1):

            raise ValueError('mathematical coordinate must be in [-1,1]!')
        
        # Recursive implementation:
        if len(ind) == 1:

            return 0.5*(1 + ind[0]*xi[:, 0])

        else:

            return 0.5*(1 + ind[0]*xi[:, 0])*self.basisFE(xi[:, 1:], ind[1:])
        
    
    def basisVal(self):

        """
        Function to compute the FE basis values at numerical integration points.
                
        Output:
            basisV [2**dim, integPnum**dim]: matrix containing the value of each
                FE basis function for all integration points at its rows
        """

        # Retrieve basis and integration information.
        basisNum = self.basisNum
        ind = self.basMultiInd
        IntegPnum = self.IntegPnum
        IntegP = self.IntegP

        # Initialize a vector to store the basis function values.
        basisV = np.zeros([basisNum, IntegPnum])     # store value of basis functions at integration points

        # Evaluate the basis function at each integration point.
        for i in range(len(ind)):                           # Iterate through each index...

            # Evaluate the basis function at this index.
            basisV[i, :] = self.basisFE(IntegP, ind[i, :])

        # Return the basis function evaluated at the integration points.
        return basisV
        
    
    def basisDeriv(self, xi, ind, dInd):

        """
        Derivatives of linear FE basis functions. The function recursively 
        computes the derivatives using
            dNb_{-1}(xi) = -0.5 and dNb_{+1}(xi) = 0.5.
        Note that every level in the recursion belongs to one coordinate thus 
        we track the depth of the recursion to determine which index in the
        multi-index to differentiate wrt.
            
        Inputs:
            xi [n x dim]: coordinates in the mathematical domain
            ind: multi-index of the basis function
            dInd: index of the coordinate the functions should be differentiated wrt
            
        Output [nx1]: derivative of the basis function specified by multi-index
            'ind' wrt the coordinate 'dInd' evaluated at all points in 'xi'
        """


        # Validate the mathematical coordinates.
        if np.sum(xi < -1) or np.sum(xi > 1):

            # Throw an error.
            raise ValueError('mathematical coordinate must be in [-1,1]!')
        
        # Recursive implementation:
        if len(ind) == 1 and dInd == 0:

            return 0.5*ind[0]

        elif len(ind) == 1:                             # If the index of this basis function has length one...

            # Compute the derivative value of the basis function at this value.
            return 0.5*(1 + ind[0]*xi[:, 0])

        elif dInd == 0:                                 # If the coordinate that we are integrating with respect to is zero...

            # Call this function recursively.
            return 0.5*ind[0]*self.basisDeriv(xi[:, 1:], ind[1:], dInd - 1)

        else:

            return 0.5*(1 + ind[0]*xi[:, 0])*self.basisDeriv(xi[:, 1:], ind[1:], dInd - 1)
        
        
    def basisDeriVal(self):

        """
        Function to compute the derivatives of FE bases at numerical integration points.
        
        Output:
            basisDV [dim, 2**dim, integPnum**dim]: tensor containing the 
                derivatives where each level contains derivatives wrt one 
                coordinate and within each level, each row belongs to derivative
                of one basis function wrt all integration points
        """

        # Retrieve basis and integration point information.
        dim = self.dim
        basisNum = self.basisNum
        ind = self.basMultiInd
        IntegPnum = self.IntegPnum
        IntegP = self.IntegP

        # Initialize the FE bases derivatives variable.
        basisDV = np.zeros([dim, basisNum, IntegPnum])     # store derivatives of basis functions at integration points

        # Compute the FE bases derivative values at the the integration points.
        for d in range(dim):                                                    # Iterate through each dimension...
            for i in range(len(ind)):                                           # Iterate through each integration point.

                # Evaluate the FE basis derivative at this integration point.
                basisDV[d, i, :] = self.basisDeriv(IntegP, ind[i, :], d)

        # Return the FE basis derivative at this integration point.
        return basisDV
    
        
    def elemTranslation(self):

        """
        Function to compute the translation vector for numerical integration 
        points to place elements around a single nonzero basis function. Note
        that the process of numerical integration for one basis function on all
        its surrounding elements is exactly equivalent to considering all basis
        functions for a single element.
        
        Output [dim x basisNum x basisNum]: coordinates of the corners of the
            elements corresponding to the basis functions
        """

        # Retrieve basis information.
        dim = self.dim
        nodeNum = self.basisNum
        coord = self.basMultiInd                                # coordinates of corners of the nodes

        # Reshape and tile the coordinates.
        Coord = reshape(coord, newshape=[1, nodeNum*dim])       # flatten the coordinates
        Coord = np.tile(Coord, reps=[nodeNum, 1])                # repeat for all nodes (elements around basis function)
        
        # Translate the corner to (0,0) and scale the element to 1x1:
        coord = np.tile(coord, reps=[1, nodeNum])
        Coord = 0.5*(Coord - coord)
        
        # Split coordinates:
        Coord = reshape(Coord, newshape=[nodeNum**2, dim]).T    # rows of coordinates
        Coord = reshape(Coord, newshape=[dim, nodeNum, nodeNum])

        # Return the coordinates of the corners of the elements corresponding to the basis functions.
        return Coord
        
    
    def integPtranslation(self):

        """
        Function to compute the translation vectors for integration points within
        each element. It uses isoparametric elements where the same basis functions
        interpolate the coordinates in the elements as a function of the corners:
            x = \sum N_i x_i, y = \sum N_i y_i, z = \sum N_i z_i.
        
        Output:
            delta [dim, elemnum, IntegPnum]: coordinates of the integration points at elements
        """

        # Retrieve basis information.
        dim = self.dim
        basVal = self.basVal        # value of basis functions at integration points one at a column
        elemCoord = self.elemCoord  # coordinates of corners of the elements around training point
        IntegPnum = self.IntegPnum  # number of integration points
        nodeNum = self.basisNum     # number of nodes of each element

        # Initialize a variable to store the coordinates of the integration points in the elements.
        delta = np.zeros([dim, nodeNum, IntegPnum])

        # Compute the integration points in the elements.
        for d in range(dim):                # Iterate through each dimension...

            # Compute the integration points in this element.
            delta[d, :, :] = np.dot(elemCoord[d, :, :], basVal)    # coordinate of integration point in each element

        # Return the integration points in this element.
        return delta
        
        
    def integWeight(self):

        """
        Function to construct the integration weights corresponding to the 
        integration points for square elements in a standard way.
        
        Output:
            IntegW [2**dim, integPnum**dim]: combination of integration points for appropriate problem dimension
        """

        # Input data:        
        dim = self.dim
        integPnum = self.integPnum                      # number of integration points per dimension
        IntegPnum = self.IntegPnum                      # total number of integration points
        basisNum = self.basisNum                        # number of basis functions
        integW = self.integW
        IntegW = np.zeros([1, IntegPnum])
        
        # Determine whether all of the integration weights have been set to one.
        if np.prod(integW == np.ones(integPnum)):           # If all of the integration weights have been set to one...

            # Return a None result.
            return None
        
        # Integration weights for one element:
        if dim == 1:                                        # If the problem is one dimensional...

            # Reshape the integration weights.
            IntegW = reshape(integW, [1, integPnum])
            
        elif dim == 2:                                      # If the problem is two dimensional...

            # Compute the integration weight associated with each pair of integration points.
            for i in range(integPnum):                      # Iterate through each integration point...
                for j in range(integPnum):                  # Iterate through each integration point...

                    # Compute the integration weight associated with this pair of integration points.
                    IntegW[0, i*integPnum+j] = integW[i]*integW[j]
                    
        elif dim == 3:                                      # If the problem is three dimensional...

            # Compute the integration weight associated with each set of integration points.
            for i in range(integPnum):                      # Iterate through each integration point...
                for j in range(integPnum):                  # Iterate through each integration point...
                    for k in range(integPnum):              # Iterate through each integration point...

                        # Determine the correct critical index.
                        ind = i*integPnum**2 + j*integPnum + k

                        # Compute the integration weight associated with this set of integration points.
                        IntegW[0, ind] = integW[i]*integW[j]*integW[k]
        
        # Repeat the current integration points.
        IntegW = np.repeat(IntegW, repeats = basisNum, axis = 0)

        # Return the integration points.
        return IntegW


    def basisTot(self, nt, hVec):

        """
        Function to generate the basis function values and derivatives for 
        all training points in the physical domain.
        
        Inputs:
            nt: total number of training points in space-time
            hVec: element scaling across dimensions
            
        Outputs:
            integNum: summation bound for numerical integration at each point
            nT: total number of integration points in the grid
            detJ: determinant of the Jacobian (scaling of the integral)
            delta: relative coordinates of the integration points from training point
            intWeight [1 x integNum]: integration weights for one training point
            N [nTx1]: basis function values for all integration points
            dN [nT x dim]: basis function derivatives for all integration points
        """

        # Retrieve stored data.
        dim = self.dim
        basisNum = self.basisNum                                # number of basis functions (equivalently elements)
        IntegPnum = self.IntegPnum                              # number of integration points
        IntegW = self.IntegW                                    # integral weights for integration points
        
        integNum = basisNum*IntegPnum                           # summation bound for numerical integration at each point
        nT = nt*integNum                                        # total number of integration points
        detJ = np.prod(0.5*hVec)                                # Jacobian scaling of the integral
        delta = reshape(self.delta, [dim, integNum])
        
        if not uf.isnone(IntegW):

            intWeight = reshape(IntegW, newshape=[1, integNum])

        else:

            intWeight = None
            
        N = reshape(self.basVal, newshape=[integNum, 1])        # basis values at integration points ()
        N = np.tile(N, reps=[nt, 1])                            # repeat for trainig points
        
        # Basis derivatives in physical domain:
        nablaPhi = reshape(self.basDeriVal, newshape=[dim, integNum])
        dN = 2/hVec*nablaPhi                                    # derivative of the bases at integration points
        dN = np.tile(dN, reps=[1,nt]).T
        
        return integNum, nT, detJ, delta, intWeight, N, dN



    def massVec(self):

        """
        Function to construct the mass vector corresponding to a training point.
        This mass vector is a row from the standard mass matrix corresponding to
        the training point location.
        This data is used to provide an alternative method to compute the contribution
        of the source term in the variational form. More explicitly, instead of
        integrating the source function at integration points, we construct the
        mass vector and use it with nodal source values to compute this contribution.
        This approach assumes that we approximate the given source function with
        FE bases as 's(x) = sum s_j N_j(x)' where 's_j' denotes the nodal values.
        For a given integration point, the number of these nodal values is
        '(2+1)**dim' which is smaller than the number of evaluations needed
        for the alternative method which is 'integPnum**dim * basisNum'.
        Also note that the entries of the mass vector are given by
            R_j = int N(x)*N_j(x) dx = |J| int phi(xi)*phi_j(xi) dxi.
        Excluding |J| which is applied later along with other quantities in the
        variational form, we calculate the desired mass vector from this equation.
        
        Outputs:
            mvec [(2+1)**dim]: desired mass vector for the training point
            mdelta [dim x (integPnum+1)**dim]: corresponding translation for the
                nodes around the training point in accordance with mass vector values
        """

        # Retrieve basis information.
        dim = self.dim
        basisNum = self.basisNum
        nodeNum = self.nodeNum                                  # number of nodes around the training point: (2+1)**dim
        IntegPnum = self.IntegPnum
        phi = self.basVal
        IntegW = self.IntegW

        # Set the integration weights.
        if not uf.isnone(IntegW):               # If the integration weights were specified...

            # Use the first row of integration weights.
            IntegW = IntegW[0, :]

        else:                                   # Otherwise...

            # Set the integration weights to one.
            IntegW = np.ones([IntegPnum])

        # Retrieve the element coordinates.
        elemCoord = self.elemCoord                              # coordinates of the corners of elements around training point
        
        # Initialize the mass matrix for a single element.
        R = np.zeros([basisNum, basisNum])

        # Compute the mass matrix for a single element.
        for i in range(IntegPnum):                              # Iterate through each integration point...

            # Compute the mass matrix component associated with this integration point.
            R += IntegW[i]*np.matmul(phi[:, i:(i + 1)], phi[:, i:(i + 1)].T)      # contribution of the current integration point
            
        # Define an index matrix that is used to determine the connectivity of
        # nodes for each element and assembly of the mass vector from 'R':
        indMat = np.arange(0, nodeNum).reshape([3]*dim, order = 'F')
        
        # Convert node coordinates of element corners into indices that uniquely
        # associate with indMat entries:
        index = np.ndarray.astype(elemCoord, int) + 1           # map coordinates to indices using indMat
        
        # Construct the desired mass vector and the corresponding translation matrix:
        mvec = np.zeros([nodeNum])                              # mass vector of training point
        mdelta = np.zeros([dim, nodeNum])                       # matrix to store delta values for nodes in accordance to indMat

        for e in range(basisNum):                               # loop over elements
            for i in range(basisNum):                           # loop over corners of elements

                ind = []                                        # indices of the relevant entry of indMat

                for d in range(dim):                            # loop over dimensions

                    ind.append(index[d, e, i])

                ind = indMat[tuple(ind)]                        # index of current node in the small mesh around training point
                mvec[ind] += R[e, i]                             # contribution of basis function of corner 'i' in element 'e' to mass vector at training point

                for d in range(dim):                            # loop over dimensions

                    mdelta[d, ind] = elemCoord[d, e, i]            # coordinates of node 'i' of element 'e' when training point located at origin

        # Return the mass vector.
        return mvec, mdelta
        


    def testComp(self):

        """Function to test FE computations to ensure that they make sense."""

        # Retrieve the problem dimension.
        dim = self.dim
        
        # Plot the node numbering for the element:
        print('\n\n===========================================================')
        print('information about a single simple quad element:\n')
        print('Node numbering for the element:')

        # Retrieve basis information.
        basisNum = self.basisNum
        order = self.basMultiInd
        IntegPnum = self.IntegPnum
        IntegP = self.IntegP


        fig = plt.figure()

        if dim == 1:

            plt.plot(order, np.zeros([basisNum, 1]), 'r.', markersize = 12)
            plt.plot(IntegP, np.zeros([IntegPnum, 1]), 'b.', markersize = 12)

            for b in range(basisNum):

                plt.text(order[b], 0.005, str(b + 1))

            for p in range(IntegPnum):

                plt.text(IntegP[p], 0.005, str(p+1))
                
        elif dim == 2:

            plt.plot(order[:, 0], order[:, 1], 'r.', markersize = 12)
            plt.plot(IntegP[:, 0], IntegP[:, 1], 'b.', markersize = 12)

            for b in range(basisNum):

                plt.text(order[b, 0] + 0.02, order[b, 1] + 0.02, str(b + 1))

            for p in range(IntegPnum):

                plt.text(IntegP[p, 0] + 0.02, IntegP[p, 1] + 0.02, str(p + 1))
                
        elif dim == 3:

            ax = fig.gca(projection = '3d')
            ax.plot(order[:, 0], order[:, 1], order[:, 2], 'r.', markersize = 12)
            ax.plot(IntegP[:, 0], IntegP[:, 1], IntegP[:, 2], 'b.', markersize = 12)

            for b in range(basisNum):

                ax.text(order[b, 0] + 0.02, order[b, 1] + 0.02, order[b, 2] + 0.02, str(b + 1))

            for p in range(IntegPnum):

                ax.text(IntegP[p, 0] + 0.02, IntegP[p, 1] + 0.02, IntegP[p, 2] + 0.02, str(p + 1))
            
        plt.title('mathematical domain')
        plt.grid(True)
        plt.legend(['basis functions', 'integration points'])
        plt.show()
        
        # Check that the basis function values add up to one at integration points:
        print('\nValue of basis functions at integration points:')
        print(np.round(self.basVal, decimals = 3))
        print('\nSum of all bases at integration points:')
        print(np.sum(self.basVal, axis = 0))
        
        # Plot the elements around training point along with their indices:
        print('\n\n===========================================================')
        print('information for the basis function with nonzero coefficient:\n')
        print('positioning of elements around a training point at origin:')
        elemCoord = self.elemCoord  # coordinates of the corners of the elements
        
        fig1 = plt.figure()

        if dim == 1:

            for e in range(basisNum):

                plt.plot(elemCoord[0, e, :], np.zeros(basisNum), 'r.', markersize = 10)
                plt.text(np.mean(elemCoord[0, e, :]), 0.0, 'e ' + str(e + 1))

            plt.plot(0.0, 0.0, 'b*', markersize = 12)               # origin (basis function location)
                
        elif dim == 2:

            plt.ylabel('y')

            for e in range(basisNum):

                plt.plot(elemCoord[0, e, :], elemCoord[1, e, :], 'r.', markersize = 10)
                plt.text(np.mean(elemCoord[0, e, :]), np.mean(elemCoord[1, e, :]), 'e ' + str(e + 1))

            plt.plot(0.0, 0.0, 'b*', markersize = 12)               # origin (basis function location)
                
        elif dim == 3:

            ax = fig1.gca(projection = '3d')

            for e in range(basisNum):

                ax.plot(elemCoord[0, e, :], elemCoord[1, e, :], elemCoord[2, e, :], 'r.', markersize = 10)
                ax.text(np.mean(elemCoord[0, e, :]), np.mean(elemCoord[1, e, :]), np.mean(elemCoord[2, e, :]), 'e ' + str(e + 1))

            ax.plot([0.0], [0.0], [0.0], 'b*', markersize = 12)       # origin (basis function location)
                
        plt.xlabel('x')
        plt.grid(True)
        plt.show()
        
        # Plot the elements around training point along with their basis values:
        print('\nvalue of the basis function at integration points:')
        delta = self.delta          # translations for integration points
        basVal = self.basVal        # corresponding basis values
        
        fig2 = plt.figure()

        if dim == 1:

            for e in range(basisNum):

                plt.plot(elemCoord[0, e, :], np.zeros(basisNum), 'r.', markersize = 10)
                plt.plot(delta[0, e, :], np.zeros(basisNum), 'b.', markersize = 8)

                for i in range(IntegPnum):

                    plt.text(delta[0, e, i] - 0.08, 0.005, str(np.round(basVal[e, i], decimals = 3)))

            plt.plot(0.0, 0.0, 'b*', markersize = 12)           # origin (basin function location)
            
        elif dim == 2:

            plt.ylabel('y')

            for e in range(basisNum):

                plt.plot(elemCoord[0, e, :], elemCoord[1, e, :], 'r.', markersize = 10)
                plt.plot(delta[0, e, :], delta[1, e, :], 'b.', markersize = 8)

                for i in range(IntegPnum):

                    plt.text(delta[0, e, i] - 0.1, delta[1, e, i] + 0.05, str(np.round(basVal[e, i], decimals = 3)))

            plt.plot(0.0, 0.0, 'b*', markersize = 12)           # origin (basin function location)
            
        elif dim == 3:

            ax = fig2.gca(projection = '3d')

            for e in range(basisNum):

                ax.plot(elemCoord[0, e, :], elemCoord[1, e, :], elemCoord[2, e, :], 'r.', markersize = 10)
                ax.plot(delta[0, e, :], delta[1, e, :], delta[2, e, :], 'b.', markersize = 8)

                for i in range(IntegPnum):

                    ax.text(delta[0, e, i] - 0.1, delta[1, e, i], delta[2, e, i] + 0.05, str(np.round(basVal[e, i], decimals = 3)))

            ax.plot([0.0], [0.0], [0.0], 'b*', markersize = 12)    # origin (basis function location)
            
        plt.xlabel('x')
        plt.grid(True)
        plt.show()
        
        # Plot the elements around training point along with their integration weights:
        IntegW = self.IntegW        # corresponding basis values

        if not uf.isnone(IntegW):

            print('\nintegration weights at integration points:')
            
            fig3 = plt.figure()

            if dim == 1:

                for e in range(basisNum):

                    plt.plot(elemCoord[0, e, :], np.zeros(basisNum), 'r.', markersize = 10)
                    plt.plot(delta[0, e, :], np.zeros(basisNum), 'b.', markersize = 8)

                    for i in range(IntegPnum):

                        plt.text(delta[0, e, i] - 0.08, 0.005, str(np.round(IntegW[e, i], decimals = 3)))

                plt.plot(0.0, 0.0, 'b*', markersize = 12)           # origin (basin function location)
                
            elif dim == 2:

                plt.ylabel('y')

                for e in range(basisNum):

                    plt.plot(elemCoord[0, e, :], elemCoord[1, e, :], 'r.', markersize = 10)
                    plt.plot(delta[0, e, :], delta[1, e, :], 'b.', markersize = 8)

                    for i in range(IntegPnum):

                        plt.text(delta[0, e, i] - 0.1, delta[1, e, i] + 0.05, str(np.round(IntegW[e, i], decimals = 3)))

                plt.plot(0.0, 0.0, 'b*', markersize = 12)           # origin (basin function location)
                
            elif dim == 3:

                ax = fig3.gca(projection = '3d')

                for e in range(basisNum):

                    ax.plot(elemCoord[0, e, :], elemCoord[1, e, :], elemCoord[2, e, :], 'r.', markersize = 10)
                    ax.plot(delta[0, e, :], delta[1, e, :], delta[2, e, :], 'b.', markersize = 8)

                    for i in range(IntegPnum):

                        ax.text(delta[0, e, i] - 0.1, delta[1, e, i], delta[2, e, i] + 0.05, str(np.round(IntegW[e, i], decimals = 3)))

                ax.plot([0.0], [0.0], [0.0], 'b*', markersize = 12)    # origin (basis function location)
                
            plt.xlabel('x')
            plt.grid(True)
            plt.show()

        
        print('\n\n===========================================================')
        print('information for the mass vector corresponding to the training point:')
        
        # Plot the element corners around the training point along with their contribution to mass vector:
        nodeNum = self.nodeNum
        massVec = self.massVec
        massDelta = self.massDelta
        
        fig2 = plt.figure()

        if dim == 1:

            plt.plot(massDelta[0, :], np.zeros(nodeNum), 'r.', markersize = 10)

            for i in range(nodeNum):

                plt.text(massDelta[0, i], -0.01, str(i))
                plt.text(massDelta[0, i] - 0.08, 0.005, str(np.round(massVec[i], decimals = 3)))

            plt.plot(0.0, 0.0, 'b*', markersize = 12)           # origin (basin function location)
            
        elif dim == 2:

            plt.ylabel('y')
            plt.plot(massDelta[0, :], massDelta[1, :], 'r.', markersize = 10)

            for i in range(nodeNum):

                plt.text(massDelta[0, i] - 0.03, massDelta[1, i] - 0.15, str(i))
                plt.text(massDelta[0, i] - 0.1, massDelta[1, i] + 0.05, str(np.round(massVec[i], decimals = 3)))

            plt.plot(0.0, 0.0, 'b*', markersize = 12)           # origin (basin function location)

        elif dim == 3:

            ax = fig2.gca(projection = '3d')
            ax.plot(massDelta[0, :], massDelta[1, :], massDelta[2, :], 'r.', markersize = 10)

            for i in range(nodeNum):

                ax.text(massDelta[0, i] - 0.03, massDelta[1, i], massDelta[2, i] - 0.25, str(i))
                ax.text(massDelta[0, i] - 0.1, massDelta[1, i], massDelta[2, i] + 0.05, str(np.round(massVec[i], decimals = 3)))

            ax.plot([0.0], [0.0], [0.0], 'b*', markersize = 12)    # origin (basis function location)
            
        plt.xlabel('x')
        plt.grid(True)
        plt.show()
        
        
        
