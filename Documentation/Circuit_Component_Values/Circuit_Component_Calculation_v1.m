%% Circuit Component Calculation.

%Clear Everything
clear, close('all'), clc


%% Define Available Resistor & Capacitor Values.

%Define the available resistors.
rs_available = dlmread('C:\Users\USER\Documents\MATLAB\MyFunctions\Controls\ResistorKitValues.txt');

%Define the available capacitors.
cs_available = dlmread('C:\Users\USER\Documents\MATLAB\MyFunctions\Controls\CapacitorKitValues.txt');


%% Compute the Second Order Filter Circuit Components for the Potentiometers.

%Define the desired cut-off frequency for the potentiometer filters.
f_cut_pots = 100;   %[Hz] Potentiometer Cut-Off Frequency.

%Print out the circuit to which these circuit components apply.
fprintf('\n\nPOTENTIOMETER 4 FILTER CIRCUIT\n')

%Compute the Second Order Filter Circuit Components for the Potentiometers.
[ RC_Filter_Strc_Full_Pots, RC_Filter_Strc_Ideal_Pots ] = GetLowPassFilterRCValues( f_cut_pots, rs_available, cs_available, 2, false, true );        %Compute the circuit components required to achieve a filter with the specified cut-off frequency.


%% Compute the Second Order Filter Circuit Components for the Pressure Sensors.

%Define the desired cut-off frequency.
f_cut_psens = 500;	%[Hz] Pressure Sensor Cut-Off Frequency.

%Print out the circuit to which these circuit components apply.
fprintf('\n\nPRESSURE SENSOR 5 FILTER CIRCUIT\n')

%Compute the Second Order Filter Circuit Components for the Pressure Sensors.
[ RC_Filter_Strc_Full_Psens, RC_Filter_Strc_Ideal_Psens ] = GetLowPassFilterRCValues( f_cut_psens, rs_available, cs_available, 2, false, true );     %Compute the circuit components required to achieve a filter with the specified cut-off frequency.


%% Define the Filtered Voltage Ranges for the Potentiometers & Pressure Sensors.

%Define the supply voltage.
V_supply = 5.2;                         %[V] Supply Voltage.

%Define the desired microcontroller voltage range.
V_domain_micro = [0 5];                 %[V] Acceptable voltage range for the microcontroller.
% V_domain_micro = [0.200 4.8];         %[V] Acceptable voltage range for the microcontroller.

%Define the filtered potentiometer voltage ranges.
V_domain_pot1 = [9.6 17.4];             %[V] Domain of Pot1 output voltages.
V_domain_pot2 = [12.2 20.0];            %[V] Domain of Pot2 output voltages.
V_domain_pot3 = [2.20 11.4];            %[V] Domain of Pot3 output voltages.
% V_domain_pot4 = [2.8 11.8];           %[V] Domain of Pot4 output voltages.
V_domain_pot4 = [3.2 12.4];             %[V] Domain of Pot4 output voltages.

%Define the filtered pressure sensor voltage ranges.
V_domain_psen3 = [0.600 4.17];
% V_domain_psen5 = [0.600 4.17];
V_domain_psen5 = [0.284 3.99];



%% Compute the Required Gains & Offsets to Map Each Filtered Circuit to 0-5V.

%Compute the required bipolar to single ended gains for the potentiometers.
[ ks_pot1, v_offset_pot1 ] = GetBipolar2SingleEndedGains( V_domain_pot1, V_domain_micro, V_supply );                %Bipolar to singled ended gains for potentiometer 1.
[ ks_pot2, v_offset_pot2 ] = GetBipolar2SingleEndedGains( V_domain_pot2, V_domain_micro, V_supply );                %Bipolar to singled ended gains for potentiometer 2.
[ ks_pot3, v_offset_pot3 ] = GetBipolar2SingleEndedGains( V_domain_pot3, V_domain_micro, V_supply );                %Bipolar to singled ended gains for potentiometer 3.
[ ks_pot4, v_offset_pot4 ] = GetBipolar2SingleEndedGains( V_domain_pot4, V_domain_micro, V_supply );                %Bipolar to singled ended gains for potentiometer 4.

%Compute the required bipolar to single ended gains for the fifth pressure sensor.
[ ks_psen3, v_offset_psen3 ] = GetBipolar2SingleEndedGains( V_domain_psen3, V_domain_micro, V_supply );
[ ks_psen5, v_offset_psen5 ] = GetBipolar2SingleEndedGains( V_domain_psen5, V_domain_micro, V_supply );




%% Compute the Amplifier / Summer Circuit Component Values.

%Compute the circuit component values necessary to achieve the bipolar to singled ended gains for the first potentiometer.
fprintf('\n\nPOTENTIOMETER 1\n')
[ Rs_Strc_Full_k1_Pot1, Rs_Strc_Partial_k1_Pot1 ] = GetOpAmpRValues( ks_pot1(1), rs_available, true, false, true );
[ Rs_Strc_Full_k2_Pot1, Rs_Strc_Partial_k2_Pot1 ] = GetOpAmpRValues( ks_pot1(2), rs_available, true, false, true );

%Compute the circuit component values necessary to achieve the bipolar to singled ended gains for the second potentiometer.
fprintf('\n\nPOTENTIOMETER 2\n')
[ Rs_Strc_Full_k1_Pot2, Rs_Strc_Partial_k1_Pot2 ] = GetOpAmpRValues( ks_pot2(1), rs_available, true, false, true );
[ Rs_Strc_Full_k2_Pot2, Rs_Strc_Partial_k2_Pot2 ] = GetOpAmpRValues( ks_pot2(2), rs_available, true, false, true );

%Compute the circuit component values necessary to achieve the bipolar to singled ended gains for the third potentiometer.
fprintf('\n\nPOTENTIOMETER 3\n')
[ Rs_Strc_Full_k1_Pot3, Rs_Strc_Partial_k1_Pot3 ] = GetOpAmpRValues( ks_pot3(1), rs_available, true, false, true );
[ Rs_Strc_Full_k2_Pot3, Rs_Strc_Partial_k2_Pot3 ] = GetOpAmpRValues( ks_pot3(2), rs_available, true, false, true );

%Compute the circuit component values necessary to achieve the bipolar to singled ended gains for the fourth potentiometer.
fprintf('\n\nPOTENTIOMETER 4\n')
[ Rs_Strc_Full_k1_Pot4, Rs_Strc_Partial_k1_Pot4 ] = GetOpAmpRValues( ks_pot4(1), rs_available, true, false, true );
[ Rs_Strc_Full_k2_Pot4, Rs_Strc_Partial_k2_Pot4 ] = GetOpAmpRValues( ks_pot4(2), rs_available, true, false, true );

%Compute the circuit component values necessary to achieve the bipolar to singled ended gains for the third pressure sensor.
fprintf('\n\nPRESSURE SENSOR 3\n')
[ Rs_Strc_Full_k1_Psen3, Rs_Strc_Partial_k1_Psen3 ] = GetOpAmpRValues( ks_psen3(1), rs_available, true, false, true );
[ Rs_Strc_Full_k2_Psen3, Rs_Strc_Partial_k2_Psen3 ] = GetOpAmpRValues( ks_psen3(2), rs_available, true, false, true );

%Compute the circuit component values necessary to achieve the bipolar to singled ended gains for the fifth pressure sensor.
fprintf('\n\nPRESSURE SENSOR 5\n')
[ Rs_Strc_Full_k1_Psen5, Rs_Strc_Partial_k1_Psen5 ] = GetOpAmpRValues( ks_psen5(1), rs_available, true, false, true );
[ Rs_Strc_Full_k2_Psen5, Rs_Strc_Partial_k2_Psen5 ] = GetOpAmpRValues( ks_psen5(2), rs_available, true, false, true );

fprintf('\n\nTESTING\n')
GetOpAmpRValues( 1.25, rs_available, false, false, true );
GetOpAmpRValues( 1.4, rs_available, false, false, true );




