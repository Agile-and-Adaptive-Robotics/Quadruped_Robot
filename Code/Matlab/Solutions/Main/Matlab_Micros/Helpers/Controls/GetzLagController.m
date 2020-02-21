function [ Gz_lag ] = GetzLagController( Gz, Pm )

%Retrieve the sampling time associated with the digital state space model.
[~, ~, dt] = tfdata( Gz );

%Throw an error if this system is not digital.
if dt == 0, error('G must be a digital transfer function.'); end

%Convert the uncontrolled digital system transfer function to the w-domain.
Gw = d2c(Gz, 'Tustin');

%Get the lead controller for this target added phase margin.
Gw_lag = GetLagController( Gw, Pm );

%Convert the lead controller from the w-domain to the z-domain.
Gz_lag = c2d(Gw_lag, dt, 'Tustin');

end