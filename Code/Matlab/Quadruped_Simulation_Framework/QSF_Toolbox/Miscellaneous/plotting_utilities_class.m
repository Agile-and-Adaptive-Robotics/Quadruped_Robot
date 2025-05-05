classdef plotting_utilities_class
    
    % This class contains properties and methods related to plotting utilities.
    
    
    %% PLOTTING UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        
        
    end
    
    
    %% PLOTTING UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = plotting_utilities_class(  )
            
            
        end
        
        
        %% Patch Functions
        
        % Implement a function to generate 2D patch data from an input signal and upper and lower output boundary signals.
        function [ xs_patch, ys_patch ] = generate_2D_patch_data( ~, xs, ys_lower, ys_upper )
           
            % Generate the x data for the patch.
            xs_patch = [ xs( : ); flip( xs( : ) ) ];
            
            % Generate the y data for the patch.
            ys_patch = [ ys_lower( : ); flip( ys_upper( : ) ) ];
            
        end
        
        
        % Implement a function to generate 3D patch data from input signals and upper and lower output boundary signals.
        function [ ps_patch_xlower, ps_patch_xupper, ps_patch_ylower, ps_patch_yupper, ps_patch_zlower, ps_patch_zupper ] = generate_3D_patch_data( ~, Xs, Ys, Zs_lower, Zs_upper )
            
            % Determine how to process the xs input data.
            if isvector( Xs )               % If this input is a vector...
            
                % Ensure that this input is a column vector.
                Xs = Xs( : );
                
            elseif ismatrix( Xs )           % If this input is a matrix...
                
                % Retrieve the first row of the matrix.
                Xs = Xs( 1, : )';
                
            end
                
            % Determine how to process the ys input data.
            if isvector( Ys )               % If this input is a vector...
            
                % Ensure that this input is a column vector.
                Ys = Ys( : );
                
            elseif ismatrix( Ys )           % If this input is a matrix...
                
                % Retrieve the first column of the matrix.
                Ys = Ys( :, 1 );
                
            end
            
            % Retrieve the number of points associated with each type of input signal.
            num_xs = length( Xs );
            num_ys = length( Ys );
            
            % Create the lower x patch data.
            xs_patch_xlower = Xs( 1 )*ones( 2*num_ys, 1 );
            ys_patch_xlower = [ Ys; flip( Ys ) ];
            zs_patch_xlower = [ Zs_upper( :, 1 ); flip( Zs_lower( :, 1 ) ) ];
            ps_patch_xlower = [ xs_patch_xlower, ys_patch_xlower, zs_patch_xlower ];
            
            % Create the upper x patch data.
            xs_patch_xupper = Xs( end )*ones( 2*num_ys, 1 );
            ys_patch_xupper = [ Ys; flip( Ys ) ];
            zs_patch_xupper = [ Zs_upper( :, end ); flipud( Zs_lower( :, end ) ) ];
            ps_patch_xupper = [ xs_patch_xupper, ys_patch_xupper, zs_patch_xupper ];
            
            % Create the lower y patch data.
            xs_patch_ylower = [ Xs; flip( Xs ) ];
            ys_patch_ylower = Ys( 1 )*ones( 2*num_xs, 1 );
            zs_patch_ylower = [ Zs_upper( 1, : ), fliplr( Zs_lower( 1, : ) ) ]';
            ps_patch_ylower = [ xs_patch_ylower, ys_patch_ylower, zs_patch_ylower ];
            
            % Create the upper y patch data.
            xs_patch_yupper = [ Xs; flip( Xs ) ];
            ys_patch_yupper = Ys( end )*ones( 2*num_xs, 1 );
            zs_patch_yupper = [ Zs_upper( end, : ), fliplr( Zs_lower( end, : ) ) ]';
            ps_patch_yupper = [ xs_patch_yupper, ys_patch_yupper, zs_patch_yupper ];
            
            % Create the lower z patch data.
            xs_patch_zlower = [ Xs( 1 )*ones( num_ys, 1 ); Xs; Xs( end )*ones( num_ys, 1 ); flip( Xs ) ];
            ys_patch_zlower = [ Ys; Ys( end )*ones( num_xs, 1 ); flip( Ys ); Ys( 1 )*ones( num_xs, 1 ) ];
            zs_patch_zlower = [ Zs_upper( :, 1 ); Zs_upper( end, : )'; flipud( Zs_upper( :, end ) ); flipud( Zs_upper( 1, : )' ) ];
            ps_patch_zlower = [ xs_patch_zlower, ys_patch_zlower, zs_patch_zlower ];
            
            % Create the upper z patch data.
            xs_patch_zupper = [ Xs( 1 )*ones( num_ys, 1 ); Xs; Xs( end )*ones( num_ys, 1 ); flip( Xs ) ];
            ys_patch_zupper = [ Ys; Ys( end )*ones( num_xs, 1 ); flip( Ys ); Ys( 1 )*ones( num_xs, 1 ) ];
            zs_patch_zupper = [ Zs_lower( :, 1 ); Zs_lower( end, : )'; flipud( Zs_lower( :, end ) ); flipud( Zs_lower( 1, : )' ) ];
            ps_patch_zupper = [ xs_patch_zupper, ys_patch_zupper, zs_patch_zupper ];
            
        end
        
        
        %% Plotting Functions.
        
        % Implement a function to compute the number of subplot rows and columns necessary to store a certain number of plots.
        function [ nrows, ncols ] = get_subplot_rows_columns( ~, n, bPreferColumns )
            
            %If the value is not supplied by the user, default to preferring to add rows.
            if nargin < 3, bPreferColumns = false; end
            
            %Determine whether n is an integer.
            if n ~= round( n )                                                            % If n is not an integer...
                
                % Round n to the nearest integer.
                n = round( n );                                                           
                
                % Throw a warning about rounding n.
                warning( 'n must be an integer.  Rounding n to the nearest integer.' )    
            
            end
            
            % Compute the square root of the integer of interest.
            nsr = sqrt( n );
            
            % Determine how many rows and columns to use in the subplot.
            if nsr == round( nsr )                    % If n is a perfect square...
            
                [ nrows, ncols ] = deal( nsr );         % Set the number of rows and columns to be the square root.
            
            else
                
                % Compute all divisors of n.
                dn = divisors( n );
                
                % Set the number of rows and columns to be the central divisors.
                nrows = dn( length( dn ) / 2 + 1 );
                ncols = dn( length( dn ) / 2 );
                
            end
            
            % Determine whether to give prefernce to columns or rows.
            if bPreferColumns                           % If we want to prefer columns...
                
                % Flip the row and column assignments, since we prefer rows by default.
                [ nrows, ncols ] = deal( ncols, nrows );
                
            end
            
        end
                
        
        % Implement a function to plot the steady state response of a subnetwork for a specific encoding scheme and gain.
        function fig = plot_steady_state_response( ~, xs, ys_desired, ys_theoretical, ys_numerical, scale, subnetwork_name, encoding_scheme, encoded_string, input_variable_string, output_variable_string, unit, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 15, save_tag = ''; end
            if nargin < 14, save_directory = './'; end
            if nargin < 13, save_flag = true; end
            if nargin < 12, unit = 'mV'; end
            if nargin < 11, output_variable_string = 'U2'; end
            if nargin < 10, input_variable_string = 'U1'; end
            if nargin < 9, encoded_string = 'Encoded'; end
            if nargin < 8, encoding_scheme = 'Absolute'; end
            if nargin < 7, subnetwork_name = 'Transmission'; end
            if nargin < 6, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( '%s %s: %s Steady State Response', encoding_scheme, subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( '%s Output, %s [%s]', encoded_string, output_variable_string, unit );

            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
            
            % Plot the desired, theoretical, and numerical steady state responses.
            plot( scale*xs, scale*ys_desired, '-', 'Linewidth', 3 )
            plot( scale*xs, scale*ys_theoretical, '-.', 'Linewidth', 3 )
            plot( scale*xs, scale*ys_numerical, '--', 'Linewidth', 3 )
            
            % Add a legend to the figure.
            legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_%s_ssr_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state response of a subnetwork for a specific encoding scheme and gain.
        function fig = surf_steady_state_response( ~, Xs, Ys, Zs_desired, Zs_theoretical, Zs_numerical, scale, viewing_angle, subnetwork_name, encoding_scheme, encoded_string, variable_strings, units, title_tag, save_flag, save_directory, save_tag  )
            
            % Set the default input arguments.
            if nargin < 17, save_tag = ''; end
            if nargin < 16, save_directory = './'; end
            if nargin < 15, save_flag = true; end
            if nargin < 14, title_tag = ''; end
            if nargin < 13, units = { '-', 'mV', 'mV' }; end
            if nargin < 12, variable_strings = { 'c1', 'U1', 'U2' }; end
            if nargin < 11, encoded_string = 'Encoded'; end
            if nargin < 10, encoding_scheme = 'Absolute'; end
            if nargin < 9, subnetwork_name = 'Transmission'; end
            if nargin < 8, viewing_angle = [ 145, 15 ]; end
            if nargin < 7, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( '%s %s: %s Steady State Response %s', encoding_scheme, subnetwork_name, encoded_string, title_tag );
            xlabel_string = sprintf( 'Gain, %s [%s]', variable_strings{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variable_strings{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Output, %s [%s]', encoded_string, variable_strings{ 3 }, units{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )
            
            % Plot the desired, theoretical, and numerical responses.
            surf( Xs, scale*Ys, scale*Zs_desired, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
            surf( Xs, scale*Ys, scale*Zs_theoretical, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
            surf( Xs, scale*Ys, scale*Zs_numerical, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
            
            % Add a legend to the figure.
            legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_%s_ssr_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state response of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = plot_steady_state_response_patch( self, xs, ys_mean, ys_min, ys_max, color, scale, subnetwork_name, encoding_scheme, encoded_string, input_variable_string, output_variable_string, unit, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 16, save_tag = ''; end
            if nargin < 15, save_directory = './'; end
            if nargin < 14, save_flag = true; end
            if nargin < 13, unit = 'mV'; end
            if nargin < 12, output_variable_string = 'U2'; end
            if nargin < 11, input_variable_string = 'U1'; end
            if nargin < 10, encoded_string = 'Encoded'; end
            if nargin < 9, encoding_scheme = 'Absolute'; end
            if nargin < 8, subnetwork_name = 'Transmission'; end
            if nargin < 7, scale = 1; end
            
            % Generate the patch data.
            [ xs_patch, ys_patch ] = self.generate_2D_patch_data( xs, ys_min, ys_max );
            
            % Compute the figure labels.
            title_string = sprintf( '%s %s: %s Steady State Response Summary', encoding_scheme, subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( '%s Output, %s [%s]', encoded_string, output_variable_string, unit );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )            
            
            % Plot a summary of the absolute encoded steady state behavior over the formulation parameters.
            patch( scale*xs_patch, scale*ys_patch, color, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
            plot( scale*xs, scale*ys_mean, '-', 'Color', color, 'Linewidth', 3 )
            plot( scale*xs, scale*ys_min, '--', 'Color', color, 'Linewidth', 1 )
            plot( scale*xs, scale*ys_max, '--', 'Color', color, 'Linewidth', 1 )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_%s_ssr_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state response of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = surf_steady_state_response_patch( self, Xs, Ys, Zs, Zs_lower, Zs_upper, color, scale, viewing_angle, subnetwork_name, encoding_scheme, encoded_string, variable_strings, units, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 18, save_tag = ''; end
            if nargin < 17, save_directory = './'; end
            if nargin < 16, save_flag = true; end
            if nargin < 15, title_tag = ''; end
            if nargin < 14, units = { '-', 'mV', 'mV' }; end
            if nargin < 13, variable_strings = { 'c1', 'U1', 'U2' }; end
            if nargin < 12, encoded_string = 'Encoded'; end
            if nargin < 11, encoding_scheme = 'Absolute'; end
            if nargin < 10, subnetwork_name = 'Transmission'; end
            if nargin < 9, viewing_angle = [ 145, 15 ]; end
            if nargin < 8, scale = 1; end
            if nargin < 7, color = [ 0.0000, 0.4470, 0.7410 ]; end
            
            % Generate the patch data.
            [ ps_patch_xlower, ps_patch_xupper, ps_patch_ylower, ps_patch_yupper, ps_patch_zlower, ps_patch_zupper ] = self.generate_3D_patch_data( Xs, Ys, Zs_lower, Zs_upper );
            
            % Compute the figure labels.
            title_string = sprintf( '%s %s: %s Steady State Response %s', encoding_scheme, subnetwork_name, encoded_string, title_tag );
            xlabel_string = sprintf( 'Gain, %s [%s]', variable_strings{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variable_strings{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Output, %s [%s]', encoded_string, variable_strings{ 3 }, units{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )
                        
            % Plot the surface data.
            surf( Xs, scale*Ys, scale*Zs, 'Edgecolor', 'None', 'Facecolor', color, 'Facealpha', 0.90 )
            
            % Plot the patches.
            patch( ps_patch_xlower( :, 1 ), scale*ps_patch_xlower( :, 2 ), scale*ps_patch_xlower( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_xupper( :, 1 ), scale*ps_patch_xupper( :, 2 ), scale*ps_patch_xupper( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_ylower( :, 1 ), scale*ps_patch_ylower( :, 2 ), scale*ps_patch_ylower( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_yupper( :, 1 ), scale*ps_patch_yupper( :, 2 ), scale*ps_patch_yupper( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zlower( :, 1 ), scale*ps_patch_zlower( :, 2 ), scale*ps_patch_zlower( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zupper( :, 1 ), scale*ps_patch_zupper( :, 2 ), scale*ps_patch_zupper( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                        
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_%s_ssr_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state response of a subnetwork for a specific gain.
        function fig = plot_steady_state_response_comparison( ~, xs_absolute, ys_desired_absolute, ys_theoretical_absolute, ys_numerical_absolute, color_absolute, xs_relative, ys_desired_relative, ys_theoretical_relative, ys_numerical_relative, color_relative, scale, subnetwork_name, encoded_string, input_variable_string, output_variable_string, unit, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 21, save_tag = ''; end
            if nargin < 20, save_directory = './'; end
            if nargin < 19, save_flag = true; end
            if nargin < 18, compact_flag = true; end
            if nargin < 17, unit = 'mV'; end
            if nargin < 16, output_variable_string = 'U2'; end
            if nargin < 15, input_variable_string = 'U1'; end
            if nargin < 14, encoded_string = 'Encoded'; end
            if nargin < 13, subnetwork_name = 'Transmission'; end
            if nargin < 12, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( 'Absolute vs Relative %s: %s Steady State Response', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( '%s Output, %s [%s]', encoded_string, output_variable_string, unit );

            % Create a figure to store the data.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to compare the absolute and relative encoding schemes on a single subplot or multiple.
            if compact_flag                   % If we want to make multiple subplots...
                
                % Format the figure.
                hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )

                % Plot the absolute desired, theoretical, and numerical steady state responses.
                plot( scale*xs_absolute, scale*ys_desired_absolute, '-', 'Color', [ color_absolute, 1/3 ], 'Linewidth', 3 )
                plot( scale*xs_absolute, scale*ys_theoretical_absolute, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale*xs_absolute, scale*ys_numerical_absolute, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )

                % Plot the relative desired, theoretical, and numerical steady state responses.
                plot( scale*xs_relative, scale*ys_desired_relative, '-', 'Color', [ color_relative, 1/3 ], 'Linewidth', 3 )
                plot( scale*xs_relative, scale*ys_theoretical_relative, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale*xs_relative, scale*ys_numerical_relative, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )

                % Add a legend to the figure.
                legend( { 'Absolute Desired', 'Absolute Achieved (Theory)', 'Absolute Achieved (Numerical)', 'Relative Desired', 'Relative Achieved (Theory)', 'Relative Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            else                                % Otherwise...
                
                % Create the subplot titles.
                subplot_title1 = sprintf( 'Absolute %s: %s Steady State Response', subnetwork_name, encoded_string );
                subplot_title2 = sprintf( 'Relative %s: %s Steady State Response', subnetwork_name, encoded_string );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( subplot_title1 )
                plot( scale*xs_absolute, scale*ys_desired_absolute, '-', 'Color', [ color_absolute, 1/3 ], 'Linewidth', 3 )
                plot( scale*xs_absolute, scale*ys_theoretical_absolute, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale*xs_absolute, scale*ys_numerical_absolute, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )
                legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( subplot_title2 )
                plot( scale*xs_relative, scale*ys_desired_relative, '-', 'Color', [ color_relative, 1/3 ], 'Linewidth', 3 )
                plot( scale*xs_relative, scale*ys_theoretical_relative, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale*xs_relative, scale*ys_numerical_relative, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            end
                
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_ssr_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state reponse of a subnetwork for a specific gain.
        function fig = surf_steady_state_response_comparison( ~, Xs_absolute, Ys_absolute, Zs_desired_absolute, Zs_theoretical_absolute, Zs_numerical_absolute, color_absolute, Xs_relative, Ys_relative, Zs_desired_relative, Zs_theoretical_relative, Zs_numerical_relative, color_relative, scale, viewing_angle, subnetwork_name, encoded_string, variable_strings, units, title_tag, compact_flag, save_flag, save_directory, save_tag  )
            
            % Set the default input arguments.
            if nargin < 24, save_tag = ''; end
            if nargin < 23, save_directory = './'; end
            if nargin < 22, save_flag = true; end
            if nargin < 21, compact_flag = true; end
            if nargin < 20, title_tag = ''; end
            if nargin < 19, units = { '-', 'mV', 'mV' }; end
            if nargin < 18, variable_strings = { 'c1', 'U1', 'U2' }; end
            if nargin < 17, encoded_string = 'Encoded'; end
            if nargin < 16, subnetwork_name = 'Transmission'; end
            if nargin < 15, viewing_angle = [ 145, 15 ]; end
            if nargin < 14, scale = 1; end
            
            % Create the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: %s Steady State Response %s', subnetwork_name, encoded_string, title_tag );
            
            % Create the figure labels.
            xlabel_string = sprintf( 'Gain, %s [%s]', variable_strings{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variable_strings{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Output, %s [%s]', encoded_string, variable_strings{ 3 }, units{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to create a compact plot.
            if compact_flag                 % If we want to create a compact plot...
                
                % Format the figure.
                hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )            

                % Plot the absolute desired, theoretical, and numerical steady state responses.
                surf( Xs_absolute, scale*Ys_absolute, scale*Zs_desired_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1/3 )
                surf( Xs_absolute, scale*Ys_absolute, scale*Zs_theoretical_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute, scale*Ys_absolute, scale*Zs_numerical_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 ) 

                % Plot the relative desired, theoretical, and numerical steady state responses.
                surf( Xs_relative, scale*Ys_relative, scale*Zs_desired_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1/3 )
                surf( Xs_relative, scale*Ys_relative, scale*Zs_theoretical_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative, scale*Ys_relative, scale*Zs_numerical_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 ) 

                % Add a legend to the figure.
                legend( { 'Absolute Desired', 'Absolute Achieved (Theory)', 'Absolute Achieved (Numerical)', 'Relative Desired', 'Relative Achieved (Theory)', 'Relative Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            else                            % Otherwise...
            
                % Create the subplot titles.
                subplot_title1 = sprintf( 'Absolute %s: %s Steady State Response %s', subnetwork_name, encoded_string, title_tag );
                subplot_title2 = sprintf( 'Relative %s: %s Steady State Response %s', subnetwork_name, encoded_string, title_tag );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title1 )            
                surf( Xs_absolute, scale*Ys_absolute, scale*Zs_desired_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1/3 )
                surf( Xs_absolute, scale*Ys_absolute, scale*Zs_theoretical_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute, scale*Ys_absolute, scale*Zs_numerical_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 )            
                legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )

                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title2 )            
                surf( Xs_relative, scale*Ys_relative, scale*Zs_desired_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1/3 )
                surf( Xs_relative, scale*Ys_relative, scale*Zs_theoretical_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative, scale*Ys_relative, scale*Zs_numerical_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )            
                legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )

            end
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_ssr_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state response of a subnetwork for a specific gain, including upper and lower boundaries.
        function fig = plot_steady_state_response_patch_comparison( self, xs, ys_mean_absolute, ys_min_absolute, ys_max_absolute, color_absolute, ys_mean_relative, ys_min_relative, ys_max_relative, color_relative, scale, subnetwork_name, encoded_string, input_variable_string, output_variable_string, unit, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 20, save_tag = ''; end
            if nargin < 19, save_directory = './'; end
            if nargin < 18, save_flag = true; end
            if nargin < 17, compact_flag = truel; end
            if nargin < 16, unit = 'mV'; end
            if nargin < 15, output_variable_string = 'U2'; end
            if nargin < 14, input_variable_string = 'U1'; end
            if nargin < 13, encoded_string = 'Encoded'; end
            if nargin < 12, subnetwork_name = 'Transmission'; end
            if nargin < 11, scale = 1; end
            
            % Generate the patch data.
            [ xs_patch, ys_patch_absolute ] = self.generate_2D_patch_data( xs, ys_min_absolute, ys_max_absolute );
            [ ~, ys_patch_relative ] = self.generate_2D_patch_data( xs, ys_min_relative, ys_max_relative );
            
            % Compute the figure labels.
            title_string = sprintf( 'Absolute vs Relative %s: %s Steady State Response Summary', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( '%s Output, %s [%s]', encoded_string, output_variable_string, unit );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine how to create the subplots.
            if compact_flag                 % If we want to plot in a compact manner...
            
                % Format the figure.
                hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )            

                % Plot a summary of the absolute steady state behavior.
                patch( scale*xs_patch, scale*ys_patch_absolute, color_absolute, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale*xs, scale*ys_mean_absolute, '-', 'Color', color_absolute, 'Linewidth', 3 )
                plot( scale*xs, scale*ys_min_absolute, '--', 'Color', color_absolute, 'Linewidth', 1 )
                plot( scale*xs, scale*ys_max_absolute, '--', 'Color', color_absolute, 'Linewidth', 1 )

                % Plot a summary of the relative steady state behavior.
                patch( scale*xs_patch, scale*ys_patch_relative, color_relative, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale*xs, scale*ys_mean_relative, '-', 'Color', color_relative, 'Linewidth', 3 )
                plot( scale*xs, scale*ys_min_relative, '--', 'Color', color_relative, 'Linewidth', 1 )
                plot( scale*xs, scale*ys_max_relative, '--', 'Color', color_relative, 'Linewidth', 1 )
                            
            else                            % Otherwise...
                
                % Create the subplot titles.
                subplot_title1 = sprintf( 'Absolute %s: %s Steady State Response', subnetwork_name, encoded_string );
                subplot_title2 = sprintf( 'Relative %s: %s Steady State Response', subnetwork_name, encoded_string );
                
                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( subplot_title1 )
                patch( scale*xs_patch, scale*ys_patch_absolute, color_absolute, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale*xs, scale*ys_mean_absolute, '-', 'Color', color_absolute, 'Linewidth', 3 )
                plot( scale*xs, scale*ys_min_absolute, '--', 'Color', color_absolute, 'Linewidth', 1 )
                plot( scale*xs, scale*ys_max_absolute, '--', 'Color', color_absolute, 'Linewidth', 1 )
                
                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( subplot_title2 )
                patch( scale*xs_patch, scale*ys_patch_relative, color_relative, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale*xs, scale*ys_mean_relative, '-', 'Color', color_relative, 'Linewidth', 3 )
                plot( scale*xs, scale*ys_min_relative, '--', 'Color', color_relative, 'Linewidth', 1 )
                plot( scale*xs, scale*ys_max_relative, '--', 'Color', color_relative, 'Linewidth', 1 )
                
            end
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_ssr_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state response of a subnetwork for a specific gain, including upper and lower boundaries.
        function fig = surf_steady_state_response_patch_comparison( self, Xs_absolute, Ys_absolute, Zs_absolute, Zs_lower_absolute, Zs_upper_absolute, color_absolute, Xs_relative, Ys_relative, Zs_relative, Zs_lower_relative, Zs_upper_relative, color_relative, scale, viewing_angle, subnetwork_name, encoded_string, variable_strings, units, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 24, save_tag = ''; end
            if nargin < 23, save_directory = './'; end
            if nargin < 22, save_flag = true; end
            if nargin < 21, compact_flag = truel; end
            if nargin < 20, title_tag = ''; end
            if nargin < 19, units = { '-', 'mV', 'mV' }; end
            if nargin < 18, variable_strings = { 'c1', 'U1', 'U2' }; end
            if nargin < 17, encoded_string = 'Encoded'; end
            if nargin < 16, subnetwork_name = 'Transmission'; end
            if nargin < 15, viewing_angle = [ 145, 15 ]; end
            if nargin < 14, scale = 1; end
                        
            % Generate the patch data.
            [ ps_patch_xlower_absolute, ps_patch_xupper_absolute, ps_patch_ylower_absolute, ps_patch_yupper_absolute, ps_patch_zlower_absolute, ps_patch_zupper_absolute ] = self.generate_3D_patch_data( Xs_absolute, Ys_absolute, Zs_lower_absolute, Zs_upper_absolute );
            [ ps_patch_xlower_relative, ps_patch_xupper_relative, ps_patch_ylower_relative, ps_patch_yupper_relative, ps_patch_zlower_relative, ps_patch_zupper_relative ] = self.generate_3D_patch_data( Xs_relative, Ys_relative, Zs_lower_relative, Zs_upper_relative );

            % Create the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: %s Steady State Response %s', subnetwork_name, encoded_string, title_tag );
            
            % Create the figure labels.
            xlabel_string = sprintf( 'Gain, %s [%s]', variable_strings{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variable_strings{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Output, %s [%s]', encoded_string, variable_strings{ 3 }, units{ 3 } );
                        
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to create a compact plot.
            if compact_flag                 % If we want to create a compact plot...
                
                % Format the figure.
                hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )            

                % Plot the absolute steady state response data.
                surf( Xs_absolute, scale*Ys_absolute, scale*Zs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_absolute( :, 1 ), scale*ps_patch_xlower_absolute( :, 2 ), scale*ps_patch_xlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_absolute( :, 1 ), scale*ps_patch_xupper_absolute( :, 2 ), scale*ps_patch_xupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute( :, 1 ), scale*ps_patch_ylower_absolute( :, 2 ), scale*ps_patch_ylower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute( :, 1 ), scale*ps_patch_yupper_absolute( :, 2 ), scale*ps_patch_yupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute( :, 1 ), scale*ps_patch_zlower_absolute( :, 2 ), scale*ps_patch_zlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute( :, 1 ), scale*ps_patch_zupper_absolute( :, 2 ), scale*ps_patch_zupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                % Plot the relative steady state response data.
                surf( Xs_relative, scale*Ys_relative, scale*Zs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_relative( :, 1 ), scale*ps_patch_xlower_relative( :, 2 ), scale*ps_patch_xlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_relative( :, 1 ), scale*ps_patch_xupper_relative( :, 2 ), scale*ps_patch_xupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative( :, 1 ), scale*ps_patch_ylower_relative( :, 2 ), scale*ps_patch_ylower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative( :, 1 ), scale*ps_patch_yupper_relative( :, 2 ), scale*ps_patch_yupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative( :, 1 ), scale*ps_patch_zlower_relative( :, 2 ), scale*ps_patch_zlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative( :, 1 ), scale*ps_patch_zupper_relative( :, 2 ), scale*ps_patch_zupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
            else                            % Otherwise...
            
                % Create the subplot titles.
                subplot_title_absolute = sprintf( 'Absolute %s: %s Steady State Response %s', subnetwork_name, encoded_string, title_tag );
                subplot_title_relative = sprintf( 'Relative %s: %s Steady State Response %s', subnetwork_name, encoded_string, title_tag );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title_absolute )            
                surf( Xs_absolute, scale*Ys_absolute, scale*Zs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_absolute( :, 1 ), scale*ps_patch_xlower_absolute( :, 2 ), scale*ps_patch_xlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_absolute( :, 1 ), scale*ps_patch_xupper_absolute( :, 2 ), scale*ps_patch_xupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute( :, 1 ), scale*ps_patch_ylower_absolute( :, 2 ), scale*ps_patch_ylower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute( :, 1 ), scale*ps_patch_yupper_absolute( :, 2 ), scale*ps_patch_yupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute( :, 1 ), scale*ps_patch_zlower_absolute( :, 2 ), scale*ps_patch_zlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute( :, 1 ), scale*ps_patch_zupper_absolute( :, 2 ), scale*ps_patch_zupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title_relative )            
                surf( Xs_relative, scale*Ys_relative, scale*Zs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_relative( :, 1 ), scale*ps_patch_xlower_relative( :, 2 ), scale*ps_patch_xlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_relative( :, 1 ), scale*ps_patch_xupper_relative( :, 2 ), scale*ps_patch_xupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative( :, 1 ), scale*ps_patch_ylower_relative( :, 2 ), scale*ps_patch_ylower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative( :, 1 ), scale*ps_patch_yupper_relative( :, 2 ), scale*ps_patch_yupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative( :, 1 ), scale*ps_patch_zlower_relative( :, 2 ), scale*ps_patch_zlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative( :, 1 ), scale*ps_patch_zupper_relative( :, 2 ), scale*ps_patch_zupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
            end
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_ssr_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state response for a subnetwork that compares absolute & relative schemes before and after encoding/decoding.
        function fig = plot_steady_state_response_full_comparison( ~, xs_absolute_encoded, ys_desired_absolute_encoded, ys_theoretical_absolute_encoded, ys_numerical_absolute_encoded, xs_absolute_decoded, ys_desired_absolute_decoded, ys_theoretical_absolute_decoded, ys_numerical_absolute_decoded, color_absolute, xs_relative_encoded, ys_desired_relative_encoded, ys_theoretical_relative_encoded, ys_numerical_relative_encoded, xs_relative_decoded, ys_desired_relative_decoded, ys_theoretical_relative_decoded, ys_numerical_relative_decoded, color_relative, scale_encoded, scale_decoded, subnetwork_name, input_variable_string_encoded, input_variable_string_decoded, output_variable_string_encoded, output_variable_string_decoded, unit_encoded, unit_decoded, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 32, save_tag = ''; end
            if nargin < 31, save_directory = './'; end
            if nargin < 30, save_flag = true; end
            if nargin < 29, compact_flag = true; end
            if nargin < 28, unit_decoded = '-'; end
            if nargin < 27, unit_encoded = 'mV'; end
            if nargin < 26, output_variable_string_decoded = 'x2'; end
            if nargin < 25, output_variable_string_encoded = 'U2'; end
            if nargin < 24, input_variable_string_decoded = 'x1'; end
            if nargin < 23, input_variable_string_encoded = 'U1'; end
            if nargin < 22, subnetwork_name = 'Transmission'; end
            if nargin < 21, scale_decoded = 1; end
            if nargin < 20, scale_encoded = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( 'Absolute vs Relative %s: Encoded vs Decoded Steady State Response', subnetwork_name );
            xlabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', input_variable_string_encoded, unit_encoded );
            ylabel_string_encoded = sprintf( 'Encoded Output, %s [%s]', output_variable_string_encoded, unit_encoded );
            xlabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', input_variable_string_decoded, unit_decoded );
            ylabel_string_decoded = sprintf( 'Decoded Output, %s [%s]', output_variable_string_decoded, unit_decoded );
            
            % Create a figure to store the data.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to compare the absolute and relative encoding schemes on a single subplot or multiple.
            if compact_flag                   % If we want to make multiple subplots...
                
                % Create the subplot titles.
                subplot_title_encoded = sprintf( 'Absolute %s: Encoded Steady State Response', subnetwork_name );
                subplot_title_decoded = sprintf( 'Relative %s: Decoded Steady State Response', subnetwork_name );

                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_encoded )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*ys_desired_absolute_encoded, '-', 'Color', [ color_absolute, 1/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*ys_theoretical_absolute_encoded, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*ys_numerical_absolute_encoded, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*ys_desired_relative_encoded, '-', 'Color', [ color_relative, 1/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*ys_theoretical_relative_encoded, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*ys_numerical_relative_encoded, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Absolute Desired', 'Absolute Achieved (Theory)', 'Absolute Achieved (Numerical)', 'Relative Desired', 'Relative Achieved (Theory)', 'Relative Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )

                % Create the second subplot.
                subplot( 1, 2, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_decoded )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*ys_desired_absolute_decoded, '-', 'Color', [ color_absolute, 1/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*ys_theoretical_absolute_decoded, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*ys_numerical_absolute_decoded, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*ys_desired_relative_decoded, '-', 'Color', [ color_relative, 1/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*ys_theoretical_relative_decoded, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*ys_numerical_relative_decoded, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Absolute Desired', 'Absolute Achieved (Theory)', 'Absolute Achieved (Numerical)', 'Relative Desired', 'Relative Achieved (Theory)', 'Relative Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
            else                                % Otherwise...
                
                % Create the subplot titles.
                subplot_title_absolute_encoded = sprintf( 'Absolute %s: Encoded Steady State Response', subnetwork_name );
                subplot_title_relative_encoded = sprintf( 'Relative %s: Encoded Steady State Response', subnetwork_name );
                subplot_title_absolute_decoded = sprintf( 'Absolute %s: Decoded Steady State Response', subnetwork_name );
                subplot_title_relative_decoded = sprintf( 'Relative %s: Decoded Steady State Response', subnetwork_name );

                % Create the first subplot.
                subplot( 2, 2, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_absolute_encoded )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*ys_desired_absolute_encoded, '-', 'Color', [ color_absolute, 1/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*ys_theoretical_absolute_encoded, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*ys_numerical_absolute_encoded, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )
                legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
                % Create the second subplot.
                subplot( 2, 2, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_absolute_decoded )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*ys_desired_absolute_decoded, '-', 'Color', [ color_absolute, 1/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*ys_theoretical_absolute_decoded, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*ys_numerical_absolute_decoded, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )
                legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
                % Create the third subplot.
                subplot( 2, 2, 3 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_relative_encoded )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*ys_desired_relative_encoded, '-', 'Color', [ color_relative, 1/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*ys_theoretical_relative_encoded, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*ys_numerical_relative_encoded, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

                % Create the fourth subplot.
                subplot( 2, 2, 4 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_relative_decoded )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*ys_desired_relative_decoded, '-', 'Color', [ color_relative, 1/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*ys_theoretical_relative_decoded, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*ys_numerical_relative_decoded, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

            end
                
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_ssr_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state response for a subnetwork that compares absolute & relative schemes before and after encoding/decoding.
        function fig = surf_steady_state_response_full_comparison( ~, Xs_absolute_encoded, Ys_absolute_encoded, Zs_desired_absolute_encoded, Zs_theoretical_absolute_encoded, Zs_numerical_absolute_encoded, Xs_absolute_decoded, Ys_absolute_decoded, Zs_desired_absolute_decoded, Zs_theoretical_absolute_decoded, Zs_numerical_absolute_decoded, color_absolute, Xs_relative_encoded, Ys_relative_encoded, Zs_desired_relative_encoded, Zs_theoretical_relative_encoded, Zs_numerical_relative_encoded, Xs_relative_decoded, Ys_relative_decoded, Zs_desired_relative_decoded, Zs_theoretical_relative_decoded, Zs_numerical_relative_decoded, color_relative, scale_encoded, scale_decoded, viewing_angle, subnetwork_name, variable_strings_encoded, variable_strings_decoded, units_encoded, units_decoded, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 36, save_tag = ''; end
            if nargin < 35, save_directory = './'; end
            if nargin < 34, save_flag = true; end
            if nargin < 33, compact_flag = true; end
            if nargin < 32, title_tag = ''; end
            if nargin < 31, units_decoded = { '-', '-', '-' }; end
            if nargin < 30, units_encoded = { '-', 'mV', 'mV' }; end
            if nargin < 29, variable_strings_decoded = { 'c1', 'x1', 'x2' }; end
            if nargin < 28, variable_strings_encoded = { 'c1', 'U1', 'U2' }; end
            if nargin < 27, subnetwork_name = 'Transmission'; end
            if nargin < 26, viewing_angle = [ 145, 15 ]; end
            if nargin < 25, scale_decoded = 1; end
            if nargin < 24, scale_encoded = 1; end
            
            % Define the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: Steady State Response %s', subnetwork_name, title_tag );
            
            % Define the figure labels.
            xlabel_string_encoded = sprintf( 'Gain, %s [%s]', variable_strings_encoded{ 1 }, units_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variable_strings_encoded{ 2 }, units_encoded{ 2 } );
            zlabel_string_encoded = sprintf( 'Encoded Output, %s [%s]', variable_strings_encoded{ 3 }, units_encoded{ 3 } );
            
            xlabel_string_decoded = sprintf( 'Gain, %s [%s]', variable_strings_decoded{ 1 }, units_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variable_strings_decoded{ 2 }, units_decoded{ 2 } );
            zlabel_string_decoded = sprintf( 'Decoded Output, %s [%s]', variable_strings_decoded{ 3 }, units_decoded{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to plot in a compact fashion.
            if compact_flag                 % If we want to create a compact plot...
                
                % Create the subplot titles.
                subplot_title_encoded = sprintf( 'Absolute %s: Encoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_decoded = sprintf( 'Relative %s: Decoded Steady State Response %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_encoded )            
                surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Zs_desired_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1/3 )
                surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Zs_theoretical_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Zs_numerical_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 )            
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Zs_desired_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1/3 )
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Zs_theoretical_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Zs_numerical_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )            
                legend( { 'Absolute Desired', 'Absolute Achieved (Theory)', 'Absolute Achieved (Numerical)', 'Relative Desired', 'Relative Achieved (Theory)', 'Relative Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
                % Create the second subplot.
                subplot( 1, 2, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_decoded )            
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Zs_desired_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1/3 )
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Zs_theoretical_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Zs_numerical_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 )            
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Zs_desired_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1/3 )
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Zs_theoretical_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Zs_numerical_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )
                legend( { 'Absolute Desired', 'Absolute Achieved (Theory)', 'Absolute Achieved (Numerical)', 'Relative Desired', 'Relative Achieved (Theory)', 'Relative Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )

            else                            % Otherwise...
                
                % Create the subplot titles.
                subplot_title_absolute_encoded = sprintf( 'Absolute %s: Encoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_relative_encoded = sprintf( 'Relative %s: Encoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_absolute_decoded = sprintf( 'Absolute %s: Decoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_relative_decoded = sprintf( 'Relative %s: Decoded Steady State Response %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 2, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_absolute_encoded ) 
                surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Zs_desired_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1/3 )
                surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Zs_theoretical_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Zs_numerical_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 )                 
                legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
                % Create the second subplot.
                subplot( 2, 2, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_absolute_decoded )
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Zs_desired_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1/3 )
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Zs_theoretical_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Zs_numerical_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 )  
                legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
                % Create the third subplot.
                subplot( 2, 2, 3 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_relative_encoded )
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Zs_desired_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1/3 )
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Zs_theoretical_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Zs_numerical_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )
                legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

                % Create the fourth subplot.
                subplot( 2, 2, 4 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_relative_decoded )
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Zs_desired_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1/3 )
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Zs_theoretical_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Zs_numerical_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )
                legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            end
                
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_ssr_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state response for a subnetwork that compares absolute & relative schemes before and after encoding/decoding, including upper and lower boundaries.
        function fig = plot_steady_state_response_patch_full_comparison( self, xs_encoded, ys_mean_absolute_encoded, ys_min_absolute_encoded, ys_max_absolute_encoded, xs_decoded, ys_mean_absolute_decoded, ys_min_absolute_decoded, ys_max_absolute_decoded, color_absolute, ys_mean_relative_encoded, ys_min_relative_encoded, ys_max_relative_encoded, ys_mean_relative_decoded, ys_min_relative_decoded, ys_max_relative_decoded, color_relative, scale_encoded, scale_decoded, subnetwork_name, input_variable_string_encoded, input_variable_string_decoded, output_variable_string_encoded, output_variable_string_decoded, unit_encoded, unit_decoded, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 30, save_tag = ''; end
            if nargin < 29, save_directory = './'; end
            if nargin < 28, save_flag = true; end
            if nargin < 27, compact_flag = true; end
            if nargin < 26, unit_decoded = '-'; end
            if nargin < 25, unit_encoded = 'mV'; end
            if nargin < 24, output_variable_string_decoded = 'x2'; end
            if nargin < 23, output_variable_string_encoded = 'U2'; end
            if nargin < 22, input_variable_string_decoded = 'x1'; end
            if nargin < 21, input_variable_string_encoded = 'U1'; end
            if nargin < 20, subnetwork_name = 'Transmission'; end
            if nargin < 19, scale_decoded = 1; end
            if nargin < 18, scale_encoded = 1; end
            
            % Generate the patch data.
            [ xs_patch_encoded, ys_patch_absolute_encoded ] = self.generate_2D_patch_data( xs_encoded, ys_min_absolute_encoded, ys_max_absolute_encoded );
            [ ~, ys_patch_relative_encoded ] = self.generate_2D_patch_data( xs_encoded, ys_min_relative_encoded, ys_max_relative_encoded );
            [ xs_patch_decoded, ys_patch_absolute_decoded ] = self.generate_2D_patch_data( xs_decoded, ys_min_absolute_decoded, ys_max_absolute_decoded );
            [ ~, ys_patch_relative_decoded ] = self.generate_2D_patch_data( xs_decoded, ys_min_relative_decoded, ys_max_relative_decoded );
            
            % Compute the figure labels.
            title_string = sprintf( 'Absolute vs Relative %s: Encoded vs Decoded Steady State Response Summary', subnetwork_name );
            xlabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', input_variable_string_encoded, unit_encoded );
            ylabel_string_encoded = sprintf( 'Encoded Output, %s [%s]', output_variable_string_encoded, unit_encoded );
            xlabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', input_variable_string_decoded, unit_decoded );
            ylabel_string_decoded = sprintf( 'Decoded Output, %s [%s]', output_variable_string_decoded, unit_decoded );
            
            % Create a figure to store the data.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to compare the absolute and relative encoding schemes on a single subplot or multiple.
            if compact_flag                   % If we want to make multiple subplots...
                
                % Create the subplot titles.
                subplot_title_encoded = sprintf( 'Absolute %s: Encoded Steady State Response', subnetwork_name );
                subplot_title_decoded = sprintf( 'Relative %s: Decoded Steady State Response', subnetwork_name );

                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_encoded )
                patch( scale_encoded*xs_patch_encoded, scale_encoded*ys_patch_absolute_encoded, color_absolute, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale_encoded*xs_encoded, scale_encoded*ys_mean_absolute_encoded, '-', 'Color', color_absolute, 'Linewidth', 3 )
                plot( scale_encoded*xs_encoded, scale_encoded*ys_min_absolute_encoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                plot( scale_encoded*xs_encoded, scale_encoded*ys_max_absolute_encoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                patch( scale_encoded*xs_patch_encoded, scale_encoded*ys_patch_relative_encoded, color_relative, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale_encoded*xs_encoded, scale_encoded*ys_mean_relative_encoded, '-', 'Color', color_relative, 'Linewidth', 3 )
                plot( scale_encoded*xs_encoded, scale_encoded*ys_min_relative_encoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                plot( scale_encoded*xs_encoded, scale_encoded*ys_max_relative_encoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                
                % Create the second subplot.
                subplot( 1, 2, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_decoded )
                patch( scale_decoded*xs_patch_decoded, scale_decoded*ys_patch_absolute_decoded, color_absolute, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale_decoded*xs_decoded, scale_decoded*ys_mean_absolute_decoded, '-', 'Color', color_absolute, 'Linewidth', 3 )
                plot( scale_decoded*xs_decoded, scale_decoded*ys_min_absolute_decoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                plot( scale_decoded*xs_decoded, scale_decoded*ys_max_absolute_decoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                patch( scale_decoded*xs_patch_decoded, scale_decoded*ys_patch_relative_decoded, color_relative, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale_decoded*xs_decoded, scale_decoded*ys_mean_relative_decoded, '-', 'Color', color_relative, 'Linewidth', 3 )
                plot( scale_decoded*xs_decoded, scale_decoded*ys_min_relative_decoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                plot( scale_decoded*xs_decoded, scale_decoded*ys_max_relative_decoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                
            else                                % Otherwise...
                
                % Create the subplot titles.
                subplot_title_absolute_encoded = sprintf( 'Absolute %s: Encoded Steady State Response', subnetwork_name );
                subplot_title_relative_encoded = sprintf( 'Relative %s: Encoded Steady State Response', subnetwork_name );
                subplot_title_absolute_decoded = sprintf( 'Absolute %s: Decoded Steady State Response', subnetwork_name );
                subplot_title_relative_decoded = sprintf( 'Relative %s: Decoded Steady State Response', subnetwork_name );

                % Create the first subplot.
                subplot( 2, 2, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_absolute_encoded )
                patch( scale_encoded*xs_patch_encoded, scale_encoded*ys_patch_absolute_encoded, color_absolute, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale_encoded*xs_encoded, scale_encoded*ys_mean_absolute_encoded, '-', 'Color', color_absolute, 'Linewidth', 3 )
                plot( scale_encoded*xs_encoded, scale_encoded*ys_min_absolute_encoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                plot( scale_encoded*xs_encoded, scale_encoded*ys_max_absolute_encoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                
                % Create the second subplot.
                subplot( 2, 2, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_absolute_decoded )
                patch( scale_decoded*xs_patch_decoded, scale_decoded*ys_patch_absolute_decoded, color_absolute, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale_decoded*xs_decoded, scale_decoded*ys_mean_absolute_decoded, '-', 'Color', color_absolute, 'Linewidth', 3 )
                plot( scale_decoded*xs_decoded, scale_decoded*ys_min_absolute_decoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                plot( scale_decoded*xs_decoded, scale_decoded*ys_max_absolute_decoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                
                % Create the third subplot.
                subplot( 2, 2, 3 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_relative_encoded )
                patch( scale_encoded*xs_patch_encoded, scale_encoded*ys_patch_relative_encoded, color_relative, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale_encoded*xs_encoded, scale_encoded*ys_mean_relative_encoded, '-', 'Color', color_relative, 'Linewidth', 3 )
                plot( scale_encoded*xs_encoded, scale_encoded*ys_min_relative_encoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                plot( scale_encoded*xs_encoded, scale_encoded*ys_max_relative_encoded, '--', 'Color', color_relative, 'Linewidth', 1 )

                % Create the fourth subplot.
                subplot( 2, 2, 4 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_relative_decoded )
                patch( scale_decoded*xs_patch_decoded, scale_decoded*ys_patch_relative_decoded, color_relative, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale_decoded*xs_decoded, scale_decoded*ys_mean_relative_decoded, '-', 'Color', color_relative, 'Linewidth', 3 )
                plot( scale_decoded*xs_decoded, scale_decoded*ys_min_relative_decoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                plot( scale_decoded*xs_decoded, scale_decoded*ys_max_relative_decoded, '--', 'Color', color_relative, 'Linewidth', 1 )

            end
                
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_ssr_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state response for a subnetwork that compares absolute & relative schemes before and after encoding/decoding, including upper and lower boundaries.
        
        
        
        % Implement a function to plot the steady state error of a subnetwork for a specific gain.
        function fig = plot_steady_state_error_comparison( ~, xs_absolute, errors_theoretical_absolute, errors_numerical_absolute, color_absolute, xs_relative, errors_theoretical_relative, errors_numerical_relative, color_relative, scale, subnetwork_name, encoded_string, input_variable_string, output_variable_string, unit, save_flag, save_directory )
            
            % Set the default input arguments.
            if nargin < 17, save_directory = './'; end
            if nargin < 16, save_flag = true; end
            if nargin < 15, unit = 'mV'; end
            if nargin < 14, output_variable_string = 'dU'; end
            if nargin < 13, input_variable_string = 'U1'; end
            if nargin < 12, encoded_string = 'Encoded'; end
            if nargin < 11, subnetwork_name = 'Transmission'; end
            if nargin < 10, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( 'Absolute vs Relative %s: %s Steady State Error', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( '%s Error, %s [%s]', encoded_string, output_variable_string, unit );

            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
            
            % Plot the absolute and relative theoretical and numerical errors.
            plot( scale*xs_absolute, scale*errors_theoretical_absolute, '-.', 'Color', color_absolute, 'Linewidth', 3 )
            plot( scale*xs_absolute, scale*errors_numerical_absolute, '--', 'Color', color_absolute, 'Linewidth', 3 )
            plot( scale*xs_relative, scale*errors_theoretical_relative, '-.', 'Color', color_relative, 'Linewidth', 3 )
            plot( scale*xs_relative, scale*errors_numerical_relative, '--', 'Color', color_relative, 'Linewidth', 3 )
            
            % Add a legend to the figure.
            legend( { 'Absolute Theoretical', 'Absolute Numerical', 'Relative Theoretical', 'Relative Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_steady_state_error.png', lower( subnetwork_name ), lower( encoded_string ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error percentage of a subnetwork for a specific gain.
        function fig = plot_steady_state_error_percentage_comparison( ~, xs_absolute, error_percentages_theoretical_absolute, error_percentages_numerical_absolute, color_absolute, xs_relative, error_percentages_theoretical_relative, error_percentages_numerical_relative, color_relative, scale, subnetwork_name, encoded_string, input_variable_string, output_variable_string, unit, save_flag, save_directory )
            
            % Set the default input arguments.
            if nargin < 17, save_directory = './'; end
            if nargin < 16, save_flag = true; end
            if nargin < 15, unit = 'mV'; end
            if nargin < 14, output_variable_string = 'dU'; end
            if nargin < 13, input_variable_string = 'U1'; end
            if nargin < 12, encoded_string = 'Encoded'; end
            if nargin < 11, subnetwork_name = 'Transmission'; end
            if nargin < 10, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( 'Absolute vs Relative %s: %s Steady State Error Percentage', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( '%s Error, %s [%%]', encoded_string, output_variable_string );

            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
            
            % Plot the absolute and relative theoretical and numerical errors.
            plot( scale*xs_absolute, error_percentages_theoretical_absolute, '-.', 'Color', color_absolute, 'Linewidth', 3 )
            plot( scale*xs_absolute, error_percentages_numerical_absolute, '--', 'Color', color_absolute, 'Linewidth', 3 )
            plot( scale*xs_relative, error_percentages_theoretical_relative, '-.', 'Color', color_relative, 'Linewidth', 3 )
            plot( scale*xs_relative, error_percentages_numerical_relative, '--', 'Color', color_relative, 'Linewidth', 3 )
            
            % Add a legend to the figure.
            legend( { 'Absolute Theoretical', 'Absolute Numerical', 'Relative Theoretical', 'Relative Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_steady_state_error_percentage.png', lower( subnetwork_name ), lower( encoded_string ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error difference of a subnetwork for a specific gain.
        function fig = plot_steady_state_error_difference( ~, xs_theoretical, error_difference_theoretical, xs_numerical, error_difference_numerical, scale, subnetwork_name, encoded_string, input_variable_string, output_variable_string, unit, save_flag, save_directory )
            
            % Set the default input arguments.
            if nargin < 13, save_directory = './'; end
            if nargin < 12, save_flag = true; end
            if nargin < 11, unit = 'mV'; end
            if nargin < 10, output_variable_string = 'dU'; end
            if nargin < 9, input_variable_string = 'U1'; end
            if nargin < 8, encoded_string = 'Encoded'; end
            if nargin < 7, subnetwork_name = 'Transmission'; end
            if nargin < 6, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( '%s: %s Steady State Error Difference', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( '%s Error Difference, %s [%s]', encoded_string, output_variable_string, unit );

            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
            
            % Plot the absolute and relative theoretical and numerical errors.
            plot( scale*xs_theoretical, scale*error_difference_theoretical, '-.', 'Linewidth', 3 )
            plot( scale*xs_numerical, scale*error_difference_numerical, '--', 'Linewidth', 3 )
            
            % Add a legend to the figure.
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal')
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_steady_state_error_difference.png', lower( subnetwork_name ), lower( encoded_string ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error difference of a subnetwork for a specific gain.
        function fig = plot_steady_state_error_percentage_difference( ~, xs_theoretical, error_percentages_difference_theoretical, xs_numerical, error_percentages_difference_numerical, scale, subnetwork_name, encoded_string, input_variable_string, output_variable_string, unit, save_flag, save_directory )
            
            % Set the default input arguments.
            if nargin < 13, save_directory = './'; end
            if nargin < 12, save_flag = true; end
            if nargin < 11, unit = 'mV'; end
            if nargin < 10, output_variable_string = 'dU'; end
            if nargin < 9, input_variable_string = 'U1'; end
            if nargin < 8, encoded_string = 'Encoded'; end
            if nargin < 7, subnetwork_name = 'Transmission'; end
            if nargin < 6, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( '%s: %s Steady State Error Percentage Difference', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( '%s Error Percentage Difference, %s [%%]', encoded_string, output_variable_string );

            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
            
            % Plot the absolute and relative theoretical and numerical errors.
            plot( scale*xs_theoretical, error_percentages_difference_theoretical, '-.', 'Linewidth', 3 )
            plot( scale*xs_numerical, error_percentages_difference_numerical, '--', 'Linewidth', 3 )
            
            % Add a legend to the figure.
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal')
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_steady_state_error_percentage_difference.png', lower( subnetwork_name ), lower( encoded_string ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error improvement of a subnetwork for a specific gain.
        function fig = plot_steady_state_error_improvement( ~, xs_theoretical, error_improvement_theoretical, xs_numerical, error_improvement_numerical, scale, subnetwork_name, encoded_string, input_variable_string, output_variable_string, unit, save_flag, save_directory )
            
            % Set the default input arguments.
            if nargin < 13, save_directory = './'; end
            if nargin < 12, save_flag = true; end
            if nargin < 11, unit = 'mV'; end
            if nargin < 10, output_variable_string = 'dU'; end
            if nargin < 9, input_variable_string = 'U1'; end
            if nargin < 8, encoded_string = 'Encoded'; end
            if nargin < 7, subnetwork_name = 'Transmission'; end
            if nargin < 6, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( '%s: %s Steady State Error Improvement', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( '%s Error Improvement, %s [%s]', encoded_string, output_variable_string, unit );

            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
            
            % Plot the absolute and relative theoretical and numerical errors.
            plot( scale*xs_theoretical, scale*error_improvement_theoretical, '-.', 'Linewidth', 3 )
            plot( scale*xs_numerical, scale*error_improvement_numerical, '--', 'Linewidth', 3 )
            
            % Add a legend to the figure.
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal')
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_steady_state_error_improvement.png', lower( subnetwork_name ), lower( encoded_string ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error improvement of a subnetwork for a specific gain.
        function fig = plot_steady_state_error_percentage_improvement( ~, xs_theoretical, error_percentages_improvement_theoretical, xs_numerical, error_percentages_improvement_numerical, scale, subnetwork_name, encoded_string, input_variable_string, output_variable_string, unit, save_flag, save_directory )
            
            % Set the default input arguments.
            if nargin < 13, save_directory = './'; end
            if nargin < 12, save_flag = true; end
            if nargin < 11, unit = 'mV'; end
            if nargin < 10, output_variable_string = 'dU'; end
            if nargin < 9, input_variable_string = 'U1'; end
            if nargin < 8, encoded_string = 'Encoded'; end
            if nargin < 7, subnetwork_name = 'Transmission'; end
            if nargin < 6, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( '%s: %s Steady State Error Percentage Improvement', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( '%s Error Percentage Improvement, %s [%%]', encoded_string, output_variable_string );

            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
            
            % Plot the absolute and relative theoretical and numerical errors.
            plot( scale*xs_theoretical, error_percentages_improvement_theoretical, '-.', 'Linewidth', 3 )
            plot( scale*xs_numerical, error_percentages_improvement_numerical, '--', 'Linewidth', 3 )
            
            % Add a legend to the figure.
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal')
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_steady_state_error_percentage_improvement.png', lower( subnetwork_name ), lower( encoded_string ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the maximum rk4 step size for a specific gain.
        function fig = plot_rk4_maximum_timestep( ~, xs_absolute, dts_absolute, color_absolute, xs_relative, dts_relative, color_relative, scale, subnetwork_name, encoded_string, input_variable_string, unit, save_flag, save_directory )
        
            % Set the default input arguments.
            if nargin < 14, save_directory = './'; end
            if nargin < 13, save_flag = true; end
            if nargin < 12, unit = 'mV'; end
            if nargin < 11, input_variable_string = 'U1'; end
            if nargin < 10, encoded_string = 'Encoded'; end
            if nargin < 9, subnetwork_name = 'Transmission'; end
            if nargin < 8, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( '%s: %s RK4 Maximum Timestep', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( 'RK4 Maximum Timestep, dt [s]' );

            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
            
            % Plot the desired, theoretical, and numerical steady state responses.
            plot( scale*xs_absolute, dts_absolute, '-', 'Color', color_absolute, 'Linewidth', 3 )
            plot( scale*xs_relative, dts_relative, '-', 'Color', color_relative, 'Linewidth', 3 )
            
            % Add a legend to the figure.
            legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_rk4_maximum_timestep_%s.png', lower( subnetwork_name ), lower( encoded_string ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the condition number for a specific gain.
        function fig = plot_condition_numbers( ~, xs_absolute, condition_numbers_absolute, color_absolute, xs_relative, condition_numbers_relative, color_relative, scale, subnetwork_name, encoded_string, input_variable_string, unit, save_flag, save_directory )
        
            % Set the default input arguments.
            if nargin < 14, save_directory = './'; end
            if nargin < 13, save_flag = true; end
            if nargin < 12, unit = 'mV'; end
            if nargin < 11, input_variable_string = 'U1'; end
            if nargin < 10, encoded_string = 'Encoded'; end
            if nargin < 9, subnetwork_name = 'Transmission'; end
            if nargin < 8, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( '%s: %s Condition Numbers', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( 'Condition Numbers [-]' );

            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
            
            % Plot the desired, theoretical, and numerical steady state responses.
            plot( scale*xs_absolute, condition_numbers_absolute, '-', 'Color', color_absolute, 'Linewidth', 3 )
            plot( scale*xs_relative, condition_numbers_relative, '-', 'Color', color_relative, 'Linewidth', 3 )
            
            % Add a legend to the figure.
            legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_condition_number_%s.png', lower( subnetwork_name ), lower( encoded_string ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        
    end
    
    
end
    