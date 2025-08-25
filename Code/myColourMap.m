function colourMap = myColourMap(styleInd, n)
% myColourMap will make a custom colormap emulating the matlab turbo
% colormap but with colours that I like more lol

% input:

% styleInd - optional - a string indicating the colourmap style to use, 
    % with options including my version of turbo, halfturbo, and the option 
    % to select a number of colours in sequence with their colour codes
    % separated by the number 2 - default is turbo
% n - optional - the resolution of the colormap - default is 256

% output:

% colormap - a colormap in the default matlab form n x 3

% set default values if necessary
if nargin < 1 || isempty(styleInd)
    styleInd = "turbo";
end
if nargin < 2 || isempty(n)

    % if we're using the Zeros version of the colormap, use like idk 1000
    % points methinks
    if contains(styleInd, "Zeros")
        n = 2000;
    else
        n = 256;
    end
    
end

% split based on the colourmap choice being made
if contains(styleInd, "turbo")

    % order will be the same as turbo, so black, to dark blue, to blue, to
    % green, to yellow, to orange to red
    k = [0 0 0];
    db = [0 0.4470 0.7410];
    lb = [0.3010 0.7450 0.9330];
    g = [0.4660 0.6740 0.1880];
    y = [0.9290 0.6940 0.1250];
    o = [0.8500 0.3250 0.0980];
    r = [0.6350 0.0780 0.1840];

    % consolidate these in a matrix, because it's easier
    colMat = cat(1, k, db, lb, g, y, o, r);

    % create a set of points at which each colour currently sits
    colPoints = linspace(0, 1, 7);

elseif contains(styleInd, "halfTurbo")

    % order will be the same as turbo but without the darker colours and
    % ending in grey, so grey, to green, to yellow, to orange to red
    gr = [0.925 0.925 0.925];
    g = [0.4660 0.6740 0.1880];
    y = [0.9290 0.6940 0.1250];
    o = [0.8500 0.3250 0.0980];
    r = [0.6350 0.0780 0.1840];

    % consolidate these in a matrix, because it's easier
    colMat = cat(1, gr, g, y, o, r);

    % create a set of points at which each colour currently sits
    colPoints = linspace(0, 1, 5);

elseif contains(styleInd, "dmTurbo")

    % order will be the same as turbo but w/out the black
    db = [0 0.4470 0.7410];
    lb = [0.3010 0.7450 0.9330];
    g = [0.4660 0.6740 0.1880];
    y = [0.9290 0.6940 0.1250];
    o = [0.8500 0.3250 0.0980];
    r = [0.6350 0.0780 0.1840];

    % consolidate these in a matrix, because it's easier
    colMat = cat(1, db, lb, g, y, o, r);

    % create a set of points at which each colour currently sits
    colPoints = linspace(0, 1, 6);

elseif contains(styleInd, "random")

    % create a colormap with random colours, using the last digit specified
    % as the seed (if provided), then exit
    randSeed = split(styleInd, "m");
    if ~isempty(randSeed{2})
        rng(str2num(randSeed{2}));
    end

    % write in a number of normal colours
    db = [0 0.4470 0.7410];
    lb = [0.3010 0.7450 0.9330];
    g = [0.4660 0.6740 0.1880];
    y = [0.9290 0.6940 0.1250];
    o = [0.8500 0.3250 0.0980];
    r = [0.6350 0.0780 0.1840];
    p = [0.4940 0.1840 0.5560];

    % join the above into a matrix
    colourMat = [db; lb; g; y; o; r; p];

    % form a randomised colourMap by taking a randomised linear combination
    % of the colours above
    colourWeights = rand(n, 7);

    % set 70% of the weights to 0
    colourWeights(colourWeights < 0.7) = 0;
    colourWeights = colourWeights ./ sum(colourWeights, 2);
    colourMap = colourWeights * colourMat;
    return

elseif contains(styleInd, "2")

    % gonna do one colour to another colourmaps here too because why not
    var1 = strsplit(styleInd, "2");
    
    % going to use some eval trickery here so I can concatenate the colours
    % easily
    var2 = "colMat = cat(1";
    for i = 1:length(var1)
        var2 = var2 + ", getColour(var1{" + i + "})";
    end
    eval(var2 + ");")

    % create a set of points at which each colour currently sits
    colPoints = linspace(0, 1, length(var1));
    
end

% create a set of values to interpolate at
intPoints = linspace(0, 1, n);

% interpolate the r values
rVals = interp1(colPoints, colMat(:, 1), intPoints);

% interpolate the g values
gVals = interp1(colPoints, colMat(:, 2), intPoints);

% interpolate the b values
bVals = interp1(colPoints, colMat(:, 3), intPoints);

% join back values
colourMap = cat(2, rVals', gVals', bVals');

% if we're doing dmTurboZero add in a zero value
if contains(styleInd, "Zeros")
    % colourMap = cat(1, 0.5 * getColour('b'), colourMap);
    % colourMap = cat(1, getColour('br'), colourMap);
    colourMap = cat(1, getColour('p'), colourMap);
end

% if we want a randomised colourmap, let's randomise it
if contains(styleInd, "Rand")
    
    % set the seed and go for it
    rng(1)
    randSeq = randperm(size(colourMap, 1));
    colourMap = colourMap(randSeq, :);

end

end
