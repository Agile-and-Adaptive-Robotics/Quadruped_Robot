function [ Gz_lead ] = GetzLeadController( Gz, Pm_add )

%Retrieve the sampling time associated with the digital state space model.
[~, ~, dt] = tfdata( Gz );

%Throw an error if this system is not digital.
if dt == 0, error('G must be a digital transfer function.'); end

%Convert the uncontrolled digital system transfer function to the w-domain.
Gw = d2c(Gz, 'Tustin');


% %Generate the frequency response data assocaited with this DVD OL transfer function.
% [mag_OL, phase_OL, wout_OL] = bode(Gw);
% 
% %Reshape the frequency response data assocaited with this DVD OL transfer function.
% [mag_OL, phase_OL] = deal( reshape(mag_OL, size(wout_OL)), reshape(phase_OL, size(wout_OL)) );
% 
% %Plot the magnitude response of the DVD OL system.
% figure, subplot(2, 1, 1), hold on, grid on, set(gca, 'XScale', 'log'), title('DVD: Magnitude Response (OL w-Domain)'), xlabel('Frequency [Hz]'), ylabel('Magnitude [dB]'), xlim([wout_OL(1)/(2*pi), wout_OL(end)/(2*pi)])
% plot(wout_OL/(2*pi), 20*log10(mag_OL), '-', 'Linewidth', 1)
% 
% %Plot the phase response of the DVD OL system.
% subplot(2, 1, 2), hold on, grid on, set(gca, 'XScale', 'log'), title('HDD: Phase Response (OL w-Domain)'), xlabel('Frequency [Hz]'), ylabel('Phase [deg]'), xlim([wout_OL(1)/(2*pi), wout_OL(end)/(2*pi)])
% plot(wout_OL/(2*pi), phase_OL, '-', 'Linewidth', 1)
% saveas(gcf, 'ME560_Lab7_HDD_wOL_Bode.jpg')

%Get the lead controller for this target added phase margin.
Gw_lead = GetLeadController( Gw, Pm_add );

%Convert the lead controller from the w-domain to the z-domain.
Gz_lead = c2d(Gw_lead, dt, 'Tustin');

end

