%% Inversion Subnetwork Conversion

% Clear everything.
clear, close( 'all' ), clc


%% Setup the design constants.

% Define the symbolic variables.
syms ca1 ca2 ca3 cr1 cr2 cr3 Ra1 Ra2 Ra3 Rr1 Rr2 Rr3 deltaa deltar U1 U2 U3a U3r

assume( [ ca1 ca2 ca3 cr1 cr2 cr3 Ra1 Ra2 Ra3 Rr1 Rr2 Rr3 deltaa deltar U1 U2 U3a U3r ], 'real' )
assume( [ ca1 ca2 ca3 cr1 cr2 cr3 Ra1 Ra2 Ra3 Rr1 Rr2 Rr3 deltaa deltar ] > 0 )

Ra1 = Rr1;
Ra2 = Rr2;
Ra3 = Rr3;
deltaa = deltar;

ca1 = ( Rr3/Rr1 )*ca3;
ca2 = ( Ra1*ca1 - deltaa*ca3 )/( deltaa*Ra2 );

cr1 = cr3;
cr2 = ( Rr3*cr1 - deltar*cr3 )/deltar;

Ua3 = ( ca1*U1 )/( ca2*U2 + ca3 );
Ur3 = ( cr1*Rr2*Rr3*U1 )/( cr2*Rr1*U2 + cr3*Rr1*Rr2 );

[ Ua3_num, Ua3_den ] = numden( Ua3 );
[ Ur3_num, Ur3_den ] = numden( Ur3 );

eq = Ua3_num*Ur3_den - Ua3_den*Ur3_num == 0;
eq = collect( eq, U2 );


% % Define the design constants.
% % cr2 = ( R2 - delta )*cr3/delta;
% 
% eq1 = ca1 == ( cr1*R1*R2*ca2 )/cr2;
% eq2 = ca2 == ( ca1 - delta*ca3 )/( delta*R1 );
% eq3 = ca3 == ( cr3*R1*ca2 )/cr2;
% 
% sol = solve( [ eq1, eq2, eq3 ], [ ca1, ca2, ca3 ] );



