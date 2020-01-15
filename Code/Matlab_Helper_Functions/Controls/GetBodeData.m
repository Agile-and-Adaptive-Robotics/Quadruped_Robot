function [ mag_est, phase_est ] = GetBodeData( Gs, ws )

%Retrieve the bode data associated with this transfer function.
[mag_est, phase_est] = bode(Gs, ws);

%Reshape the bode data.
mag_est = reshape(mag_est, size(ws)); phase_est = reshape(phase_est, size(ws));

%Convert the magnitude data to decibles.
mag_est = 20*log10(mag_est);

end

