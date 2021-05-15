classdef data_loader_class
    
    % This class contains properties and methods related to loading simulation data.
    
    
    %% DATA LOADER PROPERTIES
    
    % Define the class properties.
    properties
        
        load_path
        
    end
    
    %% DATA LOADER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = data_loader_class( load_path )
            
            % Set the default class arguments.
            if nargin < 1, self.load_path = '.'; self.load_path = load_path; end
            
        end
        
        
        % Implement a function to load BPA muscle data from a spreadsheet.
        function [ muscle_IDs, muscle_names, desired_tensions, measured_tensions, desired_pressures, measured_pressures, max_pressures, muscle_lengths, resting_muscle_lengths, max_strains, velocities, yanks, c0s, c1s, c2s, c3s, c4s, c5s, c6s, ps, Js ] = load_BPA_muscle_data( self, file_name, directory )

            % Determine whether to set the load directory to be the stored load directory.
            if nargin < 3, directory = self.load_path; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Read in the BPA muscle data.
            data = readcell( full_path, 'NumHeaderLines', 3 );
            
            % Retrieve the number of BPA muscles.
            num_BPA_muscles = size( data, 1 );
            
            % Set the number of attachment points per muscle.
            num_attachment_points = 3;
            
            % Preallocate variables to store the BPA muscle data.
            [ muscle_IDs, desired_tensions, measured_tensions, desired_pressures, measured_pressures, max_pressures, max_strains, muscle_lengths, resting_muscle_lengths, velocities, yanks, c0s, c1s, c2s, c3s, c4s, c5s, c6s ] = deal( zeros( 1, num_BPA_muscles ) );
            muscle_names = cell( 1, num_BPA_muscles );
            ps = zeros( 3, num_attachment_points, num_BPA_muscles );
            Js = zeros( num_BPA_muscles, 3 );
            
            % Retrieve the data for each BPA muscle.
            for k = 1:num_BPA_muscles                   % Iterate through each BPA muscle...
                
                % Set the BPA muscle IDs.
                muscle_IDs(k) = data{k, 1};
                
                % Set the BPA muscle names.
                muscle_names{k} = [ data{k, 2}, ' ', data{k, 3}, ' ', data{k, 4}, ' ', data{k, 5} ];
                
                % Set the BPA muscle tension data.
                desired_tensions(k) = data{k, 6};
                measured_tensions(k) = data{k, 7};

                % Set the BPA muscle pressure data.
                desired_pressures(k) = data{k, 10};
                measured_pressures(k) = data{k, 11};
                max_pressures(k) = data{k, 12};
                
                % Set the BPA muscle strain and length data.
                max_strains(k) = data{k, 13};
                muscle_lengths(k) = data{k, 15};
                resting_muscle_lengths(k) = data{k, 17};
                
                % Set the BPA muscle derived properties (velocity & yank).
                velocities(k) = data{k, 18};
                yanks(k) = data{k, 19};
                
                % Set the BPA muscle constants.
                c0s(k) = data{k, 20};
                c1s(k) = data{k, 21};
                c2s(k) = data{k, 22};
                c3s(k) = data{k, 23};
                c4s(k) = data{k, 24};
                c5s(k) = data{k, 25};
                c6s(k) = data{k, 26};
                
                % Set the BPA muscle attachment points.
                ps( :, :, k ) = [ data{k, 29}, data{k, 36}, data{k, 43};
                                  data{k, 31}, data{k, 38}, data{k, 45};
                                  data{k, 33}, data{k, 40}, data{k, 47} ];
                
                % Set the BPA muscle attachment point joint assignments.
                Js(k, :) = [ data{k, 27}, data{k, 34}, data{k, 41} ];
                
            end
            
        end
        
        
        % Implement a function to load hill muscle data from a spreadsheet.
        function [ muscle_IDs, muscle_names, activations, activation_domains, desired_active_tensions, measured_total_tensions, tension_domains, max_strains, muscle_lengths, resting_muscle_lengths, velocities, yanks, kses, kpes, bs ] = load_hill_muscle_data( self, file_name, directory )

            % Determine whether to set the load directory to be the stored load directory.
            if nargin < 3, directory = self.load_path; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Read in the hill muscle data.
            data = readcell( full_path, 'NumHeaderLines', 3 );
            
            % Retrieve the number of hill muscles.
            num_hill_muscles = size( data, 1 );
            
            % Preallocate variables to store the BPA muscle data.
            [ muscle_IDs, activations, desired_active_tensions, measured_total_tensions, max_strains, muscle_lengths, resting_muscle_lengths, velocities, yanks, kses, kpes, bs ] = deal( zeros( 1, num_hill_muscles ) );
            [ muscle_names, activation_domains, tension_domains ] = deal( cell( 1, num_hill_muscles ) );
            
            % Retrieve the data for each hill muscle.
            for k = 1:num_hill_muscles              % Iterate through each hill muscle...
                
                % Set the hill muscle IDs.
                muscle_IDs(k) = data{ k, 1 };
                
                % Set the hill muscle names.
                muscle_names{k} = [ data{k, 2}, ' ', data{k, 3}, ' ', data{k, 4}, ' ', data{k, 5} ];
                
                % Set the hill muscle activations data.
                activations(k) = data{ k, 6 };
                activation_domains{k} = [ data{ k, 7 }, data{ k, 8 } ];
                
                % Set the hill muscle tension data.
                desired_active_tensions(k) = data{ k, 9 };
                measured_total_tensions(k) = data{ k, 10 };
                tension_domains{k} = [ data{ k, 11 }, data{ k, 12 } ];
                
                % Set the hill muscle length data.
                max_strains(k) = data{ k, 13 };
                muscle_lengths(k) = data{ k, 15 };
                resting_muscle_lengths(k) = data{ k,17  };
                
                % Set the hill muscle derived properties (velocities & yanks).
                velocities(k) = data{ k, 18 };
                yanks(k) = data{ k, 19 };
                
                % Set the hill muscle parameters.
                kses(k) = data{ k, 20 };
                kpes(k) = data{ k, 21 };
                bs(k) = data{ k, 22 };
                
            end
            
        end
        
        
        % Implement a function to load link data from a spreadsheet.
        function [ link_IDs, link_names, link_parent_joint_IDs, link_child_joint_IDs, link_ps_starts, link_ps_ends, link_ps_cms, link_lengths, link_widths, link_masses, link_vs_cms, link_ws_cms, link_mesh_types ] = load_link_data( self, file_name, directory ) 
        
            % Determine whether to set the load directory to be the stored load directory.
            if nargin < 3, directory = self.load_path; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Read in the link data.
            data = readcell( full_path, 'NumHeaderLines', 3 );
            
            % Retrieve the number of links.
            num_links = size( data, 1 );
           
            % Preallocate variables to store the link data. 
            [ link_IDs, link_parent_joint_IDs, link_child_joint_IDs, link_lengths, link_widths, link_masses ] = deal( zeros( 1, num_links ) );
            [ link_ps_starts, link_ps_ends, link_ps_cms, link_vs_cms, link_ws_cms ] = deal( zeros( 3, num_links ) );
            [ link_names, link_mesh_types ] = deal( cell( 1, num_links ) );
            
            % Store the data associated with each link.
            for k = 1:num_links                                 % Iterate through each link...
                
                % Set the link IDs.
                link_IDs(k) = data{ k, 1 };
                
                % Set the link names.
                link_names{k} = [ data{k, 2}, ' ', data{k, 3}, ' ', data{k, 4} ];
                
                % Set the link joint IDs.
                link_parent_joint_IDs(k) = data{ k, 5 };
                link_child_joint_IDs(k) = data{ k, 6 };
                
                % Set the link masses.
                link_masses(k) = data{ k, 7 };
                
                % Set the link lengths and widths.
                link_lengths(k) = data{ k, 9 };
                link_widths(k) = data{ k, 11 };
                
                % Set the link mesh types.
                link_mesh_types{k} = data{ k, 12 };
                
                % Set the link points.
                link_ps_starts(:, k) = [ data{ k, 14 }; data{ k, 16 }; data{ k, 18 } ];
                link_ps_ends(:, k) = [ data{ k, 20 }; data{ k, 22 }; data{ k, 24 } ];
                link_ps_cms(:, k) = [ data{ k, 32 }; data{ k, 34 }; data{ k, 36 } ];
                                
                % Set the link velocities.
                link_vs_cms(:, k) = [ data{ k, 37 }; data{ k, 38 }; data{ k, 39 } ];
                link_ws_cms(:, k) = [ data{ k, 40 }; data{ k, 41 }; data{ k, 42 } ];
                
            end
            
        end
        
        
        % Implement a function to load joint data from a spreadsheet.
        function [ joint_IDs, joint_names, joint_parent_link_IDs, joint_child_link_IDs, joint_ps, joint_vs, joint_ws, joint_w_screws, joint_thetas ] = load_joint_data( self, file_name, directory )
            
            % Determine whether to set the load directory to be the stored load directory.
            if nargin < 3, directory = self.load_path; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Read in the link data.
            data = readcell( full_path, 'NumHeaderLines', 3 );
            
            % Retrieve the number of joints.
            num_joints = size( data, 1 );
           
            % Preallocate variables to store the joint data.
            [ joint_IDs, joint_parent_link_IDs, joint_child_link_IDs, joint_thetas ] = deal( zeros( 1, num_joints ) );
            [ joint_ps, joint_vs, joint_ws, joint_w_screws ] = deal( zeros( 3, num_joints ) );
            joint_names = cell( 1, num_joints );

            
            % Store the data associated with each joint.
            for k = 1:num_joints                                 % Iterate through each joint...
                
                % Set the joint IDs.
                joint_IDs(k) = data{ k, 1 };
                
                % Set the joint names.
                joint_names{k} = [ data{ k, 2 }, ' ', data{ k, 3 }, ' ', data{ k, 4 } ];
                
                % Set the joint link IDs.
                joint_parent_link_IDs(k) = data{ k, 5 };
                joint_child_link_IDs(k) = data{ k, 6 };
                
                % Set the joint angle.
                joint_thetas(k) = data{ k, 7 };
                
                % Set the joint points.
                joint_ps(:, k) = [ data{ k, 9 }; data{ k, 11 }; data{ k, 13 } ];
                
                % Set the joint axes of rotation.
                joint_w_screws(:, k) = [ data{ k, 14 }; data{ k, 15 }; data{ k, 16 } ];
                
                % Set the joint velocities.
                joint_vs(:, k) = [ data{ k, 17 }; data{ k, 18 }; data{ k, 19 } ];
                joint_ws(:, k) = [ data{ k, 20 }; data{ k, 21 }; data{ k, 22 } ];   
                
            end
            
            
            

            
            
        end
            
          
            
    end
end

