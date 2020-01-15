function [ StrcFull, StrcPartial ] = GetLowPassFilterRCValues( f_break, rs_full, cs_full, order, bPlotFrequencySurfaces, bPrintSelectionResults )
%% Set the Default Values and Catch Invalid User Inputs.

%Set the default values.
if nargin < 6, bPrintSelectionResults = false; end              %Turn off the printing option.
if nargin < 5, bPlotFrequencySurfaces = false; end              %Turn off the plotting option.
if nargin < 4, order = 1; end                                   %Set the filter to be first order.

%Ensure that the order is set to either 1 or 2.
if (order ~= 1) && (order ~= 2)
    warning('The filter order must be either 1 or 2.  Defaulting to order = 1.')
    order = 1;
end

%% Define the Ideal Resistor and Capacitor Range.

%Select the subset of resistor and capacitor values that are ideal to use.
[rs_partial, cs_partial] = deal( rs_full((rs_full >= 5000) & (rs_full <= 50000)), cs_full((cs_full >= 0.01e-6) & (cs_full <= 1e-6)) );

%% Compute the Resistor and Capacitor Combination that Achieves the Desired Break Frequency.

%Create a grid of the resistor and capacitor values.
[Rs_full, Cs_full] = meshgrid( rs_full, cs_full );
[Rs_partial, Cs_partial] = meshgrid( rs_partial, cs_partial );

%Compute the break frequency associated with each resistor and capacitor pair.
if order == 1
    Fs_full = 1./(2*pi*Rs_full.*Cs_full);
    Fs_partial = 1./(2*pi*Rs_partial.*Cs_partial);
elseif order == 2
    Fs_full = 0.3742./(2*pi*Rs_full.*Cs_full);
    Fs_partial = 0.3742./(2*pi*Rs_partial.*Cs_partial);
else
    error('The filter order must be 1 or 2. Filter order could not be corrected.')
end

%Compute the break frequency error.
e_full = Fs_full - f_break;
e_partial = Fs_partial - f_break;

%Compute the minimum error from both resistor and capacitor sets.
e_full_min = min(min(abs(e_full)));
e_partial_min = min(min(abs(e_partial)));

%Compute the rows and columns associated with these minimums.
[row_full, col_full] = find( abs(e_full) == e_full_min );
[row_partial, col_partial] = find( abs(e_partial) == e_partial_min );

%Retrieve the valid resistor and capacitor values.
[Rs_full_valid, Cs_full_valid] = deal( Rs_full(row_full, col_full), Cs_full(row_full, col_full) );
[Rs_partial_valid, Cs_partial_valid] = deal( Rs_partial(row_partial, col_partial), Cs_partial(row_partial, col_partial) );

%Retrieve the unique valid resistor and capacitor values.
[Rs_full_valid, Cs_full_valid] = deal( Rs_full_valid(1, :), Cs_full_valid(:, 1)' );
if (~isempty(Rs_partial_valid)) && (~isempty(Cs_partial_valid))
    [Rs_partial_valid, Cs_partial_valid] = deal( Rs_partial_valid(1, :), Cs_partial_valid(:, 1)' );
end

%Compute the achieved break frequencies.
if order == 1
    Fs_full_valid = 1./(2*pi*Rs_full_valid.*Cs_full_valid);
    Fs_partial_valid = 1./(2*pi*Rs_partial_valid.*Cs_partial_valid);
elseif order == 2
    Fs_full_valid = 0.3742./(2*pi*Rs_full_valid.*Cs_full_valid);
    Fs_partial_valid = 0.3742./(2*pi*Rs_partial_valid.*Cs_partial_valid);
else
    error('The filter order must be 1 or 2. Filter order could not be corrected.')
end

%Compute the achieved errors.
Es_full_valid = Fs_full_valid - f_break;
Es_partial_valid = Fs_partial_valid - f_break;

%% Create Structures of the Valid Resistances, Capacitances, Break Frequencies, and Errors for Output.

%Create the full output data structure.
[StrcFull.Rs, StrcFull.Cs, StrcFull.Fs, StrcFull.Es]  = deal( Rs_full_valid , Cs_full_valid, Fs_full_valid, Es_full_valid );

%Create the partial output data structure.
[StrcPartial.Rs, StrcPartial.Cs, StrcPartial.Fs, StrcPartial.Es]  = deal( Rs_partial_valid , Cs_partial_valid, Fs_partial_valid, Es_partial_valid );

%% Plot the Break Frequency Surface.

if bPlotFrequencySurfaces
    
    %Create a plane at the desired break frequency level.
    Fs_plane_full = f_break*ones(size(Rs_full, 1), size(Rs_full, 2));
    Fs_plane_partial = f_break*ones(size(Rs_partial, 1), size(Rs_partial, 2));
    
    %Plot the full set of break frequency surface.
    fig1 = figure; hold on, grid on, title(sprintf('Break Frequencies (Full, Order %0.0f, f = %0.0f [Hz]) vs Resistance & Capacitance', order, f_break)), zlabel('Break Frequencies [Hz]'), ylabel('Capacitance [F]'), xlabel('Resistance [Ohm]'), view(120, 30), rotate3d on
    h1 = surf(Rs_full, Cs_full, Fs_full, 'Facecolor', 'b', 'Facealpha', 0.5, 'Edgecolor', 'none'); h2 = surf(Rs_full, Cs_full, Fs_plane_full, 'Facecolor', 'r', 'Facealpha', 0.5, 'Edgecolor', 'none'); h3 = plot3(Rs_full(:), Cs_full(:), Fs_full(:), '.k', 'Markersize', 20); h4 = plot3(Rs_full_valid, Cs_full_valid, Fs_full_valid, '.r', 'Markersize', 20);
    legend([h1 h2 h3 h4], {'Break Frequency Surface', 'Target Break Frequency', 'Possible RC Values', 'Critical RC Values'})
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    
    %Plot the partial set of break frequency surface.
    fig2 = figure; hold on, grid on, title(sprintf('Break Frequencies (Ideal, Order %0.0f, f = %0.0f [Hz]) vs Resistance & Capacitance', order, f_break)), zlabel('Break Frequencies [Hz]'), ylabel('Capacitance [F]'), xlabel('Resistance [Ohm]'), view(120, 30), rotate3d on
    h1 = surf(Rs_partial, Cs_partial, Fs_partial, 'Facecolor', 'b', 'Facealpha', 0.5, 'Edgecolor', 'none'); h2 = surf(Rs_partial, Cs_partial, Fs_plane_partial, 'Facecolor', 'r', 'Facealpha', 0.5, 'Edgecolor', 'none'); h3 = plot3(Rs_partial(:), Cs_partial(:), Fs_partial(:), '.k', 'Markersize', 20); h4 = plot3(Rs_partial_valid, Cs_partial_valid, Fs_partial_valid, '.r', 'Markersize', 20);
    legend([h1 h2 h3 h4], {'Break Frequency Surface', 'Target Break Frequency', 'Possible RC Values', 'Critical RC Values'})
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    
    %Save the figures.
    saveas(fig1, sprintf('FullBreakFrequencySurface_Order%0.0f_f%0.0f.jpg', order, f_break)), saveas(fig2, sprintf('PartialBreakFrequencySurface_Order%0.0f_f%0.0f.jpg', order, f_break))
    
end

%% Print out the Computed Results.

if bPrintSelectionResults
    
    %Print out a header for this data.
    fprintf('ORDER %0.0f LOW PASS FILTER RC VALUES\n', order)
    
    %Print out the valid resistor and capacitor values from the full selection.
    fprintf('Full Selection Results\n')
    for k = 1:length(Rs_full_valid)
        fprintf('R = %0.3e [Ohm], C = %0.3e [F], f = %0.3e [Hz], E = %0.3f [Hz].\n', Rs_full_valid(k), Cs_full_valid(k), Fs_full_valid(k), Es_full_valid(k))
    end
    
    %Print out the valid resistor and capacitor values from the ideal selection.
    fprintf('\nIdeal Selection Results\n')
    for k = 1:length(Rs_partial_valid)
        fprintf('R = %0.3e [Ohm], C = %0.3e [F], f = %0.3e [Hz], E = %0.3f [Hz].\n', Rs_partial_valid(k), Cs_partial_valid(k), Fs_partial_valid(k), Es_partial_valid(k))
    end
    
    %Add a new line for formatting purposes.
    fprintf('\n')
    
end


end

