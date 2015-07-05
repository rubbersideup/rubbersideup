% I have saved rows from this csv file that have the Total_Bike column
% populated in crash.mat as it takes a while to load
% allcsv = loadcsv('../data/Crash_2010_to_2014_mrwa/Crash_2010_to_2014_mrwa.csv');
% isbike = ~cellfun(@isempty, {allcsv.Total_Bike});
% crashcsv = allcsv(isbike);
load crash.mat

crash_lat = cellfun(@str2double, {crashcsv.Lat});
crash_long = cellfun(@str2double, {crashcsv.Long_});

% I have saved this csv file in roads.mat as it takes a while to load
%roads = loadcsv('../data/Road_Hierarchy_mrwa/Road_Hierarchy_mrwa.csv');
load roads.mat

[shared_lats, shared_longs] = loadroutes('../data/converted/shared_coords_processed.txt');
[psp_lats, psp_longs] = loadroutes('../data/converted/psp_coords_processed.txt');
[pbn_lats, pbn_longs] = loadroutes('../data/converted/pbn_coords_processed.txt');

% Plot the routes
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

[shared_lats, shared_longs] = interpolate_routes(shared_lats, shared_longs);
[psp_lats, psp_longs] = interpolate_routes(psp_lats, psp_longs);
[pbn_lats, pbn_longs] = interpolate_routes(pbn_lats, pbn_longs);

% Computes the distances of each type of route to the crash sites
%compute_route_distances;
load routedists.mat 

% Joins rows from different MRWA tables
join;

% exports a Javascript array to data.js, which will be loaded by
% crash_stats.html
savejs;

% Saves the stats
savestats;
