function [ pmeans, classifications, actual_num_iterations ] = KmeansAlgorithm( data, num_classes, max_iterations, num_trials, bAnimate, bVerbose )
%% This function performs the k-means algorithm with num_classes classes, max_iterations max number of iterations, and num_trials number of trials.  This function returns the best means and associated classifications of the num_trials trials.

%% Set the Default Input Arguments.

if nargin < 6, bVerbose = false; end
if nargin < 5, bAnimate = false; end


%% Initialize for the K-Means Algorithm.

%Compute the number of data points.
num_data_points = size(data, 2);

%Compute the domain and range of the data points.
xDomain = [min(data(1, :)) max(data(1, :))];
yDomain = [min(data(2, :)) max(data(2, :))];

%% Perform the K-Means Algorithm.

%Preallocate the best objective function value.
best_obj_func_value = inf;

%Perform the specified number of K-means trials.
for k5 = 1:num_trials                               %Iterate through each of the trials...
    
    %Convert num_classes random values within the data domain to initialize the class means.
    % xmean0s = interp1([0 1], xDomain, rand(1, num_classes));
    % ymean0s = interp1([0 1], yDomain, rand(1, num_classes));
    rand_indexes = randi([1 num_data_points], 1, num_classes);
    xmean0s = data(1, rand_indexes);
    ymean0s = data(2, rand_indexes);
    
    %Preallocate an array to store the mean values.
    pmeans = zeros(2, max_iterations + 1, num_classes);
    
    %Store the initial mean locations.
    pmeans(1, 1, :) = reshape(xmean0s, [1 1 length(xmean0s)]);
    pmeans(2, 1, :) = reshape(ymean0s, [1 1 length(ymean0s)]);
    
    %Preallocate a matrix to store all of the distances.
    dist_mat = zeros(num_classes, num_data_points);
    
    %Preallocate a matrix to store the classifications.
    classifications = zeros(max_iterations, num_data_points);
    
    %Preallocate a counter variable.
    k2 = 0;
    
    %Set a flag that indicates whether we have converged.
    bConverged = false;
    
    %Use the K-means algorithm to determine the means of each class.
    while ((k2 < max_iterations) && (~bConverged))              %Iterate the specified number of iterations for these starting means...
        
        %Advance the counter variable.
        k2 = k2 + 1;
        
        %Compute the distance from each point to each of the class centroids.
        for k3 = 1:num_classes              %Iterate through each class...
            for k4 = 1:num_data_points      %Iterate through each data point...
                
                %Compute the distance from the current class mean to the current data point.
                dist_mat(k3, k4) = norm(data(:, k4) - pmeans(:, k2, k3), 2);
                
            end
        end
        
        %Assign each point a class based on the class mean to which it is nearest.
        [~, classifications(k2, :)] = min(dist_mat);
        
        %Determine whether we have converged.
        if ((k2 ~= 1) && (sum(classifications(k2 - 1, :) == classifications(k2, :)) == size(classifications, 2)))               %If we have converged...
            bConverged = true;                                                                                                  %Set the convergence flag to true.
        else                                                                                                                    %Otherwise compute the new means.
            %Compute the new means associated with each class.
            for k3 = 1:num_classes                                  %Iterate through each class...
                
                %Store the new means into our means matrix.
                pmeans(:, k2 + 1, k3) = mean(data(:, classifications(k2, :) == k3), 2);
                
            end
        end
        
    end
    
    %Reset the current objective function value.
    current_obj_func_value = 0;
    
    %Compute the current objective function value.
    for k3 = 1:num_classes                                  %Iterate through each of the classes...
        %Compute the current objective function value.
        current_obj_func_value = current_obj_func_value + sum(dist_mat(k3, classifications(k2, :) == k3).^2);
    end
    
    %Store the actual number of iterations.
    actual_num_iterations = k2 - 1;
    
    if (current_obj_func_value < best_obj_func_value)
        best_obj_func_value = current_obj_func_value;
        best_pmeans = pmeans;
        best_classifications = classifications;
        best_actual_num_iterations = actual_num_iterations;
    end
    
end

%Store all of the best trial values back into their standard names.
pmeans = best_pmeans;
classifications = best_classifications;
actual_num_iterations = best_actual_num_iterations;


%% Animate the Data.

%Animate the best trial if requested.
if bAnimate
    
    %Plot the data points.
    h = figure; hold on, grid off, xlabel('x-axis'), ylabel('y-axis'), title('K-Means Alogrithm'), xlim(xDomain), ylim(yDomain)
    
    %Define an array of colors.
    color_str = {'b', 'r', 'g', 'c', 'm', 'k' 'y'};
    
    %Setup for animation.
    for k = 1:num_classes                           %Iterate through each of the classes...
        
        %Define animations arrays for the classes.
        eval(sprintf('xs_class%0.0f = 0;', k))
        eval(sprintf('ys_class%0.0f = 0;', k))
        
        %Define animation arrays for the means.
        eval(sprintf('xs_means%0.0f = xmean0s(%0.0f);', k, k))
        eval(sprintf('ys_means%0.0f = ymean0s(%0.0f);', k, k))
        
        %Define the animation figure elements.
        eval( strcat( sprintf('h_class%0.0f = plot(xs_class%0.0f, ys_class%0.0f, ''.', k, k, k), color_str{k}, sprintf(''', ''Markersize'', 20, ''XDataSource'', ''xs_class%0.0f'', ''YDataSource'', ''ys_class%0.0f'');', k, k) ) )
        eval( strcat( sprintf('h_mean%0.0f = plot(xs_means%0.0f, ys_means%0.0f, ''o', k, k, k), color_str{k}, sprintf(''', ''Markersize'', 10, ''Linewidth'', 2, ''MarkerEdgeColor'', ''k'', ''MarkerFaceColor'', '''), color_str{k}, sprintf(''', ''XDataSource'', ''xs_means%0.0f'', ''YDataSource'', ''ys_means%0.0f'');', k, k) ) )
        
    end
    
    
    %Animate the data points for each iteration of the K-means algorithm.
    for k = 1:actual_num_iterations                        %Iterate through each of the K-means iterations...
        
        %Update all of the plotting vectors.
        for j = 1:num_classes                       %Iterate through each class...
            
            %Update the class points for this iteration.
            eval(sprintf('xs_class%0.0f = data(1, classifications(k, :) == %0.0f); ', j, j))
            eval(sprintf('ys_class%0.0f = data(2, classifications(k, :) == %0.0f); ', j, j))
            
            %Update the means for this iteration.
            eval(sprintf('xs_means%0.0f = pmeans(1, 1:k, %0.0f);', j, j))
            eval(sprintf('ys_means%0.0f = pmeans(2, 1:k, %0.0f);', j, j))
            
        end
        
        %Refresh the plot.
        refreshdata(h, 'caller'), drawnow
        
        %Set the animation rate.
        pause(0.1)
        
    end
    
end

%% Print Summary Statistics

%Print out summary statistics if requested.
if bVerbose
    
    %Print out the final summary statistics.
    fprintf('Best Summary Statistics:\n')
    
    %Print out the summary statistics for each class.
    for k = 1:num_classes                               %Iterate through all of the classes...
        
        %Print out the summary statistics for this class.
        fprintf('Class #%0.0f:\n', k)
        fprintf('Mean: \n'), disp(pmeans(:, actual_num_iterations, k))
        fprintf('\n\n')
        
    end
    
end

end
