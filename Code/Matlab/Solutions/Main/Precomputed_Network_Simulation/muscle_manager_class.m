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
        function self = muscle_manager_class( IDs, names, activations, activation_domains, desired_total_tensions, desired_active_tensions, desired_passive_tensions, measured_total_tensions, measured_active_tensions, measured_passive_tensions, tension_domains, desired_pressures, measured_pressures, pressure_domains, lengths, resting_lengths, velocities, yanks, typeIa_feedbacks, typeIb_feedbacks, typeII_feedbacks, kses, kpes, bs )
            
            % Define the default class properties.
            if nargin < 24, bs = 1; end
            if nargin < 23, kpes = 30; end
            if nargin < 22, kses = 30; end
            if nargin < 21, typeII_feedbacks = 0; end
            if nargin < 20, typeIb_feedbacks = 0; end
            if nargin < 19, typeIa_feedbacks = 0; end
            if nargin < 18, yanks = 0; end
            if nargin < 17, velocities = 0; end
            if nargin < 16, resting_lengths = 0; end
            if nargin < 15, lengths = 0; end
            if nargin < 14, pressure_domains = {[0, 90]}; end
            if nargin < 13, measured_pressures = 0; end
            if nargin < 12, desired_pressures = 0; end
            if nargin < 11, tension_domains = {[0, 450]}; end
            if nargin < 10, measured_passive_tensions = 0; end
            if nargin < 9, measured_active_tensions = 0; end
            if nargin < 8, measured_total_tensions = 0; end
            if nargin < 7, desired_passive_tensions = 0; end
            if nargin < 6, desired_active_tensions = 0; end
            if nargin < 5, desired_total_tensions = 0; end
            if nargin < 4, activation_domains = {[-0.050, -0.019]}; end
            if nargin < 3, activations = 0; end
            if nargin < 2, names = {''}; end
            if nargin < 1, IDs = 0; end
            
            % Determine the number of muscles that we want to create.
            self.num_muscles = length(IDs);
            
            % Ensure that we have the correct number of properties for each muscle.
            bs = self.validate_property( bs, 'bs' );
            kpes = self.validate_property( kpes, 'kpes' );
            kses = self.validate_property( kses, 'kses' );
            typeII_feedbacks = self.validate_property( typeII_feedbacks, 'typeII_feedbacks' );
            typeIb_feedbacks = self.validate_property( typeIb_feedbacks, 'typeIb_feedbacks' );
            typeIa_feedbacks = self.validate_property( typeIa_feedbacks, 'typeIa_feedbacks' );
            yanks = self.validate_property( yanks, 'yanks' );
            velocities = self.validate_property( velocities, 'velocities' );
            resting_lengths = self.validate_property( resting_lengths, 'resting_lengths' );
            lengths = self.validate_property( lengths, 'lengths' );
            pressure_domains = self.validate_property( pressure_domains, 'pressure_domains' );
            measured_pressures = self.validate_property( measured_pressures, 'measured_pressures' );
            desired_pressures = self.validate_property( desired_pressures, 'desired_pressures' );
            tension_domains = self.validate_property( tension_domains, 'tension_domains' );
            measured_passive_tensions = self.validate_property( measured_passive_tensions, 'measured_passive_tensions' );
            measured_active_tensions = self.validate_property( measured_active_tensions, 'measured_active_tensions' );
            measured_total_tensions = self.validate_property( measured_total_tensions, 'measured_total_tensions' );
            desired_passive_tensions = self.validate_property( desired_passive_tensions, 'desired_passive_tensions' );
            desired_active_tensions = self.validate_property( desired_active_tensions, 'desired_active_tensions' );
            desired_total_tensions = self.validate_property( desired_total_tensions, 'desired_total_tensions' );
            activation_domains = self.validate_property( activation_domains, 'activation_domains' );
            activations = self.validate_property( activations, 'activations' );
            names = self.validate_property( names, 'names' );
            IDs = self.validate_property( IDs, 'IDs' );
            
            % Preallocate an array of muscles.
            self.muscles = repmat( muscle_class(), 1, self.num_muscles );
            
            % Create each muscle object.
            for k = 1:self.num_muscles              % Iterate through each muscle...
                
                % Create this muscle.
                self.muscles(k) = muscle_class( IDs(k), names{k}, activations(k), activation_domains{k}, desired_total_tensions(k), desired_active_tensions(k), desired_passive_tensions(k), measured_total_tensions(k), measured_active_tensions(k), measured_passive_tensions(k), tension_domains{k}, desired_pressures(k), measured_pressures(k), pressure_domains{k}, lengths(k), resting_lengths(k), velocities(k), yanks(k), typeIa_feedbacks(k), typeIb_feedbacks(k), typeII_feedbacks(k), kses(k), kpes(k), bs(k) );
                
            end
            
        end
        
        
        % Implement a function to validate the input properties.
        function x = validate_property( self, x, var_name )
            
            % Set the default variable name.
            if nargin < 3, var_name = 'properties'; end
            
            % Determine whether we need to repeat this property for each muscle.
            if length(x) ~= self.num_muscles                % If the number of instances of this property do not agree with the number of muscles...
                
                % Determine whether to repeat this property for each muscle.
                if length(x) == 1                               % If only one muscle property was provided...
                    
                    % Repeat the muscle property.
                    x = repmat( x, 1, self.num_muscles );
                    
                else                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'The number of provided %s must match the number of muscles being created.', var_name )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the index associated with a given muscle ID.
        function muscle_index = get_muscle_index( self, muscle_ID )
            
            % Set a flag variable to indicate whether a matching muscle index has been found.
            bMatchFound = false;
            
            % Initialize the muscle index.
            muscle_index = 0;
            
            while (muscle_index < self.num_muscles) && (~bMatchFound)
                
                % Advance the muscle index.
                muscle_index = muscle_index + 1;
                
                % Check whether this muscle index is a match.
                if self.muscles(muscle_index).ID == muscle_ID                       % If this muscle has the correct muscle ID...
                    
                    % Set the match found flag to true.
                    bMatchFound = true;
                    
                end
                
            end
            
            % Determine whether a match was found.
            if ~bMatchFound                     % If a match was not found...
                
                % Throw an error.
                error('No muscle with ID %0.0f', muscle_ID)
                
            end
            
        end
        
        
        % Implement a function to store given muscle activations into the muscle manager.
        function self = store_muscle_activations( self, muscle_IDs, muscle_activations )
            
            % Ensure that the number of muscle IDs matches the number of provided muscle activations.
            if length(muscle_IDs) ~= length(muscle_activations)                     % If the number of muscle IDs does not match the number of muscle activations...
                
                % Throw an error.
                error('The number of provided muscle IDs must match the number of provided muscle activations.')
                
            end
            
            % Retrieve the number of muscle activations.
            num_activations = length(muscle_activations);
            
            % Store each muscle activation in the appropriate muscle of the muscle manager.
            for k = 1:num_activations                   % Iterate through each muscle activation...
                
                % Determine the muscle index associated with this muscle ID.
                muscle_index = self.get_muscle_index( muscle_IDs(k) );
                
                % Saturate the motor neuron activation.
                if muscle_activations(k) < self.muscles(muscle_index).activation_domain(1)
                    
                    muscle_activations(k) = self.muscles(muscle_index).activation_domain(1);
                    
                elseif muscle_activations(k) > self.muscles(muscle_index).activation_domain(2)
                    
                    muscle_activations(k) = self.muscles(muscle_index).activation_domain(2);
                    
                end
                
                % Store the motor neuron activation associated with this muscle.
                self.muscles(muscle_index).activation = muscle_activations(k);
                
            end
            
        end
        
        
        % Implement a function to compute the desired total muscle tensions associated with the activations of the constituent muscles.
        function self = activations2desired_total_tensions( self )
            
            % Compute the desired total muscle tension associated with the current muscle activation for each muscle.
            for k = 1:self.num_muscles              % Iterate through each muscle...
                
                % Compute the desired total muscle tension associated with ths current muscle activation for this muscle.
                self.muscles(k) = self.muscles(k).activation2desired_total_tension();
                
            end
            
        end
        
        
        % Implement a function to compute the desired active and desired passive muscle tension associated with the desired total muscle tension of the constituent muscles.
        function self = desired_total_tensions2desired_active_passive_tensions( self )
            
            % Compute the desired active and desired passive muscle tension associated with the desired total muscle tension of the constituent muscles.
            for k = 1:self.num_muscles              % Iterate through each muscle...
                
                % Compute the desired total muscle tension associated with ths current muscle activation for this muscle.
                self.muscles(k) = self.muscles(k).desired_total_tension2desired_active_passive_tension();
                
            end
            
        end
        
        
        
    end
end

