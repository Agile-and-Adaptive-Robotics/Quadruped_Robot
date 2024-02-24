function [Umid, slope] = GetAnimatlabmhinfProperties(Amh, Smh, dEmh)

% This function takes the sodium channel activation / deactivation properties Amh, Smh, and dEmh used to define the steady state sodium channel activation / deactivation parameter in our analytical methods and converts them to the parameters that Animatlab uses to describe these same curves.

% Compute the midpoint of the steady state sodium channel activation / deactivation parameter curve.
Umid = GetInvSteadyStateNaActDeactValue(0.5, Amh, Smh, dEmh);

% Compute the slope at the midpoint of the steady state sodium channel activation / deactivation parameter curve.
slope = -Amh.*Smh.*exp(Smh.*(Umid - dEmh))./((1 + Amh.*exp(Smh.*(Umid - dEmh))).^2);

end

