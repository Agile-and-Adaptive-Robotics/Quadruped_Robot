## MAIN PYTORCH TUTORIAL SCRIPT

# This script implements the main code necessary to experiment with Pytorch, Lava, Isaac Gym, etc.

#%% ------------------------------ IMPORT LIBRARIES ------------------------------

# Import standard libraries.
import numpy as np
import matplotlib.pyplot as plt
import lava
import lava.lib.dl.slayer as slayer

# Import custom libraries.


#%% ------------------------------ CREATE CIRCLE POINTS ------------------------------

# Define the number of parameters.
num_ts = 100
num_rs = 3

# Define the circle parameters.
ts = np.linspace( start = 0, stop = 2*np.pi, num = num_ts )
rs = np.linspace( start = 1, stop = num_rs, num = num_rs )

# Preallocate an array to store the circle points.
xs = np.zeros( ( num_ts, num_rs ) )
ys = np.zeros( ( num_ts, num_rs ) )

for k1 in range( num_ts ):
    for k2 in range( num_rs ):

        xs[ k1, k2 ] = rs[ k2 ]*np.cos( ts[ k1 ] )
        ys[ k1, k2 ] = rs[ k2 ]*np.sin( ts[ k1 ] )


#%% ------------------------------ PLOT THE CIRCLE ------------------------------

# Create a figure for the circle.
fig = plt.figure(  ); plt.xlabel( 'x' ); plt.ylabel( 'y' ); plt.title( 'Circle Plot' )

# Plot each of the circles.
for k in range( num_rs ):

    plt.plot( xs[ :, k ], ys[ :, k ] )

# Show the plot.
plt.show(  )

x = 1


