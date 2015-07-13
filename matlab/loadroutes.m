% lats is a cell array, each item is a vector of latitudes for a given
% path. Similarly for longs.
% The route files were taken from .shp files from the Department
% of Transport, converted to KML (e.g. in ArcMap). Only lines with
% <coordinates> tags were kept, the tags were then removed and the Z
% coordinates removed.

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