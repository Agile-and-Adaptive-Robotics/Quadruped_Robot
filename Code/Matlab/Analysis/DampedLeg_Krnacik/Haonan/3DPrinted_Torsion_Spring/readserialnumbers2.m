%This is an introductory function for reading in serial data

function data = readserialnumbers2()

%Initialize the serial port on the correct port, with a baud rate
s = serialport('COM4', 115200);

%Determine how many lines of data to collect, and initialize a cell array
%to store in the data from the serial port
length_to_collect = 30000;
stext = cell(length_to_collect,1);

%% Read the data and store in a matrix
%Read all the data (ASCII) into a cell array
for i = 1:length_to_collect+1  %First read almost always starts in the middle of a number, so it is likely not useable, so add 1
    stext{i} = readline(s);
end

%Convert the data from ASCII to numbers
a = 2; %initialize counting variable (first read is always 'junk')
b = 1; %initialize storing variable

while a<=length_to_collect+1 %While a is less than or equal to the amount of data we need to collect
    if(~isempty(str2num(stext{a})))  %Make sure the data we are reading is actually a number
        data(b,:) = str2num(stext{a});  %If it is a number, store it
        b = b+1;  %Increment storage variable
    end
    a = a+1;   %Increment read variable
end

%%
%close the port before ending the function
clear s