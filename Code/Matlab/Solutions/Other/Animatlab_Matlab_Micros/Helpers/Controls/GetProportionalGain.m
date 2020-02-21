function [ Kp ] = GetProportionalGain( Gs, s_design )

%Retrieve the numerator and denominator associated with the open loop transfer function.
[Gs_num, Gs_den] = tfdata(Gs);

%Compute the gain associated with the design point.
Kp = abs(polyval(Gs_den{:}, s_design))/abs(polyval(Gs_num{:}, s_design));

end

