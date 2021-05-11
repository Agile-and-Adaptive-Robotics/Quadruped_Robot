%get parameters [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias]
initialGuess = [0.25,0.25,-0.25,0,0,0,0,0,0];
%get cost
f = objectiveFunc2(initialGuess);
%optimization
jointValues = fminsearch(@objectiveFunc2,initialGuess)


