%% Bang-Bang Control Testing Plotting

%Clear Everything
clear, close('all'), clc

%% Read in the Raw Pressure Data.

%Define the directory in which the data files are saved.
dir_name = 'C:\Users\USER\Documents\Coursework\MSME\Thesis\AARL_Puppy_18_00_000\Control\Bang_Bang_Control_Testing\Pressure_Data3';

%Define the critical file numbers.
file_nums_crit = [7 2 6 1];

%Define the number of files.
num_files = length(file_nums_crit);

%Define the linewidth and markersize for plotting.
line_width = 1; marker_size = 20;

%Define the font sizes to use when plotting.
axis_font_size = 18; legend_font_size = 18; title_font_size = 18;

%Define the pressure offsets to use.
ps_desired_offsets = [0.64 0.64 0.64 0.64]; ps_actual_offsets = [0.48 0.48 0.48 0.48];

%Define the pressure scaling to use.
ps_desired_scalings = (90/3.12)*ones(1, num_files); ps_actual_scalings = (90/3.44)*ones(1, num_files);

%Compute the number of figures to make.
num_figs = ceil(num_files/2);

%Set the current number of existing figures to zero.
fig_num = 0;

%Create a variable to store the figure handles.
fig_handles = cell(1, num_figs);

%Plot the data associated with each of the data files.
for k = 1:num_files
    
    %Define the current file number.
    file_num = num2str(file_nums_crit(k));
    
    %Generate the current file name.
    file_name = ['NewFile', file_num, '.csv'];
    
    %Generate the full path to the current file.
    full_path_name = [dir_name, '\' file_name];
    
    %Read in the step size, count number, desired pressure, and actual pressure from the current file.
    dt = csvread(full_path_name, 1, 3); data = csvread(full_path_name, 2, 0);
    
    %Store the step size, count number, desired pressure, and actual pressure in their own variables.
    dt = dt(1, 2); ns = data(:, 1); ps_desired = data(:, 2); ps_actual = data(:, 3);
    
    %Adjust the actual and desired pressure with offsets and scaling.
    ps_desired = ps_desired_scalings(k)*(ps_desired - ps_desired_offsets(k)); ps_actual = ps_actual_scalings(k)*(ps_actual - ps_actual_offsets(k));
    
    %Use the step size and count number to generate the time vector associated with the desired and actual pressure data.
    ts = dt*ns;
    
    %Determine the number of data points in this data set.
    num_data_points = length(ts);
    
    %% Process the Pressure Data as Desired.
    
    %Determine the percentage of points to include in the moving average window.
    percent_to_average = 0.01;
    
    %Compute the number of points to use in the moving average.
    num_to_average = round(percent_to_average*num_data_points);
    
    %Apply a moving average filter to the desired and actual pressure data.
    ps_desired_movmean = movmean(ps_desired, num_to_average); ps_actual_movmean = movmean(ps_actual, num_to_average);
    
    %% Plot the Pressure Data.
    
    %     %Plot the raw desired pressure and actual pressure data.
    %     figure, hold on, grid on, xlabel('Time [s]'), ylabel('Pressure [V]'), title('BPA Pressure vs Time'), set(gcf, 'color', 'w'), ylim([0 4])
    %     plot(ts, ps_desired, '.-', 'Linewidth', line_width, 'Markersize', marker_size), plot(ts, ps_actual, '.-', 'Linewidth', line_width, 'Markersize', marker_size)
    %     legend({'Target Pressure', 'Actual Pressure'}, 'Location', 'South', 'Orientation', 'Horizontal')
    
    %     %Plot the moving average filtered desired pressure and actual pressure data.
    %     figure, hold on, grid on, xlabel('Time [s]'), ylabel('Pressure [V]'), title('BPA Pressure vs Time'), set(gcf, 'color', 'w'), ylim([0 4])
    %     plot(ts, ps_desired_movmean, '.-', 'Linewidth', line_width, 'Markersize', marker_size), plot(ts, ps_actual_movmean, '.-', 'Linewidth', line_width, 'Markersize', marker_size)
    %     legend({'Target Pressure', 'Actual Pressure'}, 'Location', 'South', 'Orientation', 'Horizontal')
    
    %     %Overlay the raw desired pressure and actual pressure data with the moving average filtered desired pressure and actual pressure data.
    %     figure, hold on, grid on, xlabel('Time [s]'), ylabel('Pressure [V]'), title('BPA Pressure vs Time'), set(gcf, 'color', 'w'), ylim([0 4])
    %     plot(ts, ps_desired, '.'), plot(ts, ps_actual, '.'), plot(ts, ps_desired_movmean), plot(ts, ps_actual_movmean)
    %     legend({'Target Pressure', 'Actual Pressure'}, 'Location', 'South', 'Orientation', 'Horizontal')
    
    %Determine whether to create a new figure for this data or add it to an existing figure.
    if mod(k, 2)                                                %If this is an odd iteration...
        
        %Advance the current figure counter.
        fig_num = fig_num + 1;
        
        %Create a new figure with the desired properties.
        fig_handles{fig_num} = figure; set(gcf, 'color', 'w'), subplot(2, 1, 1), title('(a) Unrestricted BPA Pressure vs Time', 'Fontsize', title_font_size)
        
    else                                                        %Otherwise... (The iteration number is even...)
        
        %Format the next subplot.
        subplot(2, 1, 2), title('(b) Restricted BPA Pressure vs Time', 'Fontsize', title_font_size)
        
    end
    
    %Format the current subplot with universal settings and plot the BPA pressure data.
    hold on, grid on, xlabel('Time [s]', 'Fontsize', axis_font_size), ylabel('BPA Pressure [psi]', 'Fontsize', axis_font_size), xlim([0 30]), ylim([-20 100])
    plot(ts, ps_desired, '.-', 'Linewidth', line_width, 'Markersize', marker_size), plot(ts, ps_actual, '.-', 'Linewidth', line_width, 'Markersize', marker_size)
    legend({'Desired Pressure', 'Actual Pressure'}, 'Location', 'South', 'Orientation', 'Horizontal', 'Fontsize', legend_font_size)
    
end

%% Save the BPA Pressure Plots.

%Define the possible figure titles to use when saving.
figure_names = {'Step_Response', 'Frequency_Response'};

%Define the screen size precentage to use.
screen_size_precentage = 0.75;

%Retrieve the screen size.
screen_size = get(0, 'Screensize');

%Define the target position.
% screen_size(3:4) = screen_size_precentage*screen_size(3:4);
screen_size(3) = screen_size_precentage*screen_size(3);

%Define the directory in which to save the figures.
save_directory = 'C:\Users\USER\Documents\Coursework\MSME\Thesis\AARL_Puppy_18_00_000\Pictures\DoggyDeux Pictures';

%Save each of the figures.
for k = 1:num_figs                                  %Iterate through each of the figures...
    
    %Get the position of this figure.
    fig_position = fig_handles{k}.Position;
        
    %Maximize the current figure.
    set(fig_handles{k}, 'Position', screen_size);
    
    %Generate the file name to use for the saved file.
    save_file_name = ['BPA_Pressure_', figure_names{k}, '_Wide.jpg'];
    
    %Save the current figure.
    saveas(fig_handles{k}, save_file_name)
    
    %Save the current figure to the DoggyDeux pictures directory.
    saveas(fig_handles{k}, [save_directory, '\', save_file_name])
    
    %Reset the size of the figure to the default figure size.
    set(fig_handles{k}, 'Position', fig_position);
    
end
