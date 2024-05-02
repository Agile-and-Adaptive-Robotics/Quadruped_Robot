classdef applied_voltage_class
    
    % This class contains properties and methods related to applied voltages.
    
    
    %% APPLIED VOLTAGE PROPERTIES
    
    % Define the class properties.
    properties
        
        ID
        name
        to_neuron_ID
        
        ts
        Vas
        
        num_timesteps
        dt
        tf
        
        enabled_flag
        
        array_utilities
        applied_voltage_utilities
        
    end
    
    
    %% APPLIED VOLTAGE METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = applied_voltage_class( ID, name, to_neuron_ID, ts, Vas, enabled_flag, array_utilities, applied_voltage_utilities )
            
            % Set the default properties.
            if nargin < 8, applied_voltage_utilities = applied_voltage_utilities_class(  ); end             % [class] Applied Voltage Utilities.
            if nargin < 7, array_utilities = array_utitlies_class(  ); end                                  % [class] Array Utilities.
            if nargin < 6, self.enabled_flag = true; else, self.enabled_flag = enabled_flag; end
            if nargin < 5, self.Vas = { [  ] }; else, self.Vas = Vas; end
            if nargin < 4, self.ts = 0; else, self.ts = ts; end
            if nargin < 3, self.to_neuron_ID = 0; else, self.to_neuron_ID = to_neuron_ID; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end
            
            % Store an instance of the utilities classes.
            self.applied_voltage_utilities = applied_voltage_utilities;
            self.array_utilities = array_utilities;
            
            % Store the applied voltage flags.
            self.enabled_flag = enabled_flag;
            
            % Store the applied voltage properties.
            self.Vas = Vas;
            self.ts = ts;
            
            % Store the applied voltage information.
            self.to_neuron_ID = to_neuron_ID;
            self.name = name;
            self.ID = ID;
            
            % Validate the applied voltage.
            assert( self.is_applied_voltage_valid( ts, Vas ), 'The lengths of the time vector and applied voltage vectors must be equal.' )
            
            % Compute the number of timesteps.
            [ ~, self ] = self.compute_num_timesteps( ts, true );
            
            % Compute the step size.
            [ ~, self ] = self.compute_dt( ts, true, array_utilities );
                        
            % Compute the final time.
            [ ~, self ] = self.compute_tf( ts, true );
            
        end
        
        
        %% Get & Set Functions
        
        % Implement a function to set the applied voltage vector.
        function self = set_applied_voltage( self, ts, Vas )
            
            % Set the default input arugments.
            if nargin < 3, Vas = 0; end
            if nargin < 2, ts = 0; end
            
            % Ensure that there are the same number of time steps as applied voltages.
            assert( length( ts ) == length( Vas ), 'The lengths of the time vector and applied voltage vectors must be equal.' )
            
            % Set the time vector.
            self.ts = ts;
            
            % Set the applied voltages.
            self.Vas;
            
            % Set the number of time steps.
            self.num_timesteps = length( self.ts );    
            
        end
        
        
        %% Validation Functions
        
        % Implement a function to validate the applied voltage.
        function valid_flag = is_applied_voltage_valid( self, ts, Vas )
           
            % Set the default input arguments.
            if nargin < 3, Vas = self.Vas; end
            if nargin < 2, ts = self.ts; end
            
            % Validate the applied voltage.
            valid_flag = length( ts ) == length( Vas );
            
        end
        
                        
        %% Compute Time Functions.
        
        % Implement a function to compute the number of time steps.
        function [ n_timesteps, self ] = compute_num_timesteps( self, ts, set_flag )
           
            % Set the default input arguments.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end
            if nargin < 2, ts = self.ts; end
            
            % Compute the number of time steps.
            n_timesteps = length( ts );                                                                              % [#] Number of Simulation Timesteps
            
            % Determine whether to update the applied voltage object.
            if set_flag, self.num_timesteps = n_timesteps; end
            
        end
        
        
        % Implement a function to compute the time step.
        function [ dt, self ] = compute_dt( self, ts, set_flag, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end
            if nargin < 2, ts = self.ts; end
            
            % Compute the step size.
            dt = array_utilities.compute_step_size( ts );                                                         % [s] Simulation Time Step Size
            
            % Determine whether to update the applied voltage object.
            if set_flag, self.dt = dt; end
            
        end
        
        
        % Implement a function to compute the final time.
        function [ tf, self ]= compute_tf( self, ts, set_flag )
            
            % Set the default input arguments.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end
            if nargin < 2, ts = self.ts; end
            
            % Compute the final time.
            tf = max( ts );                                         % [s] Final Simulation Time.
            
           % Determine whether to update the applied voltage object.
            if set_flag, self.tf = tf; end
           
        end
        
        
        % Implement a function to compute the properties associated with an applied voltage vector.
        function [ n_timesteps, dt, tf, self ] = compute_applied_voltage_properties( self, ts, Vas, set_flag, array_utilities )
            
            % Set the default input arugments.
            if nargin < 5, array_utilities = self.array_utilities; end
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end
            if nargin < 3, Vas = self.Va_DEFAULT; end                                                                  % [A] Applied Current Magnitudes
            if nargin < 2, ts = self.ts_DEFAULT; end                                                                        % [s] Applied Current Times
            
            % Ensure that there are the same number of time steps as applied voltages.
            assert( self.is_applied_voltage_valid( ts, Vas ), 'The lengths of the time vector and applied voltage vectors must be equal.' )
            
            % Create an instance of the applied voltage object that can be updated.
            applied_voltage = self;
            
            % Update the applied voltage time and magnitude vectors.
            applied_voltage.ts = ts;
            applied_voltage.Vas = Vas;
            
            % Compute the number of timesteps.
            [ n_timesteps, applied_voltage ] = applied_voltage.compute_num_timesteps( ts, true );
            
            % Compute the step size.
            [ dt, applied_voltage ] = applied_voltage.compute_dt( ts, true, array_utilities );
                        
            % Compute the final time.
            [ tf, applied_voltage ] = applied_voltage.compute_tf( ts, true );
            
            % Determine whether to update the applied current object.
            if set_flag, self = applied_voltage; end
            
        end
        
        
        %% Sampling Functions.
        
        % Implement a function to sample an applied voltages.
        function [ ts_sample, Vas_sample ] = sample_Vas( self, dt_sample, tf_sample, ts_reference, Vas_reference )
            
            % Set the default input arguments.
            if nargin < 5, Vas_reference = self.Ias; end
            if nargin < 4, ts_reference = self.ts; end
            if nargin < 3, tf_sample = self.tf; end
            if nargin < 2, dt_sample = self.ts; end
            
            % Compute the number of reference timesteps.
            n_timesteps_reference = length( Vas_reference );
            
            % Determine how to sample the applied current.
            if ~isempty( dt_sample ) && ( n_timesteps_reference > 0 )                          % If the sample spacing and existing applied voltage data is not empty...
                
                % Create the sampled time vector.
                ts_sample = ( 0:dt_sample:tf_sample )';
                
                % Determine how to sample the applied current.
                if n_timesteps_reference == 1                                           % If the number of timesteps is one.. ( The applied voltage is constant. )
                    
                    % Create the applied voltage sample as a constant vector.
                    Vas_sample = Vas_reference*ones( n_timesteps_reference, 1 );
                    
                else                                                                % Otherwise...
                    
                    % Create the applied voltage sample via interpolation.
                    Vas_sample = interp1( ts_reference, Vas_reference, ts_sample );
                    
                end
                
            else                                                                    % Otherwise...
                
                % Set the sampled time vector to be the existing time vector (perhaps empty, perhaps a complete time vector).
                ts_sample = ts_reference;
                
                % Set the sampled applied voltage vector to be the existing time vector (perhaps empty, perhaps a complete time vector).
                Vas_sample = Vas_reference;
                
            end
            
        end
        
        
%         % Implement a function to sample an applied voltage.
%         function [ Vas_sample, ts_sample ] = sample_Vas( self, dt, tf )
%             
%             % Set the default input arguments.
%             if nargin < 3, tf = max( self.ts ); end
%             if nargin < 2, dt = [  ]; end
%             
%             % Determine how to sample the applied voltage.
%             if ~isempty( dt ) && ( self.num_timesteps > 0 )                          % If the sample spacing and existing applied voltage data is not empty...
%                 
%                 % Create the sampled time vector.
%                 ts_sample = ( 0:dt:tf )';
%                 
%                 % Determine how to sample the applied voltage.
%                 if self.num_timesteps == 1                                           % If the number of timesteps is one.. ( The applied voltage is constant. )
%                     
%                     % Create the applied voltage sample as a constant vector.
%                     Vas_sample = repmat( self.Vas, [ self.num_timesteps, 1 ] );
%                     
%                 else                                                                % Otherwise...
%                     
%                     % Create the applied voltage sample via interpolation.
%                     Vas_sample = self.array_utilities.interp1_cell( self.ts, self.Vas, ts_sample );
%                     
%                 end
%                 
%             else                                                                    % Otherwise...
%                 
%                 % Set the sampled time vector to be the existing time vector (perhaps empty, perhaps a complete time vector).
%                 ts_sample = self.ts;
%                 
%                 % Set the sampled applied voltage vector to be the existing time vector (perhaps empty, perhaps a complete time vector).
%                 Vas_sample = self.Vas;
%                 
%             end
%             
%         end
        
        
        %% Enable & Disable Functions.
        
        % Implement a function to toogle whether this applied current is enabled.
        function [ enabled_flag, self ] = toggle_enabled( self, enabled_flag, set_flag )
            
            % Set the default input arguments.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            if narign < 2, enabled_flag = self.enabled_flag; end                                        % [T/F] Enabled Flag.
            
            % Toggle whether the applied current is enabled.
            enabled_flag = ~enabled_flag;                                                            	% [T/F] Applied Current Enabled Flag.
            
            % Determine whether to update the applied current object.
            if set_flag, self.enabled_flag = enabled_flag; end
            
        end
        
        
        % Implement a function to enable this applied current.
        function [ enabled_flag, self ] = enable( self, set_flag )
            
            % Set the default input arguments.
            if nargin < 2, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            
            % Enable this applied current.
            enabled_flag = true;                                                                        % [T/F] Applied Current Enabled Flag.
            
            % Determine whether to update the applied current object.
            if set_flag, self.enabled_flag = enabled_flag; end
            
        end
        
        
        % Implement a function to disable this applied current.
        function [ enabled_flag, self ] = disable( self, set_flag )
            
            % Set the default input arguments.
            if nargin < 2, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether to update the neuron object.)
            
            % Disable this applied current.
            enabled_flag = false;                                                                   	% [T/F] Applied Current Enabled Flag.
            
            % Determine wehther to update the applied current object.
            if set_flag, self.enabled_flag = enabled_flag; end
            
        end
        
        
        %% Save & Load Functions.
        
        % Implement a function to save applied voltage data as a matlab object.
        function save( self, directory, file_name, applied_voltage )
            
            % Set the default input arguments.
            if nargin < 4, applied_voltage = self; end
            if nargin < 3, file_name = 'Applied_Voltage.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the applied voltage data.
            save( full_path, applied_voltage )
            
        end
        
        
        % Implement a function to load applied voltage data as a matlab object.
        function applied_voltage = load( ~, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Applied_Voltage.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            applied_voltage = data.applied_voltage;
            
        end
        
        
    end
end

