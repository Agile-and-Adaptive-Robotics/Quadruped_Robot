function SaveFigureAtSize(fig, file_name, ratio)

%This function sets the given figure to the specified size, saves the figure, and then restores the figure to its original size.

%Get the position of this figure.
fig_position = fig.Position;

% Get the screen size.
screen_size = get(0, 'Screensize');

% Compute the desired figure size.
desired_position = [1 1 round(ratio*screen_size(3:4))];

%Maximize the current figure.
set(fig, 'Position', desired_position);

%Save the current figure.
saveas(fig, file_name)

%Reset the size of the figure to the default figure size.
set(fig, 'Position', fig_position);
    
end
