function [ sys_r ] = convert_matlab_ss( sys )

% Converts Matlab's state space form resulting from tf2ss to standard form

sys_r = xperm(sys, order(sys):-1:1);  % Reorder the states
sys_r.b = sys_r.b*sys_r.c(1);          % Switch the constant from C( my notation the [D] matrix) to B
sys_r.c = sys_r.c/sys_r.c(1);

end
