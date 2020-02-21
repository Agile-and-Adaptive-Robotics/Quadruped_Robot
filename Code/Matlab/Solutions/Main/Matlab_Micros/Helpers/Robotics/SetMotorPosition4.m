function [ nMotorPosition, bGotResponse ] = SetMotorPosition4( serial, ID, MotorPositions, CurrentMotorPosition, move_speed, bPlotMotorGraphs )
%% Set Default Arguments.

if nargin < 4, bPlotMotorGraphs = false; end            %By default, do not make the motor plots...


%Works with 140 points when computing velocities in Matlab.

ntake = 140;

if size(MotorPositions, 2) > ntake
    MotorPositions = MotorPositions(:, 1:ntake);
end

%% Compute the Velocities to Write to the Motors Based on the Motor Positions.

%Extend the motor positions.
MotorPositions_Extended = [CurrentMotorPosition, MotorPositions];

%Map the first two rows of motor positions into the same domain as the last three rows.
MotorPositions_Extended(1:2, :) = interp1([0 4096], [0 1023], MotorPositions_Extended(1:2, :));

%Compute the change in motor position between each step.
dMotorPosition = abs(diff(MotorPositions_Extended, [], 2));

%Get the maximum position change at each step.
dMotorPositionMax = max(dMotorPosition);

%Normalize the position change of each motor at each step based on the maximum position change at that step.
dMotorPosition_Normalized = dMotorPosition./dMotorPositionMax;

%Map the normalized position change to motor velocities.
MotorVelocities = round(interp1([0 1], [1 1023], move_speed*dMotorPosition_Normalized));

%Set any NAN motor velocities to one.
for k = 1:size(MotorVelocities, 2)
    if sum(isnan(MotorVelocities(:, k))) > 0
        MotorVelocities(:, k) = ones(size(MotorVelocities, 1), 1);
    end
end

%% Send the Motor Commands to the Arduino.

%State that we are beginning to write motor position.
fprintf('\nWRITING POSITIONS TO ARDUINO. Please Wait...\n')

%Write a value to the Arduino to identify the write position procedure.
fwrite(serial, 1);

%Write the number of motors we are using.
fwrite(serial, size(ID, 1));

%Convert the Number of Commands into a low and high byte.
[NumCommandsLow, NumCommandsHigh] = deal( mod(size(MotorPositions, 2), 256), floor(size(MotorPositions, 2)/256) );
        
%Write the number of position / velocity commands to expect.
fwrite(serial, NumCommandsLow);
fwrite(serial, NumCommandsHigh);

%Write the motor IDs to the Arduino.
for k1 = 1:size(ID, 1)
    fwrite(serial, ID(k1))
end
    
%Enter loop to systematically set the desired motor positions.
for k1 = 1:size(MotorPositions, 2)           %Iterate through each command position...
    
    %State the current position number.
    fprintf('Sending Position %0.0f...\n', k1)
    
    for k2 = 1:size(MotorPositions, 1)       %Iterate through each motor id...
        
        %Convert the position into a low and high byte.
        [plow, phigh] = deal( mod(MotorPositions(k2, k1), 256), floor(MotorPositions(k2, k1)/256) );
        
        %Convert the velocities into a low and high byte.
        [vlow, vhigh] = deal( mod(MotorVelocities(k2, k1), 256), floor(MotorVelocities(k2, k1)/256) );
        
        %Write the motor ID, the low position byte, and the high position byte to the serial port.
%         fwrite(serial, ID(k2)), fwrite(serial, plow), fwrite(serial, phigh), fwrite(serial, vlow), fwrite(serial, vhigh)
          fwrite(serial, plow), fwrite(serial, phigh), fwrite(serial, vlow), fwrite(serial, vhigh)

%         pause(1e-2);
        
    end
    
    %74 points works with a pause of 0.100.
    if size(MotorPositions, 2) > 1, pause(0.100); end
    
%     if mod(k1, 50) == 0, pause(10); end
    
end

%% Wait for the Arduino to Send a Flag that it is Finished.

%Set the maximum number of loops to perform while waiting for the arduino. THIS PARAMETER SHOULD BE SET TO A LARGE NUMBER.  IT IS A SAFETY TO ESCAPE THE LOOP AND PREVENT CRASHES.  IT SHOULD NOT BE RELIED ON TO REGULARLY ESCAPE THE LOOP.
cntmax = 1e6;

%Preallocate a counter variable.
cnt = 0;

%Wait for the arduino to send information back through the serial port before continuing.
while ((serial.BytesAvailable ~= 1) && (cnt < cntmax))      %While there are not two bytes per motor in the serial port...
    
    %Advance the counter...
    cnt = cnt + 1;                      %Here we are keeping track of how many times this loop runs.  This is useful for debugging.
    
    %Print the available bytes.  This is just for the purpose of debugging.  It may or may not be useful.
    %fprintf('%0.0f\n', serial.BytesAvailable)
    
end

%% Set Dummy Output Variables to Make this New Version Work with the Existing Code.

%Set the necessary outputs with dummy values.
nMotorPosition = MotorPositions;
bGotResponse = ones(size(MotorPositions, 1), size(MotorPositions, 2));

%State that we have sent all of the positions to the Arduino.
fprintf('\nDone: All Positions Sent to Arduino.\n\n')

%Determine whether to throw an error message.
if sum(sum(~bGotResponse)) > 0                  %If at least one response was deemed not valid...
    warning('At least one Arduino response was invalid or not received.')               %Throw a warning that at least one of the responses was not valid.
end

%Read the dummy output from the arduino.
bSuccess = fread(serial, 1);


%% Plot the Desired Motor Positions & the Actual Motor Positions.

if bPlotMotorGraphs                 %If we are requested to plot the motor graphs...
    
    %Define the number of commands.
    ns = 1:size(MotorPositions, 2);
    
    %Create a figure for the desired motor positions and actual motor positions.
    figure
    
    %Determine the number of rows and columns to use on the subplot.
    [ nrows, ncols ] = GetSubplotRCs( size(MotorPositions, 1), false );
    
    %Plot the desired and actual motor positions & build the associated legend.
    for k = 1:size(MotorPositions, 1)                                      %Iterate through each set of motor positions...
        
        %Format the current subplot.
        subplot(nrows, ncols, k), hold on, grid on
        title('Motor Positions vs Command Number'), ylim([0 1.25*max(MotorPositions(k, :))])
        xlabel('Command Number [#]'), ylabel('Motor Position [0-1023] / [0-4096]')
        
        %Plot the desired & actual motor positions.
        plot(ns, MotorPositions(k, :), '.-', 'Markersize', 20)
        plot(ns, nMotorPosition(k, :), '.-', 'Markersize', 20)
        
        %Add a legend to the subplot.
        legend('Write Position', 'Read Position')
        
    end
end

end

