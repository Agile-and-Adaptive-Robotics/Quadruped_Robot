%% Material Testing Data Processing

%Clear Everything
clear, close('all'), clc

%% Read in and Plot the Material Testing Data.

%Define the path to the material testing data.
material_testing_directory = 'C:\Users\USER\Documents\Coursework\MSME\Thesis\Material_Testing_Data';

%Define the group types used for naming.
group_types = {'Horizontal', 'Vertical'};

%Compute the number of specified group types.
num_group_types = length(group_types);

%Define the number of groups.
num_groups = 12;

%Plot the data from each group.
for k1 = 1:num_groups                                                                       %Iterate through each of the groups...
    
    %Generate the current group number.
    group_name = sprintf('Group %0.0f', k1);
    
    %Plot the data from each group type.
    for k2 = 1:num_group_types                                                              %Iterate through each of the group types...
        
        %Define the group number with its type.
        type_name = [sprintf('Group %0.0f ', k1), group_types{k2}];
        
        %Generate the full directory path.
        full_directory = [material_testing_directory, '\', group_name, '\', type_name];
        
        %Retrieve all of the file properties in this directory.
        listing = dir(full_directory); listing = listing(3:end);
        
        %Retrieve the number of files in this directory.
        num_files = length(listing);
        
        %Plot the data from each of the files in the current directory.
        for k3 = 1:num_files                                                                %Iterate through each file in this directory...
            
            %Retrieve the current file name.
            file_name = listing(k3).name;
            
            %Read in the data from this file.
            data = readmatrix([full_directory, '\', file_name]);
            
            %Store the data from this file into separate variables for convienence.
            ts = data(:, 1); fs = data(:, 2); ps = data(:, 3); stresses = data(:, 4); strains = data(:, 5);
            
            %Plot the data contained in this file.
            figure('color', 'w', 'name', file_name)
            subplot(2, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Force [N]'), title('Force vs Time'), plot(ts, fs, 'Linewidth', 3)
            subplot(2, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Position [mm]'), title('Position vs Time'), plot(ts, ps, 'Linewidth', 3)
            subplot(2, 2, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Stress [Pa]'), title('Stress vs Time'), plot(ts, stresses, 'Linewidth', 3)
            subplot(2, 2, 4), hold on, grid on, xlabel('Time [s]'), ylabel('Strain [%]'), title('Strain vs Time'), plot(ts, strains, 'Linewidth', 3)
            
        end
        
    end
    
end
