%% Division Subnetwork Conversion Derivation

% This script determines division subnetwork conversion constraints.

% Clear everything.
clear, close( 'all' ), clc


%% Setup Design Constants.

% Define the symbolic variables.
syms ca1 ca2 ca3 cr1 cr2 cr3 Ra1 Ra2 Ra3 Rr1 Rr2 Rr3 deltaa deltar U1 U2 U3a U3r

% Define symbolic variable assumptions.
assume( [ ca1 ca2 ca3 cr1 cr2 cr3 Ra1 Ra2 Ra3 Rr1 Rr2 Rr3 deltaa deltar U1 U2 U3a U3r ], 'real' )               % Assume that all variables are real.
assume( [ ca1 ca2 ca3 cr1 cr2 cr3 Ra1 Ra2 Ra3 Rr1 Rr2 Rr3 deltaa deltar ] > 0 )                                 % Assume that most of the variables are positive.


%% Setup Absolute & Relative Division Constraints. 

% Define maximum voltage constraints.
Ra1 = Rr1;                                                      % [V] Maximum Voltage (Neuron 1) (a = Absolute Formulation, r = Relative Formulation)
Ra2 = Rr2;                                                      % [V] Maximum Voltage (Neuron 2) (a = Absolute Formulation, r = Relative Formulation)
Ra3 = Rr3;                                                      % [V] Maximum Voltage (Neuron 3) (a = Absolute Formulation, r = Relative Formulation)

% Define the steady state membrane voltage offset.
deltaa = deltar;                                                % [V] Membrane Voltage Offset (a = Absolute Formulation, r = Relative Formulation)

% Define the absolute division design constants.
ca1 = ( Rr3/Rr1 )*ca3;                                          % [?] Absolute Division Design Constant 1
ca2 = ( Ra1*ca1 - deltaa*ca3 )/( deltaa*Ra2 );                  % [?] Absolute Division Design Constant 2

% Define the relative division design constants.
cr1 = cr3;                                                      % [?] Relative Division Design Constant 1
cr2 = ( Rr3*cr1 - deltar*cr3 )/deltar;                          % [?] Relative Division Design Constant 2

% Define the absolute & relative division steady state membrane voltages.
Ua3 = ( ca1*U1 )/( ca2*U2 + ca3 );                              % [V] Absolute Steady State Membrane Voltage
Ur3 = ( cr1*Rr2*Rr3*U1 )/( cr2*Rr1*U2 + cr3*Rr1*Rr2 );          % [V] Relative Steady State Membrane Voltage


%% Compute Additional Conversion Constraints.

% Retrieve the numerator and denominator of each formulation.
[ Ua3_num, Ua3_den ] = numden( Ua3 );
[ Ur3_num, Ur3_den ] = numden( Ur3 );

% Define the additional conversion constraint equation.
eq = Ua3_num*Ur3_den - Ua3_den*Ur3_num == 0;

% Collect like terms in the additional conversion constraint equation.
eq = collect( eq, U2 );

