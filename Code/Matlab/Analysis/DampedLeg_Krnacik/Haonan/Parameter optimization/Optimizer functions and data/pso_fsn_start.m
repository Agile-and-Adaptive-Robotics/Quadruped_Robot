function PSO_results = pso_fsn_start(data, IC_data, n_particles, n_iterations)

%% Implements a particle storm optimization algorithm using parameter values obtained from the Functional Sub Network approach described in <> as a starting point. Randomized values are added to the parameter values to arrive at the initial particle configurations.

% Unpack data to be used
UB             = data.upscal;                    % [ Upper boundary conditions for param ]
LB             = data.lowscal;                   % [ Lower boundary conditions for param ]


% Particle swarm hyperparameters
c1 = 0.1; c2 = 0.1;
w = 0.8;
n_params = length(IC_data);
sol_ary = zeros([1,n_params+1]);

% Define particles using a uniform distribution algorithm. Each has a range
% of lower to upper boundary conditions 
UB = repmat(UB, n_particles, 1);
LB = repmat(LB, n_particles, 1);
X = LB + (UB - LB) .* rand(n_particles, n_params);

% Define starting V wrt X
V = X .* 0.1 .* ( -1 + 2 * rand(n_particles, n_params) );
                                
% % Make the first particle a set of starting value that produce a trough
% X(1,3:4) = IC_data(3:4);

% Make the first particle a set of known solutions
X(1,:) = IC_data;

% Initialize data
pbest           = X;
pbest_err       = f_epoch(pbest, 0, data); %calls the function that iterates an epoch
[gbest_err,I]   = min(pbest_err);
gbest           = pbest(I,:);

fprintf('\nOptimization initialized. Beginning first time point iteration.\n')

% Create figure to update gbest on
figure; set(gcf,'color','w'); hold on
title('Current global best error')
xlabel('Iteration'); ylabel('Calculated error')

% Start process timer for single iteration
tStart = tic;

% Optimization loop (currently based on n_iterations. need to introduce convergence protocols)
for n = 1:n_iterations
    
    
    
    % Update params
    r1 = rand; r2 = rand;
    
    % calculate V and X
    V = w * V + c1*r1*(pbest - X) + c2*r2*(gbest - X);
    X = round(X+V, 4); %truncated to reduce computational time.
    
    % Verify that all values are within the boundary
    X(LB > X ) = LB(LB > X);
    X(X > UB ) = UB(X > UB);
    
    % Calculate error for this time step
    err = f_epochD3R3(X, n+1, data);
    
    % Store config values
    this_config = [X err];
    sol_ary     = [sol_ary; this_config];

    % Update personal best for all
    pbest(pbest_err >= err, :)      = X(pbest_err >= err, :);
    pbest_err(pbest_err >= err, :)  = err(pbest_err >= err, :);
    
    % Isolate group best
    [gbest_err, I]  = min(pbest_err);
    gbest           = pbest(I,:);

    
    
    % Add graph plotting gbest error
    figure(1)
    plot(n, gbest_err,'kd','MarkerSize',4, 'MarkerFaceColor', 'r')
    
    % Print iteration update
    fprintf('\nIteration %d complete. ', n)
    tCurrent = toc(tStart);
    fprintf('Elapsed time is %d hours and %.1f minutes.\n', floor(tCurrent/3600), rem(tCurrent,3600)/60)
    tRemEst = (tCurrent/n) * (n_iterations - n) / 60;    % [min]
    fprintf('Estimated time remaining is %d hours and %.1f minutes.\n', floor(tRemEst/60), rem(tRemEst,60))

end

% Save structure of results
PSO_results.gbest = gbest;
PSO_results.gbest_err = gbest_err;
PSO_results.pbest = pbest;
PSO_results.sol_ary = sol_ary;

tFinal = toc(tStart)/60; % [ min ]
fprintf('\n\nPSO complete. Total runtime: %d hours and %.1f minutes.', floor(tFinal/60), rem(tFinal, 60)); 


end