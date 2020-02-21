function [ fig ] = MergeImages( fnames, tstrs )

%Create a new figure on which to place the images.
fig = figure;

%Determine how many rows and columns to use on the subplots.
[ nrows, ncols ] = GetSubplotRCs( length(fnames), false );

%Iterate through all of the filenames.
for k = 1:length(fnames)
    
    %Read in the approperiate image.
    im = imread(fnames{k});
    
    %Create a subplot for the new image.
    ax = subplot(nrows, ncols, k);
    
    %Put the image on the new subplot.
    image(im)
    
    %Remove the axis marks and numbering.
    set(ax, 'XTick', [], 'YTick', [])
    
    %Set the title of the subplot as desired.
    title(tstrs{k})
end


end

