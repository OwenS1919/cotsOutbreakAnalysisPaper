function setFontSize(fS)
% setFontSize() will set the fontsizes of the current figure in a uniform
% fashion, with fS being a baseline font size and axes titles, legends, etc
% all set relative to this value

% input:

% fS - the baseline font size (recall default matlab fontsize is 12 I
    % think)

% note - need to update this framework later, but for now I'm just
% copy-pasting from my darkFig() code, and then will update this properly
% later

% get all of the axes, then loop over them
axesVec = findall(gcf, 'type', 'axes');
for i = 1:length(axesVec)

    % set the fontsize for the whole axes, as apparently this will change
    % the ticklabels
    axesVec(i).FontSize = 0.9 * fS;

    % change the axes title fontsize
    if ~isempty(axesVec(i).Title)
        axesVec(i).Title.FontSize = 1.1 * fS;
    end

    % change the axes subtitle fontsize
    if ~isempty(axesVec(i).Subtitle)
        axesVec(i).Subtitle.FontSize = 1 * fS;
    end

    % change the fontsize of the axes labels
    if ~isempty(axesVec(i).XLabel)
        axesVec(i).XLabel.FontSize = fS;
    end
    if ~isempty(axesVec(i).YLabel)
        axesVec(i).YLabel.FontSize = fS;
    end

    % change the fontsize of the legend
    if ~isempty(axesVec(i).Legend)
        axesVec(i).Legend.FontSize = 0.75 * fS;
    end

    % change the text on the colorbar if it exists
    if ~isempty(axesVec(i).Colorbar)
        axesVec(i).Colorbar.FontSize = 0.8 * fS;
    end

end

% now, get all the text objects and if their fontsize is less than 0.75 *
% fS, reset it
textVec = findall(gcf, 'Type', 'Text');
for i = 1:length(textVec)
    if textVec(i).FontSize < 0.9 * fS
        textVec(i).FontSize = 0.9 * fS;
    end
end

% check if the figure has a tiledlayout, if so alter its properties
currFig = gcf;
if class(currFig.Children) == "matlab.graphics.layout.TiledChartLayout"
    currFig.Children.YLabel.FontSize = fS;
    currFig.Children.XLabel.FontSize = fS;
    currFig.Children.Title.FontSize = 1.1 * fS;
    currFig.Children.Subtitle.FontSize = 1.05 * fS;
    % currFig.Children.XAxis.FontSize = 0.9 * fS;
    % currFig.Children.YAxis.FontSize = 0.9 * fS;
end

end