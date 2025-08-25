function plotShapes(shapeStruct, nameValArgs)
% plotShapes() will simply plot the shape outlines held in shapeStruct

% inputs:

% shapeStruct - holds the reef outlines in a structure with fields X and Y
    % storing the X and Y coordinates
% colour - optional - specifies the colour code - default is just whatever
    % matlab assigns
% colourMap - optional - specifies the colourmap to use - default is turbo
    % (my version of turbo)
% vals - optional - if specified, vals will be used to create a colourmap
    % and control the colours for each reef but only for the fill option -
    % default is "k", i.e. black
% fillIn - optional - specify as "fill" if the shapes are to be filled,
    % "fillBorder" if the borders are also to be coloured, rather than just
    % plotting the outlines - default is "no"
% indices - optional - if specified as "indices" will also plot the indices
    % of each reef at their centroids - default is "" i.e. no indices
% boundary - optional - provides a limit for plotting of the form [xMin,
    % xMax, yMin, yMax], so that only shapes with centroids in this range
    % are plotted - default is [] i.e. no boundary applied
% colourBar - optional - if specified as "off", will not include a
    % colourbar and won't impose a colourmap - default is "on"
% climMax - optional - if specified, will setup the colourbar to have
    % maximum value climMax

% process the and extract the nameValArgs
arguments
    shapeStruct
    nameValArgs.colour = "";
    nameValArgs.vals = [];
    nameValArgs.fill = "no";
    nameValArgs.indices = "";
    nameValArgs.boundary = [];
    nameValArgs.alpha = 1;
    nameValArgs.lineStyle = "-";
    nameValArgs.lineWidth = 0.5;
    nameValArgs.uniformInd = "no";
    nameValArgs.colourMap = "turbo";
    nameValArgs.colourBar = "on";
    nameValArgs.climMax = [];
end
colour = nameValArgs.colour;
colourMap = nameValArgs.colourMap;
vals = nameValArgs.vals;
fill = nameValArgs.fill;
indices = nameValArgs.indices;
boundary = nameValArgs.boundary;
alpha = nameValArgs.alpha;
lineStyle = nameValArgs.lineStyle;
lineWidth = nameValArgs.lineWidth;
uniformInd = nameValArgs.uniformInd;
colourBar = nameValArgs.colourBar;
climMax = nameValArgs.climMax;

% reset uniformInd unless the vals argument has been specified
if isempty(vals) && indices ~= "indices"
    uniformInd = "uniform";
end

% need an extra argument for the random colourmapping -- wait

% determine the number of shapes
nShapes = length(shapeStruct);

% if we have a boundary, reduce the shapeStruct's contents by the boundary
if ~isempty(boundary)

    % resize the boundary if it is in the form of a partition, aka x =
    % boundary{i}(:, 1)
    if sum(size(boundary) == [1, 4]) ~= 2 && sum(size(boundary) ~= [4, 1]) ...
            == 2
        boundary = [min(boundary(:, 1)), max(boundary(:, 1)), ...
            min(boundary(:, 2)), max(boundary(:, 2))];
    end

    % get rid of shapes outside the boundary
    boundaryMask = false(nShapes, 1);
    for s = 1:nShapes
        if shapeStruct(s).Centroid(1) > boundary(1) ...
                && shapeStruct(s).Centroid(1) <= boundary(2) ...
                && shapeStruct(s).Centroid(2) > boundary(3) ...
                && shapeStruct(s).Centroid(2) <= boundary(4)
        boundaryMask(s) = true;
        end
    end
    nShapes = sum(boundaryMask);
    shapeStruct = shapeStruct(boundaryMask);

    % retain the indices though for later
    indicesVals = find(boundaryMask);

    % also need to hold on to the values
    if ~isempty(vals)
        vals = vals(boundaryMask);
    end
    
else
    indicesVals = 1:nShapes;
end

% gonna try some absolute bovine excrement (tm) here
if uniformInd == "uniform"

    % this is really stupid, but if the x and y coords are in column vector
    % form (which makes sense) I need to transpose them to row form
    if size(shapeStruct(1).X, 2) < size(shapeStruct(1).X, 1)
        for s = 1:nShapes
            shapeStruct(s).X = shapeStruct(s).X';
            shapeStruct(s).Y = shapeStruct(s).Y';
        end
    end

    % concatenate all the points into a single shape object lmao
    xPoints = [];
    yPoints = [];
    for s = 1:nShapes
        xPoints = [xPoints, shapeStruct(s).X, NaN];
        yPoints = [yPoints, shapeStruct(s).Y, NaN];
    end
    shapeStruct = shapeStruct(1);
    shapeStruct(1).X = xPoints;
    shapeStruct(1).Y = yPoints;
    nShapes = 1;

end

% setup the colours array, which will hold the colours each 
colours = zeros(nShapes, 3);
if ~isempty(vals)

    % switch cases here based on whether we have a climMax specified
    if isempty(climMax)
        climMax = max(vals);
    end

    % loop through and grab all the colours
    for s = 1:nShapes
        colours(s, :) = getColour(vals(s), climMax, colourMap);
    end
    cMap = myColourMap(colourMap);

    % set the colourMap if necessary
    if colourBar == "on"

        % need to plot some dummy points to get the colorbar to work
        colormap(cMap)
        scatter([shapeStruct(1).X(1), shapeStruct(1).X(1), ...
            shapeStruct(1).X(1)], [shapeStruct(1).Y(1), ...
            shapeStruct(1).Y(1), shapeStruct(1).Y(1)], 0.00001, ...
            [min(vals), mean(vals), climMax])
        colBar = colorbar();

    end

else
    if ~isnumeric(colour)
        if colour ~= ""
            colourTrip = getColour(colour);
            colours = repmat(colourTrip, [nShapes, 1]);
        else
            for s = 1:nShapes
                colours(s, :) = [0, 0, 0];
            end
        end
    else
        colours = repmat(colour, [nShapes, 1]);
        colour = "this variable is now a string so my code does'nt " + ...
            "break how fun";
    end
end

% turn hold on
hold on

% need to plot some dummy points to get the colorbar to work
if ~isempty(vals) && colourBar == "on"
    cMap = myColourMap(colourMap);
    colormap(cMap)
    scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.0001, 0)
    scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.0001, climMax)
    colBar = colorbar();
end

if fill ~= "fill" && fill ~= "fillBorder" && fill ~= "yes"

    % if we are not filling each shape, simply loop through and plot
    % outlines
    if isempty(vals) && colour == ""
        for s = 1:nShapes
            plot(shapeStruct(s).X, shapeStruct(s).Y, 'LineStyle', ...
                lineStyle, 'LineWidth', lineWidth)
        end
    else
        for s = 1:nShapes
            plot(shapeStruct(s).X, shapeStruct(s).Y, "color", ...
                colours(s, :), 'LineStyle', lineStyle, 'LineWidth', ...
                lineWidth)
        end
    end

elseif fill == "fillBorder" || fill == "fill" || fill == "yes"

    % set whether we want to fill the borders or not
    warning("off", "all")
    if fill == "fillBorder"
        edgeAlphaArg = alpha;
    else
        edgeColorArg = 'none';
        edgeAlphaArg = 0;
    end
    lineWidthArg = lineWidth;
    
    % plot and fill da shapes, using a for loop to deal with holes and NaNs
    % etc - for some reason this goddamn command screws up the axes limits
    % so need to record some bs here
    xMax = -inf;
    xMin = inf;
    yMax = -inf;
    yMin = inf;
    for s = 1:nShapes
        if fill == "fillBorder"
            edgeColorArg = colours(s, :);
        end
        currPoly = polyshape(shapeStruct(s).X, shapeStruct(s).Y);
        plot(currPoly, "FaceColor", colours(s, :), "EdgeColor", ...
            edgeColorArg, "LineWidth", lineWidthArg, "FaceAlpha", alpha, ...
            "EdgeAlpha", edgeAlphaArg);

        % testing some malaarkey - the first is fine, second is fine
        % plot(shapeStruct(s).X, shapeStruct(s).Y, 'r.', 'MarkerSize', 20)
        % plot(currPoly.Vertices(:, 1), currPoly.Vertices(:, 2), 'r.', ...
        %     'MarkerSize', 20)
        xMax = max([xMax; shapeStruct(s).X(:)]);
        xMin = min([xMin; shapeStruct(s).X(:)]);
        yMax = max([yMax; shapeStruct(s).Y(:)]);
        yMin = min([yMin; shapeStruct(s).Y(:)]);

    end

end
warning("on", "all")

% plot the indices if needed
if indices == "indices"
    for s = 1:nShapes
        text(shapeStruct(s).Centroid(1), shapeStruct(s).Centroid(2), ...
            num2str(indicesVals(s)), "FontSize", 15)
    end
end

% going to reset the axes limits here because for some stupid ass reason
% it's not behaving itself
if ~isempty(boundary) && fill == "fill"
    axis equal
    boundary = [xMin, xMax, yMin, yMax];
    xPadding = 0.07 * (boundary(2) - boundary(1));
    yPadding = 0.07 * (boundary(4) - boundary(3));
    axis([boundary(1) - xPadding, boundary(2) + xPadding, ...
        boundary(3) - yPadding, boundary(4) + yPadding])
    axis padded
else
    axis equal
end

end