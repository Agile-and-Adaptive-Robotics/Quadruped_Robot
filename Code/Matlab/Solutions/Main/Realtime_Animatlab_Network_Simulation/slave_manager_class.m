classdef slave_manager_class
    
    % This class contains properties and methods related to managing the slave microcontrollers.
    
    % Define the class properties.
    properties
        slaves
        num_slaves
    end
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = slave_manager_class(slaves)
            
            % Determine how to define the slave array and numbers of slaves.
            if nargin < 1
                
                % Create an empty slave object.
                self.slaves = slave_class();
                
                % Set the number of slaves to one.
                self.num_slaves = 1;
                
            else
                
                % Create the slave object.
                self.slaves = slaves;
                
                % Compute the number of slaves.
                self.num_slaves = length(slaves);
                
            end
            
        end
        
        
        % Implement a function to initialize the slaves.
        function self = initialize_slaves(self)
            
            % Set the number of slaves.
            self.num_slaves = 24;
            
            % Initialize a joint counter.
            joint_counter = 0;
            
            % Initialize each of the slaves.
            for k = 1:self.num_slaves                   % Iterate through each slave...
               
                % Define the slave ID.
                slave_ID = k;
                
                % Define the muscle ID.
                muscle_ID = k + 38;
                
                % Define the first pressure sensor ID.
                pressure_sensor_ID1 = k;
                
                % Determine how to set the second pressure sensor ID and whether to advance the joint counter.
                if mod(k, 2) == 0                       % If this slave ID is even...
                    
                    % Compute the second pressure sensor ID.
                    pressure_sensor_ID2 = k - 1;
                    
                else                                    % Otherwise... (If this slave ID is odd...)
                    
                    % Compute the second pressure sensor ID.
                    pressure_sensor_ID2 = k + 1;
                    
                    % Advance the joint counter
                    joint_counter = joint_counter + 1;
                    
                end
                
                % Define the joint ID.
                joint_ID = joint_counter;
                
                % Define the slave sensor values.
                pressure_value1 = 0;
                pressure_value2 = 0;
                joint_value = 0;
                
                % Define the slave desired pressure.
                desired_pressure = 0;
                
                % Create this slave object.
                self.slaves(k) = slave_class(slave_ID, muscle_ID, pressure_sensor_ID1, pressure_sensor_ID2, joint_ID, pressure_value1, pressure_value2, joint_value, desired_pressure);
                
            end
            
            
            
        end
        
        %         function outputArg = method1(self,inputArg)
        %             %METHOD1 Summary of this method goes here
        %             %   Detailed explanation goes here
        %             outputArg = self.Property1 + inputArg;
        %         end
        
    end
end

