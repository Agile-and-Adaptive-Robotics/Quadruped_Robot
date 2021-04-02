function [ Gs, wn_crit, zeta_crit, k_crit ] = Fit2ndOrderSys( ws_data, mags_data, phase_data, tol, weights, bConvergencePlots, bErrorSurfacePlots )

%Define the default arguments.
if nargin < 7, bErrorSurfacePlots = false; end
if nargin < 6, bConvergencePlots = false; end
if nargin < 5
    %Set the default weighting.
    mag_weight = 0.8; phase_weight = 0.2;
else
    %Define the error weighting.
    mag_weight = weights(1); phase_weight = weights(2);
end
if nargin < 4, tol = 5*eps; end
if tol < 5*eps, tol = 5*eps; end

%Define the number of steps wide to make the search window.
% num_window_steps = 3;

%Define the window contraction rate.
window_contraction_rate = 0.9;

%Define the number of points to use in the descritization of the error space.
num_descritization_points = 10;

%Define the maximum number of iterations to perform.
max_num_iterations = 100;

%Define common plotting properties.
marker_size = 20; line_width = 1;

%Compute the static gain for the system.
k_crit = 10^(mags_data(1)/20);

%Define the magnitude and phase functions for a second order system.
fms = @(ws, wn, zeta) k_crit./sqrt((1 - (ws/wn).^2).^2 + (2*zeta*(ws/wn)).^2);
fps = @(ws, wn, zeta) -(180/pi)*atan2((2*(ws/wn)*zeta), (1 - (ws/wn).^2));

%Define the angular frequency and damping ratio domains.
% wns_domain = [ws_data(1) ws_data(end)];
wns_domain = 2*pi*[1e-1 (1e3)];
zetas_domain = [0.01 5];

%Preallocate variables to store the critical natural frequencies and damping ratios.
[wns_crit, zetas_crit, min_errors] = deal( zeros(1, max_num_iterations) );

%Set the convergence flag to false.
bConverged = false;

%Initialize the loop variable.
k3 = 1;

%Compute the best 2nd order system parameters in the least squares sense.
while (k3 <= max_num_iterations) && ~bConverged                                                              %Iterate the specified number of times...
    
    %Define the starting parameter space.
    wns = linspace(wns_domain(1), wns_domain(2), num_descritization_points);
    zetas = linspace(zetas_domain(1), zetas_domain(2), num_descritization_points);
    
    %Retrieve the step sizes of the natural frequencies and damping ratios.
    wns_step_size = abs(wns(2) - wns(1)); zetas_step_size = abs(zetas(2) - zetas(1));
    
    %Preallocate a variable to store the error values.
    [Wns, Zetas, errors] = deal( zeros(length(zetas), length(wns)) );
    
    %Compute the error associated with each parameter combination.
    for k1 = 1:length(wns)                                                              %Iterate through each of the natural frequencies...
        for k2 = 1:length(zetas)                                                        %Iterate through each of the damping ratios...
            
            %Define the current transfer function.
            Gs = tf(k_crit*(wns(k1)^2), [1 (2*zetas(k2)*wns(k1)) (wns(k1)^2)]);
            
            %Get the bode data for this transfer function
            [ mag_est, phase_est ] = GetBodeData( Gs, ws_data );
            
            %             %Compute the magnitude and phase estimates.
            %             mag_est = fms(ws_data, wns(k1), zetas(k2));
            %             phase_est = fps(ws_data, wns(k1), zetas(k2));
            
            %Compute the magnitude error.
            mag_error = norm(abs(mag_est - mags_data));
            
            %Compute the phase error.
            phase_error = norm(abs(phase_est - phase_data));
            
            %Compute the weighted error.
            Wns(k2, k1) = wns(k1); Zetas(k2, k1) = zetas(k2);
            errors(k2, k1) = mag_weight*mag_error + phase_weight*phase_error;
            
        end
    end
    
    %Compute the minimum weighted error.
    min_error = min(min(errors));
    
    %Find the indexes associated with the minimum weighted error.
    inds = AbsInd2DimInd( size(errors), find(errors == min_error, 1) );
    
    %Retrieve the natural frequency and damping ratio associated with minimum error.
    zeta_crit = zetas(inds(1)); wn_crit = wns(inds(2));
    
    %Store these critical natural frequencies, damping ratios, and error into arrays.
    zetas_crit(k3) = zeta_crit; wns_crit(k3) = wn_crit; min_errors(k3) = min_error;
    
    %Determine whether to plot the error surface.
    if bErrorSurfacePlots                                               %If the user requested that the error surface be plotted...
        %Plot the error surface.
        figure, hold on, grid on, xlabel('Natural Frequency [Hz]'), ylabel('Damping Ratio [-]'), title('Error Surface'), view(30, 30), rotate3d on, surf(Wns/(2*pi), Zetas, errors, 'Edgecolor', 'none')
        plot3(wn_crit/(2*pi), zeta_crit, min_error, '.r', 'Markersize', 20)
    end
    
    %Recompute the natural frequency and damping ratio domains.
    if (inds(1) == 1) && (inds(2) ~= 1)
        wns_domain = [wn_crit - (1/2)*window_contraction_rate*diff(wns_domain), wn_crit + (1/2)*window_contraction_rate*diff(wns_domain)];
        zetas_domain = [zeta_crit - (1/2)*diff(zetas_domain), zeta_crit + (1/2)*diff(zetas_domain)];
    elseif (inds(1) ~= 1) && (inds(2) == 1)
        wns_domain = [wn_crit - (1/2)*diff(wns_domain), wn_crit + (1/2)*diff(wns_domain)];
        zetas_domain = [zeta_crit - (1/2)*window_contraction_rate*diff(zetas_domain), zeta_crit + (1/2)*window_contraction_rate*diff(zetas_domain)];
    elseif (inds(1) == 1) && (inds(2) == 1)
        wns_domain = [wn_crit - (1/2)*diff(wns_domain), wn_crit + (1/2)*diff(wns_domain)];
        zetas_domain = [zeta_crit - (1/2)*diff(zetas_domain), zeta_crit + (1/2)*diff(zetas_domain)];
    else
        wns_domain = [wn_crit - (1/2)*window_contraction_rate*diff(wns_domain), wn_crit + (1/2)*window_contraction_rate*diff(wns_domain)];
        zetas_domain = [zeta_crit - (1/2)*window_contraction_rate*diff(zetas_domain), zeta_crit + (1/2)*window_contraction_rate*diff(zetas_domain)];
    end
    
    
    %Ensure the domains are positive.
    if sum(wns_domain < 0) > 0
        wns_domain = wns_domain - wns_domain(1);
    end
    if sum(zetas_domain < 0) > 0
        zetas_domain = zetas_domain - zetas_domain(1);
    end
    
    %Check the stopping condition.
    if (k3 ~= 1) && ( (abs(min_errors(k3) - min_errors(k3 - 1)) < tol) || ( (abs(wns_crit(k3) - wns_crit(k3 - 1)) < tol) && (abs(zetas_crit(k3) - zetas_crit(k3 - 1)) < tol) ))
        bConverged = true;
    end
    
    %Advance the loop variable
    k3 = k3 + 1;
    
end

%Store the actual number of iterations.
actual_num_iterations = k3 - 1;

%Create a vector of iteration numbers.
iterations = 1:actual_num_iterations;

%Truncate the critcal natural frequency, damping ratio, and error arrays if necessary.
wns_crit = wns_crit(iterations); zetas_crit = zetas_crit(iterations); min_errors = min_errors(iterations);

%Construct the second order transfer function associated with these natural frequencies, damping ratios, and errors.
Gs = tf(k_crit*(wn_crit^2), [1 (2*zeta_crit*wn_crit) (wn_crit^2)]);

%Determine whether to create the convergence plots.
if bConvergencePlots                                                                %If the user requested convergence plots...
    %Plot the critical natural frequencies, damping ratios, and errors.
    figure, hold on, grid on, xlabel('Iteration Number [#]'), ylabel('Natural Frequency [Hz]'), title('Natural Frequency vs Iteration Number'), plot(iterations, wns_crit/(2*pi), '.-', 'Markersize', marker_size, 'Linewidth', line_width)
    figure, hold on, grid on, xlabel('Iteration Number [#]'), ylabel('Damping Ratio [-]'), title('Damping Ratio vs Iteration Number'), plot(iterations, zetas_crit, '.-', 'Markersize', marker_size, 'Linewidth', line_width)
    figure, hold on, grid on, xlabel('Iteration Number [#]'), ylabel('Least Squares Error [-]'), title('Least Squares Error vs Iteration Number'), plot(iterations, min_errors, '.-', 'Markersize', marker_size, 'Linewidth', line_width)
end

end

