classdef numerical_method_utilities_class
    
    % This class contains properties and methods related to numerical methods utilities.
    
    
    %% NUMERICAL METHODS UTILITIES PROPERTIES.
    
    % Define class properties.
    properties
        
        method_names
        
    end
    
    
    %% NUMERICAL METHODS UTILITIES METHODS SETUP.
    
    % Define class methods.
    methods
        
        % Implement the class constructor.
        function self = numerical_method_utilities_class(  )
            
            % Define the method names.
            self.method_names = {'Forward Euler'};
            
        end
        
        
        %% Numerical Stability Methods.
        
        % Implement a function to determine whether a stability metric is stable.
        function stable_flag = is_metric_stable( ~, R )
            
            % Determine whether this metric is stable.
            if any( abs( R ) >= 1 )      	% If the absolute value of the stability metric is greater than or equal to one...
                
                % Set the stable flag to false.
                stable_flag = false;
                
            else                            % Otherwise...
                
                % Set the stable flag to true.
                stable_flag = true;
                
            end
            
        end
        
        
        % Implement a function to compute the RK4 stability metric.
        function R = compute_RK4_stability( ~, mu )
            
            % Compute the RK4 stability.
            R = 1 + mu + ( 1/2 )*mu.^2 + ( 1/6 )*mu.^3 + ( 1/24 )*mu.^4;
            
        end
        
        
        % Implement a function to compute the RK4 stability metric associated with a given eigenvalue and step size.
        function R = eigenvalues2RK4_stability( self, lambdas, dt )
            
            % Determine whether to reshape the time input.
            dt = reshape( dt, [ numel( dt ), 1 ] );
            
            % Compute the stability metric input.
            mu = dt*lambdas';
            
            % Compute the RK4 stability metric.
            R = self.compute_RK4_stability( mu );
            
        end
        
        
        % Implement a function to compute the compute the RK4 stability metric associated with a given system and step size.
        function R = system_matrix2RK4_stability( self, A, dt )
            
            % Compute the eigenvalues associated with this matrix.
            lambdas = eig( A );
            
            % Compute the RK4 stability metric associated with these eigenvalues.
            R = self.eigenvalues2RK4_stability( lambdas, dt );
            
        end
        
        
        % Implement a function to compute the maximum step size for RK4 given a system matrix.
        function dt = compute_max_RK4_step_size( self, A, dt0 )
            
            % Define the default input arguments.
            if nargin < 3, dt0 = 1e-6; end
            
            % Create the stability function.
            f_stability = @( dt ) reshape( max( abs( self.system_matrix2RK4_stability( A, dt ) ), [  ], 2 ), size( dt ) ) - 1;
            
            % Define the number of timesteps.
            num_dts = 7;
            
            % Compute the numerical method seeds.
            dt0s = logspace( log10( dt0 ), 0, num_dts );
            
            % Initialize the step size.
            dt = 0;
            
            % Initialize a counter variable.
            k = 0;
            
            % Compute the maximum timestep.
            while ( round( dt, 12 ) == 0 ) && ( k < num_dts )                           % While we have not yet found a valid step size and we haven't exhausted all of our numerical seeds...
                
                % Advance the loop counter.
                k = k + 1;
                
                % Compute the resulting step size.
                dt = fzero( f_stability, dt0s( k ) );
                
            end
            
        end
        
        
        %% Numerical Integration Methods.
        
        % Implement a function to perform a single forward Euler step.
        function U = forward_euler_step( ~, U, dU, dt)
            
            % Estimate the simulation states at the next time step.
            U = U + dt*dU;
            
        end
        
        
        % Implement a function to perform a single forward euler step.
        function [ x, dx ] = FE( ~, f, t, x, dt )
            
            % Compute the forward euler derivative estimate.
            dx = f( t, x );
            
            % Apply the forward euler derivative estimate.
            x = x + dt*dx;
            
        end
        
        
        % Implement a function to perform a single RK4 step.
        function [ x, dx ] = RK4( ~, f, t, x, dt )
            
            %{
            Input(s):
                f = [-] Function.
                t = [s] Time.
                x = [variable] Current State.
                dt = [s] Timestep.
            
            Output(s):
                x = [variable] Next State.
                dx = [variable] Change in State.
            %}
            
            % Compute half the step size.
            dt_half = dt/2;
            
            % Compute the middle time.
            t_mid = t + dt_half;
            
            % Compute the final time.
            t_final = t + dt;
            
            % Compute the RK4 intermediate steps.
            k1 = f( t, x );
            k2 = f( t_mid, x + dt_half*k1 );
            k3 = f( t_mid, x + dt_half*k2 );
            k4 = f( t_final, x + dt*k3 );
            
            % Compute the RK4 derivative estimate.
            dx = ( 1/6 )*( k1 + 2*k2 + 2*k3 + k4 );
            
            % Apply the RK4 derivative estimate.
            x = x + dt*dx;
            
        end
        
        
        %% Statistics Methods.
        
        % Implement a function to compute the mean, min, and max of a provided data set.
        function [ xs_mean, xs_min, xs_max ] = compute_mean_min_max( ~, xs, dims )
            
            % Compute the mean.
            xs_mean = squeeze( mean( xs, dims ) );
            
            % Compute the minimum.
            xs_min = squeeze( min( xs, [  ], dims ) );
            
            % Compute the maximum.
            xs_max = squeeze( max( xs, [  ], dims ) );
            
        end
        
        
        %% Numerical Differentiation Methods.
        
        
        %% Grid Functions.
        
        % Implement a function to retrieve specific slices of a grid.
        function [ Xs1, Xs2, Xs3 ] = get_3D_grid_slices( ~, Xs, indexes, transpose_flag )
           
            % Set the default input arguments.
            if nargin < 4, transpose_flag = false; end
            
            % Retrieve the grid slice with a fixed first dimension.
            Xs1 = squeeze( Xs( indexes( 1 ), :, : ) );
            
            % Retrieve the grid slice with a fixed second dimension.
            Xs2 = squeeze( Xs( :, indexes( 2 ), : ) );
            
            % Retrieve the grid slice with a fixed third dimension.
            Xs3 = Xs( :, :, indexes( 3 ) );

            % Determine whether to transpose the grid slices.
            if transpose_flag           % If we want to transpose the data...
                
                % Tranpose the grid slices.
                Xs1 = Xs1'; Xs2 = Xs2'; Xs3 = Xs3';
                
            end
            
        end
        
        
        % Implement a function to retrieve mean, min, and max slices of a grid.
        function [ Xs1_mean, Xs1_min, Xs1_max, Xs2_mean, Xs2_min, Xs2_max, Xs3_mean, Xs3_min, Xs3_max ] = compute_3D_grid_mean_min_max_slices( self, Xs, transpose_flag )
        
            % Set the default input arguments.
            if nargin < 3, transpose_flag = false; end
            
            % Retrieve the mean, min, and max of the grid with respect to the one dimension.
            [ Xs1_mean, Xs1_min, Xs1_max ] = self.compute_mean_min_max( Xs, 1 );
            
            % Retrieve the mean, min, and max of the grid with respect to the two dimension.
            [ Xs2_mean, Xs2_min, Xs2_max ] = self.compute_mean_min_max( Xs, 2 );
            
            % Retrieve the mean, min, and max of the grid with respect to the third dimension.
            [ Xs3_mean, Xs3_min, Xs3_max ] = self.compute_mean_min_max( Xs, 3 );

            % Determine whether to transpose the grid slices.
            if transpose_flag           % If we want to transpose the data...

                Xs1_mean = Xs1_mean'; Xs1_min = Xs1_min'; Xs1_max = Xs1_max';
                Xs2_mean = Xs2_mean'; Xs2_min = Xs2_min'; Xs2_max = Xs2_max';
                Xs3_mean = Xs3_mean'; Xs3_min = Xs3_min'; Xs3_max = Xs3_max';

            end
            
        end
        
        
        %% Error Functions.
        
        % Implement a function that computes error statistics given desired and achieved outputs.
        function [ errors, error_percentages, error_rmse, error_rmse_percentage, error_std, error_std_percentage, error_min, error_min_percentage, index_min, error_max, error_max_percentage, index_max, error_range, error_range_percentage ] = compute_error_statistics( ~, values, targets, scale )
            
            % Compute the error between the achieved and desired results.
            errors = values( :, end ) - targets( :, end );
            error_percentages = 100*( errors / scale );
            
            % Compute the root mean squared error.
            error_rmse = sqrt( ( 1 / ( numel( errors ) ) )*sum( errors.^2, 'all' ) );
            error_rmse_percentage = 100*( error_rmse / scale );
            
            % Compute the standard deviation of the error.
            error_std = std( errors, 0, 'all' );
            error_std_percentage = 100*( error_std / scale );
            
            % Compute the minimum and maximum error.
            [ error_min, index_min ] = min( errors, [  ], 'all', 'linear' );
            [ error_max, index_max ] = max( errors, [  ], 'all', 'linear' );
            error_min_percentage = 100*( error_min / scale );
            error_max_percentage = 100*( error_max / scale );
            
            % Compute the error range.
            error_range = range( errors, 'all' );
            error_range_percentage = 100*( error_range / scale );
            
        end
        
        
        % Implement a function that computes the improvement in the error between absolute and relative simulation data.
        function [ error_improvement, error_percent_improvement, error_mse_improvement, error_mse_percent_improvment, error_std_improvement, error_std_percent_improvement, error_min_improvement, error_min_percent_improvement, error_max_improvement, error_max_percent_improvement ] = compute_error_improvement_statistics( ~, error_absolute, error_relative, error_absolute_percent, error_relative_percent, mse_absolute, mse_relative, mse_absolute_percent, mse_relative_percent, std_absolute, std_relative, std_absolute_percent, std_relative_percent, error_absolute_min, error_relative_min, error_absolute_min_percent, error_relative_min_percent, error_absolute_max, error_relative_max, error_absolute_max_percent, error_relative_max_percent )
            
            % Compute the improvement in the error between the absolute and relative schemes.
            error_improvement = abs( error_absolute ) - abs( error_relative );
            error_percent_improvement = abs( error_absolute_percent ) - abs( error_relative_percent );

            % Compute the error mean squared error improvement.
            error_mse_improvement = abs( mse_absolute ) - abs( mse_relative );
            error_mse_percent_improvment = abs( mse_absolute_percent ) - abs( mse_relative_percent );

            % Compute the error standard deviation improvement.
            error_std_improvement = abs( std_absolute ) - abs( std_relative );
            error_std_percent_improvement = abs( std_absolute_percent ) - abs( std_relative_percent );

            % Compute the minimum error improvement.
            error_min_improvement = abs( error_absolute_min ) - abs( error_relative_min );
            error_min_percent_improvement = abs( error_absolute_min_percent ) - abs( error_relative_min_percent );

            % Compute the maximum error improvement.
            error_max_improvement = abs( error_absolute_max ) - abs( error_relative_max );
            error_max_percent_improvement = abs( error_absolute_max_percent ) - abs( error_relative_max_percent );

        end
        
        
        % Implement a function that computes the difference in the error between absolute and relative simulation data.
        function [ error_difference, error_percent_difference, error_mse_difference, error_mse_percent_difference, error_std_difference, error_std_percent_difference, error_min_difference, error_min_percent_difference, error_max_difference, error_max_percent_difference ] = compute_error_difference_statistics( ~, error_absolute, error_relative, error_absolute_percent, error_relative_percent, mse_absolute, mse_relative, mse_absolute_percent, mse_relative_percent, std_absolute, std_relative, std_absolute_percent, std_relative_percent, error_absolute_min, error_relative_min, error_absolute_min_percent, error_relative_min_percent, error_absolute_max, error_relative_max, error_absolute_max_percent, error_relative_max_percent )
            
            % Compute the difference in the error between the absolute and relative schemes.
            error_difference = error_relative - error_absolute;
            error_percent_difference = error_relative_percent - error_absolute_percent;
            
            % Compute the error mean squared error difference.
            error_mse_difference = mse_relative - mse_absolute;
            error_mse_percent_difference = mse_relative_percent - mse_absolute_percent;

            % compute the error standard deviation difference.
            error_std_difference = std_relative - std_absolute;
            error_std_percent_difference = std_relative_percent - std_absolute_percent;
            
            % Compute the minimum error difference.
            error_min_difference = error_relative_min - error_absolute_min;
            error_min_percent_difference = error_relative_min_percent - error_absolute_min_percent;

            % Compute the maximum error difference.
            error_max_difference = error_relative_max - error_absolute_max;
            error_max_percent_difference = error_relative_max_percent - error_absolute_max_percent;
            
        end
        
        
        %% Structure Functions.
        
        % Implement a function that concatenates two structures.
        function C = concatenate_two_structures( ~, A, B )
        
            B_fieldnames = fieldnames( B );
            
            num_B_fields = length( B_fieldnames );
            
            C = A;
            
            for k = 1:num_B_fields
               
                C.( B_fieldnames{ k } ) = B.( B_fieldnames{ k } );
                
            end
            
        end
            
        
        % Implement a function that concatenates a cell of structures.
        function new_struct = concatenate_structures( self, structures )
        
            num_structures = length( structures );
            
            new_struct = structures{ 1 };
            
            for k = 1:( num_structures - 1 )
            
                new_struct = self.concatenate_two_structures( new_struct, structures{ k + 1 } );
            
            end
            
        end
        
        
        %% Printing Functions.
        
        % Implement a function to print summary statistics.
        function print_error_statistics( ~, header_str, unit_str, scale, error_rmse_theoretical, error_rmse_percentage_theoretical, error_rmse_numerical, error_rmse_percentage_numerical, error_std_theoretical, error_std_percentage_theoretical, error_std_numerical, error_std_percentage_numerical, error_min_theoretical, error_min_percentage_theoretical, Us_critmin_achieved_theoretical_steady, error_min_numerical, error_min_percentage_numerical, Us_critmin_achieved_numerical_steady, error_max_theoretical, error_max_percentage_theoretical, Us_critmax_achieved_theoretical_steady, error_max_numerical, error_max_percentage_numerical, Us_critmax_achieved_numerical_steady, error_range_theoretical, error_range_percentage_theoretical, error_range_numerical, error_range_percentage_numerical )            
            
            % Print the relative transmission summary statistics.
            fprintf( '\n' )
            fprintf( [ '------------------------- ', header_str, ' -------------------------' ] )
            fprintf( '\n' )
            
            fprintf( 'RMSE:\n' )
            fprintf( '\tTheoretical: \t%9.3f \t[%s] \t(%6.2f [%%])\n', scale*error_rmse_theoretical, unit_str, error_rmse_percentage_theoretical )
            fprintf( '\tNumerical: \t\t%9.3f \t[%s] \t(%6.2f [%%])\n', scale*error_rmse_numerical, unit_str, error_rmse_percentage_numerical )
            fprintf( '\tDifference: \t%9.3e \t[%s] \t(%6.2f [%%])\n', scale*( error_rmse_numerical - error_rmse_theoretical ), unit_str, error_rmse_percentage_numerical - error_rmse_percentage_theoretical )
            fprintf( '\n' )
            
            fprintf( 'STD:\n' )
            fprintf( '\tTheoretical: \t%9.3f \t[%s] \t(%6.2f [%%])\n', scale*error_std_theoretical, unit_str, error_std_percentage_theoretical )
            fprintf( '\tNumerical: \t\t%9.3f \t[%s] \t(%6.2f [%%])\n', scale*error_std_numerical, unit_str, error_std_percentage_numerical )
            fprintf( '\tDifference: \t%9.3e \t[%s] \t(%6.2f [%%])\n', scale*( error_std_numerical - error_std_theoretical ), unit_str, error_std_percentage_numerical - error_std_percentage_theoretical )
            fprintf( '\n' )
            
            fprintf( 'Min:\n' )
            fprintf( '\tTheoretical: \t%9.3f \t[%s] \t(%6.2f [%%]) \t@ \t(%9.3f [%s], %9.3f [%s])\n', scale*error_min_theoretical, unit_str, error_min_percentage_theoretical, scale*Us_critmin_achieved_theoretical_steady( 1 ), unit_str, scale*Us_critmin_achieved_theoretical_steady( 2 ), unit_str )
            fprintf( '\tNumerical: \t\t%9.3e \t[%s] \t(%6.2f [%%]) \t@ \t(%9.3f [%s], %9.3f [%s])\n', scale*error_min_numerical, unit_str, error_min_percentage_numerical, scale*Us_critmin_achieved_numerical_steady( 1 ), unit_str, scale*Us_critmin_achieved_numerical_steady( 2 ), unit_str )
            fprintf( '\tDifference: \t%9.3e \t[%s] \t(%6.2f [%%])\n', scale*( error_min_numerical - error_min_theoretical ), unit_str, error_min_percentage_numerical - error_min_percentage_theoretical )
            fprintf( '\n' )
            
            fprintf( 'Max:\n' )
            fprintf( '\tTheoretical: \t%9.3f \t[%s] \t(%6.2f [%%]) \t@ \t(%9.3f [%s], %9.3f [%s])\n', scale*error_max_theoretical, unit_str, error_max_percentage_theoretical, scale*Us_critmax_achieved_theoretical_steady( 1 ), unit_str, scale*Us_critmax_achieved_theoretical_steady( 2 ), unit_str )
            fprintf( '\tNumerical: \t\t%9.3f \t[%s] \t(%6.2f [%%]) \t@ \t(%9.3f [%s], %9.3f [%s])\n', scale*error_max_numerical, unit_str, error_max_percentage_numerical, scale*Us_critmax_achieved_numerical_steady( 1 ), unit_str, scale*Us_critmax_achieved_numerical_steady( 2 ), unit_str )
            fprintf( '\tDifference: \t%9.3e \t[%s] \t(%6.2f [%%])\n', scale*( error_max_numerical - error_max_theoretical ), unit_str, error_max_percentage_numerical - error_max_percentage_theoretical )
            fprintf( '\n' )
            
            fprintf( 'Range:\n' )
            fprintf( '\tTheoretical: \t%9.3f \t[%s] \t(%6.2f [%%])\n', scale*error_range_theoretical, unit_str, error_range_percentage_theoretical )
            fprintf( '\tNumerical: \t\t%9.3f \t[%s] \t(%6.2f [%%])\n', scale*error_range_numerical, unit_str, error_range_percentage_numerical )
            fprintf( '\tDifference: \t%9.3e \t[%s] \t(%6.2f [%%])\n', scale*( error_range_numerical - error_range_theoretical ), unit_str, error_range_percentage_numerical - error_range_percentage_theoretical )
            fprintf( '\n' )
            
            fprintf( '----------------------------------------------------------------------------------------------------\n' )
            
        end
        
        
        % Implement a function to print numerical stability information.
        function print_numerical_stability_info( ~, As, dts, network_dt, condition_numbers )
        
            % Retrieve the maximum step size.
            [ dt_max, index ] = min( dts );
            
            % Retrieve the maximum condition number.
            condition_number_max = max( condition_numbers );
            
            % Retrieve the linearized system matrix associated with the maximum step size.
            A = As( :, :, index );
            
            % Print out the stability information.
            fprintf( '------------- Numerical Stability Information -------------\n' )
            fprintf( 'Linearized System Matrix: \tA \t\t\t=\n\n' ), disp( A )
            fprintf( 'Max RK4 Step Size: \t\t\tdt_max \t\t= \t%0.3e \t[s]\n', dt_max )
            fprintf( 'Proposed Step Size: \t\tdt \t\t\t= \t%0.3e \t[s]\n', network_dt )
            fprintf( 'Condition Number: \t\t\tcond( A ) \t= \t%0.3e \t[-]\n', condition_number_max )
            fprintf( '------------------------------------------------------------\n\n' )
            
        end
        
        
    end
end

