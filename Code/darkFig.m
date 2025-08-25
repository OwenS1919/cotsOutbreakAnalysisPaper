function darkFig(lightColoursInd, colormapInd, polygonInd)
% darkFig() is a function I wrote myself to convert figures into dark mode
% automatically

% input:

% lightColourInd - optional - if specified as "lightColours", colours in
    % the figure will be lightened (default is "lightColours")
% colormapInd - optional - if specified as "colormap", the colormap will be
    % converted to a dark mode version, and lightColourInd will
    % automatically be set to "lightColours", same with polygonInd
    % (default is "no")
% polygonInd - optional - if specified as "polygon" the colours of any
    % plotted polygons will be lightened (default is "no")

% set defaults
if nargin < 1 || isempty(lightColoursInd)
    lightColoursInd = "no";
end
if nargin < 2 || isempty(colormapInd)
    colormapInd = "no";
end
if nargin < 3 || isempty(polygonInd)
    polygonInd = "no";
end
if colormapInd == "colormap"
    lightColoursInd = "lightColours";
    polygonInd = "polygon";
end

% set a lightening factor for each colour 
lightFact = 0.25;

% set all axes and colsours to dark mode where possible
axesVec = findall(gcf, 'type', 'axes');
set(gcf, 'color', 'k')
for i = 1:length(axesVec)

    % first, change each axes background and text / labels colours
    set(axesVec(i), 'color', 'k')
    set(axesVec(i), 'xcolor', 'w')
    set(axesVec(i), 'ycolor', 'w')
    try
        set(axesVec(i), 'zcolor', 'w')
    catch
    end

    % if the axes has a legend, change that too
    if ~isempty(axesVec(i).Legend)
        axesVec(i).Legend.TextColor = 'w';
        axesVec(i).Legend.EdgeColor = 'w';
        axesVec(i).Legend.Color = 'k';
    end

    % change the axes title colour if possible
    if ~isempty(axesVec(i).Title)
        axesVec(i).Title.Color = 'w';
    end

    % change the axes subtitle colour if possible
    if ~isempty(axesVec(i).Subtitle)
        axesVec(i).Subtitle.Color = 'w';
    end

    % lighten the colourmap
    if colormapInd == "colormapInd"
        if ~isempty(axesVec(i).Colormap)
            axesVec(i).Colormap = axesVec(i).Colormap + ...
                lightFact * ([1, 1, 1] - axesVec(i).Colormap);
        end
    end

    % change the text on the colorbar if it exists
    if ~isempty(axesVec(i).Colorbar)
        axesVec(i).Colorbar.Color = 'w';
    end

    % if the current axes has any colours, change them too
    axesChildVec = axesVec(i).Children;

    % find out if any of the child objects have colours
    coloursInd = find(isprop(axesChildVec, "Color"));
    
    % split cases based on whether we're lightening colours or not
    if lightColoursInd == "lightColours"

        % loop over the coloured objects
        for c = 1:length(coloursInd)

            % if we have a black (or close to) line, convert it to
            % white
            if sum(axesChildVec(coloursInd(c)).Color == 0) == 3 ...
                    || sum(axesChildVec(coloursInd(c)).Color == 0.15) == 3
                axesChildVec(coloursInd(c)).Color = [1, 1, 1];
                if isprop(axesChildVec(coloursInd(c)), "Alpha")
                    axesChildVec(coloursInd(c)).Alpha = 1;
                end
                continue
            end

            % watch out for the alphas here, and the effect this could
            % have on some things
            % if we have a white color, convert it to black
            if (sum(axesChildVec(coloursInd(c)).Color == 1) == 3) ...
                    || (sum(axesChildVec(coloursInd(c)).Color == [0, 0, 0]) ...
                    == 3)
                axesChildVec(coloursInd(c)).Color = [0, 0, 0];
                if isprop(axesChildVec(coloursInd(c)), "Alpha")
                    axesChildVec(coloursInd(c)).Alpha = 1;
                end
                continue
            end

            % otherwise, just lighten the colour
            axesChildVec(coloursInd(c)).Color = ...
                axesChildVec(coloursInd(c)).Color ...
                + lightFact * ([1, 1, 1] ...
                - axesChildVec(coloursInd(c)).Color);

        end

        % if we're lightening colours for polygons, look out for any filled
        % objects
        if polygonInd == "polygon"
            fInd = find(isprop(axesChildVec, "FaceColor"));
            for f = 1:length(fInd)
                if (class(axesChildVec(fInd(f)).FaceColor) == "string" ...
                        || class(axesChildVec(fInd(f)).FaceColor) ...
                        == "char") && axesChildVec(fInd(f)).FaceColor ...
                        == "auto"
                    axesChildVec(fInd(f)).FaceColor = getColour('lb');
                end
                axesChildVec(fInd(f)).FaceColor = ...
                    axesChildVec(fInd(f)).FaceColor ...
                    + lightFact * ([1, 1, 1] ...
                    - axesChildVec(fInd(f)).FaceColor);
            end
        end
        
    else

        % loop over the coloured objects
        for c = 1:length(coloursInd)

            % if we have a black (or close to) line, convert it to
            % white
            if sum(axesChildVec(coloursInd(c)).Color == 0) == 3 ...
                    || sum(axesChildVec(coloursInd(c)).Color == 0.15) == 3
                axesChildVec(coloursInd(c)).Color = [1, 1, 1];
                if isprop(axesChildVec(coloursInd(c)), "Alpha")
                    axesChildVec(coloursInd(c)).Alpha = 1;
                end
                continue
            end

            % watch out for the alphas here, and the effect this could
            % have on some things
            % if we have a white color, convert it to black
            if (sum(axesChildVec(coloursInd(c)).Color == 1) == 3) ...
                    || (sum(axesChildVec(coloursInd(c)).Color == [0, 0, 0]) ...
                    == 3)
                axesChildVec(coloursInd(c)).Color = [0, 0, 0];
                if isprop(axesChildVec(coloursInd(c)), "Alpha")
                    axesChildVec(coloursInd(c)).Alpha = 1;
                end
                continue
            end

        end

    end

    % do the same as the above but for annotations
    textInd = find(isprop(axesChildVec, "String"));
    for c = 1:length(textInd)
        axesChildVec(textInd(c)).Color = 'w';
    end

end

% check if the figure has a tiledlayout, if so alter its properties
currFig = gcf;
w = [1, 1, 1];
if class(currFig.Children) == "matlab.graphics.layout.TiledChartLayout"
    currFig.Children.YLabel.Color = w;
    currFig.Children.XLabel.Color = w;
    currFig.Children.Title.Color = w;
    currFig.Children.Subtitle.Color = w;
end

% check if there are any annotations - turn their text white if so
% ax = findall(gcf, 'Tag', 'scribeOverlay');
% annotationHandles = findall(get(ax,'Children'),'Type','hggroup');
% for c = 1:length(annotationHandles)
%     currObj = get(annotationHandles(c));
%     if (isfield(currObj, 'String'))
%         currObj.Color = 'w';
%     end
% 
%     % axesChildVec(textInd(c)).Color = 'w';
% end

end
