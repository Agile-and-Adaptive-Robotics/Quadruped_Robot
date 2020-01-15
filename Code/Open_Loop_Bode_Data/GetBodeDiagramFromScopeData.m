%% Get Bode Diamgra From Scope Data.
%This script computes magnitude and phase data from frequency response signals.

%Clear Everything
clear, close('all'), clc

%% Setup to Read in Signals.

%Define the number of files to read.
num_files = 30;

%Define the directory name.
dir_name = 'C:\Users\USER\Documents\Coursework\MSME\Thesis\AARL_Puppy_18_00_000\Control\Open_Loop_Bode_Data\Open_Loop_Frequency_Response_Signals_3';

%Determine whether to create plots.
bMakePlots = false;

%Determine whether to print out the results.
bVerbose = true;

%Define the frequencies to use.
fs = logspace(-1, 1, 30);

%% Read in the Scope Signals.

%Preallocate arrays to store the magnitude and phase responses.
[Ms, Ps] = deal( zeros(1, num_files) );

%Define a the number of points to remove from each signal.
ns = 90*ones(1, num_files);
ns(11) = 100; ns(29) = 150; ns(30) = 50;

%Compute the magnitude and phase associated with each signal.
for k = 1:num_files                                                 %Iterate through each signal...
    
    %Define the file name.
    file_name = sprintf('NewFile%0.0f.csv', k);
    
    %Create the full path string.
    path_name = strcat(dir_name, '\', file_name);
    
    %Read in frequency response data.
    data = csvread(path_name, 2, 0); data(:, end) = [];
    
    %Read in the starting time.
    t0 = csvread(path_name, 1, 3); t0 = t0(1);
    
    %Read in the step size.
    step_size = csvread(path_name, 1, 4); step_size = step_size(1);
    
    %Compute the sampling frequency.
    fsample = 1/step_size;
    
    %Convert the sequence into a time vector.
    data(:, 1) = step_size*data(:, 1) + t0;
    
    %Define the number of data points to remove.
%     n = 250;
    
    %Store the data as separate variables.
    ts = data(ns(k):size(data, 1) - ns(k), 1); ys1 = data(ns(k):size(data, 1) - ns(k), 2); ys2 = data(ns(k):size(data, 1) - ns(k) ,3);
    
    %Define the cutoff frequency.
    fcut = 0.025*fsample;
    
    %Create a butterworth filter to apply to the data.
    [b, a] = butter(6, 2*(fcut/fsample));
    
    %Filter the data.
    zs1 = filter(b, a, ys1); zs2 = filter(b, a, ys2);
    
%     %Fit the raw data.
%     f1 = fit(ts, ys1, 'sin3'); f2 = fit(ts, ys2, 'sin2');
%     
%     %Evaluate the fitted curves.
%     zs1 = f1(ts); zs2 = f2(ts);
    
    
    %% Compute the Magnitude Associated with these Signals.
    
    %Compute the maximum and minimum values from each signal.
    [zs1_max, zs1_min] = deal( max(zs1), min(zs1) );
    [zs2_max, zs2_min] = deal( max(zs2), min(zs2) );
    
    %Compute the amplitude of each signal.
    zs1_amp = (zs1_max - zs1_min)/2;
    zs2_amp = (zs2_max - zs2_min)/2;
    
    %Compute the magnitude ratio.
    M = zs2_amp/zs1_amp;
    
    %Store the magnitude ratio into an array.
    Ms(k) = M;
    
    %% Compute the Phase Associated with these Signals.
    
    %Estimate the first derivative of each signal.
    [dzs1, dzs2] = deal( diff(zs1)./diff(ts), diff(zs2)./diff(ts) );
    
    %Compute sign change locations.
    [locs1, locs2] = deal( find(dzs1(1:end-1)>0 & dzs1(2:end) < 0), find(dzs2(1:end-1)>0 & dzs2(2:end) < 0));
    
    %Retrieve the maximum times.
    [ts1_maxes, ts2_maxes] = deal( ts(locs1), ts(locs2) );
    
    %Compute the average period of the input signal.
    period_input = mean(diff(ts1_maxes));
    
    %Compute the average frequency of the input signal.
    freq_input = 1/period_input;
    
    %Compute the signal delay.
    delay = ts2_maxes(end) - ts1_maxes(end);
    
    %Compute the phase shift.
    P = -360*freq_input*delay;
    
    %Store the phase shift into an array.
    Ps(k) = P;
    
    %Store the frequency into an array.
%     fs(k) = freq_input;
    
    %% Plot the Signals.
    
    %Determine whether to make the plots.
    if bMakePlots
        
        %Close all existing plots.
        close all
        
        %Plot the fitted signals and their derivatives.
        figure, hold on, grid on
        plot(ts, zs1, 'b'), plot(ts(1:end-1), dzs1)
        plot(ts, zs2, 'r'), plot(ts(1:end-1), dzs2)
        
        %Plot the fitted signals and the selected maximums.
        figure, hold on, grid on
        plot(ts, zs1, 'b'), plot(ts(locs1), zs1(locs1), '.b', 'Markersize', 20)
        plot(ts, zs2, 'r'), plot(ts(locs2), zs2(locs2), '.r', 'Markersize', 20)
        
        %Plot the original signals and the fitted signals.
        figure, hold on, grid on
        plot(ts, ys1(1:length(ts)), '-b'), plot(ts, zs1, '--g')
        plot(ts, ys2(1:length(ts)), '-r'), plot(ts, zs2, '--k')
        
    end
    
    %% Print out the Magnitude & Phase Result.
    
    if bVerbose
        
        %Print out the magnitude & phase result.
        fprintf('Trial:     %0.0f [#]\n', k)
        fprintf('Frequency: %0.4f [Hz]\n', freq_input)
        fprintf('Magnitude: %0.16e [-]\n', M)
        fprintf('Phase:     %0.16e [deg]\n\n', P)
        
    end
    
end

%% Plot the Magnitude and Phase Reponse.

%Plot the magnitude & phase response.
figure, subplot(2, 1, 1), hold on, grid on, set(gca, 'XScale', 'log'), title('BPA: Magnitude Response (OL)'), xlabel('Frequency [Hz]'), ylabel('Magnitude [dB]')
plot(fs, 20*log10(Ms), '.k', 'Markersize', 20)

subplot(2, 1, 2), hold on, grid on, set(gca, 'XScale', 'log'), title('DC Motor: Phase Response (OL)'), xlabel('Frequency [Hz]'), ylabel('Phase [deg]')
plot(fs, Ps, '.k', 'Markersize', 20)

%% Write the Data to a Seperate File.

%Write the data to a seperate file.
dlmwrite('OpenLoopBodeData.txt', [fs' Ms' Ps'])

%% Fit a Transfer Function to the Bode Diagram.

% %Define the natural frequencies and damping ratios to search.
% wns = linspace(100, 500, 50);
% zetas = linspace(.1, 2, 50);
% 
% %Define the magnitude and phase weighting.
% mag_weight = 0.8; phase_weight = 0.2;
% 
% %Set whether to plot the fit and error surface.
% bPlotFit = true;
% bPlotErrorSurface = false;
% 
% %Fit a transfer function to the bode diagram.
% [ Ktotal, wn_crit, zeta_crit ] = OLBode2TF( fs, Ms, Ps, wns, zetas, mag_weight, phase_weight, bPlotFit, bPlotErrorSurface );


