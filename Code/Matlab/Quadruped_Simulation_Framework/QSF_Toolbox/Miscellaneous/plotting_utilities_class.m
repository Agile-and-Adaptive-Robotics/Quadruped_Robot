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
                
        
        %% Steady State Response Plotting Functions.
        
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
            legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_%s_ssr_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state response of a subnetwork for a specific encoding scheme and gain.
        function fig = surf_steady_state_response( ~, Xs, Ys, Zs_desired, Zs_theoretical, Zs_numerical, scale, viewing_angle, subnetwork_name, encoding_scheme, encoded_string, variables_string, units, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 17, save_tag = ''; end
            if nargin < 16, save_directory = './'; end
            if nargin < 15, save_flag = true; end
            if nargin < 14, title_tag = ''; end
            if nargin < 13, units = { '-', 'mV', 'mV' }; end
            if nargin < 12, variables_string = { 'c1', 'U1', 'U2' }; end
            if nargin < 11, encoded_string = 'Encoded'; end
            if nargin < 10, encoding_scheme = 'Absolute'; end
            if nargin < 9, subnetwork_name = 'Transmission'; end
            if nargin < 8, viewing_angle = [ 145, 15 ]; end
            if nargin < 7, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( '%s %s: %s Steady State Response %s', encoding_scheme, subnetwork_name, encoded_string, title_tag );
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Output, %s [%s]', encoded_string, variables_string{ 3 }, units{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )
            
            % Plot the desired, theoretical, and numerical responses.
            surf( Xs, scale*Ys, scale*Zs_desired, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
            surf( Xs, scale*Ys, scale*Zs_theoretical, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
            surf( Xs, scale*Ys, scale*Zs_numerical, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
            
            % Add a legend to the figure.
            legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
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
        function fig = surf_steady_state_response_patch( self, Xs, Ys, Zs, Zs_lower, Zs_upper, color, scale, viewing_angle, subnetwork_name, encoding_scheme, encoded_string, variables_string, units, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 18, save_tag = ''; end
            if nargin < 17, save_directory = './'; end
            if nargin < 16, save_flag = true; end
            if nargin < 15, title_tag = ''; end
            if nargin < 14, units = { '-', 'mV', 'mV' }; end
            if nargin < 13, variables_string = { 'c1', 'U1', 'U2' }; end
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
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Output, %s [%s]', encoded_string, variables_string{ 3 }, units{ 3 } );
            
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
                legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( subplot_title2 )
                plot( scale*xs_relative, scale*ys_desired_relative, '-', 'Color', [ color_relative, 1/3 ], 'Linewidth', 3 )
                plot( scale*xs_relative, scale*ys_theoretical_relative, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale*xs_relative, scale*ys_numerical_relative, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
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
        function fig = surf_steady_state_response_comparison( ~, Xs_absolute, Ys_absolute, Zs_desired_absolute, Zs_theoretical_absolute, Zs_numerical_absolute, color_absolute, Xs_relative, Ys_relative, Zs_desired_relative, Zs_theoretical_relative, Zs_numerical_relative, color_relative, scale, viewing_angle, subnetwork_name, encoded_string, variables_string, units, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 24, save_tag = ''; end
            if nargin < 23, save_directory = './'; end
            if nargin < 22, save_flag = true; end
            if nargin < 21, compact_flag = true; end
            if nargin < 20, title_tag = ''; end
            if nargin < 19, units = { '-', 'mV', 'mV' }; end
            if nargin < 18, variables_string = { 'c1', 'U1', 'U2' }; end
            if nargin < 17, encoded_string = 'Encoded'; end
            if nargin < 16, subnetwork_name = 'Transmission'; end
            if nargin < 15, viewing_angle = [ 145, 15 ]; end
            if nargin < 14, scale = 1; end
            
            % Create the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: %s Steady State Response %s', subnetwork_name, encoded_string, title_tag );
            
            % Create the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Output, %s [%s]', encoded_string, variables_string{ 3 }, units{ 3 } );
            
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
                legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )

                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title2 )            
                surf( Xs_relative, scale*Ys_relative, scale*Zs_desired_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1/3 )
                surf( Xs_relative, scale*Ys_relative, scale*Zs_theoretical_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative, scale*Ys_relative, scale*Zs_numerical_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )            
                legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )

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
        function fig = surf_steady_state_response_patch_comparison( self, Xs_absolute, Ys_absolute, Zs_absolute, Zs_lower_absolute, Zs_upper_absolute, color_absolute, Xs_relative, Ys_relative, Zs_relative, Zs_lower_relative, Zs_upper_relative, color_relative, scale, viewing_angle, subnetwork_name, encoded_string, variables_string, units, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 24, save_tag = ''; end
            if nargin < 23, save_directory = './'; end
            if nargin < 22, save_flag = true; end
            if nargin < 21, compact_flag = truel; end
            if nargin < 20, title_tag = ''; end
            if nargin < 19, units = { '-', 'mV', 'mV' }; end
            if nargin < 18, variables_string = { 'c1', 'U1', 'U2' }; end
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
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Output, %s [%s]', encoded_string, variables_string{ 3 }, units{ 3 } );
                        
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
        function fig = plot_steady_state_response_full_comparison( ~, xs_absolute_encoded, ys_desired_absolute_encoded, ys_theoretical_absolute_encoded, ys_numerical_absolute_encoded, xs_absolute_decoded, ys_desired_absolute_decoded, ys_theoretical_absolute_decoded, ys_numerical_absolute_decoded, color_absolute, xs_relative_encoded, ys_desired_relative_encoded, ys_theoretical_relative_encoded, ys_numerical_relative_encoded, xs_relative_decoded, ys_desired_relative_decoded, ys_theoretical_relative_decoded, ys_numerical_relative_decoded, color_relative, scale_encoded, scale_decoded, subnetwork_name, input_variable_string_encoded, input_variable_string_decoded, output_variable_string_encoded, output_variable_string_decoded, unit_encoded, unit_decoded, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 33, save_tag = ''; end
            if nargin < 32, save_directory = './'; end
            if nargin < 31, save_flag = true; end
            if nargin < 30, compact_flag = true; end
            if nargin < 29, title_tag = ''; end
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
            title_string = sprintf( 'Absolute vs Relative %s: Encoded vs Decoded Steady State Response %s', subnetwork_name, title_tag );
            xlabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', input_variable_string_encoded, unit_encoded );
            ylabel_string_encoded = sprintf( 'Encoded Output, %s [%s]', output_variable_string_encoded, unit_encoded );
            xlabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', input_variable_string_decoded, unit_decoded );
            ylabel_string_decoded = sprintf( 'Decoded Output, %s [%s]', output_variable_string_decoded, unit_decoded );
            
            % Create a figure to store the data.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to compare the absolute and relative encoding schemes on a single subplot or multiple.
            if compact_flag                   % If we want to make multiple subplots...
                
                % Create the subplot titles.
                subplot_title_encoded = sprintf( 'Absolute %s: Encoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_decoded = sprintf( 'Relative %s: Decoded Steady State Response %s', subnetwork_name, title_tag );

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
                subplot_title_absolute_encoded = sprintf( 'Absolute %s: Encoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_relative_encoded = sprintf( 'Relative %s: Encoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_absolute_decoded = sprintf( 'Absolute %s: Decoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_relative_decoded = sprintf( 'Relative %s: Decoded Steady State Response %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 2, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_absolute_encoded )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*ys_desired_absolute_encoded, '-', 'Color', [ color_absolute, 1/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*ys_theoretical_absolute_encoded, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*ys_numerical_absolute_encoded, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )
                legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
                % Create the second subplot.
                subplot( 2, 2, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_absolute_decoded )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*ys_desired_absolute_decoded, '-', 'Color', [ color_absolute, 1/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*ys_theoretical_absolute_decoded, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*ys_numerical_absolute_decoded, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )
                legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
                % Create the third subplot.
                subplot( 2, 2, 3 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_relative_encoded )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*ys_desired_relative_encoded, '-', 'Color', [ color_relative, 1/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*ys_theoretical_relative_encoded, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*ys_numerical_relative_encoded, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

                % Create the fourth subplot.
                subplot( 2, 2, 4 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_relative_decoded )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*ys_desired_relative_decoded, '-', 'Color', [ color_relative, 1/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*ys_theoretical_relative_decoded, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*ys_numerical_relative_decoded, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

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
        function fig = surf_steady_state_response_full_comparison( ~, Xs_absolute_encoded, Ys_absolute_encoded, Zs_desired_absolute_encoded, Zs_theoretical_absolute_encoded, Zs_numerical_absolute_encoded, Xs_absolute_decoded, Ys_absolute_decoded, Zs_desired_absolute_decoded, Zs_theoretical_absolute_decoded, Zs_numerical_absolute_decoded, color_absolute, Xs_relative_encoded, Ys_relative_encoded, Zs_desired_relative_encoded, Zs_theoretical_relative_encoded, Zs_numerical_relative_encoded, Xs_relative_decoded, Ys_relative_decoded, Zs_desired_relative_decoded, Zs_theoretical_relative_decoded, Zs_numerical_relative_decoded, color_relative, scale_encoded, scale_decoded, viewing_angle, subnetwork_name, variables_string_encoded, variables_string_decoded, units_encoded, units_decoded, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 36, save_tag = ''; end
            if nargin < 35, save_directory = './'; end
            if nargin < 34, save_flag = true; end
            if nargin < 33, compact_flag = true; end
            if nargin < 32, title_tag = ''; end
            if nargin < 31, units_decoded = { '-', '-', '-' }; end
            if nargin < 30, units_encoded = { '-', 'mV', 'mV' }; end
            if nargin < 29, variables_string_decoded = { 'c1', 'x1', 'x2' }; end
            if nargin < 28, variables_string_encoded = { 'c1', 'U1', 'U2' }; end
            if nargin < 27, subnetwork_name = 'Transmission'; end
            if nargin < 26, viewing_angle = [ 145, 15 ]; end
            if nargin < 25, scale_decoded = 1; end
            if nargin < 24, scale_encoded = 1; end
            
            % Define the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: Steady State Response %s', subnetwork_name, title_tag );
            
            % Define the figure labels.
            xlabel_string_encoded = sprintf( 'Parameter, %s [%s]', variables_string_encoded{ 1 }, units_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 2 }, units_encoded{ 2 } );
            zlabel_string_encoded = sprintf( 'Encoded Output, %s [%s]', variables_string_encoded{ 3 }, units_encoded{ 3 } );
            
            xlabel_string_decoded = sprintf( 'Parameter, %s [%s]', variables_string_decoded{ 1 }, units_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variables_string_decoded{ 2 }, units_decoded{ 2 } );
            zlabel_string_decoded = sprintf( 'Decoded Output, %s [%s]', variables_string_decoded{ 3 }, units_decoded{ 3 } );
            
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
                % legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )

                % Create the second subplot.
                subplot( 2, 2, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_absolute_decoded )
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Zs_desired_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1/3 )
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Zs_theoretical_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Zs_numerical_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 )  
                % legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
                % Create the third subplot.
                subplot( 2, 2, 3 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_relative_encoded )
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Zs_desired_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1/3 )
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Zs_theoretical_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Zs_numerical_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )
                % legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
                % Create the fourth subplot.
                subplot( 2, 2, 4 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_relative_decoded )
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Zs_desired_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1/3 )
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Zs_theoretical_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Zs_numerical_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )
                % legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
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
        function fig = plot_steady_state_response_patch_full_comparison( self, xs_encoded, ys_mean_absolute_encoded, ys_min_absolute_encoded, ys_max_absolute_encoded, xs_decoded, ys_mean_absolute_decoded, ys_min_absolute_decoded, ys_max_absolute_decoded, color_absolute, ys_mean_relative_encoded, ys_min_relative_encoded, ys_max_relative_encoded, ys_mean_relative_decoded, ys_min_relative_decoded, ys_max_relative_decoded, color_relative, scale_encoded, scale_decoded, subnetwork_name, input_variable_string_encoded, input_variable_string_decoded, output_variable_string_encoded, output_variable_string_decoded, unit_encoded, unit_decoded, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 31, save_tag = ''; end
            if nargin < 30, save_directory = './'; end
            if nargin < 29, save_flag = true; end
            if nargin < 28, compact_flag = true; end
            if nargin < 27, title_tag = ''; end
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
            title_string = sprintf( 'Absolute vs Relative %s: Encoded vs Decoded Steady State Response %s', subnetwork_name, title_tag );
            xlabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', input_variable_string_encoded, unit_encoded );
            ylabel_string_encoded = sprintf( 'Encoded Output, %s [%s]', output_variable_string_encoded, unit_encoded );
            xlabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', input_variable_string_decoded, unit_decoded );
            ylabel_string_decoded = sprintf( 'Decoded Output, %s [%s]', output_variable_string_decoded, unit_decoded );
            
            % Create a figure to store the data.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to compare the absolute and relative encoding schemes on a single subplot or multiple.
            if compact_flag                   % If we want to make multiple subplots...
                
                % Create the subplot titles.
                subplot_title_encoded = sprintf( 'Absolute %s: Encoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_decoded = sprintf( 'Relative %s: Decoded Steady State Response %s', subnetwork_name, title_tag );

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
                subplot_title_absolute_encoded = sprintf( 'Absolute %s: Encoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_relative_encoded = sprintf( 'Relative %s: Encoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_absolute_decoded = sprintf( 'Absolute %s: Decoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_relative_decoded = sprintf( 'Relative %s: Decoded Steady State Response %s', subnetwork_name, title_tag );

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
        function fig = surf_steady_state_response_patch_full_comparison( self, Xs_absolute_encoded, Ys_absolute_encoded, Zs_absolute_encoded, Zs_lower_absolute_encoded, Zs_upper_absolute_encoded, Xs_absolute_decoded, Ys_absolute_decoded, Zs_absolute_decoded, Zs_lower_absolute_decoded, Zs_upper_absolute_decoded, color_absolute, Xs_relative_encoded, Ys_relative_encoded, Zs_relative_encoded, Zs_lower_relative_encoded, Zs_upper_relative_encoded, Xs_relative_decoded, Ys_relative_decoded, Zs_relative_decoded, Zs_lower_relative_decoded, Zs_upper_relative_decoded, color_relative, scale_encoded, scale_decoded, viewing_angle, subnetwork_name, variables_string_encoded, variables_string_decoded, units_encoded, units_decoded, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 36, save_tag = ''; end
            if nargin < 35, save_directory = './'; end
            if nargin < 34, save_flag = true; end
            if nargin < 33, compact_flag = true; end
            if nargin < 32, title_tag = '.'; end
            if nargin < 31, units_decoded = '-'; end
            if nargin < 30, units_encoded = 'mV'; end
            if nargin < 29, variables_string_decoded = 'x1'; end
            if nargin < 28, variables_string_encoded = 'U1'; end
            if nargin < 27, subnetwork_name = 'Transmission'; end
            if nargin < 26, viewing_angle = [ 145, 15 ]; end
            if nargin < 25, scale_decoded = 1; end
            if nargin < 24, scale_encoded = 1; end
            
            % Generate the patch data.
            [ ps_patch_xlower_absolute_encoded, ps_patch_xupper_absolute_encoded, ps_patch_ylower_absolute_encoded, ps_patch_yupper_absolute_encoded, ps_patch_zlower_absolute_encoded, ps_patch_zupper_absolute_encoded ] = self.generate_3D_patch_data( Xs_absolute_encoded, Ys_absolute_encoded, Zs_lower_absolute_encoded, Zs_upper_absolute_encoded );
            [ ps_patch_xlower_absolute_decoded, ps_patch_xupper_absolute_decoded, ps_patch_ylower_absolute_decoded, ps_patch_yupper_absolute_decoded, ps_patch_zlower_absolute_decoded, ps_patch_zupper_absolute_decoded ] = self.generate_3D_patch_data( Xs_absolute_decoded, Ys_absolute_decoded, Zs_lower_absolute_decoded, Zs_upper_absolute_decoded );
            [ ps_patch_xlower_relative_encoded, ps_patch_xupper_relative_encoded, ps_patch_ylower_relative_encoded, ps_patch_yupper_relative_encoded, ps_patch_zlower_relative_encoded, ps_patch_zupper_relative_encoded ] = self.generate_3D_patch_data( Xs_relative_encoded, Ys_relative_encoded, Zs_lower_relative_encoded, Zs_upper_relative_encoded );
            [ ps_patch_xlower_relative_decoded, ps_patch_xupper_relative_decoded, ps_patch_ylower_relative_decoded, ps_patch_yupper_relative_decoded, ps_patch_zlower_relative_decoded, ps_patch_zupper_relative_decoded ] = self.generate_3D_patch_data( Xs_relative_decoded, Ys_relative_decoded, Zs_lower_relative_decoded, Zs_upper_relative_decoded );
            
            % Create the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: Encoded vs Decoded Steady State Response %s', subnetwork_name, title_tag );

            % Compute the figure labels.
            xlabel_string_encoded = sprintf( 'Parameter, %s [%s]', variables_string_encoded{ 1 }, units_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 2 }, units_encoded{ 2 } );
            zlabel_string_encoded = sprintf( 'Encoded Output, %s [%s]', variables_string_encoded{ 3 }, units_encoded{ 3 } );
            xlabel_string_decoded = sprintf( 'Parameter, %s [%s]', variables_string_decoded{ 1 }, units_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variables_string_decoded{ 2 }, units_decoded{ 2 } );
            zlabel_string_decoded = sprintf( 'Decoded Output, %s [%s]', variables_string_decoded{ 3 }, units_decoded{ 3 } );
            
            % Create a figure to store the data.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to compare the absolute and relative encoding schemes on a single subplot or multiple.
            if compact_flag                   % If we want to make multiple subplots...
                
                % Create the subplot titles.
                subplot_title_encoded = sprintf( 'Absolute %s: Encoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_decoded = sprintf( 'Relative %s: Decoded Steady State Response %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_encoded )
                gobj_surf_absolute_encoded = surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Zs_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );
                gobj_patch_aboslute_encoded = patch( ps_patch_xlower_absolute_encoded( :, 1 ), scale_encoded*ps_patch_xlower_absolute_encoded( :, 2 ), scale_encoded*ps_patch_xlower_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_absolute_encoded( :, 1 ), scale_encoded*ps_patch_xupper_absolute_encoded( :, 2 ), scale_encoded*ps_patch_xupper_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute_encoded( :, 1 ), scale_encoded*ps_patch_ylower_absolute_encoded( :, 2 ), scale_encoded*ps_patch_ylower_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute_encoded( :, 1 ), scale_encoded*ps_patch_yupper_absolute_encoded( :, 2 ), scale_encoded*ps_patch_yupper_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute_encoded( :, 1 ), scale_encoded*ps_patch_zlower_absolute_encoded( :, 2 ), scale_encoded*ps_patch_zlower_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute_encoded( :, 1 ), scale_encoded*ps_patch_zupper_absolute_encoded( :, 2 ), scale_encoded*ps_patch_zupper_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                gobj_surf_relative_encoded = surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Zs_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                gobj_patch_relative_encoded = patch( ps_patch_xlower_relative_encoded( :, 1 ), scale_encoded*ps_patch_xlower_relative_encoded( :, 2 ), scale_encoded*ps_patch_xlower_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_relative_encoded( :, 1 ), scale_encoded*ps_patch_xupper_relative_encoded( :, 2 ), scale_encoded*ps_patch_xupper_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative_encoded( :, 1 ), scale_encoded*ps_patch_ylower_relative_encoded( :, 2 ), scale_encoded*ps_patch_ylower_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative_encoded( :, 1 ), scale_encoded*ps_patch_yupper_relative_encoded( :, 2 ), scale_encoded*ps_patch_yupper_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative_encoded( :, 1 ), scale_encoded*ps_patch_zlower_relative_encoded( :, 2 ), scale_encoded*ps_patch_zlower_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative_encoded( :, 1 ), scale_encoded*ps_patch_zupper_relative_encoded( :, 2 ), scale_encoded*ps_patch_zupper_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                legend( [ gobj_surf_absolute_encoded, gobj_patch_aboslute_encoded, gobj_surf_relative_encoded, gobj_patch_relative_encoded ], { 'Absolute Average', 'Absolute Range', 'Relative Average', 'Relative Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )

                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_decoded )            
                gobj_surf_absolute_decoded = surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Zs_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );
                gobj_patch_aboslute_decoded = patch( ps_patch_xlower_absolute_decoded( :, 1 ), scale_decoded*ps_patch_xlower_absolute_decoded( :, 2 ), scale_decoded*ps_patch_xlower_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_absolute_decoded( :, 1 ), scale_decoded*ps_patch_xupper_absolute_decoded( :, 2 ), scale_decoded*ps_patch_xupper_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute_decoded( :, 1 ), scale_decoded*ps_patch_ylower_absolute_decoded( :, 2 ), scale_decoded*ps_patch_ylower_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute_decoded( :, 1 ), scale_decoded*ps_patch_yupper_absolute_decoded( :, 2 ), scale_decoded*ps_patch_yupper_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute_decoded( :, 1 ), scale_decoded*ps_patch_zlower_absolute_decoded( :, 2 ), scale_decoded*ps_patch_zlower_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute_decoded( :, 1 ), scale_decoded*ps_patch_zupper_absolute_decoded( :, 2 ), scale_decoded*ps_patch_zupper_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                gobj_surf_relative_decoded = surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Zs_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                gobj_patch_relative_decoded = patch( ps_patch_xlower_relative_decoded( :, 1 ), scale_decoded*ps_patch_xlower_relative_decoded( :, 2 ), scale_decoded*ps_patch_xlower_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_relative_decoded( :, 1 ), scale_decoded*ps_patch_xupper_relative_decoded( :, 2 ), scale_decoded*ps_patch_xupper_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative_decoded( :, 1 ), scale_decoded*ps_patch_ylower_relative_decoded( :, 2 ), scale_decoded*ps_patch_ylower_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative_decoded( :, 1 ), scale_decoded*ps_patch_yupper_relative_decoded( :, 2 ), scale_decoded*ps_patch_yupper_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative_decoded( :, 1 ), scale_decoded*ps_patch_zlower_relative_decoded( :, 2 ), scale_decoded*ps_patch_zlower_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative_decoded( :, 1 ), scale_decoded*ps_patch_zupper_relative_decoded( :, 2 ), scale_decoded*ps_patch_zupper_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                legend( [ gobj_surf_absolute_decoded, gobj_patch_aboslute_decoded, gobj_surf_relative_decoded, gobj_patch_relative_decoded ], { 'Absolute Average', 'Absolute Range', 'Relative Average', 'Relative Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
            else                                % Otherwise...
                
                % Create the subplot titles.
                subplot_title_absolute_encoded = sprintf( 'Absolute %s: Encoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_relative_encoded = sprintf( 'Relative %s: Encoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_absolute_decoded = sprintf( 'Absolute %s: Decoded Steady State Response %s', subnetwork_name, title_tag );
                subplot_title_relative_decoded = sprintf( 'Relative %s: Decoded Steady State Response %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 2, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_absolute_encoded )            
                gobj_surf_absolute_encoded = surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Zs_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );
                gobj_patch_aboslute_encoded = patch( ps_patch_xlower_absolute_encoded( :, 1 ), scale_encoded*ps_patch_xlower_absolute_encoded( :, 2 ), scale_encoded*ps_patch_xlower_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_absolute_encoded( :, 1 ), scale_encoded*ps_patch_xupper_absolute_encoded( :, 2 ), scale_encoded*ps_patch_xupper_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute_encoded( :, 1 ), scale_encoded*ps_patch_ylower_absolute_encoded( :, 2 ), scale_encoded*ps_patch_ylower_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute_encoded( :, 1 ), scale_encoded*ps_patch_yupper_absolute_encoded( :, 2 ), scale_encoded*ps_patch_yupper_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute_encoded( :, 1 ), scale_encoded*ps_patch_zlower_absolute_encoded( :, 2 ), scale_encoded*ps_patch_zlower_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute_encoded( :, 1 ), scale_encoded*ps_patch_zupper_absolute_encoded( :, 2 ), scale_encoded*ps_patch_zupper_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                legend( [ gobj_surf_absolute_encoded, gobj_patch_aboslute_encoded ], { 'Average', 'Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
                % Create the second subplot.
                subplot( 2, 2, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_absolute_decoded )            
                gobj_surf_absolute_decoded = surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Zs_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );
                gobj_patch_aboslute_decoded = patch( ps_patch_xlower_absolute_decoded( :, 1 ), scale_decoded*ps_patch_xlower_absolute_decoded( :, 2 ), scale_decoded*ps_patch_xlower_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_absolute_decoded( :, 1 ), scale_decoded*ps_patch_xupper_absolute_decoded( :, 2 ), scale_decoded*ps_patch_xupper_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute_decoded( :, 1 ), scale_decoded*ps_patch_ylower_absolute_decoded( :, 2 ), scale_decoded*ps_patch_ylower_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute_decoded( :, 1 ), scale_decoded*ps_patch_yupper_absolute_decoded( :, 2 ), scale_decoded*ps_patch_yupper_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute_decoded( :, 1 ), scale_decoded*ps_patch_zlower_absolute_decoded( :, 2 ), scale_decoded*ps_patch_zlower_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute_decoded( :, 1 ), scale_decoded*ps_patch_zupper_absolute_decoded( :, 2 ), scale_decoded*ps_patch_zupper_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                legend( [ gobj_surf_absolute_decoded, gobj_patch_aboslute_decoded ], { 'Average', 'Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
                % Create the third subplot.
                subplot( 2, 2, 3 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_relative_encoded )            
                gobj_surf_relative_encoded = surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Zs_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                gobj_patch_relative_encoded = patch( ps_patch_xlower_relative_encoded( :, 1 ), scale_encoded*ps_patch_xlower_relative_encoded( :, 2 ), scale_encoded*ps_patch_xlower_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_relative_encoded( :, 1 ), scale_encoded*ps_patch_xupper_relative_encoded( :, 2 ), scale_encoded*ps_patch_xupper_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative_encoded( :, 1 ), scale_encoded*ps_patch_ylower_relative_encoded( :, 2 ), scale_encoded*ps_patch_ylower_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative_encoded( :, 1 ), scale_encoded*ps_patch_yupper_relative_encoded( :, 2 ), scale_encoded*ps_patch_yupper_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative_encoded( :, 1 ), scale_encoded*ps_patch_zlower_relative_encoded( :, 2 ), scale_encoded*ps_patch_zlower_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative_encoded( :, 1 ), scale_encoded*ps_patch_zupper_relative_encoded( :, 2 ), scale_encoded*ps_patch_zupper_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                legend( [ gobj_surf_relative_encoded, gobj_patch_relative_encoded ], { 'Average', 'Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
                % Create the fourth subplot.
                subplot( 2, 2, 4 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_relative_decoded )            
                gobj_surf_relative_decoded = surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Zs_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                gobj_patch_relative_decoded = patch( ps_patch_xlower_relative_decoded( :, 1 ), scale_decoded*ps_patch_xlower_relative_decoded( :, 2 ), scale_decoded*ps_patch_xlower_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_relative_decoded( :, 1 ), scale_decoded*ps_patch_xupper_relative_decoded( :, 2 ), scale_decoded*ps_patch_xupper_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative_decoded( :, 1 ), scale_decoded*ps_patch_ylower_relative_decoded( :, 2 ), scale_decoded*ps_patch_ylower_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative_decoded( :, 1 ), scale_decoded*ps_patch_yupper_relative_decoded( :, 2 ), scale_decoded*ps_patch_yupper_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative_decoded( :, 1 ), scale_decoded*ps_patch_zlower_relative_decoded( :, 2 ), scale_decoded*ps_patch_zlower_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative_decoded( :, 1 ), scale_decoded*ps_patch_zupper_relative_decoded( :, 2 ), scale_decoded*ps_patch_zupper_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                legend( [ gobj_surf_relative_decoded, gobj_patch_relative_decoded ], { 'Average', 'Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
            end
                
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_ssr_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        
        %% Steady State Error Plotting Functions.
        
        % Implement a function to plot the steady state error of a subnetwork for a specific encoding scheme and gain.
        function fig = plot_steady_state_error( ~, xs, es_theoretical, es_numerical, scale, subnetwork_name, encoding_scheme, encoded_string, variables_string, units_string, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 13, save_tag = ''; end
            if nargin < 12, save_directory = './'; end
            if nargin < 11, save_flag = true; end
            if nargin < 10, units_string = { 'mV', 'mV' }; end
            if nargin < 9, variables_string = { 'U1', 'E' }; end
            if nargin < 8, encoded_string = 'Encoded'; end
            if nargin < 7, encoding_scheme = 'Absolute'; end
            if nargin < 6, subnetwork_name = 'Transmission'; end
            if nargin < 5, scale = 1; end
            
            % Compute the figuret title.
            title_string = sprintf( '%s %s: %s Steady State Error', encoding_scheme, subnetwork_name, encoded_string );
            
            % Compute the figure labels.
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( '%s Error, %s [%s]', encoded_string, variables_string{ 2 }, units_string{ 2 } );

            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
            
            % Plot the theoretical and numerical steady state errors.
            plot( scale*xs, scale*es_theoretical, '-.', 'Linewidth', 3 )
            plot( scale*xs, scale*es_numerical, '--', 'Linewidth', 3 )
            
            % Add a legend to the figure.
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_%s_sse_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        

        % Implement a function to create a surface plot of the steady state response of a subnetwork for a specific encoding scheme and gain.
        function fig = surf_steady_state_error( ~, Xs, Ys, Es_theoretical, Es_numerical, scale, viewing_angle, subnetwork_name, encoding_scheme, encoded_string, variables_string, units, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 16, save_tag = ''; end
            if nargin < 15, save_directory = './'; end
            if nargin < 14, save_flag = true; end
            if nargin < 13, title_tag = ''; end
            if nargin < 12, units = { '-', 'mV', 'mV' }; end
            if nargin < 11, variables_string = { 'c1', 'U1', 'E' }; end
            if nargin < 10, encoded_string = 'Encoded'; end
            if nargin < 9, encoding_scheme = 'Absolute'; end
            if nargin < 8, subnetwork_name = 'Transmission'; end
            if nargin < 7, viewing_angle = [ 145, 15 ]; end
            if nargin < 6, scale = 1; end
            
            % Generate the figure title.
            title_string = sprintf( '%s %s: %s Steady State Error %s', encoding_scheme, subnetwork_name, encoded_string, title_tag );
            
            % Compute the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Error, %s [%s]', encoded_string, variables_string{ 3 }, units{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )
            
            % Plot the theoretical and numerical errors.
            surf( Xs, scale*Ys, scale*Es_theoretical, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
            surf( Xs, scale*Ys, scale*Es_numerical, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
            
            % Add a legend to the figure.
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_%s_sse_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = plot_steady_state_error_patch( self, xs, es_mean, es_min, es_max, color, scale, subnetwork_name, encoding_scheme, encoded_string, variables_string, units_string, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 15, save_tag = ''; end
            if nargin < 14, save_directory = './'; end
            if nargin < 13, save_flag = true; end
            if nargin < 12, units_string = { 'mV', 'mV' }; end
            if nargin < 11, variables_string = { 'U1', 'E' }; end
            if nargin < 10, encoded_string = 'Encoded'; end
            if nargin < 9, encoding_scheme = 'Absolute'; end
            if nargin < 8, subnetwork_name = 'Transmission'; end
            if nargin < 7, scale = 1; end
            
            % Generate the patch data.
            [ xs_patch, ys_patch ] = self.generate_2D_patch_data( xs, es_min, es_max );
            
            % Compute the figure labels.
            title_string = sprintf( '%s %s: %s Steady State Error Summary', encoding_scheme, subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( '%s Error, %s [%s]', encoded_string, variables_string{ 2 }, units_string{ 2 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )            
            
            % Plot a summary of the absolute encoded steady state behavior over the formulation parameters.
            patch( scale*xs_patch, scale*ys_patch, color, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
            plot( scale*xs, scale*es_mean, '-', 'Color', color, 'Linewidth', 3 )
            plot( scale*xs, scale*es_min, '--', 'Color', color, 'Linewidth', 1 )
            plot( scale*xs, scale*es_max, '--', 'Color', color, 'Linewidth', 1 )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_%s_sse_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state error of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = surf_steady_state_error_patch( self, Xs, Ys, Zs, Zs_lower, Zs_upper, color, scale, viewing_angle, subnetwork_name, encoding_scheme, encoded_string, variables_string, units, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 18, save_tag = ''; end
            if nargin < 17, save_directory = './'; end
            if nargin < 16, save_flag = true; end
            if nargin < 15, title_tag = ''; end
            if nargin < 14, units = { '-', 'mV', 'mV' }; end
            if nargin < 13, variables_string = { 'c1', 'U1', 'E' }; end
            if nargin < 12, encoded_string = 'Encoded'; end
            if nargin < 11, encoding_scheme = 'Absolute'; end
            if nargin < 10, subnetwork_name = 'Transmission'; end
            if nargin < 9, viewing_angle = [ 145, 15 ]; end
            if nargin < 8, scale = 1; end
            if nargin < 7, color = [ 0.0000, 0.4470, 0.7410 ]; end
            
            % Generate the patch data.
            [ ps_patch_xlower, ps_patch_xupper, ps_patch_ylower, ps_patch_yupper, ps_patch_zlower, ps_patch_zupper ] = self.generate_3D_patch_data( Xs, Ys, Zs_lower, Zs_upper );
            
            % Create the figure title.
            title_string = sprintf( '%s %s: %s Steady State Error %s', encoding_scheme, subnetwork_name, encoded_string, title_tag );
            
            % Compute the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Error, %s [%s]', encoded_string, variables_string{ 3 }, units{ 3 } );
            
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
                file_name = sprintf( '%s_%s_%s_sse_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error of a subnetwork for a specific gain.
        function fig = plot_steady_state_error_comparison( ~, xs_absolute, es_theoretical_absolute, es_numerical_absolute, color_absolute, xs_relative, es_theoretical_relative, es_numerical_relative, color_relative, scale, subnetwork_name, encoded_string, variables_string, units_string, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 18, save_tag = ''; end
            if nargin < 17, save_directory = './'; end
            if nargin < 16, save_flag = true; end
            if nargin < 15, compact_flag = true; end
            if nargin < 14, units_string = { 'mV', 'mV' }; end
            if nargin < 13, variables_string = { 'U1', 'E' }; end
            if nargin < 12, encoded_string = 'Encoded'; end
            if nargin < 11, subnetwork_name = 'Transmission'; end
            if nargin < 10, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( 'Absolute vs Relative %s: %s Steady State Error', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( '%s Error, %s [%s]', encoded_string, variables_string{ 2 }, units_string{ 2 } );

            % Create a figure to store the data.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to compare the absolute and relative encoding schemes on a single subplot or multiple.
            if compact_flag                   % If we want to make multiple subplots...
                
                % Format the figure.
                hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )

                % Plot the absolute theoretical and numerical steady state errors.
                plot( scale*xs_absolute, scale*es_theoretical_absolute, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale*xs_absolute, scale*es_numerical_absolute, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )

                % Plot the relative theoretical and numerical steady state errors.
                plot( scale*xs_relative, scale*es_theoretical_relative, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale*xs_relative, scale*es_numerical_relative, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )

                % Add a legend to the figure.
                legend( { 'Absolute Theoretical', 'Absolute Numerical', 'Relative Theoretical', 'Relative Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            else                                % Otherwise...
                
                % Create the subplot titles.
                subplot_title1 = sprintf( 'Absolute %s: %s Steady State Error', subnetwork_name, encoded_string );
                subplot_title2 = sprintf( 'Relative %s: %s Steady State Error', subnetwork_name, encoded_string );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( subplot_title1 )
                plot( scale*xs_absolute, scale*es_theoretical_absolute, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale*xs_absolute, scale*es_numerical_absolute, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )
                legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( subplot_title2 )
                plot( scale*xs_relative, scale*es_theoretical_relative, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale*xs_relative, scale*es_numerical_relative, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            end
                
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_sse_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state error of a subnetwork for a specific gain.
        function fig = surf_steady_state_error_comparison( ~, Xs_absolute, Ys_absolute, Es_theoretical_absolute, Es_numerical_absolute, color_absolute, Xs_relative, Ys_relative, Es_theoretical_relative, Es_numerical_relative, color_relative, scale, viewing_angle, subnetwork_name, encoded_string, variables_string, units, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 22, save_tag = ''; end
            if nargin < 21, save_directory = './'; end
            if nargin < 20, save_flag = true; end
            if nargin < 19, compact_flag = true; end
            if nargin < 18, title_tag = ''; end
            if nargin < 17, units = { '-', 'mV', 'mV' }; end
            if nargin < 16, variables_string = { 'c1', 'U1', 'E' }; end
            if nargin < 15, encoded_string = 'Encoded'; end
            if nargin < 14, subnetwork_name = 'Transmission'; end
            if nargin < 13, viewing_angle = [ 145, 15 ]; end
            if nargin < 12, scale = 1; end
            
            % Create the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: %s Steady State Error %s', subnetwork_name, encoded_string, title_tag );
            
            % Create the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Error, %s [%s]', encoded_string, variables_string{ 3 }, units{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to create a compact plot.
            if compact_flag                 % If we want to create a compact plot...
                
                % Format the figure.
                hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )            

                % Plot the absolute theoretical and numerical steady state errors.
                surf( Xs_absolute, scale*Ys_absolute, scale*Es_theoretical_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute, scale*Ys_absolute, scale*Es_numerical_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 ) 

                % Plot the relative theoretical and numerical steady state errors.
                surf( Xs_relative, scale*Ys_relative, scale*Es_theoretical_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative, scale*Ys_relative, scale*Es_numerical_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 ) 

                % Add a legend to the figure.
                legend( { 'Absolute Theoretical', 'Absolute Numerical', 'Relative Theoretical', 'Relative Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            else                            % Otherwise...
            
                % Create the subplot titles.
                subplot_title1 = sprintf( 'Absolute %s: %s Steady State Error %s', subnetwork_name, encoded_string, title_tag );
                subplot_title2 = sprintf( 'Relative %s: %s Steady State Error %s', subnetwork_name, encoded_string, title_tag );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title1 )            
                surf( Xs_absolute, scale*Ys_absolute, scale*Es_theoretical_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute, scale*Ys_absolute, scale*Es_numerical_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 )            
                legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )

                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title2 )            
                surf( Xs_relative, scale*Ys_relative, scale*Es_theoretical_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative, scale*Ys_relative, scale*Es_numerical_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )            
                legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )

            end
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_sse_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = plot_steady_state_error_patch_comparison( self, xs, es_mean_absolute, es_min_absolute, es_max_absolute, color_absolute, es_mean_relative, es_min_relative, es_max_relative, color_relative, scale, subnetwork_name, encoded_string, variables_string, units_string, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 19, save_tag = ''; end
            if nargin < 18, save_directory = './'; end
            if nargin < 17, save_flag = true; end
            if nargin < 16, compact_flag = truel; end
            if nargin < 15, units_string = { 'mV', 'mV' }; end
            if nargin < 14, variables_string = { 'U1', 'E' }; end
            if nargin < 13, encoded_string = 'Encoded'; end
            if nargin < 12, subnetwork_name = 'Transmission'; end
            if nargin < 11, scale = 1; end
            
            % Generate the patch data.
            [ xs_patch, ys_patch_absolute ] = self.generate_2D_patch_data( xs, es_min_absolute, es_max_absolute );
            [ ~, ys_patch_relative ] = self.generate_2D_patch_data( xs, es_min_relative, es_max_relative );
            
            % Compute the figure labels.
            title_string = sprintf( 'Absolute vs Relative %s: %s Steady State Error Summary', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( '%s Error, %s [%s]', encoded_string, variables_string{ 2 }, units_string{ 2 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine how to create the subplots.
            if compact_flag                 % If we want to plot in a compact manner...
            
                % Format the figure.
                hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )            

                % Plot a summary of the absolute steady state behavior.
                patch( scale*xs_patch, scale*ys_patch_absolute, color_absolute, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale*xs, scale*es_mean_absolute, '-', 'Color', color_absolute, 'Linewidth', 3 )
                plot( scale*xs, scale*es_min_absolute, '--', 'Color', color_absolute, 'Linewidth', 1 )
                plot( scale*xs, scale*es_max_absolute, '--', 'Color', color_absolute, 'Linewidth', 1 )

                % Plot a summary of the relative steady state behavior.
                patch( scale*xs_patch, scale*ys_patch_relative, color_relative, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale*xs, scale*es_mean_relative, '-', 'Color', color_relative, 'Linewidth', 3 )
                plot( scale*xs, scale*es_min_relative, '--', 'Color', color_relative, 'Linewidth', 1 )
                plot( scale*xs, scale*es_max_relative, '--', 'Color', color_relative, 'Linewidth', 1 )
                            
            else                            % Otherwise...
                
                % Create the subplot titles.
                subplot_title1 = sprintf( 'Absolute %s: %s Steady State Error', subnetwork_name, encoded_string );
                subplot_title2 = sprintf( 'Relative %s: %s Steady State Error', subnetwork_name, encoded_string );
                
                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( subplot_title1 )
                patch( scale*xs_patch, scale*ys_patch_absolute, color_absolute, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale*xs, scale*es_mean_absolute, '-', 'Color', color_absolute, 'Linewidth', 3 )
                plot( scale*xs, scale*es_min_absolute, '--', 'Color', color_absolute, 'Linewidth', 1 )
                plot( scale*xs, scale*es_max_absolute, '--', 'Color', color_absolute, 'Linewidth', 1 )
                
                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( subplot_title2 )
                patch( scale*xs_patch, scale*ys_patch_relative, color_relative, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
                plot( scale*xs, scale*es_mean_relative, '-', 'Color', color_relative, 'Linewidth', 3 )
                plot( scale*xs, scale*es_min_relative, '--', 'Color', color_relative, 'Linewidth', 1 )
                plot( scale*xs, scale*es_max_relative, '--', 'Color', color_relative, 'Linewidth', 1 )
                
            end
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_sse_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state error of a subnetwork for a specific gain, including upper and lower boundaries.
        function fig = surf_steady_state_error_patch_comparison( self, Xs_absolute, Ys_absolute, Es_absolute, Es_lower_absolute, Es_upper_absolute, color_absolute, Xs_relative, Ys_relative, Es_relative, Es_lower_relative, Es_upper_relative, color_relative, scale, viewing_angle, subnetwork_name, encoded_string, variables_string, units, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 24, save_tag = ''; end
            if nargin < 23, save_directory = './'; end
            if nargin < 22, save_flag = true; end
            if nargin < 21, compact_flag = truel; end
            if nargin < 20, title_tag = ''; end
            if nargin < 19, units = { '-', 'mV', 'mV' }; end
            if nargin < 18, variables_string = { 'c1', 'U1', 'E' }; end
            if nargin < 17, encoded_string = 'Encoded'; end
            if nargin < 16, subnetwork_name = 'Transmission'; end
            if nargin < 15, viewing_angle = [ 145, 15 ]; end
            if nargin < 14, scale = 1; end
                        
            % Generate the patch data.
            [ ps_patch_xlower_absolute, ps_patch_xupper_absolute, ps_patch_ylower_absolute, ps_patch_yupper_absolute, ps_patch_zlower_absolute, ps_patch_zupper_absolute ] = self.generate_3D_patch_data( Xs_absolute, Ys_absolute, Es_lower_absolute, Es_upper_absolute );
            [ ps_patch_xlower_relative, ps_patch_xupper_relative, ps_patch_ylower_relative, ps_patch_yupper_relative, ps_patch_zlower_relative, ps_patch_zupper_relative ] = self.generate_3D_patch_data( Xs_relative, Ys_relative, Es_lower_relative, Es_upper_relative );

            % Create the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: %s Steady State Error %s', subnetwork_name, encoded_string, title_tag );
            
            % Create the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Error, %s [%s]', encoded_string, variables_string{ 3 }, units{ 3 } );
                        
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to create a compact plot.
            if compact_flag                 % If we want to create a compact plot...
                
                % Format the figure.
                hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )            

                % Plot the absolute steady state error data.
                surf( Xs_absolute, scale*Ys_absolute, scale*Es_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_absolute( :, 1 ), scale*ps_patch_xlower_absolute( :, 2 ), scale*ps_patch_xlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_absolute( :, 1 ), scale*ps_patch_xupper_absolute( :, 2 ), scale*ps_patch_xupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute( :, 1 ), scale*ps_patch_ylower_absolute( :, 2 ), scale*ps_patch_ylower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute( :, 1 ), scale*ps_patch_yupper_absolute( :, 2 ), scale*ps_patch_yupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute( :, 1 ), scale*ps_patch_zlower_absolute( :, 2 ), scale*ps_patch_zlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute( :, 1 ), scale*ps_patch_zupper_absolute( :, 2 ), scale*ps_patch_zupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                % Plot the relative steady state error data.
                surf( Xs_relative, scale*Ys_relative, scale*Es_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_relative( :, 1 ), scale*ps_patch_xlower_relative( :, 2 ), scale*ps_patch_xlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_relative( :, 1 ), scale*ps_patch_xupper_relative( :, 2 ), scale*ps_patch_xupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative( :, 1 ), scale*ps_patch_ylower_relative( :, 2 ), scale*ps_patch_ylower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative( :, 1 ), scale*ps_patch_yupper_relative( :, 2 ), scale*ps_patch_yupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative( :, 1 ), scale*ps_patch_zlower_relative( :, 2 ), scale*ps_patch_zlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative( :, 1 ), scale*ps_patch_zupper_relative( :, 2 ), scale*ps_patch_zupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
            else                            % Otherwise...
            
                % Create the subplot titles.
                subplot_title_absolute = sprintf( 'Absolute %s: %s Steady State Error %s', subnetwork_name, encoded_string, title_tag );
                subplot_title_relative = sprintf( 'Relative %s: %s Steady State Error %s', subnetwork_name, encoded_string, title_tag );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title_absolute )            
                surf( Xs_absolute, scale*Ys_absolute, scale*Es_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_absolute( :, 1 ), scale*ps_patch_xlower_absolute( :, 2 ), scale*ps_patch_xlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_absolute( :, 1 ), scale*ps_patch_xupper_absolute( :, 2 ), scale*ps_patch_xupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute( :, 1 ), scale*ps_patch_ylower_absolute( :, 2 ), scale*ps_patch_ylower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute( :, 1 ), scale*ps_patch_yupper_absolute( :, 2 ), scale*ps_patch_yupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute( :, 1 ), scale*ps_patch_zlower_absolute( :, 2 ), scale*ps_patch_zlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute( :, 1 ), scale*ps_patch_zupper_absolute( :, 2 ), scale*ps_patch_zupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title_relative )            
                surf( Xs_relative, scale*Ys_relative, scale*Es_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 )            
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
                file_name = sprintf( '%s_%s_sse_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error for a subnetwork that compares absolute & relative schemes before and after encoding/decoding.
        function fig = plot_steady_state_error_full_comparison( ~, xs_absolute_encoded, es_theoretical_absolute_encoded, es_numerical_absolute_encoded, xs_absolute_decoded, es_theoretical_absolute_decoded, es_numerical_absolute_decoded, color_absolute, xs_relative_encoded, es_theoretical_relative_encoded, es_numerical_relative_encoded, xs_relative_decoded, es_theoretical_relative_decoded, es_numerical_relative_decoded, color_relative, scale_encoded, scale_decoded, subnetwork_name, variables_string_encoded, variables_string_decoded, units_encoded, units_decoded, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 27, save_tag = ''; end
            if nargin < 26, save_directory = './'; end
            if nargin < 25, save_flag = true; end
            if nargin < 24, compact_flag = true; end
            if nargin < 23, title_tag = ''; end
            if nargin < 22, units_decoded = { '-', '-' }; end
            if nargin < 21, units_encoded = { 'mV', 'mV' }; end
            if nargin < 20, variables_string_decoded = { 'x1', 'E' }; end
            if nargin < 19, variables_string_encoded = { 'U1', 'E' }; end
            if nargin < 18, subnetwork_name = 'Transmission'; end
            if nargin < 17, scale_decoded = 1; end
            if nargin < 16, scale_encoded = 1; end
            
            % Generate the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: Encoded vs Decoded Steady State Error %s', subnetwork_name, title_tag );
            
            % Generate the figure labels.
            xlabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 1 }, units_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Error, %s [%s]', variables_string_encoded{ 2 }, units_encoded{ 2 } );
            xlabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variables_string_decoded{ 1 }, units_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Error, %s [%s]', variables_string_decoded{ 2 }, units_decoded{ 2 } );
            
            % Create a figure to store the data.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to compare the absolute and relative encoding schemes on a single subplot or multiple.
            if compact_flag                   % If we want to make multiple subplots...
                
                % Create the subplot titles.
                subplot_title_encoded = sprintf( 'Absolute %s: Encoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_decoded = sprintf( 'Relative %s: Decoded Steady State Error %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_encoded )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*es_theoretical_absolute_encoded, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*es_numerical_absolute_encoded, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*es_theoretical_relative_encoded, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*es_numerical_relative_encoded, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Absolute Theoretical', 'Absolute Numerical', 'Relative Theoretical', 'Relative Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )

                % Create the second subplot.
                subplot( 1, 2, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_decoded )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*es_theoretical_absolute_decoded, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*es_numerical_absolute_decoded, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*es_theoretical_relative_decoded, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*es_numerical_relative_decoded, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Absolute Theoretical', 'Absolute Numerical', 'Relative Theoretical', 'Relative Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
            else                                % Otherwise...
                
                % Create the subplot titles.
                subplot_title_absolute_encoded = sprintf( 'Absolute %s: Encoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_relative_encoded = sprintf( 'Relative %s: Encoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_absolute_decoded = sprintf( 'Absolute %s: Decoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_relative_decoded = sprintf( 'Relative %s: Decoded Steady State Error %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 2, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_absolute_encoded )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*es_theoretical_absolute_encoded, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_absolute_encoded, scale_encoded*es_numerical_absolute_encoded, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )
                legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
                % Create the second subplot.
                subplot( 2, 2, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_absolute_decoded )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*es_theoretical_absolute_decoded, '-.', 'Color', [ color_absolute, 2/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_absolute_decoded, scale_decoded*es_numerical_absolute_decoded, '--', 'Color', [ color_absolute, 1 ], 'Linewidth', 3 )
                legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
                % Create the third subplot.
                subplot( 2, 2, 3 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_relative_encoded )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*es_theoretical_relative_encoded, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale_encoded*xs_relative_encoded, scale_encoded*es_numerical_relative_encoded, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

                % Create the fourth subplot.
                subplot( 2, 2, 4 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_relative_decoded )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*es_theoretical_relative_decoded, '-.', 'Color', [ color_relative, 2/3 ], 'Linewidth', 3 )
                plot( scale_decoded*xs_relative_decoded, scale_decoded*es_numerical_relative_decoded, '--', 'Color', [ color_relative, 1 ], 'Linewidth', 3 )
                legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

            end
                
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_sse_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
                
        
        % Implement a function to create a surface plot of the steady state error for a subnetwork that compares absolute & relative schemes before and after encoding/decoding.
        function fig = surf_steady_state_error_full_comparison( ~, Xs_absolute_encoded, Ys_absolute_encoded, Es_theoretical_absolute_encoded, Es_numerical_absolute_encoded, Xs_absolute_decoded, Ys_absolute_decoded, Es_theoretical_absolute_decoded, Es_numerical_absolute_decoded, color_absolute, Xs_relative_encoded, Ys_relative_encoded, Es_theoretical_relative_encoded, Es_numerical_relative_encoded, Xs_relative_decoded, Ys_relative_decoded, Es_theoretical_relative_decoded, Es_numerical_relative_decoded, color_relative, scale_encoded, scale_decoded, viewing_angle, subnetwork_name, variables_string_encoded, variables_string_decoded, units_encoded, units_decoded, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 32, save_tag = ''; end
            if nargin < 31, save_directory = './'; end
            if nargin < 30, save_flag = true; end
            if nargin < 29, compact_flag = true; end
            if nargin < 28, title_tag = ''; end
            if nargin < 27, units_decoded = { '-', '-', '-' }; end
            if nargin < 26, units_encoded = { '-', 'mV', 'mV' }; end
            if nargin < 25, variables_string_decoded = { 'c1', 'x1', 'x2' }; end
            if nargin < 24, variables_string_encoded = { 'c1', 'U1', 'U2' }; end
            if nargin < 23, subnetwork_name = 'Transmission'; end
            if nargin < 22, viewing_angle = [ 145, 15 ]; end
            if nargin < 21, scale_decoded = 1; end
            if nargin < 20, scale_encoded = 1; end
            
            % Define the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: Steady State Error %s', subnetwork_name, title_tag );
            
            % Define the figure labels.
            xlabel_string_encoded = sprintf( 'Parameter, %s [%s]', variables_string_encoded{ 1 }, units_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 2 }, units_encoded{ 2 } );
            zlabel_string_encoded = sprintf( 'Encoded Error, %s [%s]', variables_string_encoded{ 3 }, units_encoded{ 3 } );
            
            xlabel_string_decoded = sprintf( 'Parameter, %s [%s]', variables_string_decoded{ 1 }, units_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variables_string_decoded{ 2 }, units_decoded{ 2 } );
            zlabel_string_decoded = sprintf( 'Decoded Error, %s [%s]', variables_string_decoded{ 3 }, units_decoded{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to plot in a compact fashion.
            if compact_flag                 % If we want to create a compact plot...
                
                % Create the subplot titles.
                subplot_title_encoded = sprintf( 'Absolute %s: Encoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_decoded = sprintf( 'Relative %s: Decoded Steady State Error %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_encoded )            
                surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Es_theoretical_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Es_numerical_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 )            
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Es_theoretical_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Es_numerical_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )            
                legend( { 'Absolute Theoretical', 'Absolute Numerical', 'Relative Theoretical', 'Relative Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
                % Create the second subplot.
                subplot( 1, 2, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_decoded )            
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Es_theoretical_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Es_numerical_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 )            
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Es_theoretical_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 2/3 )
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Es_numerical_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )
                legend( { 'Absolute Theoretical', 'Absolute Numerical', 'Relative Theoretical', 'Relative Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )

            else                            % Otherwise...
                
                % Create the subplot titles.
                subplot_title_absolute_encoded = sprintf( 'Absolute %s: Encoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_relative_encoded = sprintf( 'Relative %s: Encoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_absolute_decoded = sprintf( 'Absolute %s: Decoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_relative_decoded = sprintf( 'Relative %s: Decoded Steady State Error %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 2, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_absolute_encoded ) 
                surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Es_theoretical_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Es_numerical_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 )                 
                legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
                % Create the second subplot.
                subplot( 2, 2, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_absolute_decoded )
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Es_theoretical_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 2/3 )
                surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Es_numerical_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 1 )  
                legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
                % Create the third subplot.
                subplot( 2, 2, 3 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_relative_encoded )
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Es_theoretical_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1/3 )
                surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Es_numerical_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )
                legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )

                % Create the fourth subplot.
                subplot( 2, 2, 4 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_relative_decoded )
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Es_theoretical_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1/3 )
                surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Es_numerical_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 1 )
                legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
            end
                
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_sse_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error for a subnetwork that compares absolute & relative schemes before and after encoding/decoding, including upper and lower boundaries.
        function fig = plot_steady_state_error_patch_full_comparison( self, xs_encoded, es_mean_absolute_encoded, es_min_absolute_encoded, es_max_absolute_encoded, xs_decoded, es_mean_absolute_decoded, es_min_absolute_decoded, es_max_absolute_decoded, color_absolute, es_mean_relative_encoded, es_min_relative_encoded, es_max_relative_encoded, es_mean_relative_decoded, es_min_relative_decoded, es_max_relative_decoded, color_relative, scale_encoded, scale_decoded, subnetwork_name, variables_string_encoded, variables_string_decoded, units_string_encoded, units_string_decoded, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 29, save_tag = ''; end
            if nargin < 28, save_directory = './'; end
            if nargin < 27, save_flag = true; end
            if nargin < 26, compact_flag = true; end
            if nargin < 25, title_tag = ''; end
            if nargin < 24, units_string_decoded = { '-', '-' }; end
            if nargin < 23, units_string_encoded = { 'mV', 'mV' }; end
            if nargin < 22, variables_string_decoded = { 'x1', 'E' }; end
            if nargin < 21, variables_string_encoded = { 'U1', 'E' }; end
            if nargin < 20, subnetwork_name = 'Transmission'; end
            if nargin < 19, scale_decoded = 1; end
            if nargin < 18, scale_encoded = 1; end
            
            % Generate the patch data.
            [ xs_patch_encoded, ys_patch_absolute_encoded ] = self.generate_2D_patch_data( xs_encoded, es_min_absolute_encoded, es_max_absolute_encoded );
            [ ~, ys_patch_relative_encoded ] = self.generate_2D_patch_data( xs_encoded, es_min_relative_encoded, es_max_relative_encoded );
            [ xs_patch_decoded, ys_patch_absolute_decoded ] = self.generate_2D_patch_data( xs_decoded, es_min_absolute_decoded, es_max_absolute_decoded );
            [ ~, ys_patch_relative_decoded ] = self.generate_2D_patch_data( xs_decoded, es_min_relative_decoded, es_max_relative_decoded );
            
            % Compute the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: Encoded vs Decoded Steady State Error %s', subnetwork_name );
            
            % Compute the figure labels.
            xlabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 1 }, units_string_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Error, %s [%s]', variables_string_encoded{ 2 }, units_string_encoded{ 2 } );
            xlabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variables_string_decoded{ 1 }, units_string_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Error, %s [%s]', variables_string_decoded{ 2 }, units_string_decoded{ 2 } );
            
            % Create a figure to store the data.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to compare the absolute and relative encoding schemes on a single subplot or multiple.
            if compact_flag                   % If we want to make multiple subplots...
                
                % Create the subplot titles.
                subplot_title_encoded = sprintf( 'Absolute %s: Encoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_decoded = sprintf( 'Relative %s: Decoded Steady State Error %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_encoded )
                gobj_es_patch_absolute_encoded = patch( scale_encoded*xs_patch_encoded, scale_encoded*ys_patch_absolute_encoded, color_absolute, 'FaceAlpha', 0.5, 'EdgeColor', 'None' );
                gobj_es_mean_absolute_encoded = plot( scale_encoded*xs_encoded, scale_encoded*es_mean_absolute_encoded, '-', 'Color', color_absolute, 'Linewidth', 3 );
                plot( scale_encoded*xs_encoded, scale_encoded*es_min_absolute_encoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                plot( scale_encoded*xs_encoded, scale_encoded*es_max_absolute_encoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                gobj_es_patch_relative_encoded = patch( scale_encoded*xs_patch_encoded, scale_encoded*ys_patch_relative_encoded, color_relative, 'FaceAlpha', 0.5, 'EdgeColor', 'None' );
                gobj_es_mean_relative_encoded = plot( scale_encoded*xs_encoded, scale_encoded*es_mean_relative_encoded, '-', 'Color', color_relative, 'Linewidth', 3 );
                plot( scale_encoded*xs_encoded, scale_encoded*es_min_relative_encoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                plot( scale_encoded*xs_encoded, scale_encoded*es_max_relative_encoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                legend( [ gobj_es_mean_absolute_encoded, gobj_es_patch_absolute_encoded, gobj_es_mean_relative_encoded, gobj_es_patch_relative_encoded ], { 'Absolute Average', 'Absolute Range', 'Relative Average', 'Relative Range' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
                % Create the second subplot.
                subplot( 1, 2, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_decoded )
                gobj_es_patch_absolute_decoded = patch( scale_decoded*xs_patch_decoded, scale_decoded*ys_patch_absolute_decoded, color_absolute, 'FaceAlpha', 0.5, 'EdgeColor', 'None' );
                gobj_es_mean_absolute_decoded = plot( scale_decoded*xs_decoded, scale_decoded*es_mean_absolute_decoded, '-', 'Color', color_absolute, 'Linewidth', 3 );
                plot( scale_decoded*xs_decoded, scale_decoded*es_min_absolute_decoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                plot( scale_decoded*xs_decoded, scale_decoded*es_max_absolute_decoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                gobj_es_patch_relative_decoded = patch( scale_decoded*xs_patch_decoded, scale_decoded*ys_patch_relative_decoded, color_relative, 'FaceAlpha', 0.5, 'EdgeColor', 'None' );
                gobj_es_mean_relative_decoded = plot( scale_decoded*xs_decoded, scale_decoded*es_mean_relative_decoded, '-', 'Color', color_relative, 'Linewidth', 3 );
                plot( scale_decoded*xs_decoded, scale_decoded*es_min_relative_decoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                plot( scale_decoded*xs_decoded, scale_decoded*es_max_relative_decoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                legend( [ gobj_es_mean_absolute_decoded, gobj_es_patch_absolute_decoded, gobj_es_mean_relative_decoded, gobj_es_patch_relative_decoded ], { 'Absolute Average', 'Absolute Range', 'Relative Average', 'Relative Range' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            else                                % Otherwise...
                
                % Create the subplot titles.
                subplot_title_absolute_encoded = sprintf( 'Absolute %s: Encoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_relative_encoded = sprintf( 'Relative %s: Encoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_absolute_decoded = sprintf( 'Absolute %s: Decoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_relative_decoded = sprintf( 'Relative %s: Decoded Steady State Error %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 2, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_absolute_encoded )
                gobj_es_patch_absolute_encoded = patch( scale_encoded*xs_patch_encoded, scale_encoded*ys_patch_absolute_encoded, color_absolute, 'FaceAlpha', 0.5, 'EdgeColor', 'None' );
                gobj_es_mean_absolute_encoded = plot( scale_encoded*xs_encoded, scale_encoded*es_mean_absolute_encoded, '-', 'Color', color_absolute, 'Linewidth', 3 );
                plot( scale_encoded*xs_encoded, scale_encoded*es_min_absolute_encoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                plot( scale_encoded*xs_encoded, scale_encoded*es_max_absolute_encoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                legend( [ gobj_es_mean_absolute_encoded, gobj_es_patch_absolute_encoded ], { 'Average', 'Range' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
                % Create the second subplot.
                subplot( 2, 2, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_absolute_decoded )
                gobj_es_patch_absolute_decoded = patch( scale_decoded*xs_patch_decoded, scale_decoded*ys_patch_absolute_decoded, color_absolute, 'FaceAlpha', 0.5, 'EdgeColor', 'None' );
                gobj_es_mean_absolute_decoded = plot( scale_decoded*xs_decoded, scale_decoded*es_mean_absolute_decoded, '-', 'Color', color_absolute, 'Linewidth', 3 );
                plot( scale_decoded*xs_decoded, scale_decoded*es_min_absolute_decoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                plot( scale_decoded*xs_decoded, scale_decoded*es_max_absolute_decoded, '--', 'Color', color_absolute, 'Linewidth', 1 )
                legend( [ gobj_es_mean_absolute_decoded, gobj_es_patch_absolute_decoded ], { 'Average', 'Range' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

                % Create the third subplot.
                subplot( 2, 2, 3 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_relative_encoded )
                gobj_es_patch_relative_encoded = patch( scale_encoded*xs_patch_encoded, scale_encoded*ys_patch_relative_encoded, color_relative, 'FaceAlpha', 0.5, 'EdgeColor', 'None' );
                gobj_es_mean_relative_encoded = plot( scale_encoded*xs_encoded, scale_encoded*es_mean_relative_encoded, '-', 'Color', color_relative, 'Linewidth', 3 );
                plot( scale_encoded*xs_encoded, scale_encoded*es_min_relative_encoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                plot( scale_encoded*xs_encoded, scale_encoded*es_max_relative_encoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                legend( [ gobj_es_mean_relative_encoded, gobj_es_patch_relative_encoded ], { 'Average', 'Range' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

                % Create the fourth subplot.
                subplot( 2, 2, 4 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_relative_decoded )
                gobj_es_patch_relative_decoded = patch( scale_decoded*xs_patch_decoded, scale_decoded*ys_patch_relative_decoded, color_relative, 'FaceAlpha', 0.5, 'EdgeColor', 'None' );
                gobj_es_mean_relative_decoded = plot( scale_decoded*xs_decoded, scale_decoded*es_mean_relative_decoded, '-', 'Color', color_relative, 'Linewidth', 3 );
                plot( scale_decoded*xs_decoded, scale_decoded*es_min_relative_decoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                plot( scale_decoded*xs_decoded, scale_decoded*es_max_relative_decoded, '--', 'Color', color_relative, 'Linewidth', 1 )
                legend( [ gobj_es_mean_relative_decoded, gobj_es_patch_relative_decoded ], { 'Average', 'Range' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

            end
                
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_sse_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state response for a subnetwork that compares absolute & relative schemes before and after encoding/decoding, including upper and lower boundaries.
        function fig = surf_steady_state_error_patch_full_comparison( self, Xs_absolute_encoded, Ys_absolute_encoded, Es_absolute_encoded, Es_lower_absolute_encoded, Es_upper_absolute_encoded, Xs_absolute_decoded, Ys_absolute_decoded, Es_absolute_decoded, Es_lower_absolute_decoded, Es_upper_absolute_decoded, color_absolute, Xs_relative_encoded, Ys_relative_encoded, Es_relative_encoded, Es_lower_relative_encoded, Es_upper_relative_encoded, Xs_relative_decoded, Ys_relative_decoded, Es_relative_decoded, Es_lower_relative_decoded, Es_upper_relative_decoded, color_relative, scale_encoded, scale_decoded, viewing_angle, subnetwork_name, variables_string_encoded, variables_string_decoded, units_encoded, units_decoded, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 36, save_tag = ''; end
            if nargin < 35, save_directory = './'; end
            if nargin < 34, save_flag = true; end
            if nargin < 33, compact_flag = true; end
            if nargin < 32, title_tag = '.'; end
            if nargin < 31, units_decoded = '-'; end
            if nargin < 30, units_encoded = 'mV'; end
            if nargin < 29, variables_string_decoded = 'x1'; end
            if nargin < 28, variables_string_encoded = 'U1'; end
            if nargin < 27, subnetwork_name = 'Transmission'; end
            if nargin < 26, viewing_angle = [ 145, 15 ]; end
            if nargin < 25, scale_decoded = 1; end
            if nargin < 24, scale_encoded = 1; end
            
            % Generate the patch data.
            [ ps_patch_xlower_absolute_encoded, ps_patch_xupper_absolute_encoded, ps_patch_ylower_absolute_encoded, ps_patch_yupper_absolute_encoded, ps_patch_zlower_absolute_encoded, ps_patch_zupper_absolute_encoded ] = self.generate_3D_patch_data( Xs_absolute_encoded, Ys_absolute_encoded, Es_lower_absolute_encoded, Es_upper_absolute_encoded );
            [ ps_patch_xlower_absolute_decoded, ps_patch_xupper_absolute_decoded, ps_patch_ylower_absolute_decoded, ps_patch_yupper_absolute_decoded, ps_patch_zlower_absolute_decoded, ps_patch_zupper_absolute_decoded ] = self.generate_3D_patch_data( Xs_absolute_decoded, Ys_absolute_decoded, Es_lower_absolute_decoded, Es_upper_absolute_decoded );
            [ ps_patch_xlower_relative_encoded, ps_patch_xupper_relative_encoded, ps_patch_ylower_relative_encoded, ps_patch_yupper_relative_encoded, ps_patch_zlower_relative_encoded, ps_patch_zupper_relative_encoded ] = self.generate_3D_patch_data( Xs_relative_encoded, Ys_relative_encoded, Es_lower_relative_encoded, Es_upper_relative_encoded );
            [ ps_patch_xlower_relative_decoded, ps_patch_xupper_relative_decoded, ps_patch_ylower_relative_decoded, ps_patch_yupper_relative_decoded, ps_patch_zlower_relative_decoded, ps_patch_zupper_relative_decoded ] = self.generate_3D_patch_data( Xs_relative_decoded, Ys_relative_decoded, Es_lower_relative_decoded, Es_upper_relative_decoded );
            
            % Create the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: Encoded vs Decoded Steady State Error %s', subnetwork_name, title_tag );

            % Compute the figure labels.
            xlabel_string_encoded = sprintf( 'Parameter, %s [%s]', variables_string_encoded{ 1 }, units_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 2 }, units_encoded{ 2 } );
            zlabel_string_encoded = sprintf( 'Encoded Error, %s [%s]', variables_string_encoded{ 3 }, units_encoded{ 3 } );
            xlabel_string_decoded = sprintf( 'Parameter, %s [%s]', variables_string_decoded{ 1 }, units_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variables_string_decoded{ 2 }, units_decoded{ 2 } );
            zlabel_string_decoded = sprintf( 'Decoded Error, %s [%s]', variables_string_decoded{ 3 }, units_decoded{ 3 } );
            
            % Create a figure to store the data.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to compare the absolute and relative encoding schemes on a single subplot or multiple.
            if compact_flag                   % If we want to make multiple subplots...
                
                % Create the subplot titles.
                subplot_title_encoded = sprintf( 'Absolute %s: Encoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_decoded = sprintf( 'Relative %s: Decoded Steady State Error %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_encoded )            
                gobj_surf_absolute_encoded = surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Es_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );
                gobj_patch_absolute_encoded = patch( ps_patch_xlower_absolute_encoded( :, 1 ), scale_encoded*ps_patch_xlower_absolute_encoded( :, 2 ), scale_encoded*ps_patch_xlower_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_absolute_encoded( :, 1 ), scale_encoded*ps_patch_xupper_absolute_encoded( :, 2 ), scale_encoded*ps_patch_xupper_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute_encoded( :, 1 ), scale_encoded*ps_patch_ylower_absolute_encoded( :, 2 ), scale_encoded*ps_patch_ylower_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute_encoded( :, 1 ), scale_encoded*ps_patch_yupper_absolute_encoded( :, 2 ), scale_encoded*ps_patch_yupper_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute_encoded( :, 1 ), scale_encoded*ps_patch_zlower_absolute_encoded( :, 2 ), scale_encoded*ps_patch_zlower_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute_encoded( :, 1 ), scale_encoded*ps_patch_zupper_absolute_encoded( :, 2 ), scale_encoded*ps_patch_zupper_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                gobj_surf_relative_encoded = surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Es_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                gobj_patch_relative_encoded = patch( ps_patch_xlower_relative_encoded( :, 1 ), scale_encoded*ps_patch_xlower_relative_encoded( :, 2 ), scale_encoded*ps_patch_xlower_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_relative_encoded( :, 1 ), scale_encoded*ps_patch_xupper_relative_encoded( :, 2 ), scale_encoded*ps_patch_xupper_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative_encoded( :, 1 ), scale_encoded*ps_patch_ylower_relative_encoded( :, 2 ), scale_encoded*ps_patch_ylower_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative_encoded( :, 1 ), scale_encoded*ps_patch_yupper_relative_encoded( :, 2 ), scale_encoded*ps_patch_yupper_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative_encoded( :, 1 ), scale_encoded*ps_patch_zlower_relative_encoded( :, 2 ), scale_encoded*ps_patch_zlower_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative_encoded( :, 1 ), scale_encoded*ps_patch_zupper_relative_encoded( :, 2 ), scale_encoded*ps_patch_zupper_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                legend( [ gobj_surf_absolute_encoded, gobj_patch_absolute_encoded, gobj_surf_relative_encoded, gobj_patch_relative_encoded ], { 'Absolute Average', 'Absolute Range', 'Relative Average', 'Relative Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_decoded )            
                gobj_surf_absolute_decoded = surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Es_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );
                gobj_patch_absolute_decoded = patch( ps_patch_xlower_absolute_decoded( :, 1 ), scale_decoded*ps_patch_xlower_absolute_decoded( :, 2 ), scale_decoded*ps_patch_xlower_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_absolute_decoded( :, 1 ), scale_decoded*ps_patch_xupper_absolute_decoded( :, 2 ), scale_decoded*ps_patch_xupper_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute_decoded( :, 1 ), scale_decoded*ps_patch_ylower_absolute_decoded( :, 2 ), scale_decoded*ps_patch_ylower_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute_decoded( :, 1 ), scale_decoded*ps_patch_yupper_absolute_decoded( :, 2 ), scale_decoded*ps_patch_yupper_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute_decoded( :, 1 ), scale_decoded*ps_patch_zlower_absolute_decoded( :, 2 ), scale_decoded*ps_patch_zlower_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute_decoded( :, 1 ), scale_decoded*ps_patch_zupper_absolute_decoded( :, 2 ), scale_decoded*ps_patch_zupper_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                gobj_surf_relative_decoded = surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Es_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                gobj_patch_relative_decoded = patch( ps_patch_xlower_relative_decoded( :, 1 ), scale_decoded*ps_patch_xlower_relative_decoded( :, 2 ), scale_decoded*ps_patch_xlower_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_relative_decoded( :, 1 ), scale_decoded*ps_patch_xupper_relative_decoded( :, 2 ), scale_decoded*ps_patch_xupper_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative_decoded( :, 1 ), scale_decoded*ps_patch_ylower_relative_decoded( :, 2 ), scale_decoded*ps_patch_ylower_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative_decoded( :, 1 ), scale_decoded*ps_patch_yupper_relative_decoded( :, 2 ), scale_decoded*ps_patch_yupper_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative_decoded( :, 1 ), scale_decoded*ps_patch_zlower_relative_decoded( :, 2 ), scale_decoded*ps_patch_zlower_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative_decoded( :, 1 ), scale_decoded*ps_patch_zupper_relative_decoded( :, 2 ), scale_decoded*ps_patch_zupper_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                legend( [ gobj_surf_absolute_decoded, gobj_patch_absolute_decoded, gobj_surf_relative_decoded, gobj_patch_relative_decoded ], { 'Absolute Average', 'Absolute Range', 'Relative Average', 'Relative Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
            else                                % Otherwise...
                
                % Create the subplot titles.
                subplot_title_absolute_encoded = sprintf( 'Absolute %s: Encoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_relative_encoded = sprintf( 'Relative %s: Encoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_absolute_decoded = sprintf( 'Absolute %s: Decoded Steady State Error %s', subnetwork_name, title_tag );
                subplot_title_relative_decoded = sprintf( 'Relative %s: Decoded Steady State Error %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 2, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_absolute_encoded )            
                gobj_surf_absolute_encoded = surf( Xs_absolute_encoded, scale_encoded*Ys_absolute_encoded, scale_encoded*Es_absolute_encoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );
                gobj_patch_absolute_encoded = patch( ps_patch_xlower_absolute_encoded( :, 1 ), scale_encoded*ps_patch_xlower_absolute_encoded( :, 2 ), scale_encoded*ps_patch_xlower_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_absolute_encoded( :, 1 ), scale_encoded*ps_patch_xupper_absolute_encoded( :, 2 ), scale_encoded*ps_patch_xupper_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute_encoded( :, 1 ), scale_encoded*ps_patch_ylower_absolute_encoded( :, 2 ), scale_encoded*ps_patch_ylower_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute_encoded( :, 1 ), scale_encoded*ps_patch_yupper_absolute_encoded( :, 2 ), scale_encoded*ps_patch_yupper_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute_encoded( :, 1 ), scale_encoded*ps_patch_zlower_absolute_encoded( :, 2 ), scale_encoded*ps_patch_zlower_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute_encoded( :, 1 ), scale_encoded*ps_patch_zupper_absolute_encoded( :, 2 ), scale_encoded*ps_patch_zupper_absolute_encoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                legend( [ gobj_surf_absolute_encoded, gobj_patch_absolute_encoded ], { 'Average', 'Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
                % Create the second subplot.
                subplot( 2, 2, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_absolute_decoded )            
                gobj_surf_absolute_decoded = surf( Xs_absolute_decoded, scale_decoded*Ys_absolute_decoded, scale_decoded*Es_absolute_decoded, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );
                gobj_patch_absolute_decoded = patch( ps_patch_xlower_absolute_decoded( :, 1 ), scale_decoded*ps_patch_xlower_absolute_decoded( :, 2 ), scale_decoded*ps_patch_xlower_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );                patch( ps_patch_xupper_absolute_decoded( :, 1 ), scale_decoded*ps_patch_xupper_absolute_decoded( :, 2 ), scale_decoded*ps_patch_xupper_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute_decoded( :, 1 ), scale_decoded*ps_patch_ylower_absolute_decoded( :, 2 ), scale_decoded*ps_patch_ylower_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute_decoded( :, 1 ), scale_decoded*ps_patch_yupper_absolute_decoded( :, 2 ), scale_decoded*ps_patch_yupper_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute_decoded( :, 1 ), scale_decoded*ps_patch_zlower_absolute_decoded( :, 2 ), scale_decoded*ps_patch_zlower_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute_decoded( :, 1 ), scale_decoded*ps_patch_zupper_absolute_decoded( :, 2 ), scale_decoded*ps_patch_zupper_absolute_decoded( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                legend( [ gobj_surf_absolute_decoded, gobj_patch_absolute_decoded ], { 'Average', 'Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
                % Create the third subplot.
                subplot( 2, 2, 3 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_relative_encoded )            
                gobj_surf_relative_encoded = surf( Xs_relative_encoded, scale_encoded*Ys_relative_encoded, scale_encoded*Es_relative_encoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                gobj_patch_relative_encoded = patch( ps_patch_xlower_relative_encoded( :, 1 ), scale_encoded*ps_patch_xlower_relative_encoded( :, 2 ), scale_encoded*ps_patch_xlower_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_relative_encoded( :, 1 ), scale_encoded*ps_patch_xupper_relative_encoded( :, 2 ), scale_encoded*ps_patch_xupper_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative_encoded( :, 1 ), scale_encoded*ps_patch_ylower_relative_encoded( :, 2 ), scale_encoded*ps_patch_ylower_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative_encoded( :, 1 ), scale_encoded*ps_patch_yupper_relative_encoded( :, 2 ), scale_encoded*ps_patch_yupper_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative_encoded( :, 1 ), scale_encoded*ps_patch_zlower_relative_encoded( :, 2 ), scale_encoded*ps_patch_zlower_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative_encoded( :, 1 ), scale_encoded*ps_patch_zupper_relative_encoded( :, 2 ), scale_encoded*ps_patch_zupper_relative_encoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                legend( [ gobj_surf_relative_encoded, gobj_patch_relative_encoded ], { 'Average', 'Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
                % Create the fourth subplot.
                subplot( 2, 2, 4 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_relative_decoded )            
                gobj_surf_relative_decoded = surf( Xs_relative_decoded, scale_decoded*Ys_relative_decoded, scale_decoded*Es_relative_decoded, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                gobj_patch_relative_decoded = patch( ps_patch_xlower_relative_decoded( :, 1 ), scale_decoded*ps_patch_xlower_relative_decoded( :, 2 ), scale_decoded*ps_patch_xlower_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
                patch( ps_patch_xupper_relative_decoded( :, 1 ), scale_decoded*ps_patch_xupper_relative_decoded( :, 2 ), scale_decoded*ps_patch_xupper_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative_decoded( :, 1 ), scale_decoded*ps_patch_ylower_relative_decoded( :, 2 ), scale_decoded*ps_patch_ylower_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative_decoded( :, 1 ), scale_decoded*ps_patch_yupper_relative_decoded( :, 2 ), scale_decoded*ps_patch_yupper_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative_decoded( :, 1 ), scale_decoded*ps_patch_zlower_relative_decoded( :, 2 ), scale_decoded*ps_patch_zlower_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative_decoded( :, 1 ), scale_decoded*ps_patch_zupper_relative_decoded( :, 2 ), scale_decoded*ps_patch_zupper_relative_decoded( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                legend( [ gobj_surf_relative_decoded, gobj_patch_relative_decoded ], { 'Average', 'Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
                
            end
                
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_sse_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        %% Steady State Error Difference Plotting Functions.

        % Implement a function to plot the steady state error difference of a subnetwork for a specific encoding scheme and gain.
        function fig = plot_steady_state_error_difference( ~, xs, es_theoretical, es_numerical, scale, subnetwork_name, encoded_string, variables_string, units_string, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 12, save_tag = ''; end
            if nargin < 11, save_directory = './'; end
            if nargin < 10, save_flag = true; end
            if nargin < 9, units_string = { 'mV', 'mV' }; end
            if nargin < 8, variables_string = { 'U1', 'dE' }; end
            if nargin < 7, encoded_string = 'Encoded'; end
            if nargin < 6, subnetwork_name = 'Transmission'; end
            if nargin < 5, scale = 1; end
            
            % Compute the figure title.
            title_string = sprintf( '%s: %s Steady State Error Difference', subnetwork_name, encoded_string );
            
            % Compute the figure labels.
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( '%s Error Difference, %s [%s]', encoded_string, variables_string{ 2 }, units_string{ 2 } );

            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
            
            % Plot the theoretical and numerical steady state errors.
            plot( scale*xs, scale*es_theoretical, '-.', 'Linewidth', 3 )
            plot( scale*xs, scale*es_numerical, '--', 'Linewidth', 3 )
            
            % Add a legend to the figure.
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_ssed_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state response of a subnetwork for a specific encoding scheme and gain.
        function fig = surf_steady_state_error_difference( ~, Xs, Ys, Es_theoretical, Es_numerical, scale, viewing_angle, subnetwork_name, encoded_string, variables_string, units, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 15, save_tag = ''; end
            if nargin < 14, save_directory = './'; end
            if nargin < 13, save_flag = true; end
            if nargin < 12, title_tag = ''; end
            if nargin < 11, units = { '-', 'mV', 'mV' }; end
            if nargin < 10, variables_string = { 'c1', 'U1', 'E' }; end
            if nargin < 9, encoded_string = 'Encoded'; end
            if nargin < 8, subnetwork_name = 'Transmission'; end
            if nargin < 7, viewing_angle = [ 145, 15 ]; end
            if nargin < 6, scale = 1; end
            
            % Generate the figure title.
            title_string = sprintf( '%s: %s Steady State Error Difference %s', subnetwork_name, encoded_string, title_tag );
            
            % Compute the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Error Difference, %s [%s]', encoded_string, variables_string{ 3 }, units{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )
            
            % Plot the theoretical and numerical errors.
            surf( Xs, scale*Ys, scale*Es_theoretical, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
            surf( Xs, scale*Ys, scale*Es_numerical, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
            
            % Add a legend to the figure.
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_ssed_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error difference of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = plot_steady_state_error_difference_patch( self, xs, es_mean, es_min, es_max, color, scale, subnetwork_name, encoded_string, variables_string, units_string, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 15, save_tag = ''; end
            if nargin < 14, save_directory = './'; end
            if nargin < 13, save_flag = true; end
            if nargin < 12, units_string = { 'mV', 'mV' }; end
            if nargin < 11, variables_string = { 'U1', 'E' }; end
            if nargin < 10, encoded_string = 'Encoded'; end
            if nargin < 8, subnetwork_name = 'Transmission'; end
            if nargin < 7, scale = 1; end
            
            % Generate the patch data.
            [ xs_patch, ys_patch ] = self.generate_2D_patch_data( xs, es_min, es_max );
            
            % Compute the figure title.
            title_string = sprintf( '%s: %s Steady State Error Difference Summary', subnetwork_name, encoded_string );
            
            % Compute the figure labels.
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( '%s Error, %s [%s]', encoded_string, variables_string{ 2 }, units_string{ 2 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )            
            
            % Plot a summary of the absolute encoded steady state behavior over the formulation parameters.
            patch( scale*xs_patch, scale*ys_patch, color, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
            plot( scale*xs, scale*es_mean, '-', 'Color', color, 'Linewidth', 3 )
            plot( scale*xs, scale*es_min, '--', 'Color', color, 'Linewidth', 1 )
            plot( scale*xs, scale*es_max, '--', 'Color', color, 'Linewidth', 1 )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_sse_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state error difference of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = surf_steady_state_error_difference_patch( self, Xs, Ys, Zs, Zs_lower, Zs_upper, color, scale, viewing_angle, subnetwork_name, encoded_string, variables_string, units, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 17, save_tag = ''; end
            if nargin < 16, save_directory = './'; end
            if nargin < 15, save_flag = true; end
            if nargin < 14, title_tag = ''; end
            if nargin < 13, units = { '-', 'mV', 'mV' }; end
            if nargin < 12, variables_string = { 'c1', 'U1', 'E' }; end
            if nargin < 11, encoded_string = 'Encoded'; end
            if nargin < 10, subnetwork_name = 'Transmission'; end
            if nargin < 9, viewing_angle = [ 145, 15 ]; end
            if nargin < 8, scale = 1; end
            if nargin < 7, color = [ 0.0000, 0.4470, 0.7410 ]; end
            
            % Generate the patch data.
            [ ps_patch_xlower, ps_patch_xupper, ps_patch_ylower, ps_patch_yupper, ps_patch_zlower, ps_patch_zupper ] = self.generate_3D_patch_data( Xs, Ys, Zs_lower, Zs_upper );
            
            % Create the figure title.
            title_string = sprintf( '%s: %s Steady State Error Difference %s', subnetwork_name, encoded_string, title_tag );
            
            % Compute the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Error, %s [%s]', encoded_string, variables_string{ 3 }, units{ 3 } );
            
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
                file_name = sprintf( '%s_%s_ssed_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error of a subnetwork for a specific gain.
        function fig = plot_steady_state_error_difference_comparison( ~, xs_encoded, es_theoretical_encoded, es_numerical_encoded, color_encoded, xs_decoded, es_theoretical_decoded, es_numerical_decoded, color_decoded, scale_encoded, scale_decoded, subnetwork_name, variables_string_encoded, variables_string_decoded, units_string_encoded, units_string_decoded, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 20, save_tag = ''; end
            if nargin < 19, save_directory = './'; end
            if nargin < 18, save_flag = true; end
            if nargin < 17, title_tag = ''; end
            if nargin < 16, units_string_decoded = { '-', '-' }; end
            if nargin < 15, units_string_encoded = { 'mV', 'mV' }; end
            if nargin < 14, variables_string_decoded = { 'x1', 'E' }; end
            if nargin < 13, variables_string_encoded = { 'U1', 'E' }; end
            if nargin < 12, subnetwork_name = 'Transmission'; end
            if nargin < 11, scale_decoded = 1; end
            if nargin < 10, scale_encoded = 1; end
            
            % Compute the figure title.
            title_string = sprintf( 'Encoded vs Decoded %s: Steady State Error Difference %s', subnetwork_name, title_tag );
            
            % Compute the figure labels.
            xlabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 1 }, units_string_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Error, %s [%s]', variables_string_encoded{ 2 }, units_string_encoded{ 2 } );
            xlabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variables_string_decoded{ 1 }, units_string_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Error, %s [%s]', variables_string_decoded{ 2 }, units_string_decoded{ 2 } );
            
            % Create a figure to store the data.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Create the subplot titles.
            subplot_title_encoded = sprintf( 'Encoded %s: Steady State Error Difference %s', subnetwork_name, title_tag );
            subplot_title_decoded = sprintf( 'Decoded %s: Steady State Error Difference %s', subnetwork_name, title_tag );

            % Create the first subplot.
            subplot( 2, 1, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_encoded )
            plot( scale_encoded*xs_encoded, scale_encoded*es_theoretical_encoded, '-.', 'Color', [ color_encoded, 2/3 ], 'Linewidth', 3 )
            plot( scale_encoded*xs_encoded, scale_encoded*es_numerical_encoded, '--', 'Color', [ color_encoded, 1 ], 'Linewidth', 3 )
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

            % Create the second subplot.
            subplot( 2, 1, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_decoded )
            plot( scale_decoded*xs_decoded, scale_decoded*es_theoretical_decoded, '-.', 'Color', [ color_decoded, 2/3 ], 'Linewidth', 3 )
            plot( scale_decoded*xs_decoded, scale_decoded*es_numerical_decoded, '--', 'Color', [ color_decoded, 1 ], 'Linewidth', 3 )
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_ssed_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state error difference of a subnetwork for a specific gain.
        function fig = surf_steady_state_error_difference_comparison( ~, Xs_encoded, Ys_encoded, Es_theoretical_encoded, Es_numerical_encoded, color_encoded, Xs_decoded, Ys_decoded, Es_theoretical_decoded, Es_numerical_decoded, color_decoded, scale_encoded, scale_decoded, viewing_angle, subnetwork_name, variables_string_encoded, variables_string_decoded, units_string_encoded, units_string_decoded, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 23, save_tag = ''; end
            if nargin < 22, save_directory = './'; end
            if nargin < 21, save_flag = true; end
            if nargin < 20, title_tag = ''; end
            if nargin < 19, units_string_decoded = { '-', '-', '-' }; end
            if nargin < 18, units_string_encoded = { '-', 'mV', 'mV' }; end
            if nargin < 17, variables_string_decoded = { 'c1', 'x1', 'dE' }; end
            if nargin < 16, variables_string_encoded = { 'c1', 'U1', 'dE' }; end
            if nargin < 15, subnetwork_name = 'Transmission'; end
            if nargin < 14, viewing_angle = [ 145, 15 ]; end
            if nargin < 13, scale_decoded = 1; end
            if nargin < 12, scale_encoded = 1; end
            
            % Create the figure title.
            title_string = sprintf( '%s: Steady State Error Difference %s', subnetwork_name, title_tag );
            
            % Create the figure labels.
            xlabel_string_encoded = sprintf( 'Parameter, %s [%s]', variables_string_encoded{ 1 }, units_string_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 2 }, units_string_encoded{ 2 } );
            zlabel_string_encoded = sprintf( 'Encoded Error Difference, %s [%s]', variables_string_encoded{ 3 }, units_string_encoded{ 3 } );
            
            xlabel_string_decoded = sprintf( 'Parameter, %s [%s]', variables_string_decoded{ 1 }, units_string_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Encoded Input, %s [%s]', variables_string_decoded{ 2 }, units_string_decoded{ 2 } );
            zlabel_string_decoded = sprintf( 'Encoded Error Difference, %s [%s]', variables_string_decoded{ 3 }, units_string_decoded{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Create the subplot titles.
            subplot_title_encoded = sprintf( '%s: Encoded Steady State Error %s', subnetwork_name, title_tag );
            subplot_title_decoded = sprintf( '%s: Decoded Steady State Error %s', subnetwork_name, title_tag );

            % Create the first subplot.
            subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_encoded )            
            surf( Xs_encoded, scale_encoded*Ys_encoded, scale_encoded*Es_theoretical_encoded, 'Edgecolor', 'None', 'Facecolor', color_encoded, 'Facealpha', 2/3 )
            surf( Xs_encoded, scale_encoded*Ys_encoded, scale_encoded*Es_numerical_encoded, 'Edgecolor', 'None', 'Facecolor', color_encoded, 'Facealpha', 1 )            
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )

            % Create the second subplot.
            subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_decoded )            
            surf( Xs_decoded, scale_decoded*Ys_decoded, scale_decoded*Es_theoretical_decoded, 'Edgecolor', 'None', 'Facecolor', color_decoded, 'Facealpha', 2/3 )
            surf( Xs_decoded, scale_decoded*Ys_decoded, scale_decoded*Es_numerical_decoded, 'Edgecolor', 'None', 'Facecolor', color_decoded, 'Facealpha', 1 )            
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_ssed_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error difference of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = plot_steady_state_error_difference_patch_comparison( self, xs_encoded, es_mean_encoded, es_min_encoded, es_max_encoded, color_encoded, xs_decoded, es_mean_decoded, es_min_decoded, es_max_decoded, color_decoded, scale_encoded, scale_decoded, subnetwork_name, variables_string_encoded, variables_string_decoded, units_string_encoded, units_string_decoded, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 22, save_tag = ''; end
            if nargin < 21, save_directory = './'; end
            if nargin < 20, save_flag = true; end
            if nargin < 19, title_tag = ''; end
            if nargin < 18, units_string_decoded = { '-', '-' }; end
            if nargin < 17, units_string_encoded = { 'mV', 'mV' }; end
            if nargin < 16, variables_string_decoded = { 'x1', 'E' }; end
            if nargin < 15, variables_string_encoded = { 'U1', 'E' }; end
            if nargin < 14, subnetwork_name = 'Transmission'; end
            if nargin < 13, scale_decoded = 1; end
            if nargin < 12, scale_encoded = 1; end

            % Generate the patch data.
            [ xs_patch_encoded, ys_patch_encoded ] = self.generate_2D_patch_data( xs_encoded, es_min_encoded, es_max_encoded );
            [ xs_patch_decoded, ys_patch_decoded ] = self.generate_2D_patch_data( xs_decoded, es_min_decoded, es_max_decoded );
            
            % Compute the figure title.
            title_string = sprintf( '%s: Steady State Error Difference %s', subnetwork_name, title_tag );
            
            % Compute the figure labels.
            xlabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 1 }, units_string_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Error, %s [%s]', variables_string_encoded{ 2 }, units_string_encoded{ 2 } );
            
            xlabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variables_string_decoded{ 1 }, units_string_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Error, %s [%s]', variables_string_decoded{ 2 }, units_string_decoded{ 2 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
                
            % Create the subplot titles.
            subplot_title_encoded = sprintf( '%s: Encoded Steady State Error Difference %s', subnetwork_name, title_tag );
            subplot_title_decoded = sprintf( '%s: Decoded Steady State Error Difference %s', subnetwork_name, title_tag );

            % Create the first subplot.
            subplot( 2, 1, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_encoded )
            patch( scale_encoded*xs_patch_encoded, scale_encoded*ys_patch_encoded, color_encoded, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
            plot( scale_encoded*xs_encoded, scale_encoded*es_mean_encoded, '-', 'Color', color_encoded, 'Linewidth', 3 )
            plot( scale_encoded*xs_encoded, scale_encoded*es_min_encoded, '--', 'Color', color_encoded, 'Linewidth', 1 )
            plot( scale_encoded*xs_encoded, scale_encoded*es_max_encoded, '--', 'Color', color_encoded, 'Linewidth', 1 )

            % Create the second subplot.
            subplot( 2, 1, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_decoded )
            patch( scale_decoded*xs_patch_decoded, scale_decoded*ys_patch_decoded, color_decoded, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
            plot( scale_decoded*xs_decoded, scale_decoded*es_mean_decoded, '-', 'Color', color_decoded, 'Linewidth', 3 )
            plot( scale_decoded*xs_decoded, scale_decoded*es_min_decoded, '--', 'Color', color_decoded, 'Linewidth', 1 )
            plot( scale_decoded*xs_decoded, scale_decoded*es_max_decoded, '--', 'Color', color_decoded, 'Linewidth', 1 )
                            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_ssed_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state error of a subnetwork for a specific gain, including upper and lower boundaries.
        function fig = surf_steady_state_error_difference_patch_comparison( self, Xs_encoded, Ys_encoded, Es_encoded, Es_lower_encoded, Es_upper_encoded, color_encoded, Xs_decoded, Ys_decoded, Es_decoded, Es_lower_decoded, Es_upper_decoded, color_decoded, scale_encoded, scale_decoded, viewing_angle, subnetwork_name, variables_string_encoded, variables_string_decoded, units_string_encoded, units_string_decoded, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 25, save_tag = ''; end
            if nargin < 24, save_directory = './'; end
            if nargin < 23, save_flag = true; end
            if nargin < 22, title_tag = ''; end
            if nargin < 21, units_string_decoded = { '-', '-', '-' }; end
            if nargin < 20, units_string_encoded = { '-', 'mV', 'mV' }; end
            if nargin < 19, variables_string_decoded = { 'c1', 'x1', 'dE' }; end
            if nargin < 18, variables_string_encoded = { 'c1', 'U1', 'dE' }; end
            if nargin < 17, subnetwork_name = 'Transmission'; end
            if nargin < 16, viewing_angle = [ 145, 15 ]; end
            if nargin < 15, scale_decoded = 1; end
            if nargin < 14, scale_encoded = 1; end
                        
            % Generate the patch data.
            [ ps_patch_xlower_encoded, ps_patch_xupper_encoded, ps_patch_ylower_encoded, ps_patch_yupper_encoded, ps_patch_zlower_encoded, ps_patch_zupper_encoded ] = self.generate_3D_patch_data( Xs_encoded, Ys_encoded, Es_lower_encoded, Es_upper_encoded );
            [ ps_patch_xlower_decoded, ps_patch_xupper_decoded, ps_patch_ylower_decoded, ps_patch_yupper_decoded, ps_patch_zlower_decoded, ps_patch_zupper_decoded ] = self.generate_3D_patch_data( Xs_decoded, Ys_decoded, Es_lower_decoded, Es_upper_decoded );

            % Create the figure title.
            title_string = sprintf( '%s: Steady State Error Difference %s', subnetwork_name, title_tag );
            
            % Create the figure labels.
            xlabel_string_encoded = sprintf( 'Parameter, %s [%s]', variables_string_encoded{ 1 }, units_string_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 2 }, units_string_encoded{ 2 } );
            zlabel_string_encoded = sprintf( 'Encoded Error Difference, %s [%s]', variables_string_encoded{ 3 }, units_string_encoded{ 3 } );
                        
            xlabel_string_decoded = sprintf( 'Parameter, %s [%s]', variables_string_decoded{ 1 }, units_string_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variables_string_decoded{ 2 }, units_string_decoded{ 2 } );
            zlabel_string_decoded = sprintf( 'Decoded Error Difference, %s [%s]', variables_string_decoded{ 3 }, units_string_decoded{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
                        
            % Create the subplot titles.
            subplot_title_encoded = sprintf( '%s: Encoded Steady State Error Difference %s', subnetwork_name, title_tag );
            subplot_title_decoded = sprintf( '%s: Decoded Steady State Error Difference %s', subnetwork_name, title_tag );

            % Create the first subplot.
            subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_encoded )            
            gobj_surf_encoded = surf( Xs_encoded, scale_encoded*Ys_encoded, scale_encoded*Es_encoded, 'Edgecolor', 'None', 'Facecolor', color_encoded, 'Facealpha', 0.90 );
            gobj_patch_encoded = patch( ps_patch_xlower_encoded( :, 1 ), scale_encoded*ps_patch_xlower_encoded( :, 2 ), scale_encoded*ps_patch_xlower_encoded( :, 3 ), color_encoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
            patch( ps_patch_xupper_encoded( :, 1 ), scale_encoded*ps_patch_xupper_encoded( :, 2 ), scale_encoded*ps_patch_xupper_encoded( :, 3 ), color_encoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_ylower_encoded( :, 1 ), scale_encoded*ps_patch_ylower_encoded( :, 2 ), scale_encoded*ps_patch_ylower_encoded( :, 3 ), color_encoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_yupper_encoded( :, 1 ), scale_encoded*ps_patch_yupper_encoded( :, 2 ), scale_encoded*ps_patch_yupper_encoded( :, 3 ), color_encoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zlower_encoded( :, 1 ), scale_encoded*ps_patch_zlower_encoded( :, 2 ), scale_encoded*ps_patch_zlower_encoded( :, 3 ), color_encoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zupper_encoded( :, 1 ), scale_encoded*ps_patch_zupper_encoded( :, 2 ), scale_encoded*ps_patch_zupper_encoded( :, 3 ), color_encoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            legend( [ gobj_surf_encoded, gobj_patch_encoded ], { 'Average', 'Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
            % Create the second subplot.
            subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_decoded )            
            gobj_surf_decoded = surf( Xs_decoded, scale_decoded*Ys_decoded, scale_decoded*Es_decoded, 'Edgecolor', 'None', 'Facecolor', color_decoded, 'Facealpha', 0.90 );
            gobj_patch_decoded = patch( ps_patch_xlower_decoded( :, 1 ), scale_decoded*ps_patch_xlower_decoded( :, 2 ), scale_decoded*ps_patch_xlower_decoded( :, 3 ), color_decoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
            patch( ps_patch_xupper_decoded( :, 1 ), scale_decoded*ps_patch_xupper_decoded( :, 2 ), scale_decoded*ps_patch_xupper_decoded( :, 3 ), color_decoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_ylower_decoded( :, 1 ), scale_decoded*ps_patch_ylower_decoded( :, 2 ), scale_decoded*ps_patch_ylower_decoded( :, 3 ), color_decoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_yupper_decoded( :, 1 ), scale_decoded*ps_patch_yupper_decoded( :, 2 ), scale_decoded*ps_patch_yupper_decoded( :, 3 ), color_decoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zlower_decoded( :, 1 ), scale_decoded*ps_patch_zlower_decoded( :, 2 ), scale_decoded*ps_patch_zlower_decoded( :, 3 ), color_decoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zupper_decoded( :, 1 ), scale_decoded*ps_patch_zupper_decoded( :, 2 ), scale_decoded*ps_patch_zupper_decoded( :, 3 ), color_decoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            legend( [ gobj_surf_decoded, gobj_patch_decoded ], { 'Average', 'Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_sse_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        %% Steady State Error Improvement Plotting Functions.

        % Implement a function to plot the steady state error improvement of a subnetwork for a specific encoding scheme and gain.
        function fig = plot_steady_state_error_improvement( ~, xs, es_theoretical, es_numerical, scale, subnetwork_name, encoded_string, variables_string, units_string, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 12, save_tag = ''; end
            if nargin < 11, save_directory = './'; end
            if nargin < 10, save_flag = true; end
            if nargin < 9, units_string = { 'mV', 'mV' }; end
            if nargin < 8, variables_string = { 'U1', 'dE' }; end
            if nargin < 7, encoded_string = 'Encoded'; end
            if nargin < 6, subnetwork_name = 'Transmission'; end
            if nargin < 5, scale = 1; end
            
            % Compute the figure title.
            title_string = sprintf( '%s: %s Steady State Error Improvement', subnetwork_name, encoded_string );
            
            % Compute the figure labels.
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( '%s Error Improvement, %s [%s]', encoded_string, variables_string{ 2 }, units_string{ 2 } );

            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
            
            % Plot the theoretical and numerical steady state errors.
            plot( scale*xs, scale*es_theoretical, '-.', 'Linewidth', 3 )
            plot( scale*xs, scale*es_numerical, '--', 'Linewidth', 3 )
            
            % Add a legend to the figure.
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_ssei_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state response of a subnetwork for a specific encoding scheme and gain.
        function fig = surf_steady_state_error_improvement( ~, Xs, Ys, Es_theoretical, Es_numerical, scale, viewing_angle, subnetwork_name, encoded_string, variables_string, units, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 15, save_tag = ''; end
            if nargin < 14, save_directory = './'; end
            if nargin < 13, save_flag = true; end
            if nargin < 12, title_tag = ''; end
            if nargin < 11, units = { '-', 'mV', 'mV' }; end
            if nargin < 10, variables_string = { 'c1', 'U1', 'E' }; end
            if nargin < 9, encoded_string = 'Encoded'; end
            if nargin < 8, subnetwork_name = 'Transmission'; end
            if nargin < 7, viewing_angle = [ 145, 15 ]; end
            if nargin < 6, scale = 1; end
            
            % Generate the figure title.
            title_string = sprintf( '%s: %s Steady State Error Improvement %s', subnetwork_name, encoded_string, title_tag );
            
            % Compute the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Error Improvement, %s [%s]', encoded_string, variables_string{ 3 }, units{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )
            
            % Plot the theoretical and numerical errors.
            surf( Xs, scale*Ys, scale*Es_theoretical, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
            surf( Xs, scale*Ys, scale*Es_numerical, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
            
            % Add a legend to the figure.
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_ssei_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error improvement of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = plot_steady_state_error_improvement_patch( self, xs, es_mean, es_min, es_max, color, scale, subnetwork_name, encoded_string, variables_string, units_string, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 15, save_tag = ''; end
            if nargin < 14, save_directory = './'; end
            if nargin < 13, save_flag = true; end
            if nargin < 12, units_string = { 'mV', 'mV' }; end
            if nargin < 11, variables_string = { 'U1', 'E' }; end
            if nargin < 10, encoded_string = 'Encoded'; end
            if nargin < 8, subnetwork_name = 'Transmission'; end
            if nargin < 7, scale = 1; end
            
            % Generate the patch data.
            [ xs_patch, ys_patch ] = self.generate_2D_patch_data( xs, es_min, es_max );
            
            % Compute the figure title.
            title_string = sprintf( '%s: %s Steady State Error Improvement Summary', subnetwork_name, encoded_string );
            
            % Compute the figure labels.
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( '%s Error, %s [%s]', encoded_string, variables_string{ 2 }, units_string{ 2 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )            
            
            % Plot a summary of the absolute encoded steady state behavior over the formulation parameters.
            patch( scale*xs_patch, scale*ys_patch, color, 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
            plot( scale*xs, scale*es_mean, '-', 'Color', color, 'Linewidth', 3 )
            plot( scale*xs, scale*es_min, '--', 'Color', color, 'Linewidth', 1 )
            plot( scale*xs, scale*es_max, '--', 'Color', color, 'Linewidth', 1 )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_ssei_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state error improvement of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = surf_steady_state_error_improvement_patch( self, Xs, Ys, Zs, Zs_lower, Zs_upper, color, scale, viewing_angle, subnetwork_name, encoded_string, variables_string, units, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 17, save_tag = ''; end
            if nargin < 16, save_directory = './'; end
            if nargin < 15, save_flag = true; end
            if nargin < 14, title_tag = ''; end
            if nargin < 13, units = { '-', 'mV', 'mV' }; end
            if nargin < 12, variables_string = { 'c1', 'U1', 'E' }; end
            if nargin < 11, encoded_string = 'Encoded'; end
            if nargin < 10, subnetwork_name = 'Transmission'; end
            if nargin < 9, viewing_angle = [ 145, 15 ]; end
            if nargin < 8, scale = 1; end
            if nargin < 7, color = [ 0.0000, 0.4470, 0.7410 ]; end
            
            % Generate the patch data.
            [ ps_patch_xlower, ps_patch_xupper, ps_patch_ylower, ps_patch_yupper, ps_patch_zlower, ps_patch_zupper ] = self.generate_3D_patch_data( Xs, Ys, Zs_lower, Zs_upper );
            
            % Create the figure title.
            title_string = sprintf( '%s: %s Steady State Error Improvement %s', subnetwork_name, encoded_string, title_tag );
            
            % Compute the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units{ 1 } );
            ylabel_string = sprintf( '%s Input, %s [%s]', encoded_string, variables_string{ 2 }, units{ 2 } );
            zlabel_string = sprintf( '%s Error, %s [%s]', encoded_string, variables_string{ 3 }, units{ 3 } );
            
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
                file_name = sprintf( '%s_%s_ssei_%s.png', lower( subnetwork_name ), lower( encoded_string ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error of a subnetwork for a specific gain.
        function fig = plot_steady_state_error_improvement_comparison( ~, xs_encoded, es_theoretical_encoded, es_numerical_encoded, color_encoded, xs_decoded, es_theoretical_decoded, es_numerical_decoded, color_decoded, scale_encoded, scale_decoded, subnetwork_name, variables_string_encoded, variables_string_decoded, units_string_encoded, units_string_decoded, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 20, save_tag = ''; end
            if nargin < 19, save_directory = './'; end
            if nargin < 18, save_flag = true; end
            if nargin < 17, title_tag = ''; end
            if nargin < 16, units_string_decoded = { '-', '-' }; end
            if nargin < 15, units_string_encoded = { 'mV', 'mV' }; end
            if nargin < 14, variables_string_decoded = { 'x1', 'E' }; end
            if nargin < 13, variables_string_encoded = { 'U1', 'E' }; end
            if nargin < 12, subnetwork_name = 'Transmission'; end
            if nargin < 11, scale_decoded = 1; end
            if nargin < 10, scale_encoded = 1; end
            
            % Compute the figure title.
            title_string = sprintf( 'Encoded vs Decoded %s: Steady State Error Improvement %s', subnetwork_name, title_tag );
            
            % Compute the figure labels.
            xlabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 1 }, units_string_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Error, %s [%s]', variables_string_encoded{ 2 }, units_string_encoded{ 2 } );
            xlabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variables_string_decoded{ 1 }, units_string_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Error, %s [%s]', variables_string_decoded{ 2 }, units_string_decoded{ 2 } );
            
            % Create a figure to store the data.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Create the subplot titles.
            subplot_title_encoded = sprintf( 'Encoded %s: Steady State Error Improvement %s', subnetwork_name, title_tag );
            subplot_title_decoded = sprintf( 'Decoded %s: Steady State Error Improvement %s', subnetwork_name, title_tag );

            % Create the first subplot.
            subplot( 2, 1, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_encoded )
            plot( scale_encoded*xs_encoded, scale_encoded*es_theoretical_encoded, '-.', 'Color', [ color_encoded, 2/3 ], 'Linewidth', 3 )
            plot( scale_encoded*xs_encoded, scale_encoded*es_numerical_encoded, '--', 'Color', [ color_encoded, 1 ], 'Linewidth', 3 )
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

            % Create the second subplot.
            subplot( 2, 1, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_decoded )
            plot( scale_decoded*xs_decoded, scale_decoded*es_theoretical_decoded, '-.', 'Color', [ color_decoded, 2/3 ], 'Linewidth', 3 )
            plot( scale_decoded*xs_decoded, scale_decoded*es_numerical_decoded, '--', 'Color', [ color_decoded, 1 ], 'Linewidth', 3 )
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_ssei_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state error improvement of a subnetwork for a specific gain.
        function fig = surf_steady_state_error_improvement_comparison( ~, Xs_encoded, Ys_encoded, Es_theoretical_encoded, Es_numerical_encoded, color_encoded, Xs_decoded, Ys_decoded, Es_theoretical_decoded, Es_numerical_decoded, color_decoded, scale_encoded, scale_decoded, viewing_angle, subnetwork_name, variables_string_encoded, variables_string_decoded, units_string_encoded, units_string_decoded, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 23, save_tag = ''; end
            if nargin < 22, save_directory = './'; end
            if nargin < 21, save_flag = true; end
            if nargin < 20, title_tag = ''; end
            if nargin < 19, units_string_decoded = { '-', '-', '-' }; end
            if nargin < 18, units_string_encoded = { '-', 'mV', 'mV' }; end
            if nargin < 17, variables_string_decoded = { 'c1', 'x1', 'dE' }; end
            if nargin < 16, variables_string_encoded = { 'c1', 'U1', 'dE' }; end
            if nargin < 15, subnetwork_name = 'Transmission'; end
            if nargin < 14, viewing_angle = [ 145, 15 ]; end
            if nargin < 13, scale_decoded = 1; end
            if nargin < 12, scale_encoded = 1; end
            
            % Create the figure title.
            title_string = sprintf( '%s: Steady State Error Improvement %s', subnetwork_name, title_tag );
            
            % Create the figure labels.
            xlabel_string_encoded = sprintf( 'Parameter, %s [%s]', variables_string_encoded{ 1 }, units_string_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 2 }, units_string_encoded{ 2 } );
            zlabel_string_encoded = sprintf( 'Encoded Error Improvement, %s [%s]', variables_string_encoded{ 3 }, units_string_encoded{ 3 } );
            
            xlabel_string_decoded = sprintf( 'Parameter, %s [%s]', variables_string_decoded{ 1 }, units_string_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Encoded Input, %s [%s]', variables_string_decoded{ 2 }, units_string_decoded{ 2 } );
            zlabel_string_decoded = sprintf( 'Encoded Error Improvement, %s [%s]', variables_string_decoded{ 3 }, units_string_decoded{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Create the subplot titles.
            subplot_title_encoded = sprintf( '%s: Encoded Steady State Error %s', subnetwork_name, title_tag );
            subplot_title_decoded = sprintf( '%s: Decoded Steady State Error %s', subnetwork_name, title_tag );

            % Create the first subplot.
            subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_encoded )            
            surf( Xs_encoded, scale_encoded*Ys_encoded, scale_encoded*Es_theoretical_encoded, 'Edgecolor', 'None', 'Facecolor', color_encoded, 'Facealpha', 2/3 )
            surf( Xs_encoded, scale_encoded*Ys_encoded, scale_encoded*Es_numerical_encoded, 'Edgecolor', 'None', 'Facecolor', color_encoded, 'Facealpha', 1 )            
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )

            % Create the second subplot.
            subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_decoded )            
            surf( Xs_decoded, scale_decoded*Ys_decoded, scale_decoded*Es_theoretical_decoded, 'Edgecolor', 'None', 'Facecolor', color_decoded, 'Facealpha', 2/3 )
            surf( Xs_decoded, scale_decoded*Ys_decoded, scale_decoded*Es_numerical_decoded, 'Edgecolor', 'None', 'Facecolor', color_decoded, 'Facealpha', 1 )            
            legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_ssei_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to plot the steady state error improvement of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = plot_steady_state_error_improvement_patch_comparison( self, xs_encoded, es_mean_encoded, es_min_encoded, es_max_encoded, color_encoded, xs_decoded, es_mean_decoded, es_min_decoded, es_max_decoded, color_decoded, scale_encoded, scale_decoded, subnetwork_name, variables_string_encoded, variables_string_decoded, units_string_encoded, units_string_decoded, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 22, save_tag = ''; end
            if nargin < 21, save_directory = './'; end
            if nargin < 20, save_flag = true; end
            if nargin < 19, title_tag = ''; end
            if nargin < 18, units_string_decoded = { '-', '-' }; end
            if nargin < 17, units_string_encoded = { 'mV', 'mV' }; end
            if nargin < 16, variables_string_decoded = { 'x1', 'E' }; end
            if nargin < 15, variables_string_encoded = { 'U1', 'E' }; end
            if nargin < 14, subnetwork_name = 'Transmission'; end
            if nargin < 13, scale_decoded = 1; end
            if nargin < 12, scale_encoded = 1; end

            % Generate the patch data.
            [ xs_patch_encoded, ys_patch_encoded ] = self.generate_2D_patch_data( xs_encoded, es_min_encoded, es_max_encoded );
            [ xs_patch_decoded, ys_patch_decoded ] = self.generate_2D_patch_data( xs_decoded, es_min_decoded, es_max_decoded );
            
            % Compute the figure title.
            title_string = sprintf( '%s: Steady State Error Improvement %s', subnetwork_name, title_tag );
            
            % Compute the figure labels.
            xlabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 1 }, units_string_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Error, %s [%s]', variables_string_encoded{ 2 }, units_string_encoded{ 2 } );
            
            xlabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variables_string_decoded{ 1 }, units_string_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Error, %s [%s]', variables_string_decoded{ 2 }, units_string_decoded{ 2 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
                
            % Create the subplot titles.
            subplot_title_encoded = sprintf( '%s: Encoded Steady State Error Improvement %s', subnetwork_name, title_tag );
            subplot_title_decoded = sprintf( '%s: Decoded Steady State Error Improvement %s', subnetwork_name, title_tag );

            % Create the first subplot.
            subplot( 2, 1, 1 ), hold on, grid on, xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), title( subplot_title_encoded )
            gobj_patch_encoded = patch( scale_encoded*xs_patch_encoded, scale_encoded*ys_patch_encoded, color_encoded, 'FaceAlpha', 0.5, 'EdgeColor', 'None' );
            gobj_plot_encoded = plot( scale_encoded*xs_encoded, scale_encoded*es_mean_encoded, '-', 'Color', color_encoded, 'Linewidth', 3 );
            plot( scale_encoded*xs_encoded, scale_encoded*es_min_encoded, '--', 'Color', color_encoded, 'Linewidth', 1 )
            plot( scale_encoded*xs_encoded, scale_encoded*es_max_encoded, '--', 'Color', color_encoded, 'Linewidth', 1 )
            legend( [ gobj_plot_encoded, gobj_patch_encoded ], { 'Average', 'Range' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
            
            % Create the second subplot.
            subplot( 2, 1, 2 ), hold on, grid on, xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), title( subplot_title_decoded )
            gobj_patch_decoded = patch( scale_decoded*xs_patch_decoded, scale_decoded*ys_patch_decoded, color_decoded, 'FaceAlpha', 0.5, 'EdgeColor', 'None' );
            gobj_plot_decoded = plot( scale_decoded*xs_decoded, scale_decoded*es_mean_decoded, '-', 'Color', color_decoded, 'Linewidth', 3 );
            plot( scale_decoded*xs_decoded, scale_decoded*es_min_decoded, '--', 'Color', color_decoded, 'Linewidth', 1 )
            plot( scale_decoded*xs_decoded, scale_decoded*es_max_decoded, '--', 'Color', color_decoded, 'Linewidth', 1 )
           legend( [ gobj_plot_decoded, gobj_patch_decoded ], { 'Average', 'Range' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
 
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_ssei_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the steady state error of a subnetwork for a specific gain, including upper and lower boundaries.
        function fig = surf_steady_state_error_improvement_patch_comparison( self, Xs_encoded, Ys_encoded, Es_encoded, Es_lower_encoded, Es_upper_encoded, color_encoded, Xs_decoded, Ys_decoded, Es_decoded, Es_lower_decoded, Es_upper_decoded, color_decoded, scale_encoded, scale_decoded, viewing_angle, subnetwork_name, variables_string_encoded, variables_string_decoded, units_string_encoded, units_string_decoded, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 25, save_tag = ''; end
            if nargin < 24, save_directory = './'; end
            if nargin < 23, save_flag = true; end
            if nargin < 22, title_tag = ''; end
            if nargin < 21, units_string_decoded = { '-', '-', '-' }; end
            if nargin < 20, units_string_encoded = { '-', 'mV', 'mV' }; end
            if nargin < 19, variables_string_decoded = { 'c1', 'x1', 'dE' }; end
            if nargin < 18, variables_string_encoded = { 'c1', 'U1', 'dE' }; end
            if nargin < 17, subnetwork_name = 'Transmission'; end
            if nargin < 16, viewing_angle = [ 145, 15 ]; end
            if nargin < 15, scale_decoded = 1; end
            if nargin < 14, scale_encoded = 1; end
                        
            % Generate the patch data.
            [ ps_patch_xlower_encoded, ps_patch_xupper_encoded, ps_patch_ylower_encoded, ps_patch_yupper_encoded, ps_patch_zlower_encoded, ps_patch_zupper_encoded ] = self.generate_3D_patch_data( Xs_encoded, Ys_encoded, Es_lower_encoded, Es_upper_encoded );
            [ ps_patch_xlower_decoded, ps_patch_xupper_decoded, ps_patch_ylower_decoded, ps_patch_yupper_decoded, ps_patch_zlower_decoded, ps_patch_zupper_decoded ] = self.generate_3D_patch_data( Xs_decoded, Ys_decoded, Es_lower_decoded, Es_upper_decoded );

            % Create the figure title.
            title_string = sprintf( '%s: Steady State Error Improvement %s', subnetwork_name, title_tag );
            
            % Create the figure labels.
            xlabel_string_encoded = sprintf( 'Parameter, %s [%s]', variables_string_encoded{ 1 }, units_string_encoded{ 1 } );
            ylabel_string_encoded = sprintf( 'Encoded Input, %s [%s]', variables_string_encoded{ 2 }, units_string_encoded{ 2 } );
            zlabel_string_encoded = sprintf( 'Encoded Error Improvement, %s [%s]', variables_string_encoded{ 3 }, units_string_encoded{ 3 } );
                        
            xlabel_string_decoded = sprintf( 'Parameter, %s [%s]', variables_string_decoded{ 1 }, units_string_decoded{ 1 } );
            ylabel_string_decoded = sprintf( 'Decoded Input, %s [%s]', variables_string_decoded{ 2 }, units_string_decoded{ 2 } );
            zlabel_string_decoded = sprintf( 'Decoded Error Improvement, %s [%s]', variables_string_decoded{ 3 }, units_string_decoded{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
                        
            % Create the subplot titles.
            subplot_title_encoded = sprintf( '%s: Encoded Steady State Error Improvement %s', subnetwork_name, title_tag );
            subplot_title_decoded = sprintf( '%s: Decoded Steady State Error Improvement %s', subnetwork_name, title_tag );

            % Create the first subplot.
            subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_encoded ), ylabel( ylabel_string_encoded ), zlabel( zlabel_string_encoded ), title( subplot_title_encoded )            
            gobj_surf_encoded = surf( Xs_encoded, scale_encoded*Ys_encoded, scale_encoded*Es_encoded, 'Edgecolor', 'None', 'Facecolor', color_encoded, 'Facealpha', 0.90 );
            gobj_patch_encoded = patch( ps_patch_xlower_encoded( :, 1 ), scale_encoded*ps_patch_xlower_encoded( :, 2 ), scale_encoded*ps_patch_xlower_encoded( :, 3 ), color_encoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
            patch( ps_patch_xupper_encoded( :, 1 ), scale_encoded*ps_patch_xupper_encoded( :, 2 ), scale_encoded*ps_patch_xupper_encoded( :, 3 ), color_encoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_ylower_encoded( :, 1 ), scale_encoded*ps_patch_ylower_encoded( :, 2 ), scale_encoded*ps_patch_ylower_encoded( :, 3 ), color_encoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_yupper_encoded( :, 1 ), scale_encoded*ps_patch_yupper_encoded( :, 2 ), scale_encoded*ps_patch_yupper_encoded( :, 3 ), color_encoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zlower_encoded( :, 1 ), scale_encoded*ps_patch_zlower_encoded( :, 2 ), scale_encoded*ps_patch_zlower_encoded( :, 3 ), color_encoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zupper_encoded( :, 1 ), scale_encoded*ps_patch_zupper_encoded( :, 2 ), scale_encoded*ps_patch_zupper_encoded( :, 3 ), color_encoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            legend( [ gobj_surf_encoded, gobj_patch_encoded ], { 'Average', 'Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
            % Create the second subplot.
            subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string_decoded ), ylabel( ylabel_string_decoded ), zlabel( zlabel_string_decoded ), title( subplot_title_decoded )            
            gobj_surf_decoded = surf( Xs_decoded, scale_decoded*Ys_decoded, scale_decoded*Es_decoded, 'Edgecolor', 'None', 'Facecolor', color_decoded, 'Facealpha', 0.90 );
            gobj_patch_decoded = patch( ps_patch_xlower_decoded( :, 1 ), scale_decoded*ps_patch_xlower_decoded( :, 2 ), scale_decoded*ps_patch_xlower_decoded( :, 3 ), color_decoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' );
            patch( ps_patch_xupper_decoded( :, 1 ), scale_decoded*ps_patch_xupper_decoded( :, 2 ), scale_decoded*ps_patch_xupper_decoded( :, 3 ), color_decoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_ylower_decoded( :, 1 ), scale_decoded*ps_patch_ylower_decoded( :, 2 ), scale_decoded*ps_patch_ylower_decoded( :, 3 ), color_decoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_yupper_decoded( :, 1 ), scale_decoded*ps_patch_yupper_decoded( :, 2 ), scale_decoded*ps_patch_yupper_decoded( :, 3 ), color_decoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zlower_decoded( :, 1 ), scale_decoded*ps_patch_zlower_decoded( :, 2 ), scale_decoded*ps_patch_zlower_decoded( :, 3 ), color_decoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zupper_decoded( :, 1 ), scale_decoded*ps_patch_zupper_decoded( :, 2 ), scale_decoded*ps_patch_zupper_decoded( :, 3 ), color_decoded, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            legend( [ gobj_surf_decoded, gobj_patch_decoded ], { 'Average', 'Range' }, 'Location', 'Best', 'Orientation', 'Vertical' )
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_ssei_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        
        %% Steady State Error Percentage Plotting Functions.

        
        %{
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
        
        
        %{
%         % Implement a function to plot the steady state error difference of a subnetwork for a specific gain.
%         function fig = plot_steady_state_error_difference( ~, xs_theoretical, error_difference_theoretical, xs_numerical, error_difference_numerical, scale, subnetwork_name, encoded_string, input_variable_string, output_variable_string, unit, save_flag, save_directory )
%             
%             % Set the default input arguments.
%             if nargin < 13, save_directory = './'; end
%             if nargin < 12, save_flag = true; end
%             if nargin < 11, unit = 'mV'; end
%             if nargin < 10, output_variable_string = 'dU'; end
%             if nargin < 9, input_variable_string = 'U1'; end
%             if nargin < 8, encoded_string = 'Encoded'; end
%             if nargin < 7, subnetwork_name = 'Transmission'; end
%             if nargin < 6, scale = 1; end
%             
%             % Compute the figure labels.
%             title_string = sprintf( '%s: %s Steady State Error Difference', subnetwork_name, encoded_string );
%             xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
%             ylabel_string = sprintf( '%s Error Difference, %s [%s]', encoded_string, output_variable_string, unit );
% 
%             % Create the figure.
%             fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, xlabel( xlabel_string ), ylabel( ylabel_string ), title( title_string )
%             
%             % Plot the absolute and relative theoretical and numerical errors.
%             plot( scale*xs_theoretical, scale*error_difference_theoretical, '-.', 'Linewidth', 3 )
%             plot( scale*xs_numerical, scale*error_difference_numerical, '--', 'Linewidth', 3 )
%             
%             % Add a legend to the figure.
%             legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal')
%             
%             % Determine whether to save the figure.
%             if save_flag                            % If we want to save the figure...
%                     
%                 % Define the file name.
%                 file_name = sprintf( '%s_%s_steady_state_error_difference.png', lower( subnetwork_name ), lower( encoded_string ) );
%                 
%                 % Save the figure.
%                 saveas( fig, [ save_directory, '\', file_name ] ) 
%             
%             end
%             
%         end
        %}
        
        
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
        %}
     
        
        %% Maximum RK4 Step Size Plotting Functions.
        
        % Implement a function to plot the maximum RK4 step size for a specific gain.
        function fig = plot_max_rk4_step_size( ~ )
            
            fig = [  ];
            
        end
        
        
        % Implement a function to create a surface plot of the maximum RK4 step size over the gain parameters.
        function fig = surf_max_rk4_step_size( ~, Xs, Ys, dTs, color, scale, viewing_angle, subnetwork_name, encoding_scheme, variables_string, units_string, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 15, save_tag = ''; end
            if nargin < 14, save_directory = './'; end
            if nargin < 13, save_flag = true; end
            if nargin < 12, title_tag = ''; end
            if nargin < 11, units_string = { '-', '-', 'ms' }; end
            if nargin < 10, variables_string = { 'c1', 'c2', 'dT' }; end
            if nargin < 9, encoding_scheme = 'Absolute'; end
            if nargin < 8, subnetwork_name = 'Transmission'; end
            if nargin < 7, viewing_angle = [ 145, 15 ]; end
            if nargin < 6, scale = 1e3; end
            if nargin < 5, color = [ 0.0000, 0.4470, 0.7410 ]; end

            % Create the figure title.
            title_string = sprintf( '%s: %s Maximum RK4 Step Size %s', subnetwork_name, encoding_scheme, title_tag );

            % Create the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 2 }, units_string{ 2 } );
            zlabel_string = sprintf( 'Maximum RK4 Step Size, %s [%s]', variables_string{ 3 }, units_string{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, rotate3d on, view( viewing_angle), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string), title( title_string )
            
            % Plot the surface.
            surf( Xs, Ys, scale*dTs, 'Edgecolor', 'None', 'Facecolor', color, 'Facealpha', 0.90 );
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_max_rk4_step_size_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), lower( save_tag ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the maximum RK4 step size of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = surf_max_rk4_step_size_patch( self, Xs, Ys, dTs, dTs_lower, dTs_upper, color, scale, viewing_angle, subnetwork_name, encoding_scheme, variables_string, units_string, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 17, save_tag = ''; end
            if nargin < 16, save_directory = './'; end
            if nargin < 15, save_flag = true; end
            if nargin < 14, title_tag = ''; end
            if nargin < 13, units_string = { '-', '-', 'ms' }; end
            if nargin < 12, variables_string = { 'c1', 'c3', 'dT' }; end
            if nargin < 11, encoding_scheme = 'Absolute'; end
            if nargin < 10, subnetwork_name = 'Transmission'; end
            if nargin < 9, viewing_angle = [ 145, 15 ]; end
            if nargin < 8, scale = 1e3; end
            if nargin < 7, color = [ 0.0000, 0.4470, 0.7410 ]; end
            
            % Generate the patch data.
            [ ps_patch_xlower, ps_patch_xupper, ps_patch_ylower, ps_patch_yupper, ps_patch_zlower, ps_patch_zupper ] = self.generate_3D_patch_data( Xs, Ys, dTs_lower, dTs_upper );
            
            % Create the figure title.
            title_string = sprintf( '%s %s: Maximum RK4 Step Size %s', encoding_scheme, subnetwork_name, title_tag );
            
            % Compute the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 2 }, units_string{ 2 } );
            zlabel_string = sprintf( 'Max RK4 Step Size, %s [%s]', variables_string{ 3 }, units_string{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )
                        
            % Plot the surface data.
            surf( Xs, Ys, scale*dTs, 'Edgecolor', 'None', 'Facecolor', color, 'Facealpha', 0.90 )
            
            % Plot the patches.
            patch( ps_patch_xlower( :, 1 ), ps_patch_xlower( :, 2 ), scale*ps_patch_xlower( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_xupper( :, 1 ), ps_patch_xupper( :, 2 ), scale*ps_patch_xupper( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_ylower( :, 1 ), ps_patch_ylower( :, 2 ), scale*ps_patch_ylower( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_yupper( :, 1 ), ps_patch_yupper( :, 2 ), scale*ps_patch_yupper( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zlower( :, 1 ), ps_patch_zlower( :, 2 ), scale*ps_patch_zlower( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zupper( :, 1 ), ps_patch_zupper( :, 2 ), scale*ps_patch_zupper( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                        
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_max_rk4_step_size_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        %{
        % Implement a function to plot a comparison of the absolute & relative maximum RK4 step size for a specific gain.
        function fig = plot_max_rk4_step_size_comparison( ~, xs_absolute, dts_absolute, color_absolute, xs_relative, dts_relative, color_relative, scale, subnetwork_name, encoded_string, input_variable_string, unit, save_flag, save_directory )
        
            % Set the default input arguments.
            if nargin < 14, save_directory = './'; end
            if nargin < 13, save_flag = true; end
            if nargin < 12, unit = 'mV'; end
            if nargin < 11, input_variable_string = 'U1'; end
            if nargin < 10, encoded_string = 'Encoded'; end
            if nargin < 9, subnetwork_name = 'Transmission'; end
            if nargin < 8, scale = 1; end
            
            % Compute the figure labels.
            title_string = sprintf( '%s: %s Maximum RK4 Step Size', subnetwork_name, encoded_string );
            xlabel_string = sprintf( '%s Input, %s [%s]', encoded_string, input_variable_string, unit );
            ylabel_string = sprintf( 'Maximum RK4 Step Size, dt [s]' );

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
                file_name = sprintf( '%s_%s_max_rk4_step_size_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), lower( save_tag ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        %}
        
        
        % Implement a function to create a surface plot of the maximum RK4 step size over the gain parameters.
        function fig = surf_max_rk4_step_size_comparison( ~, Xs, Ys, dTs_absolute, dTs_relative, color_absolute, color_relative, scale, viewing_angle, subnetwork_name, variables_string, units_string, title_tag, compact_flag, save_flag, save_directory, save_tag )
          
            % Set the default input arguments.
            if nargin < 17, save_tag = ''; end
            if nargin < 16, save_directory = './'; end
            if nargin < 15, save_flag = true; end
            if nargin < 14, compact_flag = true; end
            if nargin < 13, title_tag = ''; end
            if nargin < 12, units_string = { '-', '-', 'ms' }; end
            if nargin < 11, variables_string = { 'c1', 'c2', 'dT' }; end
            if nargin < 10, subnetwork_name = 'Transmission'; end
            if nargin < 9, viewing_angle = [ 145, 15 ]; end
            if nargin < 8, scale = 1e3; end
            if nargin < 7, color_relative = [ 0.8500, 0.3250, 0.0980 ]; end
            if nargin < 6, color_absolute = [ 0.0000, 0.4470, 0.7410 ]; end

            % Create the figure title.
            title_string = sprintf( '%s: Maximum RK4 Step Size Comparison %s', subnetwork_name, title_tag );

            % Create the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 2 }, units_string{ 2 } );
            zlabel_string = sprintf( 'Maximum RK4 Step Size, %s [%s]', variables_string{ 3 }, units_string{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine how to organize the plots.
            if compact_flag             % If we want to make a compact plot...
                
                % Format the figure.
                hold on, grid on, rotate3d on, view( viewing_angle), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string), title( title_string )
            
                % Plot the surface.
                surf( Xs, Ys, scale*dTs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );
                surf( Xs, Ys, scale*dTs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                
                % Create a legend.
                legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            else                        % Otherwise...
                
                % Create the subplot titles.
                subplot_title_absolute = sprintf( 'Absolute %s: Maximum RK4 Step Size %s', subnetwork_name, title_tag );
                subplot_title_relative = sprintf( 'Relative %s: Maximum RK4 Step Size %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string), title( subplot_title_absolute )
                surf( Xs, Ys, scale*dTs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );

                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string), title( subplot_title_relative )
                surf( Xs, Ys, scale*dTs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                
            end
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_max_rk4_step_size_comparison_%s.png', lower( subnetwork_name ), lower( save_tag ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the maximum RK4 step size of a subnetwork for a specific gain, including upper and lower boundaries.
        function fig = surf_max_rk4_step_size_patch_comparison( self, Xs_absolute, Ys_absolute, dTs_absolute, dTs_lower_absolute, dTs_upper_absolute, color_absolute, Xs_relative, Ys_relative, dTs_relative, dTs_lower_relative, dTs_upper_relative, color_relative, scale, viewing_angle, subnetwork_name, variables_string, units_string, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 23, save_tag = ''; end
            if nargin < 22, save_directory = './'; end
            if nargin < 21, save_flag = true; end
            if nargin < 20, compact_flag = truel; end
            if nargin < 19, title_tag = ''; end
            if nargin < 18, units_string = { '-', '-', 'ms' }; end
            if nargin < 17, variables_string = { 'c1', 'c3', 'dT' }; end
            if nargin < 16, subnetwork_name = 'Transmission'; end
            if nargin < 15, viewing_angle = [ 145, 15 ]; end
            if nargin < 14, scale = 1e3; end
                        
            % Generate the patch data.
            [ ps_patch_xlower_absolute, ps_patch_xupper_absolute, ps_patch_ylower_absolute, ps_patch_yupper_absolute, ps_patch_zlower_absolute, ps_patch_zupper_absolute ] = self.generate_3D_patch_data( Xs_absolute, Ys_absolute, dTs_lower_absolute, dTs_upper_absolute );
            [ ps_patch_xlower_relative, ps_patch_xupper_relative, ps_patch_ylower_relative, ps_patch_yupper_relative, ps_patch_zlower_relative, ps_patch_zupper_relative ] = self.generate_3D_patch_data( Xs_relative, Ys_relative, dTs_lower_relative, dTs_upper_relative );

            % Create the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: Maximum RK4 Step Size %s', subnetwork_name, title_tag );
            
            % Create the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 2 }, units_string{ 2 } );
            zlabel_string = sprintf( 'Maximum RK4 Step Size, %s [%s]', variables_string{ 3 }, units_string{ 3 } );
                        
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to create a compact plot.
            if compact_flag                 % If we want to create a compact plot...
                
                % Format the figure.
                hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )            

                % Plot the absolute steady state error data.
                surf( Xs_absolute, Ys_absolute, scale*dTs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_absolute( :, 1 ), ps_patch_xlower_absolute( :, 2 ), scale*ps_patch_xlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_absolute( :, 1 ), ps_patch_xupper_absolute( :, 2 ), scale*ps_patch_xupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute( :, 1 ), ps_patch_ylower_absolute( :, 2 ), scale*ps_patch_ylower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute( :, 1 ), ps_patch_yupper_absolute( :, 2 ), scale*ps_patch_yupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute( :, 1 ), ps_patch_zlower_absolute( :, 2 ), scale*ps_patch_zlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute( :, 1 ), ps_patch_zupper_absolute( :, 2 ), scale*ps_patch_zupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                % Plot the relative steady state error data.
                surf( Xs_relative, Ys_relative, scale*dTs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_relative( :, 1 ), ps_patch_xlower_relative( :, 2 ), scale*ps_patch_xlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_relative( :, 1 ), ps_patch_xupper_relative( :, 2 ), scale*ps_patch_xupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative( :, 1 ), ps_patch_ylower_relative( :, 2 ), scale*ps_patch_ylower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative( :, 1 ), ps_patch_yupper_relative( :, 2 ), scale*ps_patch_yupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative( :, 1 ), ps_patch_zlower_relative( :, 2 ), scale*ps_patch_zlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative( :, 1 ), ps_patch_zupper_relative( :, 2 ), scale*ps_patch_zupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
            else                            % Otherwise...
            
                % Create the subplot titles.
                subplot_title_absolute = sprintf( 'Absolute %s: Maximum RK4 Step Size %s', subnetwork_name, title_tag );
                subplot_title_relative = sprintf( 'Relative %s: Maximum RK4 Step Size %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title_absolute )            
                surf( Xs_absolute, Ys_absolute, scale*dTs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_absolute( :, 1 ), ps_patch_xlower_absolute( :, 2 ), scale*ps_patch_xlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_absolute( :, 1 ), ps_patch_xupper_absolute( :, 2 ), scale*ps_patch_xupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute( :, 1 ), ps_patch_ylower_absolute( :, 2 ), scale*ps_patch_ylower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute( :, 1 ), ps_patch_yupper_absolute( :, 2 ), scale*ps_patch_yupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute( :, 1 ), ps_patch_zlower_absolute( :, 2 ), scale*ps_patch_zlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute( :, 1 ), ps_patch_zupper_absolute( :, 2 ), scale*ps_patch_zupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title_relative )            
                surf( Xs_relative, Ys_relative, scale*dTs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_relative( :, 1 ), ps_patch_xlower_relative( :, 2 ), scale*ps_patch_xlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_relative( :, 1 ), ps_patch_xupper_relative( :, 2 ), scale*ps_patch_xupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative( :, 1 ), ps_patch_ylower_relative( :, 2 ), scale*ps_patch_ylower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative( :, 1 ), ps_patch_yupper_relative( :, 2 ), scale*ps_patch_yupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative( :, 1 ), ps_patch_zlower_relative( :, 2 ), scale*ps_patch_zlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative( :, 1 ), ps_patch_zupper_relative( :, 2 ), scale*ps_patch_zupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
            end
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_max_rk4_step_size_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        %% Condition Number Plotting Functions.
        
        
        %{
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
        %}
        
        
        % Implement a function to create a surface plot of the maximum condition number over the gain parameters.
        function fig = surf_max_condition_number( ~, Xs, Ys, dKs, color, scale, viewing_angle, subnetwork_name, encoding_scheme, variables_string, units_string, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 15, save_tag = ''; end
            if nargin < 14, save_directory = './'; end
            if nargin < 13, save_flag = true; end
            if nargin < 12, title_tag = ''; end
            if nargin < 11, units_string = { '-', '-', '-' }; end
            if nargin < 10, variables_string = { 'c1', 'c2', 'dK' }; end
            if nargin < 9, encoding_scheme = 'Absolute'; end
            if nargin < 8, subnetwork_name = 'Transmission'; end
            if nargin < 7, viewing_angle = [ 145, 15 ]; end
            if nargin < 6, scale = 1; end
            if nargin < 5, color = [ 0.0000, 0.4470, 0.7410 ]; end

            % Create the figure title.
            title_string = sprintf( '%s: %s Maximum Condition Number %s', subnetwork_name, encoding_scheme, title_tag );

            % Create the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 2 }, units_string{ 2 } );
            zlabel_string = sprintf( 'Maximum Condition Number, %s [%s]', variables_string{ 3 }, units_string{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, rotate3d on, view( viewing_angle), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string), title( title_string )
            
            % Plot the surface.
            surf( Xs, Ys, scale*dKs, 'Edgecolor', 'None', 'Facecolor', color, 'Facealpha', 0.90 );
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_max_condition_number_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), lower( save_tag ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the maximum condition number of a subnetwork for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = surf_max_condition_number_patch( self, Xs, Ys, dKs, dKs_lower, dKs_upper, color, scale, viewing_angle, subnetwork_name, encoding_scheme, variables_string, units_string, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 17, save_tag = ''; end
            if nargin < 16, save_directory = './'; end
            if nargin < 15, save_flag = true; end
            if nargin < 14, title_tag = ''; end
            if nargin < 13, units_string = { '-', '-', '-' }; end
            if nargin < 12, variables_string = { 'c1', 'c3', 'K' }; end
            if nargin < 11, encoding_scheme = 'Absolute'; end
            if nargin < 10, subnetwork_name = 'Transmission'; end
            if nargin < 9, viewing_angle = [ 145, 15 ]; end
            if nargin < 8, scale = 1; end
            if nargin < 7, color = [ 0.0000, 0.4470, 0.7410 ]; end
            
            % Generate the patch data.
            [ ps_patch_xlower, ps_patch_xupper, ps_patch_ylower, ps_patch_yupper, ps_patch_zlower, ps_patch_zupper ] = self.generate_3D_patch_data( Xs, Ys, dKs_lower, dKs_upper );
            
            % Create the figure title.
            title_string = sprintf( '%s %s: Maximum Condition Number %s', encoding_scheme, subnetwork_name, title_tag );
            
            % Compute the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 2 }, units_string{ 2 } );
            zlabel_string = sprintf( 'Max Condition Number, %s [%s]', variables_string{ 3 }, units_string{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )
                        
            % Plot the surface data.
            surf( Xs, Ys, scale*dKs, 'Edgecolor', 'None', 'Facecolor', color, 'Facealpha', 0.90 )
            
            % Plot the patches.
            patch( ps_patch_xlower( :, 1 ), ps_patch_xlower( :, 2 ), scale*ps_patch_xlower( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_xupper( :, 1 ), ps_patch_xupper( :, 2 ), scale*ps_patch_xupper( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_ylower( :, 1 ), ps_patch_ylower( :, 2 ), scale*ps_patch_ylower( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_yupper( :, 1 ), ps_patch_yupper( :, 2 ), scale*ps_patch_yupper( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zlower( :, 1 ), ps_patch_zlower( :, 2 ), scale*ps_patch_zlower( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zupper( :, 1 ), ps_patch_zupper( :, 2 ), scale*ps_patch_zupper( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                        
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_max_condition_number_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the maximum condition number over the gain parameters.
        function fig = surf_max_condition_number_comparison( ~, Xs, Ys, dTs_absolute, dTs_relative, color_absolute, color_relative, scale, viewing_angle, subnetwork_name, variables_string, units_string, title_tag, compact_flag, save_flag, save_directory, save_tag )
          
            % Set the default input arguments.
            if nargin < 17, save_tag = ''; end
            if nargin < 16, save_directory = './'; end
            if nargin < 15, save_flag = true; end
            if nargin < 14, compact_flag = true; end
            if nargin < 13, title_tag = ''; end
            if nargin < 12, units_string = { '-', '-', '-' }; end
            if nargin < 11, variables_string = { 'c1', 'c2', 'dK' }; end
            if nargin < 10, subnetwork_name = 'Transmission'; end
            if nargin < 9, viewing_angle = [ 145, 15 ]; end
            if nargin < 8, scale = 1; end
            if nargin < 7, color_relative = [ 0.8500, 0.3250, 0.0980 ]; end
            if nargin < 6, color_absolute = [ 0.0000, 0.4470, 0.7410 ]; end

            % Create the figure title.
            title_string = sprintf( '%s: Maximum Condition Number Comparison %s', subnetwork_name, title_tag );

            % Create the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 2 }, units_string{ 2 } );
            zlabel_string = sprintf( 'Maximum Condition Number, %s [%s]', variables_string{ 3 }, units_string{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine how to organize the plots.
            if compact_flag             % If we want to make a compact plot...
                
                % Format the figure.
                hold on, grid on, rotate3d on, view( viewing_angle), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string), title( title_string )
            
                % Plot the surface.
                surf( Xs, Ys, scale*dTs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );
                surf( Xs, Ys, scale*dTs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                
                % Create a legend.
                legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            else                        % Otherwise...
                
                % Create the subplot titles.
                subplot_title_absolute = sprintf( 'Absolute %s: Maximum Condition Number %s', subnetwork_name, title_tag );
                subplot_title_relative = sprintf( 'Relative %s: Maximum Condition Number %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string), title( subplot_title_absolute )
                surf( Xs, Ys, scale*dTs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );

                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string), title( subplot_title_relative )
                surf( Xs, Ys, scale*dTs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                
            end
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_max_condition_number_comparison_%s.png', lower( subnetwork_name ), lower( save_tag ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of the maximum condition number of a subnetwork for a specific gain, including upper and lower boundaries.
        function fig = surf_max_condition_number_patch_comparison( self, Xs_absolute, Ys_absolute, dKs_absolute, dKs_lower_absolute, dKs_upper_absolute, color_absolute, Xs_relative, Ys_relative, dKs_relative, dKs_lower_relative, dKs_upper_relative, color_relative, scale, viewing_angle, subnetwork_name, variables_string, units_string, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 23, save_tag = ''; end
            if nargin < 22, save_directory = './'; end
            if nargin < 21, save_flag = true; end
            if nargin < 20, compact_flag = truel; end
            if nargin < 19, title_tag = ''; end
            if nargin < 18, units_string = { '-', '-', '-' }; end
            if nargin < 17, variables_string = { 'c1', 'c3', 'dK' }; end
            if nargin < 16, subnetwork_name = 'Transmission'; end
            if nargin < 15, viewing_angle = [ 145, 15 ]; end
            if nargin < 14, scale = 1; end
                        
            % Generate the patch data.
            [ ps_patch_xlower_absolute, ps_patch_xupper_absolute, ps_patch_ylower_absolute, ps_patch_yupper_absolute, ps_patch_zlower_absolute, ps_patch_zupper_absolute ] = self.generate_3D_patch_data( Xs_absolute, Ys_absolute, dKs_lower_absolute, dKs_upper_absolute );
            [ ps_patch_xlower_relative, ps_patch_xupper_relative, ps_patch_ylower_relative, ps_patch_yupper_relative, ps_patch_zlower_relative, ps_patch_zupper_relative ] = self.generate_3D_patch_data( Xs_relative, Ys_relative, dKs_lower_relative, dKs_upper_relative );

            % Create the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: Maximum Condition Number %s', subnetwork_name, title_tag );
            
            % Create the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 2 }, units_string{ 2 } );
            zlabel_string = sprintf( 'Maximum Condition Number, %s [%s]', variables_string{ 3 }, units_string{ 3 } );
                        
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to create a compact plot.
            if compact_flag                 % If we want to create a compact plot...
                
                % Format the figure.
                hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )            

                % Plot the absolute steady state error data.
                surf( Xs_absolute, Ys_absolute, scale*dKs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_absolute( :, 1 ), ps_patch_xlower_absolute( :, 2 ), scale*ps_patch_xlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_absolute( :, 1 ), ps_patch_xupper_absolute( :, 2 ), scale*ps_patch_xupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute( :, 1 ), ps_patch_ylower_absolute( :, 2 ), scale*ps_patch_ylower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute( :, 1 ), ps_patch_yupper_absolute( :, 2 ), scale*ps_patch_yupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute( :, 1 ), ps_patch_zlower_absolute( :, 2 ), scale*ps_patch_zlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute( :, 1 ), ps_patch_zupper_absolute( :, 2 ), scale*ps_patch_zupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                % Plot the relative steady state error data.
                surf( Xs_relative, Ys_relative, scale*dKs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_relative( :, 1 ), ps_patch_xlower_relative( :, 2 ), scale*ps_patch_xlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_relative( :, 1 ), ps_patch_xupper_relative( :, 2 ), scale*ps_patch_xupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative( :, 1 ), ps_patch_ylower_relative( :, 2 ), scale*ps_patch_ylower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative( :, 1 ), ps_patch_yupper_relative( :, 2 ), scale*ps_patch_yupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative( :, 1 ), ps_patch_zlower_relative( :, 2 ), scale*ps_patch_zlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative( :, 1 ), ps_patch_zupper_relative( :, 2 ), scale*ps_patch_zupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
            else                            % Otherwise...
            
                % Create the subplot titles.
                subplot_title_absolute = sprintf( 'Absolute %s: Maximum Condition Number %s', subnetwork_name, title_tag );
                subplot_title_relative = sprintf( 'Relative %s: Maximum Condition Number %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title_absolute )            
                surf( Xs_absolute, Ys_absolute, scale*dKs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_absolute( :, 1 ), ps_patch_xlower_absolute( :, 2 ), scale*ps_patch_xlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_absolute( :, 1 ), ps_patch_xupper_absolute( :, 2 ), scale*ps_patch_xupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute( :, 1 ), ps_patch_ylower_absolute( :, 2 ), scale*ps_patch_ylower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute( :, 1 ), ps_patch_yupper_absolute( :, 2 ), scale*ps_patch_yupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute( :, 1 ), ps_patch_zlower_absolute( :, 2 ), scale*ps_patch_zlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute( :, 1 ), ps_patch_zupper_absolute( :, 2 ), scale*ps_patch_zupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title_relative )            
                surf( Xs_relative, Ys_relative, scale*dKs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_relative( :, 1 ), ps_patch_xlower_relative( :, 2 ), scale*ps_patch_xlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_relative( :, 1 ), ps_patch_xupper_relative( :, 2 ), scale*ps_patch_xupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative( :, 1 ), ps_patch_ylower_relative( :, 2 ), scale*ps_patch_ylower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative( :, 1 ), ps_patch_yupper_relative( :, 2 ), scale*ps_patch_yupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative( :, 1 ), ps_patch_zlower_relative( :, 2 ), scale*ps_patch_zlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative( :, 1 ), ps_patch_zupper_relative( :, 2 ), scale*ps_patch_zupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
            end
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_max_condition_number_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        %% Parameter Plotting Functions.

        % Implement a function to create a surface plot of specific network parameters over the formulation parameters.
        function fig = surf_network_parameters( ~, Xs, Ys, Zs, color, scale, viewing_angle, subnetwork_name, encoding_scheme, variables_string, units_string, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 15, save_tag = ''; end
            if nargin < 14, save_directory = './'; end
            if nargin < 13, save_flag = true; end
            if nargin < 12, title_tag = ''; end
            if nargin < 11, units_string = { '-', '-', '-' }; end
            if nargin < 10, variables_string = { 'c1', 'c2', 'x' }; end
            if nargin < 9, encoding_scheme = 'Absolute'; end
            if nargin < 8, subnetwork_name = 'Transmission'; end
            if nargin < 7, viewing_angle = [ 145, 15 ]; end
            if nargin < 6, scale = 1; end
            if nargin < 5, color = [ 0.0000, 0.4470, 0.7410 ]; end

            % Create the figure title.
            title_string = sprintf( '%s: %s Parameter %s %s', subnetwork_name, encoding_scheme, variables_string{ 3 }, title_tag );

            % Create the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 2 }, units_string{ 2 } );
            zlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 3 }, units_string{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, rotate3d on, view( viewing_angle), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string), title( title_string )
            
            % Plot the surface.
            surf( Xs, Ys, scale*Zs, 'Edgecolor', 'None', 'Facecolor', color, 'Facealpha', 0.90 );
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_parameter_%s_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), variables_string{ 3 }, lower( save_tag ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of specific network parameters for a specific encoding scheme and gain, including upper and lower boundaries.
        function fig = surf_network_parameters_patch( self, Xs, Ys, Zs, Zs_lower, Zs_upper, color, scale, viewing_angle, subnetwork_name, encoding_scheme, variables_string, units_string, title_tag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 17, save_tag = ''; end
            if nargin < 16, save_directory = './'; end
            if nargin < 15, save_flag = true; end
            if nargin < 14, title_tag = ''; end
            if nargin < 13, units_string = { '-', '-', '-' }; end
            if nargin < 12, variables_string = { 'c1', 'c3', 'K' }; end
            if nargin < 11, encoding_scheme = 'Absolute'; end
            if nargin < 10, subnetwork_name = 'Transmission'; end
            if nargin < 9, viewing_angle = [ 145, 15 ]; end
            if nargin < 8, scale = 1; end
            if nargin < 7, color = [ 0.0000, 0.4470, 0.7410 ]; end
            
            % Generate the patch data.
            [ ps_patch_xlower, ps_patch_xupper, ps_patch_ylower, ps_patch_yupper, ps_patch_zlower, ps_patch_zupper ] = self.generate_3D_patch_data( Xs, Ys, Zs_lower, Zs_upper );
            
            % Create the figure title.
            title_string = sprintf( '%s %s: Parameter %s %s', encoding_scheme, subnetwork_name, variables_string{ 3 }, title_tag );
            
            % Compute the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 2 }, units_string{ 2 } );
            zlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 3 }, units_string{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string ); hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )
                        
            % Plot the surface data.
            surf( Xs, Ys, scale*Zs, 'Edgecolor', 'None', 'Facecolor', color, 'Facealpha', 0.90 )
            
            % Plot the patches.
            patch( ps_patch_xlower( :, 1 ), ps_patch_xlower( :, 2 ), scale*ps_patch_xlower( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_xupper( :, 1 ), ps_patch_xupper( :, 2 ), scale*ps_patch_xupper( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_ylower( :, 1 ), ps_patch_ylower( :, 2 ), scale*ps_patch_ylower( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_yupper( :, 1 ), ps_patch_yupper( :, 2 ), scale*ps_patch_yupper( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zlower( :, 1 ), ps_patch_zlower( :, 2 ), scale*ps_patch_zlower( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
            patch( ps_patch_zupper( :, 1 ), ps_patch_zupper( :, 2 ), scale*ps_patch_zupper( :, 3 ), color, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                        
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_%s_parameter_%s_%s.png', lower( encoding_scheme ), lower( subnetwork_name ), variables_string{ 3 }, save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of specific network parameters over the gain parameters.
        function fig = surf_network_parameters_comparison( ~, Xs, Ys, Zs_absolute, Zs_relative, color_absolute, color_relative, scale, viewing_angle, subnetwork_name, variables_string, units_string, title_tag, compact_flag, save_flag, save_directory, save_tag )
          
            % Set the default input arguments.
            if nargin < 17, save_tag = ''; end
            if nargin < 16, save_directory = './'; end
            if nargin < 15, save_flag = true; end
            if nargin < 14, compact_flag = true; end
            if nargin < 13, title_tag = ''; end
            if nargin < 12, units_string = { '-', '-', '-' }; end
            if nargin < 11, variables_string = { 'c1', 'c2', 'dK' }; end
            if nargin < 10, subnetwork_name = 'Transmission'; end
            if nargin < 9, viewing_angle = [ 145, 15 ]; end
            if nargin < 8, scale = 1; end
            if nargin < 7, color_relative = [ 0.8500, 0.3250, 0.0980 ]; end
            if nargin < 6, color_absolute = [ 0.0000, 0.4470, 0.7410 ]; end

            % Create the figure title.
            title_string = sprintf( '%s: Parameter %s Comparison %s', subnetwork_name, variables_string{ 3 }, title_tag );

            % Create the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 2 }, units_string{ 2 } );
            zlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 3 }, units_string{ 3 } );
            
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine how to organize the plots.
            if compact_flag             % If we want to make a compact plot...
                
                % Format the figure.
                hold on, grid on, rotate3d on, view( viewing_angle), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string), title( title_string )
            
                % Plot the surface.
                surf( Xs, Ys, scale*Zs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );
                surf( Xs, Ys, scale*Zs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                
                % Create a legend.
                legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
                
            else                        % Otherwise...
                
                % Create the subplot titles.
                subplot_title_absolute = sprintf( 'Absolute %s: Parameter %s %s', subnetwork_name, variables_string{ 3 }, title_tag );
                subplot_title_relative = sprintf( 'Relative %s: Parameter %s %s', subnetwork_name, variables_string{ 3 }, title_tag );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string), title( subplot_title_absolute )
                surf( Xs, Ys, scale*Zs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 );

                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string), title( subplot_title_relative )
                surf( Xs, Ys, scale*Zs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 );
                
            end
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_parameter_%s_%s.png', lower( subnetwork_name ), variables_string{ 3 }, lower( save_tag ) );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        % Implement a function to create a surface plot of specific network for a specific gain, including upper and lower boundaries.
        function fig = surf_network_parameters_patch_comparison( self, Xs_absolute, Ys_absolute, dKs_absolute, dKs_lower_absolute, dKs_upper_absolute, color_absolute, Xs_relative, Ys_relative, dKs_relative, dKs_lower_relative, dKs_upper_relative, color_relative, scale, viewing_angle, subnetwork_name, variables_string, units_string, title_tag, compact_flag, save_flag, save_directory, save_tag )
            
            % Set the default input arguments.
            if nargin < 23, save_tag = ''; end
            if nargin < 22, save_directory = './'; end
            if nargin < 21, save_flag = true; end
            if nargin < 20, compact_flag = truel; end
            if nargin < 19, title_tag = ''; end
            if nargin < 18, units_string = { '-', '-', '-' }; end
            if nargin < 17, variables_string = { 'c1', 'c3', 'dK' }; end
            if nargin < 16, subnetwork_name = 'Transmission'; end
            if nargin < 15, viewing_angle = [ 145, 15 ]; end
            if nargin < 14, scale = 1; end
                        
            % Generate the patch data.
            [ ps_patch_xlower_absolute, ps_patch_xupper_absolute, ps_patch_ylower_absolute, ps_patch_yupper_absolute, ps_patch_zlower_absolute, ps_patch_zupper_absolute ] = self.generate_3D_patch_data( Xs_absolute, Ys_absolute, dKs_lower_absolute, dKs_upper_absolute );
            [ ps_patch_xlower_relative, ps_patch_xupper_relative, ps_patch_ylower_relative, ps_patch_yupper_relative, ps_patch_zlower_relative, ps_patch_zupper_relative ] = self.generate_3D_patch_data( Xs_relative, Ys_relative, dKs_lower_relative, dKs_upper_relative );

            % Create the figure title.
            title_string = sprintf( 'Absolute vs Relative %s: Maximum Condition Number %s', subnetwork_name, title_tag );
            
            % Create the figure labels.
            xlabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 1 }, units_string{ 1 } );
            ylabel_string = sprintf( 'Parameter, %s [%s]', variables_string{ 2 }, units_string{ 2 } );
            zlabel_string = sprintf( 'Maximum Condition Number, %s [%s]', variables_string{ 3 }, units_string{ 3 } );
                        
            % Create the figure.
            fig = figure( 'Color', 'w', 'Name', title_string );
            
            % Determine whether to create a compact plot.
            if compact_flag                 % If we want to create a compact plot...
                
                % Format the figure.
                hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( title_string )            

                % Plot the absolute steady state error data.
                surf( Xs_absolute, Ys_absolute, scale*dKs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_absolute( :, 1 ), ps_patch_xlower_absolute( :, 2 ), scale*ps_patch_xlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_absolute( :, 1 ), ps_patch_xupper_absolute( :, 2 ), scale*ps_patch_xupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute( :, 1 ), ps_patch_ylower_absolute( :, 2 ), scale*ps_patch_ylower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute( :, 1 ), ps_patch_yupper_absolute( :, 2 ), scale*ps_patch_yupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute( :, 1 ), ps_patch_zlower_absolute( :, 2 ), scale*ps_patch_zlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute( :, 1 ), ps_patch_zupper_absolute( :, 2 ), scale*ps_patch_zupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                % Plot the relative steady state error data.
                surf( Xs_relative, Ys_relative, scale*dKs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_relative( :, 1 ), ps_patch_xlower_relative( :, 2 ), scale*ps_patch_xlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_relative( :, 1 ), ps_patch_xupper_relative( :, 2 ), scale*ps_patch_xupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative( :, 1 ), ps_patch_ylower_relative( :, 2 ), scale*ps_patch_ylower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative( :, 1 ), ps_patch_yupper_relative( :, 2 ), scale*ps_patch_yupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative( :, 1 ), ps_patch_zlower_relative( :, 2 ), scale*ps_patch_zlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative( :, 1 ), ps_patch_zupper_relative( :, 2 ), scale*ps_patch_zupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
            else                            % Otherwise...
            
                % Create the subplot titles.
                subplot_title_absolute = sprintf( 'Absolute %s: Maximum Condition Number %s', subnetwork_name, title_tag );
                subplot_title_relative = sprintf( 'Relative %s: Maximum Condition Number %s', subnetwork_name, title_tag );

                % Create the first subplot.
                subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title_absolute )            
                surf( Xs_absolute, Ys_absolute, scale*dKs_absolute, 'Edgecolor', 'None', 'Facecolor', color_absolute, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_absolute( :, 1 ), ps_patch_xlower_absolute( :, 2 ), scale*ps_patch_xlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_absolute( :, 1 ), ps_patch_xupper_absolute( :, 2 ), scale*ps_patch_xupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_absolute( :, 1 ), ps_patch_ylower_absolute( :, 2 ), scale*ps_patch_ylower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_absolute( :, 1 ), ps_patch_yupper_absolute( :, 2 ), scale*ps_patch_yupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_absolute( :, 1 ), ps_patch_zlower_absolute( :, 2 ), scale*ps_patch_zlower_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_absolute( :, 1 ), ps_patch_zupper_absolute( :, 2 ), scale*ps_patch_zupper_absolute( :, 3 ), color_absolute, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
                % Create the second subplot.
                subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( viewing_angle ), xlabel( xlabel_string ), ylabel( ylabel_string ), zlabel( zlabel_string ), title( subplot_title_relative )            
                surf( Xs_relative, Ys_relative, scale*dKs_relative, 'Edgecolor', 'None', 'Facecolor', color_relative, 'Facealpha', 0.90 )            
                patch( ps_patch_xlower_relative( :, 1 ), ps_patch_xlower_relative( :, 2 ), scale*ps_patch_xlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_xupper_relative( :, 1 ), ps_patch_xupper_relative( :, 2 ), scale*ps_patch_xupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_ylower_relative( :, 1 ), ps_patch_ylower_relative( :, 2 ), scale*ps_patch_ylower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_yupper_relative( :, 1 ), ps_patch_yupper_relative( :, 2 ), scale*ps_patch_yupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zlower_relative( :, 1 ), ps_patch_zlower_relative( :, 2 ), scale*ps_patch_zlower_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                patch( ps_patch_zupper_relative( :, 1 ), ps_patch_zupper_relative( :, 2 ), scale*ps_patch_zupper_relative( :, 3 ), color_relative, 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
                
            end
            
            % Determine whether to save the figure.
            if save_flag                            % If we want to save the figure...
                    
                % Define the file name.
                file_name = sprintf( '%s_max_condition_number_%s.png', lower( subnetwork_name ), save_tag );
                
                % Save the figure.
                saveas( fig, [ save_directory, '\', file_name ] ) 
            
            end
            
        end
        
        
        
    end
    
    
end
    