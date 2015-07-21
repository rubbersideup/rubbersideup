% Outputs some csvs for loading into the stats webpage, for crashes within
% 0.1km of the PBN.
is_pbn = best_pbn_dist < 0.1;
crashcsv = crashcsv(is_pbn);

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
title('PBN crash occurrences by severity and vehicle type');
xlabel('Other vehicle involved');
set(gca, 'xticklabel', vehicle_legend)
ylabel('Count');
legend(severity_legend);
ax = axis;
ax([1,2]) = [0.5,length(vehicle_legend)+2.5];
axis(ax);
print -dpng '../pbn_severity_by_vehicle.png';
dumpcsv('../pbn_severity_by_vehicle.csv', severity_legend, vehicle_legend, severity_by_vehicle);

% Normalised version
severity_by_vehicle_normed = severity_by_vehicle ./ repmat(sum(severity_by_vehicle, 2), [1, length(severity_legend)]);
bar(severity_by_vehicle_normed, 'stacked');
title('PBN crash occurrences by severity and vehicle type (normalised)');
xlabel('Other vehicle involved');
set(gca, 'xticklabel', vehicle_legend)
ylabel('Proportion');
legend(severity_legend);
ax = axis;
ax([1,2]) = [0.5,length(vehicle_legend)+2.5];
axis(ax);
print -dpng '../pbn_severity_by_vehicle_normed.png';
dumpcsv('../pbn_severity_by_vehicle_normed.csv', severity_legend, vehicle_legend, severity_by_vehicle_normed);

% And now flipping the roles.
bar(severity_by_vehicle', 'stacked');
title('PBN crash occurrences by vehicle type and severity');
xlabel('Severity');
set(gca, 'xticklabel', severity_legend)
ylabel('Count');
legend(vehicle_legend);
ax = axis;
ax([1,2]) = [0.5,length(severity_legend)+1.5];
axis(ax);
print -dpng '../pbn_vehicle_by_severity.png';
dumpcsv('../pbn_vehicle_by_severity.csv', vehicle_legend, severity_legend, severity_by_vehicle');

vehicle_by_severity_normed = severity_by_vehicle ./ repmat(sum(severity_by_vehicle, 1), [length(vehicle_legend), 1]);
bar(vehicle_by_severity_normed', 'stacked');
title('PBN crash occurrences by vehicle type and severity (normalised)');
xlabel('Severity');
set(gca, 'xticklabel', severity_legend)
ylabel('Count');
legend(vehicle_legend);
ax = axis;
ax([1,2]) = [0.5,length(severity_legend)+1.5];
axis(ax);
print -dpng '../pbn_vehicle_by_severity_normed.png';
dumpcsv('../pbn_vehicle_by_severity_normed.csv', vehicle_legend, severity_legend, vehicle_by_severity_normed');

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
title('PBN crash occurrences by intersection and vehicle type');
xlabel('Other vehicle involved');
set(gca, 'xticklabel', vehicle_legend)
ylabel('Count');
legend(intersection_legend);
ax = axis;
ax([1,2]) = [0.5,length(vehicle_legend)+3];
axis(ax);
print -dpng '../pbn_intx_by_vehicle.png';
dumpcsv('../pbn_intx_by_vehicle.csv', intersection_legend, vehicle_legend, intx_by_vehicle);

% Now look at crash locations: intersection vs midblock, by vehicle type
% Repeat the figures
intx_by_vehicle_normed = intx_by_vehicle ./ repmat(sum(intx_by_vehicle, 2), [1, length(intersection_legend)]);
bar(intx_by_vehicle_normed, 'stacked');
title('PBN crash occurrences by intersection and vehicle type (normalised)');
xlabel('Other vehicle involved');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', vehicle_legend)
ylabel('Proportion');
legend(intersection_legend);
ax = axis;
ax([1,2]) = [0.5,length(vehicle_legend)+3];
axis(ax);
print -dpng '../pbn_intx_by_vehicle_normed.png';
dumpcsv('../pbn_intx_by_vehicle_normed.csv', intersection_legend, vehicle_legend, intx_by_vehicle_normed);

% Repeat the figures but with classes switched
bar(intx_by_vehicle', 'stacked');
title('PBN crash occurrences by vehicle type and intersection');
xlabel('Intersection');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', intersection_legend)
ylabel('Count');
legend(vehicle_legend);
ax = axis;
ax([1,2]) = [0.5,length(intersection_legend)+2];
axis(ax);
print -dpng '../pbn_vehicle_by_intx.png';
dumpcsv('../pbn_vehicle_by_intx.csv', vehicle_legend, intersection_legend, intx_by_vehicle');

% ... and the normed version.
vehicle_by_intx_normed = intx_by_vehicle ./ repmat(sum(intx_by_vehicle, 1), [length(vehicle_legend), 1]);
bar(vehicle_by_intx_normed', 'stacked');
title('PBN crash occurrences by vehicle type and intersection (normalised)');
xlabel('Intersection');
% convert the speeds from numbers to a cell array of strings, and use as
% the tick labels
set(gca, 'xticklabel', intersection_legend)
ylabel('Proportion');
legend(vehicle_legend);
ax = axis;
ax([1,2]) = [0.5,length(intersection_legend)+2];
axis(ax);
print -dpng '../pbn_vehicle_by_intx_normed.png';
dumpcsv('../pbn_vehicle_by_intx_normed.csv', vehicle_legend, intersection_legend, vehicle_by_intx_normed');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% As above, but by severity rather than by vehicle
% Similar to above, is_severity(:, lights_crash_inds) gets all crashes at
% lights with rows indicating severity, and then we sum to get the number
% of crashes by severity for traffic lights.
intx_by_severity = [sum(is_severity(:, lights_crash_inds), 2), sum(is_severity(:, roundabout_crash_inds), 2), sum(is_severity(:, stop_crash_inds), 2), sum(is_severity(:, intx_crash_inds), 2), sum(is_severity(:, midblock_crash_inds), 2)];
% Repeat the figures
bar(intx_by_severity, 'stacked');
title('PBN crash occurrences by intersection and severity');
xlabel('Severity');
set(gca, 'xticklabel', severity_legend)
ylabel('Count');
legend(intersection_legend);
ax = axis;
ax([1,2]) = [0.5,length(severity_legend)+2.5];
axis(ax);
print -dpng '../pbn_intx_by_severity.png';
dumpcsv('../pbn_intx_by_severity.csv', intersection_legend, severity_legend, intx_by_severity);


% Now look at crash locations: intersection vs midblock, by vehicle type
% Repeat the figures
intx_by_severity_normed = intx_by_severity ./ repmat(sum(intx_by_severity, 2), [1, length(intersection_legend)]);
bar(intx_by_severity_normed, 'stacked');
title('PBN crash occurrences by intersection and severity (normalised)');
xlabel('Severity');
set(gca, 'xticklabel', severity_legend)
ylabel('Proportion');
legend(intersection_legend);
ax = axis;
ax([1,2]) = [0.5,length(severity_legend)+2.5];
axis(ax);
print -dpng '../pbn_intx_by_severity_normed.png';
dumpcsv('../pbn_intx_by_severity_normed.csv', intersection_legend, severity_legend, intx_by_severity_normed);

% Repeat the figures but with classes switched
bar(intx_by_severity', 'stacked');
title('PBN crash occurrences by severity and intersection');
xlabel('Intersection');
set(gca, 'xticklabel', intersection_legend)
ylabel('Count');
legend(severity_legend);
ax = axis;
ax([1,2]) = [0.5,length(intersection_legend)+2];
axis(ax);
print -dpng '../pbn_severity_by_intx.png';
dumpcsv('../pbn_severity_by_intx.csv', severity_legend, intersection_legend, intx_by_severity');

% ... and the normed version.
severity_by_intx_normed = intx_by_severity ./ repmat(sum(intx_by_severity, 1), [length(severity_legend), 1]);
bar(severity_by_intx_normed', 'stacked');
title('PBN crash occurrences by severity and intersection (normalised)');
xlabel('Intersection');
set(gca, 'xticklabel', intersection_legend)
ylabel('Proportion');
legend(severity_legend);
ax = axis;
ax([1,2]) = [0.5,length(intersection_legend)+2];
axis(ax);
print -dpng '../pbn_severity_by_intx_normed.png';
dumpcsv('../pbn_severity_by_intx_normed.csv', severity_legend, intersection_legend, severity_by_intx_normed');


