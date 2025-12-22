function plotLarvalSupplyV2(cotsDensData, conMatGlobal, nonOutbrReefs, ...
    outbrReefs, titleString, darkMode, histInd, conInd, presInd, ...
    printInd)
% plotLarvalSupply() will create plots of the estimated mean, median, and
% maximum larval supply to reefs identified as outbreak and non-outbreaking
% reefs

% inputs:

% cotsDensData - a table containing the imputed mean, median, and maximum
    % cotsPerTow values in the columns "cotsPerTowMeanImput" etc for all
    % reefs listed in the same order as the connectivity matrix
% conMatGlobal - a global connectivity matrix, if using the conInd =
    % "conMax" option, should be a cell array of yearly connectivity
    % matrices
% nonOutbrReefs - a binary vector the same size and order as the reefs in
    % the connectivity matrix, indicating which reefs have been identified
    % as not experiencing outbreaks 
% outbrReefs - as above, however for reefs that do experience outbreaks
% histInd - optional - specify as true if you aim to plot histograms and
    % not boxplots (default is true)
% conInd - optional - a string, indicating what we're plotting, with "con"
    % for connectivity-based metrics only, "conMax" for connectivity-based
    % metrics maximised over the 5 years of simulated spawning seasons, and
    % anything else for the original (default is false)
% presInd - optional - specify as true or "presInd" if we're plotting the
    % presentation version of this figure (default is false)
% printInd - optional - specify as false if you don't want the statistical
    % tests to all print out (default is true)

% note that due to the long computation time, I've moved the solutions for
% the iterative metrics to the main text

% throw down some defaults
if nargin < 6 || isempty(darkMode)
    darkMode = true;
end
if nargin < 7 || isempty(histInd)
    histInd = true;
end
if nargin < 8 || isempty(conInd) 
    conInd = "idk";
end
if nargin < 9 || isempty(conInd) 
    presInd = false;
else
    if class(presInd) == "string"
        presInd = presInd == "presInd";
    end
end
if nargin < 10 || isempty(printInd) 
    printInd = true;
end

% convert conInd to a different variable
conMaxInd = conInd == "conMax";
conInd = conInd == "con" || conInd == "conMax";

% setup the figure
if histInd && ~conInd
    tL = tiledlayout(3, 1, 'TileSpacing', 'compact');
elseif ~histInd && conInd
    figResize(1.325, 1.85)
    tL = tiledlayout(2, 4, 'TileSpacing', 'compact');
else
    figResize(0.9, 1.85)
    tL = tiledlayout(1, 3, 'TileSpacing', 'compact');
end

% setup some random bs
var3 = ["k", "w"];
var4 = ["k+", "w+"];
var5 = ["Mean", "Median", "Max"];
var6 = ["Mean", "Median", "Maximum"];

% switch whether we're doing a dark or light mode
if darkMode 
    i = 2;
else
    i = 1;
end

% for some of the connectivity metrics we need a graph object
if conInd
    if ~conMaxInd
        graphObj = digraph(replaceNaNs(conMatGlobal, 0));
    else
        graphCell = cell(1, 5);
        for y = 1:5
            graphCell{y} = digraph(replaceNaNs(conMatGlobal{y}, 0));
        end
    end
end

% loop over the mean, median, and maximum
for j = 1:8

    % if we're not doing connectivity only stuff, skip the j > 3 iterations
    if ~conInd && j > 3
        continue
    end

    % split cases based on what we want to plot
    if ~conInd

        % calculate the incoming larval supply, switching cases based on
        % whether we're doing long term connectivity averages or taking the
        % worst case
        if class(conMatGlobal) == "cell"

            % loop over the spawning seasons
            conMetricVals = zeros(size(conMatGlobal{1}, 1), ...
                length(conMatGlobal));
            for s = 1:length(conMatGlobal)
                conMetricVals(:, s) = replaceNaNs(conMatGlobal{s}', 0) * ...
                    ((replaceNaNs(cotsDensData{:, "cotsPerTow" + var5(j) + ...
                    "Imput"}, 0) .* replaceNaNs(cotsDensData.area, 0)));
            end

            % now take the maximum over the five spawning seasons
            conMetricVals = max(conMetricVals, [], 2);

        else
            conMetricVals = replaceNaNs(conMatGlobal', 0) * ...
                ((replaceNaNs(cotsDensData{:, "cotsPerTow" + var5(j) + ...
                "Imput"}, 0) .* replaceNaNs(cotsDensData.area, 0)));
        end

        var1 = [conMetricVals(nonOutbrReefs); ...
            conMetricVals(outbrReefs)];
        var2 = [zeros(size(conMetricVals(nonOutbrReefs))); ...
            ones(size(conMetricVals(outbrReefs)))];

        % print the statistical tests
        if i == 1 && printInd

            % now do the mena values, ks test, and median test
            fprintf(strjoin("cotsPerTow" + var5(j) + ...
                "Imput", " ") + "\n")
            fprintf("Mean non-outbreaks: ")
            mean(conMetricVals(nonOutbrReefs))
            fprintf("Mean outbreaks: ")
            mean(conMetricVals(outbrReefs))

            % run the ks test
            fprintf("KS test")
            [~, p] = kstest2(conMetricVals(nonOutbrReefs), ...
                conMetricVals(outbrReefs))

            % run the median test
            fprintf("Median test")
            p = mediantest(conMetricVals(nonOutbrReefs), ...
                conMetricVals(outbrReefs))

            % throw in some newlines
            fprintf("\n\n\n")

            % that didn't work so just print a blocker thing idk
            fprintf("--------------------------------------------------\n")

        end

    else 

        % calculate the metrics I'm going to pretend to give a shit about
        % lmao
        if j == 1

            % calculate the incoming larval supply if we assume all reefs
            % have a constant density, switching cases based on whether or
            % not we want the temporal max
            if ~conMaxInd
                conMetricVals = replaceNaNs(conMatGlobal', 0) ...
                    * (replaceNaNs(cotsDensData.area, 0));
            else
                conMetricVals = zeros(size(conMatGlobal{1}, 1), 5);
                for y = 1:5
                    conMetricVals(:, y) = replaceNaNs( ...
                        conMatGlobal{y}', 0) * (replaceNaNs( ...
                        cotsDensData.area, 0));
                end
                conMetricVals = max(conMetricVals, [], 2);
            end
            var1 = [conMetricVals(nonOutbrReefs); ...
                conMetricVals(outbrReefs)];
            var2 = [zeros(size(conMetricVals(nonOutbrReefs))); ...
                ones(size(conMetricVals(outbrReefs)))];
            if presInd
                currYLabel = ["Const. density", "settlement"];
            else
                currYLabel = "Const. dens. settlement";
            end

        elseif j == 2

            % calculate the in-degree for each reef, splitting cases based
            % on whether or not we want the temporal maximum
            if ~conMaxInd
                conMetricVals = sum(full(replaceNaNs(conMatGlobal, 0)) ...
                    > 0, 1)';
            else
                conMetricVals = zeros(size(conMatGlobal{1}, 1), 5);
                for y = 1:5
                    conMetricVals(:, y) = sum(full(replaceNaNs( ...
                        conMatGlobal{y}, 0)) > 0, 1)';
                end
                conMetricVals = max(conMetricVals, [], 2);
            end
            var1 = [conMetricVals(nonOutbrReefs); ...
                conMetricVals(outbrReefs)];
            var2 = [zeros(size(conMetricVals(nonOutbrReefs))); ...
                ones(size(conMetricVals(outbrReefs)))];
            currYLabel = "In-degree";

        elseif j == 3

            % calculate the significant in-degree for each reef, splitting
            % cases based on whether or not we want the temporal maximum
            if ~conMaxInd
                conMetricVals = sum(full(replaceNaNs(conMatGlobal, 0)) ...
                    > 0.0015, 1)';
            else
                conMetricVals = zeros(size(conMatGlobal{1}, 1), 5);
                for y = 1:5
                    conMetricVals(:, y) = sum(full(replaceNaNs( ...
                        conMatGlobal{y}, 0)) > 0.0015, 1)';
                end
                conMetricVals = max(conMetricVals, [], 2);
            end
            var1 = [conMetricVals(nonOutbrReefs); ...
                conMetricVals(outbrReefs)];
            var2 = [zeros(size(conMetricVals(nonOutbrReefs))); ...
                ones(size(conMetricVals(outbrReefs)))];
            if presInd
                currYLabel = ["Substantial", "in-degree"];
            else
                currYLabel = "Subs. in-degree";
            end


        elseif j == 4

            % calculate the significant in-component for each reef,
            % splitting cases based on whether or not we want to find the
            % temporal maximum
            if ~conMaxInd
                var1 = replaceNaNs(conMatGlobal, 0) > 0.0015;
                var2 = var1;
                var10 = var1;
                for k = 2:5
                    var10 = var10 * var1;
                    var2 = var2 + var10;
                end
                var2 = full(var2 > 0);
                conMetricVals = sum(var2, 1)';
            else
                conMetricVals = zeros(size(conMatGlobal{1}, 1), 5);
                for y = 1:5
                    var1 = replaceNaNs(conMatGlobal{y}, 0) > 0.0015;
                    var2 = var1;
                    var10 = var1;
                    for k = 2:5
                        var10 = var10 * var1;
                        var2 = var2 + var10;
                    end
                    var2 = full(var2 > 0);
                    conMetricVals(:, y) = sum(var2, 1)';
                end
                conMetricVals = max(conMetricVals, [], 2);
            end
            var1 = [conMetricVals(nonOutbrReefs); ...
                conMetricVals(outbrReefs)];
            var2 = [zeros(size(conMetricVals(nonOutbrReefs))); ...
                ones(size(conMetricVals(outbrReefs)))];
            if presInd
                currYLabel = ["Substantial", "in-component"];
            else
                currYLabel = "Subs. in-component";
            end

        elseif j == 5

            % claculate the local retention for each reef, switching cases
            % based on whether or not we aim to find the temporal maximum
            if ~conMaxInd
                conMetricVals = diag(full(replaceNaNs(conMatGlobal, ...
                    0)));
            else
                conMetricVals = zeros(size(conMatGlobal{1}, 1), 5);
                for y = 1:5
                    conMetricVals(:, y) = diag(full(replaceNaNs( ...
                        conMatGlobal{y}, 0)));
                end
                conMetricVals = max(conMetricVals, [], 2);
            end
            var1 = [conMetricVals(nonOutbrReefs); ...
                conMetricVals(outbrReefs)];
            var2 = [zeros(size(conMetricVals(nonOutbrReefs))); ...
                ones(size(conMetricVals(outbrReefs)))];
            if presInd
                currYLabel = ["Local", "retention"];
            else
                currYLabel = "Local retention";
            end

        elseif j == 6

            % calculate my made up clustering component for each reef lmao
            if ~conMaxInd
                conMetricVals = zeros(size(conMatGlobal, 1), 1);
                sigConMat = replaceNaNs(conMatGlobal, 0) > 0.0015;
                for z = 1:size(conMatGlobal, 1)
                    
                    % find the source reefs for the current reef, removing
                    % the current reef
                    sourceReefs = find(sigConMat(:, z));
                    sourceReefs = sourceReefs(sourceReefs ~= z);
                    if isempty(sourceReefs)
                        continue
                    end

                    % determine the mean number of connections between the
                    % source reefs
                    conMetricVals(z) = sum(sum(sigConMat(sourceReefs, ...
                        sourceReefs))) / length(sourceReefs);

                end
            else
                conMetricVals = zeros(size(conMatGlobal{1}, 1), 5);
                for y = 1:5
                    sigConMat = replaceNaNs(conMatGlobal{y}, 0) > 0.0015;
                    for z = 1:size(conMatGlobal{y}, 1)

                        % find the source reefs for the current reef,
                        % removing the current reef
                        sourceReefs = find(sigConMat(:, z));
                        sourceReefs = sourceReefs(sourceReefs ~= z);
                        if isempty(sourceReefs)
                            continue
                        end

                        % determine the mean number of connections between
                        % the source reefs
                        conMetricVals(z, y) = sum(sum(sigConMat( ...
                            sourceReefs, sourceReefs))) ...
                            / length(sourceReefs);

                    end
                end
                conMetricVals = max(conMetricVals, [], 2);
            end
            var1 = [conMetricVals(nonOutbrReefs); ...
                conMetricVals(outbrReefs)];
            var2 = [zeros(size(conMetricVals(nonOutbrReefs))); ...
                ones(size(conMetricVals(outbrReefs)))];
            if presInd
                currYLabel = ["Substantial", "clustering"];
            else
                currYLabel = "Subs. clustering";
            end

        elseif j == 7

            % calculate pagerank here, using the earlier
            % defined graph and matlab's inbuilt calculator
            if ~conMaxInd

                % calculate the pagerank for the averaged connectivity
                % matrix
                conMetricVals = centrality(graphObj, 'pagerank', ...
                    'Importance', graphObj.Edges.Weight, 'MaxIterations', ...
                    1000);

            else

                % calculate the maximum pagerank across the 5 connectivity
                % matrices
                conMetricVals = zeros(size(conMatGlobal{1}, 1), 5);
                for y = 1:5
                    conMetricVals(:, y) = centrality(graphCell{y}, ...
                        'pagerank', 'Importance', ...
                        graphCell{y}.Edges.Weight, 'MaxIterations', ...
                        1000);
                end
                conMetricVals = max(conMetricVals, [], 2);

            end
            var1 = [conMetricVals(nonOutbrReefs); ...
                conMetricVals(outbrReefs)];
            var2 = [zeros(size(conMetricVals(nonOutbrReefs))); ...
                ones(size(conMetricVals(outbrReefs)))];
            currYLabel = "PageRank";

        elseif j == 8

            % calculate authorities here, although I'm not entirely sure
            % I'm onboard with its utility
            if ~conMaxInd

                % calculate the pagerank for the averaged connectivity
                % matrix
                conMetricVals = centrality(graphObj, 'authorities', ...
                    'Importance', graphObj.Edges.Weight, 'MaxIterations', ...
                    1000);

            else

                % calculate the maximum pagerank across the 5 connectivity
                % matrices
                conMetricVals = zeros(size(conMatGlobal{1}, 1), 5);
                for y = 1:5
                    conMetricVals(:, y) = centrality(graphCell{y}, ...
                        'authorities', 'Importance', ...
                        graphCell{y}.Edges.Weight, 'MaxIterations', ...
                        1000);
                end
                conMetricVals = max(conMetricVals, [], 2);

            end
            var1 = [conMetricVals(nonOutbrReefs); ...
                conMetricVals(outbrReefs)];
            var2 = [zeros(size(conMetricVals(nonOutbrReefs))); ...
                ones(size(conMetricVals(outbrReefs)))];
            if presInd
                currYLabel = ["Authority", "score"];
            else
                currYLabel = "Authority score";
            end

        else

            % calculate the prestige of nodes based on page 22 of this lmao
            % file:///F:/Downloads/978-3-642-21070-9.pdf

            % there's some bullshit I need to do for the transformation
            % here but I really can't be bothered

            % anyway I'm no longer doing the thing from the above, and I'm
            % instead doing this absolute codswallop
            if ~conMaxInd
                conMetricVals = ones(size(conMatGlobal, 1), 1);
                conMatGlobal = replaceNaNs(conMatGlobal, 0);
                for k = 1:100
                    conMetricVals = conMatGlobal' * conMetricVals;
                    conMetricVals = 3861 * conMetricVals ...
                        / sum(conMetricVals);
                end
                conMetricVals = conMetricVals / sum( ...
                    conMetricVals);
            else
                conMetricVals = zeros(size(conMatGlobal{1}, 1), 5);
                for y = 1:5
                    conMetricVals(:, y) = ones(size( ...
                        conMatGlobal{y}, 1), 1);
                    conMatGlobal{y} = replaceNaNs(conMatGlobal{y}, 0);
                    for k = 1:100
                        conMetricVals(:, y) = conMatGlobal{y}' ...
                            * conMetricVals(:, y);
                        conMetricVals(:, y) = 3861 ...
                            * conMetricVals(:, y) ...
                            / sum(conMetricVals(:, y));
                    end
                    conMetricVals(:, y) = conMetricVals(:, y) ...
                        / sum(conMetricVals(:, y));
                end
                conMetricVals = max(conMetricVals, [], 2);
            end
            var1 = [conMetricVals(nonOutbrReefs); ...
                conMetricVals(outbrReefs)];
            var2 = [zeros(size(conMetricVals(nonOutbrReefs))); ...
                ones(size(conMetricVals(outbrReefs)))];
            currYLabel = "Bullshit placeholder";

        end

        if i == 1 && printInd

            % now do the mena values, ks test, and median test
            fprintf(strjoin(currYLabel, " ") + "\n")
            fprintf("Mean non-outbreaks: ")
            mean(conMetricVals(nonOutbrReefs))
            fprintf("Mean outbreaks: ")
            mean(conMetricVals(outbrReefs))

            % run the ks test
            fprintf("KS test")
            [~, p] = kstest2(conMetricVals(nonOutbrReefs), ...
                conMetricVals(outbrReefs))

            % run the median test
            fprintf("Median test")
            p = mediantest(conMetricVals(nonOutbrReefs), ...
                conMetricVals(outbrReefs))

            % throw in some newlines
            fprintf("\n\n\n")

            % that didn't work so just print a blocker thing idk
            fprintf("--------------------------------------------------\n")

        end

    end

    % do this plot
    nexttile(j)
    warning("off", "all")
    hold on
    if histInd 

        % do a histogrammy bs here lmao
        binEdges = linspace(0, max(var1), 76);
        histogram(var1(var2 == 0), binEdges, 'EdgeColor', getColour('b'), ...
            'DisplayStyle', 'stairs', 'Normalization', 'probability', ...
            'LineWidth', 1)
        histogram(var1(var2 == 1), binEdges, 'EdgeColor', getColour('o'), ...
            'DisplayStyle', 'stairs', 'Normalization', 'probability', ...
            'LineWidth', 1)
        xline(mean(var1(var2 == 0)), '--k', 'linewidth', 1);
        xline(mean(var1(var2 == 0)), '--', 'color', getColour('b'), ...
            'linewidth', 1)
        xline(mean(var1(var2 == 1)), '--', 'color', getColour('o'), ...
            'linewidth', 1)
        xlabel(var6(j) + " larval settlement")

        % throw in the subfigure label
        subfigLabel(j, 'northeast')

    else

        % do this bs for the presentation version - throw the statistical
        % significance
        if ~conInd
            statSigInd = {["$D^{*}$", "$M^{*}$"], ...
                ["$D^{*}$", "$M^{*}$"], ["$D^{*}$", "$M^{*}$"]};
            exampleFigColour = {'w', 'w', 'w'};
        elseif ~conMaxInd
            statSigInd = {"", "", "", "$D^{*}$", ["$D^{*}$", "$M^{*}$"], ...
                "", "$M^{*}$", ["$D^{*}$", "$M^{*}$"]};
            exampleFigColour = {getColour('p', [], [], 0.75), 'w', 'w', ...
                'w', getColour('lb', [], [], 0.75), 'w', getColour('o', ...
                [], [], 0.75), 'w'};
        else 
            statSigInd = {"$D^{*}$", "", "", "$D^{*}$", ...
                ["$D^{*}$", "$M^{*}$"], ...
                "", "", ["$D^{*}$", "$M^{*}$"]};
            exampleFigColour = {getColour('p', [], [], 0.75), 'w', 'w', ...
                'w', getColour('lb', [], [], 0.75), 'w', getColour('o', ...
                [], [], 0.75), 'w'};
        end
        
        % do the boxplot here
        warning("off", "all")
        boxplot(var1, var2, 'colors', var3(i), 'Symbol', var4(i), ...
            'Widths', 0.15)

        % do this stuff I copied from the internet
        h = findobj(gca,'Tag','Box');
        var10 = ['r', 'g'];
        maxProb = 0;
        for k = length(h):-1:1

            % patch in the boxplot
            patch(get(h(k), 'XData'), get(h(k), 'YData'), ...
                getColour(var10(floor(k / 2) + 1)), 'FaceAlpha', 0.625, ...
                'edgecolor', 'k');

            % figure out the maximum values for the kde
            if ~conInd || (j == 1 || j == 5 || j == 7 || j == 8)
                [y, x] = kde(log(var1(var2 == 2 - k) + eps));
            else
                [y, x] = kde(var1(var2 == 2 - k));
            end
            if max(y) > maxProb
                maxProb = max(y);
            end
            
        end

        % replot the boxplot
        boxplot(var1, var2, 'colors', var3(i), 'Symbol', var4(i), ...
            'Widths', 0.15)
        yline(median(conMetricVals(outbrReefs)), '-.k')
        warning("on", "all")

        % format the rest
        set(gca, 'TickLabelInterpreter', 'Latex')
        xticklabels([])
        if ~conInd
            if ~presInd
                ylabel(var6(j) + " larval settlement")
            else
                title([var6(j), "COTS populations"])
            end
            set(gca, 'YScale', 'Log')
        else
            if presInd
                title(currYLabel)
            else
                ylabel(currYLabel)
            end
            if j == 1 || j == 5 || j == 7 || j == 8
                set(gca, 'YScale', 'Log')
            end
            if j == 5
                var9 = ylim();
                ylim([var9(1), 0.1])
            end
            if j == 7 || j == 8
                var9 = ylim();
                ylim([var9(1), 1.05  * max(conMetricVals)])
            end

        end
        xtickangle(gca, 45)
        box off

        % grab the y axis limits here, so I can reset them after plotting
        % the kdes
        yLims = ylim();

        % this is such a terrible way to do things, but so that I can make
        % the axes work I'm going to do the kdes down here
        % need to redo the above so that I can patch in the kde
        for k = length(h):-1:1

            % create the kde then patch it in, spltting cases based on
            % whether we're using a log-scale or not (so that we can
            % transform the data)
            if ~conInd || (j == 1 || j == 5 || j == 7 || j == 8)
                [y, x] = kde(log(var1(var2 == 2 - k) + eps));
                x = exp(x) - eps;
                minX = eps;
            else
                [y, x] = kde(var1(var2 == 2 - k));
                minX = 0;
            end


            % add extra points so the patch lines up, and truncate anything
            % from the kde below 0 (or eps)
            if sum(x < minX) > 0
                yNext = interp1(x, y, minX);
                y = y(x >= minX);
                x = x(x >= minX);
                y = [0; yNext; y];
                x = [minX; minX; x];
            else
                y = [0; y];
                x = [minX; x];
            end

            % can now patch and outline
            if k == 2
                yVals = - 0.25 * (y / maxProb) + 1.5;
            else
                yVals = 0.25 * (y / maxProb) + k + 0.5;
            end
            patch(yVals, x, getColour(var10(floor(k / 2) + 1)), ...
                'FaceAlpha', 0.625);
            plot(yVals([1:length(yVals), 1]), ...
                x([1:length(yVals), 1]), 'k')
            
        end

        % reset the axes
        if conInd
            xlim([0.4, 2.6])
        else
            xlim([0.5, 2.5])
        end
        ylim(yLims)

        % throw in the subfigure label
        subfigLabel(j, 'northwest')

        % throw in the statistical significance indicators
        subfigLabel(statSigInd{j}, 'southwest', 'inside', 15)

    end    

end

% show the statistically significant labels in
xlabel(tL, "$D^{*}$ -- significant distribution difference, " + ...
    "$M^{*}$ -- significant median difference, $\alpha = 0.05$", ...
    'interpreter', 'latex')

% throw in a legend and other bs
if histInd
    lG = legend("Non-outbreaking reefs", "Outbreaking reefs", "Mean", ...
        'location', 'northwest', 'Orientation', 'horizontal');
    lG.Layout.Tile = "North";
    ylabel(tL, "Proportion", "interpreter", "latex")
    setFontSize(18)
else
    lG = legend("Non-outbreak reefs", "Outbreak reefs", ...
        "Outbreak median", 'location', 'northwest', 'orientation', ...
        'horizontal');
    lG.Layout.Tile = "North";
    if ~presInd
        setFontSize(15)
    else
        setFontSize(14)
    end
end

% throw in a title and change the figure colours
if ~presInd
    title(tL, titleString, 'Interpreter', 'latex')
end
if i == 1
    lightFig()
else
    darkFig()
end

if presInd
    ylabel(tL, "Larval settlement", "interpreter", 'latex')
end

% reset some of the axis colours perhaps
if presInd && conInd
    for j = 1:8
        nexttile(j)
        ax = gca;
        ax.Color = exampleFigColour{j};
    end
end