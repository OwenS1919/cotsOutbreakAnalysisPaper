function plotQldOutline(qldOutline, outline, labelInd)
% plotQldOutline() will just do a nice plot of the qld outline in brown :3

% input:

% qldOutline - a shape structure holding the queensland outline, with the
    % fields x and y holding the longitude and latitude coordinates
    % respectively
% outline - optional - if value true, outline will be plotted, otherwise no
    % outline will be plotted (default is true)
% labelInd - optional - if value true, the label for qld will be plotted,
    % otherwise it will not (default is true)

% set defaults
if nargin < 2 || isempty(outline)
    outline = true;
end
if nargin < 3 || isempty(labelInd)
    labelInd = true;
end

% alright gang let's do this

% plot down the qld outline and label it
plotShapes(qldOutline, 'colour', getColour('br'), 'fill', 'yes', ...
    'alpha', 0.2)
if outline
    plotShapes(qldOutline, 'colour', 'k')
end
if labelInd
    text(142.5, -21, "Queensland")
end

end