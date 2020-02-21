function [ StrcFull, StrcPartial ] = GetOpAmpRValues( k_gain, rs_full, bInvertingOpAmp, bPlotGainSurface, bPrintSelectionResults )
%% Set the Default Values and Catch Invalid User Inputs.

%Set the default values.
if nargin < 5, bPrintSelectionResults = false; end              %Turn off the printing option.
if nargin < 4, bPlotGainSurface = false; end                    %Turn off the plotting option.
if nargin < 3, bInvertingOpAmp = false; end

%Ensure that the gain is positive if a non-inverting op-amp is selected.
if (~bInvertingOpAmp) && (k_gain <= 1), error('Gain must be greater than unity for non-inverting op-amps.'); end

%% Define the Ideal Resistor and Capacitor Range.

%Select the subset of resistor and capacitor values that are ideal to use.
rs_partial = rs_full((rs_full >= 5000) & (rs_full <= 50000));

%% Compute the Resistor Combination that Achieves the Desired Gain.

%Create a grid of the resistor values.
[Rs1_full, Rs2_full] = meshgrid( rs_full, rs_full );
[Rs1_partial, Rs2_partial] = meshgrid( rs_partial, rs_partial );

%Compute the gain associated with each resistor combination.
if bInvertingOpAmp
    ks_full = Rs2_full./Rs1_full;
    ks_partial = Rs2_partial./Rs1_partial;
else
    ks_full = 1 + Rs2_full./Rs1_full;
    ks_partial = 1 + Rs2_partial./Rs1_partial;
end

%Compute gain error.
e_full = ks_full - k_gain;
e_partial = ks_partial - k_gain;

%Compute the minimum error from both resistor sets.
e_full_min = min(min(abs(e_full)));
e_partial_min = min(min(abs(e_partial)));

%Compute the rows and columns associated with these minimums.
[row_full, col_full] = find( abs(e_full) == e_full_min );
[row_partial, col_partial] = find( abs(e_partial) == e_partial_min );

%Retrieve the valid resistor values.
[Rs1_full_valid, Rs2_full_valid] = deal( Rs1_full(row_full, col_full), Rs2_full(row_full, col_full) );
[Rs1_partial_valid, Rs2_partial_valid] = deal( Rs1_partial(row_partial, col_partial), Rs2_partial(row_partial, col_partial) );

%Retrieve the unique valid resistor and capacitor values.
[Rs1_full_valid, Rs2_full_valid] = deal( Rs1_full_valid(1, :), Rs2_full_valid(:, 1)' );
if (~isempty(Rs1_partial_valid)) && (~isempty(Rs2_partial_valid))
    [Rs1_partial_valid, Rs2_partial_valid] = deal( Rs1_partial_valid(1, :), Rs2_partial_valid(:, 1)' );
end

%Compute the achieved break frequencies.
if bInvertingOpAmp
    ks_full_valid = Rs2_full_valid./Rs1_full_valid;
    ks_partial_valid = Rs2_partial_valid./Rs1_partial_valid;
else
    ks_full_valid = 1 + Rs2_full_valid./Rs1_full_valid;
    ks_partial_valid = 1 + Rs2_partial_valid./Rs1_partial_valid;
end

%Compute the achieved errors.
Es_full_valid = ks_full_valid - k_gain;
Es_partial_valid = ks_partial_valid - k_gain;

% Compute the achieved error percentages.
Es_full_valid_percent = 100*Es_full_valid/k_gain;
Es_partial_valid_percent = 100*Es_partial_valid/k_gain;


%% Create Structures of the Valid Resistances, Capacitances, Break Frequencies, and Errors for Output.

%Create the full output data structure.
[StrcFull.Rs, StrcFull.Cs, StrcFull.Fs, StrcFull.Es]  = deal( Rs1_full_valid , Rs2_full_valid, ks_full_valid, Es_full_valid );

%Create the partial output data structure.
[StrcPartial.Rs, StrcPartial.Cs, StrcPartial.Fs, StrcPartial.Es]  = deal( Rs1_partial_valid , Rs2_partial_valid, ks_partial_valid, Es_partial_valid );

%% Plot the Break Frequency Surface.

if bPlotGainSurface
    
    %Create a plane at the gain level.
    ks_plane_full = k_gain*ones(size(Rs1_full, 1), size(Rs1_full, 2));
    ks_plane_partial = k_gain*ones(size(Rs1_partial, 1), size(Rs1_partial, 2));
    
    %Plot the full gain surface.
    fig1 = figure; hold on, grid on, title(sprintf('Gains (Full, k = %0.0f [-]) vs Resistance 1 & Resistance 2', k_gain)), zlabel('Gains [-]'), ylabel('Resistance 2 [Ohm]'), xlabel('Resistance 1 [Ohm]'), view(30, 30), rotate3d on
    h1 = surf(Rs1_full, Rs2_full, ks_full, 'Facecolor', 'b', 'Facealpha', 0.5, 'Edgecolor', 'none'); h2 = surf(Rs1_full, Rs2_full, ks_plane_full, 'Facecolor', 'r', 'Facealpha', 0.5, 'Edgecolor', 'none'); h3 = plot3(Rs1_full(:), Rs2_full(:), ks_full(:), '.k', 'Markersize', 20); h4 = plot3(Rs1_full_valid, Rs2_full_valid, ks_full_valid, '.r', 'Markersize', 20);
    legend([h1 h2 h3 h4], {'Break Frequency Surface', 'Target Break Frequency', 'Possible RC Values', 'Critical RC Values'})
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    
    %Plot the partial gain surface.
    fig2 = figure; hold on, grid on, title(sprintf('Gains (Ideal, k = %0.0f [-]) vs Resistance 1 & Resistance 2', k_gain)), zlabel('Gains [-]'), ylabel('Resistance 2 [Ohm]'), xlabel('Resistance 1 [Ohm]'), view(30, 30), rotate3d on
    h1 = surf(Rs1_partial, Rs2_partial, ks_partial, 'Facecolor', 'b', 'Facealpha', 0.5, 'Edgecolor', 'none'); h2 = surf(Rs1_partial, Rs2_partial, ks_plane_partial, 'Facecolor', 'r', 'Facealpha', 0.5, 'Edgecolor', 'none'); h3 = plot3(Rs1_partial(:), Rs2_partial(:), ks_partial(:), '.k', 'Markersize', 20); h4 = plot3(Rs1_partial_valid, Rs2_partial_valid, ks_partial_valid, '.r', 'Markersize', 20);
    legend([h1 h2 h3 h4], {'Gain Surface', 'Target Gain', 'Possible R Values', 'Critical R Values'})
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    
    %Save the figures.
    saveas(fig1, sprintf('FullGainSurface_k%0.0f.jpg', k_gain)), saveas(fig2, sprintf('PartialGainSurface_k%0.0f.jpg', k_gain))
    
end

%% Print out the Computed Results.

if bPrintSelectionResults
    
    %Print out a header for this data.
    fprintf('Valid Op-Amp Resistance Values\n')
    
    %Print out the valid resistor values from the full selection.
    fprintf('Full Selection Results\n')
    for k = 1:length(Rs1_full_valid)
        fprintf('R1 = %0.3e [Ohm], R2 = %0.3e [Ohm], k = %0.3e [-], E = %0.3f [-], %%E = %0.3f [%%].\n', Rs1_full_valid(k), Rs2_full_valid(k), ks_full_valid(k), Es_full_valid(k), Es_full_valid_percent(k))
    end
    
    %Print out the valid resistor and capacitor values from the ideal selection.
    fprintf('\nIdeal Selection Results\n')
    for k = 1:length(Rs1_partial_valid)
        fprintf('R1 = %0.3e [Ohm], R2 = %0.3e [Ohm], k = %0.3e [-], E = %0.3f [-], %%E = %0.3f [%%].\n', Rs1_partial_valid(k), Rs2_partial_valid(k), ks_partial_valid(k), Es_partial_valid(k), Es_partial_valid_percent(k))
    end
    
    %Add a new line for formatting purposes.
    fprintf('\n')
    
end


end

