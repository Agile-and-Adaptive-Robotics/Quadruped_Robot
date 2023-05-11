clear;close all;clc;
%% Optimization 
%get parameters [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias]
%initialGuess=[-4.612173474021026e+02,23.158328148991920,-1.063925869261585e+04,-6.578556810735615e+03,-14.885236935699204,0.221662962060255];
%initialGuess = [-4.584529608866828e+02,1.407280982810701e+02,-1.836691662593935e+04,-5.192003202845893e+03,-4.263485490934336,0.125205833629962];
%get cost(this part is not nescessary)
%f = objectiveFunc(initialGuess)
%optimization
%initialGuess = [-4.575698136738724e+02,48.556754803082330,-1.564675449509693e+04,-5.188223638070525e+03,15.968758573183504,0.248315899160000,1000,1000,1000,0,0,0];
%initialGuess = [-335.329574732636,187.071771539942,-45843.1486977200,-5372.15319683253,2.66800608190523,0.501971610722854,-9996.53556871097,1298.19763599510,2172.84998603781,0.00894344594507502,-0.0127320150040902,0.0259485986838273];
%initialGuess = [-3.317400257482017e+02,-1.696860451197242e+03,-5.362747683915033e+03,12.959266937000670,-1.028740445490991e+04,1.387539774407501e+04,-0.007251459539645,0.254418701151231];
%initialGuess = [-3.282242789687175e+02,1.318385288182033e+04,-4.626331168439117e+03,-4.352505630343931,-6.885425815325230e+03,-1.365398506752757e+03,-1.774022002544357,0.289109621023439];
initialGuess = [-3.386918324484402e+02,-3.018358816792374e+04,-4.753851055418134e+03,84.734211006545620,-7.477597034545008e+03,3.085810335881361e+05,-1.796032245835559,0.403284250126195];
initialGuess = [-3.409739623845837e+02,-3.000556328078403e+04,-4.758966096409257e+03,80.316350178433280,-7.119138186764001e+03,3.083177319088344e+05,-1.812486842132088,0.213590863225588];
initialGuess = [-3.438023737158852e+02,-3.002788396447765e+04,-4.760650659239791e+03,79.740188435433780,-7.106090808201929e+03,3.085273071969314e+05,-1.807804817281253,0.211668563833744]
options = optimset('PlotFcns',{@optimplotfval,@optimplotx});
[jointValues,fval] = fminsearch(@objectiveFuncMMComplex,initialGuess,options);
%% Define Mechanical Properties 
% Define the mechanical properties of link 1.
M1 = .716;  %[lb] Mass of femur with encoder                   
R1 = 4.75; % [in]
L1 = 9.25; %[in]
I1 =  496.26;%(1/3)*M1*L1^2;%[in^4]

% Define the mechanical properties of link 2.
M2 = .4299; %[lb]
R2 = 6.25; %[in]
L2 = 9.25; %[in
I2 = 496.26; %(1/3)*M2*L2^2;[in^4]

% Define the mechanical properties of link 3.

M3 = 0.010992; %[lb]
R3 = 3.5; %[in]
L3 = 7.875;
I3 = 122.09;%(1/3)*M3*L3^2; %[in^4]

g = 9.81;
%Stores system paramters in a vector; 
P = [M1,R1,I1,L1,M2,R2,I2,L2,M3,R3,I3,L3,g];

%% Plot
%variables for simulation
dwrite = 0.00046;
dt = dwrite*4;
init_t=0;
N = 3751;
final_t= N*dt;
t_span=linspace(init_t,final_t,N);

x0=[0.104311 jointValues(7) -0.0230097 jointValues(8) 0 0]';
Lengths = [L1,L2,L3,N];
%prompt to ask if the user would like to plot
prompt = 'Would you like to plot?(Y/N): ';
fileName = input(prompt,'s');
if fileName == 'Y' || fileName == 'y'
    [t,x] = ode45(@(t,x) Dynamic_code_complex(t,x,P,jointValues),t_span,x0);
    [a] = ProcessMuscleMutt();
    plotLegs(x,a,Lengths);
     figure
plot(t,x(:,1),'r-',t,a(:,1),'b-');
title('Hip rotation');
xlabel('time (s)');
ylabel('radians');
legend('Optimized Model', 'Muscle Mutt Data');

figure
plot(t,x(:,3),'r-',t,a(:,2),'b-');
title('Knee rotation');
xlabel('time (s)');
ylabel('radians');
legend('Optimized Model', 'Muscle Mutt Data');

figure
plot(t,x(:,5),'r-',t,a(:,3),'b-');
title('Ankle rotation');
xlabel('time (s)');
ylabel('radians');
legend('Optimized Model', 'Muscle Mutt Data');
else
end
