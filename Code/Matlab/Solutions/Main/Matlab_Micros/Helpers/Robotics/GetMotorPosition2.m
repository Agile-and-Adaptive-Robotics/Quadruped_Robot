function [ nMotorPosition, bGotResponse ] = GetMotorPosition2( serial, ID, NumReadAttempts )
%% Setup to Read the Motor Positions.

%Set the default number of read attempts to three.
if nargin < 3, NumReadAttempts = 3; end

%Ensure that the number of read attempts is a positive integer.
NumReadAttempts = abs(round(NumReadAttempts));

%Ensure that the number of read attempts is odd.
if mod(NumReadAttempts, 2) == 0                 %If the number of read attempts is even...
    NumReadAttempts = NumReadAttempts + 1;      %Increase the number of read attempts to the nearest odd integer.
end

%Preallocate the actual position values.
nMotorPosition = zeros(length(ID), NumReadAttempts);

%Set the maximum number of loops to perform while waiting for the arduino. THIS PARAMETER SHOULD BE SET TO A LARGE NUMBER.  IT IS A SAFETY TO ESCAPE THE LOOP AND PREVENT CRASHES.  IT SHOULD NOT BE RELIED ON TO REGULARLY ESCAPE THE LOOP.
cntmax = 1e6;

%Preallocate a variable to store whether a response was received from the Arduino before proceeding.
bGotResponse = -1*ones(length(ID), NumReadAttempts);

%% Write to the Arduino to Request Motor Positions.
%State that we are beginning to read motor positions.
fprintf('\nREADING POSITIONS FROM ARDUINO. Please Wait...\n')

for k2 = 1:NumReadAttempts
    
    %Write a value to the Arduino to identify the write position procedure.
    fwrite(serial, 2);
    
    %Write the number of motors we are using.
    fwrite(serial, size(ID, 1));
    
    for k1 = 1:length(ID)       %Iterate through each motor id...
        
        %Write the motor ID to the serial port.
        fwrite(serial, ID(k1));
        
    end
    
    %% Wait for the Arduino to Respond.
    %Preallocate a counter variable.
    cnt = 0;
    
    %Wait for the arduino to send information back through the serial port before continuing.
    while ((serial.BytesAvailable ~= 2*length(ID)) && (cnt < cntmax))      %While there are not two bytes per motor in the serial port...
        
        %Advance the counter...
        cnt = cnt + 1;                      %Here we are keeping track of how many times this loop runs.  This is useful for debugging.
        
    end
    
    %% Interpret the Information Sent From the Arduino.
    %Determine whether the motor position was received from the arduino.
    if cnt < cntmax                             %If the maximum number of itereations was not exceeded...
        
        %Read the motor positions from the arduino.
        for k1 = 1:length(ID)       %Iterate through each motor id...
            
            %Read the position from the motor.
            nMotorPosition(k1, k2) = fread(serial, 1) + fread(serial, 1)*256;
            
            %Determine if the response from the Arduino is a valid position or an error code.
            if (nMotorPosition(k1, k2) <= 4096) && (nMotorPosition(k1, k2) >= 0)                  %If the response is a valid position...
                bGotResponse(k1, k2) = 1;               %Record that a valid response was received.
            else
                bGotResponse(k1, k2) = 0;               %Record that a valid response was not received.
            end
            
        end
        
    else
        
        %Read the motor positions from the arduino.
        for k1 = 1:length(ID)       %Iterate through each motor id...
            %Report that the motor position was never received.
            nMotorPosition(k1, k2) = -500;
            
            %Record that a valid response was not received.
            bGotResponse(k1, k2) = 0;
        end
        
    end
    
end

%% Determine Which Read Attempt to Preserve.

%Retrieve the median position of the read attempts.
medMotorPosition = median(nMotorPosition, 2);

%Preallocate variables to store the rows and columns of the median motor positions.
[rs, cs] = deal( zeros( length(medMotorPosition), 1 ) );

%Find the rows and columns associated with these medians.
for k = 1:length(medMotorPosition)                                              %Iterate through each of the median motor positions...
    [rs(k), cs(k)] = find( medMotorPosition(k) == nMotorPosition(k, :), 1 );    %Extract the first matching row and column number in this row.
end

%Store the rows and columns into a matrix for sorting.
L = [rs cs];

%Sort the rows and columns so that the first row is the first value extracted.
L = MultiSort(L);

%Reassign the rows and columns to be their sorted versions.
[rs, cs] = deal( L(:, 1), L(:, 2) );

%Preallocate the median bGotResponse variable.
medGotResponse = -1*ones(length(rs), 1);

%Extract the associated bGotResponse values.
for k = 1:length(rs)
   medGotResponse(k, 1) = bGotResponse(rs(k), cs(k)); 
end

%Reassign the output variables to be the median of the read attempts.
[nMotorPosition, bGotResponse] = deal( medMotorPosition, medGotResponse );

%State that we have read the motor positions from the Arduino.
fprintf('\nDone: Reading motor positions from Arduino.\n\n')

%% Determine Whether the Data was Valid.
%Determine whether to throw a warning message.
if sum(sum(~bGotResponse)) > 0                  %If at least one response was deemed not valid...
    warning('At least one Arduino response was invalid or not received.')               %Throw a warning that at least one of the responses was not valid.
end


end

