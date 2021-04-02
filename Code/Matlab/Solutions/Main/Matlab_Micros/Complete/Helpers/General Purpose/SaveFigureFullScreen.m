function SaveFigureFullScreen(fig, file_name)
%This function maximizes a matlab figure, saves it while maximized, and then restores the figure to its original size.

%Get the position of this figure.
fig_position = fig.Position;

%Maximize the current figure.
set(fig, 'Position', get(0, 'Screensize'));

%Save the current figure.
saveas(fig, file_name)

%Reset the size of the figure to the default figure size.
set(fig, 'Position', fig_position);
    
end
