%% Force / Length Requirements.

%Clear Everything
clear, close('all'), clc

%% Setup the System.

%Define the z-axis rotation matrix.
fR = @(x) [cos(x) -sin(x) 0; sin(x) cos(x) 0; 0 0 1];

%Define the moment necessary to move the limb.
M = 1;

%Define the joint location
P1 = [0; 0; 1];

%Define the radius / distance from the joint to the muscle attachment location.
r = 1;

%Define maximum limb angle with respect to the global frame.
% theta_max = 135*(pi/180);
theta_max = 251*(pi/180);

%Define the template point we will use to rotate into position for the muscle attachment point.
P2_template = [r; 0; 1];

%Define the starting limb location.
P2 = fR(theta_max)*P2_template;

%Define the pulley location.
P3 = [P1(1) + 1; P1(2) + 3; 1];

%Compute the vector from P1 to P3.
P31 = P3 - P1;

%Compute the minimum limb angle with respect to the global frame.
theta_min = atan2( P31(2), P31(1) );

%Assemble the first two points into a matrix to store the limb points.
Ps_limb = [P1 P2];

%Assemble the second two points into a matrix to store the string points.
Ps_string = [P2 P3];

%Compute the vector from P2 to P3.
P32 = P3 - P2;

%Compute the initial string length.
L0_string = norm(P32(1:2), 2);

%Setup a plot of these three points.
figure, hold on, grid on, set(gcf, 'color', 'w'), set(gca, 'XColor', 'w', 'YColor', 'w'), title('Muscle-Limb Simulation')
plot(P1(1, :), P1(2, :), '.', 'Markersize', 20), plot(P2(1, :), P2(2, :), '.', 'Markersize', 20), plot(P3(1, :), P3(2, :), '.', 'Markersize', 20)
plot(Ps_limb(1, :), Ps_limb(2, :), '-'), plot(Ps_string(1, :), Ps_string(2, :), '-')


%% Setup the Simulation.

%Define the minimum and maximum radii of interest.
r_max = 2; r_min = 0.25;

%Define the radius step size.
r_step = 0.25;

%Define the radii of interest.
rs = r_min:r_step:r_max;

%Compute the number of radii to simulate.
num_radii = length(rs);

%Define the theta step size to simulate.
theta_step = 1*(pi/180);

%Define the thetas of interest.
thetas = theta_max:(-theta_step):theta_min; thetas_deg = (180/pi)*thetas;

%Compute the number of thetas in the simulation.
num_thetas = length(thetas);

%Define a vector of the simulation time steps.
time_steps = 1:num_thetas;

%Preallocate arrays to store the string length and required force.
[Ls_string, Fs] = deal( zeros(num_radii, num_thetas) );

%Compute the required force and length change at each angle for each radius.
for k1 = 1:num_radii                    %Iterate through each of the radii...
    
    %Define the template point we will use to rotate into position for the muscle attachment point.
    P2_template = [rs(k1); 0; 1];
    
    %Compute the required force and length change at each angle for this radius.
    for k2 = 1:num_thetas                %Iterate through each of the thetas...
        
        %Compute the current muscle attachment location.
        P2 = fR(thetas(k2))*P2_template;
        
        %Compute the vector from P2 to P3.
        P32 = P3 - P2;
        
        %Compute the current length of the string.
        Ls_string(k1, k2) = norm(P32(1:2), 2);
        
        %Compute the string angle with respect to the global frame.
        gamma = atan2( P32(2), P32(1) );
        
        %Compute the angle between the the limb and the string.
        phi = thetas(k2) - gamma;
        
        %Compute the force required to move the limb at this location.
        Fs(k1, k2) = (M/r)*csc(phi);
        
    end
    
end

%Compute the string length change associated with each step
dLs_string = Ls_string - L0_string;

%% Plot the Applied Force Requirement vs Time & Limb Angle.

%Plot the required force vs time.
figure, hold on, grid on, xlabel('Time Step [#]'), ylabel('Required Force [N]'), title('Required Force vs Time Step'), plot(time_steps, Fs)

%Plot the required force vs angle.
figure, hold on, grid on, xlabel('Limb Angle [deg]'), ylabel('Required Force [N]'), title('Required Force vs Limb Angle'), plot(thetas_deg, Fs)

%% Plot the Change in String Length Requirement vs Time & Limb Angle.

%Plot the required string length vs time.
figure, subplot(1, 2, 1), hold on, grid on, xlabel('Time Step [#]'), ylabel('Required String Length [m]'), title('Required String Length vs Time Step'), plot(time_steps, Ls_string)
subplot(1, 2, 2), hold on, grid on, xlabel('Time Step [#]'), ylabel('Required Change in String Length [m]'), title('Required Change in String Length vs Time Step'), plot(time_steps, dLs_string)

%Plot the required string length vs limb angle.
figure, subplot(1, 2, 1), hold on, grid on, xlabel('Limb Angle [deg]'), ylabel('Required String Length [m]'), title('Required String Length vs Limb Angle'), plot(thetas_deg, Ls_string)
subplot(1, 2, 2), hold on, grid on, xlabel('Limb Angle [deg]'), ylabel('Required Change in String Length [m]'), title('Required Change in String Length vs Limb Angle'), plot(thetas_deg, dLs_string)


