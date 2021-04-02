function [ Timer_Count, Prescale ] = GetTimerPrescaler( Target_Frequency, Clock_Frequency )

%Define the maximum allowable count size.
MaxCounts = 2^16;

%Define the prescalers.
Prescales = [1 8 64 256 1024];

%Compute the timer count options.
Timer_Counts = (Clock_Frequency ./ (Prescales * Target_Frequency)) - 1;

%Determine which prescalers and counter values are valid.
Prescales = Prescales( Timer_Counts < MaxCounts );
Timer_Counts = Timer_Counts( Timer_Counts < MaxCounts );

%Compute the maximum valid timer count.
[Timer_Count, index] = max(Timer_Counts);

%Compute the associated prescaler.
Prescale = Prescales(index);

end

