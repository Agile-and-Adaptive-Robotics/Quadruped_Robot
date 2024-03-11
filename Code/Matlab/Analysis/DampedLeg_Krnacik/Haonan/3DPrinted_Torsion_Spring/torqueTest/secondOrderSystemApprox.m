names = {'5CW' '5CCW' '10CW' '10CCW' '20CW' '20CCW'};

tr = [tr5CW tr5CCW tr10CW tr10CCW tr20CW tr20CCW];
ts = [ts5CW ts5CCW ts10CW ts10CCW ts20CW ts20CCW];

I = 6.16561;        % kg*mm^2
T = torque*1000;    % kg*mm^2/s^2

zeta = zeros(1,length(ts));
omegan = zeros(1,length(ts));
b = zeros(1,length(ts));
k = zeros(1,length(ts));

s = tf('s');

for ii = 1:length(tr)
zeta(ii) = dampingRatio(tr(ii),ts(ii));
omegan(ii) = (4.5*zeta(ii))/ts(ii);
b(ii) = 2*I*zeta(ii)*omegan(ii);
k(ii) = I*omegan(ii)^2;

sys = T/(I*s^2 + b(ii)*s + k(ii));
figure
step(sys)
title(names(ii))
xlim([0 12E3])
end
