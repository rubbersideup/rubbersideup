% Outputs some csvs for loading into the stats webpage
speed_classes = [10, 30:10:110];
speed_legend = cell(size(speed_classes));
for ii=1:length(speed_classes)
    speed_legend{ii} = sprintf('%dkm/h', speed_classes(ii));
end

% A vehicle field will either be empty or '1'.
% To check for which other type of vehicle was involved, we initially check
% that the field for that vehicle is not empty, then invert the results.
% There are no recorded cases where multiple other vehicle types were
% involved.
% These are all row vectors
vs_truck = ~cellfun(@isempty, {crashcsv.Total_Truck}) & ~cellfun(@isempty, {crashcsv.Total_Heavy_Truck});
vs_motorcycle = ~cellfun(@isempty, {crashcsv.Total_Motor_Cycle});
vs_pedestrian = ~cellfun(@isempty, {crashcsv.Total_Pedestrian});
vs_other = ~cellfun(@isempty, {crashcsv.Total_Others_Vehicles});
vs_animal = ~cellfun(@isempty, {crashcsv.Total_Animal});
% Collate these into a single array. The legend and vsvehicle must be in
% the same order.
vehicle_legend = {'Truck', 'Motorcycle', 'Other', 'Pedestrian', 'Animal', 'Bike only'};
vs_vehicle = [vs_truck; vs_motorcycle; vs_other; vs_pedestrian; vs_animal];
vs_vehicle(end + 1, :) = sum(vs_vehicle) == 0; % bike only - if no other vehicles involved

% Some roads have a 51km/h speed limit in the database which we change to 50
% Later we need to look out for NaN values for speed limits, sometimes they
% are undefined.
parsed_speeds = cellfun(@str2double, {crashcsv.SPLI_SPEED_LIMIT});
parsed_speeds(parsed_speeds == 51) = 50;

% Now collate the severity classes for each crash.
all_severity = {crashcsv.Severity};
% Again these are row vectors.
is_fatal = strcmp('Fatal', all_severity);
is_hospital = strcmp('Hospital', all_severity);
is_medical = strcmp('Medical', all_severity);
% Property has two classes that both start with 'Property'. Combine these
% as we have no definitions for differentiating minor vs major property
% damage.
is_property = ~cellfun(@isempty, strfind(all_severity, 'Property'));
is_unknown = strcmp('Unknown', all_severity); % Actually, no cases of this.
severity_legend = {'Fatal', 'Hospital', 'Medical', 'Property'};
is_severity = [is_fatal; is_hospital; is_medical; is_property];

% Create a matrix containing different speed limit/vehicle and speed
% limit/severity combinations.
% For these matrices, the column name is given first.
speed_vs_vehicle = zeros(length(vehicle_legend), length(speed_classes));
speed_vs_severity = zeros(length(severity_legend), length(speed_classes));
for ii=1:length(speed_classes)
    for jj=1:length(vehicle_legend)
        % Basically, find the columns with the corresponding speed limits,
        % and count how many of those crashes involve this vehicle type.
        speed_vs_vehicle(jj, ii) = sum(vs_vehicle(jj, :) .* (parsed_speeds == speed_classes(ii)));
    end
    
    for jj=1:length(severity_legend)
        speed_vs_severity(jj, ii) = sum(is_severity(jj, :) .* (parsed_speeds == speed_classes(ii)));
    end
end

% Now some charts.
clf
bar(speed_vs_severity', 'stacked');
title('Crash occurrences by severity and speed limit zone');
xlabel('Speed limit (km/h)');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', cellfun(@num2str, {speed_classes(:)}, 'UniformOutput', false));
ylabel('Count');
legend(severity_legend);
ax = axis;
% Add 1.5 here to provide room for the legend.
ax([1,2]) = [0.5,length(speed_classes)+3.5];
axis(ax);
% Save the figure as a PNG
print -dpng '../severity_vs_speed.png';
dumpcsv('../severity_vs_speed.csv', severity_legend, speed_legend, speed_vs_severity');


bar(speed_vs_vehicle', 'stacked');
title('Crash occurrences by vehicle type and speed limit zone');
xlabel('Speed limit (km/h)');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', cellfun(@num2str, {speed_classes(:)}, 'UniformOutput', false))
ylabel('Count');
legend(vehicle_legend);
ax = axis;
ax([1,2]) = [0.5,length(speed_classes)+3.5];
axis(ax);
print -dpng '../vehicle_vs_speed.png';
dumpcsv('../vehicle_vs_speed.csv', vehicle_legend, speed_legend, speed_vs_vehicle');

% Same figures but switching the grouping.
bar(speed_vs_severity, 'stacked');
title('Crash occurrences by speed limit zone and severity');
xlabel('Severity');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', severity_legend)
ylabel('Count');
legend(speed_legend);
ax = axis;
ax([1,2]) = [0.5,length(severity_legend)+1.5];
axis(ax);
% Save the figure as a PNG
print -dpng '../speed_vs_severity.png';
dumpcsv('../speed_vs_severity.csv', severity_legend, speed_legend, speed_vs_severity');

bar(speed_vs_vehicle, 'stacked');
title('Crash occurrences by speed limit zone and vehicle');
xlabel('Other vehicle involved');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', vehicle_legend)
ylabel('Count');
legend(speed_legend);
ax = axis;
ax([1,2]) = [0.5,length(vehicle_legend)+2.5];
axis(ax);
% Save the figure as a PNG
print -dpng '../speed_vs_vehicle.png';
dumpcsv('../speed_vs_vehicle.csv', vehicle_legend, speed_legend, speed_vs_vehicle');

% These are normed by speed limit, so very low or very high speed limit
% zones that do not have a lot of data can be visualised.
speed_vs_vehicle_normed = speed_vs_vehicle ./ repmat(sum(speed_vs_vehicle), [length(vehicle_legend), 1]);
speed_vs_severity_normed = speed_vs_severity ./ repmat(sum(speed_vs_severity), [length(severity_legend), 1]);

% Repeat the figures
bar(speed_vs_severity_normed', 'stacked');
title('Crash occurrences by severity and speed limit zone (normalised)');
xlabel('Speed limit (km/h)');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', cellfun(@num2str, {speed_classes(:)}, 'UniformOutput', false))
ylabel('Proportion');
legend(severity_legend);
ax = axis;
ax([1,2]) = [0.5,length(speed_classes)+3.5];
axis(ax);
print -dpng '../severity_vs_speed_normed.png';
dumpcsv('../severity_vs_speed_normed.csv', severity_legend, speed_legend, speed_vs_severity_normed');

bar(speed_vs_vehicle_normed', 'stacked');
title('Crash occurrences by vehicle type and speed limit zone (normalised)');
xlabel('Speed limit (km/h)');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', cellfun(@num2str, {speed_classes(:)}, 'UniformOutput', false))
ylabel('Proportion');
legend(vehicle_legend);
ax = axis;
ax([1,2]) = [0.5,length(speed_classes)+3.5];
axis(ax);
print -dpng '../vehicle_vs_speed_normed.png';
dumpcsv('../vehicle_vs_speed_normed.csv', vehicle_legend, speed_legend, speed_vs_vehicle_normed');

% Same figures but switching the grouping.
speed_vs_vehicle_transpose_normed = speed_vs_vehicle ./ repmat(sum(speed_vs_vehicle, 2), [1, length(speed_classes)]);
speed_vs_severity_transpose_normed = speed_vs_severity ./ repmat(sum(speed_vs_severity, 2), [1, length(speed_classes)]);

bar(speed_vs_severity_transpose_normed, 'stacked');
title('Crash occurrences by speed limit zone and severity (normalised)');
xlabel('Severity');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', severity_legend)
ylabel('Proportion');
legend(speed_legend);
axis([0.5,5.5,0,1]);
% Save the figure as a PNG
print -dpng '../speed_vs_severity_normed.png';
dumpcsv('../speed_vs_severity_normed.csv', speed_legend, severity_legend, speed_vs_severity_transpose_normed);

bar(speed_vs_vehicle_transpose_normed, 'stacked');
title('Crash occurrences by speed limit zone and vehicle (normalised)');
xlabel('Other vehicle involved');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', vehicle_legend)
ylabel('Proportion');
legend(speed_legend);
ax = axis;
ax([1,2]) = [0.5,length(vehicle_legend)+2.5];
axis(ax);
% Save the figure as a PNG
print -dpng '../speed_vs_vehicle_normed.png';
dumpcsv('../speed_vs_vehicle_normed.csv', speed_legend, vehicle_legend, speed_vs_vehicle_transpose_normed);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Severity by vehicle now
% We already have the crashes classified by vehicle type
% Now for each vehicle type, we extract the number of crashes
% by severity, preserving the order in severity_legend.
% Here, vs_vehicle(:, lights_crash_inds) gets all crashes at traffic
% lights, and then sum(xx, 2) sums the number of crashes at lights by
% vehicle (row).
severity_by_vehicle = [sum(vs_vehicle(:, is_fatal), 2), sum(vs_vehicle(:, is_hospital), 2), sum(vs_vehicle(:, is_medical), 2), sum(vs_vehicle(:, is_property), 2)];
bar(severity_by_vehicle, 'stacked');
title('Crash occurrences by severity and vehicle type');
xlabel('Other vehicle involved');
set(gca, 'xticklabel', vehicle_legend)
ylabel('Count');
legend(severity_legend);
ax = axis;
ax([1,2]) = [0.5,length(vehicle_legend)+2.5];
axis(ax);
print -dpng '../severity_by_vehicle.png';
dumpcsv('../severity_by_vehicle.csv', severity_legend, vehicle_legend, severity_by_vehicle);

% Normalised version
severity_by_vehicle_normed = severity_by_vehicle ./ repmat(sum(severity_by_vehicle, 2), [1, length(severity_legend)]);
bar(severity_by_vehicle_normed, 'stacked');
title('Crash occurrences by severity and vehicle type (normalised)');
xlabel('Other vehicle involved');
set(gca, 'xticklabel', vehicle_legend)
ylabel('Proportion');
legend(severity_legend);
ax = axis;
ax([1,2]) = [0.5,length(vehicle_legend)+2.5];
axis(ax);
print -dpng '../severity_by_vehicle_normed.png';
dumpcsv('../severity_by_vehicle_normed.csv', severity_legend, vehicle_legend, severity_by_vehicle_normed);

% And now flipping the roles.
bar(severity_by_vehicle', 'stacked');
title('Crash occurrences by vehicle type and severity');
xlabel('Severity');
set(gca, 'xticklabel', severity_legend)
ylabel('Count');
legend(vehicle_legend);
ax = axis;
ax([1,2]) = [0.5,length(severity_legend)+1.5];
axis(ax);
print -dpng '../vehicle_by_severity.png';
dumpcsv('../vehicle_by_severity.csv', vehicle_legend, severity_legend, severity_by_vehicle');

vehicle_by_severity_normed = severity_by_vehicle ./ repmat(sum(severity_by_vehicle, 1), [length(vehicle_legend), 1]);
bar(vehicle_by_severity_normed', 'stacked');
title('Crash occurrences by vehicle type and severity (normalised)');
xlabel('Severity');
set(gca, 'xticklabel', severity_legend)
ylabel('Count');
legend(vehicle_legend);
ax = axis;
ax([1,2]) = [0.5,length(severity_legend)+1.5];
axis(ax);
print -dpng '../vehicle_by_severity_normed.png';
dumpcsv('../vehicle_by_severity_normed.csv', vehicle_legend, severity_legend, vehicle_by_severity_normed');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now dumping the distance to the infrastructure
clf
best_dist = min([best_psp_dist; best_pbn_dist; best_shared_dist]);
hist_bins = 0:0.1:10;
dist_hist = histc(best_dist, hist_bins);
bar(hist_bins, dist_hist, 'histc');
title('Crash occurrences by distance from bike infrastructure');
xlabel('Distance from any bike infrastructure (km)');
ylabel('Count');
ax = axis;
ax([1,2]) = [min(hist_bins), max(hist_bins)]; % set to range of hist_bins 
axis(ax);
print -dpng '../Dist_from_any.png';

hold off
dist_hist = histc(best_psp_dist, hist_bins);
bar(hist_bins, dist_hist, 'histc');
% we get the mean distance of those that fall within this window.
title({'Crash occurrences by distance from Principal Shared Paths', ...
sprintf('Mean distance: %.1fkm', mean(best_psp_dist(best_psp_dist < max(hist_bins))))});
xlabel('Distance from PSP (km)');
ylabel('Count');
ax = axis;
ax([1,2]) = [min(hist_bins), max(hist_bins)]; % set to range of hist_bins 
axis(ax);
print -dpng '../Dist_from_psp.png';

hold off
dist_hist = histc(best_pbn_dist, hist_bins);
bar(hist_bins, dist_hist, 'histc');
title({'Crash occurrences by distance from Perth Bike Network', ...
sprintf('Mean distance: %.1fkm', mean(best_pbn_dist(best_pbn_dist < max(hist_bins))))});
xlabel('Distance from nearest PBN route (km)');
ylabel('Count');
ax = axis;
ax([1,2]) = [min(hist_bins), max(hist_bins)]; % set to range of hist_bins 
axis(ax);
print -dpng '../Dist_from_pbn.png';

hold off
dist_hist = histc(best_shared_dist, hist_bins);
bar(hist_bins, dist_hist, 'histc');
title({'Crash occurrences by distance from other shared paths', ...
sprintf('Mean distance: %.1fkm', mean(best_shared_dist(best_shared_dist < max(hist_bins))))});
xlabel('Distance from shared path (km)');
ylabel('Count');
ax = axis;
ax([1,2]) = [min(hist_bins), max(hist_bins)]; % set to range of hist_bins 
axis(ax);
print -dpng '../Dist_from_shared.png';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now look at crash locations: intersection vs midblock, by vehicle type
% Remember that 'Intersection' was reclassified in join.m as
% either Lights, Roundabout or Stop if other database tables had these
% features in the vicinity of the intersection.
lights_crash_inds = strcmp('Lights', {crashcsv.Acc_Type});
roundabout_crash_inds = strcmp('Roundabout', {crashcsv.Acc_Type});
stop_crash_inds = strcmp('Stop', {crashcsv.Acc_Type});
intx_crash_inds = strcmp('Intersection', {crashcsv.Acc_Type});
midblock_crash_inds = strcmp('Midblock', {crashcsv.Acc_Type});
intersection_legend = {'Traffic lights', 'Roundabout', 'Stop sign', 'Other intersection', 'Midblock'};
% We already have the crashes classified by vehicle type
% Now for each vehicle type, we extract the number of crashes
% by intersection.
% Here, vs_vehicle(:, lights_crash_inds) gets all crashes at traffic
% lights, and then sum(xx, 2) sums the number of crashes at lights by
% vehicle (row).
intx_by_vehicle = [sum(vs_vehicle(:, lights_crash_inds), 2), sum(vs_vehicle(:, roundabout_crash_inds), 2), sum(vs_vehicle(:, stop_crash_inds), 2), sum(vs_vehicle(:, intx_crash_inds), 2), sum(vs_vehicle(:, midblock_crash_inds), 2)];
% Repeat the figures
bar(intx_by_vehicle, 'stacked');
title('Crash occurrences by intersection and vehicle type');
xlabel('Other vehicle involved');
set(gca, 'xticklabel', vehicle_legend)
ylabel('Count');
legend(intersection_legend);
ax = axis;
ax([1,2]) = [0.5,length(vehicle_legend)+3];
axis(ax);
print -dpng '../intx_by_vehicle.png';
dumpcsv('../intx_by_vehicle.csv', intersection_legend, vehicle_legend, intx_by_vehicle);

% Now look at crash locations: intersection vs midblock, by vehicle type
% Repeat the figures
intx_by_vehicle_normed = intx_by_vehicle ./ repmat(sum(intx_by_vehicle, 2), [1, length(intersection_legend)]);
bar(intx_by_vehicle_normed, 'stacked');
title('Crash occurrences by intersection and vehicle type (normalised)');
xlabel('Other vehicle involved');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', vehicle_legend)
ylabel('Proportion');
legend(intersection_legend);
ax = axis;
ax([1,2]) = [0.5,length(vehicle_legend)+3];
axis(ax);
print -dpng '../intx_by_vehicle_normed.png';
dumpcsv('../intx_by_vehicle_normed.csv', intersection_legend, vehicle_legend, intx_by_vehicle_normed);

% Repeat the figures but with classes switched
bar(intx_by_vehicle', 'stacked');
title('Crash occurrences by vehicle type and intersection');
xlabel('Intersection');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', intersection_legend)
ylabel('Count');
legend(vehicle_legend);
ax = axis;
ax([1,2]) = [0.5,length(intersection_legend)+2];
axis(ax);
print -dpng '../vehicle_by_intx.png';
dumpcsv('../vehicle_by_intx.csv', vehicle_legend, intersection_legend, intx_by_vehicle');

% ... and the normed version.
vehicle_by_intx_normed = intx_by_vehicle ./ repmat(sum(intx_by_vehicle, 1), [length(vehicle_legend), 1]);
bar(vehicle_by_intx_normed', 'stacked');
title('Crash occurrences by vehicle type and intersection (normalised)');
xlabel('Intersection');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', intersection_legend)
ylabel('Proportion');
legend(vehicle_legend);
ax = axis;
ax([1,2]) = [0.5,length(intersection_legend)+2];
axis(ax);
print -dpng '../vehicle_by_intx_normed.png';
dumpcsv('../vehicle_by_intx_normed.csv', vehicle_legend, intersection_legend, vehicle_by_intx_normed');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% As above, but by severity rather than by vehicle
% Similar to above, is_severity(:, lights_crash_inds) gets all crashes at
% lights with rows indicating severity, and then we sum to get the number
% of crashes by severity for traffic lights.
intx_by_severity = [sum(is_severity(:, lights_crash_inds), 2), sum(is_severity(:, roundabout_crash_inds), 2), sum(is_severity(:, stop_crash_inds), 2), sum(is_severity(:, intx_crash_inds), 2), sum(is_severity(:, midblock_crash_inds), 2)];
% Repeat the figures
bar(intx_by_severity, 'stacked');
title('Crash occurrences by intersection and severity');
xlabel('Severity');
set(gca, 'xticklabel', severity_legend)
ylabel('Count');
legend(intersection_legend);
ax = axis;
ax([1,2]) = [0.5,length(severity_legend)+2.5];
axis(ax);
print -dpng '../intx_by_severity.png';
dumpcsv('../intx_by_severity.csv', intersection_legend, severity_legend, intx_by_severity);


% Now look at crash locations: intersection vs midblock, by vehicle type
% Repeat the figures
intx_by_severity_normed = intx_by_severity ./ repmat(sum(intx_by_severity, 2), [1, length(intersection_legend)]);
bar(intx_by_severity_normed, 'stacked');
title('Crash occurrences by intersection and severity (normalised)');
xlabel('Severity');
set(gca, 'xticklabel', severity_legend)
ylabel('Proportion');
legend(intersection_legend);
ax = axis;
ax([1,2]) = [0.5,length(severity_legend)+2.5];
axis(ax);
print -dpng '../intx_by_severity_normed.png';
dumpcsv('../intx_by_severity_normed.csv', intersection_legend, severity_legend, intx_by_severity_normed);

% Repeat the figures but with classes switched
bar(intx_by_severity', 'stacked');
title('Crash occurrences by severity and intersection');
xlabel('Intersection');
set(gca, 'xticklabel', intersection_legend)
ylabel('Count');
legend(severity_legend);
ax = axis;
ax([1,2]) = [0.5,length(intersection_legend)+2];
axis(ax);
print -dpng '../severity_by_intx.png';
dumpcsv('../severity_by_intx.csv', severity_legend, intersection_legend, intx_by_severity');

% ... and the normed version.
severity_by_intx_normed = intx_by_severity ./ repmat(sum(intx_by_severity, 1), [length(severity_legend), 1]);
bar(severity_by_intx_normed', 'stacked');
title('Crash occurrences by severity and intersection (normalised)');
xlabel('Intersection');
set(gca, 'xticklabel', intersection_legend)
ylabel('Proportion');
legend(severity_legend);
ax = axis;
ax([1,2]) = [0.5,length(intersection_legend)+2];
axis(ax);
print -dpng '../severity_by_intx_normed.png';
dumpcsv('../severity_by_intx_normed.csv', severity_legend, intersection_legend, severity_by_intx_normed');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Next - by LGA
% Only keep the metropolitan LGAs.
is_metro_lga = strcmp('Metropolitan', {roads.RA_NAME});
lg_area_names = unique({roads(is_metro_lga).LG_NAME});

crashes_by_lga = zeros(1, length(lg_area_names));
km_by_lga = zeros(1, length(lg_area_names));

% First we get the number of km for each LGA.
for ii=1:length(lg_area_names)
    
    % This is the number of crashes
    crashes_by_lga(ii) = sum(strcmp(lg_area_names{ii}, {crashcsv.LG_NAME}));

    % Indices of roads lying in this LGA
    roads_this_lga = find(strcmp(lg_area_names{ii}, {roads.LG_NAME}));

    % We only count km for single carriageway roads, or for dual
    % carriageway roads, we get the distance of the left carriageway.
    % i.e. don't duplicate distance by counting left AND right.
    single_or_left = strcmp('Left', {roads(roads_this_lga).CWY}) | strcmp('Single', {roads(roads_this_lga).CWY});
    end_km_these_roads = cellfun(@str2double, {roads(roads_this_lga(single_or_left)).END_TRUE_DIST});
    start_km_these_roads = cellfun(@str2double, {roads(roads_this_lga(single_or_left)).START_TRUE_DIST});
    
    km_by_lga(ii) = sum(end_km_these_roads - start_km_these_roads);
end
crashes_per_km_by_lga = crashes_by_lga ./ km_by_lga;

barh(km_by_lga)
set(gca, 'ytick', 1:length(lg_area_names))
set(gca, 'yticklabel', lg_area_names)
axis ij
title('Kilometres of road by administrative area');
xlabel('Total kilometres');
ylabel('Area');
grid on
print -dpng '../lga_km.png'
% These are just row vectors.
dumpcsv('../lga_km.csv', lg_area_names, {'Total kilometres'}, km_by_lga);

barh(crashes_by_lga)
set(gca, 'ytick', 1:length(lg_area_names))
set(gca, 'yticklabel', lg_area_names)
axis ij
title('Number of crashes by administrative area');
xlabel('Number of crashes');
ylabel('Area');
grid on
print -dpng '../lga_crashes.png'
dumpcsv('../lga_crashes.csv', lg_area_names, {'Number of crashes'}, crashes_by_lga);

barh(crashes_per_km_by_lga)
set(gca, 'ytick', 1:length(lg_area_names))
set(gca, 'yticklabel', lg_area_names)
axis ij
title('Crashes per km by administrative area');
xlabel('Crashes/km');
ylabel('Area');
grid on
print -dpng '../lga_crashes_per_km.png';
dumpcsv('../lga_crashes_per_km.csv', lg_area_names, {'Number of crashes per km'}, crashes_per_km_by_lga);

