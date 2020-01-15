%% Animatlab Serial Port Communication Testing.

%Clear Everything
clear, close('all'), clc

%% Testing Animatlab Serial Port Communication.

% %Open a serial port to simulate animatlab output.
% serial_animatlab = OpenAtmegaSerialPort( 'COM9', 9600 );
% animatlab_value = 1023;
% animatlab_ID = 1;

%Open the serial port.
serial_port = OpenAtmegaSerialPort( 'COM10', 9600 );

%Define the number of points to keep on the plot at one time.
num_points_to_keep = 100;

%Define the Animatlab Muscle IDs.  These can be any integer value.
MuscleIDs = [1 2 3];

%Compute the number of muscles in the simulation.
num_muscles = length(MuscleIDs);

%Preallocate an array to store the muscle counts.
MuscleCounts = zeros(1, num_muscles);

%Preallocate a cell array to store the muscle activations.
[TimeSteps, MuscleActivations] = deal( cell(1, num_muscles) );

%Format the muscle activation plot.
h = figure; hold on, grid on, axis([0 num_points_to_keep 0 1023])

%Iterate through each of the muscles and perform the necessary initializations.
for k = 1:num_muscles                                                                       %Iterate through each of the muscles...
    %Preallocate the time step and muscle activation array.
    [TimeSteps{k}, MuscleActivations{k}] = deal( zeros(1, num_points_to_keep) );
    
    %Initialize the plotting / animation arrays.
    eval(sprintf('ts%0.0f_to_plot = TimeSteps{%0.0f}(1);', k, k))
    eval(sprintf('xs%0.0f_to_plot = MuscleActivations{%0.0f}(1);', k, k))
    
    %Create the initial plot element.
    eval(sprintf('plot(ts%0.0f_to_plot, xs%0.0f_to_plot, ''.'', ''Markersize'', 5, ''XDataSource'', ''ts%0.0f_to_plot'', ''YDataSource'', ''xs%0.0f_to_plot'');', k, k, k, k))
end


%Continuously search the serial port.
while true                                  %Iterate indefinitely...
    
    %     %Simulate Animatlab output.
    %     SimulateAnimatlabOutput( serial_animatlab, animatlab_value, animatlab_ID )
    
    %Read a sentence from animatlab.
    [ xs, IDs ] = ReadSentenceFromAnimatlab( serial_port, false );    
    
    %Assign each of the muscle IDs and values to the required arrays.
    for k1 = 1:length(IDs)                                                              %Iterate through each of the muscle values read in...
        
        %Compute the cell array index associated with the current muscle ID.
        muscle_loc1 = find(MuscleIDs == IDs(k1));
        %     disp(ID)
        
        %Only continue processing this iteration if a valid muscle ID was detected.
        if ~isempty(muscle_loc1)                                                            %If we got a valid muscle ID...
            
            %Advance the muscle counter associated with this muscle.
            MuscleCounts(muscle_loc1) = MuscleCounts(muscle_loc1) + 1;
            
            %Compute the index of the next open slot in the muscle activation array associated with the current muscle ID.
            muscle_loc2 = MuscleCounts(muscle_loc1);
            
            %Determine how to store the new point.
            if muscle_loc2 <= num_points_to_keep                              %If we have fewer than the total number of points to keep...
                
                %Store the muscle activation value and time step into the correct cell array locations.
                TimeSteps{muscle_loc1}(muscle_loc2) = muscle_loc2;
                MuscleActivations{muscle_loc1}(muscle_loc2) = xs(k1);
                
                %Update the arrays for plotting.
                eval(sprintf('ts%0.0f_to_plot = TimeSteps{%0.0f}(1:MuscleCounts(%0.0f));', muscle_loc1, muscle_loc1, muscle_loc1))
                eval(sprintf('xs%0.0f_to_plot = MuscleActivations{%0.0f}(1:MuscleCounts(%0.0f));', muscle_loc1, muscle_loc1, muscle_loc1))
                
            else
                
                %Store the time and muscle activation values into arrays.
                TimeSteps{muscle_loc1} = (1 + (muscle_loc2 - num_points_to_keep)):muscle_loc2;
                MuscleActivations{muscle_loc1} = [MuscleActivations{muscle_loc1}(2:end) xs(k1)];
                
                %Set the arrays for plotting.
                eval(sprintf('ts%0.0f_to_plot = TimeSteps{muscle_loc1};', muscle_loc1));
                eval(sprintf('xs%0.0f_to_plot = MuscleActivations{muscle_loc1};', muscle_loc1));
                
                %Create an array of all of the time step vectors in order to determine the limits of the plot.
                ts = [];
                for k2 = 1:num_muscles
                    ts = [ts TimeSteps{k2}];
                end
                
                %Set the new plot axes.
                xlim([min(ts) max(ts)])
                
            end
            
            %             %Refresh the plot.
            %             refreshdata(h, 'caller'), drawnow
            
            %     %Switch the simulated animatlab ID.
            %     if animatlab_ID == 1
            %         animatlab_ID = 2;
            %     elseif animatlab_ID == 2
            %         animatlab_ID = 3;
            %     else
            %         animatlab_ID = 1;
            %     end
            
        end
        
    end
    
    %Refresh the plot.
    refreshdata(h, 'caller'), drawnow
    
end

%Close the test serial port.
% CloseSerialPort(serial_test)

%Close the serial port.
CloseSerialPort(serial_port)

%(8*sin(t) + 8)*10^-9


