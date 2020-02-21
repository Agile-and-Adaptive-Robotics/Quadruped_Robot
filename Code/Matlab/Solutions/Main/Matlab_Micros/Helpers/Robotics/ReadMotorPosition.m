function [ MotorPositions, cnt ] = ReadMotorPosition( serial, ID )

%Set the maximum number of loops to perform while waiting for the arduino.
cntmax = 1000;

%Preallocate the motor positions array.
MotorPositions = zeros( length(ID), 1 );

%Collect the motor positions.
for k = 1:length(ID)                %Iterate through each supplied ID...
    
    %Write the Motor ID who's position to query.
    fwrite(serial, ID(k))
    
    %Wait for the arduino to send information back through the serial port before continuing.
    while ((serial.BytesAvailable ~= 2) && (cnt < cntmax))      %While there are not two bytes in the serial port...
        
        %Advance the counter...
        cnt = cnt + 1;                      %Here we are keeping track of how many times this loop runs.  This is useful for debugging.
        
        %Print the available bytes.  This is just for the purpose of debugging.  It may or may not be useful.
        %fprintf('%0.0f\n', serial.BytesAvailable)
        
    end
    
    %Determine whether the motor position was received from the arduino.
    if cnt < cntmax
        %Read the position from the motor.
        MotorPositions(k, 1) = fread(serial, 1) + fread(serial, 1)*256;
    else
        %Report that the motor position was never received.
        MotorPositions(k, 1) = -1;
    end
    
end

end

