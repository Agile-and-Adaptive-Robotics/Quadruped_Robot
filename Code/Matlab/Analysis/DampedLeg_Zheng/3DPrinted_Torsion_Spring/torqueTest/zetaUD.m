function zeta = zetaUD(ts,omegan)

% this function is used to calculate the damping ratio of a heavily
% overdamped second order system with settling time and natural frequency
% as inputs. Settling time must be calculated with the criteria of ±5%
% steady state value

zeta = (ts*omegan)/4.5;
end