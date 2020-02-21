function [ nStepData ] = MapStepResponseData(StepData, tfinal)

%Retrieve the complete input signal.
Input_Time = StepData(:, 1);
Input_Signal = StepData(:, 2);
Output_Signal = StepData(:, 3);

%Retrieve the desired portion of the input signal.
Input_Signal = Input_Signal( (Input_Time >= 0) & (Input_Time <= tfinal) );
Output_Signal = Output_Signal( (Input_Time >= 0) & (Input_Time <= tfinal) );
Input_Time = Input_Time( (Input_Time >= 0) & (Input_Time <= tfinal) ); Input_Time = Input_Time - Input_Time(1);

%Interpolate the output signal.
Input_Time_Interp = linspace(Input_Time(1), Input_Time(end), 1000);
Output_Signal_Interp = interp1(Input_Time, Output_Signal, Input_Time_Interp);

%Compute the zero associated with the output signal.
[~, index] = min(abs(Output_Signal_Interp));
rt_time = Input_Time_Interp(index);

%Compute the new input time vector.
Input_Time = Input_Time - rt_time;

%Retrieve the mean value of the input signal during the up-step.
Input_Signal_Amp = mean(Input_Signal(Input_Time > rt_time));

%Normalize the Input & Output signals with respect to the mean input signal amplitude.
Input_Signal = Input_Signal/Input_Signal_Amp;
Output_Signal = Output_Signal/Input_Signal_Amp;

%Define the new step data.
nStepData = [Input_Time Input_Signal Output_Signal];

end