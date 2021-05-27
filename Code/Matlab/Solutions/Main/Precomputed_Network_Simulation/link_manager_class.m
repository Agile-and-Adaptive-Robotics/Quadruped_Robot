classdef link_manager_class
    
    % This class contains properties and methods related to managing linkages.
    
    %% LINK MANAGER PROPERTIES
    
    % Define class properties.
    properties
        
        links
        num_links
        
        Ms_cms
        Ts_cms
        Js_cms
        
        Ms_links
        Ts_links
        Js_links
        
        Ms_meshes
        Ts_meshes
        Js_meshes
        
        physics_manager
        
    end
    
    %% LINK MANAGER METHODS SETUP
    
    % Define class methods.
    methods
        
        % Implement the class constructor.
        function self = link_manager_class( links )
                    
            % Create an instance of the physics manager.
            self.physics_manager = physics_manager_class(  );
            
            % Define the default class properties.
            if nargin < 1, self.links = link_class(  ); else, self.links = links; end
        
            % Retrieve the number of links.
            self.num_links = length(self.links);
            
            % Set the home configurations.
            self.Ms_cms = self.get_home_cm_configurations( );
            self.Ms_links = self.get_home_link_configurations( );
            self.Ms_meshes = self.get_home_mesh_configurations( );
            
            % Set the current configurations to be the same as the home configurations.
            self.Ts_cms = self.Ms_cms;
            self.Ts_links = self.Ms_links;
            self.Ts_meshes = self.Ms_meshes;
        
            % Set the link assignments in the standard way.
            self.Js_cms = self.physics_manager.get_standard_joint_assignments( size( self.Ms_cms, 3 ), size( self.Ms_cms, 4 ) );
            self.Js_links = self.physics_manager.get_standard_joint_assignments( size( self.Ms_links, 3 ), size( self.Ms_links, 4 ) );
            self.Js_meshes = self.physics_manager.get_standard_joint_assignments( size( self.Ms_meshes, 3 ), size( self.Ms_meshes, 4 ) );
        
        end
        
        
        %% Link Manager Initialization Functions
        
        % Implement a function to validate the input properties.
        function x = validate_property( self, x, var_name )
            
            % Retrieve the number of dimensions of this variable.
            num_dims = length(size(x));
            
            % Retrieve the length of the final dimension.
            n = size( x, num_dims );
            
            % Define the repetition pattern.
            rep_pattern = ones( 1, n ); rep_pattern(end) = n;
            
            % Set the default variable name.
            if nargin < 3, var_name = 'properties'; end
            
            % Determine whether we need to repeat this property for each object.
            if n ~= self.num_links                % If the number of instances of this property do not agree with the number of objects...
                
                % Determine whether to repeat this property for each object.
                if length(x) == 1                               % If only one property was provided...
                    
                    % Repeat the link property.
                    x = repmat( x, rep_pattern );
                    
                else                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'The number of provided %s must match the number of objects being created.', var_name )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to get the home configurations of the center of masses of the links.
        function Ms_cms = get_home_cm_configurations( self )
            
            % Preallocate the link center of mass configuration matrix.
            Ms_cms = zeros( 4, 4, 1, self.num_links );
            
            % Compute the link center of mass configuration matrix.
            for k = 1:self.num_links                                % Iterate through each of the links...
                
                % Retrieve this link's center of mass configuration matrix.
                Ms_cms( :, :, 1, k ) = self.links(k).M_cm;
                
            end
            
        end
        
        
        % Implement a function to get the home configurations of the link points of the links.
        function Ms_links = get_home_link_configurations( self )
            
            % Define the number of link points.
            num_link_points = 2;
            
            % Preallocate the link points configuration matrix.
            Ms_links = zeros( 4, 4, num_link_points, self.num_links );
            
            % Compute the link points configuration matrix.
            for k1 = 1:self.num_links                                   % Iterate through each of the links...
                for k2 = 1:num_link_points                              % Iterate through each of the link points...
                
                    % Retrieve this link's points configuration matrix.
                    Ms_links( :, :, k2, k1 ) = self.links(k1).Ms_link(:, :, k2);
                
                end
            end
            
        end
        
        
        % Implement a function to get the home configurations of the meshes of the links.
        function Ms_meshes = get_home_mesh_configurations( self )
            
            % Define the number of mesh points.
            num_mesh_points = size( self.links(1).Ms_mesh, 3 );
            
            % Preallocate the mesh points configuration matrix.
            Ms_meshes = zeros( 4, 4, num_mesh_points, self.num_links );
            
            % Compute the mesh points configuration matrix.
            for k1 = 1:self.num_links                                % Iterate through each of the links...
                for k2 = 1:num_mesh_points                          % Iterate through each of the mesh points...
                    
                    % Retrieve this link's points configuration matrix.
                    Ms_meshes( :, :, k2, k1 ) = self.links(k1).Ms_mesh(:, :, k2);
                    
                end
            end
            
        end
            
            
        % Implement a function to initialize an instance of the link manager class using constituent link data.
        function self = initialize_from_link_data( IDs, names, parent_joint_IDs, child_joint_IDs, ps_starts, ps_ends, lens, widths, masses, ps_cms, vs_cms, ws_cms, Rs, mesh_types )
             
            % Define the default class properties.
            if nargin < 14, mesh_types = {''}; end
            if nargin < 13, Rs = eye(3); end
            if nargin < 12, ws_cms = zeros( 3, 1 ); end
            if nargin < 11, vs_cms = zeros( 3, 1 ); end
            if nargin < 10, ps_cms = zeros( 3, 1 ); end
            if nargin < 9, masses = 0; end
            if nargin < 8, widths = 0; end
            if nargin < 7, lens = 0; end
            if nargin < 6, ps_ends = zeros( 3, 1 ); end
            if nargin < 5, ps_starts = zeros( 3, 1 ); end
            if nargin < 4, child_joint_IDs = 0; end
            if nargin < 3, parent_joint_IDs = 0; end
            if nargin < 2, names = {''}; end
            if nargin < 1, IDs = 0; end
            
            % Define the number of links.
            self.num_links = length(IDs);
            
            % Ensure that we have the correct number of properties for each link.
            IDs = self.validate_property( IDs, 'IDs' );
            names = self.validate_property( names, 'names' );
            parent_joint_IDs = self.validate_property( parent_joint_IDs, 'parent_joint_IDs' );
            child_joint_IDs = self.validate_property( child_joint_IDs, 'child_joint_IDs' );
            ps_starts = self.validate_property( ps_starts, 'ps_starts' );
            ps_ends = self.validate_property( ps_ends, 'ps_ends' );
            lens = self.validate_property( lens, 'lens' );
            widths = self.validate_property( widths, 'widths' );
            masses = self.validate_property( masses, 'masses' );
            ps_cms = self.validate_property( ps_cms, 'ps_cms' );
            vs_cms = self.validate_property( vs_cms, 'vs_cms' );
            ws_cms = self.validate_property( ws_cms, 'ws_cms' );
            Rs = self.validate_property( Rs, 'Rs' );
            mesh_types = self.validate_property( mesh_types, 'mesh_types' );
            
            % Preallocate an array of links.
            self.links = repmat( link_class(), 1, self.num_links );
            
            % Create each link object.
            for k = 1:self.num_links               % Iterate through each of the links...
                
                % Create this link.
                self.links(k) = link_class( IDs(k), names{k}, parent_joint_IDs(k), child_joint_IDs(k), ps_starts(:, k), ps_ends(:, k), lens(k), widths(k), masses(k), ps_cms(:, k), vs_cms(:, k), ws_cms(:, k), Rs(:, :, k), mesh_types{k} );
                                
            end
            
            % Set the home configurations.
            self.Ms_cms = self.get_home_cm_configurations( );
            self.Ms_links = self.get_home_link_configurations( );
            self.Ms_meshes = self.get_home_mesh_configurations( );
            
            % Set the current configurations to be the same as the home configurations.
            self.Ts_cms = self.Ms_cms;
            self.Ts_links = self.Ms_links;
            self.Ts_meshes = self.Ms_meshes;
            
            % Set the link assignments in the standard way.
            self.Js_cms = self.physics_manager.get_standard_joint_assignments( size( self.Ms_cms, 3 ), size( self.Ms_cms, 4 ) );
            self.Js_links = self.physics_manager.get_standard_joint_assignments( size( self.Ms_links, 3 ), size( self.Ms_links, 4 ) );
            self.Js_meshes = self.physics_manager.get_standard_joint_assignments( size( self.Ms_meshes, 3 ), size( self.Ms_meshes, 4 ) );

        end
        
        
        %% Link Get & Set Property Functions
        
        % Implement a function to retrieve the index associated with a given link ID.
        function link_index = get_link_index( self, link_ID )
            
            % Set a flag variable to indicate whether a matching link index has been found.
            bMatchFound = false;
            
            % Initialize the link index.
            link_index = 0;
            
            while (link_index < self.num_links) && (~bMatchFound)
                
                % Advance the link index.
                link_index = link_index + 1;
                
                % Check whether this link index is a match.
                if self.links(link_index).ID == link_ID                       % If this link has the correct link ID...
                    
                    % Set the match found flag to true.
                    bMatchFound = true;
                    
                end
                
            end
            
            % Determine whether a match was found.
            if ~bMatchFound                     % If a match was not found...
                
                % Throw an error.
                error('No link with ID %0.0f.', link_ID)
                
            end
            
        end
        
        
        % Implement a function to validate the link IDs.
        function link_IDs = validate_link_IDs( self, link_IDs )
            
            % Determine whether we want get the desired link property from all of the links.
            if isa( link_IDs, 'char' )                                                      % If the link IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmp( link_IDs, 'all' ) || strcmp( link_IDs, 'All' )                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the link IDs.
                    link_IDs = zeros( 1, self.num_links );
                    
                    % Retrieve the link ID associated with each link.
                    for k = 1:self.num_links                   % Iterate through each link...
                        
                        % Store the link ID associated with the current link.
                        link_IDs(k) = self.links(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error('Link_IDs must be either an array of valid link IDs or one of the strings: ''all'' or ''All''.')
                    
                end
                
            end
            
        end
            
        
        % Implement a function to retrieve the properties of specific links.
        function xs = get_link_property( self, link_IDs, link_property )
            
            % Validate the link IDs.
            link_IDs = self.validate_link_IDs( link_IDs );
            
            % Determine how many links to which we are going to apply the given method.
            num_properties_to_get = length(link_IDs);
            
            % Preallocate a variable to store the link properties.
            xs = zeros(1, num_properties_to_get);
            
            % Retrieve the given link property for each link.
            for k = 1:num_properties_to_get
                
                % Retrieve the index associated with this link ID.
                link_index = self.get_link_index( link_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'xs{k} = self.links(%0.0f).%s;', link_index, link_property );
                
                % Evaluate the given link property.
                eval(eval_str);
                
            end
            
        end
        
        
        % Implement a function to set the properties of specific links.
        function self = set_link_property( self, link_IDs, link_property_values, link_property )
            
            % Validate the link IDs.
            link_IDs = self.validate_link_IDs( link_IDs );
            
            % Validate the link property values.
            if ~isa( link_property_values, 'cell' )                    % If the link property values are not a cell array...
               
                % Convert the link property values to a cell array.
                link_property_values = num2cell( link_property_values );
                
            end
            
            % Set the properties of each link.
            for k = 1:self.num_links                   % Iterate through each link...
                
                % Determine the index of the link property value that we want to apply to this link (if we want to set a property of this link).
                index = find(self.links(k).ID == link_IDs, 1);
                
                % Determine whether to set a property of this link.
                if ~isempty(index)                         % If a matching link ID was detected...
                    
                    % Create an evaluation string that sets the desired link property.
                    eval_string = sprintf('self.links(%0.0f).%s = link_property_values{%0.0f};', k, link_property, index);
                    
                    % Evaluate the evaluation string.
                    eval(eval_string);
                    
                end
            end
            
        end
        
         
        %% Link Manager Call Link Methods Function
        
        % Implement a function to that calls a specified link method for each of the specified links.
        function self = call_link_method( self, link_IDs, link_method )
            
            % Validate the link IDs.
            link_IDs = self.validate_link_IDs( link_IDs );
            
            % Determine how many links to which we are going to apply the given method.
            num_links_to_evaluate = length(link_IDs);
            
            % Evaluate the given link method for each link.
            for k = 1:num_links_to_evaluate               % Iterate through each of the links of interest...
                
                % Retrieve the index associated with this link ID.
                link_index = self.get_link_index( link_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'self.links(%0.0f) = self.links(%0.0f).%s();', link_index, link_index, link_method );
                
                % Evaluate the given muscle method.
                eval(eval_str);
                
            end
            
        end
        
        
        %% Plotting Functions
        
        % Implement a function to plot the end points of all of the links.
        function fig = plot_link_end_points( self, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if nargin < 3, plotting_options = {  }; end
            
            % Determine whether we want to add these link end points to an existing plot or create a new plot.
            if nargin < 2
                
                % Create a figure to store the link end points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Link End Points')
                
            end
            
            % Plot the end points of each link.
            for k = 1:self.num_links          % Iterate through each link...
            
                % Plot the end points for this link.
                fig = self.links(k).plot_link_end_points( fig, plotting_options );
            
            end
            
        end
        
        
        % Implement a function to plot the com points of all of the links.
        function fig = plot_link_com_points( self, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if nargin < 3, plotting_options = {  }; end
            
            % Determine whether we want to add these link com points to an existing plot or create a new plot.
            if nargin < 2
                
                % Create a figure to store the link com points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Link COM Points')
                
            end
            
            % Plot the com points of each link.
            for k = 1:self.num_links          % Iterate through each link...
            
                % Plot the com points for this link.
                fig = self.links(k).plot_link_com_point( fig, plotting_options );
            
            end
            
        end
        
        
        % Implement a function to plot the mesh points of all of the links.
        function fig = plot_link_mesh_points( self, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if nargin < 3, plotting_options = {  }; end
            
            % Determine whether we want to add these link mesh points to an existing plot or create a new plot.
            if nargin < 2
                
                % Create a figure to store the link mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Link Mesh Points')
                
            end
            
            % Plot the mesh points of each link.
            for k = 1:self.num_links          % Iterate through each link...
            
                % Plot the mesh points for this link.
                fig = self.links(k).plot_link_mesh_points( fig, plotting_options );
            
            end
            
        end
        
        
        % Implement a function to plot any type of point for all of the links.
        function fig = plot_link_points( self, fig, plotting_options, point_type )
           
            % Set the default types of points to plot.
            if nargin < 4, point_type = 'All'; end
            
            % Determine whether to specify default plotting options.
            if nargin < 3, plotting_options = {  }; end
            
            % Determine whether we want to add these link points to an existing plot or create a new plot.
            if nargin < 2
                
                % Create a figure to store the link points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Link Points')
                
            end
            
            % Plot the points of each link.
            for k = 1:self.num_links          % Iterate through each link...
            
                % Plot the points for this link.
                fig = self.links(k).plot_link_points( fig, plotting_options, point_type );
            
            end
                        
        end
        
        
    end
end

