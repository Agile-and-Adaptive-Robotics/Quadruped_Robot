%% Delta Analysis

% Clear Everything.
clear, close('all'), clc


%% Setup the Problem.

% Define the neuron properties.
Gm = 1e-6;
R = 20e-3;

% Define the sodium channel properties.
dEna = 110e-3;

dEh = 0;
Sh = 50;
Ah = 0.5;

dEm = 40e-3;
Sm = -50;
Am = 1;

% Define the synapse properties.
dEs = -40e-3;

% Define the sodium channel steady state activation and deactivation functions.
fminf = @( U ) 1./( 1 + Am.*exp( -Sm.*( dEm - U ) ) );
fhinf = @( U ) 1./( 1 + Ah.*exp( -Sh.*( dEh - U ) ) );

% Compute the sodium channel conductance.
Gna = ( Gm*R )/( fminf( R )*fhinf( R )*( dEna - R ) );

% Set the initial delta value.
delta0 = 0;

% Compute the synaptic conductance.
gs = ( -Gm*delta0 + Gna*fminf( delta0 )*fhinf( delta0 )*( dEna - delta0 ) )/( delta0 - dEs );


%% Compute the Effective Deltas.

% Define the delta function.
f = @( delta, Iapp ) -Gm*delta + gs*( dEs - delta ) + Gna*fminf( delta )*fhinf( delta )*( dEna - delta ) + Iapp;

% Define the number of applied currents.
num_Iapps = 100;

% Define the applied currents of interest.
Iapps = linspace( 0, 1e-9, num_Iapps );

% Preallocate an array to store the effective deltas.
deltas = zeros( 1, num_Iapps );

% Compute each of the effective deltas.
for k = 1:num_Iapps
    
   deltas( k ) = fzero( @( delta ) f( delta, Iapps(k) ), delta0 ); 
    
end


%% Plot the Results.

% Plot the effective deltas.
figure( 'Color', 'w' ), hold on, grid on, xlabel('Iapp [A]'), ylabel('Effective delta [V]'), title('Effective Delta vs Applied Current')
plot( Iapps, deltas, '-', 'Linewidth', 3 )


