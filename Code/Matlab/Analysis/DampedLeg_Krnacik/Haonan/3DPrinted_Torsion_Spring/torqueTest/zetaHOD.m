function zeta = zetaHOD(ts,omegan)

% this function is used to calculate the damping ratio of a heavily
% overdamped second order system with settling time and natural frequency
% as inputs. Settling time must be calculated with the criteria of ±5%
% steady state value

zeta = -(log(0.05)^2 + ts^2*omegan^2)/(2*ts*omegan*log(0.05));
end