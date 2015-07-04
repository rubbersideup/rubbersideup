% does some table joins from different main roads datasets. The bulk of the
% data is from the crash dataset, but we then find road class and speed
% limit data from the other tables.

if ~exist('crashcsv', 'var')
    load crash.mat
end

if ~exist('roads', 'var')
    load roads.mat
end

if ~exist('speedscsv', 'var')
    load speeds.mat
end

% preallocate these
all_roads_roads = {roads.ROAD};
all_roads_start_slk = cellfun(@str2double, {roads.START_SLK});
all_roads_end_slk = cellfun(@str2double, {roads.END_SLK});

all_speeds_roads = {speedscsv.ROAD};
all_speeds_start_slk = cellfun(@str2double, {speedscsv.START_SLK});
all_speeds_end_slk = cellfun(@str2double, {speedscsv.END_SLK});


for ii=1:length(crashcsv)
    road_no = crashcsv(ii).Road_No;
    crash_slk = str2double(crashcsv(ii).SLK);

    % first we want to do a join on crash.Road_No = roads.Road and on
    % crash.SLK >= roads.START_SLK  and crash.SLK <= roads.END_SLK
    % Then copy the ROAD_HIERARCHY column from the roads, which will be one of
    % Acces Road, Distributor A, Distributor B, Local Distributor, Primary
    % Distributor, Regional Distributor
    roads_inds = find(strcmp(road_no, all_roads_roads));
    found = crash_slk >= all_roads_start_slk(roads_inds) & crash_slk <= all_roads_end_slk(roads_inds);    
    
    crashcsv(ii).ROAD_HIERARCHY = roads(roads_inds(found)).ROAD_HIERARCHY;
    
    % Similarly we want to do a join on crash.Road_No = speeds.Road and on
    % crash.SLK >= speeds.START_SLK  and crash.SLK <= speeds.END_SLK
    % Then copy the SPLI_SPEED_LIMIT column from the speeds. Note that there
    % are some values that are 51, rather than 50. Remapt these values to 50.
    speeds_inds = find(strcmp(road_no, all_speeds_roads));
    found = crash_slk >= all_speeds_start_slk(speeds_inds) & crash_slk <= all_speeds_end_slk(speeds_inds);    
    
    crashcsv(ii).SPLI_SPEED_LIMIT = speedscsv(speeds_inds(found)).SPLI_SPEED_LIMIT;

end    
