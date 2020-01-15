function [ Gc, Kp, Ki ] = GetPIController( Gs, Pm )

%Retrieve the gain cross-over frequency.
[~, ~, ~, Wgc] = margin(Gs);

%Define the gain function.
fgain = @(x) 20*log10(bode(Gs, x));

%Define the phase margin function.
% fphase_margin = @(x) 180 + phase_func(Gs, x);
fphase_margin = @(x) -180 + phase_func(Gs, x);

%Retrieve the frequency associated with this target phase margin.
wg = fzero( @(x) fphase_margin(x) - Pm, Wgc);

%Get the gain associated with this target gain cross over frequency.
Gp = fgain(wg);

%Compute the proportional constant.
Kp = 10^(-Gp/20);

%Compute the integral constant.
Ki = Kp*(wg/10);

%Create a transfer function variable.
s = tf('s');

%Define the PI controller transfer function.
Gc = Kp + Ki/s;

%Define the phase function.
    function [ phase ] = phase_func(Gs, x)
       
        [~, phase] = bode(Gs, x);
        
    end


end

