function [ nMotorPosition, cnt ] = SetMotorPosition( serial, ID, MotorPosition )

%Preallocate the actual position values.
nMotorPosition = zeros(size(MotorPosition, 1), size(MotorPosition, 2));

%Set the maximum number of loops to perform while waiting for the arduino..
cntmax = 1000;

%Enter loop to systematically set the desired motor positions.
for k1 = 1:size(MotorPosition, 2)           %Iterate through each command position...
    for k2 = 1:size(MotorPosition, 1)       %Iterate through each motor id...
        
        %Convert the position into a low and high byte.
        low = mod(MotorPosition(k2, k1), 256);
        high = floor(MotorPosition(k2, k1)/256);
        
        %Print out the command sent to the motor for debugging.
        %         fprintf('ID = %0.0f, low = %0.0f, high = %0.0f \n', ID(k2), low, high)
        
        %Write the motor ID, the low position byte, and the high position byte to the serial port.
        fwrite(serial, ID(k2)), fwrite(serial, low), fwrite(serial, high)
        
        %Preallocate a counter variable.
        cnt = 0;
        
        %Wait for the arduino to send information back through the serial port before continuing.
        while ((serial.BytesAvailable ~= 2) && (cnt < cntmax))      %While there are not two bytes in the serial port...
            
            %Advance the counter...
            cnt = cnt + 1;                      %Here we are keeping track of how many times this loop runs.  This is useful for debugging.
            
            %Print the available bytes.  This is just for the purpose of debugging.  It may or may not be useful.
            %fprintf('%0.0f\n', serial.BytesAvailable)
            
        end
        
        if cnt < cntmax
            %Read the position from the motor.
            nMotorPosition(k2, k1) = fread(serial, 1) + fread(serial, 1)*256;
        else
            %Report that the motor position was never received.
            nMotorPosition(k2, k1) = -1;
        end
    end
end

end

