%% Bang-Bang Pressure Data Plotting.

%Clear Everything
clear, close('all'), clc

%% Define the Voltage & Pressure Domains.

%Define the voltage domain.
v_domain = [0 4.83];

%Define the pressrue domain.
p_domain = [0 90];

%% Read in the Bang-Bang Pressure Data.

%Define the sampling rate.
dt = 0.02;

%Define the pressure offset to apply.
pressure_offset = 0.55;

%Read in the Bang-Bang Pressure Data Without Flow Rate Limits.
pressure_data1 = csvread('C:\Users\USER\Documents\Coursework\MSME\Thesis\AARL_Puppy_18_00_000\Control\Bang_Bang_Control_Testing\Pressure_Data\NewFile1.csv', 2, 0);

%Align the pressure data.
pressure_data1(:, 3) = pressure_data1(:, 3) - pressure_offset;

%Create a time vector for this data.
ts_pdata1 = linspace2(0, dt, size(pressure_data1, 1));

%Read in the Bang-Bang Pressure Data With Flow Rate Limits.
pressure_data2 = csvread('C:\Users\USER\Documents\Coursework\MSME\Thesis\AARL_Puppy_18_00_000\Control\Bang_Bang_Control_Testing\Pressure_Data\NewFile1_Flow_Rate_Limited.csv', 2, 0);

%Align the pressure data.
pressure_data2(:, 3) = pressure_data2(:, 3) - pressure_offset;

%Create a time vector for this data.
ts_pdata2 = linspace2(0, dt, size(pressure_data2, 1));

%% Compute Summary Statistics of the Data.

%Define a vector of indexes associated with a steady state pressure value.
ts1 = 262:401;

%Retrieve a steady state subsection of the pressure.
ys1 = pressure_data1(ts1, 3);

%Compute the average steady state value.
ys1_avg = mean(ys1);

%Retrieve the data range.
ys1_range = range(ys1);

%Convert the voltage range to a pressure range.
ps1_range = interp1(v_domain, p_domain, ys1_range);

%Define a vector of indexes associated with a steady state pressure value.
ts2 = 476:629;

%Retrieve a steady state subsection of the pressure.
ys2 = pressure_data2(ts2, 3);

%Compute the average steady state value.
ys2_avg = mean(ys2);

%Retrieve the data range.
ys2_range = range(ys2);

%Convert the voltage range to a pressure range.
ps2_range = interp1(v_domain, p_domain, ys2_range);

%Plot the steady state pressures.
figure, hold on, grid on, xlabel('Time [s]'), ylabel('Pressure Voltage [V]'), title('Pressure Voltage vs Time'), plot(ts1, ys1, '-')

%Plot the steady state pressures.
figure, hold on, grid on, xlabel('Time [s]'), ylabel('Pressure Voltage [V]'), title('Pressure Voltage vs Time'), plot(ts2, ys2, '-')


%% Plot the Bang-Bang Pressure Data in Units of Voltage

%Plot the bang-bang pressure data with and without flow rate limits.
figure, set(gcf, 'color', 'w')
subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Pressure Voltage [V]'), title('No Flow Rate Limit: Pressure Voltage vs Time'), plot(pressure_data1(:, 1), pressure_data1(:, 2), '-'), plot(pressure_data1(:, 1), pressure_data1(:, 3), '-')
subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Pressure Voltage [V]'), title('Flow Rate Limit: Pressure Voltage vs Time'), plot(pressure_data2(:, 1), pressure_data2(:, 2), '-'), plot(pressure_data2(:, 1), pressure_data2(:, 3), '-')

%% Plot the Bang-Bang Pressure Data in Units of Pressure

%Convert the pressure data from voltages to pressures.
pressure_data1(:, 2:3) = interp1(v_domain, p_domain, pressure_data1(:, 2:3), 'linear', 'extrap'); pressure_data2(:, 2:3) = interp1(v_domain, p_domain, pressure_data2(:, 2:3), 'linear', 'extrap');

%Plot the bang-bang pressure data with and without flow rate limits.
figure, set(gcf, 'color', 'w')
subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Pressure [psi]'), title('(a) Unrestricted Flow Rate: Pressure Voltage vs Time'), ylim([0 70]), plot(ts_pdata1, pressure_data1(:, 2), '-'), plot(ts_pdata1, pressure_data1(:, 3), '-')
subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Pressure [psi]'), title('(b) Restricted Flow Rate: Pressure Voltage vs Time'), ylim([0 70]), plot(ts_pdata2, pressure_data2(:, 2), '-'), plot(ts_pdata2, pressure_data2(:, 3), '-')
legend('Target Pressure', 'Actual Pressure', 'Orientation', 'Horizontal', 'Location', 'South')

%Save the bang-bang pressure data plot.
saveas(gcf, 'Bang_Bang_Pressure_Data.jpg')

