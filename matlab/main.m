% This is the main script to parse the CSV files.
% It generates crash locations saved in data.js
% and also the stats figures and CSV files.
% Lots of this has been loaded, processed and then saved into .mat files
% which is much faster for reprocessing (e.g. generating new stats)
% than loading everything directly from the CSV files each time.
% However you can just uncomment the relevant lines below if you want
% to regenerate everything from scratch.

% I have saved rows from this csv file that have the Total_Bike column
% populated in crash.mat as it takes a while to load
% allcsv = loadcsv('../data/Crash_2010_to_2014_mrwa/Crash_2010_to_2014_mrwa.csv');
% isbike = ~cellfun(@isempty, {allcsv.Total_Bike});
% crashcsv = allcsv(isbike);
% crash_lat = cellfun(@str2double, {crashcsv.Lat});
% crash_long = cellfun(@str2double, {crashcsv.Long_});
load crash.mat

% I have saved this csv file in roads.mat as it takes a while to load
%roads = loadcsv('../data/Road_Hierarchy_mrwa/Road_Hierarchy_mrwa.csv');
load roads.mat

% trafficlights = loadcsv('../data/Traffic_Signals_mrwa/Traffic_Signals_latlong.csv');
% lights_lat = cellfun(@str2double, {trafficlights.IIT_LATITUDE});
% lights_long = cellfun(@str2double, {trafficlights.IIT_LONGITUDE});
% valid_lights = ~strcmp('DECOMMISSIONED', {trafficlights.Signal_Type_NotUsed}) & ~isempty({trafficlights.Signal_Type_NotUsed}) & ...
%     ~isnan(lights_lat) & ~isnan(lights_long);
% lights_lat = lights_lat(valid_lights);
% lights_long = lights_long(valid_lights);
% clear valid_lights;
load trafficlights;

% roundabouts = loadcsv('../data/Signs_Regulatory_mrwa/Signs_Regulatory_mrwa.csv');
% roundabouts_lat = cellfun(@str2double, {roundabouts.LATITUDE});
% roundabouts_long = cellfun(@str2double, {roundabouts.LONGITUDE});
% % could be 'MULTI-LANE ROUNDABOUT'
% valid_roundabouts = cellfun(@(x) ~isempty(strfind(x, 'ROUNDABOUT')), {roundabouts.PANEL_01_DESIGN_MEANING}) & ...
%     ~cellfun(@(x) ~isempty(strfind(x, 'AHEAD')), {roundabouts.PANEL_01_DESIGN_MEANING});
% roundabouts_lat = roundabouts_lat(valid_roundabouts);
% roundabouts_long = roundabouts_long(valid_roundabouts);
% clear valid_roundabouts;
load roundabouts;

% stops = loadcsv('../data/Signs_Regulatory_mrwa/Signs_Regulatory_mrwa.csv');
% stops_lat = cellfun(@str2double, {stops.LATITUDE});
% stops_long = cellfun(@str2double, {stops.LONGITUDE});
% % e.g. 'STOP (900x900)'
% valid_stops = cellfun(@(x) ~isempty(strfind(x, 'STOP (')), {stops.PANEL_01_DESIGN_MEANING});
% stops_lat = stops_lat(valid_stops);
% stops_long = stops_long(valid_stops);
% clear valid_stops;
load stops;

% There are 3 types of routes to process. We generate distances of each
% crash site separately for each type of bike route.
[shared_lats, shared_longs] = loadroutes('../data/converted/shared_coords_processed.txt');
[psp_lats, psp_longs] = loadroutes('../data/converted/psp_coords_processed.txt');
[pbn_lats, pbn_longs] = loadroutes('../data/converted/pbn_coords_processed.txt');

% Plot the routes in a figure.
% figure(1)
% clf
% hold on
% for ii=1:length(shared_lats)
%     plot(shared_longs{ii}, shared_lats{ii}, 'b-');
% end
% for ii=1:length(psp_lats)
%     plot(psp_longs{ii}, psp_lats{ii}, 'r-');
% end
% for ii=1:length(pbn_lats)
%     plot(pbn_longs{ii}, pbn_lats{ii}, 'k-');
% end

% Computes the distances of each type of route to the crash sites
% Again this was precomputed and saved.
%compute_route_distances;
load routedists.mat 

% Joins rows from different MRWA tables
join;

% exports a Javascript array to data.js, which will be loaded by
% the map
savejs;

% Generates stats, saves them as PNG figures and CSV files
savestats;
