classdef precomputed_simulation_manager_class

    % This class contains properties and methods related to managing simulation data.
    
    % Define the class properties.
    properties
        muscle_IDs
        num_muscles
        num_timesteps
        dt
        times
        activations
    end
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = precomputed_simulation_manager_class( muscle_IDs, times, activations, dt, num_muscles, num_timesteps )

            % Define the number of time steps.
            if nargin < 6, self.num_timesteps = 0; else, self.num_timesteps = num_timesteps; end
            
            % Define the number of muscles.
            if nargin < 5, self.num_muscles = 0; else, self.num_muscles = num_muscles; end
            
            % Define the simulation time step.
            if nargin < 4, self.dt = 0; else, self.dt = dt; end
            
            % Define the motor neuron activations.
            if nargin < 3, self.activations = 0; else, self.activations = activations; end
            
            % Define the simulation times.
            if nargin < 2, self.times = 0; else, self.times = times; end
            
            % Define the muscle IDs.
            if nargin < 1, self.muscle_IDs = 0; else, self.muscle_IDs = muscle_IDs; end
            
        end
        
        % Implement a function to simulation data.
        function self = load_simulation_data( self, load_path, max_num_data_points )
                        
            % Read in the muscle IDs.
            muscle_IDs_temp = readmatrix( load_path, spreadsheetImportOptions( 'NumVariables', 12, 'DataRange', 'C2:N2' ) );
            self.muscle_IDs = str2double( muscle_IDs_temp(1:2:end) );
        
            % Update the number of muscles.
            self.num_muscles = length( self.muscle_IDs );
            
            % Read in the simulation data.
            simulation_data = readmatrix( load_path, spreadsheetImportOptions( 'NumVariables', 14, 'DataRange', 'A5' ) );
            
            % Retrieve the number of simulation data points.
            num_data_points = size( simulation_data, 1 );

            % Determine whether to set the maximum number of data points to be all of the data.
            if nargin < 3, max_num_data_points = size( simulation_data, 1 ); end
           
            % Compute the subsampling step size.
            sampling_step_size = ceil( num_data_points/max_num_data_points );
           
            % Store the simulation data.
            self.times = str2double( simulation_data(1:sampling_step_size:end, 2) );
            self.activations = str2double( simulation_data(1:sampling_step_size:end, 3:2:end) );
            self.dt = self.times(2) - self.times(1);
            self.num_timesteps = length(self.times);

        end
        
        
        % Implement a function to plot the motor neuron activations.
        function fig = plot_activation( self, fig )
        
            
            % UPDATE PLOTS SO THAT THEY ALL HAVE FIGURE NAMES.
            % MAKE PLOT LABELS MORE SPECIFIC.
            
            % Create a figure window if none was provided.
            if nargin < 2, fig = figure('Color', 'w'); end
            
            % Format the figure.
            hold on, grid on, xlabel('Time [s]'), ylabel('Motor Neuron Activation [V]'), title('Motor Neuron Activation vs Time')
            
            % Create a legend string.
            legstr = cell( 1, self.num_muscles );
            
            % Create a variable to store the plot elements.
            line_elements = gobjects( 1, self.num_muscles );
            
            % Plot each motor neuron activations.
            for k = 1:self.num_muscles                      % Iterate through each muscle...

                % Plot the motor neuron activations.
                line_elements(k) = plot( self.times, self.activations(:, k), '-', 'Linewidth', 3 );

                % Create the legend string.
                legstr{k} = sprintf( 'Muscle %0.0f', self.muscle_IDs(k) );
                
            end
            
            % Add a legend to the plot.
            legend( line_elements, legstr )
            
        end
    end
end

