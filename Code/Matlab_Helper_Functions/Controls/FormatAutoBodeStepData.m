function [ StepData ] = FormatAutoBodeStepData(DataIn, DataOut, Freq, NumPointsPerCycle)

Period = 1/Freq;
NumPoints = length(DataIn);
NumCycles = NumPoints/NumPointsPerCycle;
TotalTime = NumCycles*Period;
Times = linspace(0, TotalTime, NumPoints);

StepData = [Times', DataIn, DataOut];

end