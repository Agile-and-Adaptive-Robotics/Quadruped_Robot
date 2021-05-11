%get parameters [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias]
initialGuess = [-9,-9,-10,0,0,0,0,0,0];
%get cost
f = objectiveFunc(initialGuess);
%optimization
jointValues = fminsearch(@objectiveFunc,initialGuess)