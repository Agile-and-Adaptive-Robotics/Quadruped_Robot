function [ StepData ] = NumericalStepInfo( ts, ys, FilterSize, bPlotStepResponse )
%% Apply a Moving Average Filter.

%Set the default options and catch expections.
if nargin < 4, bPlotStepResponse = false; end
if nargin < 3, FilterSize = 0; end
if FilterSize > 1, warning('Filter size must be in [0, 1]. Defaulting to 1.'), FilterSize = 1; end
if FilterSize < 0, warning('Filter size must be in [0, 1]. Defaulting to 0.'), FilterSize = 0; end
if isempty(FilterSize), FilterSize = 0.10; end

%Set the number of points to average.
if FilterSize == 0                                      %If the filter is turned off...
    NumPointsToAvg = 1;                                 %Set the number of points to average to one.
else
    NumPointsToAvg = round(FilterSize*length(ys));      %Determine the number of points to average.
end

%Compute the moving average of the signal.
ys_avg = movmean(ys, NumPointsToAvg);


%% Compute the Steady State Value.

%Compute the steady state value.
ys_ss = ys_avg(end);

%% Compute the Peak & Peak Time.

%Compute the peak value of the signal.
[Peak, ind] = max(ys_avg);

%Compute the peak time.
Peak_Time = ts(ind);

%% Compute the Rise Time.
%Compute the 10% and 90% values.
ys_rt = [0.1 0.9]*ys_ss;

%Create interpolated time and signal vectors.
ts_interp = linspace(ts(1), Peak_Time, 1000);
ys_interp = interp1(ts, ys_avg, ts_interp);

%Determine the locations at which the 10% and 90% values occur.
[~, index_10] = min(abs(ys_interp - ys_rt(1)));
[~, index_90] = min(abs(ys_interp - ys_rt(2)));

%Retrieve the 10% and 90% times.
% ts_rt = interp1(ys_avg, ts, ys_rt);
ts_rt = [ts_interp(index_10), ts_interp(index_90)];

%Compute the rise time.
Rise_Time = diff(ts_rt);

%% Compute the Settling Time.

%Define the settling time criteria.
SettlingRatio = 0.05;

%Retrieve the settling time bounds.
SettlingBnds = [1 - SettlingRatio, 1 + SettlingRatio]*ys_ss;

%Determine which values are within the bounds.
locs_inbnds = (ys_avg > SettlingBnds(1)) & (ys_avg < SettlingBnds(2));

%Preallocate the bAllInBnds boolean to indicate that not all of the values are in bounds.
bAllInBnds = false;

%Set the location counter variable to start at 1.
loc_crit = 0;

%Determine the location after which all values are in bounds.
while ~bAllInBnds && (loc_crit < length(locs_inbnds))
    loc_crit = loc_crit + 1;
    bAllInBnds = (sum(locs_inbnds(loc_crit:end))/length(locs_inbnds(loc_crit:end)) == 1);
end

%Retrieve the portion of the signal that stays in bounds.
ts_inbnds = ts( loc_crit:end );
ys_inbnds = ys_avg( loc_crit:end );

%Retrieve the Settling Time.
Settling_Time = ts_inbnds(1);

%% Compute the Settling Minimum & Maximum.

%Compute the Settling Minimum.
[Settling_Min, ind] = min(ys_inbnds);
Settling_Min_Time = ts_inbnds(ind);

%Compute the Settling Maximum.
[Settling_Max, ind] = max(ys_inbnds);
Settling_Max_Time = ts_inbnds(ind);


%% Compute the Percent Maximum Overshoot and Undershoot.

%Compute the PMO of the signal.
PMO = (100*(Peak - ys_ss))/ys_ss;

%Compute the PMU of the signal.
PMU = (100*(ys_ss - min(ys_avg)))/ys_ss;

%% Format the Output Structure.

%Create the output data structure that stores the step response charactersitics.
StepData.RiseTime = Rise_Time;
StepData.SettlingTime = Settling_Time;
StepData.SettlingMin = Settling_Min;
StepData.SettlingMax = Settling_Max;
StepData.Overshoot = PMO;
StepData.Undershoot = PMU;
StepData.Peak = Peak;
StepData.PeakTime = Peak_Time;

%% Plot the Step Response, if this option is set.

%Plot the step response characteristics, if requested.
if bPlotStepResponse                                                                                        %If we are asked to plot the step response characteristics...
    
    %Create a figure to store the step response.
    figure, hold on, grid on, title('Step Response'), ylabel('Amplitude [-]'), xlabel('Time [s]')
    
    %Plot the original step response signal.
    plot(ts, ys)
    
    %Plot the moving average step response signal.
    plot(ts, ys_avg)
    
    %Plot the Rise Time Points.
    plot(ts_rt, ys_rt, '.', 'Markersize', 20);
    
    %Plot the settling time bounds.
    h_bnd = plot(ts, SettlingBnds(1)*ones(1, length(ts)), '--');
    plot(ts, SettlingBnds(2)*ones(1, length(ts)), '--', 'Color', h_bnd.Color)
    
    %Plot the portion of the signal that stays in bounds.
    plot(ts_inbnds, ys_inbnds, 'Linewidth', 3)
    
    %Plot the settling time maximum and minimum values.
    plot(Settling_Min_Time, Settling_Min, '.', 'Markersize', 20)
    plot(Settling_Max_Time, Settling_Max, '.', 'Markersize', 20)
    
    %Plot the Peak value.
    plot(Peak_Time, Peak, '.', 'Markersize', 20)
    
    %Add a legend to the plot.
    legend('Original Signal', 'Moving Average Signal', 'Rise Time Points', 'Settling Time LB', 'Setting Time UB', 'Settled Signal', 'Settling Min', 'Settling Max', 'Peak', 'Location', 'Southeast')
end

end

