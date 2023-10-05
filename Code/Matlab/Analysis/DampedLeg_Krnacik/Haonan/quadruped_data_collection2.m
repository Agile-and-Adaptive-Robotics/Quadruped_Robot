%% 1. Calibrate quadruped leg joints

% initialize serial communication with baud rate
s = serialport('COM11', 115200);

% read and display quadruped leg angles
stext = readline(s);
    if(~isempty(str2num(stext)))  % Make sure the data we are reading is actually a number
        angles_current = str2num(stext);  % If it is a number, store it
        fprintf('%d\n',angles_current);
    end
    x = s.NumBytesAvailable;

data = read(s,4,"double");
clear s