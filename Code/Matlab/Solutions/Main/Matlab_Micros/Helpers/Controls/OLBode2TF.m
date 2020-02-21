function [ Ktotal, wn_crit, zeta_crit ] = OLBode2TF( Freqs, Mag_Normal, Phase, wns, zetas, mag_weight, phase_weight, bPlotFit, bPlotErrorSurface )
%% Set the Default Arguments.

if nargin < 7, bPlotErrorSurface = false; end
if nargin < 6, bPlotFit = false; end


%% Determine the Least Squares Model Parameters.

%Define the frequency domain.
fDomain = [Freqs(1) Freqs(end)];

%Define a transfer function variable.
s = tf('s');

%Define the starting bode diagram gain.
Ktotal = Mag_Normal(1);

%Define a vector to store the weighted errors.
weighted_errors = zeros(length(wns), length(zetas));

%Plot the theoretical model associated with each natural frequency option.
for k1 = 1:length(wns)           %Iterate through all of the natural frequencies...
    for k2 = 1:length(zetas)     %Iterate through all of the damping ratios...
        
        %Choose the current natural frequency and damping ratio.
        wn = wns(k1); zeta = zetas(k2);
        
        %Define the current theoretical model.
        Gs = (Ktotal*(wn^2))/(s^2 + (2*wn*zeta)*s + (wn^2));
        
        %Generate the theoretical Motor Bode Response Data.
        %         [mag, phase, wout] = bode(Gs, ws);
        [mag, phase, wout] = bode(Gs, {2*pi*fDomain(1), 2*pi*fDomain(2)});
        
        %Reshape the Motor Bode Response Data.
        [mag, phase] = deal( reshape(mag, size(wout)), reshape(phase, size(wout)) );
        
        %Interpolate the magnitude & phase response at the measurement frequencies.
        mag_interp = interp1(wout/(2*pi), mag, Freqs);
        phase_interp = interp1(wout/(2*pi), phase, Freqs);
        
        %Compute the magnitude and phase error.
        mag_error = abs(20*log10(mag_interp) - 20*log10(Mag_Normal));
        phase_error = abs(phase_interp - Phase);
        
        %Compute the error magnitude components..
        mag_norm = norm(mag_error); phase_norm = norm(phase_error);
        
        %Weight the errors.
        weighted_errors(k2, k1) = mag_weight*mag_norm + phase_weight*phase_norm;
        
    end
end

%Compute the minimum weighted error.
min_weighted_error = min(min(weighted_errors));

%Find the indexes associated with the minimum weighted error.
[min_row, min_col] = find(weighted_errors == min_weighted_error);

%Retrieve the natural frequency and damping ratio associated with minimum error.
wn_crit = wns(min_col); zeta_crit = zetas(min_row);


%% Plot the Experimental Data and Least Squares Model.

%Determine whether to plot the least squares model.
if bPlotFit
    
    %Define the least squares theoretical model.
    Gs = (Ktotal*(wn_crit^2))/(s^2 + (2*wn_crit*zeta_crit)*s + (wn_crit^2));
    
    %Retrieve the bode data associated with the least squares model.
    [mag, phase, wout] = bode(Gs, {2*pi*fDomain(1), 2*pi*fDomain(2)});
    
    %Reshape the Motor Bode Response Data.
    [mag, phase] = deal( reshape(mag, size(wout)), reshape(phase, size(wout)) );
    
    %Plot the frequency response magnitude data.
    figure; subplot(2, 1, 1), hold on, grid on, set(gca, 'XScale', 'log'), title('Magnitude Response'), xlabel('Frequency [Hz]'), ylabel('Magnitude [dB]')
    plot(wout/(2*pi), 20*log10(mag), '-', 'Linewidth', 3), plot(Freqs, 20*log10(Mag_Normal), '.', 'Markersize', 20)
    
    %Plot the frequency response phase data.
    subplot(2, 1, 2), hold on, grid on, set(gca, 'XScale', 'log'), title('Phase Response'), xlabel('Frequency [Hz]'), ylabel('Phase [deg]')
    plot(wout/(2*pi), phase, '-', 'Linewidth', 3), plot(Freqs, Phase, '.', 'Markersize', 20)
    
end

%% Plot the Least Squares Error Surface.

%Determine whether to plot the least squares error surface.
if bPlotErrorSurface
    
    %Create a mesh of natural frequencies and zetas.
    [Wns, Zetas] = meshgrid( wns, zetas );
    
    %Plot the weight error surface.
    figure, hold on, grid on, title('Weighted Error vs Natural Frequency & Damping Ratio'), xlabel('Natural Frequency [rad/s]'), ylabel('Damping Ratio [-]'), zlabel('Weighted Error [-]'), view(-30, 15), rotate3d on
    surf(Wns, Zetas, weighted_errors, 'Edgecolor', 'none', 'Facealpha', 0.75)
    
end

end

