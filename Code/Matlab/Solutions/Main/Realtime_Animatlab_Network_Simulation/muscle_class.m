classdef muscle_class

    % This class contains properties and methods related to muscles.
    
    % Define the muscle data class properties.
    properties
        ID
        motor_neuron_activation
        length
        velocity
        tension
    end
    
    % Define the muscle class methods.
    methods
        
        % Implement the class constructor.
        function self = muscle_class( ID, motor_neuron_activation, length, velocity, tension )

            % Define the muscle tension.
            if nargin < 5, self.tension = 0; else, self.tension = tension; end
            
            % Define the muscle velocity.
            if nargin < 4, self.velocity = 0; else, self.velocity = velocity; end
            
            % Define the muscle length.
            if nargin < 3, self.length = 0; else, self.length = length; end
            
            % Define the motor neuron activation.
            if nargin < 2, self.motor_neuron_activation = 0; else, self.motor_neuron_activation = motor_neuron_activation; end
            
            % Define the muscle ID.
            if nargin < 1, self.ID = 0; else, self.ID = ID; end
            
        end
        
%         function outputArg = method1(self,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = self.Property1 + inputArg;
%         end
    end
end

