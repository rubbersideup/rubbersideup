% lats is a cell array, each item is a vector of latitudes for a given
% path.

function [lats, longs] = loadroutes(filename)

fp = fopen(filename, 'r');

lats = {};
longs = {};

% Load each row into an array element.
while ~feof(fp)
    this_line = strtrim(fgets(fp));

    parsed = sscanf(this_line, '%f,%f ');
    longs{end+1} = parsed(1:2:end)';
    lats{end+1} = parsed(2:2:end)';
    
end

fclose(fp);