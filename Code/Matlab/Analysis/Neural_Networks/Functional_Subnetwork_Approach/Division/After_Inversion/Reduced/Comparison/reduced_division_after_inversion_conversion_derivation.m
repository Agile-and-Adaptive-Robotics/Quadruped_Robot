%% Reduced Division After Inversion Subnetwork Conversion Derivation.

% This script determines division subnetwork conversion constraints.

% Clear everything.
clear, close( 'all' ), clc


%% Setup Design Constants.

% Define the symbolic variables.
syms ca1 ca2 cr1 cr2 Ra1 Ra2 Ra3 Rr1 Rr2 Rr3 deltaa1 deltaa2 deltar1 deltar2 U1 U2 U3a U3r

% Define symbolic variable assumptions.
assume( [ ca1 ca2 cr1 cr2 Ra1 Ra2 Ra3 Rr1 Rr2 Rr3 deltaa1 deltaa2 deltar1 deltar2 U1 U2 U3a U3r ], 'real' )                 % Assume that all variables are real.
assume( [ ca1 ca2 cr1 cr2 Ra1 Ra2 Ra3 Rr1 Rr2 Rr3 deltaa1 deltaa2 deltar1 deltar2 ] > 0 )                                   % Assume that most of the variables are positive.


%% Setup Absolute & Relative Division After Inversion Constraints. 

% Define maximum voltage constraints.
Ra1 = Rr1;                                                                                                                          % [V] Maximum Voltage (Neuron 1) (a = Absolute Formulation, r = Relative Formulation)
Ra2 = Rr2;                                                                                                                          % [V] Maximum Voltage (Neuron 2) (a = Absolute Formulation, r = Relative Formulation)
Ra3 = Rr3;                                                                                                                          % [V] Maximum Voltage (Neuron 3) (a = Absolute Formulation, r = Relative Formulation)

% Define the steady state membrane voltage offset.
deltaa1 = deltar1;                                                                                                                  % [V] Membrane Voltage Offset (a = Absolute Formulation, r = Relative Formulation)
deltaa2 = deltar2;                                                                                                                  % [V] Membrane Voltage Offset (a = Absolute Formulation, r = Relative Formulation)

% Define the absolute division design constants.
ca1 = ( ( deltaa1 - Ra2 )*deltaa2*Ra3 )/( ( deltaa2 - Ra3 )*Ra1 );                                                  % [?] Absolute Division Design Constant 1
ca2 = ( ca1*Ra1 - deltaa2*Ra2 )/( deltaa2 );                                                                                    % [?] Absolute Division Design Constant 2

% Define the relative division design constants.
cr1 = ( ( Rr2 - deltar1 )*deltar2 )/( ( Rr3 - deltar2 )*Rr2 );                                                              % [?] Relative Division Design Constant 1
cr2 = ( deltar2*Rr2 - deltar1*Rr3 )/( ( Rr3 - deltar2 )*Rr2 );                                                                  % [?] Relative Division Design Constant 2

% Define the absolute & relative division steady state membrane voltages.
Ua3 = ( ca1*U1 )/( U2 + ca2 );                                                                                                  % [V] Absolute Steady State Membrane Voltage
Ur3 = ( cr1*Rr2*Rr3*U1 )/( Rr1*U2 + cr2*Rr1*Rr2 );                                                                              % [V] Relative Steady State Membrane Voltage


%% Compute Additional Conversion Constraints.

% Retrieve the numerator and denominator of each formulation.
[ Ua3_num, Ua3_den ] = numden( Ua3 );
[ Ur3_num, Ur3_den ] = numden( Ur3 );

% Define the additional conversion constraint equation.
eq = Ua3_num*Ur3_den - Ua3_den*Ur3_num == 0;

% Collect like terms in the additional conversion constraint equation.
eq = collect( eq, U2 );

