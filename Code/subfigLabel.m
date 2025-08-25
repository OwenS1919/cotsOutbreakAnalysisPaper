function subfigLabel(label, location, insideInd, fontSize)
% subfigLab() will add a subfigure label to plots in a tiledlayout()

% inputs:

% label - the label to use for the subfigure, can be either a string e.g.
    % "A" or an integer which is then mapped to the alphabet
% location - optional - the location to place the figure label, can be
    % "northeast", "northwest" etc etc (default is "northwest")
% insideInd - optional - specify as "inside" if the label is to appear
    % inside the axes, and "outside" otherwise (default is "inside")


% set defaults
if nargin < 2 || isempty(location) 
    location = "northeast";
end
if nargin < 3 || isempty(insideInd) 
    insideInd = "inside";
end
if nargin < 4 || isempty(fontSize)
    fontSize = 12;
end

% alright let's try this - might be easiest to just set the positions here
if location == "northeast"
    x = 0.975;
    y = 0.975;
    horAlign = "right";
    verAlign = "top";
elseif location == "northwest"
    x = 0.025;
    y = 0.975;
    horAlign = "left";
    verAlign = "top";
elseif location == "southeast"
    x = 0.975;
    y = 0.025;
    horAlign = "right";
    verAlign = "bottom";
else 
    x = 0.025;
    y = 0.025;
    horAlign = "left";
    verAlign = "bottom";
end

% if I try to use outside throw an error because I haven't coded it yet
if insideInd == "outside"
    error("oops need to code this up")
end

% if we've inputted an integer for the label, convert it to a letter
if isnumeric(label)
    var1 = ["(a)", "(b)", "(c)", "(d)", "(e)", "(f)", "(g)", "(h)", "(i)", ...
        "(j)", "(k)"];
    label = var1(label);
end

% now plot the text
text(x, y, label, 'units', 'normalized', 'HorizontalAlignment', horAlign, ...
    'VerticalAlignment', verAlign, 'FontSize', fontSize)

end