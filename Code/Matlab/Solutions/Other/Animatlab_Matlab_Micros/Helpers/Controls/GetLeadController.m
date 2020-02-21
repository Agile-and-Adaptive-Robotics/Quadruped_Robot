function [ Gc, a, T ] = GetLeadController( Gs, Pm_add )

%Verify that the desired amount of added phase margin is within bounds.
if (Pm_add <= 0) || (Pm_add >= 90)
    error('The desired amount of added phase margin must be in (0, pi/2).')
end
    
%Define the gain function.
fgain = @(x) 20*log10(bode(Gs, x));

%Compute the a parameter.
a = (1 + sind(Pm_add))./(1 - sind(Pm_add));

%Determine the target gain level.
Gp = -10*log10(a);

%Retrieve the gain cross-over frequency.
[~, ~, ~, Wgc] = margin(Gs);

%Retrieve the frequency associated with this target gain level.
wm = fzero( @(x) fgain(x) - Gp, Wgc);

%Compute the T parameter.
T = 1/(sqrt(a)*wm);

%Define a transfer function variable.
s = tf('s');

%Define the lead controller.
Gc = (1 + a*T*s)/(1 + T*s);

end

