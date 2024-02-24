function pso_fsn_start(df, fsn_vals, n_particles, n_iterations):
%% Implements a particle storm optimization algorithm using parameter values obtained from the Functional Sub Network approach described in <> as a starting point. Randomized values are added to the parameter values to arrive at the initial particle configurations.
%         df variable is a DataFrame containing pertinent information about the parameters to be optimized. The DataFrame must contain the following columns (and a value for each paramter):
%
%             'structure_name'       : structure (neuron/synapse/muscle/etc) containing parameter to be optimized
%             'aproj_structure_root' : location of structure parent in element tree/root of aproj sim file
%             'asim_structure_root'  : location of structure parent in element tree/root of asim file
%             'aproj_var_name'       : name (in project file) of parameter to be optimized
%             'asim_var_name'        : name (in asim file) of parameter to be optimized
%             'var_abs_min'          : lowest parameter value alllowed by AnimatLab
%             'var_abs_max'          : highest parameter value allowed by AnimatLab
%
%         :param n_particles: DESCRIPTION, defaults to 20
%         :type n_particles: TYPE, optional
%         :param n_iterations: DESCRIPTION, defaults to 20
%         :type n_iterations: TYPE, optional
%         :return: DESCRIPTION
%         :rtype: TYPE
%
%         """
        %start process timer
        Tic = tic;
%         % ensure class-wide access to stochastic vars
%         self.n_iterations = n_iterations
%         self.n_particles  = n_particles
    % particle swarm hyperparameters
    c1 = 0.1; c2 = 0.1;
    w = 0.8;
    n_params = length(df);
    sol_ary = zeros([1,n_params+1]);
    % define particles using a uniform distribution algorithm
    X = zeros([n_particles, n_params]);
    for n = 1:n_params
        % the following line will need to be revised for MATLAB to parse
        X(:,n) = np.random.default_rng().uniform(low  = df['val_abs_min'][n],...
                                                  high = df['val_abs_max'][n],...
                                                  size = [n_particles]);
    end
    % define starting V wrt X
    V = np.random.default_rng().uniform(low=-1,...
                                        high = 1,...
                                        size=[n_particles, n_params])*0.1*X;
    % Make the first particle a set of starting value that produce a trough
    X(1,:) = fsn_vals;
    % Initialize data
    pbest       = X;
    pbest_err   = f_epoch(pbest, 0); %calls the function that iterates an epoch
    gbest       = pbest(min(pbest_err),:);
    gbest_err   = min(pbest_err);
    %optimization loop (currently based on n_iterations. need to introduce convergence protocols)
    for n = 1:n_iterations
        % Update params
        r1 = rand; r2 = rand;
        % calculate V and X
        V = w * V + c1*r1*(pbest - X) + c2*r2*(gbest - X);
        X = round(X + V, 4); %truncated to reduce computational time.
        % verify that all values are within the boundary (needs to be
        % revised for MATLAB)
%         X[X<np.matlib.repmat( df['val_abs_min'].to_numpy(),n_particles,1)] = np.matlib.repmat( df['val_abs_min'].to_numpy(),n_particles,1)[X<np.matlib.repmat( df['val_abs_min'].to_numpy(),n_particles,1)]
%         X[X>np.matlib.repmat( df['val_abs_max'].to_numpy(),n_particles,1)] = np.matlib.repmat( df['val_abs_max'].to_numpy(),n_particles,1)[X>np.matlib.repmat( df['val_abs_max'].to_numpy(),n_particles,1)]
        %iterate the configuration
        err = f_epoch(X, n+1);
        % store config values
        this_config = [X err]; %might need to verify err is an n x 1 double
        sol_ary = [sol_ary; this_config];
%             % update class variable on every epoch
%             self.configs = sol_ary
        %update personal best for all
        pbest(pbest_err >= err, :) = X(pbest_err >= err, :);
        %isolate group best
        pbest_err   = min([pbest_err obj]);
        gbest       = pbest(min(pbest_err),:);
        gbest_err   = min(pbest_err);
%             % report to user
%             print(f"pbest: {pbest}")
%             print(f"gbest: {gbest}")
%
%             print(f"Best RSME in group: {gbest_obj} \n")
    end
%         self.best_x = gbest
%         print(f"Best configuration: {gbest}")
%
%         % add solution set to df DataFrame
%         df['new_vals'] = gbest
%
%         % save results as a matlab variable (for visualizations)
%         file_path = 'data' + time.strftime('_%b_%d_%Y_%H%M',time.localtime()) + '.mat'
%         scipy.io.savemat(file_path, {'data': sol_ary})
%         print(f"data saved as {file_path}")
%
%         %generate a project (aproj) file containing solution
%         self.write_aproj_file(df=df, new_aproj_filename= "/pso_solution" + time.strftime('_%b_%d_%Y_%H%M',time.localtime()))
%
%         %report elapsed time
%         toc = (time.time() - tic)/60
%         print(f"Simulation elapsed time: {toc:.2f} minutes")
%
%         %ding when done
%         duration = 1000  % milliseconds
%         freq = 440  % Hz
%         winsound.Beep(freq, duration)
end