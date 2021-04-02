classdef muscle_manager_class
    
    % This class contains properties and methods related to managing muscle objects.
    
    % Define the class properties.
    properties
        muscles
        num_muscles
    end
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = muscle_manager_class( muscles )
            
            % Determine how to define the muscle array and numbers of muscles.
            if nargin < 1
                
                % Create an empty muscle object.
                self.muscles = muscle_class();
                
                % Set the number of muscles to one.
                self.num_muscles = 1;
                
            else
                
                % Create the muscle object.
                self.muscles = muscles;
                
                % Compute the number of muscles.
                self.num_muscles = length(muscles);
                
            end
            
        end
        
        
        % Implement a function to initialize the muscles.
        function self = initialize_muscles(self)
            
            % Set the number of muscles.
            self.num_muscles = 24;
            
            % Initialize each of the muscles.
            for k = 1:self.num_muscles                   % Iterate through each muscle...
                
                % Define the muscle ID.
                ID = k + 38;
                
                % Define the motor neuron activation.
                motor_neuron_activation = 0;
                
                % Define the muscle length.
                muscle_length = 0;
                
                % Define the muscle velocity.
                muscle_velocity = 0;
                
                % Define the muscle tension.
                muscle_tension = 0;
                
                % Create this slave object.
                self.muscles(k) = muscle_class( ID, motor_neuron_activation, muscle_length, muscle_velocity, muscle_tension );
                
            end
            
        end
        
        %         function outputArg = method1(self,inputArg)
        %             %METHOD1 Summary of this method goes here
        %             %   Detailed explanation goes here
        %             outputArg = self.Property1 + inputArg;
        %         end
        
    end
end

