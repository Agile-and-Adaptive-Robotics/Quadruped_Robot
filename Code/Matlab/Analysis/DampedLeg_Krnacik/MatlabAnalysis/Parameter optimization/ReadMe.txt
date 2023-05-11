DYNAMIC PROPERTIES CALC
Was used to calculate risetime in the hip, and frequency and damping ratio in the knee for rat trials so they did not need to be calculated at every iteration
Several different versions tried

IC_check
Main script is dynamic_IC_check.
Allows the user to enter values of friction (not used), k, and b.
User must enter a trial and muscle number to compare to.
Using IC from selected trial, ODE is run on system with selected parameters.
Joint angles over time are outputted and user has option to save. 

OPTIMIZER FUNCTIONS AND DATA
These are miscellaneous scripts need to run the optimizers.
Includes cost calculations, joint angle data, EOM, mechanical properties of the systems, etc.

OPTIMIZER SCRIPTS
Different optimization scripts
NOTE: Much of the code floating around this project has been copy and pasted from previous versions I've written, and some comments may contain errors
These had many changes and iterations, and the code gets a little sloppy in some places. Please contact me if there's any confusion.

RESULTS
Optimization results, sorted into folders.
Generally a data file and a figure are saved for each optimization.

TRIAL PLOTTING
Plotting of the rat leg trials used, as joint angle data over time.

