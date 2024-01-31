%% Inversion Subnetwork Conversion Derivation

% This script determines inversion subnetwork conversion constraints.

% Clear everything.
clear, close( 'all' ), clc


%% Setup Design Constants.

% Define the symbolic variables.
syms ca1 ca2 ca3 cr1 cr2 cr3 Ra1 Ra2 Ra3 Rr1 Rr2 Rr3 deltaa deltar U1 U2a U2r

% Define symbolic variable assumptions.
assume( [ ca1 ca2 ca3 cr1 cr2 cr3 Ra1 Ra2 Rr1 Rr2 deltaa deltar U1 U2a U2r ], 'real' )                  % Assume that all variables are real.
assume( [ ca1 ca2 ca3 cr1 cr2 cr3 Ra1 Ra2 Rr1 Rr2 deltaa deltar ] > 0 )                                 % Assume that most of the variables are positive.


%% Setup Absolute & Relative Inversion Constraints. 

% Define maximum voltage constraints.
Ra1 = Rr1;                                                      % [V] Maximum Voltage (Neuron 1) (a = Absolute Formulation, r = Relative Formulation)
Ra2 = Rr2;                                                      % [V] Maximum Voltage (Neuron 2) (a = Absolute Formulation, r = Relative Formulation)

% Define the steady state membrane voltage offset.
deltaa = deltar;                                                % [V] Membrane Voltage Offset (a = Absolute Formulation, r = Relative Formulation)

% Define the absolute inversion design constants.
ca1 = Rr2*ca3;                                          % [?] Absolute Inversion Design Constant 1
ca2 = ( ca1 - deltaa*ca3 )/( deltaa*Ra1 );                  % [?] Absolute Inversion Design Constant 2

% Define the relative inversion design constants.
cr1 = cr3;                                                      % [?] Relative Inversion Design Constant 1
cr2 = ( Rr2 - deltar )*cr3/deltar;                          % [?] Relative Inversion Design Constant 2

% Define the absolute & relative inversion steady state membrane voltages.
Ua2 = ( ca1 )/( ca2*U1 + ca3 );                              % [V] Absolute Steady State Membrane Voltage
Ur2 = ( cr1*Rr1*Rr2 )/( cr2*U1 + cr3*Rr1 );          % [V] Relative Steady State Membrane Voltage


%% Compute Additional Conversion Constraints.

% Retrieve the numerator and denominator of each formulation.
[ Ua2_num, Ua2_den ] = numden( Ua2 );
[ Ur2_num, Ur2_den ] = numden( Ur2 );

% Define the additional conversion constraint equation.
eq = Ua2_num*Ur2_den - Ua2_den*Ur2_num == 0;

