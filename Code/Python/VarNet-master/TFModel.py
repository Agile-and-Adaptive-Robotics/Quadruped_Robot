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
This file contains the classes to build a NN model using TensorFlow for the AD-PDE.

"""


# ------------------------------------------------------------ IMPORT NECESSARY LIBRARIES ------------------------------------------------------------

# Import the necessary libraries.
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras import layers
from tensorflow.python.client import device_lib
from UtilityFunc import UF

# Create function aliases.
shape = np.shape
reshape = np.reshape
size = np.size
uf = UF()


# ------------------------------------------------------------ TENSORFLOW NEURAL NETWORK CLASS ------------------------------------------------------------
        
class TFNN():

    """
    Class to construct the tensorflow computational graph and models across devices.
    
    Attributes:
        dim
        inpDim
        seqLen
        depth
        layerWidth
        modelId
        activationFun
        timeDependent
        RNNdata
        graph: TensorFlow computational graph that stores the data
        model: NN model
        processorNum: number of processing units
        processors: processors to be used for training (GPU or CPU)
        controller: controller for parallel programming
        lossOpt [dict]: dictionary containing data to optimize the loss function
        learning_rate
        optimizer_name: to be used for training: Adam, RMSprop
        compTowers: list of 'NNModel' objects corresponding to the processors
        optimSetup variables:
            step
            saver
            loss
            optMinimize
            sess
    """

    # -------------------- CONSTRUCTOR --------------------

    # Implement the tensorflow neural network constructor.
    def __init__(self, dim, inpDim, layerWidth, modelId, activationFun, timeDependent, RNNdata, processors, controller, lossOpt, optimizer_name, learning_rate):

        """
        Class to construct the tensorflow variables, model, loss function on a 
        single computational graph across multiple devices.
        
        Inputs:
            dim: dimension of the spatial domain
            inpDim: number of the NN inputs
            layerWidth [lNum x 1]: widths of the hidden layers
            modelId: indicator for the sequential TensorFlow model to be trained:
                'MLP': multi-layer perceptron with 'sigmoid' activation
                'RNN': recurrent network with 'gru' nodes
            activationFun: activation function used in layers
            timeDependent: boolean to specify time-dependent PDEs
            RNNdata: data of the RNN including the sequence length
            processors: processor(s) to be used for training (GPUs or CPU)
                data is split between processors if more than one is specified 
            controller (CPU or GPU): processor to contain the training data and
                perform optimization in the parallel setting
            lossOpt [dict]: dictionary containing data to optimize the loss function:
                integWflag: if True include integration weights in the loss function
                isSource: if True the source term is not zero in the PDE
            optimizer_name: to be used for training: Adam, RMSprop
            learning_rate: learning rate for Adam optimizer
        """

        # Define the depth of the network.
        depth = len(layerWidth)

        # Create a list of activation functions (one per layer).
        if type(activationFun) == str:                        # If the activation function is a string...

            # Create a list of activation functions.
            activationFun = [activationFun]*depth

        elif type(activationFun) == list and len(activationFun) == 1:   # If the activation function is a list of length one...

            # Tile the activation function list to the correct length.
            activationFun = activationFun*depth

        elif not len(activationFun) == depth:                         # If the activation function length is not the same length as the network depth...

            # Throw an error.
            raise ValueError('activation function list is incompatible with number of layers!')

        # Determine whether the requested processors are available.
        processors, flag = self.get_processor(processors)

        # Retrieve the number of processors.
        puNum = len(processors)

        # Ensure that all of the requested processors are available.
        for i in range(puNum):                  # Iterate through each of the specified processors...

            # Determine whether this processor is available.
            if not flag[i]:                 # If this processor is not available...

                # Throw an error.
                raise ValueError('requested processor %i is unavailable!' % i)

        # Determine whether the controller is available.
        controller, flag = self.get_processor(controller)

        # Retrieve the first controller.
        controller = controller[0]

        # Determine whether this controller is available.
        if not flag:                    # If this controller is not available...

            # Throw an error.
            raise ValueError('requested controller is unavailable!')

        # Determine whether the learning rate is plausible.
        if learning_rate < 0.0:             # If the learning rate is negative...

            # Throw an error.
            raise ValueError('learning rate must be positive!')

        # Determine whether the optimizer is rms.
        if optimizer_name.lower() == 'rms':               # If the specified optimizer is rms...

            # Set the optimizer name to rms prop.
            optimizer_name = 'rmsprop'

        # Determine whether the requested optimizer is valid.
        if not (optimizer_name.lower() == 'adam' or optimizer_name.lower() == 'rmsprop'):           # If the optimizer is not valid...

            # Throw an error.
            raise ValueError('unknown optimizer requested!')
        
        # Get the available GPUs.
        gpuList = self.get_available_gpus()

        # Determine how to specify the processors and controllers.
        if uf.isnone(processors) and uf.isnone(controller):         # If neither processors nor controllers were specified...

            # Determine whether to use a GPU for training.
            if uf.isempty(gpuList):             # If there are no GPUs available...

                # State that we are using the default processors and controllers.
                print('\nUsing CPU for training ...')
                processors = ['/device:CPU:0']
                controller = '/device:CPU:0'

            else:

                # State that we are using the first available GPU for training.
                print('\nUsing first available GPU for training ...')
                processors = gpuList[0:1]
                controller = gpuList[0]

        elif not uf.isnone(processors) and uf.isnone(controller):               # If a controller was not specified, but a processor was...

            # Determine which processor to use.
            if type(processors) == list and len(processors) == 1:               # If only one processor was specified...

                # Set the controller to be the same as the processor.
                controller = processors[0]

            elif type(processors) == str:                                       # If the processor was specified as a string...

                # Set the controller to be the same as the processor.
                controller = processors

            else:

                # State that we are using the CPU as the controller.
                print('\nUsing the CPU as the controller for parallel training ...')

                # Set the controller to be the CPU.
                controller = 'CPU:0'

        elif uf.isnone(processors) and not uf.isnone(controller):               # If a processor was specified but not a controller...

             # Determine whether there are enough GPUs for use as a processor.
            if len(gpuList) <= 1:                                               # If the GPU list is less than one...

                # Throw an error.
                raise ValueError('not enough GPUs for parallel training!')

            else:

                # State that we are using the GPUS for training.
                print('\nUsing all available GPUs for parallel training ...')

                # Assign the processor to be the GPU.
                processors = gpuList
        
        # Store parameters.
        self.dim = dim
        self.inpDim = inpDim
        self.depth = depth
        self.layerWidth = layerWidth
        self.modelId = modelId
        self.activationFun = activationFun
        self.timeDependent = timeDependent
        self.RNNdata = RNNdata
        self.processorNum = puNum           # number of processing units
        self.processors = processors
        self.controller = controller
        self.lossOpt = lossOpt
        self.optimizer_name = optimizer_name
        self.learning_rate = learning_rate
        
        # Create the computational graph and central optimizer.
        graph = tf.Graph()                  # computational graph of the class

        # Define the shared model.
        with graph.as_default(), tf.device(controller):

            # Define the tensorflow model.
            self.defModel()                 # define the shared model

            # Determine how to define the optimizer.
            if optimizer_name.lower() == 'adam':                  # If the optimizer is Adam...

                # Create an Adam optimizer.
                optimizer = tf.train.AdamOptimizer(learning_rate, name = 'Optimizer')

            elif optimizer_name.lower() == 'rmsprop':             # If the optimizer is RMS prop...

                # Create an RMS Prop optimizer.
                optimizer = tf.train.RMSPropOptimizer(learning_rate, name = 'Optimizer')

        # Store the graph and optimizer.
        self.graph = graph
        self.optimizer = optimizer

        # Setup the tower.
        self.towerSetup()

        # Setup the optimizer.
        self.optimSetup()                   # setup the optimization nodes and start the session
        
        
    # Implement a function to define the neural network model.
    def defModel(self):

        """Function to setup the NN model according to PDE and MOR parameters."""

        # Determine whether the model is already defined.
        if hasattr(self, 'model'):              # If the tensorflow model has already been defined...

            # Throw an error.
            raise Exception('model is already defined!')

        # Retrieve some parameters.
        inpDim = self.inpDim
        layerWidth = self.layerWidth
        depth = self.depth
        modelId = self.modelId
        activFun = self.activationFun

        # Create the model.
        with tf.name_scope('defModel'):             # Define the scope of interest.

            # Initialize the model as sequential.
            model = Sequential()

            # Determine the model type.
            if modelId == 'MLP':                    # If the specified model type is MLP...

                # Create the first layer.
                model.add(layers.Dense(layerWidth[0], activation = activFun[0], input_shape = (inpDim,), kernel_initializer = 'glorot_uniform', name = 'dense_0'))

                # Create each layer.
                for d in range(depth - 1):                    # loop over network depth

                    # Create the name for this layer.
                    name = 'dense_' + str(d + 1)

                    # Create this layer.
                    model.add(layers.Dense(layerWidth[d + 1], activation = activFun[d + 1], kernel_initializer = 'glorot_uniform', name = name))
                    
            elif modelId == 'RNN':                  # If the specified model type is RNN...

                # Retrieve the sequence length.
                seqLen = self.RNNdata.seqLen                # number of time discretizations

                # Define the first RNN layer.
                # model.add(layers.GRU(layerWidth[0], activation = activFun[d + 1], recurrent_activation = 'hard_sigmoid', input_shape = (seqLen, inpDim), return_sequences = True, kernel_initializer = 'he_uniform', unroll=True, name='gru_0'))
                model.add(layers.GRU(layerWidth[0], activation = activFun[0], recurrent_activation = 'hard_sigmoid', input_shape = (seqLen, inpDim), return_sequences = True, kernel_initializer = 'he_uniform', unroll=True, name='gru_0'))

                # Define the rest of the RNN layers.
                for d in range(depth - 1):                    # Iterate through each layer...

                    # Define the name of this layer.
                    name = 'gru_' + str(d + 1)

                    # Generate this next layer.
                    model.add(layers.GRU(layerWidth[d + 1], activation = activFun, recurrent_activation = 'hard_sigmoid', return_sequences = True, kernel_initializer = 'he_uniform', unroll=True, name = name))

            # Generate the output layer.
            model.add(layers.Dense(1, name='output'))      # output layer
            
        # Print out the number of inputs.
        print('\nNumber of inputs:', inpDim)

        # Print out the model summary.
        model.summary()
        
        # Store the model.
        self.model = model                                  # add the model to the attributes
        
    
    
    def towerSetup(self):

        """
        Function to setup the computational towers located on the requested device.
        """

        # Ensure that the computational towers are not already defined.
        if hasattr(self, 'compTowers'):                 # If the computational towers are already defined...

            # Throw an error.
            raise Exception('computational towers are already defined!')
            
        # Retrieve stored data.
        dim = self.dim
        inpDim = self.inpDim
        modelId = self.modelId
        timeDependent = self.timeDependent
        RNNdata = self.RNNdata
        puNum = self.processorNum           # number of processing units
        processors = self.processors
        lossOpt = self.lossOpt
        graph = self.graph
        model = self.model
        optimizer = self.optimizer
        
        # Initialize the computational towers.
        compTowers = []                     # instances of 'NNModel' for computational towers (processors)

        # Setup the towers.
        with graph.as_default():

            # Setup each processor.
            for i, pu in enumerate(processors):      # Iterate through each processor...

                # Retrieve the the name of this processor.
                name = 'tower_{}'.format(i)

                # Setup this processor.
                with tf.device(pu), tf.name_scope(name):

                    # Determine whether we have multiple processors.
                    if puNum > 1:               # If we have multiple processors...

                        # Print this tower.
                        print('\n\nTower %i:' % i)
                    
                    # Create an instance of class 'NNModel' and add it to list:
                    compTowers.append(NNModel(dim, inpDim, modelId, timeDependent, RNNdata, lossOpt, model, optimizer))

                    # Determine whether we have multiple processors.
                    if puNum > 1:               # If we have multiple processors...

                        # Print out status information.
                        print('\n' + '-'*80)
        
        # Store the computational tower data.
        self.compTowers = compTowers        # computational towers to be used for training
        


    def optimSetup(self):

        """Function to define the saver and optimization nodes. """

        # Determine whether the optimization node is already setup.
        if hasattr(self, 'optMinimize'):                # If the optimization node is setup...

            # Throw an error.
            raise Exception('optimization node is already defined!')
            
        # Retrieve stored data.
        puNum = self.processorNum
        controller = self.controller
        graph = self.graph
        optimizer = self.optimizer
        compTowers = self.compTowers
        
        with graph.as_default():

            # Define the saver.
            saver = tf.train.Saver(max_to_keep = 2)           # save optimization state

            # State that the saver has been constructed.
            print('\nsaver constructed.')

            # Setup the losses.
            with tf.name_scope('optimSetup'), tf.device(controller):

                # Compute the loss gradient.
                grad = self.sum_grads()

                # Get the current global step.
                step = tf.train.get_or_create_global_step()

                # Apply the current gradients.
                apply_grad = optimizer.apply_gradients(grad, global_step = step, name = 'optimizer')

                # Compute the losses over all of the towards.
                loss = tf.reduce_sum([compTowers[pu].loss for pu in range(puNum)], name = 'loss')
                BCloss = tf.reduce_sum([compTowers[pu].BCloss for pu in range(puNum)], name = 'BCloss')
                ICloss = tf.reduce_sum([compTowers[pu].ICloss for pu in range(puNum)], name = 'ICloss')
                varLoss = tf.reduce_sum([compTowers[pu].varLoss for pu in range(puNum)], name = 'varLoss')
                lossVec = tf.concat([compTowers[pu].lossVec for pu in range(puNum)], axis = 0, name = 'lossVec')

                # State that the optimizer has been constructed.
                print('optimizer constructed.\n')

            # Configure the processors.
            config = tf.ConfigProto(log_device_placement = False)
#            config.gpu_options.allow_growth = True

            # Start a new training session.
            sess = tf.Session(config=config)                # start a new training session

            # Initialize the tensorflow variables.
            sess.run(tf.global_variables_initializer())     # initialize all variables
        
        # Store the aggregate data.
        self.step = step
        self.saver = saver
        self.optMinimize = apply_grad
        self.sess = sess
        
        self.loss = loss
        self.BCloss = BCloss                                # BCs loss component
        self.ICloss = ICloss                                # ICs loss component
        self.varLoss = varLoss                              # variational loss component
        self.lossVec = lossVec                              # variational loss field



    def sum_grads(self):

        """
        Function to compute the gradient of shared trainable variable across all towers.
        Note that this function provides a synchronization point across all towers.
        The output of the 'compute_gradients()', used in 'NNModel', is a list of 
        (gradient, variable) tuples that ranges over the trainable variables.
                
        Output: list of pairs of (gradient, variable)
        """

        # Retrieve model data.
        puNum = self.processorNum
        compTowers = self.compTowers

        # Determine whether we only need to compute the gradient associated with a single computational tower.
        if puNum == 1:                          # If we only have a single computational tower...

            # Return the gradient from this single computational tower.
            return compTowers[0].grad
        
        # Collect gradients from different towers:
        tower_grads = []
        for tower in compTowers:
            tower_grads.append(tower.grad)
            
        # Sum gradients for individual variables:
        grad_varTot = []
        for i, grad_var in enumerate(zip(*tower_grads)):        # loop over trainable variables

            # Each grad_and_vars looks like the following:
            # ((grad0_gpu0, var0_gpu0), ... , (grad0_gpuN, var0_gpuN))
            grads = [g for g, _ in grad_var]
            grad = tf.reduce_sum(grads, 0, name = 'grad_sum_' + str(i))
    
            # Since variables are shared among towers, we use the first tower's variables:
            var = grad_var[0][1]
            grad_var = (grad, var)
            grad_varTot.append(grad_var)
        
        return grad_varTot
            


    def get_available_gpus(self):

        """
        Function to return the list of all visible GPUs.
        """

        # Retrieve the available devices.
        local_device_protos = device_lib.list_local_devices()

        # From among the available devices, return any available GPUs.
        return [x.name for x in local_device_protos if x.device_type == 'GPU']


    # Implement a function to determine whether a specific processor is available.
    def get_processor(self, processors):

        """
        Function to determine if requested processors (CPU or GPU) is available.
        The processors should be specified as 'CPU:i' or 'GPU:i' where i is the
        index of the processor.
        """

        # Ensure that the processors variable is a list.
        if not type(processors) == list:              # If the processors variable is not a list...

            # Convert the processors to a list.
            processors = [processors]

        # Retrieve the number of processing units.
        puNum = len(processors)                         # number of processing units

        # Determine whether the processes variable was specified.
        if uf.isnone(processors):           # If the processors variable is empty...

            # Create a flag that specifies that all of the processes are true.
            flag = [True]*puNum

            # Return the processors and the flag.
            return processors, flag

        # Retrieve the local devices.
        local_device_protos = device_lib.list_local_devices()

        # Initialize a flag variable to indicate that every processor is false.
        flag = [False]*puNum

        # Determine whether to set the processor flags to true.
        for i in range(puNum):                  # Iterate through each processor...
            for x in local_device_protos:       # Iterate through each protocol...

                # Determine whether to set this processor flag to true.
                if x.name[8:].lower() == processors[i].lower():         # Determine whether this is the specified processor...

                    # Set this flag to true.
                    flag[i] = True

                    # Leave this iteration.
                    break

            # Label this processor.
            processors[i] = '/device:' + processors[i].upper()

        # Return the processors and flag.
        return processors, flag
    
    
        
    def assign_to_device(self, processor, controller):
        """
        Returns a function to place variables on the controller.
    
        Inputs:
            processor: device for everything but variables
            controller: device to put the trainable variables on
    
        If 'controller' is not set, the variables will be placed on the default processor.
        The best processor for shared varibles depends on the platform as well 
        as the model. Start with 'CPU:0' and then test 'GPU:0' to see if there 
        is an improvement.
        """

        varNames = ['Variable', 'VariableV2', 'AutoReloadVariable', 'MutableHashTable', 'MutableHashTableOfTensors', 'MutableDenseHashTable']
        
        def _assign(op):

            node_def = op if isinstance(op, tf.NodeDef) else op.node_def

            if node_def.op in varNames:

                return controller

            else:

                return processor

        return _assign



# ------------------------------------------------------------ NEURAL NETWORK MODEL CLASS ------------------------------------------------------------

class NNModel():

    """
    Class to construct the tensorflow computational model on a given device.
    
    Attributes:
        dim
        inpDim
        seqLen
        modelId
        model: NN model
        modelGrad variables:
            Input
            dM_dt
            dM_dx
            d2M_dx2
        LossFun variables:
            bDof
            w
            intShape
            detJ
            integW
            biDimVal
            source
            gcoef
            N
            dNt
            biInput
            biLabel
            loss
            detJvec
        grad: gradient of the loss function wrt to trainable variables
        Residual variables:
            diff
            vel
            diff_dx
            res
    """
    
    def __init__(self, dim, inpDim, modelId, timeDependent, RNNdata, lossOpt, model, optimizer):

        """
        Class to construct the tensorflow variables, model, loss function on a 
        single computational graph.
        
        Input:
            dim: dimension of the spatial domain
            inpDim: number of the NN inputs
            modelId: indicator for the sequential TensorFlow model to be trained:
                'MLP': multi-layer perceptron with 'sigmoid' activation
                'RNN': recurrent network with 'gru' nodes
            timeDependent: boolean to specify time-dependent PDEs
            RNNdata: data of the RNN including the sequence length
            lossOpt [dict]: dictionary containing data to optimize the loss function:
                integWflag: if True include integration weights in the loss function
                isSource: if True the source term is not zero in the PDE
            model: NN model that is shared among the computational towers
            optimizer: optimization node to update the weights
        """

        # Store the input data.
        self.dim = dim
        self.inpDim = inpDim
        self.modelId = modelId
        self.RNNdata = RNNdata
        self.timeDependent = timeDependent
        self.optimizer = optimizer
        self.model = model                  # shared model among computational towers

        # Compute the model gradients.
        self.modelGrad()                    # Compute the gradient of the network output with respect to its input.

        # Compute the loss function.
        self.LossFun(lossOpt)               # Define the loss function.

        # Compute the loss gradient.
        self.computeGrad()                  # compute the gradient of loss function with respect to weights and biases.

        # Compute the model residual.
        self.Residual()                     # Function to compute the PDE residual field
    
    
    
    def modelGrad(self):

        """
        Function to define the model gradients. We assume that the order of 
        inputs to the NN are 'x, t, MOR parameters'.
        """

        # Determine whether the variables and gradients are already defined.
        if hasattr(self, 'Input'):              # If the variables and gradients are already defined...

            # Throw an error.
            raise ValueError('Variables and gradients are already defined!')
        
        # Retrieve model data.
        dim = self.dim
        model = self.model
        modelId = self.modelId
        inpDim = self.inpDim
        
        with tf.name_scope('model_grad'):

            # Create an input placeholder.
            Input = tf.placeholder(tf.float32, name = 'Input')    # inner-domain nodes

            # Determine how to compute the gradients.
            if modelId == 'MLP':                    # If the model is MLP...

                # Set the shape of the input layer.
                Input.set_shape([None, inpDim])

                # Compute the gradient of the network output with respect to the network inputs.
                dM_dx = tf.gradients(model(Input), Input)[0]    # first order derivative wrt inputs

                # Determine the derivative of the network output with respect to time.
                if self.timeDependent:                      # If the problem is time dependent...

                    # The time derivative of the network output is the final coordinate of the input gradient calculation.
                    dM_dt = dM_dx[:, dim:(dim + 1)]

                else:                                       # Otherwise...

                    # Set the time derivative of the output to be zero.
                    dM_dt = None

                # Define the spatial gradient of the network's output by removing the temporal derivative component.
                dM_dx = dM_dx[:, 0:dim]                          # keep only relevant derivatives

                # Compute the first component of the second derivative of the network output with respect to the first spatial dimension.
                d2M_dx2 = tf.gradients(dM_dx[:, 0], Input)[0][:, 0:1]

                # Sum the diagonal second derivative gradient components of each input.         THIS MOST LIKELY HAS TO DO WITH THE VARIATIONAL FORM / ODE IMPLEMENTATION.
                for d in range(1, dim):                          # second order derivative wrt x_d

                    # Sum the diagonal second derivative gradient components of each input.
                    d2M_dx2 = d2M_dx2 + tf.gradients(dM_dx[:, d], Input)[0][:, d:(d + 1)]
                
            elif modelId == 'RNN':                  # If the model is RNN...

                # Retrieve the sequence length.
                seqLen = self.RNNdata.seqLen                    # number of time discretizations

                # Set the input shape.
                Input.set_shape([None, seqLen, inpDim])

                # Compute the gradient of the RNN output with respect to each input.
                dM_dx = self.gradRNN(model, Input)              # first order derivative wrt inputs

                # Retrieve the temporal component of the gradient.
                dM_dt = dM_dx[:, :, dim:(dim + 1)]                    # derivative wrt to time

                # Retrieve the spatial component of the gradient.
                dM_dx = dM_dx[:, :, 0:dim]                        # keep only relevant derivatives

                # Set the second order derivative with respect to the spatial variables.
                d2M_dx2 = None                                  # it is computationally very demanding to compute

#                d2M_dx2 = tf.gradients(dM_dx[:,:,0], Input)[0][:,:,0:1]
#                for d in range(1,dim):                          # second order derivative wrt x_d
#                    d2M_dx2 = d2M_dx2 + tf.gradients(dM_dx[:,:,d], Input)[0][:,:,d:(d+1)]
                
        # Store the input and gradient values.
        self.Input = Input
        self.dM_dt = dM_dt
        self.dM_dx = dM_dx
        self.d2M_dx2 = d2M_dx2
        
        
    def LossFun(self, lossOpt):

        """
        Define training loss function.
        
        Note: the determinant of the Jacobian matrix is not properly applied.
              Specifically, detJ**2 must multiply the numerical integration
              result and not detJ. This is because we square the variational
              term below. This is not a problem for identical test functions 
              since detJ acts as a scaling and can be combined with weight value,
              but for non-identical test function supports, the calculation is
              inaccurate.
        
        Inputs:
            lossOpt [dict]: dictionary containing data to optimize the loss function:
                integWflag: if True include integration weights in the loss function
                isSource: if True the source term is not zero in the PDE
        """

        # Determine whether the loss function is already defined.
        if hasattr(self, 'loss'):                   # If the loss function has already been defined...

            # Throw an error.
            raise ValueError('Loss function is already defined!')

        # State that we are generating the loss function.
        print('\nloss function in construction ...')
        
        # Retrieve problem information.
        dim = self.dim
        inpDim = self.inpDim
        timeDependent = self.timeDependent
        modelId = self.modelId
        model = self.model
        Input = self.Input
        dM_dx = self.dM_dx
        
        # Define the loss computation node:
        with tf.name_scope('loss_fun'):

            # Define the boundary condition input placeholder.
            biInput = tf.placeholder(tf.float32, name = 'biInput'); biInput.set_shape([None, inpDim])       # boundary nodes

            # Define the boundary condition output placeholder.
            biLabel = tf.placeholder(tf.float32, name = 'biLabel'); biLabel.set_shape([None, 1])            # boundary labels

            # Define placeholder to store the total number of boundary nodes over space-time.
            bDof = tf.placeholder(tf.int32, name = 'bDof')                                                  # total number of boundary nodes over space-time

            # Define a placeholder for the weights.
            w = tf.placeholder(tf.float32, name = 'w')                                                      # weights for loss function

            # Define a placeholder for the number of integration points per element.
            intShape = tf.placeholder(tf.int32, name = 'intShape')                                          # number of integration points per element

            # Define a placeholder for the Jacobian.
            detJ = tf.placeholder(tf.float32, name = 'detJ')                                                # determinant of the Jacobian

            # Define a placeholder for the integration weights.
            integW = tf.placeholder(tf.float32, name = 'integW')                                            # integration weights

            # Define a placeholder for the boundary-initial condition dimensional correction.
            biDimVal = tf.placeholder(tf.float32, name = 'biDimVal')                                        # dimensional correction for boundary-initial condition

            # Define a placeholder for the source term.
            source = tf.placeholder(tf.float32, name = 'source'); source.set_shape([None, 1])               # source term

            # Define a placeholder for the PDE coefficients.
            gcoef = tf.placeholder(tf.float32, name = 'gcoef'); gcoef.set_shape([None, dim])                # coefficient of \nabla c

            # Define a placeholder for the FE basis function values at the integration points.
            N = tf.placeholder(tf.float32, name = 'N'); N.set_shape([None, 1])                              # FE basis function values at integration points

            # Define a placeholder for the time-derivative of the FE basis functions at the integration points.
            dNt = tf.placeholder(tf.float32, name = 'dNt'); dNt.set_shape([None, 1])                        # time-derivative of the FE basis functions at integration points

            # Define a placeholder for the determinant of the jacobian vector.
            detJvec = tf.placeholder(tf.bool, shape = [], name = 'detJvec')
    
            # Compute the PDE components:
            if modelId == 'MLP':                                    # If the model is a MLP...

                # Evaluate the network at the boundary / initial condition input.
                biVal = model(biInput)

                # Evaluate the network at the input.
                Val = model(Input)

                # Transfer over the gradient.
                grad = dM_dx
                
            elif modelId == 'RNN':                                  # If the model is a RNN...

                # Store the RNN data.
                RNNdata = self.RNNdata

                # Retrieve data from the RNN data.
                seqLen = RNNdata.seqLen                             # number of time discretizations
                bdof = RNNdata.bdof                                 # number of boundary nodes
                integInd = RNNdata.integInd                         # mapping from RNN to numerical integration

                # Evaluate the model at the input.
                Val = model(Input)

                # Retrieve the boundary and initial condition network outputs.
                bVal = tf.reshape(Val[0:bdof, :, 0], [bdof*seqLen, 1])
                iVal = Val[bdof:, 0:1, 0]

                # Concatenate the boundary and initial condition network outputs.
                biVal = tf.concat([bVal, iVal], axis = 0)

                # Gather the network outputs and gradient.
                Val = tf.gather_nd(Val, indices = integInd, name = "gatherNd")
                grad = tf.gather_nd(dM_dx, indices = integInd, name = "gatherNd")
            
            # Compute the boundary and initial condition error.
            biCs = biDimVal*(biVal - biLabel)**2

            # Retrieve only the boundary condition error.
            bCs = biCs[:bDof, 0:1]                                   # boundary condition error term

            # Compute the reduced mean of the boundary condition errors.
            bCs = tf.reduce_mean(bCs)

            # Compute the initial condition error.
            if timeDependent:                                        # If this problem is time dependent...

                # Retrieve only the initial condition error.
                iCs = biCs[bDof:, 0:1]                               # initial condition error term

                # Compute the reduced mean of the initial condition errors.
                iCs = tf.reduce_mean(iCs)                            # returns nan for empty tensor

            else:

                # Set the IC error to zero.
                iCs = tf.constant(0.0, dtype = tf.float32, name = 'constIC')


            # ------------------------------ THIS LOOKS LIKE THE PLACE TO DEFINE THE PDE ERROR ------------------------------

            # Gauss-Legendre integration of the PDE '\nabla c (kapa*\nabla v + bbu*v) - c*vdot'.

            # Compute the \nabla c contribution to the integrand.
            int1 = tf.multiply(grad, gcoef)                             # \nabla c contribution to integrand

            # Compute the reduced sum of the integrand error (so far).
            int1 = tf.reduce_sum(int1, axis = -1, keepdims = True)      # inner-product (sum over coordinates)

            # Determine whether to account for the time-derivative loss.
            if timeDependent:                                           # If this problem is time-dependent...

                # Compute the time-derivative contribution to the integrand.
                int1 = int1 - tf.multiply(Val, dNt)       # contribution of time-derivative to integrand

            # Determine whether to account for the source error.
            if lossOpt['isSource']:                                     # If this is the source error...

                # Compute the source-term contribution to the integrand.
                int1 = int1 - tf.multiply(source, N)                    # contribution of source-term to integrand

            # Reshape the training data.
            int1 = tf.reshape(int1, intShape)                           # reshape back for each training point

            # Apply the integration weights.
            if lossOpt['integWflag']:                                   # If we were asked to apply the integration weights...

                # Apply the integration weights.
                int1 = integW*int1                # integration weights

            # Sum over integration points and elements.
            int1 = tf.reduce_sum(int1, axis = -1, keepdims = True)**2   # sum over integration points and elements

            # Compute the integrand error term.
            int2 = tf.cond( detJvec, lambda: tf.reduce_sum(detJ*int1), lambda: detJ*tf.reduce_sum(int1) )           # sum of errors at training points # move 'detJ' outside for computational efficiency

            # Compute the aggregate loss.
            loss = w[0]*bCs + w[1]*iCs + w[2]*int2                      # loss value used for training

            # Compute the loss vector.
            lossVec = detJ*int1                                         # vector of loss values across domain
        
        # Store the loss data.
        self.bDof = bDof
        self.w = w
        self.intShape = intShape
        self.detJ = detJ
        self.integW = integW
        self.biDimVal = biDimVal
        self.source = source
        self.gcoef = gcoef
        self.N = N
        self.dNt = dNt
        self.biInput = biInput
        self.biLabel = biLabel
        self.loss = loss
        self.detJvec = detJvec

        # Store the loss components.
        self.BCloss = bCs                                           # BCs loss component
        self.ICloss = iCs                                           # ICs loss component
        self.varLoss = int2                                         # variational loss component
        self.lossVec = lossVec                                      # variational loss field

        # State that the loss function is constructed.
        print('loss function constructed.\n')
            


    def computeGrad(self):

        """
        Function to compute the gradient of the loss function wrt the trainable variables.
        """

        # Ensure that the loss gradient has not already been defined.
        if hasattr(self, 'grad'):                   # If the loss gradient has already been defined...

            # Throw an error.
            raise Exception('grad node is already defined!')

        # State that the loss gradient is being formulated.
        print('gradient node in construction ...')
        
        # Retrieve the optimizer and the loss.
        loss = self.loss
        optimizer = self.optimizer

        # Compute the gradients of the loss.
        with tf.name_scope('compute_grad'):

            # Compute the gradients of the loss.
            grad = optimizer.compute_gradients(loss)        # returns a list of (gradient, variable) pairs
            
        # Store the gradients.
        self.grad = grad

        # State that we have finished constructing the gradient.
        print('gradient node constructed.\n')



    def Residual(self):

        """Function to compute the residual of the PDE."""

        # Ensure that the PDE residual is not already defined.
        if hasattr(self, 'residual'):               # If the PDE residual has already been defined...

            # Throw an error.
            raise Exception('PDE-residual is already defined!')

        # State that we are formulating the residual function.
        print('residual function in construction ...')
        
        # Retrieve the model data.
        dim = self.dim
        modelId = self.modelId
        dM_dt = self.dM_dt
        dM_dx = self.dM_dx
        d2M_dx2 = self.d2M_dx2
        source = self.source
        
        # Compute the PDE residual.
        with tf.name_scope('residual'):

            # Define a placeholder for the diffusivity values at the integration points.
            diff = tf.placeholder(tf.float32, name='diff'); diff.set_shape([None, 1])                   # diffusivity values at integration points

            # Define a placeholder for the velocity values at the integration points.
            vel = tf.placeholder(tf.float32, name='vel'); vel.set_shape([None, dim])                    # velocity vector field values at integration points

            # Define a placeholder for the gradient of the diffusivity field at the integration points.
            diff_dx = tf.placeholder(tf.float32, name='diff_dx'); diff_dx.set_shape([None, dim])        # gradient of the diffusivity field at integration points
            
            # Compute the gradient and Hessian:
            if modelId == 'MLP':                        # If the model is a MLP...

                # Retrieve the time gradient.
                gradt = dM_dt

                # Retrieve the spatial gradient.
                grad = dM_dx

                # Retrieve the spatial hessian.
                hess = d2M_dx2
                
                # Define the residual computation node:
                if gradt is None:

                    # Initialize the residual to zero.
                    res = 0

                else:

                    # Initialize the residual to be the negative of the temporal gradient.
                    res = - gradt

                # Compute the diffusivity contribution to the residual.
                res = res + tf.multiply(diff, hess)

                # Compute the velocity contribution to the residual.
                res = res - tf.reduce_sum( tf.multiply(vel-diff_dx, grad), axis=-1, keepdims=True )

                # Compute the source contribution to the residual.
                res = res + source
                
            elif modelId == 'RNN':                        # If the model is a RNN...

                # Retrieve the sequence length.
                seqLen = self.RNNdata.seqLen

                # Retrieve the number of degrees of freedom of the spatial gradient.
                dof = tf.shape(dM_dx)[0]
    #                gradt = tf.reshape(dM_dt, [dof*seqLen, 1])
    #                grad = tf.reshape(dM_dx, [dof*seqLen, dim])
    #                hess = tf.reshape(d2M_dx2, [dof*seqLen, 1])

                # Set the residual to zero.
                res = tf.zeros([dof*seqLen, 1])         # A true residual for RNN is not computationally feasible.
            
        # Store the residual data.
        self.diff = diff
        self.vel = vel
        self.diff_dx = diff_dx
        self.residual = res

        # State that we have finished constructing the residual function.
        print('residual function constructed.\n')



################################# deprecated ##################################
        
    def optimSetup(self):
        """Function to define the optimization nodes. """
        
        if hasattr(self, 'optimizer'):
            raise Exception('optimization node is already defined!')
        
        print('optimization node in construction ...')
        
        # Data:
        graph = self.graph
        processor = self.processor
        loss = self.loss
        
        with graph.as_default(), tf.name_scope("compute_gradients"):
            saver = tf.train.Saver(max_to_keep=2)                               # save optimization state
            print('saver constructed.\n')
            with tf.device(processor):
                step = tf.train.get_or_create_global_step()                     # global optimization step
                optimizer = tf.train.AdamOptimizer(name='Optimizer')
                optMinimize = optimizer.minimize(loss, global_step=step)        # add loss function
                resetList = [optimizer.get_slot(var, name) for var in tf.trainable_variables() for name in optimizer.get_slot_names()]
                resetOpt = tf.variables_initializer(resetList)                  # reset node for slot variables (history) of the optimizer for trainable variables
            print('optimizer constructed.')
            
            config = tf.ConfigProto(log_device_placement=False)
#            config.gpu_options.allow_growth = True
            sess = tf.Session(config=config)                                    # start a new training session
        
        # Store data:
        self.step = step
        self.saver = saver
        self.optimizer = optimizer
        self.optMinimize = optMinimize
        self.resetOpt = resetOpt
        self.sess = sess
    
    
    
    def gradRNN(self, model, Input):
        """
        Function to compute the gradient of the RNN wrt its inputs. Note that 
        for RNNs, each output depends on all inputs before it. If we assume that
        the spatial input is constant for each batch, then the total derivative
        is simply the sum of derivatives of each output wrt all inputs up to that
        output. See the notes for details.
        
        Inputs:
            model: RNN model
            Input: Input to the model
        """
        seqLen = self.RNNdata.seqLen
        val = model(Input)                                          # pass the input to the model
        
        # Compute gradient for each output wrt all inputs and sum them up:
        grad = []
        print()
        for t in range(seqLen):
            print('calculating the gradient for output number ', t+1)
            gradTmp = tf.gradients(val[:,t,:], Input)[0]            # gradient for each output
            grad.append(gradTmp)
        grad = tf.stack(grad, axis=1)                               # stack all gradients into a tensor
        grad = tf.reduce_sum(grad, axis=2, keepdims=False)          # sum over Input for each output
        
        return grad






        
        










