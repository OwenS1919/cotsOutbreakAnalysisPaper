    function [uniqueArr, countsArr] = uniqueAndCount(inputArr, rowsColsInd)
% uniqueAndCount() will perform matlab's unique function, however also
% return the counts associated with each of the unique elements

% inputs:

% inputArr - the input array to perform the operation on
% rowsColsInd - optional - indicates whether to use the options "rows" or
    % "columns" in the call to unique, or can just use "vector", in which
    % case the input is just a vector - default is "vector"

% outputs:

% uniqueArr - the unique elements of inputArr
% countsArr - their associated counts

% set a default for rowsColsInd
if nargin < 2 || isempty(rowsColsInd)
    rowsColsInd = "vector";
end

% if we want to find the unique columns, transpose the matrix so that my
% life is easier
if rowsColsInd == "cols"
    inputArr = inputArr';
end

% do the shit for multiDim arrays
if rowsColsInd == "rows" || rowsColsInd == "cols"
    uniqueArr = unique(inputArr, 'rows');
    countsArr = zeros(length(uniqueArr), 1);
    for i = 1:length(uniqueArr)
        countsArr(i) = sum((inputArr(:, 1) == uniqueArr(i, 1)) ...
            .* (inputArr(:, 2) == uniqueArr(i, 2)));
    end
elseif rowsColsInd == "vector"
    uniqueArr = unique(inputArr);
    countsArr = zeros(size(uniqueArr));
    for i = 1:length(uniqueArr)
        countsArr(i) = sum(inputArr == uniqueArr(i));
    end
else
    error('haven''t coded this yet lol')
end

% flip the shit back if we did earlier
if rowsColsInd == "cols"
    uniqueArr = uniqueArr';
end

end