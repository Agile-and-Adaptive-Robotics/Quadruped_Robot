classdef plotting_utilities_class
    
    % This class contains properties and methods related to plotting utilities.
    
    
    %% PLOTTING UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        
        
    end
    
    
    %% PLOTTING UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = plotting_utilities_class(  )
            
            
        end
        
        %% Plotting Functions
        
        % Implement a function to compute the number of subplot rows and columns necessary to store a certain number of plots.
        function [ nrows, ncols ] = get_subplot_rows_columns( ~, n, bPreferColumns )
            
            %If the value is not supplied by the user, default to preferring to add rows.
            if nargin < 3, bPreferColumns = false; end
            
            %Determine whether n is an integer.
            if n ~= round(n)                                                            %If n is not an integer...
                n = round(n);                                                           %Round n to the nearest integer.
                warning('n must be an integer.  Rounding n to the nearest integer.')    %Throw a warning about rounding n.
            end
            
            %Compute the square root of the integer of interest.
            nsr = sqrt(n);
            
            %Determine how many rows and columns to use in the subplot.
            if nsr == round(nsr)                    %If n is a perfect square...
                [nrows, ncols] = deal(nsr);         %Set the number of rows and columns to be the square root.
            else
                %Compute all divisors of n.
                dn = divisors(n);
                
                %Set the number of rows and columns to be the central divisors.
                nrows = dn(length(dn)/2 + 1);
                ncols = dn(length(dn)/2);
            end
            
            %Determine whether to give prefernce to columns or rows.
            if bPreferColumns                           %If we want to prefer columns...
                
                %Flip the row and column assignments, since we prefer rows by default.
                [nrows, ncols] = deal(ncols, nrows);
                
            end
            
        end
        
        
        
        
    end
    
    
end
    