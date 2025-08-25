function saveFig(figName, res)
% saveFig() will save a figure directly into the "Figures" folder, which
% should be contained in the "Code" folder

% input:

% figName - a string representing the name of the figure to be saved
% res - optional - specifies the resolution to save the image as - default
    % is 600

% set defaults
if nargin < 2 || isempty(res)
    res = 600;
end

% save the figure
exportgraphics(gcf, "Figures\" + figName + ".png", ...
    'Resolution', res, 'BackgroundColor', 'current')

end
