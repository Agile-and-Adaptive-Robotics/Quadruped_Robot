function [ Gc, a, T ] = GetLagController( Gs, Pm )

%Verify that the desired amount of added phase margin is within bounds.
if (Pm <= 0) || (Pm >= 180)
    error('The desired amount of phase margin must be in (0, 180).')
end

%Define the gain function.
fgain = @(x) 20*log10(bode(Gs, x));

%Define the phase margin function.
% fphase_margin = @(x) 180 + phase_func(Gs, x);                     %This version appears to be for when the phase is negative.
fphase_margin = @(x) phase_func(Gs, x) - 180;                       %This version appears to be for when the phase is positive.

%Retrieve the gain cross-over frequency.
[~, ~, ~, Wgc] = margin(Gs);

%Retrieve the frequency associated with this target phase margin.
wg = fzero( @(x) fphase_margin(x) - Pm, Wgc);

%Get the gain associated with this target gain cross over frequency.
Gp = fgain(wg);

%Compute the a parameter.
a = 10^(-abs(Gp)/20);

%Compute the T parameter.
T = 10/(wg*a);

%Define a transfer function variable.
s = tf('s');

%Define the lead controller.
Gc = (1 + a*T*s)/(1 + T*s);

    function [ phase ] = phase_func(Gs, w)
       
        [~, phase] = bode(Gs, w);
        
    end

end

