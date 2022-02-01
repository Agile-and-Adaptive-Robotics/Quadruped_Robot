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
            if nargin < 1, self.load_path = '.'; else, self.load_path = load_path; end
            
        end
        
        
        %% Data Loading Functions
        
        % Implement a function to load BPA muscle data from a spreadsheet.
        function [ muscle_IDs, muscle_names, desired_tensions, measured_tensions, desired_pressures, measured_pressures, max_pressures, muscle_lengths, resting_muscle_lengths, max_strains, velocities, yanks, c0s, c1s, c2s, c3s, c4s, c5s, c6s, ps, Js, muscle_types ] = load_BPA_muscle_data( self, file_name, directory )

            % Determine whether to set the load directory to be the stored load directory.
            if nargin < 3, directory = self.load_path; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Determine how to read in the BPA muscle data.
            if verLessThan( 'matlab', '2019a' )                         % If this Matlab version is older than 2019a...
               
                % Read in the BPA muscle data.
                [ ~, ~, data ] = xlsread( full_path, 'A4:AU27' );
                
            else                                                        % Otherwise...
                
                % Read in the BPA muscle data.
                data = readcell( full_path, 'NumHeaderLines', 3 );

            end
                        
            % Retrieve the number of BPA muscles.
            num_BPA_muscles = size( data, 1 );
            
            % Set the number of attachment points per muscle.
            num_attachment_points = 3;
            
            % Preallocate variables to store the BPA muscle data.
            [ muscle_IDs, desired_tensions, measured_tensions, desired_pressures, measured_pressures, max_pressures, max_strains, muscle_lengths, resting_muscle_lengths, velocities, yanks, c0s, c1s, c2s, c3s, c4s, c5s, c6s ] = deal( zeros( 1, num_BPA_muscles ) );
            [ muscle_names, muscle_types ] = deal( cell( 1, num_BPA_muscles ) );
            ps = zeros( 3, num_attachment_points, num_BPA_muscles );
            Js = zeros( num_attachment_points, num_BPA_muscles );
            
            % Retrieve the data for each BPA muscle.
            for k = 1:num_BPA_muscles                   % Iterate through each BPA muscle...
                
                % Set the BPA muscle IDs.
                muscle_IDs(k) = data{ k, 1 };
                
                % Set the BPA muscle names.
                muscle_names{k} = [ data{ k, 2 }, ' ', data{ k, 3 }, ' ', data{ k, 4 }, ' ', data{ k, 5 } ];
                
                % Retrieve the BPA muscle types.
                muscle_types{k} = data{ k, 5 };
                
                % Set the BPA muscle tension data.
                desired_tensions(k) = data{ k, 6 };
                measured_tensions(k) = data{ k, 7 };

                % Set the BPA muscle pressure data.
                desired_pressures(k) = data{ k, 10 };
                measured_pressures(k) = data{ k, 11 };
                max_pressures(k) = data{ k, 12 };
                
                % Set the BPA muscle strain and length data.
                max_strains(k) = data{ k, 13 };
                muscle_lengths(k) = data{ k, 15 };
                resting_muscle_lengths(k) = data{ k, 17 };
                
                % Set the BPA muscle derived properties (velocity & yank).
                velocities(k) = data{ k, 18 };
                yanks(k) = data{ k, 19 };
                
                % Set the BPA muscle constants.
                c0s(k) = data{ k, 20 };
                c1s(k) = data{ k, 21 };
                c2s(k) = data{ k, 22 };
                c3s(k) = data{ k, 23 };
                c4s(k) = data{ k, 24 };
                c5s(k) = data{ k, 25 };
                c6s(k) = data{ k, 26 };
                
                % Set the BPA muscle attachment points.
                ps( :, :, k ) = [ data{ k, 29 }, data{ k, 36 }, data{ k, 43 };
                                  data{ k, 31 }, data{ k, 38 }, data{ k, 45 };
                                  data{ k, 33 }, data{ k, 40 }, data{ k, 47 } ];
                
                % Set the BPA muscle attachment point joint assignments.
                Js( :, k ) = [ data{ k, 27 };
                               data{ k, 34 };
                               data{ k, 41 } ];
                
            end
            
        end
        
        
        % Implement a function to load hill muscle data from a spreadsheet.
        function [ muscle_IDs, muscle_names, activations, activation_domains, desired_active_tensions, measured_total_tensions, tension_domains, max_strains, muscle_lengths, resting_muscle_lengths, velocities, yanks, kses, kpes, bs ] = load_hill_muscle_data( self, file_name, directory )

            % Determine whether to set the load directory to be the stored load directory.
            if nargin < 3, directory = self.load_path; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Determine how to read in the hill muscle data.
            if verLessThan( 'matlab', '2019a' )                         % If this Matlab version is older than 2019a...
               
                % Read in the hill muscle data.
                [ ~, ~, data ] = xlsread( full_path, 'A4:V27' );
                
            else                                                        % Otherwise...
                
                % Read in the hill muscle data.
                data = readcell( full_path, 'NumHeaderLines', 3 );

            end
            
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
                muscle_names{k} = [ data{ k, 2 }, ' ', data{ k, 3 }, ' ', data{ k, 4 }, ' ', data{ k, 5 } ];
                
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
            
            % Determine how to read in the link data.
            if verLessThan( 'matlab', '2019a' )                         % If this Matlab version is older than 2019a...
               
                % Read in the link data.
                [ ~, ~, data ] = xlsread( full_path, 'A4:AP17' );
                
            else                                                        % Otherwise...
                
                % Read in the link data.
                data = readcell( full_path, 'NumHeaderLines', 3 );

            end
            
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
                link_names{k} = [ data{ k, 2 }, ' ', data{ k, 3 }, ' ', data{ k, 4 } ];
                
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
                link_ps_starts( :, k ) = [ data{ k, 14 }; data{ k, 16 }; data{ k, 18 } ];
                link_ps_ends( :, k ) = [ data{ k, 20 }; data{ k, 22 }; data{ k, 24 } ];
                link_ps_cms( :, k ) = [ data{ k, 32 }; data{ k, 34 }; data{ k, 36 } ];
                                
                % Set the link velocities.
                link_vs_cms( :, k ) = [ data{ k, 37 }; data{ k, 38 }; data{ k, 39 } ];
                link_ws_cms( :, k ) = [ data{ k, 40 }; data{ k, 41 }; data{ k, 42 } ];
                
            end
            
        end
        
        
        % Implement a function to load joint data from a spreadsheet.
        function [ joint_IDs, joint_names, joint_parent_link_IDs, joint_child_link_IDs, joint_ps, joint_vs, joint_ws, joint_w_screws, joint_thetas, joint_domains, joint_orientations, joint_torques ] = load_joint_data( self, file_name, directory )
            
            % Determine whether to set the load directory to be the stored load directory.
            if nargin < 3, directory = self.load_path; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Determine how to read in the joint data.
            if verLessThan( 'matlab', '2019a' )                         % If this Matlab version is older than 2019a...
               
                % Read in the joint data.
                [ ~, ~, data ] = xlsread( full_path, 'A4:AP17' );
                
            else                                                        % Otherwise...
                
                % Read in the joint data.
                data = readcell( full_path, 'NumHeaderLines', 3 );

            end
            
            % Retrieve the number of joints.
            num_joints = size( data, 1 );
           
            % Preallocate variables to store the joint data.
            [ joint_IDs, joint_parent_link_IDs, joint_child_link_IDs, joint_thetas, joint_torques ] = deal( zeros( 1, num_joints ) );
            [ joint_ps, joint_vs, joint_ws, joint_w_screws ] = deal( zeros( 3, num_joints ) );
            joint_domains = zeros( 2, num_joints );
            [ joint_names, joint_orientations ] = deal( cell( 1, num_joints ) );
            
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
                
                % Set the joint domains.
                joint_domains(:, k) = [ data{ k, 8 }; data{ k, 9 } ];
                
                % Set the joint points.
                joint_ps(:, k) = [ data{ k, 11 }; data{ k, 13 }; data{ k, 15 } ];
                
                % Set the joint axes of rotation.
                joint_w_screws(:, k) = [ data{ k, 16 }; data{ k, 17 }; data{ k, 18 } ];
                
                % Set the joint velocities.
                joint_vs(:, k) = [ data{ k, 19 }; data{ k, 20 }; data{ k, 21 } ];
                joint_ws(:, k) = [ data{ k, 22 }; data{ k, 23 }; data{ k, 24 } ];   
                
                % Set the joint orientations.
                joint_orientations{k} = data{ k, 25 };
                
                % Set the joint torques.
                joint_torques(k) = data{ k, 26 };
                
            end
            
        end
            
          
        % Implement a function to load neuron data from a spreadsheet.
        function [ neuron_IDs, neuron_names, neuron_Cms, neuron_Gms, neuron_Ers, neuron_Rs, neuron_Ams, neuron_Sms, neuron_dEms, neuron_Ahs, neuron_Shs, neuron_dEhs, neuron_dEnas, neuron_tauh_maxs, neuron_Gnas ] = load_neuron_data( self, file_name, directory )
            
            % Determine whether to set the load directory to be the stored load directory.
            if nargin < 3, directory = self.load_path; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Determine how to read in the neuron data.
            if verLessThan( 'matlab', '2019a' )                         % If this Matlab version is older than 2019a...
               
                % Read in the neuron data.
                [ ~, ~, data ] = xlsread( full_path, 'A4:O7' );
                
            else                                                        % Otherwise...
                
                % Read in the neuron data.
                data = readcell( full_path, 'NumHeaderLines', 3 );

            end
            
            % Retrieve the number of neurons.
            num_neurons = size( data, 1 );
           
            % Preallocate variables to store the neuron data.
            [ neuron_IDs, neuron_Cms, neuron_Gms, neuron_Ers, neuron_Rs, neuron_Ams, neuron_Sms, neuron_dEms, neuron_Ahs, neuron_Shs, neuron_dEhs, neuron_dEnas, neuron_tauh_maxs, neuron_Gnas ] = deal( zeros( 1, num_neurons ) );
            neuron_names = cell( 1, num_neurons );
            
            % Store the data associated with each neuron.
            for k = 1:num_neurons                           % Iterate through each neuron...
                
                % Set the neuron IDs.
                neuron_IDs(k) = data{ k, 1 };
                
                % Set the neuron names.
                neuron_names{k} = data{ k, 2 };

                % Set the neuron membrane properties.
                neuron_Cms(k) = data{ k, 3 };
                neuron_Gms(k) = data{ k, 4 };
                neuron_Ers(k) = data{ k, 5 };
                neuron_Rs(k) = data{ k, 6 };

                % Set the neuron sodium channel activation parameters.
                neuron_Ams(k) = data{ k, 7 };
                neuron_Sms(k) = data{ k, 8 };
                neuron_dEms(k) = data{ k, 9 };

                % Set the neuron sodium channel deactivation parameters.
                neuron_Ahs(k) = data{ k, 10 };
                neuron_Shs(k) = data{ k, 11 };
                neuron_dEhs(k) = data{ k, 12 };

                % Set the neuron sodium channel properties.
                neuron_dEnas(k) = data{ k, 13 };
                neuron_tauh_maxs(k) = data{ k, 14 };
                neuron_Gnas(k) = data{ k, 15 };
                
            end
            
        end
        
        
        % Implement a function to load synapse data from a spreadsheet.
        function [ synapse_IDs, synapse_names, synapse_dEsyns, synapse_gsyn_maxs, synapse_from_neuron_IDs, synapse_to_neuron_IDs ] = load_synapse_data( self, file_name, directory )
            
            % Determine whether to set the load directory to be the stored load directory.
            if nargin < 3, directory = self.load_path; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Determine how to read in the synapse data.
            if verLessThan( 'matlab', '2019a' )                         % If this Matlab version is older than 2019a...
               
                % Read in the synapse data.
                [ ~, ~, data ] = xlsread( full_path, 'A4:F19' );
                
            else                                                        % Otherwise...
                
                % Read in the synapse data.
                data = readcell( full_path, 'NumHeaderLines', 3 );

            end
            
            % Retrieve the number of synapses.
            num_synapses = size( data, 1 );
           
            % Preallocate variables to store the synapse data.
            [ synapse_IDs, synapse_dEsyns, synapse_gsyn_maxs, synapse_from_neuron_IDs, synapse_to_neuron_IDs ] = deal( zeros( 1, num_synapses ) );
            synapse_names = cell( 1, num_synapses );
            
            % Store the data associated with each neuron.
            for k = 1:num_synapses                           % Iterate through each neuron...
                
                % Set the synapse IDs.
                synapse_IDs(k) = data{ k, 1 };
                
                % Set the synapse names.
                synapse_names{k} = data{ k, 2 };
                
                % Set the synapse reversal potentials.
                synapse_dEsyns(k) = data{ k, 3 };
                
                % Set the maximum synapse conductances.
                synapse_gsyn_maxs(k) = data{ k, 4 };
                
                % Set the synapse from neuron ID.
                synapse_from_neuron_IDs(k) = data{ k, 5 };
                
                % Set the synapse to neuron ID.
                synapse_to_neuron_IDs(k) = data{ k, 6 };
                
            end
            
        end
        
        
        
            
    end
end

