function plotPoints(points, nameValArgs)
% plotCentroids() will plot a list of points organised in an n x 2 matrix,
% where the fist column contains the x values and the second contains the y

% input:

% points - an n x 2 matrix in which the first column contains the x values,
    % and the second contains the y

% process the and extract the nameValArgs
arguments
    points
    nameValArgs.colour = "k";
    nameValArgs.markerSize = 1;
end
colour = nameValArgs.colour;
markerSize = nameValArgs.markerSize;

% if we've already supplied the rgb triplet then change how I'm plotting
% lmao
if class(colour) == "double"
    plot(points(:, 1), points(:, 2), '.', 'MarkerSize', markerSize, ...
        'Color', colour)
else
    plot(points(:, 1), points(:, 2), '.', 'MarkerSize', markerSize, ...
        'Color', getColour(colour))
end

end